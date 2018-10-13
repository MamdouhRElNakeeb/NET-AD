//
//  Task.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/31/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class Task{
    
    var id = ""
    var creatorID = ""
    var creatorName = ""
    var creatorImg = ""
    var title = ""
    var description = ""
    var status = false
    
    init(id: String, creatorID: String, title: String, description: String) {
        self.id = id
        self.creatorID = creatorID
        self.title = title
        self.description = description
    }
}
