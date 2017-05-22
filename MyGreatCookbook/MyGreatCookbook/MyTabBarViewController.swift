//
//  MyTabBarViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/19.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit

class MyTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        // Do any additional setup after loading the view.
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        viewController.viewDidLoad()
        return true
    }
    
}
