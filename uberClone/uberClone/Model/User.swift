//
//  User.swift
//  uberClone
//
//  Created by Михаил Щербаков on 04.04.2022.
//

import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let uid: String
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    
    init(uid: String, dict: [String:Any]) {
        self.uid = uid
        self.fullname = dict["fullname"] as? String ?? ""
        self.email = dict["email"] as? String ?? ""
        
        if let index = dict["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
    
}
