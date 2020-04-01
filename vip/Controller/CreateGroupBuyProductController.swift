//
//  CreateProductDataController.swift
//  vip
//
//  Created by rourou on 04/03/2020.
//  Copyright © 2020 Ines. All rights reserved.
//救命網站 scrollview https://fluffy.es/scrollview-storyboard-xcode-11/#structure
// 時間戳 https://www.hangge.com/blog/cache/detail_1198.html

import Foundation
import UIKit
import Firebase
import FirebaseStorage



class CreateGroupBuyProductController: UIViewController {
    
    @IBOutlet weak var ProductName: UITextField!
    @IBOutlet weak var Price: UITextField!
    @IBOutlet weak var Description: UITextField!
    @IBOutlet weak var ProductEvaluation: UITextField!
    @IBOutlet weak var SellerEvaluation: UITextField!
    @IBOutlet weak var Notice: UITextField!
    @IBOutlet weak var ManuDate: UITextField!
    @IBOutlet weak var ExpDate: UITextField!
    @IBOutlet weak var Method: UITextField!
    @IBOutlet weak var GroupBuyPeople: UITextField!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    let imagePicker = UIImagePickerController()



    var ref: DatabaseReference!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(CreateProductDataController.openGallery(tapGesture:)))
        productImage.isUserInteractionEnabled = true
        productImage.addGestureRecognizer(tapGesture)

        
    }
    
    @objc func openGallery(tapGesture: UITapGestureRecognizer){
        print("test")
        self.setImagePicker()
    }
    
    
    
    @IBAction func CreatBtn(_ sender: Any) {
        
         var strURL = ""
         let storageRef = Storage.storage().reference().child("GroupBuyProductImage").child((ProductName.text)!+".png")
                               
            if let uploadData = self.productImage.image!.pngData(){
                storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                   if error != nil{
                    print("error!!!", error ?? 0)
                        return
                                       }
                    storageRef.downloadURL(completion: {(url, error) in
                        if let imageURL = url?.absoluteString{
                          strURL = imageURL
                          print("strURL1: ",strURL)
                          print("imageURL:", imageURL)
                            self.productInfo(imageURL: strURL)
                          
                                           }
                                       })
                                   })
        }
    
    }
    
    private func productInfo(imageURL: String) -> Void{
        
        var newData = ["ProductName": ProductName.text ?? "Null", "Price": Price.text ?? "Null", "Description": Description.text ?? "Null", "ProductEvaluation": ProductEvaluation.text ?? "Null", "SellerEvaluation": SellerEvaluation.text ?? "Null"]
        
        newData["Notice"] = Notice.text ?? "Null"
        newData["ManuDate"] = ManuDate.text ?? "Null"
        newData["ExpDate"] = ExpDate.text ?? "Null"
        newData["Method"] = Method.text ?? "Null"
        newData["GroupBuyPeople"] = GroupBuyPeople.text ?? "Null"
        newData["imageURL"] = imageURL
//    時間戳看開始    
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = String(timeInterval)
        print("timeStamp：\(timeStamp)")
        newData["productCreateTime"] = timeStamp 

        let date = Date(timeIntervalSince1970: timeInterval)
        //格式化
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        print("新增日期時間：\(dformatter.string(from: date))")
//    時間戳結束
        print(newData)
        
        self.ref.child("GroupBuy").childByAutoId().setValue(newData)
        
        print("creat product data successfully")
        
}
    
    @IBAction func backButtonWasPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


extension CreateGroupBuyProductController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
       func setImagePicker(){
           if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
               
           }
       }
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]){
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        productImage.image = image
        self.dismiss(animated: true, completion: nil)
        
    }
   }

