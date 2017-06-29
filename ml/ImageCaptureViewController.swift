//
//  ImageCaptureViewController.swift
//  ml
//
//  Created by 程晓龙 on 29/06/2017.
//  Copyright © 2017 becomedragon. All rights reserved.
//

import UIKit
import AVFoundation

class ImageCaptureViewController: UIViewController {
    
    var avSession = AVCaptureSession()
    var avPreviewLayer = AVCaptureVideoPreviewLayer()
    var avConnection:AVCaptureConnection?
    let closeButton = UIButton()
    let predicLabel = UILabel()
    var avOutput = AVCapturePhotoOutput()
    var outputSetting:AVCapturePhotoSettings?
    var previewType:NSNumber?
    var previewFormat:[String : Any]?
    var captureButton = UIButton()
    let Goomodel = GoogLeNetPlaces()
    let resModel = Resnet50()
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.configAVCapture()
        //iOS 11的生命周期有改变，第二次push进来，不走viewdidload?
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.avSession.startRunning()
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.capture), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .commonModes)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.avSession.stopRunning()
        self.timer?.invalidate()
        self.timer = nil
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func capture() {
        if (avConnection?.isActive)! {
            outputSetting = self.createOutputSetting()
            avOutput.capturePhoto(with: outputSetting!, delegate: self)
            outputSetting = nil
        }
    }
    
    func createOutputSetting() -> AVCapturePhotoSettings {
        outputSetting = AVCapturePhotoSettings()
        previewType  = outputSetting?.availablePreviewPhotoPixelFormatTypes.first!
        previewFormat = [kCVPixelBufferPixelFormatTypeKey as String:previewType,
                         kCVPixelBufferWidthKey as String:UIScreen.main.bounds.width,
                         kCVPixelBufferHeightKey as String:UIScreen.main.bounds.height] as [String : Any]
        outputSetting?.previewPhotoFormat = self.previewFormat
        return outputSetting!;
    }
    
    func configAVCapture() {
        let device = AVCaptureDevice.default(for: .video)
        
        guard let input = try? AVCaptureDeviceInput.init(device: device!) else {
            return
        }
        
        avSession.sessionPreset = .photo
        if avSession.canAddInput(input) {
            avSession.addInput(input)
        }
        
        if avSession.canAddOutput(avOutput) {
            avSession.addOutput(avOutput)
        }
        
        avPreviewLayer.session = avSession
        avPreviewLayer.videoGravity = .resizeAspectFill
        avPreviewLayer.frame = self.view.layer.bounds
        self.view.layer.insertSublayer(avPreviewLayer, at: 0)
        
        avConnection = avOutput.connection(with: .video)
        
        predicLabel.frame = CGRect(x: 0, y: self.view.frame.size.height - 400, width: self.view.frame.size.width, height: 200)
        predicLabel.text = "predicting...."
        predicLabel.textAlignment = .center
        predicLabel.font = UIFont.systemFont(ofSize: 40)
        predicLabel.textColor = UIColor.black
        predicLabel.numberOfLines = 0
        self.view.addSubview(predicLabel)
    }
}

extension ImageCaptureViewController:AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if photo.fileDataRepresentation() != nil {
            let image = UIImage(data: photo.fileDataRepresentation()!)
            guard let output = try? resModel.prediction(image: (image?.resize(to: CGSize(width: 224, height: 224)).pixelBuffer()!)!) else {
                fatalError("Unexpected runtime error.")
            }
            let problity = "\(Int(output.classLabelProbs[output.classLabel]! * 100))%"
            predicLabel.text = output.classLabel + "\n" + problity
        }
    }
}
