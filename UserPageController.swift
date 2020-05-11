//
//  UserPageController.swift
//  PG
//
//  Created by михаил on 11.05.2020.
//  Copyright © 2020 михаил. All rights reserved.
//

import UIKit

class UserPageController: UIViewController {

    var token : String = ""
    

    @IBOutlet weak var PressMenu: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("token = ",self.token)

        //self.revealViewController()?.r
        PressMenu.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
    }

}
