//
//  GroupBuyJoinController.swift
//  vip
//
//  Created by Ines on 2020/4/4.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class GroupBuyJoinController: UIViewController {
    
    var index  = Int()
    var productId = String()
    var uid = Auth.auth().currentUser?.uid
    @IBOutlet weak var btnMenu: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("GroupBuyOpenController begining!")
        print("index : ",index)
        print("productId : ",productId)
        btnAction()
        Database.database().reference().child("GroupBuy").child(productId).child("openedBy")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in 
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    Database.database().reference().child("GroupBuy").child(self.productId).child("openedBy").child(snapshots[self.index].key)
                        .queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in 
                            
                            
                            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                                
                                for snap in datas{
                                    let key = snap.key
                                    print(key)
                                    Database.database().reference(withPath: "GroupBuy/\(self.productId)/openedBy/\(snapshots[self.index].key)/\(key)/JoinUser/users/\(self.uid ?? "")").setValue(self.uid)
                                    
                                }
                            }
                            
                            
                        })
                    
                    
                }
                
                
            })
    }
    
    func btnAction(){
           btnMenu.target = self.revealViewController()
           btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
       }
    
    
    
}
