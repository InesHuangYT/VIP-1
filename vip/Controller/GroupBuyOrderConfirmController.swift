//
//  GroupBuyOrderConfirmController.swift
//  vip
//
//  Created by Ines on 2020/4/7.
//  Copyright © 2020 Ines. All rights reserved.
////OrderComfirmCollectionViewCell


import UIKit
import Firebase

class GroupBuyOrderConfirmController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var payfeeLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var checkButton: UIButton!
    var productId = String()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    var payFee = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        userInfo()
        
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
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
        payfeeLabel.text = "付款總金額    " + (payFee) + "元"
        
    }
    
    
    
    func collectionViewDeclare(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "OrderComfirmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "OrderComfirmCollectionViewCell")
    }
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    
    //    加入開團資料庫 成立訂單
    @IBAction func checkButtonWasPressed(_ sender: Any) {
    
    
    }
    
}
extension GroupBuyOrderConfirmController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderComfirmCollectionViewCell", for: indexPath) as! OrderComfirmCollectionViewCell
        
        print("self.productId",self.productId)
        cell.setProductLabel(productId: String(self.productId))
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        vc.productId = productId
        self.navigationController?.pushViewController(vc,animated: true)
    }
}

extension GroupBuyOrderConfirmController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.3)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}
