//
//  ContactsGroups.swift
//  VK_Messenger
//
//  Created by Dima on 17/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import Foundation

class ContactsGroups {
    
    var section: String?
    var itemsArray: [Contact]?
    
    static func createGroups(contacts: [Contact]) -> [ContactsGroups] {
        
        var contactGroups = [ContactsGroups]() //main array

        let group = ContactsGroups()
        group.itemsArray = [Contact]()
        group.section = "Favorites"
        
        for contact in contacts[0..<5] {
            group.itemsArray!.append(contact)
        }
        contactGroups.append(group)
        
        var currentCharacter: Character?
        
        for item in contacts.sort({ (item1, item2) -> Bool in
            if item1.firstName == item2.firstName {
                return item1.lastName < item2.lastName
            }
            return item1.firstName < item2.firstName
        }) {
            let firstCharacter = item.firstName?.characters.first
            var group = ContactsGroups()
            group.itemsArray = [Contact]()
            
            if firstCharacter != currentCharacter {
                currentCharacter = firstCharacter
                group.section = "\(firstCharacter!)"
                contactGroups.append(group)
            } else {
                group = contactGroups.last!
            }
            group.itemsArray!.append(item)
        }
        
        return contactGroups
    }
}