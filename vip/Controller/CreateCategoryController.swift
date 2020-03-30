//
//  CreateCategoryController.swift
//  vip
//
//  Created by Ines on 2020/3/31.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit



class CreateCategoryController: UIViewController {
    
    @IBOutlet weak var categoryButton: UIButton!
    let transparentView = UIView()
    let tableViews = UITableView()
    var waySources = [String]()
    var selectButton = UIButton()
    var selectText = String()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViews.delegate = self
        tableViews.dataSource = self
        tableViews.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
    }
    
    func addTransparent(frames:CGRect){
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)  
        self.view.addSubview(tableViews)
        tableViews.layer.cornerRadius = 8
        tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y, width: frames.width, height: 0)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableViews.reloadData()
        let tapGesture = UITapGestureRecognizer(target: self
            , action: #selector(removeTransparent))
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: { 
            self.transparentView.alpha = 0.5
            self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.waySources.count * 50) )
        }, completion: nil)
        
    }
    
    @objc func removeTransparent(){
        let frames = categoryButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { 
                        self.transparentView.alpha = 0
                        self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @IBAction func categoryWasPressed(_ sender: Any) {
        waySources = ["熱銷商品","視覺相關","美妝保養","美食甜點","3C家電","日用品","媽咪親子","居家生活"]
        selectButton = categoryButton
        selectText = "Category"
        addTransparent(frames: categoryButton.frame)
    }
}

extension CreateCategoryController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waySources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViews.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = waySources[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectButton.setTitle(waySources[indexPath.row], for: .normal)
        // selectDeliverWayButton.setTitle(cell?.textLabel?.text, for: .normal) --other way
        let cell = tableViews.cellForRow(at: indexPath) // 得知點選哪一個cell
        print("cell:",cell?.textLabel?.text! ?? 0)
        let storyboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateProductData") as!  CreateProductDataController
        vc.productCategory = waySources[indexPath.row]
        self.navigationController?.pushViewController(vc,animated: true)
        removeTransparent()
    }
    
    
}









