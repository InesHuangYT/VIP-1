//
//  OrderComfirmController.swift
//  vip
//
//  Created by Chun on 2020/4/5.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit

class OrderComfirmController: UIViewController {
    var productId = String()

    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    
    
}
