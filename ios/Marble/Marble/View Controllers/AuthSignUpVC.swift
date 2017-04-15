//
//  AuthSignUpVC.swift
//  Marble
//
//  Created by Daniel Li on 3/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class AuthSignUpVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var legalText: UITextView!
    
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
        
        let legalPlain = "By tapping Sign Up, you agree to the Terms of Service and Privacy Policy." as NSString
        
        let tosRange = legalPlain.range(of: "Terms of Service")
        let attrStr = NSMutableAttributedString(string: legalPlain as String)
        attrStr.addAttribute(NSLinkAttributeName, value: "https://amarbleapp.com/legal/tos", range: tosRange)
        
        let ppRange = legalPlain.range(of: "Privacy Policy")
        attrStr.addAttribute(NSLinkAttributeName, value: "https://amarbleapp.com/legal/privacy-policy", range: ppRange)
        
        legalText.attributedText = attrStr
        legalText.textAlignment = .center
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.MarbleBlue.cgColor)
        if UIScreen.main.bounds.height < 570 {
            if textField == signupUsername {
                animateViewMoving(up: true, moveValue: 60)
            } else if textField == signupPassword {
                animateViewMoving(up: true, moveValue: 80)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.FormUnderlineGray.cgColor)
        if UIScreen.main.bounds.height < 570 {
            if textField == signupUsername {
                animateViewMoving(up: false, moveValue: 60)
            } else if textField == signupPassword {
                animateViewMoving(up: false, moveValue: 80)
            }
        }
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
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
            
            if name.characters.count > 20  || name.characters.count < 3 {
                AuthLoginVC.createTextFieldBorder(width: 2.0, field: self.signupName, color: UIColor.red.cgColor)
                let alert = UIAlertController(title: "Name invalid", message: "Name must be between 3 and 20 characters.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if username.characters.count > 15 || username.characters.count < 4 {
                AuthLoginVC.createTextFieldBorder(width: 2.0, field: self.signupUsername, color: UIColor.red.cgColor)
                let alert = UIAlertController(title: "Username invalid", message: "Username must be between 4 and 15 characters.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            Networker.shared.signup(name: name, username: username, password: password, completionHandler: { response in
                switch response.result {
                case .success(let val):
                    alert.dismiss(animated: true, completion: {
                        let json = JSON(val)
                        let status = json["status"].int ?? -1
                        if status == 0, let auth_token = json["auth_token"].string, let userId = json["user_id"].int {
                            if KeychainWrapper.setAuthToken(token: auth_token) && KeychainWrapper.setUserID(id: userId) {
                                self.present(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                            }
                        } else  {
                            switch status {
                            case 1:
                                let title = json["title"].stringValue
                                let message = json["message"].stringValue
                                AuthLoginVC.createTextFieldBorder(width: 2.0, field: self.signupUsername, color: UIColor.red.cgColor)
                                let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            default:
                                print("ERROR: " + String(describing: json))
                                let alert = UIAlertController(title: "Oops", message: "Something went wrong...", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
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
