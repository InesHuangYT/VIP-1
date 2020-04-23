//
//  ProcessingOrderController.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class ProcessingOrderController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    var myOrderCount = Int()
    var myOrderId = [String]() 
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        setupGridView()
        print("myOrderId",myOrderId)
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProcessingOrderCell", bundle: nil), forCellWithReuseIdentifier: "ProcessingOrderCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func getOrderProductId(orderIndex:Int,orderId:String,vc:ProcessingOrderInformationController){
        let productOrderRef = Database.database().reference().child("ProductOrder").child(orderId)
        var productIdStrings = [String]()
        
        productOrderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let orderProgress = value?["OrderStatus"] as? String ?? ""
            let payment = value?["Payment"] as? String ?? ""
            let orderCreateTime = value?["OrderCreateTime"] as? String ?? ""
            
            //find what productIds in this order
            let productIdString = value?["ProductId"] as? [String]
            print("productIdString",productIdString ?? "")            
            let productCount = (productIdString?.count) ?? 0 as Int 
            
            for i in 0 ... productCount-1 {
                productIdStrings.append(productIdString?[i] ?? "")
            }            
            
            vc.orderIndex = orderIndex
            vc.orderIds = self.myOrderId[orderIndex]
            vc.productIdString = productIdStrings
            vc.progresss = orderProgress
            vc.payments = payment
            vc.orderCreateTimes = orderCreateTime
            
            self.navigationController?.pushViewController(vc,animated: true)
            
        })
        
    }
    
    
    
}



extension ProcessingOrderController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        return myOrderCount
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProcessingOrderCell", for: indexPath) as! ProcessingOrderCell
        cell.setLabel(orderId:myOrderId[indexPath.row])
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProcessingOrderInformationControllerId") as!  ProcessingOrderInformationController
        getOrderProductId(orderIndex: indexPath.row, orderId: myOrderId[indexPath.row], vc:vc )
        
        
        
    }
}

extension ProcessingOrderController: UICollectionViewDelegateFlowLayout{
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



