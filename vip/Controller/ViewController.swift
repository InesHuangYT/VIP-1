//
//  MainController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var groupBuyButton: UIButton!
    @IBOutlet weak var shppingCartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        setupTextField()
    }
 
    private func setupTextField(){
        searchTextField.delegate = self
        
        let tapOnScreen :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapOnScreen)
    }
    @objc private func hideKeyboard(){
        searchTextField.resignFirstResponder()
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
    
    @IBAction func groupBuyButtonWasPresed(_ sender: Any) {
        Database.database().reference().child("GroupBuy")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                let allKeys = snapshot.value as! [String : AnyObject]
                let nodeToReturn = allKeys.keys
                let counts = nodeToReturn.count
                print("nodeToReturn ",nodeToReturn)
                let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyControllerId") as! GroupBuyController
                vc.count = counts
                self.navigationController?.pushViewController(vc,animated: true)
            })
    }
    
    @IBAction func shoppingCartButtonWasPressed(_ sender: Any) {
        
        let ref = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser!.uid)
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let storyboard: UIStoryboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ShoppingCart") as! ShoppingCartController
            print("snapshot",snapshot.exists())
            if (snapshot.exists()==false){
                
                vc.shoppingCount = 0
                self.navigationController?.pushViewController(vc,animated: true)
            }else{
                let allKeys = snapshot.value as! [String : AnyObject] 
                let nodeToReturn = allKeys.keys
                let counts = nodeToReturn.count
                print("nodeToReturn ",nodeToReturn)
                print("counts ",counts)
                
                
                vc.shoppingCount = counts
                self.navigationController?.pushViewController(vc,animated: true)
            }
        })
    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        let productRef =  Database.database().reference().child("Product")
        let searchText = searchTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductControllerId") as!  ProductController
        print("searchText",searchText)
        if searchText != ""{
            print("here",searchText)
            
            productRef.queryOrdered(byChild: "ProductName").queryStarting(atValue: searchText).queryEnding(atValue: "\u{f8ff}" + searchText + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.children.allObjects as! [DataSnapshot]
                let count = data.count
                for child in data {
                    print(child.key)
                    vc.searchId.append(child.key)
                    
                }
                
                vc.count = count
                vc.fromSearch = true
                
                self.navigationController?.pushViewController(vc,animated: true)
            })
            
            
        }
        
        
        
        //            
        //            Database.database().reference().child("Product").queryOrdered(byChild: "ProductName").queryEqual(toValue : search)
        //                .observe(.value, with: {
        //                (snapshot) in
        //                let allKeys = snapshot.value as! [String : AnyObject]
        //                let nodeToReturn = allKeys.keys
        //                let counts = nodeToReturn.count
        //                print("nodeToReturn ",nodeToReturn)
        //                let storyboard = UIStoryboard(name: "Product", bundle: nil)
        //                let vc = storyboard.instantiateViewController(withIdentifier: "ProductControllerId") as!  ProductController
        //                vc.count = counts
        //
        //                self.navigationController?.pushViewController(vc,animated: true)
        //            })
        
        
    }
    
    //    下面的程式 會導致後面要加入團購或是開團購時，一直導回 GroupBuyController Scene *(.observe)
    //        Database.database().reference().child("GroupBuy").observe(.value, with: { 
    //            (snapshot) in 
    //            let allKeys = snapshot.value as! [String : AnyObject]
    //            let nodeToReturn = allKeys.keys
    //            let counts = nodeToReturn.count
    //            print("nodeToReturn ",nodeToReturn)
    //            let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
    //            let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyControllerId") as! GroupBuyController
    //            vc.count = counts
    //            self.navigationController?.pushViewController(vc,animated: true)
    //            
    //        })
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
