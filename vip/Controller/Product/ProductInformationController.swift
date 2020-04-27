//
//  ProductInformationController.swift
//  vip
//
//  Created by Ines on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class ProductInformationController: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var sellerEvaluationLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var pauseAndPlay: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var addShoppingCart: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var estimatedWidth = 200.0
    var cellMarginSize = 16.0
    
    var imageURL : String!
    var productID:[String] = []
    var ID:String!
    var audioPlayer: AVAudioPlayer?
    
    var selectProductId = [String]()
    var fromShoppingCart = false
    var productId = String()
    var fromMyOrder = false //從訂單來
    var fromCheckOut = false
    var price = String()
    var index = Int()
    var commentCount = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("index",index)
        print("productId!!!!!!!!",productId)
        btnAction()
        layOut()
        audioPlay()
        collectionViewDeclare()
        setupGridView()
        
        //        從訂單進來 用productId 
        if (fromMyOrder == true){
            setLabel(productId:productId)
        }
            //        從購物車或一般商品查詢或我的最愛或分類進來 用index
        else{
            setLabel(index: index,selectProductId:selectProductId)
        }
        
        //hide addShoppingCart button
        if(fromShoppingCart == true || fromMyOrder == true) {
            addShoppingCart.isHidden = true
        }
        
    }
    
    
    func collectionViewDeclare(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ProductComment", bundle: nil), forCellWithReuseIdentifier: "ProductComment")
    }
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func layOut(){
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        productImage.layer.cornerRadius = 45
        productImage.layer.borderWidth = 1
        productImage.layer.borderColor = myColor.cgColor
        productImage.image = UIImage(named:"logo")
        
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
    
    func audioPlay(){
        let lemmonSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Easy Lemon 30 Second", ofType: "mp3")!)
        print(lemmonSound)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: lemmonSound)
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
        
        pauseAndPlay.setImage(UIImage(named : "pause"), for: UIControl.State.normal) //停
        pauseAndPlay.setImage(UIImage(named : "play"), for: UIControl.State.selected) //播
        
        slider.maximumValue = Float(audioPlayer?.duration ?? 0)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
    }
    
    @IBAction func pauseAndPlayButtonWasPressed(_ sender: UIButton) {
        
        pauseAndPlay.isSelected = !sender.isSelected
        
        if(audioPlayer?.isPlaying == true){
            audioPlayer?.stop()
            
        }else{
            audioPlayer?.play()
        }
        
    }
    
    // drag slider
    @IBAction func changeAudioTime(_ sender: Any) {
        audioPlayer?.stop()
        audioPlayer?.currentTime = TimeInterval(slider.value)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    
    @objc func updateSlider(){
        slider.value = Float(audioPlayer?.currentTime ?? 0)
        NSLog("HHHHii")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        audioPlayer?.stop()
    }
    
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func setLabel(index:Int,selectProductId:[String]){    
        let productRef = Database.database().reference().child("Product")
        
        if fromShoppingCart == true {
            
            self.ID = selectProductId[index]
            
            productRef.child(selectProductId[index]).queryOrderedByKey()
                .observeSingleEvent(of: .value, with: { snapshot in
                    let value = snapshot.value as? NSDictionary
                    let name = value?["ProductName"] as? String ?? ""
                    let price = value?["Price"] as? String ?? ""
                    let description = value?["Description"] as? String ?? ""
                    let productEvaluationAll = value?["ProductEvaluationAll"] as? String ?? ""
                    let sellerEvaluation = value?["SellerEvaluation"] as? String ?? ""
                    self.nameLabel.text = name
                    self.priceLabel.text = price + "元"
                    self.descriptionLabel.text = "產品描述 " + description
                    self.evaluationLabel.text = "產品評價 " + productEvaluationAll + "星"
                    self.sellerEvaluationLabel.text = "商家評價 " + sellerEvaluation
                    let url = value?["imageURL"] as? String ?? ""
                    if let imageUrl = URL(string: url){
                        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                            if error != nil {
                                print("Download Image Task Fail: \(error!.localizedDescription)")
                            }
                            else if let imageData = data {
                                DispatchQueue.main.async { 
                                    self.productImage.image = UIImage(data: imageData)
                                }
                            }
                            
                        }.resume()
                    } 
                    
                    //                  我的最愛
                    let likeListRef = Database.database().reference().child("LikeList").child(Auth.auth().currentUser?.uid ?? "")
                    likeListRef.child(selectProductId[index]).queryOrderedByKey()
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
                })
            
        }
            
        else{
            
            productRef.queryOrderedByKey()
                .observeSingleEvent(of: .value, with: { snapshot in
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        let id = userSnap.key
                        self.productID.append(id)
                    }
                    print("This ID = ", self.productID[index])
                    self.ID = self.productID[index]
                    
                    //                  我的最愛
                    let likeListRef = Database.database().reference().child("LikeList").child(Auth.auth().currentUser?.uid ?? "")
                    likeListRef.child(self.ID).queryOrderedByKey()
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
                    
                    if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                        let nameResults = datas.compactMap({
                            ($0.value as! [String: Any])["ProductName"]
                        })
                        let priceResults = datas.compactMap({
                            ($0.value as! [String: Any])["Price"]
                        })
                        let descriptionResults = datas.compactMap({
                            ($0.value as! [String: Any])["Description"]
                        })
                        let productEvaluationResults = datas.compactMap({
                            ($0.value as! [String: Any])["ProductEvaluationAll"]
                        })
                        let sellerEvaluationResults = datas.compactMap({
                            ($0.value as! [String: Any])["SellerEvaluation"]
                        })
                        let imageResults = datas.compactMap({
                            ($0.value as! [String: Any])["imageURL"]
                        })
                        
                        self.nameLabel.text = nameResults[index] as? String
                        self.priceLabel.text = (priceResults[index] as! String) + "元"
                        self.price = priceResults[index] as! String //給下面加入購物車使用
                        self.descriptionLabel.text = "產品描述 " + (descriptionResults[index] as! String)
                        self.evaluationLabel.text = "產品評價 " + (productEvaluationResults[index] as! String)
                        self.sellerEvaluationLabel.text = "商家評價 " + (sellerEvaluationResults[index] as! String)
                        let productImageUrl = imageResults[index] 
                        self.imageURL = imageResults[index] as? String
                        if let imageUrl = URL(string: productImageUrl as! String){
                            URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                                if error != nil {
                                    print("Download Image Task Fail: \(error!.localizedDescription)")
                                }
                                else if let imageData = data {
                                    DispatchQueue.main.async { 
                                        self.productImage.image = UIImage(data: imageData)
                                    }
                                }
                                
                            }.resume()
                            
                        }
                    }
                    
                    
                })
            
        }
    }
    
    // FromMyOrder
    func setLabel(productId:String){
        self.ID = productId            
        let productRef = Database.database().reference().child("Product").child(productId)
        productRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let name = value?["ProductName"] as? String ?? ""
            let price = value?["Price"] as? String ?? "" 
            let description = value?["Description"] as? String ?? "" 
            let productEvaluationAll = value?["ProductEvaluationAll"] as? String ?? ""
            let sellerEvaluation = value?["SellerEvaluation"] as? String ?? "" 
            let url = value?["imageURL"] as? String ?? ""
            self.nameLabel.text = name
            self.priceLabel.text = price
            self.descriptionLabel.text = "產品描述 " + description
            self.evaluationLabel.text = "產品評價 " + productEvaluationAll + "星"
            self.sellerEvaluationLabel.text = "商家評價 " + sellerEvaluation
            if let imageUrl = URL(string: url){
                URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                    if error != nil {
                        print("Download Image Task Fail: \(error!.localizedDescription)")
                    }
                    else if let imageData = data {
                        DispatchQueue.main.async { 
                            self.productImage.image = UIImage(data: imageData)
                        }
                    }
                    
                }.resume()
                
            }
            
            //                  我的最愛
            let likeListRef = Database.database().reference().child("LikeList").child(Auth.auth().currentUser?.uid ?? "")
            likeListRef.child(self.ID).queryOrderedByKey()
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
            
            
            
            
        })
        
    }
    
    
    
    @IBAction func addToCart(_ sender: Any) { // 還沒做加入購物車過了
        ref = Database.database().reference()
        let user = Auth.auth().currentUser!
        
        let newData = ["ProductName" : self.nameLabel.text, "Price" : self.price, "imageURL": self.imageURL,"Status" : "Selected"]
        
        self.ref.child("ShoppingCart").child(user.uid).child(self.ID).setValue(newData)
        
        let message = UIAlertController(title: "加入購物車成功", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
        {action in 
            print(self.nameLabel.text ?? "" + "Add to ShoppingCart")
        })
        
        let shoppingCartAction = UIAlertAction(title: "去我的購物車", style: .default, handler:  {action in 
            self.goToShoppingCart()
            print(self.nameLabel.text ?? "" + "Add to ShoppingCart")
        })
        
        message.addAction(confirmAction)
        message.addAction(shoppingCartAction)
        self.present(message, animated: true, completion: nil)
        
    }
    
    func goToShoppingCart(){
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
                vc.shoppingCount = counts
                self.navigationController?.pushViewController(vc,animated: true)
            }
        })
        
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
    
    @IBAction func LikeButton(_ sender: UIButton) {
        
        let ref = Database.database().reference().child("LikeList").child(Auth.auth().currentUser?.uid ?? "")
        if sender.isSelected  {
            self.likeButton.setImage(UIImage(named : "like-2"), for: UIControl.State.normal)   
            sender.isSelected = false
            let removeRef = ref.child(self.ID).child("Status")
            removeRef.removeValue()
            alertUnLike()
        }
        else{
            self.likeButton.setImage(UIImage(named : "like"), for: UIControl.State.selected)
            sender.isSelected = true
            ref.child(self.ID).child("Status").setValue("Like")
            alertLike()
        }
        
    }
    
}


extension ProductInformationController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return commentCount
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductComment", for: indexPath) as! ProductComment
        if fromShoppingCart == true {
            cell.setLable(index: indexPath.row, productId:   selectProductId[index])
        }
        if fromMyOrder == true{
            cell.setLable(index: indexPath.row, productId: productId)
        }
        else{
            let productRef = Database.database().reference().child("Product")
            productRef.queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    let id = userSnap.key
                    self.productID.append(id)
                }
                cell.setLable(index: indexPath.row, productId: self.productID[self.index])
            })
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}

extension ProductInformationController: UICollectionViewDelegateFlowLayout{
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
