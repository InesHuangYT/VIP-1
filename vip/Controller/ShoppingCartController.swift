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




class ShoppingCartController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference!
    var test:UILabel!
    var numCell:Int!
    var name:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        print("lookup name = ", self.name)
        //        data = [CellData.init(image: "image", productName: "name", price: "$150")]
    }
    
    func loadData(){
        ref = Database.database().reference()
        let user = Auth.auth().currentUser!
        let queue = DispatchQueue(label: "com.appcoda.myqueue")
        queue.sync {
            self.ref.child("ShoppingCart").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                if let data = snapshot.children.allObjects as? [DataSnapshot] {
                    print(data)
                    let retriName = data.compactMap({($0.value as! [String:Any])["ProductName"]})
                    print("retriName:",retriName)
                    let retriprice = data.compactMap({($0.value as![String:Any])["Price"]})
                    let imageURL = data.compactMap({
                        ($0.value as! [String: Any])["imageURL"]
                    })
                    self.name = retriName as! [String]
                    
                }
                
            })
        }
        
        
    }
    
    func numberOfSectionInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        return 3
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
