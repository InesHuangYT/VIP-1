//
//  OrderController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit

class OrderController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func transitionToMyGroupBuyScene(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "GroupBuy", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MyGroupBuyControllerId") as! MyGroupBuyController
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
}
