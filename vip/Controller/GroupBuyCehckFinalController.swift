//
//  GroupBuyCehckFinalController.swift
//  vip
//
//  Created by Ines on 2020/4/7.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class GroupBuyCehckFinalController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var payfeeLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let ref =  Database.database().reference().child("GroupBuy")
    var index = Int()
    var productId = String()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    var payFee = ""
    var orderAutoId = ""
    var groupBuyStyle = String()
    var groupBuyPeople = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        userInfo()  
        collectionViewDeclare()
        setGroupBuyStatus(productId: productId, index: index, groupBuyPeople: groupBuyPeople)
        
        if groupBuyStyle == "Open"{
            successLabel.text = "已開團成功"
            
        }
        if groupBuyStyle == "Join"{
            successLabel.text = "已加入成功"
            
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
        
        let deliverWays = value["deliverWays"] as? String
        let paymentWays = value["paymentWays"] as? String       
        orderId.text = orderAutoId
        payfeeLabel.text = "付款總金額    " + (payFee) + "元"
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        
    }
    func collectionViewDeclare(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CehckFinalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CehckFinalCollectionViewCell")
    }
    
    
    func setGroupBuyStatus(productId:String,index:Int,groupBuyPeople:Int){
        let refs = ref.child(productId).child("OpenGroupId")
        refs.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                refs.child(snapshots[self.index].key).child("JoinBy")
                    .queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in
                        
                        if let snapshotss = snapshot.children.allObjects as? [DataSnapshot]{
                            print("這個商品目前參加人數：",snapshotss.count)
                            let currentCount = snapshotss.count
                            print("groupBuyPeople人數：",self.groupBuyPeople)
                            if (currentCount >= self.groupBuyPeople){
                                refs.child(snapshots[self.index].key).child("Status").setValue("Ready")
                            }
                        }
                        
                    })
            }
            
        })
        
    }
    
    
    
    
    @IBAction func backToMainPage(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let newFrontViewController = UINavigationController.init(rootViewController: vc)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }
    
    
    
    
}

extension GroupBuyCehckFinalController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CehckFinalCollectionViewCell", for: indexPath) as! CehckFinalCollectionViewCell
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

extension GroupBuyCehckFinalController: UICollectionViewDelegateFlowLayout{
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
