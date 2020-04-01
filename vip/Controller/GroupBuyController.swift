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
        self.collectionView.reloadData()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "GroupBuyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GroupBuyCollectionViewCell")
        self.setupGridView()
        btnAction()

        
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

}



extension GroupBuyController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {

        return count

    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupBuyCollectionViewCell", for: indexPath) as! GroupBuyCollectionViewCell
//        cell.setProductLabel(text: self.dataProductName[indexPath.row])
        cell.setProductLabel(index: indexPath.row)
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as!  GroupBuyInformationController
        vc.index = indexPath.row        
        self.navigationController?.pushViewController(vc,animated: true)

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
