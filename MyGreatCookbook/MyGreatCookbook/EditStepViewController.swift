//
//  EditStepViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/18.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit

class EditStepViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var stepTextView: UITextView!
    
    var initText: String?
    
    var stepNum: Int? = nil
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let frame: CGRect = textView.frame
        print(self.view.frame.size)
        let offset: CGFloat = frame.origin.y + 100 - (self.view.frame.size.height - 330)
        
        if offset > 0  {
            self.view.frame = CGRect(x: 0, y: -offset, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepTextView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        if initText != nil {
            stepTextView.text = initText
            initText = nil
        }
    }
}
