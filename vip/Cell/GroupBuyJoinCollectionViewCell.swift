//
//  GroupBuyJoinCollectionViewCell.swift
//  vip
//
//  Created by Ines on 2020/4/2.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class GroupBuyJoinCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var groupBuyId: UILabel!
    @IBOutlet weak var joinButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 2
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 25

    }

    
    
    func setProductLabel(productId:String){
//        Database.database().reference().child("GroupBuy").child(productId).child("openedBy")
//            .queryOrderedByKey()
//            .observeSingleEvent(of: .value, with: { snapshot in 
//                if let datas = snapshot.children.allObjects as? [DataSnapshot]{
//                   print("datas",datas)
////                self.userName.text = users
//                }    
//            })
        self.groupBuyId.text = productId
                
    
    }
    
}
