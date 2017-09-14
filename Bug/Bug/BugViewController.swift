//
//  BugViewController.swift
//  Bug
//
//  Created by Cleofas Pereira on 14/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

class BugViewController: UIViewController {

    @IBOutlet weak var bugView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        bugView.setNeedsDisplay()
    }

}
