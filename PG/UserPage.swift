//
//  UserPage.swift
//  PG
//
//  Created by михаил on 09.04.2020.
//  Copyright © 2020 михаил. All rights reserved.
//

import UIKit

class UserPage: UIViewController {
    
    var token: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tokenvalue.text = token

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var tokenvalue: UILabel!
    

}
