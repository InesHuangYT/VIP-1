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
                    print(snapshot.children.allObjects)
//                    print("SNAP key:",snapshot.)
                    if let data = snapshot.children.allObjects as? [DataSnapshot] {
//                        let retriId = data.
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        return cell
    }
    

    @IBAction func OrderBtn(_ sender: Any) {
    }
    
    @IBAction func DeleteBtn(_ sender: Any) {
    }
    
    
}
