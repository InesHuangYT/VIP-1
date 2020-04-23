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
        
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
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
