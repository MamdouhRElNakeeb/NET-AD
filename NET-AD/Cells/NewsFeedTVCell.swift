//
//  NewsFeedTVCell.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/17/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import SDWebImage

class NewsFeedTVCell: UITableViewCell {

    
//    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var feedImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editorIV: UIImageView!
    @IBOutlet weak var editorTV: UILabel!
    @IBOutlet weak var postIV: UIImageView!
    @IBOutlet var videoPlayBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var playerView: PlayerView!
    
//    var playerView = PlayerView()
    
//    internal var aspectConstraint : NSLayoutConstraint? {
//        didSet {
//            if oldValue != nil {
//                editorIV.removeConstraint(oldValue!)
//            }
//            if aspectConstraint != nil {
//                editorIV.addConstraint(aspectConstraint!)
//            }
//        }
//    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        aspectConstraint = nil
//    }
    
//    func setCustomImage(image : UIImage) {
//        
//        let aspect = image.size.width / image.size.height
//        
//        let constraint = NSLayoutConstraint(item: editorIV, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: editorIV, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
//        constraint.priority = UILayoutPriority(rawValue: 999)
//        
//        aspectConstraint = constraint
//        
//        editorIV.image = image
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.editorIV.layer.cornerRadius = self.editorIV.frame.width / 2
        self.editorIV.layer.masksToBounds = true
        acceptBtn.imageView?.contentMode = .scaleAspectFit
        rejectBtn.imageView?.contentMode = .scaleAspectFit
        saveBtn.imageView?.contentMode = .scaleAspectFit
//        videoPlayBtn.isHidden = true
//        playerView.frame = postIV.frame
        playerView.isHidden = true
//        self.contentView.addSubview(playerView)
//
//        contentView.bringSubview(toFront: playerView)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        self.postIV.isHidden = false
//    }

}
