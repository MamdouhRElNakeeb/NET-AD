//
//  PostCategoryCVCell.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 7/7/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit
import SDWebImage

class PostCategoryCVCell: UICollectionViewCell {
    
    var bgIV = UIImageViewTopAligned()
    var titleLbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let dim = (frame.width / 2)
        
//        contentView.frame = CGRect(x: 0, y: 0, width: dim, height: dim)
        bgIV.frame = contentView.frame
        
        let blackV = UIView(frame: contentView.frame)
        blackV.backgroundColor = UIColor.black
        blackV.alpha = 0.3
        
        titleLbl.frame = contentView.frame
        titleLbl.textColor = UIColor.white
        titleLbl.textAlignment = .center
        
        
        contentView.addSubview(bgIV)
        contentView.addSubview(blackV)
        contentView.addSubview(titleLbl)
        
        bgIV.layer.cornerRadius = 20
        bgIV.layer.masksToBounds = true
        blackV.layer.cornerRadius = 20
        blackV.layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
