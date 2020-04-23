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
    
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    var ref: DatabaseReference!
    var test:UILabel!
    var count = Int()
    var name:[Any] = []
    var shoppingCount = Int()
    var selectProductId = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        collectionViewDeclare()
        
        ref = Database.database().reference()
        let user = Auth.auth().currentUser!
        
        print("shoppingCount",shoppingCount)
        
        
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
    
    
    @IBAction func goToCheckButton(_ sender: Any) {
        let shoppingCartRef = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "")
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderCheckoutControllerId") as! OrderCheckoutController
        shoppingCartRef.queryOrdered(byChild: "Status").queryEqual(toValue: "Selected").observeSingleEvent(of: .value, with: { snapshot in
            
            let data = snapshot.children.allObjects as! [DataSnapshot]
            
            let count = data.count
            for child in data {
                print(child.key)
                self.selectProductId.append(child.key)
            }
            
            vc.selectProductId = self.selectProductId 
            vc.count = count
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
        
    }
    

    
    
    
}

extension LikeListController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        if collectionView.isEqual(productCollectionView){
            return shoppingCount
        }
        else{
            
            return shoppingCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoppingCartCollectionViewCell", for: indexPath) as! ShoppingCartCollectionViewCell
        if collectionView.isEqual(productCollectionView){
            cell.loadData(index: indexPath.row)
            cell.delegate = self
            cell.index = indexPath.row
            return cell
        }
        else{
            cell.loadData(index: indexPath.row)
            cell.delegate = self
            cell.index = indexPath.row
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
        
        let shoppingCartRef = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "")
        
        vc.index = indexPath.row
        vc.fromShoppingCart = true
        
        shoppingCartRef.queryOrdered(byChild: "Status").queryEqual(toValue: "Selected").observeSingleEvent(of: .value, with: { snapshot in
            
            let data = snapshot.children.allObjects as! [DataSnapshot]
            for child in data {
                print(child.key)
                self.selectProductId.append(child.key)
            }
            
            vc.selectProductId = self.selectProductId 
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
        
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
