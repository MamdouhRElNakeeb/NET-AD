//
//  PostCategoriesCVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PostCategoriesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var items = Array<Category>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        initCollectionView()
        
        getData()
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
    }
    
    @objc func back(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewCategoryOnClick(_ sender: Any) {
        
    }
    
    func getData(){
        
        Alamofire.request(APIRequest.init(url: API.POST_CATEGORIES).get()).responseJSON{
            response in
            
            print(response)
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                
                if json["status"].boolValue{
                    for category in json["data"]["sections"].arrayValue{
                        self.items.append(Category.init(id: category["_id"].stringValue,
                                                        title: category["title"].stringValue,
                                                        description: category["description"].stringValue,
                                                        img: category["template"].stringValue,
                                                        width: category["width"].doubleValue,
                                                        height: category["height"].doubleValue))
                    }
                    self.collectionView?.reloadData()
                }
                else{
                    let alert = UIAlertController(title: "Error", message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }

    func initCollectionView(){
        
        let itemSize = (self.collectionView.frame.width / 2)
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 20
        
        collectionView?.collectionViewLayout = flowLayout
        
        collectionView?.setCollectionViewLayout(flowLayout, animated: true)
        collectionView?.register(PostCategoryCVCell.self, forCellWithReuseIdentifier: "PostCategoryCVCell")
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white
        collectionView?.allowsSelection = true
        
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCategoryCVCell", for: indexPath) as! PostCategoryCVCell
    
        // Configure the cell
        cell.titleLbl.text = items[indexPath.row].title
        cell.bgIV.sd_setImage(with: URL(string: API.SERVER + items[indexPath.row].img))
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewPostVC") as! NewPostVC
        vc.category = self.items[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
