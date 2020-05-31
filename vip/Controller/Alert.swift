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
    
    func alertLike(){
        let message = UIAlertController(title: "已加入我的最愛", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
        {action in 
            print("Add to LikeList")
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func alertUnLike(){
        let message = UIAlertController(title: "已移除我的最愛", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
        {action in 
            print("delete to LikeList")
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    
}

extension UICollectionViewCell {
    
    func alertSelect(delegate: UIViewController?){
        let message = UIAlertController(title: "已取消選取此商品", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
        {action in 
            print("Add to checkOut")
        })
        message.addAction(confirmAction)
        delegate?.present(message, animated: true, completion: nil)
    }
    
    func alertDeselect(delegate: UIViewController?){
        let message = UIAlertController(title: "已選取此商品", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler:
        {action in 
            print("delete to checkOut")
        })
        message.addAction(confirmAction)
        delegate?.present(message, animated: true, completion: nil)
    }
}
