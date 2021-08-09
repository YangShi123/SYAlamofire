//
//  ViewController.swift
//  SYAlamofire
//
//  Created by shiyawn@163.com on 08/09/2021.
//  Copyright (c) 2021 shiyawn@163.com. All rights reserved.
//

import UIKit
import SYAlamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NET.GET(url: "url", parameters: [:]).success { (response) in
            
        }.failed { (e) in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

