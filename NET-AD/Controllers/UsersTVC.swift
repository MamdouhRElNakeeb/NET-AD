//
//  UsersTVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/31/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class UsersTVC: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor.green
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        getData()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        getData()
    }
    
    func getData(){
        
        Alamofire.request(APIRequest.init(url: API.REGISTER).get()).responseJSON{
            response in
            
            print(response)
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                for user in json["users"].arrayValue{
                    self.users.append(User.init(id: user["_id"].stringValue,
                                                name: user["name"].stringValue,
                                                img: user["avatar"].stringValue,
                                                email: user["email"].stringValue,
                                                type: user["type"].stringValue))
                }
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                
                if self.users.isEmpty{
                    HUD.flash((.label("لا توجد محررين")), delay: 0.5)
                }
                
            case .failure(let error):
                print(error)
                HUD.flash((.label("لا توجد محررين")), delay: 0.5)
                
            }
            
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTVCell", for: indexPath) as! UserTVCell

        // Configure the cell...
        cell.nameLbl.text = users[indexPath.row].name
        cell.img.sd_setImage(with: URL(string: API.SERVER + users[indexPath.row].img), placeholderImage: UIImage(named: "profile_icn"))
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AssignTaskTVC") as! AssignTaskTVC
        vc.user = users[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
