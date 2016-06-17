//
//  Dialogs.swift
//  VK_Messenger
//
//  Created by Dima on 16/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import Foundation

class Dialog {
    var messageID: Int?
    var unixTime: Double?
    var out: Int?
    var userID: Int?
    var readState: Int?
    var text: String?
    var attachmentsType: String?
    var action: String?
    
    init(response: NSDictionary) {
        
        if let message = response["message"] as? NSDictionary {
            messageID = message["id"] as? Int
            unixTime = message["date"] as? Double
            out = message["out"] as? Int
            userID = message["user_id"] as? Int
            readState = message["read_state"] as? Int
            text = message["body"] as? String
            
            if let attachments = message["attachments"] as? NSArray {
                for item in attachments {
                    if let type = item["type"] {
                        attachmentsType = type as? String
                    }
                }
            }
            if let value = message["action"] {
                action = value as? String
            }
        }
    }
}