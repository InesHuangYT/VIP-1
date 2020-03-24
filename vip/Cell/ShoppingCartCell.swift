//
//  TableViewCell.swift
//  vip
//
//  Created by rourou on 03/03/2020.
//  Copyright © 2020 Ines. All rights reserved.
//

import Foundation
import UIKit

class ShoppingCartCell: UITableViewCell{
    
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var Price: UILabel!
    
    
    @IBAction func InfoButton(_ sender: UIButton) {
    }
    
    
    @IBAction func LikeButton(_ sender: UIButton) {
    }
    
    @IBAction func checkBoxTapped(_ sender: UIButton){
        if sender.isSelected{
            print("Selected!")
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
    }
}
