//
//  MenuViewController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var menuNameArr: Array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        menuNameArr = ["我的最愛","首頁","類別","團購","我的訂單","購物車","個人資訊"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        
        cell.lblMenu.text! = menuNameArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _: SWRevealViewController = self.revealViewController()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
        let desController = mainStoryboard.instantiateViewController(withIdentifier: "LikeListControllerId") as! LikeListController
        let newFrontViewController = UINavigationController.init(rootViewController: desController)
        let cell: MenuTableViewCell = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        
        if cell.lblMenu.text! == "我的最愛" // transit to ShoppingCart Storyboard
        {
            let likeListRef = Database.database().reference().child("LikeList").child(Auth.auth().currentUser!.uid)
            let likeListGroupRef = Database.database().reference().child("LikeListGroupBuy").child(Auth.auth().currentUser!.uid)
            
            // find LikeList productId
            likeListRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                let likeListData = snapshot.children.allObjects as! [DataSnapshot]
                let likeListCounts = likeListData.count
                var likeListProductId = [String]()
                var likeListGroupProductId = [String]()
                
                if likeListData.count != 0 {
                    for i in 0...likeListData.count-1 {
                        likeListProductId.append(likeListData[i].key)
                    }
                }
                
                print("likeListCounts ",likeListCounts)
                print("likeListProductId ",likeListProductId)
                desController.likeListCounts = likeListCounts
                desController.likeListProductId = likeListProductId
                
                // find LikeListGroupBuy productId
                likeListGroupRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                    let likeListGroupData = snapshot.children.allObjects as! [DataSnapshot]
                    let likeListGroupCounts = likeListGroupData.count
                    
                    if likeListGroupData.count != 0 {
                        for i in 0...likeListGroupData.count-1 {
                            likeListGroupProductId.append(likeListGroupData[i].key)
                        }
                    }
                    
                    desController.likeListGroupCounts = likeListGroupCounts
                    desController.likeListGroupProductId = likeListGroupProductId
                    self.revealViewController().pushFrontViewController(newFrontViewController, animated: true)
                })
            })
            
            
            
        }
        
        if cell.lblMenu.text! == "首頁"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "類別"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "團購"
        {
            Database.database().reference().child("GroupBuy").queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                (snapshot) in 
                let allKeys = snapshot.value as! [String : AnyObject]
                let nodeToReturn = allKeys.keys
                let counts = nodeToReturn.count
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "GroupBuy", bundle: nil)
                let desController = mainStoryboard.instantiateViewController(withIdentifier: "GroupBuyControllerId") as! GroupBuyController
                desController.count = counts
                let newFrontViewController = UINavigationController.init(rootViewController: desController)
                
                self.revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            })
        }
        
        if cell.lblMenu.text! == "我的訂單"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "OrderController") as! OrderController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "購物車"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ShoppingCart") as! ShoppingCartController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            let ref = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser!.uid)
            ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
                if (snapshot.exists()==false){
                    desController.shoppingCount = 0
                    self.revealViewController().pushFrontViewController(newFrontViewController, animated: true)
                }else{
                    let allKeys = snapshot.value as! [String : AnyObject]
                    let nodeToReturn = allKeys.keys
                    let counts = nodeToReturn.count
                    print("nodeToReturn ",nodeToReturn)
                    print("counts ",counts)
                    desController.shoppingCount = counts
                    self.revealViewController().pushFrontViewController(newFrontViewController, animated: true)
                }
                
                
            })
            
        }
        
        if cell.lblMenu.text! == "個人資訊"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "FriendControllerId") as! FriendController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
