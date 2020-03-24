//
//  SignUpViewController.swift
//  vip
//
//  Created by Ines on 2020/2/17.
//  Copyright © 2020 Ines. All rights reserved.
// Swift - 告警提示框（UIAlertController）的用法 https://www.hangge.com/blog/cache/detail_651.html

import UIKit
import FirebaseAuth
import Firebase

class SignUpController: UIViewController {
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var uid = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        if let user = Auth.auth().currentUser{
                   uid = user.uid
               }
    }
    
    // To hideKeyboard
    private func setupTextField(){
        accountTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
        nameTextField.delegate = self
         
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
   }
    
    @objc private func hideKeyboard(){
        accountTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordConfirmTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
      }

    @IBAction func signUpConfirmTap(_ sender: Any) {
        
//        validate the fields
        let error = validateField()
        if error != nil{
            //something wrong with text fields, show error message
            showError(error!)
            print("error here: ",error!)
        }else{
            let account = accountTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
           
            
//        create the user 
            Auth.auth().createUser(withEmail: account, password: password) {(result,err) in 
                if err != nil{
                    print("here err ! ",err as Any)
                    self.showError("Error with account form, must be email form")
                    
                }else{
                    
                    if let user = Auth.auth().currentUser{
                        self.uid = user.uid
                        print("self.uid: ",self.uid)
                    }
                    print("Successfully signed up")
                    Database.database().reference(withPath: "users/\(self.uid)/Profile/account").setValue(account)
                    Database.database().reference(withPath: "users/\(self.uid)/Profile/password").setValue(password)
                    Database.database().reference(withPath: "users/\(self.uid)/Profile/name").setValue(name)
                    Database.database().reference(withPath: "users/\(self.uid)/Profile/way").setValue("directly")
                   
                        self.transitionToOtherScene()
                   

                      
                }
                
            }
        }

    }
    
    
// check if signUp all fit the format
    func validateField() -> String? {
        
        //check that all fields are filled in  
        if accountTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordConfirmTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "請輸入全部空格！"
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isPasswordValid(cleanedPassword) == false{
            return "密碼長度至少為6"
        }
        if passwordTextField.text != passwordConfirmTextField.text{
            
            return "密碼不一致"
        }
        return nil
    }
    
    
//   if password is secured
    func isPasswordValid(_ password : String) -> Bool{
//       at least more that eight charaters && at least one alphabet https://stackoverflow.com/questions/39284607/how-to-implement-a-regex-for-password-validation-in-swift
//        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")
        let passwordTest = NSPredicate(format: "SELF MATCHES %@","^[0-9A-Za-z]{6,16}$")
        return passwordTest.evaluate(with: password)
    }
    
//   error message
    func showError(_ message : String){
        errorLabel.text = message
        errorLabel.textColor = UIColor.red
//        errorLabel.alpha = 1
    }
    
//  go to next step
    func transitionToOtherScene(){
        let storyboard = UIStoryboard(name: "SignUpLogIn", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeControllerId") as! HomeController
        self.navigationController?.pushViewController(vc,animated: true)
    }
    
}

extension SignUpController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
 }
}
