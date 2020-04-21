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
    
    var imageURL : String!
    var productID:[String] = []
    var ID:String!
    var audioPlayer: AVAudioPlayer?
    
    var selectProductId = [String]()
    var fromShoppingCart = false
    var fromCheckOut = false
    var price = String()
    
    var index  = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("index",index)
        setLabel(index: index,selectProductId:selectProductId)
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        productImage.layer.cornerRadius = 45
        productImage.layer.borderWidth = 1
        productImage.layer.borderColor = myColor.cgColor
        productImage.image = UIImage(named:"logo")
        
        btnAction()
        audioPlay()
        
        if(fromShoppingCart == true) {
            addShoppingCart.isHidden = true
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
            productRef.child(selectProductId[index]).queryOrderedByKey()
                .observeSingleEvent(of: .value, with: { snapshot in
                    let value = snapshot.value as? NSDictionary
                    let name = value?["ProductName"] as? String ?? ""
                    let price = value?["Price"] as? String ?? ""
                    let description = value?["Description"] as? String ?? ""
                    let productEvaluation = value?["ProductEvaluation"] as? String ?? ""
                    let sellerEvaluation = value?["SellerEvaluation"] as? String ?? ""
                    self.nameLabel.text = name
                    self.priceLabel.text = price + "元"
                    self.descriptionLabel.text = "產品描述 " + description
                    self.evaluationLabel.text = "產品評價 " + productEvaluation
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
                            ($0.value as! [String: Any])["ProductEvaluation"]
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
    
    @IBAction func LikeButton(_ sender: UIButton) {
        if sender.isSelected{
            print("Like Button Selected!")
            sender.isSelected = false
        }else{
            sender.isSelected = true
        }
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
    
    
    
    
    
    
}
