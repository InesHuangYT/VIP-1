//
//  ProcessingOrderInformationCell.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

//顯示訂單有幾個商品 和歷史紀錄cell共用
class ProcessingOrderInformationCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    
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
    
    func setLabel(productId:String){
        
        let productRef = Database.database().reference().child("Product").child(productId)
        productRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let name = value?["ProductName"] as? String ?? ""
            let price = value?["Price"] as? String ?? ""     
            let url = value?["imageURL"] as? String ?? ""
            self.name.text = name
            self.price.text = price + "元"
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
        
        })
    }

    
}
