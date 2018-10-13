//
//  NewsFeedTVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/18/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import PKHUD
import Photos
import AVKit
import AVFoundation

class NewsFeedTVC: UITableViewController {
    
    var posts = [Post]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.estimatedRowHeight = self.view.frame.width
        tableView.rowHeight = UITableViewAutomaticDimension
     
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = UIColor.green
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        getData()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        getData()
    }

    func getData(){
        
        posts.removeAll()
        
        Alamofire.request(APIRequest.init(url: API.NEWS_FEED).get()).responseJSON{
            
            response in
            
            print(response)
            
            switch response.result{
            case .success(let value):
                let json = JSON(value)
                print(json["status"])
                if json["status"].boolValue{
                    
                    for post in json["data"]["media"].arrayValue{
                        
                        self.posts.append(Post.init(id: post["_id"].stringValue,
                                                    editorID: post["_creator"]["_id"].stringValue,
                                                    editorImg: post["_creator"]["avatar"].stringValue,
                                                    editorName: post["_creator"]["name"].stringValue,
                                                    img: post["url"].stringValue,
                                                    status: post["status"].intValue,
                                                    comment: "",
                                                    timeInMillis: 0,
                                                    type: post["type"].stringValue,
                                                    width: post["attributes"]["width"].doubleValue,
                                                    height: post["attributes"]["height"].doubleValue))
                    }
                    
                    self.posts.reverse()
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
                else{
                    HUD.flash((.label("لا توجد منشورات جديدة")), delay: 0.5)
                }
            case .failure(let error):
                print(error)
                HUD.flash((.label("حدث خطأ، حاول مرة أخرى")), delay: 0.5)
            }
        }
    }
    
    func loadImage(url: URL, cell: NewsFeedTVCell) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.postIV.image = downloadedImage
                        
                        print("width: \(downloadedImage.size.width)")
                        print("height: \(downloadedImage.size.height)")
                        
                        if downloadedImage.size.width / downloadedImage.size.height >= 1{
                            cell.postIV.contentMode = .scaleAspectFit
                            print("greaterOrEqual")
                        }
                        else{
                            cell.postIV.contentMode = .scaleAspectFill
                            print("lessThan")
                        }
                        
                        let ratio = downloadedImage.size.width / cell.contentView.frame.width
                        cell.feedImageHeightConstraint.constant = downloadedImage.size.height / ratio
                    }
                }
            }
        }
    }
    
    @objc func acceptPost(_ sender: UIButton){
        
        var request = APIRequest.init(url: API.NEWS_FEED).putJSON()
        
        let params: JSON = [
            "_id": posts[sender.tag].id,
            "status": 1002 // accept
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
                
                if json["status"] == 1004 {
                    HUD.flash((.label("تمت الموافقة")), delay: 0.5)
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
    
    @objc func rejectPost(id: String, comment: String){
        
        var request = APIRequest.init(url: API.NEWS_FEED).putJSON()
        
        let params: JSON = [
            "_id": id,
            "comment": comment,
            "status": 1003 // reject
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
                
                if json["status"] == 1003 {
                    HUD.flash((.label("تمت الرفض")), delay: 0.5)
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
    
    @objc func addRejectComment(_ sender: UIButton){
        
        let alert = UIAlertController(title: "رفض المنشور", message: "برجاء توضيح سبب الرفض", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "سبب الرفض"
        }
        
        alert.addAction(UIAlertAction(title: "إرسال", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction) -> Void in
            
            let comment = alert.textFields![0].text!
            self.rejectPost(id: self.posts[sender.tag].id, comment: comment)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func saveImage(_ sender: UIButton){
        let index: Int = sender.tag
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! NewsFeedTVCell
        
        if posts[sender.tag].type == "Image"{
            
            UIImageWriteToSavedPhotosAlbum(cell.postIV.image!, nil, nil, nil)
            HUD.flash((.label("Image saved to Camera Roll")), delay: 0.5)
        }
        else{
            DispatchQueue.global(qos: .background).async {
                
                let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .short
                let destinationFileUrl = documentsUrl.appendingPathComponent("NET-AD-\(dateFormatter.string(from: Date())).mp4")
                
                //Create URL to the source file you want to download
                let fileURL = URL(string: API.SERVER + self.posts[index].img)
                print(self.posts[index].img)
                
                let sessionConfig = URLSessionConfiguration.default
                let session = URLSession(configuration: sessionConfig)
                
                let request = URLRequest(url:fileURL!)
                
                let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                    if let tempLocalUrl = tempLocalUrl, error == nil {
                        // Success
                        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                            print("Successfully downloaded. Status code: \(statusCode)")
                        }
                        
                        do {
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                            print(destinationFileUrl)
                            DispatchQueue.main.async {
                                HUD.flash((.label("Video saved to Camera Roll")), delay: 0.5)
                            }
                            print("Video is saved!")
                            
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                        
                    } else {
                        print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
                    }
                }
                task.resume()
                
            }
        }
        
    }
    
    @objc func togglePlayer(_ sender: UIButton){
        
        let index = sender.tag
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! NewsFeedTVCell
        
        if cell.playerView.player?.rate == 0 || cell.playerView.player?.error == nil{
            cell.playerView.isHidden = false
            cell.playerView.player?.play()
            cell.videoPlayBtn.isHidden = true
        }
        else{
            cell.playerView.isHidden = true
            cell.playerView.player?.pause()
            cell.videoPlayBtn.isHidden = false
            cell.playerView.player = nil;
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if !self.posts.isEmpty{
            let ratio = tableView.frame.width / CGFloat(self.posts[indexPath.row].width)
            return 59 + ratio * CGFloat(self.posts[indexPath.row].height)
        }
        else{
            return UITableViewAutomaticDimension
        }
        
//        if self.posts[indexPath.row].height != 0.0{
//            return CGFloat(self.posts[indexPath.row].height)
//        }
//        else{
//            return UITableViewAutomaticDimension
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedTVCell", for: indexPath) as! NewsFeedTVCell
//        var cellFrame = cell.frame.size
//        cellFrame.height =  cellFrame.height - 15
//        cellFrame.width =  cellFrame.width - 15
        
        if UserDefaults.standard.string(forKey: "type") != "Editor"{
            if posts != nil && !posts.isEmpty{
                
                let post = posts[indexPath.row]
                
                switch post.status{
                    
                case 1001: // pending
                    cell.acceptBtn.isHidden = false
                    cell.rejectBtn.isHidden = false
                    
                case 1003: // rejected
                    cell.acceptBtn.isHidden = false
                    cell.acceptBtn.isEnabled = true
                    cell.rejectBtn.isEnabled = false
                    
                default: // accepted, published
                    cell.acceptBtn.isHidden = true
                    cell.rejectBtn.isHidden = true
                }
               
//                var cellFrame = cell.frame.size
//                cellFrame.height =  cellFrame.height - 15
//                cellFrame.width =  cellFrame.width - 15
                
                if post.type == "Image"{
                    
                    let url = URL(string: API.SERVER + post.img)
                    print(url!)
//                    self.loadImage(url: url!, cell: cell)
//                    cell.postIV.sd_setImage(with: url, placeholderImage: nil)
                    
//                    if post.width / post.height >= 1{
//                        cell.postIV.contentMode = .scaleAspectFit
//                        print("greaterOrEqual")
//                    }
//                    else{
//                        cell.postIV.contentMode = .scaleAspectFill
//                        print("lessThan")
//                    }
                    
                    cell.postIV.sd_setImage(with: url, placeholderImage: nil, options: [], completed: { (downloadedImage, error, cache, url) in
                        if downloadedImage != nil {
                            cell.indicator.stopAnimating()
//                            cell.feedImageHeightConstraint.constant = self.getAspectRatioAccordingToiPhones(cellImageFrame: cellFrame, downloadedImage: downloadedImage!)

                            print("width: \(downloadedImage?.size.width)")
                            print("height: \(downloadedImage?.size.height)")

//                            if (downloadedImage?.size.width)! / (downloadedImage?.size.height)! >= 1{
//                                cell.postIV.contentMode = .scaleAspectFit
//                                print("greaterOrEqual")
//                            }
//                            else{
//                                cell.postIV.contentMode = .scaleAspectFill
//                                print("lessThan")
//                            }
//
//                            let ratio = (downloadedImage?.size.width)! / self.view.frame.width
////                            cell.feedImageHeightConstraint.constant = (downloadedImage?.size.height)! / ratio
//                            self.posts[indexPath.row].height = Double((downloadedImage?.size.height)! / ratio)
//                            print("cellHeight: \(self.posts[indexPath.row].height)")
//                            tableView.endUpdates()
                        }

                    })
                    
                    
                    cell.playerView.isHidden = true
                    cell.videoPlayBtn.isHidden = true
                }
                else{
                    print(API.SERVER + post.img)
//                    cell.postIV.image = UIImage(named: "post_bg2")
                    getThumbnailFrom(path: URL(string: API.SERVER + post.img)!, cell: cell)
                    
                    cell.videoPlayBtn.isHidden = false
                    cell.playerView.isHidden = false
                    cell.playerView.frame = cell.postIV.frame
                    cell.playerView.playerLayer.player = AVPlayer(url: URL(string: API.SERVER + post.img)!)
                    cell.playerView.isHidden = true
                    cell.videoPlayBtn.superview?.bringSubview(toFront: cell.videoPlayBtn)
                    cell.videoPlayBtn.tag = indexPath.row
                    cell.videoPlayBtn.addTarget(self, action: #selector(togglePlayer(_:)), for: .touchUpInside)
                }
                
                cell.editorIV.sd_setImage(with: URL(string: API.SERVER + post.editorImg), placeholderImage: UIImage(named: "profile_icn"))
                
                cell.editorTV.text = post.editorName
            }
            
            
            cell.acceptBtn.tag = indexPath.row
            cell.acceptBtn.addTarget(self, action: #selector(acceptPost(_:)), for: .touchUpInside)
            cell.rejectBtn.tag = indexPath.row
            cell.rejectBtn.addTarget(self, action: #selector(addRejectComment(_:)), for: .touchUpInside)
            cell.saveBtn.tag = indexPath.row
            cell.saveBtn.addTarget(self, action: #selector(saveImage(_:)), for: .touchUpInside)
            
        }
        else{
            cell.acceptBtn.isHidden = true
            cell.rejectBtn.isHidden = true
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("row clicked: \(indexPath.row)")
        let cell = tableView.cellForRow(at: indexPath) as! NewsFeedTVCell
        
        if posts[indexPath.row].type != "Image"{
            if cell.playerView.player?.rate == 0 || cell.playerView.player?.error == nil{
                cell.playerView.isHidden = false
                cell.playerView.player?.play()
                cell.videoPlayBtn.isHidden = true
            }
            else{
                cell.playerView.isHidden = true
                cell.playerView.player?.pause()
                cell.videoPlayBtn.isHidden = false
                cell.playerView.player = nil
            }
        }
        
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if !posts.isEmpty && posts[indexPath.row].type == "Video"{
//
//            guard let videoCell = (cell as? NewsFeedTVCell) else { return }
//            let visibleCells = tableView.visibleCells
//            let minIndex = visibleCells.startIndex
//            if tableView.visibleCells.index(of: cell) == minIndex {
//                videoCell.playerView.player?.play()
//            }
//
//        }
//    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !posts.isEmpty && posts[indexPath.row].type == "Video"{
            guard let videoCell = cell as? NewsFeedTVCell else { return };
            
            videoCell.playerView.player?.pause();
            videoCell.playerView.player = nil;
        }
        
    }
    
    func getAspectRatioAccordingToiPhones(cellImageFrame:CGSize, downloadedImage: UIImage)->CGFloat {
        let widthOffset = downloadedImage.size.width - cellImageFrame.width
        let widthOffsetPercentage = (widthOffset*100)/downloadedImage.size.width
        let heightOffset = (widthOffsetPercentage * downloadedImage.size.height)/100
        let effectiveHeight = downloadedImage.size.height - heightOffset
        return(effectiveHeight)
    }
    // MARK: Optional function for resize of image
    func resizeHighImage(image:UIImage)->UIImage {
        let size = image.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
        
    }
    
    func getThumbnailFrom(path: URL, cell: NewsFeedTVCell) {
        
        DispatchQueue.global(qos: .background).async {
            
            do {
                
                let asset = AVURLAsset(url: path , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(1, 2), actualTime: nil)
                let downloadedImage = UIImage(cgImage: cgImage)
                
                print("vwidth: \(downloadedImage.size.width)")
                print("vheight: \(downloadedImage.size.height)")
                
                DispatchQueue.main.async(execute: {
                    
                    cell.postIV.image = downloadedImage
                    cell.indicator.stopAnimating()
                })
                
            } catch let error {
                
                print("*** Error generating thumbnail: \(error.localizedDescription)")
                
            }
            
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openVideo" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //                let video = tableDataSource[indexPath.row]
                if posts[indexPath.row].type == "Video"{
                    let destination = segue.destination as! AVPlayerViewController
                    destination.player = AVPlayer(url: URL(string: API.SERVER + self.posts[indexPath.row].img)!)
                    destination.player?.play()
                }
                
            }
        }
    }
}

