//
//  DetailRecipeTableViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/18.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class DetailRecipeTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var coverPhotoView: UIImageView!
    
    @IBOutlet weak var recipeNameField: UILabel!
    
    @IBAction func shareRecipe(_ sender: UIBarButtonItem) {
        let image = UIImage(view: self.view)
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    var recipe: Recipe!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showRecipe()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
    }
    
    private func showRecipe() {
        if let data = recipe.coverPhoto as? Data {
            coverPhotoView.image = UIImage(data: data)
        }
        recipeNameField.text = recipe?.name
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return recipe.ingredients.count
        } else {
            return recipe.steps.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Ingredient Cell", for: indexPath)
            cell.textLabel?.text = recipe.ingredients[indexPath.row]
            cell.detailTextLabel?.text = recipe.quantities[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Step Cell", for: indexPath) as! DetailStepTableViewCell
            if let data = recipe.stepPhotos[indexPath.row] {
                cell.stepPhotoView.image = UIImage(data: data)
            }
            cell.stepNumLabel.text = "\(indexPath.row + 1)"
            cell.stepDetailLabel.text = recipe.steps[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Ingredient"
        } else {
            return "Step"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationController = destinationViewController as? UINavigationController {
            destinationViewController = navigationController.visibleViewController ?? destinationViewController
        }
        if destinationViewController is CookPlanViewController {
            if let popoverPresentationController = segue.destination.popoverPresentationController {
                popoverPresentationController.delegate = self
            }
        }

    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
        ) -> UIModalPresentationStyle
    {
        if traitCollection.verticalSizeClass == .compact {
            return .none
        } else if traitCollection.horizontalSizeClass == .compact {
            return .overFullScreen
        } else {
            return .none
        }
    }

}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}
