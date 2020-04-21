//
//  MyGroupBuyOrderController.swift
//  vip
//
//  Created by Ines on 2020/4/19.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
class MyGroupBuyOrderController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var orderID: UILabel!
    @IBOutlet weak var payFeeLabel: UILabel!
    @IBOutlet weak var payWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var productId = String()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    var payFee = String()
    var orderAutoId = String()
    var status = String()
    var index = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("come")
        btnAction()
        userInfo()
        collectionViewDeclare()
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func userInfo(){
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
            .child("Profile")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String:Any]
                    else {
                        print("Error")
                        return
                }
                self.setLabel(value: value)
            })
    }
    
    func setLabel(value:[String:Any]){
        
        let deliverWays = value["deliverWays"] as? String
        let paymentWays = value["paymentWays"] as? String
        orderID.text = orderAutoId
        payFeeLabel.text = "付款總金額    " + (payFee) + "元"
        payWaysLabel.text = "付款方式    " + (paymentWays!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        
    }
    
    func collectionViewDeclare(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CehckFinalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CehckFinalCollectionViewCell")
    }
    
    
  
    
    
    
    
    
    
    
}

extension MyGroupBuyOrderController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CehckFinalCollectionViewCell", for: indexPath) as! CehckFinalCollectionViewCell
        print("self.productId",self.productId)
        cell.setProductLabel(productId: productId, fromShoppingCart: false)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as! GroupBuyInformationController
        vc.productId = productId
        vc.index = index
        vc.status = status
        vc.from = "MyGroupBuy"
        self.navigationController?.pushViewController(vc,animated: true)
    }
}

extension MyGroupBuyOrderController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.5)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
    }
}




