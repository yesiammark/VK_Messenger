//
//  Message.swift
//  VK_Messenger
//
//  Created by Dima on 18/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import Foundation

class Message {
    var body: String?
    var userID: Int!
    var fromID: Int!
    var date: Double!
    
    init(response: NSDictionary) {
        body = response["body"] as? String
        userID = response["user_id"] as! Int
        fromID = response["from_id"] as! Int
        date = response["date"] as! Double
    }
    
    func addPhotoMessage() {
        
    }
    
}