//
//  LoginVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginVC: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
    }

    @IBAction func loginBtnOnClick(_ sender: Any) {
        
//        UserDefaults.standard.set("", forKey: "x_auth")
//        UserDefaults.standard.set(UUID().uuidString, forKey: "client_id")
//        UserDefaults.standard.synchronize()
        
        
        let params: JSON = [
            "email": emailTF.text!,
            "password": passTF.text!,
            "apn": UserDefaults.standard.string(forKey: "apn") ?? ""
        ]
        
        var request = APIRequest(url: API.LOGIN).postJSON()
        let json = params.rawString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON{
            response in
            
            print(response)
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                let headers = JSON(response.response?.allHeaderFields)
                print(headers)
                
                if json["status"].boolValue{
                    print(headers["x_auth"].stringValue)
                    UserDefaults.standard.set(headers["x_auth"].stringValue, forKey: "x_auth")
                    UserDefaults.standard.set(json["data"]["user"]["name"].string, forKey: "name")
                    UserDefaults.standard.set(json["data"]["user"]["type"].string, forKey: "type")
                    UserDefaults.standard.set(json["data"]["user"]["_id"].string, forKey: "id")
                    UserDefaults.standard.set(self.emailTF.text!, forKey: "email")
                    UserDefaults.standard.set(true, forKey: "login")
                    UserDefaults.standard.synchronize()
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                    vc.type = json["data"]["user"]["type"].stringValue
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    
                    let alert = UIAlertController(title: "حدث خطأ", message: "حاول مرة أخرى", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "حسناً", style: UIAlertActionStyle.destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print(error)
                
                let alert = UIAlertController(title: "حدث خطأ", message: "حاول مرة أخرى", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "حسناً", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
