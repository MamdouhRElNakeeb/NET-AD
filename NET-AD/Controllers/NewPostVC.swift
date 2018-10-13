//
//  NewPostVC.swift
//  Sa7fyApp
//
//  Created by Mamdouh El Nakeeb on 7/3/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Photos
import PKHUD
import iOSPhotoEditor
import Alamofire
import SwiftyJSON
import RichEditorView
import GrowingTextView
import AssetsLibrary


class NewPostVC: UIViewController {

    @IBOutlet var postBgHeightConstraint: NSLayoutConstraint!
    @IBOutlet var postBgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var postBgIV: UIImageView!
    @IBOutlet weak var titleBgV: UIView!
    
    @IBOutlet var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleGTV: GrowingTextView!
    @IBOutlet var textEditor: RichTextEditor!
    
    @IBOutlet weak var contentTV: UITextView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var addImgBtn: UIButton!
    @IBOutlet weak var addVidBtn: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var imgIndicator: UIActivityIndicatorView!
    
//    var textEditor = RichTextEditor()
    var lastLocation = CGPoint(x: 0, y: 0)
    var textEditorX: CGFloat = 0.0
    var textEditorY:CGFloat = 0.0
    
    var richEditor = RichEditorView()
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()
    
    var cropView = ImageCropper()
    var tempIV = DraggableImageView()
    var postIVs = [DraggableImageView]()
    
    // Store original video and video for merging as properties
    var videoURL: URL!
    var videoAsset: AVAsset!
    // The video player object: an instance of VideoPlayerView
    var videoPlayerView: VideoPlayerView!
    
    var assetWriter:AVAssetWriter?
    var assetReader:AVAssetReader?
    let bitrate:NSNumber = NSNumber(value:250000)
    
    let processingLabel: UILabel = {
        let label = UILabel()
        label.text = "PROCESSING"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.alpha = 0.7
        label.font = UIFont.systemFont(ofSize: 30)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    
    // Create a custom transitioning animation object
    //   This is an instance of our CustomViewControllerAnimatedTransitioning class
    let transition = CustomViewControllerAnimatedTransitioning()
    
    var uploadPV = UIProgressView()
    var uploadAV = UIAlertController()
    var timer = Timer()
    var progress: Float = 0
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    var category = Category()
    var postTitle = ""
    var postDesc = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        postBgIV.sd_setImage(with: URL(string: API.SERVER + category.img))
                
        self.postBgHeightConstraint.constant = CGFloat(category.height) * UIScreen.main.bounds.width / CGFloat(category.width)
        self.postBgWidthConstraint.constant = UIScreen.main.bounds.width
        
        
        postBgIV.sd_setImage(with: URL(string: API.SERVER + category.img), placeholderImage: nil, options: [], completed: { (downloadedImage, error, cache, url) in
            if downloadedImage != nil {
                self.imgIndicator.stopAnimating()
                print("width: \(downloadedImage?.size.width)")
                print("height: \(downloadedImage?.size.height)")
                
//                if (downloadedImage?.size.width)! / (downloadedImage?.size.height)! >= 1{
//                    self.postBgIV.contentMode = .scaleAspectFit
//                    print("greaterOrEqual")
//                }
//                else{
//                    self.postBgIV.contentMode = .scaleAspectFill
//                    print("lessThan")
//                }
//
//                let ratio = (downloadedImage?.size.width)! / self.containerView.frame.width
//                self.postBgHeightConstraint.constant = (downloadedImage?.size.height)! / ratio
                
//                self.containerView.frame = CGRect(x: self.containerView.frame.minX, y: self.containerView.frame.minY, width: self.containerView.frame.width, height: (downloadedImage?.size.height)! / ratio)
                
//                let widthOffset = downloadedImage.size.width - containerView.frame.width
//                let widthOffsetPercentage = (widthOffset * 100) / downloadedImage.size.width
//                let heightOffset = (widthOffsetPercentage * downloadedImage.size.height)/100
//                let effectiveHeight = downloadedImage.size.height - heightOffset
            }
            
        })
        
        titleGTV.layer.borderColor = UIColor(red: 238/255, green: 223/255, blue: 80/255, alpha: 1).cgColor
        titleGTV.layer.borderWidth = 2
        titleGTV.layer.masksToBounds = true
        titleGTV.font = UIFont.systemFont(ofSize: 22)
        titleGTV.textAlignment = .center
        titleGTV.textColor = UIColor.white
        titleGTV.contentInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        titleGTV.autocorrectionType = .no
        titleGTV.delegate = self
        
        textEditor.dataSource = self
        textEditor.text = "إدخل النص هنا"
        textEditor.layer.borderColor = UIColor.clear.cgColor
        textEditor.textColor = UIColor.white
        textEditor.font = UIFont.systemFont(ofSize: 18)
        textEditor.textAlignment = .center
        textEditor.backgroundColor = UIColor.clear
        textEditor.layer.borderColor = UIColor.clear.cgColor
    
        lastLocation = textEditor.center

        self.containerView.addSubview(textEditor)
        
        textEditor.topAnchor.constraint(equalTo: titleGTV.bottomAnchor, constant: 10)
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "done"), style: .plain, target: self, action: #selector(savePost))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        navigationItem.title = "منشور جديد"
    }
    
    @objc func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.textEditor.superview)
        self.textEditor.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
    }

    @objc func savePost() {
        
        if videoURL != nil{
            
            self.exportVideo()
            
        }
        else{
            let photoEditor = PhotoEditorViewController(nibName:"PhotoEditorViewController",bundle: Bundle(for: PhotoEditorViewController.self))
            photoEditor.photoEditorDelegate = self
            let bounds = CGRect(x: 0, y: 0, width: self.containerView.bounds.width, height: self.postBgHeightConstraint.constant)
            //            let size = CGSize(width: self.postBgIV.bounds.width, height: postBgIV.bounds.height)
            photoEditor.image = self.containerView.getSnapshotImage(size: bounds.size)
            //Colors for drawing and Text, If not set default values will be used
            //photoEditor.colors = [.red, .blue, .green]
            
            //Stickers that the user will choose from to add on the image
            for i in 0...23{
                photoEditor.stickers.append(UIImage(named: "stamp\(i)")!)
            }
            
            //To hide controls - array of enum control
            //photoEditor.hiddenControls = [.crop, .draw, .share]
            
            present(photoEditor, animated: true, completion: nil)
        }
        
            
            
//        }
//        else{
//            HUD.flash((.label("an error occurred, Try again later!")), delay: 0.5)
//        }
        
    }
    
    @IBAction func addImgBtnOnClick(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func exportVideo(){
        
        postTitle = titleGTV.text
        postDesc = textEditor.htmlString()
        
        self.view.addSubview(processingLabel)
        processingLabel.frame = self.containerView.frame
        
        let mutableComposition = getVideoComposition()
        
        let videoTrack: AVAssetTrack = mutableComposition.tracks(withMediaType: AVMediaType.video)[0]
        let videoSize = videoTrack.naturalSize
        let ratio = videoSize.width / containerView.frame.width
        print("ratio: \(ratio)")
        print("width: \(videoSize.width)")
        print("height: \(videoSize.height)")
        
        videoPlayerView.controlsContainerView.isHidden = true
        textEditor.endEditing(true)
        titleGTV.endEditing(true)
        
        titleGTV.transform = titleGTV.transform.scaledBy(x: ratio, y: ratio)
        titleGTV.layer.frame = CGRect(x: -9 * ratio, y: 25 * ratio, width: titleGTV.frame.width, height: titleGTV.frame.height)
    
        textEditor.transform = CGAffineTransform(scaleX: ratio, y: ratio)
        
        
        let videoLayer = CALayer()
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.frame = CGRect(x: 0, y: videoPlayerView.frame.minY * ratio, width: videoSize.width, height: videoSize.height)
        
        let containerLayer = CALayer()
        containerLayer.isGeometryFlipped = true
        containerLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: postBgHeightConstraint.constant * ratio)
//        containerLayer.addSublayer(bgLayer)
        textEditor.layer.isGeometryFlipped = true
        textEditor.center.x = containerLayer.frame.midX
        textEditor.center.y = titleGTV.bounds.maxY + 20 * ratio
//        textEditor.layer.contentsGravity = kCAGravityResizeAspect
        titleGTV.layer.isGeometryFlipped = true
//        titleGTV.layer.contentsGravity = kCAGravityResizeAspect
        
        let bounds = CGRect(x: 0, y: 0, width: self.containerView.bounds.width, height: self.postBgHeightConstraint.constant)
        
        videoPlayerView.isHidden = true
        titleGTV.isHidden = true
        textEditor.isHidden = true
        
        let vidBg = CALayer()
        vidBg.frame = postBgIV.frame
//        vidBg.contents = postBgIV.image?.cgImage
        vidBg.contents = self.containerView.getSnapshotImage(size: bounds.size).cgImage
        vidBg.transform = CATransform3DMakeScale(ratio, ratio, 1)
        vidBg.frame = CGRect(x: 0, y: 0, width: vidBg.frame.width, height: vidBg.frame.height)
        
        containerLayer.addSublayer(vidBg)
        containerLayer.addSublayer(videoLayer)
//        containerLayer.addSublayer(textEditor.layer)
//        containerLayer.addSublayer(titleGTV.layer)
//        containerLayer.masksToBounds = true
        
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = CMTimeMake(1, 30)
        layerComposition.renderSize = CGSize(width: videoSize.width, height: containerLayer.frame.height)
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: containerLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mutableComposition.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        let videoScale = CGAffineTransform(scaleX: 1, y: 1.8)
        layerInstruction.setTransform(videoScale, at: kCMTimeZero)
        instruction.layerInstructions = [layerInstruction]
        layerComposition.instructions = [instruction]
        
        let exportUrl = generateExportUrl()
    
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .medium
        dateFormat.timeStyle = .short
        var tempFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("NET-AD-\(dateFormat.string(from: Date())).mp4", isDirectory: false)
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)

        // Set up exporter
        guard let exporter = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetMediumQuality) else { return }
        exporter.videoComposition = layerComposition
        exporter.outputURL = tempFileUrl
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.exportAsynchronously() {
            DispatchQueue.main.async {
                
                self.exportDidComplete(exportURL: exporter.outputURL!, doneEditing: true)
                print("urllllll \(exporter.outputURL!)")
//                self.uploadVideo(path: exporter.outputURL!)
                let data = try? Data(contentsOf: tempFileUrl)
                print(data!)
//                self.uploadPost(fileData: data!, type: "Video")
//                self.uploadVideo(path: tempFileUrl)
                self.uploadVideoRaw(path: tempFileUrl, width: Double(layerComposition.renderSize.width), height: Double(layerComposition.renderSize.height))
            }
        }
    }
    
    // Helper function that return a AVMutableComposition instance of the current video
    func getVideoComposition() -> AVMutableComposition {
        // Create an AVMutableComposition for editing
        let mutableComposition = AVMutableComposition()
        // Get video tracks and audio tracks of our video and the AVMutableComposition
        let compositionVideoTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionAudioTrack = mutableComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let videoTrack: AVAssetTrack  = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let audioTrack: AVAssetTrack  = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        // Add our video tracks and audio tracks into the Mutable Composition normal order
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoTrack, at: kCMTimeZero)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: audioTrack, at: kCMTimeZero)
        } catch {
//            alertErrors()
            return AVMutableComposition()
        }
        
        return mutableComposition
    }
    
    // Helper function that generate a unique URL for saving
    func generateExportUrl() -> URL {
        
        // Create a custom URL using curernt date-time to prevent conflicted URL in the future.
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .long
        dateFormat.timeStyle = .short
        let dateString = dateFormat.string(from: Date())
        let exportPath = (documentDirectory as NSString).strings(byAppendingPaths: ["edited-video-\(dateString).mp4"])[0]
        
        return NSURL(fileURLWithPath: exportPath) as URL
    }
    
    //Export Finish Handler
    func exportDidComplete(exportURL: URL, doneEditing: Bool) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
        }) { saved, error in
            if saved {
            }
            else {
//                self.alertErrors()
                print("errrrreeerr")
            }
        }
        self.processingLabel.text = "UPLOADING"
//        self.processingLabel.removeFromSuperview()
       
    }
    
    @IBAction func addVidBtnOnClick(_ sender: Any) {
        
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
    
    // Helper function to pause currently playing video
    func pauseVideo() {
        videoPlayerView.player.pause()
        videoPlayerView.pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        videoPlayerView.isPlaying = false
    }
    
    @objc func syncProgress() {
        
        self.uploadPV.progress = self.progress / 1.0
        print("progNow: \(self.uploadPV.progress)")
        if self.uploadPV.progress > 0.99 {
            timer.invalidate()
            uploadAV.dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadVideo(path: URL){

        let parameters: Parameters = [
            "_creator": UserDefaults.standard.string(forKey: "id") ?? "",
            "_section": self.category.id,
            "type": "Video",
            "title": postTitle,
            "description": postDesc
        ]

        let headers = [
            "x_auth": UserDefaults.standard.string(forKey: "x_auth") ?? "",
            "client_id": "nakeeb"
        ]

        print(parameters)

//        indicator.startAnimating()
        
        var videoData: Data?
        var stream: InputStream?
        
        videoData = try! Data(contentsOf: path)
        print(videoData!)
        
        stream = InputStream(url: path)
        print(stream)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(stream!, withLength: UInt64((videoData?.count)!), name: "medium", fileName: "post.mp4", mimeType: "video/mp4")
            
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                print("heloo1111")
            }
            
        },
           to: API.NEWS_FEED, method: .post, headers: headers,
           
           encodingCompletion: { encodingResult in
            
            print(encodingResult)
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                self.uploadAV = UIAlertController(title: "Please wait", message: "Post is uploading", preferredStyle: .alert)
                
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
                            var msg = ""
                            if UserDefaults.standard.string(forKey: "type") != "Editor"{
                                msg = "تم نشر الخبر بنجاح"
                            }
                            else{
                                msg = json["message"].stringValue
                            }
                            
                            let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                                (action: UIAlertAction) -> Void in
                                
                                HUD.flash((.label("Post saved to Camera Roll")), delay: 0.5)
                                
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
                print(encodingError)
                
                self.syncProgress()
                self.indicator.stopAnimating()
                
                let alert = UIAlertController(title: "Error", message: "Upload photo is faild!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        })


    }
    
    func compressFile(urlToCompress: URL, outputURL: URL, completion:@escaping (URL)->Void){
        //video file to make the asset
        
        var audioFinished = false
        var videoFinished = false
        
        let asset = AVAsset(url: urlToCompress);
        
        let duration = asset.duration
        let durationTime = CMTimeGetSeconds(duration)
        
        print("Video Actual Duration -- \(durationTime)")
        
        //create asset reader
        do{
            assetReader = try AVAssetReader(asset: asset)
        } catch{
            assetReader = nil
        }
        
        guard let reader = assetReader else{
            fatalError("Could not initalize asset reader probably failed its try catch")
        }
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
        
        let videoReaderSettings: [String:Any] =  [(kCVPixelBufferPixelFormatTypeKey as String?)!:kCVPixelFormatType_32ARGB ]
        
        // ADJUST BIT RATE OF VIDEO HERE
        
        let videoSettings:[String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:self.bitrate],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoWidthKey: videoTrack.naturalSize.width
        ]
        
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        
        if reader.canAdd(assetReaderVideoOutput){
            reader.add(assetReaderVideoOutput)
        }else{
            fatalError("Couldn't add video output reader")
        }
        
        if reader.canAdd(assetReaderAudioOutput){
            reader.add(assetReaderAudioOutput)
        }else{
            fatalError("Couldn't add audio output reader")
        }
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        //we need to add samples to the video input
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        
        do{
            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        }catch{
            assetWriter = nil
        }
        guard let writer = assetWriter else{
            fatalError("assetWriter was nil")
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: kCMTimeZero)
        
        
        let closeWriter:()->Void = {
            if (audioFinished && videoFinished){
                self.assetWriter?.finishWriting(completionHandler: {
                    print("------ Finish Video Compressing")
                    self.checkFileSize(sizeUrl: (self.assetWriter?.outputURL)!, message: "The file size of the compressed file is: ")
                    
                    completion((self.assetWriter?.outputURL)!)
                })
                
                self.assetReader?.cancelReading()
            }
        }
        
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while(audioInput.isReadyForMoreMediaData){
                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                if (sample != nil){
                    audioInput.append(sample!)
                }else{
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            //request data here
            while(videoInput.isReadyForMoreMediaData){
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil){
                    let timeStamp = CMSampleBufferGetPresentationTimeStamp(sample!)
                    let timeSecond = CMTimeGetSeconds(timeStamp)
                    let per = timeSecond / durationTime
                    print("Duration --- \(per)")
                    DispatchQueue.main.async {
//                        self.progress.progress = Float(per)
                    }
                    videoInput.append(sample!)
                }else{
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
//                        self.progress.progress = 1.0
                        closeWriter()
                    }
                    break;
                }
            }
        }
    }
    
    func checkFileSize(sizeUrl: URL, message:String){
        let data = NSData(contentsOf: sizeUrl)!
        print(message, (Double(data.length) / 1048576.0), " mb")
    }
    
    func compressVideooo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4 //AVFileTypeQuickTimeMovie (m4v)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func uploadVideoRaw(path: URL, width: Double, height: Double){
        
        let parameters: [String: Any] = [
            "_creator": UserDefaults.standard.string(forKey: "id") ?? "",
            "_section": self.category.id,
            "type": "Video",
            "title": postTitle,
            "description": postDesc,
            "width": "\(width)",
            "height": "\(height)"
        ]
        
        let headers = [
            "x_auth": UserDefaults.standard.string(forKey: "x_auth") ?? "",
            "client_id": "nakeeb"
        ]
        
        // url path to php file
        let url = URL(string: API.NEWS_FEED)!
        
        // Adding the url to the request variable
        var request = URLRequest(url: url)
        
        // Declare POST method
        request.httpMethod = "POST"
        
        
        // Assign video to videoData variable
        let videoData = NSData(contentsOf: path)
        
        // Creat a UUID for the boundary as a string
        let boundary = "Boundary-\(UUID().uuidString)"
        
        //Set the request value to multipart/form-data     the boundary is the UUID string
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers{
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        let body = NSMutableData();
        
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        let filename = "post.mp4"
        let mimetype = "video/mp4"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"medium\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(videoData! as Data)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        request.httpBody = body as Data
//        request.httpBody = createBodyWithParamsVideo(parameters, //This is the card's UUID
//            filePathKey: "medium",
//            imageDataKey: videoData as Data, //The video's data from the card
//            boundary: boundary) // A unquie ID setup just for the baundary
        
        // launch session
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if response == nil {
                let alert = UIAlertController(title: "Error", message: "An error occurred, Try again later!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: {
                    (UIAlertAction) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            
            // get main queue to communicate back to user
            DispatchQueue.main.async(execute: {
                if error == nil {
                    do {
                        let responseJSON = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                       
                        let json = JSON(responseJSON!)
                        print(json)
                        
                        if json["status"].boolValue{
                            var msg = ""
                            if UserDefaults.standard.string(forKey: "type") != "Editor"{
                                msg = "تم نشر الخبر بنجاح"
                            }
                            else{
                                msg = json["message"].stringValue
                            }
                            print(msg)
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
                            self.navigationController?.pushViewController(vc, animated: true)
                            
                        }
                        else{
//                            let alert = UIAlertController(title: "Error", message: json["message"].stringValue, preferredStyle: UIAlertControllerStyle.alert)
//                            alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
//                            self.present(alert, animated: true, completion: nil)
                        }
                    
                        
                        // error while jsoning
                    } catch {
                        let message = error
                        print(message)
                        
                        let alert = UIAlertController(title: "Error", message: "An error occurred, Try again later!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    //no nothing
                    let alert = UIAlertController(title: "Error", message: "An error occurred, Try again later!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.destructive, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
            }.resume()
    
        
        
    }
    
    func uploadPost(fileData: Data, type: String, width: Double, height: Double){
        
        let parameters: Parameters = [
            "_creator": UserDefaults.standard.string(forKey: "id") ?? "",
            "_section": self.category.id,
            "type": type,
            "title": postTitle,
            "description": postDesc,
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
            print("upload vidimg")
            if type == "Image"{
                multipartFormData.append(fileData, withName: "medium", fileName: "post.png", mimeType: "image/png")
            }
            else{
//                let stream = InputStream(data: fileData)
                multipartFormData.append(fileData, withName: "medium", fileName: "post.mp4", mimeType: "video/mp4")
//                multipartFormData.append(stream, withLength: UInt64(fileData.count), name: "medium", fileName: "post.mp4", mimeType: "video/mp4")
                print("upload video")
            }
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                print("heloooooozzzzozozz")
            }
        },
           to: API.NEWS_FEED, method: .post, headers: headers)
            
        { (result) in
            
            print(result)
            switch result {
            case .success(let upload, _, _):
                
                self.uploadAV = UIAlertController(title: "Please wait", message: "Post is uploading", preferredStyle: .alert)
                
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
                            var msg = ""
                            if UserDefaults.standard.string(forKey: "type") != "Editor"{
                                msg = "تم نشر الخبر بنجاح"
                            }
                            else{
                                msg = json["message"].stringValue
                            }
                            
                            let alert = UIAlertController(title: "Success", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                                (action: UIAlertAction) -> Void in
                                
                                HUD.flash((.label("Post saved to Camera Roll")), delay: 0.5)
                                
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
    
    @objc func scaleImg(_ sender: UIPinchGestureRecognizer) {
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
    }
}

extension NewPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        
            picker.dismiss(animated: true, completion: nil)
            
            let ratio = image.size.width / image.size.height
            var newImg = DraggableImageView()
            
            if image.size.width > image.size.height{
                newImg = DraggableImageView(frame: CGRect(x:0, y: contentTV.frame.maxY + 30, width: self.containerView.frame.width, height: self.containerView.frame.width / ratio))
                
                newImg.imageView.contentMode = .scaleAspectFit
            }
            else{
                newImg = DraggableImageView(frame: CGRect(x:0, y: contentTV.frame.maxY + 30, width: self.containerView.frame.width, height: self.containerView.frame.width))
                newImg.imageView.contentMode = .scaleAspectFill
            }
            
            newImg.imageView.image = image
            newImg.draggableImageViewDelegate = self
            
            self.containerView.addSubview(newImg)
            self.containerView.bringSubview(toFront: newImg)
            
        }
        else if let videoURL = info["UIImagePickerControllerReferenceURL"] as? URL{
            
            self.dismiss(animated: true, completion: nil)
            /*
            let videoPlayerWidth = self.view.frame.width
            let videoPlayerHeight = videoPlayerWidth * 9/16
            let videoPlayerFrame = CGRect(x: 0, y: contentTV.frame.maxY + 30, width: videoPlayerWidth, height: videoPlayerHeight)
            videoPlayerView = VideoPlayerView(frame: videoPlayerFrame, url: videoURL)
            self.view.addSubview(videoPlayerView)
            */
            self.videoURL = videoURL
            self.videoAsset = AVURLAsset(url: videoURL)
            print("url true: \(videoURL)")
            addVideoPlayerView(with: self.containerView.frame.width)
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension NewPostVC: RichTextEditorDataSource{
    
    func presentationStyle(for richTextEditor: RichTextEditor!) -> RichTextEditorToolbarPresentationStyle {
//        return RichTextEditorToolbarPresentationStylePopover
        return RichTextEditorToolbarPresentationStyleModal
    }
    
    func shouldDisplayToolbar(for richTextEditor: RichTextEditor!) -> Bool {
        return true
    }
    
    func shouldDisplayRichTextOptionsInMenuController(for richTextEdiotor: RichTextEditor!) -> Bool {
        return true
    }
}

extension NewPostVC: GrowingTextViewDelegate{
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        self.titleHeightConstraint.constant = height
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let layoutManager:NSLayoutManager = textView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var numberOfLines = 0
        var index = 0
        var lineRange:NSRange = NSRange()
        
        while (index < numberOfGlyphs) {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange);
            numberOfLines = numberOfLines + 1
        }
        
        print(numberOfLines)
        
        if numberOfLines > 1{
            titleHeightConstraint.constant = 70
        }
        else{
            titleHeightConstraint.constant = 31
        }
        
    }
}

extension NewPostVC: DraggableImageViewDelegate{
    
    func cropImage(draggableImageView: DraggableImageView) {
        cropView = ImageCropper(frame: self.view.frame)
        cropView.initWithImage(image: draggableImageView.imageView.image!)
        cropView.delegate = self
        draggableImageView.isHidden = true
//        let croppedImage = cropView.getCroppedImage()
        self.tempIV = draggableImageView
        self.tempIV.isHidden = true
        self.view.addSubview(cropView)
    }
    
    func removeImageView(view: UIView) {
        view.removeFromSuperview()
    }
}

extension NewPostVC: CropViewDelegate{
    
    func croppedImg(image: UIImage) {
        
        print("asfjaskdfhas")
        let ratio = image.size.width / image.size.height
        var newImg = DraggableImageView()
        
        if image.size.width > image.size.height{
            newImg = DraggableImageView(frame: CGRect(x:0, y: contentTV.frame.maxY + 30, width: self.containerView.frame.width, height: self.containerView.frame.width / ratio))
            
            newImg.imageView.contentMode = .scaleAspectFit
        }
        else{
            newImg = DraggableImageView(frame: CGRect(x:0, y: contentTV.frame.maxY + 30, width: self.containerView.frame.width, height: self.containerView.frame.width))
            newImg.imageView.contentMode = .scaleAspectFill
        }
        
        newImg.imageView.image = image
        newImg.draggableImageViewDelegate = self
        self.cropView.removeFromSuperview()
        self.containerView.addSubview(newImg)
        
    }
    
}

// Add the videoPlayerView and handle device orientation
extension NewPostVC {
    // Add the videoPlayerView to the top of our screen
    func addVideoPlayerView(with width: CGFloat) {
        let videoPlayerWidth = width
        let videoPlayerHeight = videoPlayerWidth*9/16
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: videoPlayerWidth, height: videoPlayerHeight)
        videoPlayerView = VideoPlayerView(frame: videoPlayerFrame, url: videoURL)
        
        self.containerView.addSubview(videoPlayerView)
        videoPlayerView.bringSubview(toFront: self.containerView)
        
        videoPlayerView.layer.masksToBounds = true
        videoPlayerView.isUserInteractionEnabled = true
    }
    
    // When device rotates, we modify the videoPlayerView acoordingly
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videoPlayerView.removeFromSuperview()
//        addVideoPlayerView(with: self.view.frame.height)
    }
}

/**
 Conform to UIViewControllerTransitioningDelegate to performs custom transisioning animation
 */
extension NewPostVC: UIViewControllerTransitioningDelegate {
    
    // Custom presentation animation
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.shrinkedPoint = galleryButton.center
        transition.transitionMode = .present
        return transition
    }
    
    // Custom dismission animation
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        transition.shrinkedPoint = galleryButton.center
        transition.transitionMode = .dismiss
        return transition
    }
}

extension NewPostVC: PhotoEditorDelegate {
    
    func doneEditing(image: UIImage) {
        //        imageView.image = image
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        HUD.flash((.label("Image saved to Camera Roll")), delay: 0.5)
//        print("editing done")
        
        
//        let image = self.containerView.getSnapshotImage(size: bounds.size)
        let photo = UIImagePNGRepresentation(image)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        uploadPost(fileData: photo!, type: "Image", width: Double(image.size.width), height: Double(image.size.height))
    }
    
    func canceledEditing() {
        print("Canceled")
    }
}

