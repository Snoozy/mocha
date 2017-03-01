//
//  CreateMarbleVC.swift
//  Marble
//
//  Created by Daniel Li on 2/6/17.
//  Copyright © 2017 Marble, LLC. All rights reserved.
//

import UIKit

class CreateMarbleVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet weak var marbleNameField: UITextField!
    
    @IBAction func createMarblePress(_ sender: Any) {
        let name = marbleNameField.text ?? ""
        Networker.shared.createGroupWith(name: name, completionHandler: { response in
            switch response.result {
            case .success:
                let response = response.result.value as! NSDictionary
                if let status = response["status"] as? Int {
                    if status == 0 {  // group create success
                        self.performSegue(withIdentifier: "CreateGroupUnwind", sender: nil)
                    } else {  // error occurred
                        let alert = UIAlertController(title: "Error", message: "Group creation failed", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { alert in
                            self.marbleNameField.text = ""
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
