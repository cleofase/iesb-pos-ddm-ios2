//
//  StarViewController.swift
//  Bezier
//
//  Created by Cleofas Pereira on 14/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class StarViewController: UIViewController {

    @IBAction func pointsSlider(_ sender: UISlider) {
        starView.points = Int(sender.value)
        starView.setNeedsDisplay()
    }
    
    @IBAction func brightSlider(_ sender: UISlider) {
        starView.bright = CGFloat(sender.value)
        starView.setNeedsDisplay()
    }
    
    @IBAction func faseSlider(_ sender: UISlider) {
        starView.fase = CGFloat(sender.value)
        starView.setNeedsDisplay()
    }
    
    @IBAction func scaleSlider(_ sender: UISlider) {
        starView.scale = CGFloat(sender.value)
        starView.setNeedsDisplay()
    }
    
    @IBOutlet weak var starView: StarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
