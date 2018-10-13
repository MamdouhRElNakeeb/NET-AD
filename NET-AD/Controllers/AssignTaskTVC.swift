//
//  AssignTaskTVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/31/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class AssignTaskTVC: UITableViewController {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    var user = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTV.addBorder(view: descriptionTV, stroke: UIColor.gray, fill: UIColor.clear, radius: 15, width: 2)
        
    }

    @IBAction func addBtnOnClick(_ sender: Any) {
        
        let params: JSON = [
            "title": titleTF.text!,
            "description": descriptionTV.text!,
            "_receiver": user
        ]
        
        var request = APIRequest(url: API.TASKS).postJSON()
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
                        
                        _ = self.navigationController?.popViewController(animated: true)
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
