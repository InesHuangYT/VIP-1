//
//  CategoryController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class CategoryController: UIViewController {

    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var popularProduct: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    @IBAction func popularProductWasPresed(_ sender: Any) {
        Database.database().reference().child("Product").observe(.value, with: { 
            (snapshot) in 
            let allKeys = snapshot.value as! [String : AnyObject]
            let nodeToReturn = allKeys.keys
            let counts = nodeToReturn.count
            print("nodeToReturn ",nodeToReturn)
            let storyboard = UIStoryboard(name: "Product", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProductControllerId") as!  ProductController
            vc.count = counts
            self.navigationController?.pushViewController(vc,animated: true)
        })
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
