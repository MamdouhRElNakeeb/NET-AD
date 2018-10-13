//
//  Post.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/18/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation

class Post {
    
    var id = ""
    var editorID = ""
    var editorImg = ""
    var editorName = ""
    var img = ""
    var status = 1001
    var comment = ""
    var timeInMillis = 0
    var type = "Image"
    var height = 0.0
    var width = 0.0
    
    init(id: String, editorID: String, editorImg: String, editorName: String, img: String, status: Int, comment: String, timeInMillis: Int, type: String) {
        
        self.id = id
        self.editorID = editorID
        self.editorImg = editorImg
        self.editorName = editorName
        self.img = img
        self.status = status
        self.comment = comment
        self.timeInMillis = timeInMillis
        self.type = type
    }
    
    init(id: String, editorID: String, editorImg: String, editorName: String, img: String, status: Int, comment: String, timeInMillis: Int, type: String, width: Double, height: Double) {
        
        self.id = id
        self.editorID = editorID
        self.editorImg = editorImg
        self.editorName = editorName
        self.img = img
        self.status = status
        self.comment = comment
        self.timeInMillis = timeInMillis
        self.type = type
        self.width = width
        self.height = height
    }
    
}
