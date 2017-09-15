//
//  AddMarbleCodeVC.swift
//  Marble
//
//  Created by Daniel Li on 2/2/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class AddMarbleCodeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinBtn.layer.borderColor = Constants.Colors.MarbleBlue.cgColor
        joinBtn.backgroundColor = Constants.Colors.MarbleBlue
        joinBtn.layer.borderWidth = 1
        joinBtn.layer.cornerRadius = 8
        joinBtn.setTitleColor(UIColor.white, for: .normal)
        
        numberLabel.text = ""
        
        if UIScreen.main.bounds.height < 570 {
            numberLabel.font = UIFont.boldSystemFont(ofSize: 30)
            for constraint in numberLabel.constraints where (constraint.identifier == "joinBtnToNumbers") {
                constraint.constant = 5
                self.view.updateConstraints()
                self.view.layoutIfNeeded()
                break
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    
    var activityIndicator: UIActivityIndicatorView!
    var originalButtonText: String?
    
    func loadingButton() {
        originalButtonText = joinBtn.titleLabel?.text
        joinBtn.setTitle("", for: .normal)
        if activityIndicator == nil {
            activityIndicator = createActivityIndicator()
        }
        
        showSpinning()
    }
    
    func stopLoadingButton() {
        joinBtn.setTitle(originalButtonText, for: .normal)
        activityIndicator.stopAnimating()
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        joinBtn.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: joinBtn, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        joinBtn.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: joinBtn, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        joinBtn.addConstraint(yCenterConstraint)
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        return activityIndicator
    }
    
    
    var responder: SCLAlertViewResponder?
    
    @IBAction func numberBtnPressed(_ sender: NumberButton) {
        if (numberLabel.text?.characters.count)! < 8 {
            let value = sender.numValue
            numberLabel.text = numberLabel.text! + value
        }
    }
    
    
    @IBAction func joinPressed(_ sender: UIButton) {
        if numberLabel.text != nil && numberLabel.text != "" {
            loadingButton()
            Networker.shared.findGroupBy(code: numberLabel.text!, completionHandler: { response in
                switch response.result {
                case .success:
                    self.stopLoadingButton()
                    let response = response.result.value as! NSDictionary
                    if let status = response["status"] as? Int {
                        if status == 0 {  // successfuly found group
                            let name = response["group_name"] as! String
                            let memberCount = response["member_count"] as! Int
                            let groupId = response["group_id"] as! Int
                            
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false,
                                hideWhenBackgroundViewIsTapped: true
                            )
                            
                            let alert = SCLAlertView(appearance: appearance)
                            alert.addButton("Join Marble", action: {
                                Networker.shared.joinGroup(id: groupId, completionHandler: { response in
                                    switch response.result {
                                    case .success(let value):
                                        print("segue")
                                        let json = JSON(value)
                                        print(json)
                                        let group = json["group"]
                                        let groupId = group["group_id"].int!
                                        State.shared.addGroup(name: group["name"].stringValue, id: groupId, lastSeen: group["last_seen"].int64 ?? 0, members: group["members"].int ?? 1)
                                        self.performSegue(withIdentifier: "JoinGroupToMainUnwind", sender: nil)
                                    case .failure:
                                        print(response.debugDescription)
                                    }
                                })
                            })
                            alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
                                self.clearNumbers()
                                self.responder?.close()
                            })
                            self.responder = alert.showInfo(name, subTitle: String(memberCount) + (memberCount > 1 ? " members" : " member"))
                        } else {  // error occurred
                            
                            let alert = UIAlertController(title: "Error", message: "Group does not exist", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { alert in
                                self.clearNumbers()
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                case .failure:
                    print(response.debugDescription)
                }
                
            })
        }
    }
    
    func clearNumbers() {
        self.numberLabel.text = ""
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if numberLabel.text != "" {
            numberLabel.text = numberLabel.text?.substring(to: (numberLabel.text?.index(before: (numberLabel.text?.endIndex)!))!)
        }
    }

}
