//
//  MenuViewController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var menuNameArr: Array = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        menuNameArr = ["我的最愛","首頁","類別","團購","我的訂單","購物車","個人資訊"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell") as! MenuTableViewCell
        
        cell.lblMenu.text! = menuNameArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _: SWRevealViewController = self.revealViewController()
        
        let cell: MenuTableViewCell = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        
        if cell.lblMenu.text! == "我的最愛"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "首頁"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "類別"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "CategoryController") as! CategoryController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "團購"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "我的訂單"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "OrderController") as! OrderController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "購物車"
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let desController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let newFrontViewController = UINavigationController.init(rootViewController: desController)
            
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
        
        if cell.lblMenu.text! == "個人資訊"
        {
             let mainStoryboard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
             let desController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileControllerId") as! ProfileController
             let newFrontViewController = UINavigationController.init(rootViewController: desController)
             
             revealViewController().pushFrontViewController(newFrontViewController, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
