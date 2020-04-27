//
//  CommentController.swift
//  vip
//
//  Created by Chun on 2020/4/25.
//  Copyright © 2020 Chun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import Speech
import AVFoundation

class CommentController: UIViewController ,SFSpeechRecognizerDelegate, UITextFieldDelegate, AVAudioRecorderDelegate{
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectGradeButton: UIButton!
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh_TW")) //"en-US"
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var audioPlayer: AVAudioPlayer?
    let Sound = URL(fileURLWithPath: Bundle.main.path(forResource: "Easy Lemon 30 Second", ofType: "mp3")!)
    
    var estimatedWidth = 300.0
    var cellMarginSize = 16.0
    
    var gradeSources = [String]()
    var selectButton = UIButton()
    let transparentView = UIView()
    let tableViews = UITableView()
    var productIdString = String()
    var productIdStringAll = [String]()
    var orderIds = String()
    var fromGroupBuy = false
    var uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        
        collectionViewDeclare()
        setupGridView()
        
        tableViews.delegate = self
        tableViews.dataSource = self
        tableViews.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        commentTextField.delegate = self
        
        print(productIdString)
        print("orderIds" , orderIds)
    }
    
    
    @IBAction func servicecall(_ sender: Any) {
        if let callURL:URL = URL(string: "tel:\(+886961192398)") {
            
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
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    func microphoneaccess(){
        microphone.isEnabled = false
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
                self.microphone.isEnabled = isButtonEnabled
            }
        }
    }
    
    func audioPlay(){
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: Sound)
        audioPlayer?.play()
    }
    
    //cell
    func collectionViewDeclare(){
        self.collectionView.reloadData()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CommentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CommentCollectionViewCell")
    }
    
    func setupGridView(){
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
    }
    
    //grade button
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
            self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.gradeSources.count * 50) )
        }, completion: nil)
    }
    
    @objc func removeTransparent(){
        let frames = selectGradeButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0,
                       options: .curveEaseInOut, animations: {
                        self.transparentView.alpha = 0
                        self.tableViews.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    @IBAction func grade(_ sender: Any) {
        gradeSources = ["1分","2分","3分","4分","5分"]
        selectButton = selectGradeButton
        addTransparent(frames: selectGradeButton.frame)
    }
    
    //record button
    @IBAction func record(_ sender: Any) {
        microphoneaccess()
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionTask?.cancel()
            recognitionRequest?.endAudio()
            microphone.isEnabled = false
            microphone.setTitle( "開始錄音", for: .normal)
            microphone.setImage(UIImage(named: "microphone"), for: .normal)
        } else {
            try! audioPlayer = AVAudioPlayer(contentsOf: Sound)
            audioPlayer?.play()
            
            startRecording()
            microphone.setTitle( "錄音完成", for: .normal)
            microphone.setImage(UIImage(named: "microphone-2"), for: .normal)
        }
    }
    
    //speech to text
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
                
                self.commentTextField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphone.isEnabled = true
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
            microphone.isEnabled = true
        } else {
            microphone.isEnabled = false
        }
    }
    
    //keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //down button
    @IBAction func comfirmButtonPressed(_ sender: Any) {
        let commemtText = commentTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = UIAlertController(title: "是否保存文字檔評論", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "是", style: .default, handler:
        {action in
            if self.fromGroupBuy == false {
                Database.database().reference(withPath: "Product/\(self.productIdString)/ProductEvaluation/\(self.uid ?? "")/comment").setValue(commemtText)
                self.comfirmAlert()
            }else{
                Database.database().reference(withPath: "GroupBuy/\(self.productIdString)/ProductEvaluation/\(self.uid ?? "")/comment").setValue(commemtText)
                self.comfirmAlert()
            }
            
        })
        
        let commentCartAction = UIAlertAction(title: "否", style: .default, handler:  {action in
            self.comfirmAlert()
        })
        
        message.addAction(confirmAction)
        message.addAction(commentCartAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func comfirmAlert(){
        let message2 = UIAlertController(title: "評論成功", message: nil, preferredStyle: .alert)
        let confirmAction2 = UIAlertAction(title: "回首頁", style: .default, handler:
        {action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as!  ViewController
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        let commentCartAction2 = UIAlertAction(title: "繼續評論其他商品", style: .default, handler:  {action in
            let storyboard: UIStoryboard = UIStoryboard(name: "Order", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentAllController") as! CommentAllController
            
            vc.orderIds = self.orderIds //要給 Comment Controller用
            
            if self.fromGroupBuy == false {
                self.checkIfProductCommentBefore(vc:vc)
            }else{
                self.checkIfGroupCommentBefore(vc:vc)
            }
        })
        
        message2.addAction(confirmAction2)
        message2.addAction(commentCartAction2)
        self.present(message2, animated: true, completion: nil)
    }
    
    
    func checkIfProductCommentBefore(vc:CommentAllController){
        let orderRef = Database.database().reference().child("ProductOrder").child(orderIds)
        orderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            let value = snapshot.value as? NSDictionary
            let comment = value?["Comment"] as? String
            print("comment",comment ?? "")      
            if comment == "false"{
                vc.productIdString = self.productIdStringAll
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                orderRef.child("CommentProductId").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
                    let value = snapshot.value as? NSDictionary
                    var needComment = [String]()
                    for i in self.productIdStringAll {
                        let commentProductId = value?[i] as? String
                        if commentProductId == nil { //沒評論過
                            print("沒評論過",i )
                            needComment.append(i)
                        }
                    }
                    
                    print("needComment 沒評論過的有",needComment)
                    vc.productIdString = needComment
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                })
            }
        })
        
    }
    
    func checkIfGroupCommentBefore(vc:CommentAllController){
           let orderRef = Database.database().reference().child("GroupBuyOrder").child(orderIds)
           orderRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
               let value = snapshot.value as? NSDictionary
               let comment = value?["Comment"] as? String
               print("comment",comment ?? "")      
               if comment == "false"{
                   vc.productIdString.append(self.productIdString)
                   self.navigationController?.pushViewController(vc, animated: true)
               }else{
                   self.navigationController?.pushViewController(vc, animated: true)
               }
           })
       }
    
    
    
    func findIndex(selectProductId:String,vc:GroupBuyInformationController){
           let productRef =  Database.database().reference().child("GroupBuy")
           productRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
               let data = snapshot.children.allObjects as! [DataSnapshot]
               
               for i in 1...data.count {
                   if data[i-1].key == selectProductId {
                       print("find index", i-1)
                       vc.index = i-1
                       
                   }else{
                       print("Not find index", i-1)
                   }
               }
           
               self.navigationController?.pushViewController(vc,animated: true)
               
               
           })
           
       }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Order", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentAllController") as!  CommentAllController
        vc.productIdString = productIdStringAll
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CommentController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        
        return 1
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCollectionViewCell", for: indexPath) as! CommentCollectionViewCell
        cell.setLabel(productId:productIdString, fromGroupBuy: fromGroupBuy)
        
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if fromGroupBuy == false {
            let storyboard = UIStoryboard(name: "Product", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProductInformationControllerId") as!  ProductInformationController
            vc.fromMyOrder = true
            vc.productId = productIdStringAll[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            let storyboard = UIStoryboard(name: "GroupBuy", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GroupBuyInformationControllerId") as! GroupBuyInformationController
            vc.productId = productIdString
            vc.from = "CommentController"
            findIndex(selectProductId: productIdString, vc: vc)
            
        }
    }
}

extension CommentController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.calculateWith()
        return CGSize(width: width, height: width*0.5)
    }
    func calculateWith()-> CGFloat{
        let estimateWidth = CGFloat(estimatedWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimateWidth))
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize)*(cellCount-1)-margin)/cellCount
        return width
        
    }
}
extension CommentController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViews.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = gradeSources[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectButton.setTitle(gradeSources[indexPath.row], for: .normal)
        
        let cells = tableViews.cellForRow(at: indexPath) //
        print("cell:",cells?.textLabel?.text! ?? 0)
        
        if fromGroupBuy == false{
            Database.database().reference(withPath: "Product/\(self.productIdString)/ProductEvaluation/\(self.uid ?? "")/grade").setValue(cells?.textLabel?.text!)
            Database.database().reference(withPath: "Product/\(self.productIdString)/ProductEvaluation/\(self.uid ?? "")/comment").setValue("")
            Database.database().reference(withPath: "ProductOrder/\(orderIds)/Comment/").setValue("true")
            Database.database().reference(withPath: "ProductOrder/\(orderIds)/CommentProductId/\(productIdString)").setValue("true")
            removeTransparent()
        }else{
            Database.database().reference(withPath: "GroupBuy/\(self.productIdString)/ProductEvaluation/\(self.uid ?? "")/grade").setValue(cells?.textLabel?.text!)
            Database.database().reference(withPath: "GroupBuy/\(self.productIdString)/ProductEvaluation/\(self.uid ?? "")/comment").setValue("")
            Database.database().reference(withPath: "GroupBuyOrder/\(orderIds)/Comment/").setValue("true")
            Database.database().reference(withPath: "GroupBuyOrder/\(orderIds)/CommentProductId/\(productIdString)").setValue("true")
            removeTransparent()
        }
        
    }
}


