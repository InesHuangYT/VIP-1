//
//  ProcessingOrderCell.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class ProcessingOrderCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var payment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellColorSet()
    }
    
    func cellColorSet(){
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 5
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 45   
        image.layer.cornerRadius = 45
        image.layer.borderWidth = 1
        image.layer.borderColor = myColor.cgColor
        image.image = UIImage(named: "logo")
        
    }
    
    func setLabel(orderId:String){
        let productOrderRef = Database.database().reference().child("ProductOrder").child(orderId)
        let productRef = Database.database().reference().child("Product")
        productOrderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let orderProgress = value?["OrderStatus"] as? String ?? ""
            let payment = value?["Payment"] as? String ?? ""
            if orderProgress == "Processing" {
                self.progress.text = "此訂單處理中"
            } 
            if orderProgress == "Shipping" {
                self.progress.text = "此訂單已出貨"
            } 
            if orderProgress == "Delivered" {
                self.progress.text = "此訂單已到貨"
            } 
//            if orderProgress == "Picked" {
//                self.progress.text = "已取貨"
//            } 
  
            
            self.payment.text = "付款總金額" + (payment) + "元"
            
            let productId = value?["ProductId"] as? [String]
            print("productId",productId ?? "")
            print("productId 0 ",productId?[0] ?? "")            
            //列出第一個商品id
            productRef.child(productId?[0] ?? "").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let name = value?["ProductName"] 
                let price = value?["Price"] as! String + "元"
                let url = value?["imageURL"]
                if let imageUrl = URL(string: url as! String){
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
                self.name.text = name as? String
                self.price.text = price 
                
                
            })
            
            
            
            
            
        })
    }
}
