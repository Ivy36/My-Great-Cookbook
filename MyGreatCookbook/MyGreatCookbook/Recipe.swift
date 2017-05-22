//
//  Recipe.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/18.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import CoreData

class Recipe: NSManagedObject {
    /*var steps: [(Data?, String?)] {
        get {
            return NSKeyedUnarchiver.unarchiveObject(with: stepList) as! [(Data?, String?)]
            //return (stepList as? [(Data?, String?)]? ?? [])!
        }
        set {
            stepList = NSKeyedArchiver.archivedData(withRootObject: newValue)
        }
    }*/
    
    var stepPhotos: [Data?] {
        get {
            return stepPhotoList as? Array<Data?> ?? []
        }
        set {
            stepPhotoList = newValue as NSArray
        }
    }
    
    var steps: [String?] {
        get {
            return stepDetailList as? Array<String?> ?? []
        }
        set {
            stepDetailList = newValue as NSArray
        }
    }
    
    var ingredients: [String?] {
        get {
            return ingredientList as? [String?] ?? []
        }
        set {
            ingredientList = newValue as NSArray
        }
    }
    
    var quantities: [String?] {
        get {
            return quantityList as? [String?] ?? []
        }
        set {
            quantityList = newValue as NSArray
        }
    }
}
