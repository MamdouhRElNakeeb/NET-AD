//
//  SplashVC.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import AVKit

class SplashVC: UIViewController {
    
    
    var player: AVPlayer?
    var count = 3
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        
        loadVideo()
        
        
    }
    
    @objc private func updateUI(){
        
        if count > 0 {
            count -= 1
        }
        else{
            showVC()
        }
        
    }
    
    @objc func showVC(){
        if UserDefaults.standard.bool(forKey: "login"){
            let vc = storyboard?.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            let vc = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func loadVideo() {
        
        //this line is important to prevent background music stop
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch { }
        
        let path = Bundle.main.path(forResource: "splash_vid", ofType:"mp4")
        
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path!))
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer.zPosition = -1
        
        NotificationCenter.default.addObserver(self, selector: #selector(showVC), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        self.view.layer.addSublayer(playerLayer)
        
        player?.seek(to: kCMTimeZero)
        player?.play()
    }

}
