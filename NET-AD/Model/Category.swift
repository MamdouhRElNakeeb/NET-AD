//
//  Category.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/18/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class Category{
    
    var id = ""
    var title = ""
    var description = ""
    var img = ""
    var width = 0.0
    var height = 0.0
    
    init(id: String, title: String, description: String, img: String) {
        
        self.id = id
        self.title = title
        self.description = description
        self.img = img
    }
    
    init(id: String, title: String, description: String, img: String, width: Double, height: Double) {
        
        self.id = id
        self.title = title
        self.description = description
        self.img = img
        self.width = width
        self.height = height
    }
    
    init() {
        
    }
}
