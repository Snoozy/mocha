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

        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var placeholderButtons: Array<NumPlaceholderButton>?
    var buttonIdx = 0

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var responder: SCLAlertViewResponder?
    
    @IBAction func numberBtnPressed(_ sender: NumberButton) {
        if buttonIdx < (placeholderButtons?.count)! {
            placeholderButtons?[buttonIdx].changeValue(to: Int(sender.numValue)!)
            buttonIdx += 1
            if buttonIdx == (placeholderButtons?.count)! {
                activityIndicator.startAnimating()
                
                var codeString = ""
                for btn in placeholderButtons! {
                    codeString += String(btn.value!)
                }
                
                Networker.shared.findGroupBy(code: codeString, completionHandler: { response in
                    
                    self.activityIndicator.stopAnimating()
                    switch response.result {
                    case .success:
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
                                            State.shared.addGroup(name: group["name"].stringValue, id: groupId, lastSeen: group["last_seen"].int64 ?? 0)
                                            self.performSegue(withIdentifier: "JoinGroupToMainUnwind", sender: nil)
                                        case .failure:
                                            print(response.debugDescription)
                                        }
                                    })
                                })
                                alert.addButton("Cancel", backgroundColor: UIColor.white, textColor: Constants.Colors.MarbleBlue, action: {
                                    self.resetPlaceholders()
                                    self.responder?.close()
                                })
                                self.responder = alert.showInfo(name, subTitle: String(memberCount) + " members")
                            } else {  // error occurred
                                
                                let alert = UIAlertController(title: "Error", message: "Group does not exist", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { alert in
                                    self.resetPlaceholders()
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
    }
    
    func resetPlaceholders() {
        for btn in self.placeholderButtons! {
            btn.revertChange()
        }
        self.buttonIdx = 0
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if buttonIdx > 0 {
            buttonIdx -= 1
            placeholderButtons?[buttonIdx].revertChange()
        }
    }

}
