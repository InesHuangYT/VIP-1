//
//  DeadLineController.swift
//  vip
//
//  Created by Chun on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import EventKit
import Firebase

class DeadLineController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    //    var productId = [String]()
    var titles = String()
    var time = String()
    var deadline = Date()
    var productIdString = [String]()
    var fromGroupBuy = false // from MyGroupBuyController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionViewDeclare()
        self.setupGridView()
        btnAction()
        print("productIdString",productIdString)
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "DeadLineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DeadLineCollectionViewCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func settime(_ string:String, dateFormat:String = "yyyy-MM-dd") -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        return date!
    }
    
    @IBAction func btnAddEvent(_ sender: Any) {
        
        let eventStore:EKEventStore = EKEventStore()
        let productCount = (productIdString.count) 
        if fromGroupBuy == true {
            // 我的團購只有一個商品
            Database.database().reference().child("GroupBuy").child(productIdString[0])
                .queryOrderedByKey()
                .observeSingleEvent(of: .value, with: { snapshot in
                    let value = snapshot.value as? NSDictionary
                    self.titles = value?["ProductName"] as? String ?? ""
                    self.time = value?["ExpDate"] as? String ?? ""
                    self.deadline = self.settime(self.time, dateFormat: "yyyy-MM-dd")
                    eventStore.requestAccess(to: .event) {(granted, error) in
                        if(granted) && (error == nil)
                        {
                            print("granted \(granted)")
                            let event:EKEvent = EKEvent(eventStore: eventStore)
                            event.title = self.titles + "有效期限"
                            event.startDate = self.deadline
                            event.endDate = self.deadline
                            event.notes = self.titles + "到期囉"
                            event.calendar = eventStore.defaultCalendarForNewEvents
                            do{
                                try eventStore.save(event, span: .thisEvent)
                            }catch let error as NSError{
                                print("error \(error)")
                            }
                            print("Save Event")
                        }
                    }
                })
        }
        else {
            for i in 0...productCount-1 {
                Database.database().reference().child("Product").child(productIdString[i])
                    .queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in
                        let value = snapshot.value as? NSDictionary
                        self.titles = value?["ProductName"] as? String ?? ""
                        self.time = value?["ExpDate"] as? String ?? ""
                        self.deadline = self.settime(self.time, dateFormat: "yyyy-MM-dd")
                        eventStore.requestAccess(to: .event) {(granted, error) in
                            if(granted) && (error == nil)
                            {
                                print("granted \(granted)")
                                let event:EKEvent = EKEvent(eventStore: eventStore)
                                event.title = self.titles + "有效期限"
                                event.startDate = self.deadline
                                event.endDate = self.deadline
                                event.notes = self.titles + "到期囉"
                                event.calendar = eventStore.defaultCalendarForNewEvents
                                do{
                                    try eventStore.save(event, span: .thisEvent)
                                }catch let error as NSError{
                                    
                                    print("error \(error)")
                                }
                                print("Save Event")
                            }
                        }
                    })
            }
        }
        let message = UIAlertController(title: "加入行事曆成功", message: nil, preferredStyle: .alert)
        let confirm = UIAlertAction(title: "確認", style: .default, handler:
        {action in})
        message.addAction(confirm)
        self.present(message, animated: true, completion: nil)
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
}

extension DeadLineController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return productIdString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeadLineCollectionViewCell", for: indexPath) as! DeadLineCollectionViewCell
        cell.setProductLabel(productId: productIdString[indexPath.row], fromGroupBuy: false)
        print("productIdString Call",productIdString[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DeadLine", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DeadLineInformationController") as!  DeadLineInformationController
        vc.productId = productIdString[indexPath.row]
        self.navigationController?.pushViewController(vc,animated: true)
    }
}

extension DeadLineController: UICollectionViewDelegateFlowLayout{
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

