//
//  ViewController.swift
//  tCam
//
//  Created by Manabu Tonosaki on 2019/03/18.
//  Copyright © 2019 sysartist. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var viewCamera: UIView!
    
    var captureSesssion: AVCaptureSession!
    var camera:AVCaptureDevice!
    var stillImageOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var z:Double!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // スワイプ処理
        viewCamera.backgroundColor = UIColor.black
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        viewCamera.addGestureRecognizer(panGestureRecognizer)
        
        // カメラの設定
        captureSesssion = AVCaptureSession()
        captureSesssion.sessionPreset = .high

        stillImageOutput = AVCapturePhotoOutput()

        //　カメラデバイスのインスタンスを取得（背面カメラ）
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        for device in devices
        {
            if device.position == AVCaptureDevice.Position.back
            {
                camera = device
            }
        }
        
        // 解像度の設定
        captureSesssion.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        let device = AVCaptureDevice.default(for: .video)
        do
        {
            let input = try AVCaptureDeviceInput(device: device!)
            
            // 入力
            if (captureSesssion.canAddInput(input))
            {
                captureSesssion.addInput(input)
                // 出力
                if (captureSesssion.canAddOutput(stillImageOutput!))
                {
                    // カメラ起動
                    captureSesssion.addOutput(stillImageOutput!)
                    captureSesssion.startRunning()
                    
                    // アスペクト比、カメラの向き　（ズーム倍率を反映させる）
                    z = 1.0
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSesssion)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill // アスペクトフィット
                    previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
                    
                    viewCamera.layer.addSublayer(previewLayer!)
                    
                    // ビューのサイズの調整
                    previewLayer?.position = CGPoint(x: self.viewCamera.frame.width / 2, y: self.viewCamera.frame.height / 2)
                    previewLayer?.bounds = viewCamera.frame
                }
            }
        }
        catch {
            print(error)
        }
    }

    let maxZoomScale: CGFloat = 6.0
    let minZoomScale: CGFloat = 1.0
    let zoomSpeed: CGFloat = 200 // 100=標準速度
    var startZoom: CGFloat = 1.0
    
    @objc func panGesture(sender: UIPanGestureRecognizer)
    {
        do
        {
            try camera.lockForConfiguration()
            
            switch( sender.state)
            {
            case .began:
                startZoom = camera.videoZoomFactor
                break
            case .ended:
                break
            default:
                let delta: CGPoint = sender.translation(in: self.view)
                var z:CGFloat = -delta.y / (10000.0 / zoomSpeed) + startZoom
                if( z < minZoomScale )
                {
                    z = minZoomScale
                }
                if( z > maxZoomScale )
                {
                    z = maxZoomScale
                }
                print( z )
                camera.videoZoomFactor = z
                break
            }
            
            camera.unlockForConfiguration()
        }
        catch
        {
        }
    }
}

