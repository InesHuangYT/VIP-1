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
    var count = Int()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        checkFinishCount()
        checkWaitCount()
        checkHistoryCount()
        print("countWaiting",countWaiting)
        print("countReady",countReady)
        
        
    }
    
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
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
        if count == 0 {
            zeroHistoryOrder.text = "目前無歷史訂單"
        }else{
            zeroHistoryOrder.text = "目前有"+String(count)+"筆訂單"
        }
    }
    
    func getProductId(index:Int,status:String,vc:GroupBuyInformationController){
        
        let userGroupBuyOrderRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        let userGroupBuyStatusRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("Status").child(status).child("OrderId")
        
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        
        userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                userGroupBuyOrderRef.child(snapshots[index].key).queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        let userGroupBuyValue = snapshot.value as? NSDictionary
                        let productId = userGroupBuyValue?["ProductId"] as? String ?? ""
                        vc.productId = productId
                        groupBuyRef.child(productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                            let groupBuyPeople = snapshot.value as? NSDictionary
                            let people = groupBuyPeople?["GroupBuyPeople"] as! String
                            vc.groupBuyPeople = Int(people) ?? 0
                            print("groupBuyPeople",Int(people) ?? 0)
                            
                            
                            Database.database().reference().child("GroupBuy").child(productId).child("OpenGroupId")
                                .queryOrderedByKey()
                                .observeSingleEvent(of: .value, with: { snapshot in 
                                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                        print("GroupBuy key count here : ",snapshots.count)
                                        vc.openByCount = snapshots.count
                                        vc.index = index
                                        self.navigationController?.pushViewController(vc,animated: true)
                                        
                                    }
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
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        if collectionView.isEqual(finshCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupBuyCollectionViewCell", for: indexPath) as! MyGroupBuyCollectionViewCell
            print("finishCollectionView") 
            cell.setReadyLabel(index:indexPath.row,status:"Ready")
            return cell
            
        } 
        else if collectionView.isEqual(waitCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupBuyCollectionViewCell", for: indexPath) as! MyGroupBuyCollectionViewCell
            print("waitCollectionView")
            cell.setReadyLabel(index:indexPath.row,status:"Waiting")
            return cell
            
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyGroupBuyCollectionViewCell", for: indexPath) as! MyGroupBuyCollectionViewCell
            print("hostoryCollectionView")
            cell.setReadyLabel(index:indexPath.row,status:"History")
            return cell
            
        }
        
        
        
        //        return cell
        
        //        cell.setProductLabel(text: self.dataProductName[indexPath.row])
        //        cell.setProductLabel(index: indexPath.row)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name:"GroupBuy",bundle:nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController          
        if collectionView.isEqual(finshCollectionView){
            vc.status = "Ready"
            getProductId(index:indexPath.row , status: "Ready", vc: vc)
        }
            
        else if collectionView.isEqual(waitCollectionView) {
            vc.status = "Waiting"
            getProductId(index:indexPath.row , status: "Waiting", vc: vc)
            
        }
        else{
            vc.status = "History"
            getProductId(index:indexPath.row , status: "History", vc: vc)
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
