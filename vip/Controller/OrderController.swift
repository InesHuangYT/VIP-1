//
//  OrderController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class OrderController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        countStatus()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func transitionToProcessingOrder(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProcessingOrderControllerId") as! ProcessingOrderController
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    @IBAction func transitionToHistoryOrder(_ sender: Any) {
    }
    
    
    
    @IBAction func transitionToMyGroupBuyScene(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyGroupBuyControllerId") as! MyGroupBuyController
        let userGroupBuyRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
        
        userGroupBuyRef.child("Status").child("Ready/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                print("datas.count",datas.count)
                vc.countReady = datas.count
                
                userGroupBuyRef.child("Status").child("Waiting/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                        vc.countWaiting = datas.count
                        
                        userGroupBuyRef.child("Status").child("History/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                                vc.countHistory = datas.count
                                self.navigationController?.pushViewController(vc,animated: true)
                            }
                            
                        })
                        
                        
                        
                        
                    }
                    
                })
                
                
            }
        })
        
        
        
    }
    
    
    func countStatus(){
        let userGroupBuyOrderRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        let userGroupBuyRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
        let productRef = Database.database().reference().child("GroupBuy")
        let orderRef = Database.database().reference().child("GroupBuyOrder")
        
        
        userGroupBuyOrderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in datas{
                    print("snap",snap.key) // orderId
                    
                    //                  find productId
                    userGroupBuyOrderRef.child(snap.key).observeSingleEvent(of: .value, with: { snapshot in 
                        let value = snapshot.value as? NSDictionary
                        let productId = value?["ProductId"] as? String ?? ""
                        print("productId",productId)
                        
                        //                      find openGroupId
                        orderRef.child(snap.key).observeSingleEvent(of: .value, with: { snapshot in 
                            let value = snapshot.value as? NSDictionary
                            let openGroupId = value?["OpenGroupId"] as? String ?? ""
                            print("openGroupId",openGroupId)
                            
                            productRef.child(productId).child("OpenGroupId").child(openGroupId).observeSingleEvent(of: .value, with: { snapshot in 
                                let value = snapshot.value as? NSDictionary
                                let status = value?["Status"] as? String ?? ""
                                print("status",status)
                                if status == "Ready" {
                                    userGroupBuyRef.child("Status").child("Ready").child("OrderId").child(snap.key).setValue(snap.key)
                                }
                                
                                if status == "Waiting" {
                                    userGroupBuyRef.child("Status").child("Waiting").child("OrderId").child(snap.key).setValue(snap.key)
                                    
                                }
                                if status == "Delivered" {
                                    userGroupBuyRef.child("Status").child("History").child("OrderId").child(snap.key).setValue(snap.key)
                                    let readyRef = userGroupBuyRef.child("Status").child("Ready").child("OrderId").child(snap.key)
                                    
                                    readyRef.removeValue()
                                }
                            })
                            
                            
                            
                        })
                        
                        
                    })
                    
                    
                    
                }
                
            }
            
            
            
            
            
        })
    }
    
    
    
}
