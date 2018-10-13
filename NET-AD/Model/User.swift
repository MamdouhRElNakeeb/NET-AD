//
//  User.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/31/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class User {
    
    var id = ""
    var name = ""
    var img = ""
    var email = ""
    var type = ""
    
    init(id: String, name: String, img: String, email: String, type: String) {
        self.id = id
        self.name = name
        self.img = img
        self.email = email
        self.type = type
    }
}
