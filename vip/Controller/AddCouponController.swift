//
//  AddCouponController.swift
//  vip
//
//  Created by Chun on 2020/3/17.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class AddCouponController: UIViewController {

    let ref =  Database.database().reference()
    @IBOutlet weak var head: UITextField!
    @IBOutlet weak var body: UITextField!
    @IBOutlet weak var OK: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func add(_ sender: Any) {
        
        let data = ["head":head.text ?? "NULL", "body":body.text ?? "NULL"]
        self.ref.child("coupon").childByAutoId().setValue(data)
    }
}
