//
//  SignUpController.swift
//  vip
//
//  Created by Ines on 2020/2/17.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LogInController: UIViewController,GIDSignInDelegate {
 
    

//    UITextField
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
//    UILabel
    @IBOutlet weak var errorLabel: UILabel!
//    UIButton
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var forgetPasswordButtin: UIButton!
    @IBOutlet weak var googleConnectionButton: GIDSignInButton!
   
//    var
    var uid = ""
    var account = ""
    var userName = ""
    
    //properties
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        GIDSignIn.sharedInstance().delegate = self
        if let user = Auth.auth().currentUser{
            uid = user.uid            
        }
        
    }
    
    //private function 
    private func setupTextField(){
        accountTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    //actions
    @objc private func hideKeyboard(){
        accountTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @IBAction func signUpButtonWasPressed(_ sender: UIButton) {
    }
    
    @IBAction func logInButtonWasPressed(_ sender: UIButton) {
        let account = accountTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: account, password: password) { (result, error) in
            
            if error != nil{
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.textColor = UIColor.red
            }else{
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                self.navigationController?.pushViewController(vc,animated: true)  
            }
            
        }
    }
    
//    connect google button 
    @IBAction func googleConnectionButtonWasPressed(_ sender: Any) {
         GIDSignIn.sharedInstance()?.presentingViewController = self
                GIDSignIn.sharedInstance()?.signIn()
                // Automatically sign in the user.
        if uid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("no uid")
        }else{
            print("uid : ", uid)
        }
//                GIDSignIn.sharedInstance()?.restorePreviousSignIn()
                
    }
    
    @IBAction func forgetPasswordWasPressed(_ sender: Any) {
            
    }
    
    func currentUserName()->(uid: String, account: String, username: String){
        if let user = Auth.auth().currentUser{
            uid = user.uid
            account = user.email!
            userName = user.displayName!
            print("uid : ",uid)
            print("userName : ",userName)
            
        }
        return(uid,account,userName)

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!){
            
            if let error  = error {
                print("here is the erro occur : \(error.localizedDescription)")
            }
            else{
                guard let authentication = user.authentication else {return}
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
                Auth.auth().signIn(with: credential) { (authresult, error) in
                    if error != nil{
                        print("faled to signIn and retrieve data with error")
                        return
                    }
                    else{
//                        self.currentUserName()
                        print("start connect googleSignUp data to firebase!")
                        let currentUser = self.currentUserName()
                        let newUid = currentUser.uid
                        let newAcoount = currentUser.account
                        let newUserName = currentUser.username
                        Database.database().reference(withPath: "users/\(newUid)/Profile/account").setValue(newAcoount)
                        Database.database().reference(withPath: "users/\(newUid)/Profile/name").setValue(newUserName)
                         Database.database().reference(withPath: "users/\(newUid)/Profile/way").setValue("google")
                        let storyboard1 = UIStoryboard(name: "SignUpLogIn", bundle: nil)
                        let vc1 = storyboard1.instantiateViewController(withIdentifier: "HomeControllerId") as! HomeController
                        
                        let storyboard2 = UIStoryboard(name: "Main", bundle: nil)
                        let vc2 = storyboard2.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                        Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("Profile")
                            .queryOrderedByKey()
                            .observeSingleEvent(of: .value, with: { snapshot in 
                                guard let value = snapshot.value as? [String:Any]
                                else {
                                    print("Error")
                                    return
                            }
                                if (value["deliverWays"] as? String == nil || value["paymentWays"] as? String == nil) {
                                     self.navigationController?.pushViewController(vc1,animated: true)
                                }else{
                                     self.navigationController?.pushViewController(vc2,animated: true)
                                }                            
                        })
                        
                        
//                        self.present(vc, animated: true, completion: nil)
                               }
                    }
                }
//                let userId = user.userID;                // For client-side use only!
//                let fullName = user.profile.name;
//                let email = user.profile.email;
//                let idToken = user.authentication.idToken; // Safe to send to the server
//
//                print("userId: ":userId!,"fullName: ":fullName!,"email: ":email!,"idToken: ":idToken!)
                
            }
        
        
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!){
       
        // Perform any operations when the user disconnects from app here.
        print("User has diconected!")
        
    }
    
} 

extension LogInController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
}




    
