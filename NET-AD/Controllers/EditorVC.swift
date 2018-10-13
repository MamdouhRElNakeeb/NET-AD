//
//  ViewController.swift
//  Sa7fyApp
//
//  Created by Mamdouh El Nakeeb on 7/3/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import CLImageEditor
import iOSPhotoEditor
import PKHUD

import AVKit
import AVFoundation
import MobileCoreServices

class EditorVC: UIViewController {

    @IBOutlet weak var editPhotoBtn: UIButton!
    @IBOutlet weak var videoEditingBtn: UIButton!
    @IBOutlet weak var collageBtn: UIButton!
    
    // Create a custom transitioning animation object
    //   This is an instance of our CustomViewControllerAnimatedTransitioning class
    let transition = CustomViewControllerAnimatedTransitioning()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        editPhotoBtn.imageView?.tintColor = UIColor.white
        videoEditingBtn.imageView?.tintColor = UIColor.white
        collageBtn.imageView?.tintColor = UIColor.white
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
    }
    
    @objc func back(){
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func videEditingBtnOnClick(_ sender: Any) {
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
//        videoPickerController.transitioningDelegate = self
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false { return }
        videoPickerController.allowsEditing = true
        videoPickerController.sourceType = .photoLibrary
        videoPickerController.mediaTypes = [kUTTypeMovie as String]
        videoPickerController.modalPresentationStyle = .custom
        self.present(videoPickerController, animated: true, completion: nil)
    }
    
    @IBAction func editPhotoBtnOnClick(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
}

extension EditorVC: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
//        imageView.image = image
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        HUD.flash((.label("Image saved to Camera Roll")), delay: 0.5)
        print("editing done")
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}

extension EditorVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            
            
//            let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
//            photoEditor.photoEditorDelegate = self
//            photoEditor.image = image
//            //Colors for drawing and Text, If not set default values will be used
//            //photoEditor.colors = [.red, .blue, .green]
//
//            //Stickers that the user will choose from to add on the image
//            for i in 0...10 {
//                photoEditor.stickers.append(UIImage(named: i.description )!)
//            }
            
            //To hide controls - array of enum control
            //photoEditor.hiddenControls = [.crop, .draw, .share]
            
//            present(photoEditor, animated: true, completion: nil)
  
            guard let editor = CLImageEditor(image: image, delegate: self) else {
                return
            }
            self.present(editor, animated: true, completion: {})
            
        }
        
        else if let videoURL = info["UIImagePickerControllerReferenceURL"] as? URL{
            self.dismiss(animated: true, completion: nil)
            
            // We create a VideoEditorViewController to play video as well as for editing purpose
            let videoEditorViewController = VideoEditorViewController()
            videoEditorViewController.videoURL = videoURL
            videoEditorViewController.videoAsset = AVURLAsset(url: videoURL)
            videoEditorViewController.transitioningDelegate = self
            self.present(videoEditorViewController, animated: true, completion: nil)
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        HUD.flash((.label("Image saved to Camera Roll")), delay: 0.5)
        print("editing done")
        dismiss(animated: true, completion: nil)
    }
    
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        print("cancelled")
        dismiss(animated: true, completion: nil)
    }
}

/**
 Conform to UIViewControllerTransitioningDelegate to performs custom transisioning animation
 */
extension EditorVC: UIViewControllerTransitioningDelegate {
    
    // Custom presentation animation
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.shrinkedPoint = videoEditingBtn.center
        transition.transitionMode = .present
        return transition
    }
    
    // Custom dismission animation
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.shrinkedPoint = videoEditingBtn.center
        transition.transitionMode = .dismiss
        return transition
    }
}


