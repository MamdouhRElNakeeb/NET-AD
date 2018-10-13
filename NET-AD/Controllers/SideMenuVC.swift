//
//  SideMenuVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/30/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userIDTF = String()
    
    
    var titles: [String] = [
        "إضافة أدمن",
        "إضافة مدير",
        "إضافة محرر",
        "إضافة موضوع جديد",
        "وسيلة الإنتقال",
        "الفتاوى",
        "الأماكن الهامة",
        "الوجبات",
        "عن البرنامج",
        "خروج"
    ]
    
    @IBOutlet weak var sideMenuTV: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuTV.separatorStyle = .none
        sideMenuTV.frame = CGRect(x: 0, y: (self.view.frame.size.height - 45 * CGFloat(titles.count)) / 2.0, width: self.view.frame.size.width, height: 45 * CGFloat(titles.count))
        sideMenuTV.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth]
        sideMenuTV.isOpaque = false
        sideMenuTV.backgroundColor = UIColor.clear
        sideMenuTV.backgroundView = nil
        sideMenuTV.isScrollEnabled = true
        
        if UserDefaults.standard.string(forKey: "type") == "Admin"{
            titles = [
                "إضافة أدمن",
                "إضافة مدير",
                "إضافة محرر",
                "إضافة موضوع جديد",
                "إضافة تكليف",
                "خروج"
            ]
        }
        else if UserDefaults.standard.string(forKey: "type") == "Editor"{
            titles = [
                "خروج"
            ]
        }
        else{
            titles = [
                "خروج"
            ]
        }
       
        self.sideMenuTV.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTVCell") as! SideMenuTVCell
        
        cell.title.text = titles[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell: SideMenuTVCell = tableView.cellForRow(at: indexPath)! as! SideMenuTVCell
        cell.contentView.backgroundColor = UIColor.white
        
        if cell.title.text == "خروج"{
            UserDefaults.standard.set(false, forKey: "login")
            UserDefaults.standard.synchronize()
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        switch indexPath.row {
        case 0:
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddUserTVC") as! AddUserTVC
            vc.type = "Admin"
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 1:
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddUserTVC") as! AddUserTVC
            vc.type = "Moderator"
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 2:
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddUserTVC") as! AddUserTVC
            vc.type = "Editor"
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 3:
            let vc = storyboard?.instantiateViewController(withIdentifier: "AddCategoryVC") as! AddCategoryVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 4:
            let vc = storyboard?.instantiateViewController(withIdentifier: "UsersTVC") as! UsersTVC
            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 5: //fatawy
//            let vc = storyboard?.instantiateViewController(withIdentifier: "FatawyAnswersTVC") as! FatawyAnswersTVC
//            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 6: //places
//            let vc = storyboard?.instantiateViewController(withIdentifier: "ImportantLocationsVC") as! ImportantLocationsVC
//            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 7: //meals
            
//            let vc = storyboard?.instantiateViewController(withIdentifier: "MealsVC") as! MealsVC
//            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        case 8: //about
//            let vc = storyboard?.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
//            self.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func joinUser(){
        
        let alert = UIAlertController(title: "مرحباً بك", message: "أدخل الرقم التعريفى الخاص بك", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "User ID"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "إدخال", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction) -> Void in
            
            self.userIDTF = alert.textFields![0].text!
            print(self.userIDTF)
            let userDefaults = UserDefaults.standard
            userDefaults.set(self.userIDTF, forKey: "userID")
            userDefaults.set(true, forKey: "logged")
            userDefaults.synchronize()
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

