//
//  TaskTVCell.swift
//  NET-AD
//
//  Created by Mamdouh El Nakeeb on 8/31/18.
//  Copyright © 2018 Mamdouh El Nakeeb. All rights reserved.
//

import UIKit

class TaskTVCell: UITableViewCell {

    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var markDoneBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        markDoneBtn.imageView?.contentMode = .scaleAspectFit
    }
}
