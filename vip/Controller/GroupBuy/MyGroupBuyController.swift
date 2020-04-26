//
//  MyGroupBuyController.swift
//  vip
//
//  Created by Ines on 2020/4/9.
//  Copyright © 2020 Ines. All rights reserved.
// 放置多个UICollectionView，但是模擬中仅執行一个UICollectionView
// https://t.codebug.vip/questions-1371838.htm

import UIKit
import Firebase

class MyGroupBuyController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    @IBOutlet weak var finshCollectionView: UICollectionView!
    @IBOutlet weak var waitCollectionView: UICollectionView!
    @IBOutlet weak var historyCollectionView: UICollectionView!
    
    @IBOutlet weak var zeroFinishOrder: UILabel!
    @IBOutlet weak var zeroWaitOrder: UILabel!
    @IBOutlet weak var zeroHistoryOrder: UILabel!
    
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    var countReady = Int()
    var countWaiting = Int()
    var countHistory = Int()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        checkFinishCount()
        checkWaitCount()
        checkHistoryCount()
        print("countWaiting",countWaiting)
        print("countReady",countReady)
        print("countHistory",countHistory)
        
        
        
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
    
    func collectionViewDeclare(){
        self.finshCollectionView.reloadData()
        finshCollectionView.delegate = self
        finshCollectionView.dataSource = self
        finshCollectionView.register(UINib(nibName: "MyGroupBuyCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "MyGroupBuyCollectionViewCell")
        
        
        waitCollectionView.delegate = self
        waitCollectionView.dataSource = self
        waitCollectionView.register(UINib(nibName: "MyGroupBuyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyGroupBuyCollectionViewCell")
        
        
        historyCollectionView.delegate = self
        historyCollectionView.dataSource = self
        historyCollectionView.register(UINib(nibName: "MyGroupBuyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyGroupBuyCollectionViewCell")
        
        
    }
    func checkFinishCount(){
        if countReady == 0 {
            zeroFinishOrder.text = "目前無已成團訂單"
        }else{
            zeroFinishOrder.text = "目前有"+String(countReady)+"筆訂單"
        }
    }
    
    func checkWaitCount(){
        if countWaiting == 0 {
            zeroWaitOrder.text = "目前無訂單"
        }else{
            zeroWaitOrder.text = "目前有"+String(countWaiting)+"筆訂單"
        }
    }
    
    func checkHistoryCount(){
        if countHistory == 0 {
            zeroHistoryOrder.text = "目前無歷史訂單"
        }else{
            zeroHistoryOrder.text = "目前有"+String(countHistory)+"筆訂單"
        }
    }
    
    func getProductId(index:Int,status:String,vc:MyGroupBuyOrderController){
     
        let userGroupBuyOrderRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        let userGroupBuyStatusRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("Status").child(status).child("OrderId")
        
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        let orderRef = Database.database().reference().child("GroupBuyOrder")
        
        
        userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                vc.status = status
                let orderId = snapshots[index].key
                vc.orderAutoId = orderId
                orderRef.child(orderId).queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        let orderValue = snapshot.value as? NSDictionary
                        let openGroupId = orderValue?["OpenGroupId"] as? String ?? ""
                        
                        let payfee = orderValue?["Payment"] as? String ?? ""
                        vc.payFee = payfee
                        vc.openGroupId = openGroupId
                        print("payFee",payfee)
                        
                        
                        userGroupBuyOrderRef.child(snapshots[index].key).queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in 
                                let userGroupBuyValue = snapshot.value as? NSDictionary
                                let productId = userGroupBuyValue?["ProductId"] as? String ?? ""
                                vc.productId = productId
                                groupBuyRef.child(productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                                    let groupBuyPeople = snapshot.value as? NSDictionary
                                    let people = groupBuyPeople?["GroupBuyPeople"] as! String
                                    print("groupBuyPeople",Int(people) ?? 0)
                                    self.navigationController?.pushViewController(vc,animated: true)
                                    
                                    
                                })
                                
                            })   
                        
                        
                    }) 
            }
            
            
            
        })
        
        
    }
    
    
    
    func getHistoryProductId(index:Int,status:String,vc:MyGroupBuyHistoryOrderController){
     
        let userGroupBuyOrderRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        let userGroupBuyStatusRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("Status").child(status).child("OrderId")
        
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        let orderRef = Database.database().reference().child("GroupBuyOrder")
        
        
        userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                vc.status = status
                let orderId = snapshots[index].key
                vc.orderAutoId = orderId
                orderRef.child(orderId).queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        let orderValue = snapshot.value as? NSDictionary
                        let openGroupId = orderValue?["OpenGroupId"] as? String ?? ""
                        
                        let payfee = orderValue?["Payment"] as? String ?? ""
                        vc.payFee = payfee
                        vc.openGroupId = openGroupId
                        print("payFee",payfee)
                        
                        
                        userGroupBuyOrderRef.child(snapshots[index].key).queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in 
                                let userGroupBuyValue = snapshot.value as? NSDictionary
                                let productId = userGroupBuyValue?["ProductId"] as? String ?? ""
                                vc.productId = productId
                                groupBuyRef.child(productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                                    let groupBuyPeople = snapshot.value as? NSDictionary
                                    let people = groupBuyPeople?["GroupBuyPeople"] as! String
                                    print("groupBuyPeople",Int(people) ?? 0)
                                    self.navigationController?.pushViewController(vc,animated: true)
                                    
                                    
                                })
                                
                            })   
                        
                        
                    }) 
            }
            
            
            
        })
        
        
    }
    
    
    
    
}

extension MyGroupBuyController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        if collectionView.isEqual(finshCollectionView) {
            return countReady
        }
        else if collectionView.isEqual(waitCollectionView) {
            return countWaiting
        }
        else {
            return countHistory
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        if collectionView.isEqual(finshCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupBuyCollectionViewCell", for: indexPath) as! MyGroupBuyCollectionViewCell
            print("finishCollectionView") 
            cell.setReadyLabel(index:indexPath.row,status:"Ready")
            cell.index = indexPath.row
            cell.currentStatus = "Ready"
            cell.delegate = self
            return cell
            
        } 
        else if collectionView.isEqual(waitCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupBuyCollectionViewCell", for: indexPath) as! MyGroupBuyCollectionViewCell
            print("waitCollectionView")
            cell.setReadyLabel(index:indexPath.row,status:"Waiting")
            cell.delegate = self
            return cell
            
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupBuyCollectionViewCell", for: indexPath) as! MyGroupBuyCollectionViewCell
            print("historyCollectionView")
            cell.setReadyLabel(index:indexPath.row,status:"History")
            cell.delegate = self
            return cell
            
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name:"GroupBuy",bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyGroupBuyOrderControllerId") as! MyGroupBuyOrderController  
        let historyVc = storyboard.instantiateViewController(withIdentifier: "MyGroupBuyHistoryOrderControllerId") as! MyGroupBuyHistoryOrderController  
        
        
        if collectionView.isEqual(finshCollectionView){
            vc.status = "Ready"
            vc.index = indexPath.row
            getProductId(index:indexPath.row , status: "Ready", vc: vc)
        }
            
        else if collectionView.isEqual(waitCollectionView) {
            vc.status = "Waiting"
            vc.index = indexPath.row
            getProductId(index:indexPath.row , status: "Waiting", vc: vc)
        }
            
        else if collectionView.isEqual(historyCollectionView){
            vc.status = "History"
            vc.index = indexPath.row
            getHistoryProductId(index:indexPath.row , status: "History", vc: historyVc)
            
        }
    }
}

extension MyGroupBuyController: UICollectionViewDelegateFlowLayout{
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
