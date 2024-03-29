//
//  MainController.swift
//  vip
//
//  Created by Chun on 2020/3/16.
//  Copyright © 2020 Ines. All rights reserved.
//
//Speech:https://www.appcoda.com.tw/siri-speech-framework/
// hide keyboard https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift

import UIKit
import Firebase
import Speech
import AVFoundation

class ViewController: UIViewController ,SFSpeechRecognizerDelegate{
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var groupBuyButton: UIButton!
    @IBOutlet weak var shppingCartButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_TW")) //"en-US"
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    
    var audioPlayer: AVAudioPlayer?
    let Sound = URL(fileURLWithPath: Bundle.main.path(forResource: "Easy Lemon 30 Second", ofType: "mp3")!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        setupTextField()
        hideKeyboardWhenTappedAround() 
        ifNewUser()
        
    }
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func setupTextField(){
        searchTextField.delegate = self
        let tapOnScreen :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapOnScreen)
    }
    
    @objc private func hideKeyboard(){
        searchTextField.resignFirstResponder()
    }
    
    func ifNewUser(){
        let ref = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("Profile")
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let phone = value?["phone"] as? String ?? "" 
            let newUser = value?["newUser"] as? String ?? "" 
            print("newUser",newUser)
            print("phone",phone)

            
            if newUser == "true"{
                let alert = UIAlertController(title: "親愛的使用者您好，歡迎使用VIP，我們將提供商品語音自動播放服務，是否需要立即幫您開啟即可享受商品自動播放語音廣告服務", message: "", preferredStyle: .alert)
                let openAction = UIAlertAction(title: "開啟自動播放服務", style: .default, handler: { (action) in
                    ref.child("autoPlay").setValue("true")
                })
                let noAction = UIAlertAction(title: "之後再使用", style: .cancel, handler: { (action) in
                    ref.child("autoPlay").setValue("false")
                })
                alert.addAction(openAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            }
             ref.child("newUser").setValue("false")
            
        })
        
        
    }
    
    func microphoneaccess(){
        microphoneButton.isEnabled = false
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    func audioPlay(){
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: Sound)
        audioPlayer?.play()
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
        microphoneaccess()
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionTask?.cancel()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle( "開始語音輸入", for: .normal)
            microphoneButton.setImage(UIImage(named: "microphone"), for: .normal)
        } else {
            try! audioPlayer = AVAudioPlayer(contentsOf: Sound)
            audioPlayer?.play()
            
            startRecording()
            microphoneButton.setTitle( "語音輸入完成", for: .normal)
            microphoneButton.setImage(UIImage(named: "microphone-2"), for: .normal)
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        //        else {
        //        fatalError("Audio engine has no input node")
        //    }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.searchTextField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    
    
    
    
    
    @IBAction func callservice(_ sender: Any) {
        if let callURL:URL = URL(string: "tel:\(886961192398)") {
            
            let application:UIApplication = UIApplication.shared
            
            if (application.canOpenURL(callURL)) {
                let alert = UIAlertController(title: "撥打客服專線", message: "", preferredStyle: .alert)
                let callAction = UIAlertAction(title: "是", style: .default, handler: { (action) in
                    application.openURL(callURL)
                })
                let noAction = UIAlertAction(title: "否", style: .cancel, handler: { (action) in
                    print("Canceled Call")
                })
                
                alert.addAction(callAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func groupBuyButtonWasPresed(_ sender: Any) {
        Database.database().reference().child("GroupBuy")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value, with: { snapshot in
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
    
    @IBAction func shoppingCartButtonWasPressed(_ sender: Any) {
        
        let ref = Database.database().reference().child("ShoppingCart").child(Auth.auth().currentUser!.uid)
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let storyboard: UIStoryboard = UIStoryboard(name: "ShoppingCart", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ShoppingCart") as! ShoppingCartController
            print("snapshot",snapshot.exists())
            if (snapshot.exists()==false){
                
                vc.shoppingCount = 0
                self.navigationController?.pushViewController(vc,animated: true)
            }else{
                let allKeys = snapshot.value as! [String : AnyObject] 
                let nodeToReturn = allKeys.keys
                let counts = nodeToReturn.count
                print("nodeToReturn ",nodeToReturn)
                print("counts ",counts)
                
                
                vc.shoppingCount = counts
                self.navigationController?.pushViewController(vc,animated: true)
            }
        })
    }
    
    @IBAction func enterButtonPressed(_ sender: UIButton) {
        let productRef =  Database.database().reference().child("Product")
        let searchText = searchTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let storyboard = UIStoryboard(name: "Product", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProductControllerId") as!  ProductController
        print("searchText",searchText)
        if searchText != ""{
            print("here",searchText)
            
            productRef.queryOrdered(byChild: "ProductName").queryStarting(atValue: searchText).queryEnding(atValue: searchText + "\u{f8ff}").observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.children.allObjects as! [DataSnapshot]
                let count = data.count
                for child in data {
                    print(child.key) 
                    vc.searchId.append(child.key)
                }
                vc.count = count
                vc.fromSearch = true
                self.navigationController?.pushViewController(vc,animated: true)
            })
            
            
        }
        
    }
    
    //    下面的程式 會導致後面要加入團購或是開團購時，一直導回 GroupBuyController Scene *(.observe)
    //        Database.database().reference().child("GroupBuy").observe(.value, with: { 
    //            (snapshot) in 
    //            let allKeys = snapshot.value as! [String : AnyObject]
    //            let nodeToReturn = allKeys.keys
    //            let counts = nodeToReturn.count
    //            print("nodeToReturn ",nodeToReturn)
    //            let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
    //            let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyControllerId") as! GroupBuyController
    //            vc.count = counts
    //            self.navigationController?.pushViewController(vc,animated: true)
    //            
    //        })
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension ViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false            
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

