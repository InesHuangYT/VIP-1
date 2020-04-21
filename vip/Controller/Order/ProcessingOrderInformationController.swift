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
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var orderCreateTime: UILabel!
    @IBOutlet weak var payTime: UILabel!
    @IBOutlet weak var deliverStartTime: UILabel!
    @IBOutlet weak var deliverArriveTime: UILabel!
    @IBOutlet weak var orderFinishTime: UILabel!
    
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var payWay: UILabel!
    @IBOutlet weak var deliverWay: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    

        override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
    }
    
    
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    
    
    
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
