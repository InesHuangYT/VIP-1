//
//  MyGroupBuyHistoryOrderController.swift
//  vip
//
//  Created by Ines on 2020/4/27.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class MyGroupBuyHistoryOrderController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var orderID: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var orderCreateTime: UILabel!
    @IBOutlet weak var payTime: UILabel!
    @IBOutlet weak var deliverStartTime: UILabel!
    @IBOutlet weak var deliverArriveTime: UILabel!
    @IBOutlet weak var orderFinishTime: UILabel!
    
    @IBOutlet weak var payFeeLabel: UILabel!
    @IBOutlet weak var payWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    
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
        btnAction()
        userInfo()
        collectionViewDeclare()
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
        
        let groupBuyOrderRef = Database.database().reference().child("GroupBuyOrder")
        progress.text = "已到貨"
        
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
    @IBAction func commentButton(_ sender: Any) {
        let storyboardDeadLine = UIStoryboard(name:"Order",bundle:nil)
        let vc = storyboardDeadLine.instantiateViewController(withIdentifier: "CommentAllController") as! CommentAllController 
        vc.fromGroupBuy = true
        vc.openGroupId = openGroupId
        vc.payFee = payFee
        vc.orderAutoId = orderAutoId
        vc.status = status
        vc.index = index
        checkIfCommentBefore(vc:vc)
    }
    
    
    func checkIfCommentBefore(vc:CommentAllController){
        let orderRef = Database.database().reference().child("GroupBuyOrder").child(orderAutoId)
        orderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let comment = value?["Comment"] as? String
            print("comment",comment ?? "")      
            if comment == "false"{
                vc.productIdString.append(self.productId)
                vc.productIdAll.append(self.productId)
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                vc.productIdAll.append(self.productId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    @IBAction func detailInformation(_ sender: Any) {
        let storyboardDeadLine = UIStoryboard(name:"DeadLine",bundle:nil)
        let vcDeadLine = storyboardDeadLine.instantiateViewController(withIdentifier: "DeadLineController") as! DeadLineController   
        
        vcDeadLine.fromGroupBuy = true
        vcDeadLine.productIdString.append(productId)
        self.navigationController?.pushViewController(vcDeadLine, animated: true)
    }
    
}
extension MyGroupBuyHistoryOrderController : UICollectionViewDataSource{
    
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

extension MyGroupBuyHistoryOrderController : UICollectionViewDelegateFlowLayout{
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
