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
    
    func userInfo(){
        Database.database().reference().child("users").child(uid ?? "")
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
    
    // 結帳建立資料
    @IBAction func checkButtonWasPressed(_ sender: Any) {
        
        let orderRef = Database.database().reference().child("ProductOrder").childByAutoId()
        let orderId = orderRef.key
        let userProductRef = Database.database().reference().child("UserProduct").child(uid ?? "")
        
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderCheckFinalControllerId") as!  OrderCheckFinalController
        
        
        //    時間戳看開始    
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = String(timeInterval)
        print("timeStamp：\(timeStamp)")
        
        let date = Date(timeIntervalSince1970: timeInterval)
        //格式化
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        print("新增日期時間：\(dformatter.string(from: date))")
        //    時間戳結束
        
        
        orderRef.child("Payment").setValue(payFee)
        orderRef.child("ProductId").setValue(selectProductId)
        orderRef.child("OrderStatus").setValue("Processing")
        orderRef.child("OrderCreateTime").setValue(timeStamp)
        userProductRef.child("OrderId").child(orderId ?? "").child("ProductId").setValue(selectProductId)
        userProductRef.child("Status").child("Processing").child("OrderId").child(orderId ?? "").setValue(orderId)
        
        vc.payFee = payFee
        vc.selectProductId = selectProductId
        vc.orderAutoId = orderId ?? ""
        vc.count = count
        
        let message = UIAlertController(title: "結帳成功", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
        {action in
            print("checkout success")
            self.navigationController?.pushViewController(vc, animated: true)
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
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
        vc.index = indexPath.row
        vc.fromShoppingCart = true
        vc.fromCheckOut = true
        vc.selectProductId = self.selectProductId
        
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

