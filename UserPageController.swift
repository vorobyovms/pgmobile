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
        let storage = LocalStorage()
        let token = storage.GetToken()
        let personal_id = storage.GetPersonalID()
        let telephone = storage.GetTelephone()
        print("token = ",token)
        print("personal_id = ",personal_id)
        print("telephone = ",telephone)
        PressMenu.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
    }

}
