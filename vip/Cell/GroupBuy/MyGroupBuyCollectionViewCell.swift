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
        
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        
        userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print(snapshots[index].key)    
                print("count ",snapshots.count)    
                
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
                
                
                
                
                
            }
            
            
        })
    }
    
    
}
