//
//  EmoticonViewController.swift
//  Emoticon
//
//  Created by Cleofas Pereira on 14/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class EmoticonViewController: UIViewController {
    @IBAction func changeEyeAperture(_ sender: UISwitch) {
        eyesOpen = sender.isOn
    }
    
    @IBAction func adjustHumor(_ sender: UISlider) {
        humorStatus = Double(sender.value)
    }
    
    @IBOutlet weak var emoticon: EmoticonView!
    
    var eyesOpen: Bool {
        get {
            return emoticon.eyesOpen
        }
        set {
            emoticon.eyesOpen = newValue
            emoticon.setNeedsDisplay()
        }
    }
    
    var humorStatus: Double {
        get {
            return emoticon.mouthCurvature
        }
        set {
            emoticon.mouthCurvature = newValue
            emoticon.setNeedsDisplay()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        emoticon.setNeedsDisplay()
    }
    
}
