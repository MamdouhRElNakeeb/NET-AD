//
//  PostCategory.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class PostCategory{
    
    var id = 0
    var title = ""
    var bgImg = ""
    
    init(id: Int, title: String, bgImg: String) {
        self.id = id
        self.title = title
        self.bgImg = bgImg
    }
    
    init() {
    }
}
