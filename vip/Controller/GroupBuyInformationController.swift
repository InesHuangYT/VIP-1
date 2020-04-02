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
    var users = Auth.auth().currentUser?.displayName
    var openByCount = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.reloadData()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "GroupBuyJoinCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyJoinCollectionViewCell")
        btnAction()
        self.setupGridView()
        setLabel(index:index)
        let myColor : UIColor = UIColor( red: 137/255, green: 137/255, blue:128/255, alpha: 1.0 )
        groupBuyImage.layer.cornerRadius = 45
        groupBuyImage.layer.borderWidth = 1
        groupBuyImage.layer.borderColor = myColor.cgColor
    }

    func btnAction(){
              btnMenu.target = self.revealViewController()
              btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
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
    
    @IBAction func groupBuyOpenButtonWasPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyOpenControllerId") as!  GroupBuyOpenController
        Database.database().reference(withPath: "users/\(self.uid ?? "wrong message : no currentUser")/GroupBuy/\(self.productId)").setValue(self.productId)
        Database.database().reference(withPath: "GroupBuy/\(self.productId)/openedBy/\(String(self.uid!))").setValue(self.users)
        print((self.users ?? "") + " 開團 ")
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
    
    
}


extension GroupBuyInformationController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupBuyJoinCollectionViewCell", for: indexPath) as! GroupBuyJoinCollectionViewCell
        cell.setProductLabel(productId: self.productId )
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        vc.index = indexPath.row        
        self.navigationController?.pushViewController(vc,animated: true)

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
