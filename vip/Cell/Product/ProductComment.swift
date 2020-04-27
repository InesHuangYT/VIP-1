//
//  ProductComment.swift
//  vip
//
//  Created by Ines on 2020/4/27.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class ProductComment: UICollectionViewCell {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var play: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 5
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 45   
    }
    
    func setLable(index:Int,productId:String){
        let productRef = Database.database().reference().child("Product").child(productId).child("ProductEvaluation")
        productRef.queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                if let datas = snapshot.children.allObjects as? [DataSnapshot] { 
                    let userId = datas[index].key
                    Database.database().reference().child("users").child(userId)
                        .child("Profile")
                        .queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in
                            guard let value = snapshot.value as? [String:Any]
                                else {
                                    print("Error")
                                    return
                            }
                            let name = value["name"] as? String
                            self.username.text = name
                        })
                    
                    let comment = datas.compactMap({
                        ($0.value as! [String: Any])["comment"]
                    })
                    let grade = datas.compactMap({
                        ($0.value as! [String: Any])["grade"]
                    })
                    self.comment.text = (grade[index] as! String) + "   " + (comment[index] as! String)  
                    
                    
                }
                
            })
        
    }
    
    func setLable(index:Int,groupProductId:String){
           let productRef = Database.database().reference().child("GroupBuy").child(groupProductId).child("ProductEvaluation")
           productRef.queryOrderedByKey()
               .observeSingleEvent(of: .value, with: { snapshot in
                   if let datas = snapshot.children.allObjects as? [DataSnapshot] { 
                       let userId = datas[index].key
                       Database.database().reference().child("users").child(userId)
                           .child("Profile")
                           .queryOrderedByKey()
                           .observeSingleEvent(of: .value, with: { snapshot in
                               guard let value = snapshot.value as? [String:Any]
                                   else {
                                       print("Error")
                                       return
                               }
                               let name = value["name"] as? String
                               self.username.text = name
                           })
                       
                       let comment = datas.compactMap({
                           ($0.value as! [String: Any])["comment"]
                       })
                       let grade = datas.compactMap({
                           ($0.value as! [String: Any])["grade"]
                       })
                       self.comment.text = (grade[index] as! String) + "   " + (comment[index] as! String)  
                       
                       
                   }
                   
               })
           
       }
    
    
    
    
    
    
}

