//
//  HomeController.swift
//  vip
//
//  Created by Ines on 2020/2/19.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import Firebase

class CellClass : UITableViewCell{
    
}
class HomeController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var selectDeliverWayButton: UIButton!
    @IBOutlet weak var selectPaymentWayButton: UIButton!
    @IBOutlet weak var signUpConfirm: UIButton!
    
    @IBOutlet weak var currentUserlabel: UILabel!

    @IBOutlet weak var phoneTextField: UITextField!
    
    var waySources = [String]()
    var selectText = String()
    var selectButton = UIButton()
    let transparentView = UIView()
    let tableViews = UITableView()
//    var selectedButton = UIButton()
    var uid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViews.delegate = self
        tableViews.dataSource = self
        tableViews.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        // To hideKeyboard
        phoneTextField.delegate = self
        
        print("current user uidd : " , currentUserName())
     }
    
    // To hideKeyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
    }

    
    
    func currentUserName()->(String){
        if let user = Auth.auth().currentUser{
            uid = user.uid
            print("uid : ",uid)
            currentUserlabel.text = " login uid is : " + (uid)
        }
        return(uid)

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
        let frames = selectDeliverWayButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: { 
                        self.transparentView.alpha = 0
                        self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
    }
    
       
    
    @IBAction func deliverWaysWasPressed(_ sender: Any) {
        waySources = ["宅配","711","全家便利商店"]
        selectButton = selectDeliverWayButton
        selectText = "deliverWays"
        addTransparent(frames: selectDeliverWayButton.frame)
    }
    
    @IBAction func paymentWaysWasPressed(_ sender: Any) {
        waySources = ["貨到付款","信用卡/VISA","線上支付","銀行轉帳"]
        selectButton = selectPaymentWayButton
        selectText = "paymentWays"
        addTransparent(frames: selectPaymentWayButton.frame)
    }
    


    
    @IBAction func signUpConfirmWasPressed(_ sender: Any) {
        var error = ""
        if phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            error = "請輸入手機號碼"
            print(error)
        }else{
            let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            Database.database().reference(withPath:"users/\(self.uid)/Profile/phone").setValue(phone)
        }
         Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
        .child("Profile")
        .queryOrderedByKey()
        .observeSingleEvent(of: .value, with: { snapshot in 
            guard let value = snapshot.value as? [String:Any] else{
                print("Error")
                return
            }
            
            if (value["way"] as? String) == "google"{
                let message = UIAlertController(title: "您已註冊成功", message: "", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "確認", style: .default, handler: {action in 
                    print("here go to profile page!")
                    self.transitionToProfileScene()

                })
                message.addAction(confirmAction)
                self.present(message, animated: true, completion: nil)

            }else{
                let message = UIAlertController(title: "註冊成功", message: nil, preferredStyle: .alert)
                       let confirmAction = UIAlertAction(title: "返回登入頁面", style: .default, handler:
                       {action in 
                           print("here need to return login page!")
                           self.transitionToLogInScene()
                       })
                       message.addAction(confirmAction)
                       self.present(message, animated: true, completion: nil)
            }
            
        })
        
       
    }
    
    //  go to logIn step
        func transitionToLogInScene(){
            let storyboard = UIStoryboard(name: "SignUpLogIn", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "LogInControllerId") as! LogInController
            self.navigationController?.pushViewController(vc,animated: true)
        }
    func transitionToProfileScene(){
               let storyboard = UIStoryboard(name: "Profile", bundle: nil)
               let vc = storyboard.instantiateViewController(withIdentifier: "ProfileControllerId") as! ProfileController
               self.navigationController?.pushViewController(vc,animated: true)
           }
        
    

    
}



extension HomeController : UITableViewDelegate, UITableViewDataSource{
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
        
        Database.database().reference(withPath: "users/\(self.uid)/Profile/\(selectText)").setValue(cell?.textLabel?.text!)
        removeTransparent()
    }
}




