//
//  OrderComfirmController.swift
//  vip
//
//  Created by Chun on 2020/4/5.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase 

class OrderComfirmController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var payFeeLabel: UILabel!
    @IBOutlet weak var payWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var backbtn: UIButton!
    @IBOutlet weak var checkoutbtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectProductId = [String]()
    var count = Int()
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    var payFee = String()
    var uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        userInfo()
        
        
        print("payFee",payFee)
        
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
        payFeeLabel.text = "付款總金額    " + (payFee) + "元"
        payWaysLabel.text = "付款方式    " + (paymentWays!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        
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
    
    
    @IBAction func checkButtonWasPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderCheckFinalControllerId") as!  OrderCheckFinalController
        
        
        
    }
    
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
}

extension OrderComfirmController :UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderComfirmCollectionViewCell", for: indexPath) as! OrderComfirmCollectionViewCell
        print("selectProductId[indexPath.row]",selectProductId[indexPath.row])
        cell.setProductLabel(productId: selectProductId[indexPath.row],fromShoppingCart:true)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
//        vc.ID = productId
        self.navigationController?.pushViewController(vc,animated: true)
    }
}

extension OrderComfirmController: UICollectionViewDelegateFlowLayout{
    func collectionView(_collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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

