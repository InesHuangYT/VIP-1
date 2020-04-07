//
//  GroupBuyCheckOutCollectionViewCell.swift
//  vip
//
//  Created by Ines on 2020/4/6.
//  Copyright © 2020 Ines. All rights reserved.
// Read and Write Data on iOS  https://firebase.google.com/docs/database/ios/read-and-write

import UIKit
import Firebase

class GroupBuyCheckOutCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
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
    
    func setProductLabel(productId:String){
        let ref =  Database.database().reference().child("GroupBuy").child(productId)
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let name = value?["ProductName"] as? String ?? ""
            let price = value?["Price"] as? String ?? ""
            let url = value?["imageURL"] as? String ?? ""
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
            self.name.text = name
            self.price.text = price + "元" 
            
        })
        
    }
    
    
}
