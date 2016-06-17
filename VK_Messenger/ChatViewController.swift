//
//  ChatViewController.swift
//  VK_Messenger
//
//  Created by Dima on 18/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var user: Contact!
    var isFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBubbles()
        showLoadEarlierMessagesHeader = true
        self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

        loadMessageHistory()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.collectionView!.collectionViewLayout.springinessEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    private func loadMessageHistory() {
        ServerManager.sharedManager.getMessagesHistoryForUserID(user.userID!, offset: messages.count) { (messages, error) in
            
            guard error == nil else {print(error); return}
            
            for item in messages {
                self.messages.insert(item, atIndex: 0)
            }
            self.finishReceivingMessage()
        }
    }
    
    private func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    func addMessage(withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.insert(message, atIndex: messages.count)
        ServerManager.sharedManager.postMessageForUserID(user.userID!, message: text)
    }
    
    func showUserProfile(sender: UIBarButtonItem) {
        print("Tap")
    }

    // MARK: - JSQMessagesCollectionVie
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
                
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
            cell.textView?.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView!.textColor!, NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        } else {
            cell.textView!.textColor = UIColor.blackColor()
            cell.textView?.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView!.textColor!, NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        automaticallyScrollsToMostRecentMessage = false
        loadMessageHistory()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        addMessage(withMessageText: text, senderId: senderId, senderDisplayName: senderDisplayName, date: date)
        automaticallyScrollsToMostRecentMessage = true
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("didPressAccessoryButton")
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("didTapMessageBubbleAtIndexPath")
    }
}
