//
//  AccessToken.swift
//  VK_Messenger
//
//  Created by Dima on 12/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import Foundation

class AccessToken {
    var token: String?
    var expires: NSDate?
    var userID: Int?
    
    init(dictionary: [String: AnyObject]) {
    
        token = dictionary["access_token"] as? String
        userID = Int(dictionary["user_id"] as! String)
        
        let timeInterval = Double(dictionary["expires_in"] as! String)
        expires = NSDate(timeIntervalSinceNow: timeInterval!)
    }
    
    static func parseResponse(response: String) -> [String: AnyObject] {

        var dict = [String: AnyObject]()
        let array = response.componentsSeparatedByString("#")
        
        if array.count > 1 {
            let string = array.last
            
            let components = string?.componentsSeparatedByString("&")
            
            for component in components! {
                
                let items = component.componentsSeparatedByString("=")
                
                if items.count == 2 {
                    dict[items.first!] = items.last!
                }
            }
        }
        return dict
    }
}