//
//  ProcessingOrderInformationCell.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

//顯示訂單有幾個商品
class ProcessingOrderInformationCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
