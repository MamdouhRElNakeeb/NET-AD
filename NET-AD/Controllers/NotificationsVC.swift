//
//  NotificationsVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/17/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class NotificationsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var notifs = [Notification]()
    
    var dateFormat = DateFormat(format: "dd MMM")
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.green
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
        self.tableView.addSubview(self.refreshControl)
        
        getData()
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getData()
    }
    
    func getData(){
        
        notifs.removeAll()
        
        let url = API.NOTIFICATIONS + "?_receiver=" + UserDefaults.standard.string(forKey: "id")!
        Alamofire.request(APIRequest.init(url: url).get()).responseJSON{
            response in
            
            print(response)
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                for notif in json["logs"].arrayValue{
                    self.notifs.append(Notification.init(id: notif["_id"].stringValue,
                                                         title: notif["title"].stringValue,
                                                         content: notif["description"].stringValue))
                }
                
                self.notifs.reverse()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                if self.notifs.isEmpty{
                    HUD.flash((.label("لا توجد إشعارات جديدة")), delay: 0.5)
                }
                
            case .failure(let error):
                print(error)
                HUD.flash((.label("لا توجد إشعارات جديدة")), delay: 0.5)
                
            }
        
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTVCell", for: indexPath) as! NotificationTVCell
        
        
        if notifs != nil && !notifs.isEmpty{
            cell.postIV.sd_setImage(with: URL(string: API.SERVER + notifs[indexPath.row].postImg), placeholderImage: UIImage(named: "logo"))
            
            let titleAttrs = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor.black,
                ] as [NSAttributedStringKey : Any]
            
            let contentAttrs = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.gray,
                ] as [NSAttributedStringKey : Any]
            
            let titleAttrStr = NSMutableAttributedString(string: notifs[indexPath.row].title, attributes: titleAttrs)
            let contentAttrStr = NSMutableAttributedString(string: "\n \(notifs[indexPath.row].content)", attributes: contentAttrs)
            
            titleAttrStr.append(contentAttrStr)
            cell.contentLbl.attributedText = titleAttrStr
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
