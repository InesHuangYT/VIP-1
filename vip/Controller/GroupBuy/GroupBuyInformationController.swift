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
    
    @IBOutlet weak var joinCollectionView: UICollectionView!
    @IBOutlet weak var commentCollectionView: UICollectionView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var productEvaluation: UILabel!
    @IBOutlet weak var sellerEvaluation: UILabel!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var groupBuyImage: UIImageView!
    @IBOutlet weak var groupBuyOpenButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var estimatedWidth = 280.0
    var cellMarginSize = 16.0
    
    var index  = Int()
    var productId = String()
    var uid = Auth.auth().currentUser?.uid
    var openByCount = Int()
    var groupBuyPeople = Int()
    var status = ""
    var from = String()
    var commentCount = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDeclare()
        btnAction()
        setupGridView()
        if status == ""{
            setLabel(index:index)
        }
        else {
            setMyGroupBuyLabel(index:index)
        }
        //        從哪一頁面過來
        if from != "" {
            groupBuyOpenButton.isHidden = true
        }
        
        layOut()
        print("openByCount",self.openByCount)
        print("groupBuyPeople",self.groupBuyPeople)
        print("from",from)
        print("status",status)
        print("index",index)
        
        
        
    }
    
    func layOut(){
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        groupBuyImage.layer.cornerRadius = 45
        groupBuyImage.layer.borderWidth = 1
        groupBuyImage.layer.borderColor = myColor.cgColor
        
        //        購物車選取按鈕設定
        likeButton.setTitle("點擊以加入我的最愛",for: UIControl.State.normal)
        likeButton.setTitle("點擊以取消我的最愛",for: UIControl.State.selected)
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
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func collectionViewDeclare(){
        joinCollectionView.reloadData()
        joinCollectionView.delegate = self
        joinCollectionView.dataSource = self
        joinCollectionView.register(UINib(nibName: "GroupBuyJoinCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyJoinCollectionViewCell")
        
        commentCollectionView.delegate = self
        commentCollectionView.dataSource = self
        commentCollectionView.register(UINib(nibName: "ProductComment", bundle: nil), forCellWithReuseIdentifier: "ProductComment")
        
    }
    
    func setupGridView(){
        let flow = joinCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
        let flows = commentCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flows.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flows.minimumLineSpacing = CGFloat(self.cellMarginSize)
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
                        ($0.value as![String: Any])["ProductEvaluationAll"]
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
                    //                    我的最愛
                    let likeListRef = Database.database().reference().child("LikeListGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
                    likeListRef.child(datas[index].key).queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in
                            let value = snapshot.value as? [String:Any]
                            let likeStatus = value?["Status"] as? String ?? ""
                            print("likeStatus = ", likeStatus)
                            if likeStatus == ""{
                                self.setSelectButton(status: likeStatus,select:false)
                                
                            }else{
                                self.setSelectButton(status: likeStatus,select:true) 
                            }
                            
                        })
                    
                    //                    
                    
                }
            }
        )
        
    }
    
    func setMyGroupBuyLabel(index:Int){
        let userGroupBuyOrderRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("OrderId")
        
        let userGroupBuyStatusRef =  Database.database().reference().child("UserGroupBuy").child(Auth.auth().currentUser?.uid ?? "").child("Status").child(status).child("OrderId")
        
        let groupBuyRef = Database.database().reference().child("GroupBuy")
        
        userGroupBuyStatusRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                print(snapshots[index].key)    
                print("count ",snapshots.count)    
                
                userGroupBuyOrderRef.child(snapshots[index].key).queryOrderedByKey()
                    .observeSingleEvent(of: .value, with: { snapshot in 
                        let userGroupBuyValue = snapshot.value as? NSDictionary
                        let productId = userGroupBuyValue?["ProductId"] as? String ?? ""
                        
                        //                    我的最愛
                        let likeListRef = Database.database().reference().child("LikeListGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
                        likeListRef.child(productId).queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in
                                let value = snapshot.value as? [String:Any]
                                let likeStatus = value?["Status"] as? String ?? ""
                                print("likeStatus = ", likeStatus)
                                if likeStatus == ""{
                                    self.setSelectButton(status: likeStatus,select:false)
                                    
                                }else{
                                    self.setSelectButton(status: likeStatus,select:true) 
                                }
                                
                            })
                        
                        //   
                        
                        groupBuyRef.child(productId).queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in 
                                
                                let productValue = snapshot.value as? NSDictionary
                                let name = productValue?["ProductName"] as? String ?? ""
                                let price = productValue?["Price"] as? String ?? ""
                                let productDescription = productValue?["Description"] as? String ?? ""
                                let productEvaluation = productValue?["ProductEvaluationAll"] as? String ?? ""
                                let sellerEvaluation = productValue?["SellerEvaluation"] as? String ?? ""
                                let url = productValue?["imageURL"] as? String ?? ""
                                
                                self.name.text = name
                                self.price.text = price + "元"
                                self.productDescription.text = "產品描述 " + productDescription
                                self.productEvaluation.text = "產品評價 " + productEvaluation
                                self.sellerEvaluation.text = "商家評價 " + sellerEvaluation
                                if let imageUrl = URL(string: url){
                                    URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                        if error != nil {
                                            print("Download Image Task Fail: \(error!.localizedDescription)")
                                        }
                                        else if let imageData = data {
                                            DispatchQueue.main.async { 
                                                self.groupBuyImage.image = UIImage(data: imageData)
                                            }
                                        }
                                        
                                    }.resume()
                                }
                                
                            })
                        
                        
                        
                    })
                
                
                
            }
            
            
        })
    }
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        
        let ref = Database.database().reference().child("LikeListGroupBuy").child(Auth.auth().currentUser?.uid ?? "")
        if sender.isSelected  {
            
            print("here")
            self.likeButton.setImage(UIImage(named : "like-2"), for: UIControl.State.normal) 
            sender.isSelected = false
            let removeRef = ref.child(productId).child("Status")
            removeRef.removeValue()
            alertUnLike()
            
        }
        else{
            
            print("hi")
            self.likeButton.setImage(UIImage(named : "like"), for: UIControl.State.selected)
            sender.isSelected = true
            
            ref.child(productId).child("Status").setValue("Like")
            alertLike()
        }
        
    }
    
    func setSelectButton(status:String,select:Bool){
        
        if select == false {
            likeButton.isSelected = false
        }
        
        if status == "Like"{
            print("like!!!!!!!")
            self.likeButton.setImage(UIImage(named : "like"), for: UIControl.State.selected)
        }
        if status == "Unlike"{
            print("unlike!!!!!!!")
            self.likeButton.setImage(UIImage(named : "like-2"), for: UIControl.State.normal)
        }
    }
    
    
    
    //   我要open團
    @IBAction func groupBuyOpenButtonWasPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyCheckOutControllerId") as!  GroupBuyCheckOutController
        vc.index = index
        vc.productIndex = index
        vc.productId = productId
        vc.groupBuyStyle = "Open"
        vc.groupBuyPeople = self.groupBuyPeople
        
        self.navigationController?.pushViewController(vc,animated: true)
        
    }
    
    func setUpMessageNo(){
        let message = UIAlertController(title: "您已經在此團購結帳過摟", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "回我的訂單", style: .default, handler: {action in 
            print("連到我的團購！！ !")
            self.transition()
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func transition(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderController") as! OrderController
        let newFrontViewController = UINavigationController.init(rootViewController: vc)
        revealViewController().pushFrontViewController(newFrontViewController, animated: true)
    }
    
    
    
}

//   我要Join團
extension GroupBuyInformationController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        if collectionView.isEqual(joinCollectionView){
            return self.openByCount 
        }else{
            return commentCount
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{

        if collectionView.isEqual(joinCollectionView){
            let groupBuyJoinCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:"GroupBuyJoinCollectionViewCell", for: indexPath) as! GroupBuyJoinCollectionViewCell
            print("self.productId",self.productId)
            groupBuyJoinCollectionViewCell.setProductLabel(productId:self.productId, index:indexPath.row, groupBuyPeople: self.groupBuyPeople)
            return groupBuyJoinCollectionViewCell
            
        }else{
            let productCommentCell = collectionView.dequeueReusableCell(withReuseIdentifier:
                "ProductComment", for: indexPath) as! ProductComment
            print("commentCount",commentCount)
            print("productId",productId)
            productCommentCell.setLable(index: indexPath.row, groupProductId: productId)
            return productCommentCell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.isEqual(joinCollectionView){ 
            let storyboard = UIStoryboard(name: "Checkout", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyCheckOutControllerId") as!  GroupBuyCheckOutController
            vc.index = indexPath.row   
            vc.productIndex = index
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
