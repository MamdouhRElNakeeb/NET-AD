//
//  Notification.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/17/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class Notification {
    
    var id = ""
    var title = ""
    var postImg = ""
    var content = ""
    var timeInMillis = 0
    
    init(id: String, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}
