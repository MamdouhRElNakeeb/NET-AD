//
//  DraggableImageView.swift
//  Sa7fyApp
//
//  Created by Mamdouh El Nakeeb on 7/3/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit

class DraggableImageView: UIView {

    weak var draggableImageViewDelegate: DraggableImageViewDelegate?
    var removeBtn = UIButton()
    var cropBtn = UIButton()
    var imageView = UIImageView()
    
    var lastLocation = CGPoint(x: 0, y: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        imageView.layer.masksToBounds = true
        
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        removeBtn.frame = CGRect(x: frame.width - 40, y: 10, width: 30, height: 30)
        removeBtn.setTitle("X", for: .normal)
        removeBtn.backgroundColor = UIColor.red
        removeBtn.addTarget(self, action: #selector(removeImageView), for: .touchUpInside)
        removeBtn.isHidden = true
        
        cropBtn.frame = CGRect(x: removeBtn.frame.minX - 40, y: 10, width: 30, height: 30)
        cropBtn.setTitle("C", for: .normal)
        cropBtn.backgroundColor = UIColor.yellow
        cropBtn.setTitleColor(UIColor.black, for: .normal)
        cropBtn.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        cropBtn.isHidden = true
        
        self.addSubview(imageView)
        self.addSubview(removeBtn)
        self.addSubview(cropBtn)
        
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action: #selector(detectPan(_:)))
        self.gestureRecognizers = [panRecognizer]
        
        let longPressRecognizer = UITapGestureRecognizer(target: self, action: #selector(pressed(sender:)))
        self.addGestureRecognizer(longPressRecognizer)
        
        let pinchZoomGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaleImg(_:)))
        self.addGestureRecognizer(pinchZoomGesture)
    }
    
    @objc func pressed(sender: UITapGestureRecognizer) {
        
        if removeBtn.isHidden {
            removeBtn.isHidden = false
            cropBtn.isHidden = false
        }
        else{
            removeBtn.isHidden = true
            cropBtn.isHidden = true
        }
        
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let vc = parentResponder as? UIViewController{
                vc.view.endEditing(true)
            }
        }
        
    }

    
    @objc func removeImageView(){
//        self.draggableImageViewDelegate?.removeImageView(view: self)
        self.removeFromSuperview()
    }
    
    @objc func cropImage(){
        draggableImageViewDelegate?.cropImage(draggableImageView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview)
        self.center = CGPoint(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)
    }
    
    @objc func scaleImg(_ sender: UIPinchGestureRecognizer) {
        sender.view?.transform = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale))!
        sender.scale = 1.0
    }
    
    override func touchesBegan(_ touches: (Set<UITouch>?), with event: UIEvent!) {
        // Promote the touched view
        self.superview?.bringSubview(toFront: self)
        
        // Remember original location
        lastLocation = self.center
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

protocol DraggableImageViewDelegate: class {
    func removeImageView(view: UIView)
    func cropImage(draggableImageView: DraggableImageView)
}
