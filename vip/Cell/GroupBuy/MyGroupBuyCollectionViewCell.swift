//
//  MyGroupBuyCollectionViewCell.swift
//  vip
//
//  Created by Ines on 2020/4/9.
//  Copyright © 2020 Ines. All rights reserved.
// swift show alert with custom cell https://stackoverflow.com/questions/34219578/swift-show-alert-with-custom-cell

import UIKit
import Firebase

class MyGroupBuyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var notificateToSeller: UIButton!
    var delegate: UIViewController?
    var index = Int()
    var currentStatus = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColorSet()
    }
    
    func cellColorSet(){
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 5
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 45
        image.image = UIImage(named: "logo")
        image.layer.cornerRadius = 20
        image.layer.borderWidth = 1
        image.layer.borderColor = myColor.cgColor
        
    }
    func setReadyLabel(index:Int,status:String){
        let userGroupBuyOrderRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        
        let userGroupBuyStatusRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("Status").child(status).child("OrderId")
        let orderRef =  Database.database().reference().child("GroupBuyOrder")
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        
        userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print("snapshots[index].key",snapshots[index].key)  
                
                print("count ",snapshots.count)    
                //            find openGroupId    
                orderRef.child(snapshots[index].key).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    let orderValue = snapshot.value as? NSDictionary
                    let openGroupId = orderValue?["OpenGroupId"] as? String ?? ""
                    print("openGroupId : ", openGroupId)
                    
                    userGroupBuyOrderRef.child(snapshots[index].key).queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in 
                            let userGroupBuyValue = snapshot.value as? NSDictionary
                            let productId = userGroupBuyValue?["ProductId"] as? String ?? ""
                            
                            groupBuyRef.child(productId).queryOrderedByKey()
                                .observeSingleEvent(of: .value, with: { snapshot in 
                                    
                                    let productValue = snapshot.value as? NSDictionary
                                    let name = productValue?["ProductName"] as? String ?? ""
                                    let price = productValue?["Price"] as? String ?? ""
                                    let url = productValue?["imageURL"] as? String ?? ""
                                    
                                    self.name.text = name
                                    self.price.text = price + "元"
                                    
                                    
                                    groupBuyRef.child(productId).child("OpenGroupId").child(openGroupId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                                        let statusValue = snapshot.value as? NSDictionary
                                        let status = statusValue?["Status"] as? String ?? ""
                                        self.setStatus(openGroupId: openGroupId, status: status, productId: productId)
                                    })
                                    
                                    
                                    if let imageUrl = URL(string: url){
                                        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                            if error != nil {
                                                print("Download Image Task Fail: \(error!.localizedDescription)")
                                            }
                                            else if let imageData = data {
                                                DispatchQueue.main.async { 
                                                    self.image.image = UIImage(data: imageData)
                                                }
                                            }
                                            
                                        }.resume()
                                    }
                                    
                                })
                            
                            
                        })
                    
                    
                })
                
                
            }
            
            
        })
    }
    
    func setStatus(openGroupId:String,status:String,productId:String){
        
        let openGroupIdref =  Database.database().reference().child("GroupBuy").child(productId).child("OpenGroupId").child(openGroupId)
        let groupBuyRef = Database.database().reference().child("GroupBuy")   
        
        //      已成團 尚未通知商家出貨
        if status == "Ready" { 
            
            openGroupIdref.child("OpenBy").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                if let snapshot1 = snapshot.children.allObjects as? [DataSnapshot]{  
                    print("snapshot1[0]",snapshot1[0].key)
                    if((Auth.auth().currentUser?.uid ?? "") as String == snapshot1[0].key){
                        self.notificateToSeller.isHidden = false
                        self.status.text = "開團成功"
                        self.notificateToSeller.setTitle("通知商家出貨", for: .normal)
                        self.notificateToSeller.backgroundColor = UIColor(red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
                    }
                    else{
                        
                        self.status.text = "等待開團者通知商家出貨"
                        
                    }
                }
            })
            
        }   
            //     開團者已通知商家
        else if status == "Already Notify to Seller" {
            
            self.status.text = "開團者已通知商家出貨"
        }
            
        else if status == "Seller Shipped"{
            self.status.text = "商家已出貨"
            
        }
            
            //      未成團 顯示剩餘幾人即開團
        else if status == "Waiting" { 
            
            groupBuyRef.child(productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                let groupBuyPeople = snapshot.value as? NSDictionary
                let people = groupBuyPeople?["GroupBuyPeople"] as! String
                let intPeople = Int(people)
                print("people",Int(people) ?? 0)
                
                openGroupIdref.child("JoinBy").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    if let snapshot1 = snapshot.children.allObjects as? [DataSnapshot]{  
                        print("這個商品目前參加人數：",snapshot1.count)  
                        let overage = intPeople! - snapshot1.count
                        self.status.text = "剩餘" + String(overage) + "人即成團"
                    }
                })
                
            })
        }
            
//            歷史紀錄
        else {
            
            self.status.text = "已到貨"     
        }
        
        
        
        
    }
    
    
    
    @IBAction func notificatoToSellerButtonWasPressed(_ sender: Any) {
        let message = UIAlertController(title: "已幫您通知商家出貨摟", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: {action in 
            
            
            let userGroupBuyStatusRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("Status").child(self.currentStatus).child("OrderId")
            let userGroupBuyOrderIdRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
            let orderRef =  Database.database().reference().child("GroupBuyOrder")
            let groupBuyRef = Database.database().reference().child("GroupBuy")
            
            userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    print("snapshots[index].key",snapshots[self.index].key)  
                    
                    //            find openGroupId    
                    orderRef.child(snapshots[self.index].key).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                        let orderValue = snapshot.value as? NSDictionary
                        let openGroupId = orderValue?["OpenGroupId"] as? String ?? ""
                        print("openGroupId",openGroupId)
                        
                        //            find productId
                        userGroupBuyOrderIdRef.child(snapshots[self.index].key).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                            let productIdValue = snapshot.value as? NSDictionary
                            let productId = productIdValue?["ProductId"] as? String ?? ""
                            groupBuyRef.child(productId).child("OpenGroupId").child(openGroupId).child("Status").setValue("Already Notify to Seller")
                            self.status.text = "已通知商家出貨"
                            self.notificateToSeller.isHidden = true

                            
                        })
                    })
                }
            })
            
        })
        message.addAction(confirmAction)
//       在cell裡面增加button 讓controller跳出alert
        self.delegate?.present(message, animated: true, completion: nil)
    }
    
    
    
}


