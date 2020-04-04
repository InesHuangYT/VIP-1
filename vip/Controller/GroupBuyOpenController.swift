//
//  GroupBuyOpenController.swift
//  vip
//
//  Created by Ines on 2020/4/2.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class GroupBuyOpenController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var openButton: UIButton!
    var index  = Int()
    var productId = String()
    var uid = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    @IBAction func openButtonWasPressed(_ sender: Any) {
        
        let ref =  Database.database().reference().child("GroupBuy").child(productId).child("openedBy").child(self.uid ?? "")
       
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                print("empty:",snapshots.isEmpty)
                if snapshots.isEmpty {
                    
                    let groupBuyRef = Database.database().reference(withPath: "GroupBuy/\(self.productId)/openedBy/\(self.uid ?? "")").childByAutoId().child("JoinUser/users/\(self.uid ?? "")")
                    
                    groupBuyRef.setValue(String(self.uid ?? ""))
                    print(String(self.uid ?? "") + " 開團 ")
                    
                    //  開團規則：一位使用者只能在一個商品內開一次團
                    ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                            snapshot in
                            
                            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                                
                                for snap in datas{
                                    let key = snap.key
                                    print(key)
                                    Database.database().reference(withPath: "users/\(self.uid ?? "wrong message : no currentUser")/GroupBuy/\(self.productId)/OpenGroupId/\(key)").setValue(key)
                                }
                            }
                            
                        })
                }else{
                    print("group already exist, can't open the group")
                    
                }
                
            }
            
        })
    }
    
    
}
