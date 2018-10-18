//
//  ViewController.swift
//  Seafood
//
//  Created by Robin He on 10/18/18.
//  Copyright © 2018 Robin He. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var image: UIImageView!
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var cameraPic: UIImageView!
    
    @IBOutlet weak var trueOrfalse: UIImageView!
    
    @IBOutlet weak var text: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraPic.layer.cornerRadius=10
        cameraPic.layer.masksToBounds=true
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate=self
    }

    @IBAction func cameraTap(_ sender: UIButton) {
            present(imagePicker,animated: true,completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image.image = imagePicked
            guard  let CIimage = CIImage(image: imagePicked)  else
            {fatalError("image cannot convert to icimage type")}
            
            detect(ciimage: CIimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(ciimage:CIImage){
        
        guard  let model = try? VNCoreMLModel(for: Inceptionv3().model) else{fatalError("can not use the coreModel")}
        let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
            guard  let result = vnRequest.results as? [VNClassificationObservation] else{fatalError("cannot get the request result")}
            print(result)
            if let firstResult = result.first {
                if firstResult.identifier.contains("banana"){
                    self.trueOrfalse.image=UIImage(named: "correct")
                    self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor : UIColor.blue]
                
                    self.navigationItem.title="It is a banana!"
                }else {
                    self.trueOrfalse.image=UIImage(named: "cross")
                    self.navigationItem.title="Not a banana!"
                    self.navigationController?.navigationBar.titleTextAttributes=[NSAttributedString.Key.foregroundColor : UIColor.red]

                    
                }
                
                
            }
        }
       let handler = VNImageRequestHandler(ciImage:ciimage)
        do{
       try handler.perform([request])
        }catch{
            print(error)
        }
    }
}

