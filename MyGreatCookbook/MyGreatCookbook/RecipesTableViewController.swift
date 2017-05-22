//
//  RecipesTableViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/18.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class RecipesTableViewController: FetchedResultsTableViewController, UISearchBarDelegate {
    
    var recipes = [Recipe]()//? = nil
    
    var recipeSearch = [Recipe]()

    var container = AppDelegate.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var fetchedResultsController: NSFetchedResultsController<Recipe>?
    
    @IBAction func saveNewRecipe(from segue: UIStoryboardSegue) {
        if let editor = segue.source as? CreationTableViewController {
            let context = container.viewContext
            if editor.recipe == nil {
                    let newRecipe = Recipe(context: context)
                    if let image = editor.coverPhotoView.image {
                        newRecipe.coverPhoto = UIImagePNGRepresentation(image)! as NSData
                    }
                    newRecipe.name = editor.recipeNameTextField.text
                    newRecipe.unique = editor.date as NSDate
                    var newIngredientArray = [String?]()
                    var newQuantityArray = [String?]()
                    var newStepPhotoArray = [Data?]()
                    var newStepDetailArray = [String?]()
                    var i = 0
                    while( i < editor.ingredients.count) {
                            newIngredientArray.append(editor.ingredients[i].0)
                            newQuantityArray.append(editor.ingredients[i].1)
                            i += 1
                        }
                    
                    i = 0
                    while( i < editor.step.count) {
                            newStepPhotoArray.append(editor.step[i].0)
                            newStepDetailArray.append(editor.step[i].1)
                            i += 1
                        }
                    newRecipe.ingredients = newIngredientArray
                    newRecipe.quantities = newQuantityArray
                    newRecipe.stepPhotos = newStepPhotoArray
                    newRecipe.steps = newStepDetailArray
                    
                    newRecipe.isDraft = false
                    try? context.save()
            } else {
                    let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
                    request.predicate = NSPredicate(format: "unique = %@", editor.recipe!.unique!)
                    let fetchedObj = try? context.fetch(request)
                    guard (fetchedObj?.count)! > 0 else { print("not found in coredata"); return }
                    let updateRecipe = fetchedObj![0]
                    if let image = editor.coverPhotoView.image {
                        updateRecipe.coverPhoto = UIImagePNGRepresentation(image)! as NSData
                    }
                    updateRecipe.name = editor.recipeNameTextField.text
                    var i = 0
                    updateRecipe.ingredients.removeAll()
                    updateRecipe.quantities.removeAll()
                    updateRecipe.stepPhotos.removeAll()
                    updateRecipe.steps.removeAll()
                    
                    while( i < editor.ingredients.count) {
                        updateRecipe.ingredients.append(editor.ingredients[i].0)
                        updateRecipe.quantities.append(editor.ingredients[i].1)
                        i += 1
                    }
                    
                    i = 0
                    while( i < editor.step.count) {
                        updateRecipe.stepPhotos.append(editor.step[i].0)
                        updateRecipe.steps.append(editor.step[i].1)
                        i += 1
                    }
                    updateRecipe.isDraft = false
                    try! context.save()
                }
            updateUI()
            self.viewDidLoad()            
        }
    }
    
    private func updateUI() {
            let  context = container.viewContext
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            let textSort = NSSortDescriptor(key:"name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
            request.sortDescriptors = [textSort]
            request.predicate = NSPredicate(format: "isDraft = false")
            recipes = try! context.fetch(request)
            recipeSearch = recipes
            tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recipe Cell", for: indexPath) as! RecipeTableViewCell
        
         let recipe = recipeSearch[indexPath.row]
         if let data = recipe.coverPhoto {
                cell.recipeImage.image = UIImage(data: data as Data )
            } else {
                cell.recipeImage.image = nil
            }
            cell.recipeNameLabel.text = recipe.name
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidLoad() {
        updateUI()
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        searchBar.text = ""
        searchBar.delegate = self
        recipeSearch = recipes
        self.title = "Recipes"
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            recipeSearch = recipes
        } else {
            recipeSearch = []
            for recipe in recipes {
                if (recipe.name?.hasPrefix(searchText))! {
                    recipeSearch.append(recipe)
                }
            }
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination
        if let identifier = segue.identifier{
            switch identifier {
            case "Show Recipe Detail":
                if let cell = sender as? RecipeTableViewCell, let detailRecipeVC = destinationVC as? DetailRecipeTableViewController, let indexPath = tableView.indexPath(for: cell){
                    detailRecipeVC.recipe = recipeSearch[indexPath.row]
                }
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeSearch.count
    }

    @IBAction func deleteRecipe(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delRecipe = recipeSearch[indexPath.row]
            container.performBackgroundTask{ context in
                    let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
                    request.predicate = NSPredicate(format: "unique = %@", delRecipe.unique!)
                do {
                    let fetchedObj = try? context.fetch(request)
                    guard (fetchedObj?.count)! > 0 else { print("not found in coredata"); return }
                    
                    context.delete(fetchedObj![0])
                    try context.save()
                    print("del success")
                    
                }catch{
                    print("CoreData delete data fail")
                }
                
            }
            recipeSearch.remove(at: indexPath.row)
            updateUI()
            self.viewDidLoad()
            tableView.isEditing = false
        }
    }
}
