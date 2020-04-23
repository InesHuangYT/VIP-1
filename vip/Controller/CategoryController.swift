//
//  CategoryController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class CategoryController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var popularProduct: UIButton!
    
    let productRef = Database.database().reference().child("Product")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    @IBAction func popularProductWasPresed(_ sender: Any) {
        let vc = getProductVc() 
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "熱銷商品").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
        
        
        
    }
    
    @IBAction func visuallyProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "視覺相關").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
        
    }
    
    @IBAction func makeupProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "美妝保養").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    @IBAction func dessertProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "美食甜點").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    
    
    @IBAction func cProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "3C家電").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    
    @IBAction func dailyProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "日用品").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    @IBAction func familyProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "媽咪親子").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    @IBAction func lifeProductWasPresed(_ sender: Any) {
        let vc = getProductVc()
        
        productRef.queryOrdered(byChild: "Category").queryEqual(toValue: "居家生活").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            let count = data.count
            for child in data {
                print(child.key)
                vc.categoryId.append(child.key)
            }
            
            vc.count = count
            vc.fromCategory = true
            
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    
    
    func getProductVc() -> ProductController{
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductControllerId") as!  ProductController
        return vc
    }
    
    
    
    
    
}
