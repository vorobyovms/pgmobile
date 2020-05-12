//
//  LocalStorage.swift
//  PG
//
//  Created by михаил on 11.05.2020.
//  Copyright © 2020 михаил. All rights reserved.
//

import Foundation


//Сюда записываем после удачной аутенфикации данные пользователя

public class LocalStorage {
    
    struct defaultsKeys {
        static let keyOne = "personal_id"
        static let keyTwo = "token"
        static let keyThree = "telephone"
    }
    
    let defaults = UserDefaults.standard
    
    public func SaveData(id: CLong, token: String, telephone: String) {
        defaults.set(id, forKey: defaultsKeys.keyOne)
        defaults.set(token, forKey: defaultsKeys.keyTwo)
        defaults.set(telephone, forKey: defaultsKeys.keyThree)
    }
    
    public func GetToken() -> Any {
        let tokenres = defaults.string(forKey: defaultsKeys.keyTwo) as Any
        return tokenres
    }
    
    public func GetPersonalID() -> Any {
        let personal_id = defaults.string(forKey: defaultsKeys.keyOne) as Any
        return personal_id
    }
    
    public func GetTelephone() -> Any {
        let telephone = defaults.string(forKey: defaultsKeys.keyThree) as Any
        return telephone
    }
    
    
}
