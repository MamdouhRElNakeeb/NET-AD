//
//  TasksTVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/18/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class TasksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [Task]()
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.tableView.addSubview(self.refreshControl)

        getData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getData()
    }
    
    func getData(){
        
        tasks.removeAll()
        
        let url = API.TASKS + "?_receiver=" + UserDefaults.standard.string(forKey: "id")!
        
        Alamofire.request(APIRequest.init(url: url).get()).responseJSON{
            response in
            
            print(response)
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                for task in json["data"]["tasks"].arrayValue{
                    if !task["done"].boolValue{
                        self.tasks.append(Task.init(id: task["_id"].stringValue,
                                                    creatorID: task["_creator"].stringValue,
                                                    title: task["title"].stringValue,
                                                    description: task["description"].stringValue))
                    }
                }
                
                self.tasks.reverse()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
                if self.tasks.isEmpty{
                    HUD.flash((.label("لا توجد تكليفات جديدة")), delay: 0.5)
                }
                
            case .failure(let error):
                print(error)
                HUD.flash((.label("لا توجد تكليفات جديدة")), delay: 0.5)
                
            }
            
        }
    }
    
    @objc func markTaskAsDone(_ sender: UIButton){
        var request = APIRequest.init(url: API.TASKS).putJSON()
        
        let params: JSON = [
            "_id": tasks[sender.tag].id
        ]
        
        let json = params.rawString()!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON{
            response in
            
            print(response)
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if json["data"]["task"]["done"].boolValue {
                    HUD.flash((.label("تم إنهاء الكليف")), delay: 0.7)
                    self.getData()
                }
                else{
                    HUD.flash((.label("حدث خطأ، حاول مرة أخرى")), delay: 0.5)
                }
            case .failure(let error):
                print(error)
                HUD.flash((.label("حدث خطأ، حاول مرة أخرى")), delay: 0.5)
            }
        }
    }
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTVCell", for: indexPath) as! TaskTVCell

        // Configure the cell...
        
        if tasks != nil && !tasks.isEmpty{
            let titleAttrs = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                NSAttributedStringKey.foregroundColor: UIColor.black,
                ] as [NSAttributedStringKey : Any]
            
            let contentAttrs = [
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                NSAttributedStringKey.foregroundColor: UIColor.gray,
                ] as [NSAttributedStringKey : Any]
            
            let titleAttrStr = NSMutableAttributedString(string: tasks[indexPath.row].title, attributes: titleAttrs)
            let contentAttrStr = NSMutableAttributedString(string: "\n \(tasks[indexPath.row].description)", attributes: contentAttrs)
            
            titleAttrStr.append(contentAttrStr)
            cell.contentLbl.attributedText = titleAttrStr
            
            cell.markDoneBtn.tag = indexPath.row
            cell.markDoneBtn.addTarget(self, action: #selector(markTaskAsDone(_:)), for: .touchUpInside)
            
        }
        
        return cell
    }

}
