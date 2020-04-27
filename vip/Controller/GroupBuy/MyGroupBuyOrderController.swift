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
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var orderCreateTime: UILabel!
    @IBOutlet weak var payTime: UILabel!
    @IBOutlet weak var deliverStartTime: UILabel!
    @IBOutlet weak var deliverArriveTime: UILabel!
    @IBOutlet weak var orderFinishTime: UILabel!
    @IBOutlet weak var notificateToSeller: UIButton!
    
    @IBOutlet weak var payFeeLabel: UILabel!
    @IBOutlet weak var payWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    
    var productId = String()
    var openGroupId = String()
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
        print("index",index)
        
        if status == "Ready" {
            cancelButton.isHidden = true //已成團就無法刪除訂單
        }
        
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
        //        progress
        let groupBuyStatusRef = Database.database().reference().child("GroupBuy").child(productId).child("OpenGroupId").child(openGroupId)
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        let groupBuyOrderRef = Database.database().reference().child("GroupBuyOrder")
        
        
        groupBuyStatusRef.queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                let statusValue = snapshot.value as? NSDictionary
                let status = statusValue?["Status"] as? String ?? ""
                
                //已成團
                if status == "Ready" {
                    groupBuyStatusRef.child("OpenBy").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                        if let snapshot1 = snapshot.children.allObjects as? [DataSnapshot]{  
                            print("snapshot1[0]",snapshot1[0].key)
                            if((Auth.auth().currentUser?.uid ?? "") as String == snapshot1[0].key){                                self.progress.text = "已成團"
                                self.notificateToSeller.isHidden = false
                                
                            }
                            else{
                                self.progress.text = "等候開團者通知商家出貨"
                            }
                        }
                    })   
                } 
                
                if status == "Already Notify to Seller" {
                    self.progress.text = "已通知商家出貨"
                } 
                if status == "Seller Shipped" {
                    self.progress.text = "商家已出貨"
                } 
                if status == "Waiting" {
                    
                    groupBuyRef.child(self.productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                        let groupBuyPeople = snapshot.value as? NSDictionary
                        let people = groupBuyPeople?["GroupBuyPeople"] as! String
                        let intPeople = Int(people)
                        print("people",Int(people) ?? 0)
                        
                        groupBuyStatusRef.child("JoinBy").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                            if let snapshot1 = snapshot.children.allObjects as? [DataSnapshot]{  
                                print("這個商品目前參加人數：",snapshot1.count)  
                                let overage = intPeople! - snapshot1.count
                                self.progress.text = "剩餘" + String(overage) + "人即成團"
                            }
                        })  
                    })                    
                } 
            })
        
        //        time
        groupBuyOrderRef.child(self.orderAutoId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let timeValue = snapshot.value as? NSDictionary
            let orderCreateTimes = timeValue?["OrderCreateTime"] as! String
            let timeStamp = Double(orderCreateTimes) ?? 1000000000
            let timeInterval:TimeInterval = TimeInterval(timeStamp)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            print("新增日期時間：\(dformatter.string(from: date))")
            self.orderCreateTime.text = "訂單成立時間    " + dformatter.string(from: date)
            self.payTime.text = "付款時間    " + dformatter.string(from: date)
        })
        
        
        //       
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
    
    @IBAction func notificatToSeller(_ sender: Any) {
        let message = UIAlertController(title: "已幫您通知商家出貨摟", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: {action in 
            let groupBuyRef = Database.database().reference().child("GroupBuy")
            groupBuyRef.child(self.productId).child("OpenGroupId").child(self.openGroupId).child("Status").setValue("Already Notify to Seller")
            self.progress.text = "已通知商家出貨"
            self.notificateToSeller.isHidden = true
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        let cancelMessage = UIAlertController(title: "確認要取消訂單？", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: {action in
            let groupBuyOrderRef = Database.database().reference().child("GroupBuyOrder")
            let groupBuyRef = Database.database().reference().child("GroupBuy")
            let userGroupBuyOrderRef = Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
            
            groupBuyOrderRef.child(self.orderAutoId).queryOrderedByKey()
                .observeSingleEvent(of: .value, with: { snapshot in 
                    let orderValue = snapshot.value as? NSDictionary
                    let openGroupId = orderValue?["OpenGroupId"] as? String ?? ""
                    
                    userGroupBuyOrderRef.child("OrderId").child(self.orderAutoId).queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in 
                            let orderValue = snapshot.value as? NSDictionary
                            let productId = orderValue?["ProductId"] as? String ?? ""
                            
                            groupBuyRef.child(productId).child("OpenGroupId").child(openGroupId).child("OpenBy").queryOrderedByKey()
                                .observeSingleEvent(of: .value, with: { snapshot in 
                                    if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                                        if datas[0].key == Auth.auth().currentUser?.uid ?? "" {
                                            print("im the opener!!!!!")
                                            groupBuyRef.child(productId).child("OpenGroupId").child(openGroupId).removeValue()
                                        }
                                        else{
                                            groupBuyRef.child(productId).child("OpenGroupId").child(openGroupId).child("JoinBy").child(Auth.auth().currentUser?.uid ?? "").removeValue()
                                        }
                                        
                                        
                                        groupBuyOrderRef.child(self.orderAutoId).removeValue()
                                        userGroupBuyOrderRef.child("OrderId").child(self.orderAutoId).removeValue()
                                        userGroupBuyOrderRef.child("Status").child("Waiting").child("OrderId").child(self.orderAutoId).removeValue()
                                        print("remove orderId completed!")
                                        
                                    }
                                    
                                })  
                        })
                })
            
            
            
            let message = UIAlertController(title: "已取消訂單", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler: {action in
                self.transitionToMyGroupBuyController()                
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
    
    func transitionToMyGroupBuyController(){
        let storyboard: UIStoryboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyGroupBuyControllerId") as! MyGroupBuyController
        let userGroupBuyRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
        
        userGroupBuyRef.child("Status").child("Ready/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                print("datas.count",datas.count)
                vc.countReady = datas.count
                
                userGroupBuyRef.child("Status").child("Waiting/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                        vc.countWaiting = datas.count
                        
                        userGroupBuyRef.child("Status").child("History/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                                vc.countHistory = datas.count
                                self.navigationController?.pushViewController(vc,animated: true)
                            }
                            
                        })
                        
                    }
                    
                })
                
                
            }
        }) 
    }
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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




