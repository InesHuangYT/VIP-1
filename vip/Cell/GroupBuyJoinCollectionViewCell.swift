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
    
    
    func setProductLabel(productId:String,index:Int,groupBuyPeople:Int){
        Database.database().reference().child("GroupBuy").child(productId).child("openedBy")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in 
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    print(snapshots[index].key)     
                    Database.database().reference().child("GroupBuy").child(productId).child("openedBy").child(snapshots[index].key)
                        .queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in 
                            
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                self.groupBuyId.text = (String(snapshots.count)) + " 人參加  /  " + (String(groupBuyPeople)) + " 人成團"
                                print("這個開團人數：",snapshots.count)     
                                
                            }
                            
                        })
                            Database.database().reference().child("users").child(snapshots[index].key).child("Profile").child("name")
                                .queryOrderedByKey()
                                .observeSingleEvent(of: .value, with: { snapshot in 
                                    print("name : ",snapshot.value as? String ?? "")
                                    self.userName.text = "開團人 " + (snapshot.value as? String ?? "")
                                })
                            
                        
                    
                }
                
            })
    }
    
    
    @IBAction func joinButtonWasPressed(_ sender: Any) {
        
    }
    
    
}
