//
//  DeadLineInformationController.swift
//  vip
//
//  Created by Chun on 2020/4/23.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class DeadLineInformationController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ManuDateLabel: UILabel!
    @IBOutlet weak var ExpDateLabel: UILabel!
    @IBOutlet weak var otherInfoLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    var productId = String()
    var fromGroupBuy = false // from MyGroupBuyController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        productImage.layer.cornerRadius = 45
        productImage.layer.borderWidth = 1
        productImage.layer.borderColor = myColor.cgColor
        productImage.image = UIImage(named:"logo")
        
        setLabel(ProductId: productId,fromGroupBuy:fromGroupBuy)
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    @IBAction func callservice(_ sender: Any) {
        if let callURL:URL = URL(string: "tel:\(+886961192398)") {
            
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(callURL)) {
                let alert = UIAlertController(title: "撥打客服專線", message: "", preferredStyle: .alert)
                let callAction = UIAlertAction(title: "是", style: .default, handler: { (action) in
                    application.openURL(callURL)
                })
                let noAction = UIAlertAction(title: "否", style: .cancel, handler: { (action) in
                    print("Canceled Call")
                })
                
                alert.addAction(callAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func setLabel(ProductId:String,fromGroupBuy:Bool){
        
        var ref = Database.database().reference()
        if fromGroupBuy == false{
            ref = ref.child("Product")
        }
        else{
            ref = ref.child("GroupBuy")
        }
        
        ref.child(ProductId).queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                let name = value?["ProductName"] as? String ?? ""
                let price = value?["Price"] as? String ?? ""
                let manuDate = value?["ManuDate"] as? String ?? ""
                let expDate = value?["ExpDate"] as? String ?? ""
                let method = value?["Method"] as? String ?? ""
                self.nameLabel.text = name
                self.priceLabel.text = price + "元"
                self.ManuDateLabel.text = "製造日期 " + manuDate
                self.ExpDateLabel.text = "有效期限 " + expDate
                self.otherInfoLabel.text = "使用方式 " + method
                let url = value?["imageURL"] as? String ?? ""
                if let imageUrl = URL(string: url){
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
    }
    
    
    
    
}
