//
//  ShoppingCartController.swift
//  vip
//
//  Created by rourou on 03/03/2020.
//  Copyright © 2020 Ines. All rights reserved.
//

import Foundation
import UIKit
import Firebase


struct CellData{
    let id : String?
    let image : String?
    let productName : String?
    let price : String?
}

class ShoppingCartController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference!
    var Data = [CellData]()
    var test:UILabel!
    var numCell:Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
        super.viewDidLoad()
//        data = [CellData.init(image: "image", productName: "name", price: "$150")]
    }
   
    func loadData(){
        Database.database().reference().child("ShoppingCart")
                  .observeSingleEvent(of: .value, with: { snapshot in
                    
                    if let data = snapshot.children.allObjects as? [DataSnapshot] {
//                        let retriId = data.
                        self.numCell = data.count
                        let retriName = data.compactMap({($0.value as! [String:Any])["ProductName"]})
                        print("retriName:",retriName)
                        
                        
                    }
                    
                    
          
         

          
          })
    }
    
    func numberOfSectionInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        //Count Products
        return self.numCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ShoppingCartCell
        cell.ProductName.text = ""
        cell.Price.text = ""
        
        
        return cell
    }
    

    @IBAction func OrderBtn(_ sender: Any) {
    }
    
    @IBAction func DeleteBtn(_ sender: Any) {
    }
    
    
}
