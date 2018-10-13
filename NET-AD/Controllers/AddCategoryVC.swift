//
//  AddCategoryVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/30/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddCategoryVC: UIViewController {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var selectedIV: UIImageView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    
    var uploadPV = UIProgressView()
    var uploadAV = UIAlertController()
    var timer = Timer()
    var progress: Float = 0
    
    @IBOutlet var indicator: UIActivityIndicatorView!
    //    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        descriptionTV.addBorder(view: descriptionTV, stroke: UIColor.gray, fill: UIColor.clear, radius: 15, width: 2)
    }
    
    @IBAction func addImgBtnOnClick(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func addBtnOnClick(_ sender: Any) {
    
        if let image = selectedIV.image{
            let photo = UIImagePNGRepresentation(image)
            uploadPhoto(fileData: photo!, width: Double(image.size.width), height: Double(image.size.height))
        }
        
    }
    
    func uploadPhoto(fileData: Data, width: Double, height: Double){
        
        let parameters: Parameters = [
            "_id": UserDefaults.standard.string(forKey: "id") ?? "",
            "title": self.nameTF.text!,
            "description": self.descriptionTV.text!,
            "width": "\(width)",
            "height": "\(height)"
        ]
        
        let headers = [
            "x_auth": UserDefaults.standard.string(forKey: "x_auth") ?? "",
            "client_id": "nakeeb"
        ]
        
        print(parameters)
        
        indicator.startAnimating()
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileData, withName: "template", fileName: "category.png", mimeType: "image/png")
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        },
                         to: API.POST_CATEGORIES, method: .post, headers: headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                self.uploadAV = UIAlertController(title: "Please wait", message: "Photo is uploading", preferredStyle: .alert)
                
                //  Progress dialog
                self.present(self.uploadAV, animated: true, completion: {
                    
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.syncProgress), userInfo: nil, repeats: true)
                    //  Add your progressbar after alert is shown (and measured)
                    let margin:CGFloat = 8.0
                    let rect = CGRect(x: margin, y: 72, width: self.uploadAV.view.frame.width - margin * 2.0 , height: 2.0)
                    self.uploadPV = UIProgressView(frame: rect)
                    self.uploadPV.progress = self.progress
                    
                    self.uploadPV.tintColor = UIColor.blue
                    self.uploadAV.view.addSubview(self.uploadPV)
                    
                })
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                    self.progress = Float(progress.fractionCompleted)
                })
                
                upload.responseJSON { response in
                    print("resVal: \(response.result.value)")
                    self.syncProgress()
                    
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
                
                self.indicator.stopAnimating()
                
            case .failure(let encodingError):
                print("uploadErr: \(encodingError)")
                
                self.syncProgress()
                self.indicator.stopAnimating()
                
                let alert = UIAlertController(title: "Error", message: "Upload photo is faild!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

    @objc func syncProgress() {
        
        self.uploadPV.progress = self.progress / 1.0
        print("progNow: \(self.uploadPV.progress)")
        if self.uploadPV.progress > 0.99 {
            timer.invalidate()
            uploadAV.dismiss(animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension AddCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.selectedIV.image = pickedImage
        } else {
            let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.selectedIV.image = pickedImage
        }
        addBtn.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
