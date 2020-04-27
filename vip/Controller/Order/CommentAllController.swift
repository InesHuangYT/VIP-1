//
//  CommentAllController.swift
//  vip
//
//  Created by Chun on 2020/4/26.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import UIKit


class CommentAllController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var commentLabel: UILabel!

    //from history
    var orderIndex = Int()
    var progresss = String()
    var payment = String()
    var orderCreateTimes = String()
    var orderEndTime = String()
    var productIdStringAll = [String]()
    var orderIds = String()
    
    //from groupbuy
    var productIdAll = [String]()
    var openGroupId = String()
    var payFee = String()
    var orderAutoId = String()
    var status = String()
    var index = Int()
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    var productIdString = [String]()
    var uid = ""
    var fromGroupBuy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        setupGridView()
        
        if productIdString.isEmpty {
            commentLabel.font = UIFont(name: "Helvetica-Light", size: 20)
            commentLabel.text = "這個訂單商品已評論完"
        }
    }
    
    func currentUserName()->(String){
        if let user = Auth.auth().currentUser{
            uid = user.uid
        }
        return(uid)
    }
    

    @IBAction func servicecall(_ sender: Any) {
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
    
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    @IBAction func backButton(_ sender: Any) {
        if (fromGroupBuy == false){
            let storyboard = UIStoryboard(name: "Order", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HistoryOrderInformationControllerId") as!  HistoryOrderInformationController
            vc.orderIds = orderIds
            vc.orderIndex = orderIndex
            vc.productIdString = productIdStringAll
            vc.progresss = progresss
            vc.payments = payment
            vc.orderCreateTimes = orderCreateTimes
            vc.orderEndTime = orderEndTime
            
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MyGroupBuyHistoryOrderControllerId") as!  MyGroupBuyHistoryOrderController
            
            vc.productId = productIdAll[0]
            vc.openGroupId = openGroupId
            vc.payFee = payFee
            vc.orderAutoId = orderAutoId
            vc.status = status
            vc.index = index
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension CommentAllController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        return productIdString.count        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
        cell.setLabel(productId:productIdString[indexPath.row],fromGroupBuy: fromGroupBuy)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentController") as!  CommentController
        vc.productIdString = productIdString[indexPath.row]
        vc.productIdStringAll = productIdString
        vc.fromGroupBuy = fromGroupBuy
        vc.orderIds = orderIds
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension CommentAllController: UICollectionViewDelegateFlowLayout{
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
