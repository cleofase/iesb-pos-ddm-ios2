//
//  Operation.swift
//  Calculadora
//
//  Created by Cleofas Pereira on 20/07/17.
//  Copyright © 2017 IESB - Instituto de Educação Superior de Brasília. All rights reserved.
//

import Foundation
struct MathematicalOperation {
    var firstOperand: Double?
    var secondOperand: Double?
    var unaryFunction: ((Double) -> (Double))?
    var binaryFunction: ((Double,Double) -> (Double))?
    var description: String?
   
    
    var hasFunction: Bool {
        get {
            if firstOperand != nil {
                return true
            }

            if unaryFunction != nil {
                return true
            }

            if binaryFunction != nil {
                return true
            }
            return false
        }
    }
    
    var functionIsConstant: Bool {
        get {
            return firstOperand != nil && unaryFunction == nil && binaryFunction == nil
        }
    }
    
    var functionIsUnary: Bool {
        get {
            return unaryFunction != nil
        }
    }
    
    var functionIsBinary: Bool {
        get {
            return binaryFunction != nil
        }
    }
}
