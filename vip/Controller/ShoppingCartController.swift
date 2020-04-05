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
    var count = Int()
    var name:[Any] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        let user = Auth.auth().currentUser!
        
        DispatchQueue.main.async {
        self.ref.child("ShoppingCart").child(user.uid).observeSingleEvent(of: .value, with: { snapshot in
                if let data = snapshot.children.allObjects as? [DataSnapshot] {
                let retriName = data.compactMap({($0.value as! [String:Any])["ProductName"]})
                self.name = retriName
                    
            }
            
        })
            self.tableView.reloadData()
        }
        print("num ITEM = ", self.name.count)
        
//        print("ViewCount2 self.count= ", self.count)
//        print("ViewCount2 = ", count)
//
        
        //        self.tableView.delegate = self
        //        self.tableView.dataSource = self
        
    }
    
    
    
   
   
    
    func numberOfSectionInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
               
        return name.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ShoppingCartCell
        cell.loadData(index: indexPath.row)
        
        return cell
    }
    
    
    @IBAction func OrderBtn(_ sender: Any) {
    }
    
    @IBAction func DeleteBtn(_ sender: Any) {
    }
    
    
}
