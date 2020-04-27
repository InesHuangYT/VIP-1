//
//  ProductController.swift
//  vip
//
//  Created by Ines on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.

//救命網站 解決UITapGestureRecognizer中断了UITableView didSelectRowAtIndexPath https://www.itranslater.com/qa/details/2122914725183882240

import UIKit
import Firebase


class ProductController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    var estimatedWidth = 130.0
    var cellMarginSize = 23.0
    var ref: DatabaseReference!
    var count = Int()
    var fromSearch = false
    var searchId = [String]()
    var fromCategory = false
    var categoryId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.collectionView.reloadData()
        self.collectionView.delegate = self 
        self.collectionView.dataSource = self
        //        將ProductCollectionViewCell連進來 
        self.collectionView.register(UINib(nibName: "ProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionViewCell")
        self.setupGridView()
        btnAction()
        print("searchId",searchId)
        print("categoryId",categoryId)
        
        
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
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    func findIndex(searchId:String,vc:ProductInformationController){
        let productRef =  Database.database().reference().child("Product")
        
        productRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            productRef.child(searchId).child("ProductEvaluation").observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.children.allObjects as! [DataSnapshot]
                vc.commentCount = data.count
                print("commentCount",data.count)
            })
            let data = snapshot.children.allObjects as! [DataSnapshot]
            for i in 1...data.count {
                if data[i-1].key == searchId {
                    print("find index", i-1)
                    vc.index = i-1
                }else{
                    print("Not find index", i-1)
                }
            }
            self.navigationController?.pushViewController(vc,animated: true)
            
        })
        
    }
    
}


extension ProductController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        //        let productCount = Database.database().reference().child("Product").key?.count 
        //        新增商品後不會自動更新，改用前類別頁傳值
        return count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        if fromSearch == true {
            cell.setProductLabel(productId: searchId[indexPath.row])
        }
        else if fromCategory == true {
            cell.setProductLabel(productId: categoryId[indexPath.row])
        }
        else {
            cell.setProductLabel(index: indexPath.row)
        }
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
        
        if fromSearch == true {
            print("csearchId[indexPath.row]",searchId[indexPath.row])
            
            findIndex(searchId: searchId[indexPath.row],vc:vc)
            
        }
        else if fromCategory == true {
            print("categoryId[indexPath.row]",categoryId[indexPath.row])
            findIndex(searchId: categoryId[indexPath.row],vc:vc)
        }
            
        else{
            vc.index = indexPath.row        
            self.navigationController?.pushViewController(vc,animated: true)
            
        }
        
        
    }
}

extension ProductController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*1.25)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}
extension ProductController: UISearchBarDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
}
