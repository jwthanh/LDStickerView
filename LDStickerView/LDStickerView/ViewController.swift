//
//  ViewController.swift
//  LDStickerView
//
//  Created by Vũ Trung Thành on 1/18/15.
//  Copyright (c) 2015 V2T Multimedia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var imageView: UIImageView = UIImageView(image: UIImage(named: "cu-meo.png"))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        var stickerView: LDStickerView = LDStickerView(frame: CGRectMake(10, 10, imageView.frame.size.width, imageView.frame.size.height))
        stickerView.setContentView(imageView)
        view.addSubview(stickerView)
        
        var imageView1: UIImageView = UIImageView(image: UIImage(named: "Minion1x.png"))
        imageView1.contentMode = UIViewContentMode.ScaleAspectFill
        var stickerView1: LDStickerView = LDStickerView(frame: CGRectMake(80, 200, imageView1.frame.size.width, imageView1.frame.size.height))
        stickerView1.setContentView(imageView1)
        view.addSubview(stickerView1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

