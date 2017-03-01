//
//  AuthViewController.swift
//  Marble
//
//  Created by Daniel Li on 1/23/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AuthViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // SIGN UP VIEW
    @IBOutlet weak var signupName: UITextField!
    @IBOutlet weak var signupPassword: UITextField!
    @IBOutlet weak var signupUsername: UITextField!

    @IBAction func signupGo(_ sender: UIButton) {
        let username = self.signupUsername.text
        let name = self.signupName.text
        let password = self.signupPassword.text
        
        if let username = username, let name = name, let password = password {
        
            Networker.shared.signup(name: name, username: username, password: password, completionHandler: { response in
                switch response.result {
                case .success:
                    let response = response.result.value as! NSDictionary
                    if let auth_token = response["auth_token"] as? String, let userId = response["user_id"] as? Int {
                        if KeychainWrapper.setAuthToken(token: auth_token) && KeychainWrapper.setUserID(id: userId) {
                            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                        }
                    }
                case .failure:
                    print(response)
                }
            })
        }
    }
    
    
    // LOG IN VIEW
    
    @IBOutlet weak var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    @IBAction func loginGo(_ sender: UIButton) {
        let username = self.loginUsername.text
        let password = self.loginPassword.text
        
        if let username = username, let password = password {
            Networker.shared.login(username: username, password: password, completionHandler:  { response in
                switch response.result {
                case .success:
                    let response = response.result.value as! NSDictionary
                    if let auth_token = response["auth_token"] as? String, let userId = response["user_id"] as? Int {
                        print("NEW AUTH TOKEN: " + auth_token)
                        if KeychainWrapper.setAuthToken(token: auth_token) && KeychainWrapper.setUserID(id: userId) {
                            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                        }
                    }
                case .failure:
                    print(response)
                }
            })
        }
    }
    
}
