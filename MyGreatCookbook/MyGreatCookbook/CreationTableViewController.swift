//
//  CreationTableViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/12.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class CreationTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var recipe: Recipe?
    
    private var coverImagePicker = UIImagePickerController()
    
    private var stepImagePicker = UIImagePickerController()
    
    private var setImageIndex = 0
    
    var date = Date()
    
    var ingredients = [(String?, String?)]()
    
    var step = [(Data?, String?)]()
    
    var container = AppDelegate.persistentContainer
    
    
    @IBOutlet weak var addCoverPlaceHolder: UILabel!
    
    @IBOutlet weak var coverPhotoView: UIImageView!
    
    @IBOutlet weak var addStepBtn: UIButton!
    
    @IBOutlet weak var recipeNameTextField: UITextField!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateIngredientTable (from segue: UIStoryboardSegue) {
        if let editor = segue.source as? IngredientTableViewController {
            if let row = editor.rowBeingEdited {
                let indexPath = NSIndexPath(row: Swift.abs(row) - 1, section: 0)
                if let cell = editor.tableView.cellForRow(at: indexPath as IndexPath) as? IngredientTableViewCell {
                    if row > 0 {
                        cell.ingredientNameText.resignFirstResponder()
                    } else {
                        cell.quantityText.resignFirstResponder()
                    }
                }
            }
            ingredients = editor.ingredients
            var i = ingredients.count - 1
            while(i >= 0) {
                if (ingredients[i].0 == nil || ingredients[i].0?.characters.count == 0) && (ingredients[i].1 == nil || ingredients[i].1?.characters.count == 0){
                    ingredients.remove(at: i)
                }
                i -= 1
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func updateStep (from segue: UIStoryboardSegue) {
        if let editor = segue.source as? EditStepViewController {
            step[editor.stepNum!].1 = editor.stepTextView.text
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture(toImage: coverPhotoView)
        coverImagePicker.allowsEditing = true
        stepImagePicker.allowsEditing = true
        recipeNameTextField.delegate = self
        if recipe != nil {
            if let data = recipe?.coverPhoto as? Data {
                coverPhotoView.image = UIImage(data: data)
            }
            recipeNameTextField.text = recipe!.name
            ingredients.removeAll()
            var i = 0
            while(i < recipe!.ingredients.count) {
                ingredients.append((recipe!.ingredients[i], recipe!.quantities[i]))
                i += 1
            }
            step.removeAll()
            i = 0
            while(i < recipe!.steps.count) {
                step.append((recipe!.stepPhotos[i], recipe!.steps[i]))
                i += 1
            }
        }
        if coverPhotoView.image != nil {
            addCoverPlaceHolder.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func addTapGesture(toImage imageView: UIImageView) {
        let handler = #selector(addImage(byReactingTo:))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: handler)
        tapRecognizer.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleToFill
        imageView.addGestureRecognizer(tapRecognizer)
    }
    
    func addImage(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        switch tapRecognizer.state {
        case .ended:
            let alert = UIAlertController(title:nil, message:nil, preferredStyle: .actionSheet)
            if tapRecognizer.view == coverPhotoView {
                alert.addAction(UIAlertAction(title: "Album",
                                              style: .default,
                                              handler: { [weak self, coverImagePicker] _ in self?.openAlbum(coverImagePicker)}))
                alert.addAction(UIAlertAction(title: "Camera",
                                              style: .default,
                                              handler: { [weak self, coverImagePicker] _ in self?.openCamera(coverImagePicker)}))
            } else {
                let tappedLocation = tapRecognizer.location(in: tableView)
                if let indexPath = tableView.indexPathForRow(at: tappedLocation) {
                    setImageIndex =  indexPath.row
                }
                
                alert.addAction(UIAlertAction(title: "Album",
                                              style: .default,
                                              handler: { [weak self, stepImagePicker] _ in self?.openAlbum(stepImagePicker)}))
                alert.addAction(UIAlertAction(title: "Camera",
                                              style: .default,
                                              handler: { [weak self, stepImagePicker] _ in self?.openCamera(stepImagePicker)}))
            }
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            break   
        }
    }

    private func openAlbum(_ imagePicker: UIImagePickerController) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func openCamera(_ imagePicker: UIImagePickerController) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Warning", message: "You don't have a camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            imagePicker.delegate = self
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            if picker == coverImagePicker {
                coverPhotoView.image = image
                addCoverPlaceHolder.isHidden = true
            } else {
                step[setImageIndex].0 = UIImagePNGRepresentation(image)
                tableView.reloadData()
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recipeNameTextField.resignFirstResponder()
        return true
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return ingredients.count > 0 ? ingredients.count:1
        } else {
            return (step.count > 0) ? step.count : 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if ingredients.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Add Ingredient", for: indexPath)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Ingredient Cell", for: indexPath)
                cell.textLabel?.text = ingredients[indexPath.row].0
                cell.detailTextLabel?.text = ingredients[indexPath.row].1
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Step Cell", for: indexPath) as! StepTableViewCell
            addTapGesture(toImage: cell.stepImageView)
            if step.count > indexPath.row {
                if let data = step[indexPath.row].0 {
                    cell.stepImageView.image = UIImage(data: data)
                    cell.stepImagePlaceHolder.isHidden = true
                }
                if let text = step[indexPath.row].1 {
                    cell.stepDetailLabel.text = text
                }
            } else {
                while(step.count <= indexPath.row) {
                    step.append((nil, nil))
                }
            }
            cell.stepNumLabel.text =  "\(indexPath.row + 1)"
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Ingredient"
        } else if section == 1 {
            return "Step"
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return CGFloat(190)
        }
    }
    
    
    @IBAction func addStepCell(_ sender: UIButton) {
        step.append((nil,nil))
        tableView.reloadData()
    }
    
    @IBAction func rearrangeStep(_ sender: UIButton) {
        self.isEditing = !self.isEditing
        /*if self.isEditing {
            sender.setTitle("OK", for: .selected)
        } else {
            sender.setTitle("Rearrange", for: .normal)
        }*/
        //tableView.setEditing(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination
        if let identifier = segue.identifier {
            switch identifier {
                case "Edit Ingredient" :
                    if let ingredientTableVC = destinationVC as? IngredientTableViewController {
                        ingredientTableVC.ingredients = ingredients
                }
                case "Edit Step" :
                    if let cell = sender as? StepTableViewCell, let editStepVC = destinationVC as? EditStepViewController, let indexPath = tableView.indexPath(for: cell) {
                        editStepVC.title = "Step " + "\(indexPath.row + 1)"
                        editStepVC.stepNum = indexPath.row
                        if let text = step[indexPath.row].1 {
                            editStepVC.initText = text
                        }
                }
                default: break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        var finalIndexPath: IndexPath? = nil
        if proposedDestinationIndexPath.section == 0 {
            finalIndexPath = IndexPath(row: 0, section: 1)
        } else if proposedDestinationIndexPath.section == 1 {
            finalIndexPath = proposedDestinationIndexPath
        }
        return finalIndexPath!
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var temp : (Data?, String?) = (nil, nil)
        temp = step[sourceIndexPath.row]
        step[sourceIndexPath.row] = step[destinationIndexPath.row]
        step[destinationIndexPath.row] = temp
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(indexPath.row)
            if step.count > 1 {
              step.remove(at: indexPath.row)
            }
            tableView.isEditing = false
            //print(step)
            tableView.reloadData()
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "Save New Recipe" {
            if coverPhotoView.image == nil {
                handleNoCover()
                return false
            }
            if recipeNameTextField.text == nil || recipeNameTextField.text!.isEmpty {
                handleNoName()
                return false
            }
            if ingredients.count == 0 {
                handleNoIngredients()
                return false
            }
            for eachStep in step {
                if eachStep.0 == nil || eachStep.1 == nil {
                    handleUncompleteStep()
                    return false
                }
            }
        }
        if identifier == "Save Draft" {
            if recipeNameTextField.text == nil || recipeNameTextField.text!.isEmpty {
                handleNoName()
                return false
            }
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    private func handleNoCover() {
        let alert = UIAlertController(title: "Missing Cover", message: "A recipe must have a cover photo.", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    private func handleNoName() {
        let alert = UIAlertController(title: "Missing Name", message: "A recipe must have a name.", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    private func handleNoIngredients() {
        let alert = UIAlertController(title: "Missing Ingredient", message: "A recipe must have some ingredients.", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
    private func handleUncompleteStep() {
        let alert = UIAlertController(title: "Step Uncompleted", message: "Some steps may miss details.", preferredStyle: .alert)
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    
}

