//
//  MyGroupBuyCollectionViewCell.swift
//  vip
//
//  Created by Ines on 2020/4/9.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class MyGroupBuyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func setProductLabel(index:Int){
        
        let userGroupBuyRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        let productRef = Database.database().reference().child("GroupBuy")
        
        userGroupBuyRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print(snapshots[index].key)    
                print("count ",snapshots.count)    
                
                userGroupBuyRef.child(snapshots[index].key).queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        let userGroupBuyValue = snapshot.value as? NSDictionary
                        let productId = userGroupBuyValue?["ProductId"] as? String ?? ""
                        
                        productRef.child(productId).queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in 
                               
                                let productValue = snapshot.value as? NSDictionary
                                let name = productValue?["ProductName"] as? String ?? ""
                                let price = productValue?["Price"] as? String ?? ""

                                self.name.text = name
                                self.price.text = price 
                                
                                
                            })
                        
                        
                    })
                
                
                
                
                
            }
            
            
        })
    }
    
    
    
}
