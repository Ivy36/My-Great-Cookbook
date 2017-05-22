//
//  CookPlanViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/19.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import EventKit

class CookPlanViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var eventTextField: UITextField!
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
         presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func saveEvent(_ sender: UIBarButtonItem) {
        let store = EKEventStore()
        store.requestAccess(to: .event) { (bool, error) in
            print(bool ? "init success" : "init fail")
        }
        let newEvent = EKEvent(eventStore: store)
        let alarm = EKAlarm(relativeOffset: -60 * 60)
        newEvent.title = self.eventTextField.text!
        newEvent.notes = "Buy ingredients"
        newEvent.addAlarm(alarm)
        newEvent.startDate = self.datePicker.date
        newEvent.endDate = newEvent.startDate.addingTimeInterval(60*60)
        newEvent.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(newEvent, span: .thisEvent)
            let alert = UIAlertController(title: "Add Event Successfully", message: nil, preferredStyle: .alert)
            present(alert, animated: true)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            print("add event")
        } catch let error as NSError {
            print (error, "fail to add event")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let popoverPresentationController = navigationController?.popoverPresentationController {
            if popoverPresentationController.arrowDirection != .unknown {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Plan"
    }
}
