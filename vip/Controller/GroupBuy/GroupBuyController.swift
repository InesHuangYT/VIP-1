//
//  GroupByController.swift
//  vip
//
//  Created by Ines on 2020/3/30.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class GroupBuyController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    var ref: DatabaseReference!
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    var count = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewDeclare()
        self.setupGridView()
        btnAction()
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
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "GroupBuyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyCollectionViewCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
}



extension GroupBuyController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupBuyCollectionViewCell", for: indexPath) as! GroupBuyCollectionViewCell
        cell.setProductLabel(index: indexPath.row)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        vc.index = indexPath.row   
        let groupBuyRef =  Database.database().reference().child("GroupBuy")
        
        groupBuyRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                if let datas = snapshot.children.allObjects as? [DataSnapshot] {
                    print("key:" ,datas[indexPath.row].key)
                    
                    groupBuyRef.child(datas[indexPath.row].key).child("ProductEvaluation").observeSingleEvent(of: .value, with: { (snapshot) in
                        let data = snapshot.children.allObjects as! [DataSnapshot]
                        vc.commentCount = data.count
                        print("commentCount",data.count)
                    })
                    vc.productId = datas[indexPath.row].key
                    
                    let groupBuyPeople = datas.compactMap({
                        ($0.value as! [String: Any])["GroupBuyPeople"]
                    }) 
                    let people = groupBuyPeople[indexPath.row] as! String
                    let peoples = Int64(people)
                    vc.groupBuyPeople = Int(peoples ?? 0) 
                    
                    Database.database().reference().child("GroupBuy").child(datas[indexPath.row].key).child("OpenGroupId")
                        .queryOrderedByKey()
                        .observeSingleEvent(of: .value, with: { snapshot in 
                            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                                
                                print("GroupBuy key count : ",snapshots.count)
                                vc.openByCount = snapshots.count
                                self.navigationController?.pushViewController(vc,animated: true)
                                
                            }
                        })
                }
            })
        
        
        
    }
}

extension GroupBuyController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.5)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}

extension GroupBuyController: UISearchBarDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
}
