//
//  GroupBuyOpenController.swift
//  vip
//
//  Created by Ines on 2020/4/2.
//  Copyright © 2020 Ines. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class GroupBuyOpenController: UIViewController {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var pauseAndPlay: UIButton!
    
    var index  = Int()
    var productId = String()
    var uid = Auth.auth().currentUser?.uid
    var audioPlayer: AVAudioPlayer?



//    var backgroundAudio = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "Easy Lemon 30 Second", ofType: "mp3") ?? "")
    
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
        pauseAndPlay.setImage(UIImage(named : "pause"), for: UIControl.State.normal)
        pauseAndPlay.setImage(UIImage(named : "play"), for: UIControl.State.selected)

    }
    
    @IBAction func pauseAndPlayButtonWasPressed(_ sender: UIButton) {
        pauseAndPlay.isSelected = !sender.isSelected
        if(audioPlayer?.isPlaying == true){
            audioPlayer?.stop()
        }else{
            audioPlayer?.play()
        }
        
    }
    func btnAction(){
        btnMenu.target = self.revealViewController()
        btnMenu.action = #selector(SWRevealViewController.rightRevealToggle(_:))
    }
    
    @IBAction func openButtonWasPressed(_ sender: Any) {
        
        let ref =  Database.database().reference().child("GroupBuy").child(productId).child("openedBy").child(self.uid ?? "")
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in 
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                print("empty:",snapshots.isEmpty)
                if snapshots.isEmpty {
                    
                    let groupBuyRef = Database.database().reference(withPath: "GroupBuy/\(self.productId)/openedBy/\(self.uid ?? "")").childByAutoId().child("JoinUser/users/\(self.uid ?? "")")
                    
                    groupBuyRef.setValue(String(self.uid ?? ""))
                    print(String(self.uid ?? "") + " 開團 ")
                    
                    //  開團規則：一位使用者只能在一個商品內開一次團
                    ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { 
                        snapshot in
                        
                        if let datas = snapshot.children.allObjects as? [DataSnapshot]{
                            
                            for snap in datas{
                                let key = snap.key
                                print(key)
                                Database.database().reference(withPath: "users/\(self.uid ?? "wrong message : no currentUser")/GroupBuy/\(self.productId)/OpenGroupId/\(key)").setValue(key)
                                self.setUpMessageOk()
                            }
                        }
                        
                    })
                }else{
                    print("group already exist, can't open the group")
                    self.setUpMessageNo()
                }
                
            }
            
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
