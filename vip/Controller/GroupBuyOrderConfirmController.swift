//
//  GroupBuyOrderConfirmController.swift
//  vip
//
//  Created by Ines on 2020/4/7.
//  Copyright © 2020 Ines. All rights reserved.


import UIKit
import Firebase


//var GroupBuyOrderConfirmVC = GroupBuyOrderConfirmController()

class GroupBuyOrderConfirmController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var payfeeLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var checkButton: UIButton!
    
    var productId = String()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    var payFee = ""
    let ref =  Database.database().reference().child("GroupBuy")
    var uid = Auth.auth().currentUser?.uid
    
    
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
        payfeeLabel.text = "付款總金額    " + (payFee) + "元"
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
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
    
    
    
    //    加入開團資料庫 成立訂單
    @IBAction func checkButtonWasPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyCehckFinalControllerId") as!  GroupBuyCehckFinalController
        
        
        ref.child(productId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let reff = self.ref.child(self.productId).child("OpenGroupId").childByAutoId()
            reff.child("OpenBy").child(self.uid ?? "").setValue(self.uid ?? "")
            reff.child("JoinBy").child(self.uid ?? "").setValue(self.uid ?? "")
            
            self.ref.child(self.productId).child("OpenGroupId").queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                snapshot in
                
                if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for snap in datas{
                        let key = snap.key
                        print("keyyyyy",key)
                        Database.database().reference(withPath: "UserGroupBuy/\(self.uid ?? "wrong message : no currentUser")/OpenGroupId/\(reff.key ?? "")/ProductId/\(self.productId)").setValue(self.productId)
                        
//                        self.setUpMessageOk()
                    }
                }
                
            })
            
            let value = snapshot.value as? NSDictionary
            let price = value?["Price"] as? String ?? ""
            let payment = Int(price)
            let allPay = (payment ?? 0) as Int + 60
            vc.payFee = String(allPay) 
            vc.productId = self.productId
            vc.orderAutoId = reff.key ?? ""
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
