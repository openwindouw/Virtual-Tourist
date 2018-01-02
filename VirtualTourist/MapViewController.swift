//
//  ViewController.swift
//  VirtualTourist
//
//  Created by user on 12/31/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    @IBOutlet weak var buttonHeightConstant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func showPinDetailOnTap(_ sender: Any) {
        performSegue(withIdentifier: "showPinDetail", sender: nil)
    }
}

