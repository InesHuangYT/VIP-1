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
                                        
                                        if datass[0].key == self.uid {
                                            
                                            print("uid already inside ", datass[0].key )
                                            self.setUpMessageNo()
                                        }
                                            
                                        else{
                                            ref.child(snapshots[self.index].key).child(datas[0].key).child("JoinUser/users").child(self.uid ?? "").setValue(self.uid)
                                            
                                            print("Join sucessfully !")
                                            Database.database().reference(withPath: "users/\(self.uid ?? "wrong message : NoCurrentUser")/GroupBuy/\(self.productId)/JoinGroupId/\(datas[0].key)").setValue(datas[0].key)
                                            self.setUpMessageOk()
                                        }
                                        
                                    }
                                })
                            
                            
                        }
                        
                        
                    })
            }
            
            
        })
    }
    
    
    func setUpMessageOk(){
        let message = UIAlertController(title: "您已加入成功", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "回主畫面", style: .default, handler: {action in 
            print("here go to Main Scene!")
            self.transition()
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func setUpMessageNo(){
        let message = UIAlertController(title: "您已加入過摟", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "回主畫面", style: .default, handler: {action in 
            print("here go to Main Scene!")
            self.transition()
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func transition(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        present(vc, animated: true, completion: nil)
    }
}
