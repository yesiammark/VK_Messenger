//
//  ContactsTableViewController.swift
//  VK_Messenger
//
//  Created by Dima on 16/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

// TODO: загрузка изображений в кеш
// TODO: получение разных типов сообщений
// TODO: отправка разных типов сообщений
// TODO: получение новых сообщений без ручного обновления


import UIKit

class ContactsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, LoginViewControllerDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var onlineStautsControl: UISegmentedControl!
    
    var contactsGroup = [ContactsGroups]()
    var allContacts = [Contact]()
    var totalContacts: Int?
    var imagesCache = NSCache()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredContacts = [Contact]()
    var onlineContacts = [Contact]()
    var isFirstLunch = false
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self
        
        //SearchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        //RefreshControl
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "reload", forControlEvents: .ValueChanged)
        
        
        //Indicator
        indicator.hidesWhenStopped = true
        indicator.center = view.center
        view.insertSubview(indicator, aboveSubview: tableView)
        indicator.startAnimating()
        
        checkToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLunch {
            isFirstLunch = false
            
            let login = LoginViewController()
            login.delegate = self
            login.modalTransitionStyle = .CrossDissolve
            self.presentViewController(login, animated: true, completion: nil)
        }
    }
    
    // MARK: - Methods
    
    func reload() {
        loadContacts()
        refreshControl?.endRefreshing()
    }
    
    func loadContacts() {
        ServerManager.sharedManager.getContacts(0, offset: 0) { (contacts, count, error) -> () in
            print("data loaded")
            self.contactsGroup = ContactsGroups.createGroups(contacts)
            self.totalContacts = count
            self.allContacts = contacts
            var array = [Contact]()
            self.tableView.reloadData()
            self.indicator.stopAnimating()
            for contact in contacts {
                if contact.online == 1 {
                    array.append(contact)
                }
            }
            self.onlineContacts = array
            self.onlineStautsControl.setTitle("\(self.onlineContacts.count) online", forSegmentAtIndex: 1)
        }
    }

    func checkToken() {
        if NSUserDefaults.standardUserDefaults().valueForKey("access_token") != nil {
            loadContacts()
            return
        }
        
        isFirstLunch = true
    }
    
    // MARK: - Private Methods
    
    private func loadDestinationViewController(vc: ChatViewController, withUser user:Contact) {
        vc.title = user.fullName
        vc.senderId = String(NSUserDefaults.standardUserDefaults().objectForKey("user_id")!)
        vc.senderDisplayName = "Me"
        vc.user = user
    }
    
    // MARK: - Search
    
    func filterContactsSearchText(searchText: String) {
        if onlineStautsControl.selectedSegmentIndex == 1 {
            filteredContacts = onlineContacts.filter({ contact in
                return contact.fullName.localizedStandardContainsString(searchText)
            })
        } else {
            filteredContacts = allContacts.filter({ contact in
                
                return contact.fullName.localizedStandardContainsString(searchText)
            })
        }
        tableView.reloadData()
    }
    
    // MARK: - Search controller
    
    func updateSearchResultsForSearchController( searchController: UISearchController) {
        self.filterContactsSearchText(searchController.searchBar.text!)
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        if searchController.active && searchController.searchBar.text != "" {
            return 1
        }
        
        if onlineStautsControl.selectedSegmentIndex == 1 {
            return 1
        }
        
        return contactsGroup.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.active && searchController.searchBar.text != "" {
            return nil
        }
        if onlineStautsControl.selectedSegmentIndex == 1 {
            return nil
        }
        
        return contactsGroup[section].section
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.active && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        
        if onlineStautsControl.selectedSegmentIndex == 1 {
            return onlineContacts.count
        }
        return contactsGroup[section].itemsArray!.count
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        
        if searchController.active {
            return nil
        }
        
        if onlineStautsControl.selectedSegmentIndex == 1 {
            return nil
        }
        var array = [String]()
        
        for item in self.contactsGroup {
            
            if item.section == "Favorites" {
                array.append("★")
            } else {
                array.append(item.section!)   
            }
        }
        
        return array
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactCell", forIndexPath: indexPath) as! ContactTableViewCell
        
        let user: Contact
        if searchController.active && searchController.searchBar.text != "" {
            user = filteredContacts[indexPath.row]
        } else if onlineStautsControl.selectedSegmentIndex == 1 {
            user = onlineContacts[indexPath.row]
        } else {
            let section = contactsGroup[indexPath.section]
            user = section.itemsArray![indexPath.row]
        }
        
        cell.fullName.text = "\(user.fullName)"
        
        cell.userImage.backgroundColor = UIColor.whiteColor()
        
        if let image = imagesCache.objectForKey(user.userID!) as? UIImage {
            cell.userImage.image = image
        } else {
            cell.userImage.image = nil
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                
                if let url = NSURL(string: user.imageLink!) {
                    if  let data = NSData(contentsOfURL: url) {
                        
                        self.imagesCache.setObject(UIImage(data: data)!, forKey: user.userID!)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            UIView.transitionWithView(cell.userImage, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                                cell.userImage.image = UIImage(data: data)
                                }, completion: nil)
                        })
                    }
                }
                
                
            }
        }

        if user.online == 1 {
            cell.onlineStatus.text = "online"
        } else {
            cell.onlineStatus.text = ""
        }
        
        return cell
    }
    
    // MARK: - Tabbar Delegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if let nc = viewController as? UINavigationController {
            if let vc = nc.viewControllers.first as? DialogsTableViewController {
                vc.imagesCache = imagesCache
            }
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func changeStatusFilter(sender: UISegmentedControl) {
        tableView.reloadData()
    }
        
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showChat" {
            let chatVC = segue.destinationViewController as! ChatViewController
            let indexPath = tableView.indexPathForSelectedRow

            if onlineStautsControl.selectedSegmentIndex == 1 {
                let user = onlineContacts[indexPath!.row]
                self.loadDestinationViewController(chatVC, withUser: user)
                return
            }
            if searchController.active && searchController.searchBar.text != "" {
                let user = filteredContacts[indexPath!.row]
                self.loadDestinationViewController(chatVC, withUser: user)
                return
            }
            
            let user = contactsGroup[indexPath!.section].itemsArray![indexPath!.row]
            self.loadDestinationViewController(chatVC, withUser: user)
        }
    }
    
    // MARK: - LoginViewControllerDelegate
    func loginControllerDidSetToken(viewController: LoginViewController) {
        loadContacts()
    }
}
