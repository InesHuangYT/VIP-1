//
//  GroupBuyInformationController.swift
//  vip
//
//  Created by Ines on 2020/3/31.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit

class GroupBuyInformationController: UIViewController {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var productEvaluation: UILabel!
    @IBOutlet weak var sellerEvaluation: UILabel!
    
    @IBOutlet weak var groupBuyImage: UIImageView!
    
    var index  = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("index ",index)
       
    }
    


}
