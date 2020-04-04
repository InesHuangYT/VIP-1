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
    let image : String?
    let productName : String?
    let price : String?
}

class ShoppingCartController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var data = [CellData]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        super.viewDidLoad()
        data = [CellData.init(image: "image", productName: "name", price: "$150")]
    }
   
    func loadData(){
        
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
