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
            print("finshCollectionView")
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
            
            return cell
            
        }
        
        
        
        //        return cell
        
        //        cell.setProductLabel(text: self.dataProductName[indexPath.row])
        //        cell.setProductLabel(index: indexPath.row)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
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
