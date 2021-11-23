//
//  EquipmentList.swift
//  BLETptDemo
//
//  Created by dete108 on 2021/11/1.
//  Copyright © 2021 dete108. All rights reserved.
//

import UIKit

class EquipmentList: UITableViewCell {

    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var listLabel1: UILabel!
    @IBOutlet weak var listLabel2: UILabel!
    @IBOutlet weak var listLabel3: UILabel!
    @IBOutlet weak var listLabel4: UILabel!
    @IBOutlet weak var listButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
