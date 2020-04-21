//
//  ProcessingOrderCell.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class ProcessingOrderCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var progress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
