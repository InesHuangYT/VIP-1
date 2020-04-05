//
//  CouponController.swift
//  vip
//
//  Created by Chun on 2020/3/17.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class CouponController: UIViewController {

    let ref =  Database.database().reference()
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var head: UILabel!
    @IBOutlet weak var body: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        
        ref.child("coupon").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let id = value?.allKeys
            self.ref.child("coupon").child(id?[0] as! String)
                       .queryOrderedByKey()
                       .observeSingleEvent(of: .value, with: { snapshot in 
                           guard let values = snapshot.value as? [String:Any]
                               else {
                                   print("Error")
                                   return
                           }
                        print("values : " , values)

                        self.setLabel(value: values )
                       })
            
        }
       
    )}
    func setLabel(value:[String:Any]){
        let first = value["head"] as? String
        let second = value["body"] as? String
        head.text = first
        body.text = second

    }
    
}
