//
//  ViewController.swift
//  ml
//
//  Created by 程晓龙 on 28/06/2017.
//  Copyright © 2017 becomedragon. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var predicLabel: UILabel!
    let albumPicker = UIImagePickerController()
    let cameraPicker = ImageCaptureViewController()
    
    let model = GoogLeNetPlaces()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func openAlbume(_ sender: Any) {
        albumPicker.sourceType = .photoLibrary
        albumPicker.delegate = self
        self.navigationController?.present(albumPicker, animated: true, completion: nil)
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        self.navigationController?.pushViewController(cameraPicker, animated: true)
    }
}

extension ViewController:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker == albumPicker {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            guard let output = try? model.prediction(sceneImage:image.resize(to: CGSize(width: 224, height: 224)).pixelBuffer()!) else {
                fatalError("Unexpected runtime error.")
            }
            picker.dismiss(animated: true, completion: nil)
            predicLabel.text = output.sceneLabel
        }
    }
}

extension ViewController:UINavigationControllerDelegate {
    
}
