//
//  NewTimerViewController.swift
//  MyGreatCookbook
//
//  Created by Jing on 17/3/19.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
import UserNotifications

class NewTimerViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    private var timer: Timer?
    
    private var countTime: Int = 0
    
    private var countSec: Int = 0
    
    private var isTimerRunning = false
    
    private var resumeTapped = false
    
    private var isGrantedNotificationAccess = false

    @IBOutlet weak var startBtn: UIButton!
   
    @IBOutlet weak var stopBtn: UIButton!
    
    @IBOutlet weak var zeroLabel: UILabel!
    
    @IBOutlet weak var secondLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    
    @IBOutlet weak var timerPicker: UIDatePicker!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var alarmImageView: UIImageView!
    
    @IBAction func timerStart(_ sender: UIButton) {
            zeroLabel.isHidden = true
            stopBtn.isEnabled = true
            startBtn.isEnabled = false
            //messageLabel.text = ""
            timerPicker.isEnabled = false
            stepper.isEnabled = false
            countSec = Int(stepper.value)
            //print(timerPicker.countDownDuration)
            countTime = Int(timerPicker.countDownDuration) - Int(timerPicker.countDownDuration) % 60 + countSec
            sendNotification()
            messageLabel.text = toTimeString(time: TimeInterval(countTime))
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(countDown)), userInfo: nil, repeats: true)
    }
    
    func countDown() {
        countSec -= 1
        countTime -= 1
        messageLabel.text = toTimeString(time: TimeInterval(countTime))
        if countSec == -1 {
            if countTime < 0 {
                messageLabel.text = toTimeString(time: TimeInterval(0))
                handleTimeOver()
                stop()
            } else {
                countSec = 59
                secondLabel.text = "\(countSec)" + " s"
                timerPicker.countDownDuration = TimeInterval(countTime)
                if countTime < 60 {
                    zeroLabel.isHidden = false
                }
            }
        } else {
            secondLabel.text = "\(countSec)" + " s"
        }
    }

    @IBAction func timerStop(_ sender: UIButton) {
        stop()
    }
    
    private func stop() {
        stopBtn.isEnabled = false
        startBtn.isEnabled = true
        zeroLabel.isHidden = true
        timerPicker.isEnabled = true
        stepper.isEnabled = true
        stepper.value = 0
        secondLabel.text = "0 s"
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerStopMsg"])
    }
    
    private func handleTimeOver() {
        let alert = UIAlertController(title: "Timing Complete", message: "Watch out for your food!", preferredStyle: .alert)
        present(alert, animated: true)
        let systemSoundID: SystemSoundID = 1151
        AudioServicesPlayAlertSound(systemSoundID)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        soundAlert()
    }
    
    private func toTimeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let min = Int(time) / 60 % 60
        let second = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hour, min, second)
    }
    
    @IBAction func changeSecond(_ sender: UIStepper) {
        secondLabel.text = "\(Int(stepper.value))" + " s"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.minimumValue = 0
        stepper.maximumValue = 59
        stopBtn.isEnabled = false
        secondLabel.text = "0 s"
        messageLabel.text = toTimeString(time: TimeInterval(0))
        zeroLabel.isHidden = true
        alarmImageView.image = #imageLiteral(resourceName: "alarm")
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound],
            completionHandler: { (granted,error) in
                self.isGrantedNotificationAccess = granted
        })
    }
    
    private func sendNotification() {
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = "Timing Complete"
            content.body = "Watch out for your food!"
            content.sound = UNNotificationSound.default()
            
            //Set the trigger of the notification -- here a timer.
            let date = Date(timeIntervalSinceNow: TimeInterval(countTime))
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate,
                                                        repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(
                identifier: "timerStopMsg",
                content: content,
                trigger: trigger
            )
            
            //Add the notification to the currnet notification center
            //UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().add(request) { (error) in
                UNUserNotificationCenter.current().delegate = self
            }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")  
        default:
            print("Unknown action")
        }
        completionHandler()
    }
    
    private func soundAlert() {
        let systemSoundID: SystemSoundID = 1304
        AudioServicesPlaySystemSound(systemSoundID)
        AudioServicesPlaySystemSoundWithCompletion(systemSoundID) {
            _ in
            AudioServicesPlaySystemSound(systemSoundID)
        }
    }
}
