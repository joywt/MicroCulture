//
//  ViewController.swift
//  MicroCulture
//
//  Created by wang tie on 17/2/13.
//  Copyright © 2017年 developer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var showLabel: UILabel!
    @IBOutlet var resultLabel: UILabel!
    
    @IBOutlet var mutualButton: UIButton!
    
    
    lazy var showText:String = {
       return ""
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mutualButton.isEnabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func appendElement(_ sender: Any) {
    }
    
    @IBAction func operate(_ sender: Any) {
    }
    
    @IBAction func enter(_ sender: Any) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

