//
//  ShoppingCartCollectionViewCell.swift
//  vip
//
//  Created by Ines on 2020/4/21.
//  Copyright © 2020 Ines. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ShoppingCartCollectionViewCell: UICollectionViewCell {
    
    var delegate: UIViewController?
    
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var lookInformation: UILabel!
    var ref: DatabaseReference!
    var index = Int()
    let user = Auth.auth().currentUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColorSet()
        
    }
    
    //    override func setSelected(_ selected: Bool, animated: Bool) {
    //        super.setSelected(selected, animated: animated)
    //        
    //        // Configure the view for the selected state
    //    }
    
    func cellColorSet(){
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 5
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 45
        ProductImage.image = UIImage(named: "logo")
        ProductImage.layer.cornerRadius = 20
        ProductImage.layer.borderWidth = 1
        ProductImage.layer.borderColor = myColor.cgColor
        
    }
    
    func loadData(index:Int){
        ref = Database.database().reference()
        
        self.ref.child("ShoppingCart").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            
            if let data = snapshot.children.allObjects as? [DataSnapshot] {
                print(data)
                let retriName = data.compactMap({($0.value as! [String:Any])["ProductName"]})
                print("retriName:",retriName)
                let retriprice = data.compactMap({($0.value as![String:Any])["Price"]})
                let imageURL = data.compactMap({
                    ($0.value as! [String: Any])["imageURL"]
                })
                self.ProductName.text = retriName[index] as? String
                self.Price.text = (retriprice[index] as? String ?? "") + "元"
                
                let productImageUrl = imageURL[index]
                self.ProductImage.image = UIImage(named: "logo")
                if let imageUrl = URL(string: productImageUrl as! String){
                    URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        }
                        else if let imageData = data {
                            DispatchQueue.main.async {
                                self.ProductImage.image = UIImage(data: imageData)
                            }
                        }
                        
                    }.resume()
                    
                }
                
            }
            
        })
        
    }
    
    func loadData(productId:String,hiddenSelectButton:Bool){
        if hiddenSelectButton == true {
            selectButton.isHidden = true
            lookInformation.isHidden = true
        }
        Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "").child(productId)
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? [String:Any]
                self.ProductName.text = value?["ProductName"] as? String ?? ""
                self.Price.text = (value?["Price"] as? String ?? "") + "元"
                let productImageUrl = value?["imageURL"] 
                self.ProductImage.image = UIImage(named: "logo")
                if let imageUrl = URL(string: productImageUrl as! String){
                    URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        }
                        else if let imageData = data {
                            DispatchQueue.main.async { 
                                self.ProductImage.image = UIImage(data: imageData)
                            }
                        }
                        
                    }.resume()
                    
                }
                
            })
        
    }
    
    
    @IBAction func checkBoxTapped(_ sender: UIButton){
        let shoppingCartRef = Database.database().reference().child("ShoppingCart")
        shoppingCartRef.child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
            
            if let data = snapshot.children.allObjects as? [DataSnapshot] {
                if sender.isSelected{
                    sender.isSelected = false
                    print("cancel Selected!")
                    print(self.index)
                    shoppingCartRef.child(self.user.uid).child(data[self.index].key).child("Status").setValue("Canceled")
                    
                }else{
                    sender.isSelected = true
                    shoppingCartRef.child(self.user.uid).child(data[self.index].key).child("Status").setValue("Selected")
                    
                }
                
            }
            
            
            
            
            
        })
        
    }
    
    
    
    @IBAction func LikeButton(_ sender: UIButton) {
        if sender.isSelected{
            print("Like Button Selected!")
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
    }
    
}