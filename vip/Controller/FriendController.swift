//
//  FriendController.swift
//  vip
//
//  Created by Ines on 2020/6/9.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit

class FriendController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var time: UIButton!
    @IBOutlet weak var price: UIButton!
    @IBOutlet weak var relation: UIButton!
    @IBOutlet weak var type: UIButton!
    let transparentView = UIView()
    let tableViews = UITableView()
    var sources = [String]()
    var selectButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        delegate()
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func delegate(){
        
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
            self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.sources.count * 50) )
        }, completion: nil)
    }
    @objc func removeTransparent(){
        let frames = time.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.transparentView.alpha = 0
                        self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @IBAction func timeB(_ sender: Any) {
        sources = ["6月21日","6月22日","6月23日","6月24日","6月25日"]
        selectButton = time
        addTransparent(frames: time.frame)
    }
    
    @IBAction func priceB(_ sender: Any) {
        sources = ["100-500元","500-1000元","1000-2000元","2000-3000元"]
        selectButton = price
        addTransparent(frames: price.frame)
        
    }
    @IBAction func relationB(_ sender: Any) {
        sources = ["情人","朋友","夫妻","姐妹","兄弟"]
        selectButton = relation
        addTransparent(frames: relation.frame)
    }
    @IBAction func typeB(_ sender: Any) {
        sources = ["實用","文青","娛樂","運動","音樂"]
        selectButton = type
        addTransparent(frames: type.frame)
    }
    
    @IBAction func check(_ sender: Any) {
        
    }
    
}
extension FriendController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViews.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sources[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectButton.setTitle(sources[indexPath.row], for: .normal)
        let cell = tableViews.cellForRow(at: indexPath) // 得知點選哪一個cell
        print("cell:",cell?.textLabel?.text! ?? 0)
        removeTransparent()
    }
}
