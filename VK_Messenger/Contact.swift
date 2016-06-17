//
//  Contacts.swift
//  VK_Messenger
//
//  Created by Dima on 16/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import Foundation

class Contact {
    var userID: Int?
    var firstName: String?
    var lastName: String?
    var imageLink: String?
    var online: Int?
    var fullName: String {
        return firstName! + " " + lastName!
    }
    
    init(response: NSDictionary) {
        userID = response["id"] as? Int
        firstName = response["first_name"] as? String
        lastName = response["last_name"] as? String
        imageLink = response["photo_50"] as? String
        online = response["online"] as? Int
    }
}