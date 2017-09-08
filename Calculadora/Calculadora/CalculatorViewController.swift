//
//  ViewController.swift
//  Calculadora
//
//  Created by Pedro Henrique on 11/05/17.
//  Copyright © 2017 IESB - Instituto de Educação Superior de Brasília. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!

    
    var userIsInMiddleOfTyping = false
    var userTouchedDot = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        let currentValue = display.text!
        if userIsInMiddleOfTyping {
            display.text = currentValue + digit
        }else {
            display.text = digit
            userIsInMiddleOfTyping = true
        }
    }
    
    
    @IBAction func touchDot(_ sender: UIButton) {
        if !userTouchedDot {
            userTouchedDot = true
            userIsInMiddleOfTyping = true
            let currentValue = display.text!
            display.text = currentValue + "."
        }
        
    }
        
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
   
    private var brain = CalculatorBrain()
    
    
    @IBAction func performOperation(_ sender: UIButton) {
        brain.setOperand(displayValue)
        userIsInMiddleOfTyping = false
        userTouchedDot = false
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
            displayValue = brain.result!
        }
    }

    @IBAction func clearOperation(_ sender: UIButton) {
        brain.clear()
        displayValue = brain.result!
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationNavigationController = segue.destination as? UINavigationController {
            if let destinationViewController = destinationNavigationController.viewControllers[0] as? GraphViewController {
                if !brain.hasOperationPending && brain.currentOperation.hasFunction {
                    destinationViewController.operationForPloting = brain.currentOperation
                }
            }
        }
    }
}

