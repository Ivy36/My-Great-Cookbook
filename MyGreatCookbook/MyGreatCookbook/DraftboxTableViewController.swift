//
//  DraftboxTableViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/18.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class DraftboxTableViewController: FetchedResultsTableViewController {
    
    var drafts = [Recipe]()
    
    var container = AppDelegate.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    @IBAction func saveDraft(from segue: UIStoryboardSegue) {
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
                    newRecipe.isDraft = true
                    try? context.save()
            } else {
                container.performBackgroundTask{ context in
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
                    updateRecipe.isDraft = true
                    try? context.save()
            }
            }
            updateUI()
            //self.viewDidLoad()
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Recipe>?
    
    private func updateUI() {
        let context = container.viewContext
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let textSort = NSSortDescriptor(key:"name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        request.sortDescriptors = [textSort]
        request.predicate = NSPredicate(format: "isDraft = true")
        drafts = try! context.fetch(request)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Draft Cell", for: indexPath)
            cell.textLabel?.text = drafts[indexPath.row].name
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            cell.detailTextLabel?.text = dateFormatter.string(from: drafts[indexPath.row].unique as! Date)
            return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drafts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //updateUI()
        tableView.tableFooterView = UIView()
        self.title = "Draft"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination
        if let identifier = segue.identifier{
            switch identifier {
            case "Edit Draft":
                if let cell = sender as? UITableViewCell, let navigationVC = destinationVC as? UINavigationController, let creationTableVC = navigationVC.visibleViewController as?  CreationTableViewController, let indexPath = tableView.indexPath(for: cell){
                    creationTableVC.recipe = drafts[indexPath.row]
                }
            default:
                break
            }
        }

    }
    
    @IBAction func deleteDraft(_ sender: UIBarButtonItem) {
        self.isEditing = !self.isEditing
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = container.viewContext
            let delDraft = drafts[indexPath.row]
            let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
            request.predicate = NSPredicate(format: "unique = %@", delDraft.unique!)
            do {
                let fetchedObj = try? context.fetch(request)
                guard (fetchedObj?.count)! > 0 else { print("not found in coredata"); return }
                
                context.delete(fetchedObj![0])
                try context.save()
                print("del success")
            }catch{
                print("CoreData delete data fail")
            }
            updateUI()
            self.viewDidLoad()
            tableView.isEditing = false
        }
    }

}
