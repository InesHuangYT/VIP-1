//
//  GroupBuyInformationController.swift
//  vip
//
//  Created by Ines on 2020/3/31.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class GroupBuyInformationController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var productEvaluation: UILabel!
    @IBOutlet weak var sellerEvaluation: UILabel!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var groupBuyImage: UIImageView!
    @IBOutlet weak var groupBuyOpenButton: UIButton!
    
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    var index  = Int()
    var productId = String()
    var uid = Auth.auth().currentUser?.uid
    var openByCount = Int()
    var groupBuyPeople = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDeclare()
        btnAction()
        self.setupGridView()
        setLabel(index:index)
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        groupBuyImage.layer.cornerRadius = 45
        groupBuyImage.layer.borderWidth = 1
        groupBuyImage.layer.borderColor = myColor.cgColor
        print("openByCount",self.openByCount)
        print("groupBuyPeople",self.groupBuyPeople)
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GroupBuyJoinCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyJoinCollectionViewCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    
    func setLabel(index:Int){
        Database.database().reference().child("GroupBuy")
            .queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                snapshot in
                
                if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                    let name = datas.compactMap({
                        ($0.value as! [String: Any])["ProductName"]
                    }) 
                    let price = datas.compactMap({
                        ($0.value as! [String: Any])["Price"]
                    })
                    let productDescription = datas.compactMap({
                        ($0.value as! [String: Any])["Description"]
                    })
                    let productEvaluation = datas.compactMap({
                        ($0.value as![String: Any])["ProductEvaluation"]
                    })
                    let sellerEvaluation = datas.compactMap({
                        ($0.value as! [String: Any])["SellerEvaluation"]
                    })
                    let image = datas.compactMap({
                        ($0.value as! [String: Any])["imageURL"]
                    })
                    
                    
                    self.name.text =  name[index] as? String
                    self.price.text = (price[index] as! String) + "元"
                    self.productDescription.text = "產品描述 " + (productDescription[index] as! String)
                    self.productEvaluation.text = "產品評價 " + (productEvaluation[index] as! String)
                    self.sellerEvaluation.text = "商家評價 " + (sellerEvaluation[index] as! String)
                    let imageUrl = image[index]
                    if let url = URL(string: imageUrl as! String){
                        URLSession.shared.dataTask(with: url){
                            (data,response,error) in 
                            if error != nil {
                                print("Download Image Task Fail: \(error!.localizedDescription)")
                            }
                            else if let imageData = data {
                                DispatchQueue.main.async {
                                    self.groupBuyImage.image = UIImage(data:imageData)
                                }
                            }
                        }.resume()
                    }
                    
                }
            }
        )
        
    }
    
    //   我要open團
    @IBAction func groupBuyOpenButtonWasPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyCheckOutControllerId") as!  GroupBuyCheckOutController
        vc.index = index
        vc.productId = productId
        vc.groupBuyStyle = "Open"
        self.navigationController?.pushViewController(vc,animated: true)
        
        
    }
    
    
    
}

//   我要Join團
extension GroupBuyInformationController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return self.openByCount 
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupBuyJoinCollectionViewCell", for: indexPath) as! GroupBuyJoinCollectionViewCell
        print("self.productId",self.productId)
        cell.setProductLabel(productId: String(self.productId), index:indexPath.row, groupBuyPeople: self.groupBuyPeople)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyCheckOutControllerId") as!  GroupBuyCheckOutController
        vc.index = indexPath.row      
        vc.productId = productId
        vc.groupBuyStyle = "Join"
        vc.groupBuyPeople = self.groupBuyPeople
        
        let ref =  Database.database().reference().child("GroupBuy").child(productId).child("OpenGroupId")
        
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print("index",indexPath.row)
                print("[self.index].key",snapshots[indexPath.row].key)
                ref.child(snapshots[indexPath.row].key)
                    .queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        
                        
                        ref.child(snapshots[indexPath.row].key).child("JoinBy")
                            .queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in
                                
                                var access = true
                                if let datass = snapshot.children.allObjects as? [DataSnapshot]{
                                    
                                    for i in datass{
                                        
                                        if i.key == self.uid {
                                            print("uid already inside ", i.key )
                                            self.setUpMessageNo()
                                            access = false   
                                        }  
                                    }
                                    if access == true{
                                        self.navigationController?.pushViewController(vc,animated: true)
                                        
                                    }
                                    
                                }
                            })   
                        
                    })
            }
        })
        
        
        
        
        
        
        
    }
    
    func setUpMessageNo(){
        let message = UIAlertController(title: "您已經在此團購結帳過摟", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "導入回我的團購看訂單", style: .default, handler: {action in 
            print("連到我的團購！！ !")
            //            連到我的團購！！
            self.transition()
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func transition(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        present(vc, animated: true, completion: nil)
    }
}

extension GroupBuyInformationController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.3)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}
