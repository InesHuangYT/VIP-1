//
//  MainController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var groupBuyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
        setupTextField()

    }
    private func setupTextField(){
        searchTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func hideKeyboard(){
        searchTextField.resignFirstResponder()
    }
    
    @IBAction func groupBuyButtonWasPresed(_ sender: Any) {
        Database.database().reference().child("GroupBuy").observe(.value, with: { 
            (snapshot) in 
            let allKeys = snapshot.value as! [String : AnyObject]
            let nodeToReturn = allKeys.keys
            let counts = nodeToReturn.count
            print("nodeToReturn ",nodeToReturn)
            let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyControllerId") as! GroupBuyController
            vc.count = counts
            self.navigationController?.pushViewController(vc,animated: true)
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
