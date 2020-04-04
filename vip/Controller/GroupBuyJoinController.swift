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
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("GroupBuyOpenController begining!")
        print("index : ",index)
        print("productId : ",productId)
        btnAction()
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    @IBAction func joinButtonWasPressed(_ sender: Any) {
        
        let ref =  Database.database().reference().child("GroupBuy").child(productId).child("openedBy")
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                ref.child(snapshots[self.index].key)
                    .queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        
                        
                        if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                            print("這這",datas[0].key) 
                            
                            
                            ref.child(snapshots[self.index].key).child(datas[0].key).child("JoinUser/users")
                                .queryOrderedByKey()
                                .observeSingleEvent(of: .value, with: { snapshot in
                                    
                                    if let datass = snapshot.children.allObjects as? [DataSnapshot]{
                                        for snap in datass{
                                            let key = snap.key
                                            if key == self.uid {
                                                print("uid already inside ", key)
                                                
                                            }else{
                                                ref.child(snapshots[self.index].key).child(datas[0].key).child("JoinUser/users").child(self.uid ?? "").setValue(self.uid)
                                                
                                                print("Join sucessfully !")
                                                Database.database().reference(withPath: "users/\(self.uid ?? "wrong message : NoCurrentUser")/GroupBuy/\(self.productId)/JoinGroupId/\(datas[0].key)").setValue(datas[0].key)
                                            }
                                        }
                                    }
                                })
                            
                            
                        }
                        
                        
                    })
            }
            
            
        })
    }
    
    
}
