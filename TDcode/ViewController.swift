//
//  ViewController.swift
//  TDcode
//
//  Created by apple on 2017/8/14.
//  Copyright © 2017年 apple. All rights reserved.
//

import UIKit
import AVFoundation//扫描
import CoreImage//生成
class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    var session:AVCaptureSession?
    var layer:AVCaptureVideoPreviewLayer?
    var input:AVCaptureDeviceInput?
    var output:AVCaptureMetadataOutput?
     var device:AVCaptureDevice?
    var lineview:UIView?
    var imageview:UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn=UIButton.init(frame: CGRect(x:100,y:100,width:200,height:50))
        btn.backgroundColor=UIColor.green
        btn.addTarget(self, action: #selector(btnClick), for: UIControlEvents.touchUpInside)
        btn.setTitle("点我进行二维码扫描", for: UIControlState.normal)
        self.view.addSubview(btn)
        
        let rightbtn=UIButton.init(frame: CGRect(x:100,y:30,width:200,height:50))
        rightbtn.backgroundColor=UIColor.blue
        rightbtn.addTarget(self, action: #selector(rightbtnClick), for: UIControlEvents.touchUpInside)
        rightbtn.setTitle("点我生成二维码", for: UIControlState.normal)
        self.view.addSubview(rightbtn)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func rightbtnClick() {
        // 1. 创建一个二维码滤镜实例(CIFilter)
        let filter=CIFilter.init(name: "CIQRCodeGenerator")
        // // 滤镜恢复默认设置
        filter?.setDefaults()
        // 2. 给滤镜添加数据
        let str:String="123456"
        let mydata:Data=str.data(using: String.Encoding.utf8)!
        filter?.setValue(mydata, forKeyPath: "inputMessage")
        // 3. 生成二维码
        let image:CIImage=(filter?.outputImage)!
         // 4. 显示二维码
        self.imageview=UIImageView.init(frame: CGRect(x:50,y:300,width:100,height:100))
//        self.imageview?.image=UIImage.init(ciImage: image)
        self.imageview?.image=self.createNonInterpolatedUIImageFormCIImage(image, size: 100)//图片的宽高
        self.view.addSubview(self.imageview!)
        
       
    }
    //生成清晰的图片
    func createNonInterpolatedUIImageFormCIImage(_ image:CIImage,size:CGFloat) -> UIImage {
        let extent: CGRect = image.extent.integral
        let scale: CGFloat = min(size / extent.width, size / extent.height)
        // 1.创建bitmap;
        let width: size_t = size_t(extent.width * scale)
        let height: size_t = size_t(extent.height * scale)
        let cs: CGColorSpace? = CGColorSpaceCreateDeviceGray()
        
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs!, bitmapInfo: 0)!
        let context = CIContext(options: nil)
        
        let bitmapImage: CGImage? = context.createCGImage(image, from: extent)
        bitmapRef.interpolationQuality = CGInterpolationQuality.none
        bitmapRef.scaleBy(x: scale, y: scale)
        bitmapRef.draw(bitmapImage!, in: extent);
        // 2.保存bitmap到图片
        let scaledImage: CGImage = bitmapRef.makeImage()!
        return UIImage(cgImage: scaledImage)
     
    
    }
    
    func btnClick()  {
        device=AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        session=AVCaptureSession.init()
        do {
            try input=AVCaptureDeviceInput.init(device: device)
            if (input != nil) {
                session?.addInput(input)
            }
        } catch  {
            print("2112")
            return;
        }
        
        output=AVCaptureMetadataOutput.init()
        output?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
         self.session?.sessionPreset=AVCaptureSessionPresetHigh
        self.session?.addOutput(self.output)
        output?.metadataObjectTypes=[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code]
        layer=AVCaptureVideoPreviewLayer.init(session: session)
        layer?.videoGravity=AVLayerVideoGravityResizeAspectFill
        //设置相机扫描框的大小
        layer?.frame=CGRect(x:20,y:170,width:280,height:280)
        self.view.layer.insertSublayer(layer!, at: 0)
        lineview=UIView.init(frame: CGRect(x:20,y:170,width:280,height:1))
        lineview?.backgroundColor=UIColor.red
        self.view.addSubview(lineview!)
        session?.startRunning()//开始捕捉
        UIView.animate(withDuration: 5, delay: 0.0, options: UIViewAnimationOptions.repeat, animations: {
            self.lineview?.frame=CGRect(x:20,y:449,width:280,height:1)
        }) { (istrue) in
           self.lineview?.frame=CGRect(x:20,y:170,width:280,height:1)
        }
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        print("来到代理方法")
        var zhqrcode:String="";
        for i in 0..<metadataObjects.count {
            let metadata:AVMetadataObject=metadataObjects[i] as! AVMetadataObject
            if metadata.type==AVMetadataObjectTypeQRCode {
                let codeobgj:AVMetadataMachineReadableCodeObject=metadata as! AVMetadataMachineReadableCodeObject
                zhqrcode=codeobgj.stringValue
                break;
            }
        }
        print(zhqrcode)
        session?.stopRunning()
        layer?.removeFromSuperlayer()
        layer=nil
        lineview?.removeFromSuperview()
        lineview=nil
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

