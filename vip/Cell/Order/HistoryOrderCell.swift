//
//  HistoryOrderCell.swift
//  vip
//
//  Created by Ines on 2020/4/23.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase


class HistoryOrderCell: UICollectionViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
