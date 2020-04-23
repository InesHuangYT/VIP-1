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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColorSet()
        
    }
    
    func cellColorSet(){
          let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
          layer.borderWidth = 2
          layer.borderColor = myColor.cgColor
          layer.cornerRadius = 25
          
      }
    
    func setProductLabel(productId:String,index:Int,groupBuyPeople:Int){
        let ref =  Database.database().reference().child("GroupBuy").child(productId).child("OpenGroupId")
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                print(snapshots[index].key)    
                
                ref.child(snapshots[index].key)
                    .queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        
                        if let snapshotss = snapshot.children.allObjects as? [DataSnapshot]{
                            
                            print("這",snapshotss[0].key) 
                            ref.child(snapshots[index].key).child("JoinBy").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                                
                                
                                if let snapshotsss = snapshot.children.allObjects as? [DataSnapshot]{  
                                    self.groupBuyId.text = (String(snapshotsss.count)) + " 人參加  /  " + (String(groupBuyPeople)) + " 人成團"
                                    print("這個商品目前參加人數：",snapshotsss.count)     
                                    
                                }
                            })
                            
                            
                            ref.child(snapshots[index].key).child("OpenBy").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                                if let snapshotsss = snapshot.children.allObjects as? [DataSnapshot]{  
                                    Database.database().reference().child("users").child(snapshotsss[0].key).child("Profile").child("name")
                                        .queryOrderedByKey()
                                        .observeSingleEvent(of: .value, with: { snapshot in 
                                            print("name : ",snapshot.value as? String ?? "")
                                            self.userName.text = "開團人 " + (snapshot.value as? String ?? "")
                                        })
                                }
                                
                                
                                
                            })
                            
                        }
                        
                    })
                
                
                
                
                
                
            }
            
        })
    }
    
    
    
    
    
}
