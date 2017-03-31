//
//  AuthSignUpVC.swift
//  Marble
//
//  Created by Daniel Li on 3/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class AuthSignUpVC: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: signupName, color: Constants.Colors.FormUnderlineGray.cgColor)
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: signupPassword, color: Constants.Colors.FormUnderlineGray.cgColor)
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: signupUsername, color: Constants.Colors.FormUnderlineGray.cgColor)
        
        signUpBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
        signUpBtn.backgroundColor = Constants.Colors.MarbleBlue
        signUpBtn.layer.borderWidth = 1
        signUpBtn.layer.cornerRadius = 7
        signUpBtn.setTitleColor(UIColor.white, for: .normal)
        
        signupName.delegate = self
        signupPassword.delegate = self
        signupUsername.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.MarbleBlue.cgColor)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.FormUnderlineGray.cgColor)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == signupName {
            signupUsername.becomeFirstResponder()
        } else if textField == signupUsername {
            signupPassword.becomeFirstResponder()
        } else if textField == signupPassword {
            signupPassword.resignFirstResponder()
            signup()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signupName.becomeFirstResponder()
    }
    
    
    // SIGN UP VIEW
    @IBOutlet weak var signupName: UITextField!
    @IBOutlet weak var signupPassword: UITextField!
    @IBOutlet weak var signupUsername: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBAction func signupGo(_ sender: UIButton) {
        signupPassword.resignFirstResponder()
        signupUsername.resignFirstResponder()
        signupName.resignFirstResponder()
        signup()
    }
    
    func signup() {
        let username = self.signupUsername.text
        let name = self.signupName.text
        let password = self.signupPassword.text
        
        if let username = username, let name = name, let password = password {
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            Networker.shared.signup(name: name, username: username, password: password, completionHandler: { response in
                switch response.result {
                case .success:
                    alert.dismiss(animated: true, completion: {
                        let response = response.result.value as! NSDictionary
                        if let auth_token = response["auth_token"] as? String, let userId = response["user_id"] as? Int {
                            if KeychainWrapper.setAuthToken(token: auth_token) && KeychainWrapper.setUserID(id: userId) {
                                self.present(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                            }
                        } else if let error = response["error"] as? Int {
                            switch error {
                            case 1:
                                AuthLoginVC.createTextFieldBorder(width: 2.0, field: self.signupUsername, color: UIColor.red.cgColor)
                                let alert = UIAlertController(title: "Username Taken", message: "This username has been taken.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            default:
                                debugPrint("unknown error code.")
                                return
                            }
                        }
                    })
                case .failure:
                    print(response)
                }
            })
        }
    }
}
