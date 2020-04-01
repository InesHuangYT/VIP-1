//
//  GroupBuyCollectionCollectionViewCell.swift
//  vip
//
//  Created by Ines on 2020/3/31.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage



class GroupBuyCollectionViewCell: UICollectionViewCell {
    var ref: DatabaseReference!

    @IBOutlet weak var groupBuyImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var groupPeople: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        layer.borderWidth = 5
        layer.borderColor = myColor.cgColor
        layer.cornerRadius = 45   
        groupBuyImage.layer.cornerRadius = 45
        groupBuyImage.layer.borderWidth = 1
        groupBuyImage.layer.borderColor = myColor.cgColor
        groupBuyImage.image = UIImage(named: "logo")
    }

    
    
    
    func setProductLabel(index:Int){
        Database.database().reference().child("GroupBuy")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in 
                
                if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    let nameResults = datas.compactMap({
                        ($0.value as! [String: Any])["ProductName"]
                    })
                    
                    let priceResults = datas.compactMap({
                        ($0.value as! [String: Any])["Price"]
                    })
                    
                    let peopleResults = datas.compactMap({
                        ($0.value as! [String: Any])["GroupBuyPeople"]
                    }) 
                    
                    let imageResults = datas.compactMap({
                        ($0.value as! [String: Any])["imageURL"]
                    })
                    self.productName.text = nameResults[index] as? String
                    self.productPrice.text = (priceResults[index] as! String) + "元" 
                    self.groupPeople.text = (peopleResults[index] as! String) + "人成團"
                    let productImageUrl = imageResults[index] 
                    self.groupBuyImage.image = UIImage(named: "logo")
                    if let imageUrl = URL(string: productImageUrl as! String){
                        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                            if error != nil {
                                print("Download Image Task Fail: \(error!.localizedDescription)")
                            }
                            else if let imageData = data {
                                DispatchQueue.main.async { 
                                    self.groupBuyImage.image = UIImage(data: imageData)
                                }
                            }
                            
                        }.resume()
                        
                    }
                    
                }
                
                
            })
    }
}
