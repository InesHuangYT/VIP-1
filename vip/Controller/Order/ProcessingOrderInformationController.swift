//
//  ProcessingOrderInformationController.swift
//  vip
//
//  Created by Ines on 2020/4/22.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase 

class ProcessingOrderInformationController: UIViewController {
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
    }
    
    
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
}
