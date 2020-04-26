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
    @IBOutlet weak var orderZero: UILabel!
    @IBOutlet weak var backToMain: UIButton!
    
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
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
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
    
    @IBAction func backToMain(_ sender: Any) {
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
//        let newFrontViewController = UINavigationController.init(rootViewController: desController)
//        
//        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        self.navigationController?.popViewController(animated: true)
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
        if myOrderCount != 0 {
            orderZero.isHidden = true
//            backToMain.isHidden = true
        }
        
        return myOrderCount
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProcessingOrderCell", for: indexPath) as! ProcessingOrderCell
        cell.setLabel(orderId:myOrderId[indexPath.row])
        cell.delegate = self
        cell.orderId = myOrderId[indexPath.row]
        cell.removeIndex = indexPath.row
        
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

//Delete Cell in UICollectionView Xcode 9.0 (Swift 4.0) https://www.youtube.com/watch?v=TlAkqQ2Z3uk

//extension ProcessingOrderController: ProcessingOrderProtocol{
//    func deleteData(index: Int) {
//        let myOderRef =  Database.database().reference().child("UserProduct").child(Auth.auth().currentUser?.uid ?? "")
//        myOderRef.child("Status").child("Processing/OrderId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
//            if let datas = snapshot.children.allObjects as? [DataSnapshot]{
//                self.myOrderCount = datas.count
//                
//                for data in datas {
//                    self.myOrderId.append(data.key)
//                }
//            }
//            self.collectionView.reloadData()
//
//        })
//    }
//}


