//
//  CreateMarbleVC.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class CreateMarbleVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        marbleNameField.delegate = self
        
        createBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
        createBtn.backgroundColor = Constants.Colors.MarbleBlue
        createBtn.layer.borderWidth = 1
        createBtn.layer.cornerRadius = 7
        createBtn.setTitleColor(UIColor.white, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        marbleNameField.becomeFirstResponder()
    }
    
    @IBAction func cancelBtnPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.MarbleBlue.cgColor)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        AuthLoginVC.createTextFieldBorder(width: 2.0, field: textField, color: Constants.Colors.FormUnderlineGray.cgColor)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        marbleNameField.resignFirstResponder()
        create()
        return true
    }
    
    
    @IBOutlet weak var marbleNameField: UITextField!
    
    @IBAction func createMarblePress(_ sender: Any) {
        create()
    }
    
    func create() {
        if let name = marbleNameField.text {
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            
            Networker.shared.createGroupWith(name: name, completionHandler: { response in
                switch response.result {
                case .success:
                    alert.dismiss(animated: true, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                case .failure:
                    print(response.debugDescription)
                    let alert = UIAlertController(title: "Error", message: "Group creation failed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { alert in
                        self.marbleNameField.text = ""
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
}
