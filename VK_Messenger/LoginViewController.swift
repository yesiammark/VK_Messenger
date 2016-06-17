//
//  LoginViewController.swift
//  VK Messenger
//
//  Created by Dima on 12/02/16.
//  Copyright © 2016 Dima. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func loginControllerDidSetToken(viewController: LoginViewController)
}

class LoginViewController: UIViewController, UIWebViewDelegate {
    
    var delegate: LoginViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = UIWebView(frame: view.bounds)
        webView.delegate = self
        
        view.addSubview(webView)
        let url = NSURL(string: "https://oauth.vk.com/authorize?client_id=5275598&display=page&redirect_uri=https://oauth.vk.com/blank.html&scope=friends,messages&response_type=token&v=5.45")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
                
        if let response = request.URL?.description {
            print(response)
            if response.containsString("access_token") {
                
                let accessToken = AccessToken(dictionary: AccessToken.parseResponse(response))
                
                NSUserDefaults.standardUserDefaults().setObject(accessToken.token!, forKey: "access_token")
                NSUserDefaults.standardUserDefaults().setObject(accessToken.expires!, forKey: "expires_in")
                NSUserDefaults.standardUserDefaults().setObject(accessToken.userID!, forKey: "user_id")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                delegate?.loginControllerDidSetToken(self)
                self.dismissViewControllerAnimated(true, completion: nil)
                return false
            }
        }
        
        return true
    }
}
