//
//  DialogsTableViewController.swift
//  VK_Messenger
//
//  Created by Dima on 16/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import UIKit

class DialogsTableViewController: UITableViewController {

    var dialogsArray = [Dialog]()
    var totalDialogs: Int?
    var contactsDict = [Int: Contact]()
    var imagesCache = NSCache()
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Indicator
        indicator.hidesWhenStopped = true
        indicator.center = view.center
        view.insertSubview(indicator, aboveSubview: tableView)
        indicator.startAnimating()
        
        self.loadDialogs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadDialogs() {
        ServerManager.sharedManager.getDialogs(dialogsArray.count) { (dialogs, count, error) -> () in
            self.dialogsArray += dialogs
            self.totalDialogs = count
            
            var string = ""
            for id in dialogs {
                string += "\(id.userID!),"
            }
            
            //Get users from dialog
            ServerManager.sharedManager.getUserByID(string, success: { (dict) -> () in
                for (key, value) in dict {
                    self.contactsDict.updateValue(value, forKey: key)
                }
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                }) { (error) -> () in
                    
            }
        }

    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dialogsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DialogCell", forIndexPath: indexPath) as! DialogTableViewCell

        let dialog = dialogsArray[indexPath.row]
        cell.messageText.text = dialog.text!
        
        let date = NSDate(timeIntervalSince1970: dialog.unixTime!)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        cell.publicationDate.text = dateFormatter.stringFromDate(date)

        if let user = contactsDict[dialog.userID!] {
            cell.fullName.text = "\(user.fullName)"
        }
        
        if let attachment = dialog.attachmentsType {
            cell.messageText.text = attachment
        }
        
        if dialog.action != nil {
            cell.messageText.text = "User has left"
        }
        
        if dialog.readState == 0 {
            cell.messageView.backgroundColor = UIColor(red: 237/255.0, green: 241/255.0, blue: 245/255.0, alpha: 1.0)
            cell.leadingConstraint.constant = 8
        } else {
            cell.messageView.backgroundColor = UIColor.clearColor()
            cell.leadingConstraint.constant = 0
        }
        
        cell.userImage.backgroundColor = UIColor.whiteColor()
        if let image = imagesCache.objectForKey(dialog.userID!) as? UIImage {
            cell.userImage.image = image
        } else {
            cell.userImage.image = nil
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                
                if let user = self.contactsDict[dialog.userID!] {
                    let url = NSURL(string: user.imageLink!)
                    
                    if let data = NSData(contentsOfURL: url!) {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.imagesCache.setObject(UIImage(data: data)!, forKey: dialog.userID!)
                            
                            UIView.transitionWithView(cell.userImage, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                cell.userImage.image = UIImage(data: data)
                                }, completion: nil)
                        })
                    }
                }
            })
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == dialogsArray.count - 1 {
            if dialogsArray.count < totalDialogs {
                self.loadDialogs()
            }
        }
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.beginUpdates()
            self.dialogsArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            //TODO: Delete dialog on server
            
            tableView.endUpdates()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showChat" {
            
            let indexPath = tableView.indexPathForSelectedRow
            
            let userID = dialogsArray[indexPath!.row].userID!
            let user = contactsDict[userID]
            
            let chatVC = segue.destinationViewController as! ChatViewController
            
            chatVC.title = user?.fullName
            chatVC.senderId = String(NSUserDefaults.standardUserDefaults().objectForKey("user_id")!)
            chatVC.senderDisplayName = "Me"
            chatVC.user = user
        }
    }
}
