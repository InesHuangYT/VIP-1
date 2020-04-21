//
//  ShoppingCartController.swift
//  vip
//
//  Created by rourou on 03/03/2020.
//  Copyright © 2020 Ines. All rights reserved.
//

import Foundation
import UIKit
import Firebase




class ShoppingCartController : UIViewController{
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
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
        
        DispatchQueue.main.async {
            self.ref.child("ShoppingCart").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                if let data = snapshot.children.allObjects as? [DataSnapshot] {
                    let retriName = data.compactMap({($0.value as! [String:Any])["ProductName"]})
                    self.name = retriName
                    
                }
                
            })
        }
        print("num ITEM = ", self.name.count)
        print("shoppingCount",shoppingCount)
        
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    func collectionViewDeclare(){
        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ShoppingCartCollectionViewCell", bundle: nil),forCellWithReuseIdentifier: "ShoppingCartCollectionViewCell")
        
        
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
    
    func findIndex(selectProductId:String,vc:ProductInformationController){
        let shoppingCartRef =  Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "")
        shoppingCartRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            
            for i in 1...data.count {
                if data[i-1].key == selectProductId {
                    print("find index", i-1)
                    vc.index = i-1
                    
                }else{
                    print("Not find index", i-1)
                }
            }
            vc.fromShoppingCart = true
            self.navigationController?.pushViewController(vc,animated: true)
            
            
        })
        
    }
    
    
    
}

extension ShoppingCartController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return shoppingCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoppingCartCollectionViewCell", for: indexPath) as! ShoppingCartCollectionViewCell
        cell.loadData(index: indexPath.row)
        cell.delegate = self
        cell.index = indexPath.row
        return cell
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
        
//             shoppingCartRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
        //            let data = snapshot.children.allObjects as! [DataSnapshot]
        //            self.findIndex(selectProductId: data[indexPath.row].key,vc: vc)
        //            
        //            
        //        })
        
    }
}

extension ShoppingCartController: UICollectionViewDelegateFlowLayout{
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
