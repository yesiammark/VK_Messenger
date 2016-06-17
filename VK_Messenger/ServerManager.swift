//
//  ServerManager.swift
//  VK_Messenger
//
//  Created by Dima on 13/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import Foundation
import Alamofire
import JSQMessagesViewController

class ServerManager {
    static var sharedManager = ServerManager()
    
    func refreshToken(complition: ()->()) {
        
        request(.GET, "https://oauth.vk.com/authorize?client_id=5275598&display=page&redirect_uri=https://oauth.vk.com/blank.html&scope=friends,messages&response_type=token&v=5.45").response { (_, response, _, error) -> Void in
            
            if let response = response?.URL?.description {
                if response.containsString("access_token") {
                    
                    let accessToken = AccessToken(dictionary: AccessToken.parseResponse(response))
                    
                    NSUserDefaults.standardUserDefaults().setObject(accessToken.token!, forKey: "access_token")
                    NSUserDefaults.standardUserDefaults().setObject(accessToken.expires!, forKey: "expires_in")
                    NSUserDefaults.standardUserDefaults().setObject(accessToken.userID!, forKey: "user_id")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    complition()
                }
            }
        }
    }
    
    func checkTokenIsExpire(complition: ()->()) {
        
        if let tokenDate = NSUserDefaults.standardUserDefaults().valueForKey("expires_in") as? NSDate {
            
            if tokenDate.compare(NSDate()) == NSComparisonResult.OrderedAscending {
               
                //refresh
                refreshToken({ () -> () in
                    complition()
                    return
                })
            }
            complition()
        }
    }
    
    func getContacts(count: Int, offset: Int, complition:([Contact], count: Int, error: NSError?) -> ()) {
        
        checkTokenIsExpire { () -> () in
            if let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("access_token") {
                
                let params: [String: AnyObject] = [
                    "order": "hints",
                    "count": count,
                    "offset": offset,
                    "fields": "photo_50,online",
                    "name_case": "nom",
                    "v": "5.45",
                    "access_token": accessToken]
                
                request(.GET, "https://api.vk.com/method/friends.get", parameters: params).responseJSON { (response) -> Void in
                    if let JSON = response.result.value {
                        if let responseJSON = JSON["response"] as? NSDictionary {
                            let count = responseJSON["count"] as! Int
                            var contacts = [Contact]()
                            
                            if let items = responseJSON["items"] as? NSArray {
                                for item in items {
                                    let contact = Contact(response: item as! NSDictionary)
                                    contacts.append(contact)
                                }
                            }
                            
                            complition(contacts, count: count, error: nil)
                        }
                    }
                }
            }
        }
    }
    
    func getDialogs(offset:Int, success:(dialogs: [Dialog], count: Int, error: NSError?) -> ()) {
        
        checkTokenIsExpire { () -> () in
            if let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("access_token") {
                
                let params: [String: AnyObject] = [
                    "offset": offset,
                    "v": "5.45",
                    "access_token": accessToken]
                
                request(.GET, "https://api.vk.com/method/messages.getDialogs", parameters: params).responseJSON { (response) -> Void in
                    var dialogs = [Dialog]()
                    var count = 0
                    
                    if let JSON = response.result.value {
                        if let responseJSON = JSON["response"] as? NSDictionary {
                            
                            count = responseJSON["count"] as! Int
                            
                            if let items = responseJSON["items"] as? NSArray {
                                
                                for item in items {
                                    let dialog = Dialog(response: item as! NSDictionary)
                                    dialogs.append(dialog)
                                }
                                
                            }
                        }
                    }
                    success(dialogs: dialogs, count: count, error: response.result.error)
                }
            }
        }
    }
    
    func getUserByID(id: String, success:([Int: Contact]) -> (), error: (NSError) -> ()) {
        
        let params: [String: AnyObject] = [
            "user_ids": id,
            "fields": "photo_50,online",
            "name_case": "Nom",
            "v": "5.45"]
        
        request(.GET, "https://api.vk.com/method/users.get", parameters: params).responseJSON { (response) -> Void in
            if let JSON = response.result.value {
                if let items = JSON["response"] as? NSArray {
                    var contacts = [Int: Contact]()
                    for item in items {
                        let contact = Contact(response: item as! NSDictionary)
                        contacts[contact.userID!] = contact
                    }
                    success(contacts)
                }
            }
        }
    }
    
    func getMessagesHistoryForUserID(userID: Int, offset: Int, complition: ([JSQMessage], NSError?) -> ()){
        
        checkTokenIsExpire { () -> () in
            if let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("access_token") {
                let params: [String: AnyObject] = [
                    "offset": offset,
                    "user_id": userID,
                    "v": "5.45",
                    "access_token": accessToken]
                
                request(.GET, "https://api.vk.com/method/messages.getHistory", parameters: params).responseJSON(completionHandler: { (response) -> Void in
                    
                    var messages = [JSQMessage]()
                    
                    if let JSON = response.result.value {
                        if let response = JSON["response"] as? NSDictionary {
                            if let items = response["items"] as? NSArray {
                                for item in items {
                                    
                                    let messageItem = Message(response: item as! NSDictionary)
                                    let date = NSDate(timeIntervalSince1970: messageItem.date)
                                
                                    let message = JSQMessage(senderId: String(messageItem.fromID), senderDisplayName: String(messageItem.userID), date: date, text: messageItem.body)
                                    
                                    messages.append(message)
                                }
                            }
                        }
                    }
                    complition(messages, response.result.error)
                })
            }
        }
    }
    
    func postMessageForUserID(userID: Int, message: String) {
        
        checkTokenIsExpire { () -> () in
            if let accessToken = NSUserDefaults.standardUserDefaults().valueForKey("access_token") {
                let params: [String: AnyObject] = [
                    "user_id": userID,
                    "message": message,
                    "v": "5.45",
                    "access_token": accessToken]
                
                request(.POST, "https://api.vk.com/method/messages.send", parameters: params).responseJSON(completionHandler: { (response) -> Void in
                    print(response)
                })
            }
        }
    }
    
}