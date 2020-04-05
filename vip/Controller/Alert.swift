//
//  Alert.swift
//  vip
//
//  Created by rourou on 05/04/2020.
//  Copyright © 2020 Ines. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    func showAlert(title: String, message: String, handlerOK:((UIAlertAction) -> Void)?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: handlerOK)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
