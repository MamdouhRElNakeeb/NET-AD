//
//  API.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import Foundation
import Alamofire

class API{
    
    static var SERVER = "http://206.189.213.156:3000/"
    static var LOGIN = SERVER + "profile/login"
    static var REGISTER = SERVER + "profile"
    
    static var POST_CATEGORIES = SERVER + "section"
    static var NEWS_FEED = SERVER + "medium"
    static var NOTIFICATIONS = SERVER + "log"
    static var TASKS = SERVER + "task"
    
}

class APIRequest{
    
    var request: URLRequest
    
    init(url: String) {
        
        request = URLRequest(url: URL(string: url)!)
        if let xAuth = UserDefaults.standard.string(forKey: "x_auth") {
            request.setValue(xAuth, forHTTPHeaderField: "x_auth")
        }
        request.setValue("nakeeb", forHTTPHeaderField: "client_id")
        
        print(request.allHTTPHeaderFields)
        
    }
    
    func get() -> URLRequest{
        
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
    
    func postJSON() -> URLRequest{
        
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func postFormData() -> URLRequest{
        
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func putJSON() -> URLRequest{
        
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        return request
    }
}
