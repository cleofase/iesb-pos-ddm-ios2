//
//  FunctionHouse.swift
//  Calculadora
//
//  Created by Cleofas Pereira on 19/07/17.
//  Copyright © 2017 IESB - Instituto de Educação Superior de Brasília. All rights reserved.
//

import Foundation

struct GraphBrain {
    private var description: String?
    private var function: typeFunction?

    private enum typeFunction {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
    }
    
    var operation: MathematicalOperation? {
        didSet {
            processOperation()
        }
    }
    
    private mutating func processOperation() {
        if operation != nil {
            if operation!.hasFunction {
                if operation!.functionIsBinary {
                    function = typeFunction.binary(operation!.binaryFunction!)
                    description = "\(operation!.firstOperand!) \(operation!.description!) X"
                } else if operation!.functionIsUnary {
                    function = typeFunction.unary(operation!.unaryFunction!)
                    description = "\(operation!.description!)(X)"
                } else if operation!.functionIsConstant {
                    function = typeFunction.constant(operation!.firstOperand!)
                    description = operation!.description!
                }
            }

        }
    }
    
    func functionDescription() -> String? {
        return description
    }
    
    
    func functionValue(whenX x: Double) -> Double? {
        if function != nil {
            switch function! {
            case .constant(let constant):
                return constant
            case .unary(let function):
                return function(x)
            case .binary(let function):
                return function(operation!.firstOperand!, x)
            }
        } else {
            return nil
        }
    
    
    }
}
