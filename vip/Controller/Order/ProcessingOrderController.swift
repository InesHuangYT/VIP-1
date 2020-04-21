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
    override func viewDidLoad() {
        
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        setupGridView()
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GroupBuyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyCollectionViewCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    
}


// 改
extension ProcessingOrderController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        return 1
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupBuyCollectionViewCell", for: indexPath) as! GroupBuyCollectionViewCell
        //        cell.setProductLabel(text: self.dataProductName[indexPath.row])
        cell.setProductLabel(index: indexPath.row)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        vc.index = indexPath.row   
        Database.database().reference().child("GroupBuy")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in 
                if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                    print("key:" ,datas[indexPath.row].key)
                    vc.productId = datas[indexPath.row].key
                    
                    let groupBuyPeople = datas.compactMap({
                        ($0.value as! [String: Any])["GroupBuyPeople"]
                    }) 
                    
                    let people = groupBuyPeople[indexPath.row] as! String
                    let peoples = Int64(people)
                    print("peoples", peoples ?? 0)
                    vc.groupBuyPeople = Int(peoples ?? 0) 
                    
                    Database.database().reference().child("GroupBuy").child(datas[indexPath.row].key).child("OpenGroupId")
                        .queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in 
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                
                                print("GroupBuy key count : ",snapshots.count)
                                vc.openByCount = snapshots.count
                                self.navigationController?.pushViewController(vc,animated: true)
                                
                            }
                        })
                }
            })
        
        
        
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



