//
//  IngredientTableViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/16.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit

class IngredientTableViewController: UITableViewController, UITextFieldDelegate {
    
    var ingredients = [(String?, String?)]()
    
    var rowBeingEdited: Int? = nil
    
    @IBAction func addLine(_ sender: UIButton) {
        ingredients.append((nil, nil))
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ingredients.count == 0 {
            ingredients.append((nil, nil))
        }
        return ingredients.count == 0 ? 1:ingredients.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Edit Ingredient Cell", for: indexPath) as! IngredientTableViewCell
        cell.ingredientNameText.tag = indexPath.row + 1
        cell.quantityText.tag = -indexPath.row - 1
        cell.ingredientNameText.delegate = self
        cell.quantityText.delegate = self
        if ingredients.count != 0 {
            cell.ingredientNameText.text = ingredients[indexPath.row].0
            cell.quantityText.text = ingredients[indexPath.row].1
        }
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let row = Swift.abs(textField.tag) - 1
        if row >= ingredients.count {
            while(ingredients.count <= row) {
                ingredients.append((nil, nil))
            }
        }
        
        if textField.tag > 0 {
            ingredients[row].0 = textField.text
        } else {
            ingredients[row].1 = textField.text
        }
        rowBeingEdited = nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rowBeingEdited = textField.tag
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*if let cell = textField.superview?.superview as? IngredientTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                if textField == cell.ingredientNameText {
                    ingredients[indexPath.row].0 = textField.text
                    print("Ingredient" , textField.text)
                } else if textField == cell.quantityText {
                    ingredients[indexPath.row].1 = textField.text
            }
        }*/
        //textField.becomeFirstResponder()
        textField.resignFirstResponder()
        return true
    }
}
