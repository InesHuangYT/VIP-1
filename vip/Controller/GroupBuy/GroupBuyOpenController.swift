//
//  GroupBuyOpenController.swift
//  vip
//
//  Created by Ines on 2020/4/2.
//  Copyright © 2020 Ines. All rights reserved.
// audioPlayer https://www.youtube.com/watch?v=Kq7eVJ6RSp8

import UIKit
import Firebase
import AVFoundation

class GroupBuyOpenController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var pauseAndPlay: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    var index  = Int()
    var productId = String()
    var uid = Auth.auth().currentUser?.uid
    var audioPlayer: AVAudioPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnAction()
        
        let lemmonSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Easy Lemon 30 Second", ofType: "mp3")!)
        print(lemmonSound)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! audioPlayer = AVAudioPlayer(contentsOf: lemmonSound)
        audioPlayer!.prepareToPlay()
        audioPlayer!.play()
        
        pauseAndPlay.setImage(UIImage(named : "pause"), for: UIControl.State.normal) //停
        pauseAndPlay.setImage(UIImage(named : "play"), for: UIControl.State.selected) //播
        
        slider.maximumValue = Float(audioPlayer?.duration ?? 0)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func pauseAndPlayButtonWasPressed(_ sender: UIButton) {
        
        pauseAndPlay.isSelected = !sender.isSelected
        
        if(audioPlayer?.isPlaying == true){
            audioPlayer?.stop()
            
        }else{
            audioPlayer?.play()
        }
        
    }
    
    // drag slider
    @IBAction func changeAudioTime(_ sender: Any) {
        audioPlayer?.stop()
        audioPlayer?.currentTime = TimeInterval(slider.value)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    
    @objc func updateSlider(){
        slider.value = Float(audioPlayer?.currentTime ?? 0)
        NSLog("HHHHii")
    }
    
    
    
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    @IBAction func openButtonWasPressed(_ sender: Any) {
        
        let ref =  Database.database().reference().child("GroupBuy").child(productId).child("OpenGroupId")
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            
            
            let reff = ref.childByAutoId()
            reff.child("OpenBy").child(self.uid ?? "").setValue(self.uid ?? "")
            reff.child("JoinBy").child(self.uid ?? "").setValue(self.uid ?? "")
            
            print(String(self.uid ?? "") + " 開團 ")
            
            //  開團規則：一位使用者可讚一個商品內開一次以上的團 
            ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                snapshot in
                
                if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                    
                    for snap in datas{
                        let key = snap.key
                        print(key)
                        Database.database().reference(withPath: "UserGroupBuy/\(self.uid ?? "wrong message : no currentUser")/OpenGroupId/\(reff.key ?? "")/ProductId/\(self.productId)").setValue(self.productId)
                        self.setUpMessageOk()
                    }
                }
                
            })
            //                 if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
            //                print("empty:",snapshots.isEmpty)
            //                if snapshots.isEmpty {
            //                    
            //                    ref.childByAutoId().child("JoinUser/\(self.uid ?? "")").setValue(String(self.uid ?? ""))
            //                    print(String(self.uid ?? "") + " 開團 ")
            //                    
            //                    //  開團規則：一位使用者只能在一個商品內開一次團 
            //                    ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { 
            //                        snapshot in
            //                        
            //                        if let datas = snapshot.children.allObjects as? [DataSnapshot]{
            //                            
            //                            for snap in datas{
            //                                let key = snap.key
            //                                print(key)
            //                                Database.database().reference(withPath: "UserGroupBuy/\(self.uid ?? "wrong message : no currentUser")/OpenGroupId/\(key)/ProductId/\(self.productId)").setValue(self.productId)
            //                                self.setUpMessageOk()
            //                            }
            //                        }
            //                        
            //                    })
            //                }else{
            //                    print("group already exist, can't open the group")
            //                    self.setUpMessageNo()
            //                }
            
            //            }
            
        })
    }
    
    func setUpMessageOk(){
        let message = UIAlertController(title: "您已開團成功", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "回主畫面", style: .default, handler: {action in 
            print("here go to Main Scene!")
            self.transition()
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    func setUpMessageNo(){
        let message = UIAlertController(title: "您已開團過摟", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "回主畫面", style: .default, handler: {action in 
            print("here go to Main Scene!")
            self.transition()
        })
        message.addAction(confirmAction)
        self.present(message, animated: true, completion: nil)
    }
    
    func transition(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        present(vc, animated: true, completion: nil)
    }
    
}
