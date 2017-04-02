//
//  ProcessAuthVC.swift
//  Marble
//
//  Created by Daniel Li on 3/30/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class AuthLoginVC: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: loginUsername, color: Constants.Colors.FormUnderlineGray.cgColor)
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: loginPassword, color: Constants.Colors.FormUnderlineGray.cgColor)
        
        loginBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.cornerRadius = 7
        loginBtn.setTitleColor(Constants.Colors.MarbleBlue, for: .normal)
        
        loginUsername.delegate = self
        loginPassword.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.MarbleBlue.cgColor)
        if textField == loginPassword && UIScreen.main.bounds.height < 570 {  // only scroll up on iphone 5 gen
            animateViewMoving(up: true, moveValue: 70)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.FormUnderlineGray.cgColor)
        if textField == loginPassword && UIScreen.main.bounds.height < 570 {
            animateViewMoving(up: false, moveValue: 70)
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
        if textField == loginUsername {
            loginPassword.becomeFirstResponder()
        } else if textField == loginPassword {
            loginPassword.resignFirstResponder()
            login()
        }
        return true
    }
    
    static func createTextFieldBorder(width: Float, field: UITextField, color: CGColor) {
        let border = CALayer()
        let width = CGFloat(width)
        
        border.borderColor = color
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: field.frame.size.height)
        border.borderWidth = width
        field.layer.addSublayer(border)
        field.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginUsername.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // LOG IN VIEW
    
    @IBOutlet weak var loginUsername: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func loginGo(_ sender: UIButton) {
        loginUsername.resignFirstResponder()
        loginPassword.resignFirstResponder()
        login()
    }

    func login() {
        let username = self.loginUsername.text
        let password = self.loginPassword.text
        
        if let username = username, let password = password {
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            Networker.shared.login(username: username, password: password, completionHandler:  { response in
                switch response.result {
                case .success:
                    alert.dismiss(animated: true, completion: {
                        let response = response.result.value as! NSDictionary
                        if let auth_token = response["auth_token"] as? String, let userId = response["user_id"] as? Int {
                            print("NEW AUTH TOKEN: " + auth_token)
                            if KeychainWrapper.setAuthToken(token: auth_token) && KeychainWrapper.setUserID(id: userId) {
                                self.present(UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!, animated: true, completion: nil)
                            }
                        } else if let error = response["error"] as? Int {
                            switch error {
                            case 1:
                                AuthLoginVC.createTextFieldBorder(width: 2.0, field: self.loginPassword, color: UIColor.red.cgColor)
                                let alert = UIAlertController(title: "Invalid Password", message: "Invalid username and password combination.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                                self.loginPassword.text = ""
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
