//
//  AddUserTVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/30/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddUserTVC: UITableViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        switch type {
        case "Admin":
            self.navigationItem.title = "إضافة أدمن"
        case "Editor":
            self.navigationItem.title = "إضافة محرر"
        default:
            self.navigationItem.title = "إضافة مدير"
        }
    }
    
    @IBAction func addBtnOnClick(_ sender: Any) {
        
        
        let params: JSON = [
            "email": emailTF.text!,
            "password": passwordTF.text!,
            "name": nameTF.text!,
            "type": type
        ]
        
        var request = APIRequest(url: API.REGISTER).postJSON()
        let json = params.rawString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON{
            response in
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if json["status"].boolValue{
                    let alert = UIAlertController(title: "Success", message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                        (action: UIAlertAction) -> Void in
                        self.emailTF.text = ""
                        self.nameTF.text = ""
                        self.passwordTF.text = ""
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    let alert = UIAlertController(title: "Error", message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Error", message: "An error occurred, Try again later!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
