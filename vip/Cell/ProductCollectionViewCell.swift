//
//  ProductCollectionViewCell.swift
//  VIP
//
//  Created by Ines on 2020/3/18.
//  Copyright © 2020 Ines. All rights reserved.
// 救命網站 https://stackoverflow.com/questions/27341888/iterate-over-snapshot-children-in-firebase

import UIKit
import Firebase
import FirebaseStorage

class ProductCollectionViewCell: UICollectionViewCell {
    var ref: DatabaseReference!
    @IBOutlet weak var productLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 5
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 45   
        productImage.layer.cornerRadius = 45
        productImage.layer.borderWidth = 1
        productImage.layer.borderColor = myColor.cgColor

    }
    


    
     func setProductLabel(index:Int){
          Database.database().reference().child("Product")
              .queryOrderedByKey()
              .observeSingleEvent(of: .value, with: { snapshot in 

                if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                   
                    let nameResults = datas.compactMap({
                        ($0.value as! [String: Any])["ProductName"]
                    })
                    let priceResults = datas.compactMap({
                        ($0.value as! [String: Any])["Price"]
                    })
                    let imageResults = datas.compactMap({
                        ($0.value as! [String: Any])["imageURL"]
                    })
                    self.productLabel.text = nameResults[index] as? String
                    self.priceLabel.text = (priceResults[index] as! String) + "元" 
                    let productImageUrl = imageResults[index] 
                    self.productImage.image = UIImage(named: "logo")
                    if let imageUrl = URL(string: productImageUrl as! String){
                       URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        }
                        else if let imageData = data {
                            DispatchQueue.main.async { 
                               self.productImage.image = UIImage(data: imageData)
                            }
                        }
                        
                        }.resume()

                    }

                }
           
              
              })
      }
    
   
    
//    失敗品 不要用
    func failed(index:Int){

        Database.database().reference().child("Product")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in 
                let value = snapshot.value as? [String:Any]
                let valueKey = value.map { Array($0.keys) }
                print("valueKey",valueKey ?? 0)
                print("valueKey[0]",valueKey?[0] as Any) 
                var toString : String?
                
                let tryDatabase = Database.database().reference().child("Product").queryOrdered(byChild: "ExpDat")
                
                tryDatabase.observeSingleEvent(of: .value, with: {snapshot in
                    //read multi data
                    //toString = valueKey?[index]
                    let values = snapshot.value as? [String:Any]
                    print("valuesA",values)
                    let valueKeys = values.map { Array($0.keys) }
                    
                    toString = valueKeys?[index]
                    print("toString",toString ?? 0)
                    self.ref = Database.database().reference().child("Product")
                    let reference = self.ref.child(toString!)
                    reference.observe(.value, with: { (snapshot) in
                        let value = snapshot.value as? [String: Any]
                        self.productLabel.text = value?["ProductName"] as? String ?? ""
                        self.priceLabel.text = value?["Price"] as? String ?? ""
                        let productImageUrl = value?["imageURL"] 
                        self.productImage.image = UIImage(named: "logo")
                        
                        if let imageUrl = URL(string: productImageUrl as! String){
                            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                if error != nil {
                                    print("Download Image Task Fail: \(error!.localizedDescription)")
                                }
                                else if let imageData = data {
                                    DispatchQueue.main.async { 
                                        self.productImage.image = UIImage(data: imageData)
                                    }
                                }
                                
                            }.resume()
                            
                        }
                        
                    })
                })

            })
        
        //                print("snapshot",snapshot.children.allObjects)
        //                for i in snapshot.children {
        //                    
        //                }
        //                let children = snapshot.children
        //                while let rest = children.nextObject() as? DataSnapshot, let value = rest.value {
        //                    self.yourArray.append(value as! [String: Any])
    }
    
    
    
}
