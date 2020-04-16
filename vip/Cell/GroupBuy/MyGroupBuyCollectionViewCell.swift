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
        let orderRef =  Database.database().reference().child("Order")
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
                                    self.price.text = price 
                                    self.setStatus(openGroupId: openGroupId, status: status, productId: productId)
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
        
        if status == "Ready" { // 已成團 開團者要通知商家 商家已出貨 的分類
            self.status.text = "等開團者通知商家出貨"
                 
            
            
        }
        else if status == "Waiting" { //未成團 顯示剩餘幾人即開團
            
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
            
            
            
            
            
        else {
            
            self.status.text = "已到貨"     
        }
        
        
        
        
    }
    
    
    
}

