//
//  GroupBuyInformationController.swift
//  vip
//
//  Created by Ines on 2020/3/31.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class GroupBuyInformationController: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var productEvaluation: UILabel!
    @IBOutlet weak var sellerEvaluation: UILabel!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var groupBuyImage: UIImageView!
    
    var index  = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("index ",index)
        btnAction()
        setLabel(index:index)
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
               groupBuyImage.layer.cornerRadius = 45
               groupBuyImage.layer.borderWidth = 1
               groupBuyImage.layer.borderColor = myColor.cgColor
    }
    
    
    func btnAction(){
              btnMenu.target = self.revealViewController()
              btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
          }
    
    
    func setLabel(index:Int){
        Database.database().reference().child("GroupBuy")
            .queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                snapshot in
                if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                    let name = datas.compactMap({
                        ($0.value as! [String: Any])["ProductName"]
                    }) 
                    let price = datas.compactMap({
                        ($0.value as! [String: Any])["Price"]
                    })
                    let productDescription = datas.compactMap({
                        ($0.value as! [String: Any])["Description"]
                    })
                    let productEvaluation = datas.compactMap({
                        ($0.value as![String: Any])["ProductEvaluation"]
                    })
                    let sellerEvaluation = datas.compactMap({
                        ($0.value as! [String: Any])["SellerEvaluation"]
                    })
                    let image = datas.compactMap({
                        ($0.value as! [String: Any])["imageURL"]
                    })
                    
                    
                    self.name.text =  name[index] as? String
                    self.price.text = (price[index] as! String) + "元"
                    self.productDescription.text = "產品描述 " + (productDescription[index] as! String)
                    self.productEvaluation.text = "產品評價 " + (productEvaluation[index] as! String)
                    self.sellerEvaluation.text = "商家評價 " + (sellerEvaluation[index] as! String)
                    let imageUrl = image[index]
                    if let url = URL(string: imageUrl as! String){
                        URLSession.shared.dataTask(with: url){
                            (data,response,error) in 
                            if error != nil {
                                print("Download Image Task Fail: \(error!.localizedDescription)")
                            }
                            else if let imageData = data {
                                DispatchQueue.main.async {
                                    self.groupBuyImage.image = UIImage(data:imageData)
                                }
                            }
                        }.resume()
                    }
                    
                    
                    
                }
            }
                
                
                
        )
    }
    
}
