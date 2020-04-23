//
//  HistoryOrderCell.swift
//  vip
//
//  Created by Ines on 2020/4/23.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase


class HistoryOrderCell: UICollectionViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var payment: UILabel!
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
            let orderEndTime = value?["OrderEndTime"] as? String ?? ""
            let payment = value?["Payment"] as? String ?? ""
            
            //time
            let timeStamp = Double(orderEndTime) ?? 1000000000
            let timeInterval:TimeInterval = TimeInterval(timeStamp)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            print("新增日期時間：\(dformatter.string(from: date))")
            self.progress.text = "訂單完成時間\n" + dformatter.string(from: date)
            
            
            self.payment.text = "付款總金額" + (payment) + "元"
            let productId = value?["ProductId"] as? [String]
            
            //列出第一個商品id
            productRef.child(productId?[0] ?? "").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let name = value?["ProductName"] 
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
                
                
                
            })
            
            
            
            
            
        })
        
        
        
    }
}
