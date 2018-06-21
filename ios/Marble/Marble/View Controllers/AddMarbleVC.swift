//
//  AddMarbleVC.swift
//  Marble
//
//  Created by Daniel Li on 6/19/18.
//  Copyright © 2018 Marble, LLC. All rights reserved.
//

import UIKit

class AddMarbleVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    @IBAction func cancelPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
