//
//  AppDelegate.swift
//  studyBuddy
//
//  Created by Hayden Kreuter on 6/5/19.
//  Copyright © 2019 Hayden Kreuter. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    func applicationWillResignActive(_ application: UIApplication) {
        do {
            try context.save()
        } catch {
            
        }
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // makes core data storage available
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if error == nil {
                self.context = self.container.viewContext
            } else {
                print("Error")
            }
        })
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {

                var spellingLists: [WordListEntity] = []
                var nextTestList: WordListEntity?
                let request: NSFetchRequest<WordListEntity> = WordListEntity.fetchRequest()
                do {
                    spellingLists = try self.context.fetch(request)
                } catch {}
                
                for list in spellingLists {
                    if let date = list.testDate {
                        if date > Date().addingTimeInterval(86399) {
                            if nextTestList != nil {
                                if date < nextTestList!.testDate! {
                                    nextTestList = list
                                }
                            } else {
                                nextTestList = list
                            }
                        }
           
                    }
                }
                
                if let listToNotify = nextTestList {
                    self.scheduleNotifications(list: listToNotify)
                }
        
                
                
            }
        })
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let data = try? Data(contentsOf: url) {
            if let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? Dictionary<String, Any> {
                loadFromDictionary(dictionary: dictionary)
            }
        }
        
        
        return true
    }

    
    func loadFromDictionary(dictionary: Dictionary<String, Any>) {
        var listName: String! = "Imported List"
        let dateCreated: Date! = Date()
        var testDate: Date?
        
        
        
        if let name = dictionary["listName"] as? String {
            listName = name
        }
    
        
        if let testDateInterval = dictionary["testDate"] as? TimeInterval {
            testDate = Date(timeIntervalSince1970: testDateInterval)
        }
        
        let app = UIApplication.shared
        let appDelegate = app.delegate as! AppDelegate
        let context = appDelegate.context
        
        let newListEntity = WordListEntity(context: context!)
        newListEntity.listName = listName
        newListEntity.dateCreated = dateCreated
        newListEntity.testDate = testDate
        
        
        if let words = dictionary["words"] as? [Dictionary<String, Any>] {
            for word in words {
                guard let wordName = word["wordName"] as? String else {
                    continue
                }
                guard let order = word["order"] as? Int16 else {
                    continue
                }
                
                guard let audioData = word["audioRecordingData"] as? String else {
                    continue
                }
                
                let newWord: WordEntity = WordEntity(context: context!)
                newWord.wordName = wordName
                newWord.order = order
                
                
                if let voiceData = Data(base64Encoded: audioData) {
                    let uuid = UUID().uuidString + ".m4a"
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let documentDirectory = paths[0]
                    let fileName = documentDirectory.appendingPathComponent(uuid)
                    
                    do {
                        try voiceData.write(to: fileName, options: .atomic)
                    } catch {
                        
                    }
                    newWord.recordingPath = uuid
                } else {
                    newWord.recordingPath = "0"
                }
                
                newWord.wordListEntity = newListEntity
            }
            
        }
        
        do {
            try context!.save()
        } catch {
            
        }
        
        let tempNavController = self.window?.rootViewController as! UINavigationController
        let tempVC = tempNavController.viewControllers.first as! HomeViewController
        tempVC.openLinkedList(newList: newListEntity)
        
    }
    
    func scheduleNotifications(list: WordListEntity) {

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        if let enteredTestDate = list.testDate {
            let dayBefore: Date = enteredTestDate.addingTimeInterval(-3600 * 8)
            let twoDayBefore: Date = dayBefore.addingTimeInterval(-86400)
            let threeDaysBefore: Date = twoDayBefore.addingTimeInterval(-86400)
            let listMastery: Double = Double(round(10 * (list.calculateMastery() * 100)) / 10)
            let currentDate: Date = Date()
            
            if dayBefore > currentDate {
                var title: String = ""
                var body: String = ""
                if listMastery < 60 && list.wordsStudied < list.wordEntity!.count * 2 {
                    title = "It's study time!"
                    body = "It looks like you haven’t studied much for your test tomorrow. That's okay! I can help you learn your words. Let's do this!"
                } else if listMastery > 80 {
                    title = "Let's review for tomorrow's test!"
                    body = "It looks like you know these words pretty well. Let's take a practice test so you can ace this tomorrow!"
                } else {
                    title = "Let's review for tomorrow's test!"
                    body = "You're current mastery is at \(listMastery)%. Let's get to 100%! today!"
                }
                createNotification(title: title , body: body, date: dayBefore, id: "oneDayBeforeTest")
            }
            
            if twoDayBefore > currentDate {
                var title: String = ""
                var body: String = ""

                if listMastery < 60 && list.wordsStudied < list.wordEntity!.count * 2 {
                    title = "Come study with me!"
                    body = "It looks like you haven’t studied much for your test. That's okay! I can help you learn your words. Let's do this!"
                } else if listMastery > 75 {
                    title = "Let's review for your test."
                    body = "It looks like you are on track for your text in 2 days. Let's brush up on your skills so you'll do great!"
                } else {
                    title = "Let's review for your test!"
                    body = "You're current mastery is at \(listMastery)%. Let's get to 75% today!"
                }
                createNotification(title: title , body: body, date: twoDayBefore, id: "twoDaysBeforeTest")
            }
            
            if threeDaysBefore > currentDate {
                let title: String = "Let's Study!"
                let body: String = "How about a little study session to get ready for your test?"

                createNotification(title: title , body: body, date: threeDaysBefore, id: "threeDaysBeforeTest")
            }
            

            }
        }
    
    func createNotification(title: String, body: String, date: Date, id: String) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: date.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        

    }
    
}

