//
//  LikeListController.swift
//  vip
//
//  Created by Ines on 2020/4/24.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class LikeListController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var groupBuyCollectionView: UICollectionView!
    
    @IBOutlet weak var myLikeListLabel: UILabel!
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    var ref: DatabaseReference!
    
    // value from MenuController
    var likeListCounts = Int()
    var likeListGroupCounts = Int()
    var likeListProductId = [String]()
    var likeListGroupProductId = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        ref = Database.database().reference()
        likeListLabel()
        
        print("likeListProductId",likeListProductId)
        print("likeListGroupProductId",likeListGroupProductId)
        
        
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        productCollectionView.reloadData()
        productCollectionView.delegate = self
        productCollectionView.dataSource = self
        productCollectionView.register(UINib(nibName: "ShoppingCartCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "ShoppingCartCollectionViewCell")
        
        groupBuyCollectionView.reloadData()
        groupBuyCollectionView.delegate = self
        groupBuyCollectionView.dataSource = self
        groupBuyCollectionView.register(UINib(nibName: "ShoppingCartCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "ShoppingCartCollectionViewCell")
    }
    
    func likeListLabel(){
        if  likeListGroupCounts==0 && likeListCounts==0 {
            myLikeListLabel.text = "目前你的最愛是空的哦！" 
        }
    }
    
    func findProductIndex(searchId:String,vc:ProductInformationController){
        let productRef =  Database.database().reference().child("Product")
        productRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            for i in 1...data.count {
                if data[i-1].key == searchId {
                    print("find index", i-1)
                    vc.index = i-1
                }else{
                    print("Not find index", i-1)
                }
            }
            self.navigationController?.pushViewController(vc,animated: true)
            
            
        })
        
    }
    
    func findGroupBuyProductIndex(searchId:String,vc:GroupBuyInformationController){
        let groupBuyRef =  Database.database().reference().child("GroupBuy")
        groupBuyRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.children.allObjects as! [DataSnapshot]
            for i in 1...data.count {
                if data[i-1].key == searchId {
                    print("find index", i-1)
                    vc.index = i-1
                }else{
                    print("Not find index", i-1)
                }
            }
            
            groupBuyRef.child(searchId).queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                
                let value = snapshot.value as? NSDictionary
                let groupBuyPeople = value?["GroupBuyPeople"] as? String ?? ""
                let peoples = Int64(groupBuyPeople)
                vc.groupBuyPeople = Int(peoples ?? 0)
                
                groupBuyRef.child(searchId).child("OpenGroupId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        
                        print("GroupBuy key count : ",snapshots.count)
                        vc.openByCount = snapshots.count
                        self.navigationController?.pushViewController(vc,animated: true)
                        
                    }
                })
                
            })
            
        })
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let newFrontViewController = UINavigationController.init(rootViewController: desController)
        
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }
    
}

extension LikeListController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        if collectionView.isEqual(productCollectionView){
            return likeListCounts
        }
        else{
            
            return likeListGroupCounts
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoppingCartCollectionViewCell", for: indexPath) as! ShoppingCartCollectionViewCell
        
        
        if collectionView.isEqual(productCollectionView){
            cell.loadData(productId: likeListProductId[indexPath.row], hiddenSelectButton: true, fromWhere: "LikeList")
            return cell
        }
        else {
            cell.loadData(productId: likeListGroupProductId[indexPath.row], hiddenSelectButton: true, fromWhere: "LikeListGroupBuy")
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let productStoryboard = UIStoryboard(name: "Product", bundle: nil)
        let groupBuyStoryboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        
        let vc = productStoryboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
        let vcGroup = groupBuyStoryboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        
        if collectionView.isEqual(productCollectionView){
            findProductIndex(searchId: likeListProductId[indexPath.row], vc: vc)
        }
            
        else{
            vcGroup.productId = likeListGroupProductId[indexPath.row]
            findGroupBuyProductIndex(searchId: likeListGroupProductId[indexPath.row], vc:vcGroup )
            
        }
        
    }
}

extension LikeListController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.45)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}
