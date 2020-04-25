//
//  ProcessingOrderInformationController.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase 

class ProcessingOrderInformationController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var orderCreateTime: UILabel!
    @IBOutlet weak var payTime: UILabel!
    @IBOutlet weak var deliverStartTime: UILabel!
    @IBOutlet weak var deliverArriveTime: UILabel!
    @IBOutlet weak var orderFinishTime: UILabel!
    
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var payWay: UILabel!
    @IBOutlet weak var deliverWay: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //processing order cpntroller 傳值過來
    var orderIndex = Int() //not use
    var orderIds = String()
    var productIdString = [String]()
    var progresss = String()
    var payments = String()
    var orderCreateTimes = String()
    
    //layout
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        setupGridView()
        setLabel()
        
        print("productIdString",productIdString)
    }
    
    
    
    @IBAction func callservice(_ sender: Any) {
        if let callURL:URL = URL(string: "tel:\(886961192398)") {
            
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
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProcessingOrderInformationCell", bundle: nil), forCellWithReuseIdentifier: "ProcessingOrderInformationCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func setLabel(){
        
        orderId.text = orderIds
        payment.text = "付款總金額    " + payments + "元"
        
        //progress
        if progresss == "Processing" {
            progress.text = "此訂單處理中"
        } 
        if progresss == "Shipping" {
            progress.text = "此訂單已出貨"
        } 
        if progresss == "Delivered" {
            progress.text = "此訂單已到貨"
        } 
        
        //time
        let timeStamp = Double(orderCreateTimes) ?? 1000000000
        let timeInterval:TimeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        print("新增日期時間：\(dformatter.string(from: date))")
        orderCreateTime.text = dformatter.string(from: date)
        
        //payway deliverway
        let userProfileRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
            .child("Profile")
        userProfileRef.queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String:Any]
                    else {
                        print("Error")
                        return
                }
                let deliverWays = value["deliverWays"] as? String
                let paymentWays = value["paymentWays"] as? String
                self.payWay.text = "付款方式    " + (paymentWays!)
                self.deliverWay.text = "寄送方式    " + (deliverWays!)
            })
    }
    
    
    
    @IBAction func cancelButton(_ sender: Any) {
        let cancelMessage = UIAlertController(title: "確認要取消訂單？", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: {action in
            let productOrderRef = Database.database().reference().child("ProductOrder")
            let userProductOrderRef = Database.database().reference().child("UserProduct").child(Auth.auth().currentUser?.uid ?? "")
            productOrderRef.child(self.orderIds).removeValue()
            userProductOrderRef.child("OrderId").child(self.orderIds).removeValue()
            userProductOrderRef.child("Status").child("Processing").child("OrderId").child(self.orderIds).removeValue()
            print("remove orderId completed!")
            
            let message = UIAlertController(title: "已取消訂單", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: {action in
                self.transitionToProcessingOrder(myOderRef: userProductOrderRef)
            })
            message.addAction(okAction)
            //       在cell裡面增加button 讓controller跳出alert
            self.present(message, animated: true, completion: nil)
            
        })
        let backAction = UIAlertAction(title: "返回", style: .cancel, handler: {action in
        })
        cancelMessage.addAction(confirmAction)
        cancelMessage.addAction(backAction)        
        //       在cell裡面增加button 讓controller跳出alert
        self.present(cancelMessage, animated: true, completion: nil)
        
        
    }
    
    func transitionToProcessingOrder(myOderRef:DatabaseReference){
        let storyboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProcessingOrderControllerId") as! ProcessingOrderController
        let myOderRef =  Database.database().reference().child("UserProduct").child(Auth.auth().currentUser?.uid ?? "")
        var myOrderId = [String]()
        myOderRef.child("Status").child("Processing/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                vc.myOrderCount = datas.count
                
                for data in datas {
                    myOrderId.append(data.key)
                }
                vc.myOrderId = myOrderId
                self.navigationController?.pushViewController(vc,animated: true) 
            }
        })
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}



extension ProcessingOrderInformationController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        return productIdString.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProcessingOrderInformationCell", for: indexPath) as! ProcessingOrderInformationCell
        print("productIdString[indexPath.row]",productIdString[indexPath.row])
        cell.setLabel(productId:productIdString[indexPath.row])
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
        vc.fromMyOrder = true
        vc.productId = productIdString[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ProcessingOrderInformationController: UICollectionViewDelegateFlowLayout{
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



