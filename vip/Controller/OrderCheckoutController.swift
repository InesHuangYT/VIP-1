//
//  CheckoutController.swift
//  vip
//
//  Created by Chun on 2020/4/1.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class OrderCheckoutController: UIViewController, UITextFieldDelegate {
    
    var index = Int()
    var productId = String()
    var count = Int()
    
    let ref = Database.database().reference()
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    
    var selectProductId = [String]()
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var deliverWaysLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var paymentWaysLabel: UILabel!
    @IBOutlet weak var couponTextField: UITextField!
    @IBOutlet weak var itemfeeLabel: UILabel!
    @IBOutlet weak var deliverfeeLabel: UILabel!
    @IBOutlet weak var payfeeLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTextField()
        collectionViewDeclare()
        btnAction()
        
        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
            .child("Profile")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String:Any]
                    else {
                        print("Error")
                        return
                }
                self.setLabel(value: value)
            })
        
        getItemFeeLabel()
        print(selectProductId)
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    private func setupTextField(){
        couponTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc private func hideKeyboard(){
        couponTextField.resignFirstResponder()
    }
    
    func collectionViewDeclare(){
        collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ShoppingCartCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShoppingCartCollectionViewCell")
    }
    func setLabel(value:[String:Any]){
        
        let account = value["account"] as? String
        let name = value["name"] as? String
        let deliverWays = value["deliverWays"] as? String
        let paymentWays = value["paymentWays"] as? String
        if (value["phone"] as? String) == nil{
            print("phone is null ")
            phoneLabel.text = "請設定手機號碼"
            phoneLabel.textColor = UIColor(red: 255/255, green: 136/255, blue: 128/255, alpha: 1)
        }else{
            let phone = value["phone"] as? String
            phoneLabel.text = "手機號碼    " + (phone!)
        }
        nameLabel.text = "姓名            " + (name!)
        emailLabel.text = "信箱            " + (account!)
        deliverWaysLabel.text = "寄送方式    " + (deliverWays!)
        paymentWaysLabel.text = "付款方式    " + (paymentWays!)
    }
    
    func getItemFeeLabel(){
        var productTotal = Int()
        let shoppingCartRef = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "")
        shoppingCartRef.queryOrdered(byChild: "Status").queryEqual(toValue: "Selected").observeSingleEvent(of: .value, with: { snapshot in
            
            if let data = snapshot.children.allObjects as? [DataSnapshot] {
                let price = data.compactMap({($0.value as! [String:Any])["Price"]})
                for i in 0...price.count-1 {
                    let mon = price[i] as? String
                    let money = Int(mon ?? "")
                    productTotal += (money ?? 0) as Int
                }
                print(productTotal)
                self.itemfeeLabel.text = String(productTotal) + "元"
                self.deliverfeeLabel.text = String(60)
                let allPay = (productTotal ?? 0) as Int + 60
                self.payfeeLabel.text = String(allPay) + "元" 
                
            }
            
            
        })
        
        
    }
    
    func transitionToLogInScene(){
        let storyboard = UIStoryboard(name: "SignUpLogIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LogInControllerId") as! LogInController
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    
    @IBAction func confirmOrderButtonWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderComfirmControllerId") as! OrderComfirmController
        var productTotal = Int()
        
        let shoppingCartRef = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "")
        shoppingCartRef.queryOrdered(byChild: "Status").queryEqual(toValue: "Selected").observeSingleEvent(of: .value, with: { snapshot in
            
            if let data = snapshot.children.allObjects as? [DataSnapshot] {
                let price = data.compactMap({($0.value as! [String:Any])["Price"]})
                for i in 0...price.count-1 {
                    let mon = price[i] as? String
                    let money = Int(mon ?? "")
                    productTotal += (money ?? 0) as Int
                }
                print(productTotal)
                
                let allPay = (productTotal) as Int + 60
                vc.payFee = String(allPay) 
                vc.count = self.count
                vc.selectProductId = self.selectProductId
                self.navigationController?.pushViewController(vc,animated: true)
            }

        })
        
        
        
    }
    
    
    
    
    
    
}
extension OrderCheckoutController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShoppingCartCollectionViewCell", for: indexPath) as! ShoppingCartCollectionViewCell
        cell.loadData(productId:selectProductId[indexPath.row],hiddenSelectButton:true)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
        
        let shoppingCartRef = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser?.uid ?? "")
        shoppingCartRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let data = snapshot.children.allObjects as! [DataSnapshot]
            self.findIndex(selectProductId: data[indexPath.row].key,vc: vc)
            
            
        })
        
    }
    
}

extension OrderCheckoutController: UICollectionViewDelegateFlowLayout{
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
