//
//  CalculatorBrain.swift
//  Calculadora
//
//  Created by Pedro Henrique on 18/05/17.
//  Copyright © 2017 IESB - Instituto de Educação Superior de Brasília. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    var currentOperation = MathematicalOperation()
    var hasOperationPending: Bool = false

    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unary(sqrt),
        "sen": Operation.unary(sin),
        "cos": Operation.unary(cos),
        "tan": Operation.unary(tan),
        "log": Operation.unary(log10),
        "±": Operation.unary({ -$0 }),
        "mod": Operation.binary({$0.truncatingRemainder(dividingBy:$1)}),
        "xˆy": Operation.binary(pow),
        "/": Operation.binary({ $0 / $1 }),
        "×": Operation.binary({ $0 * $1 }),
        "+": Operation.binary({ $0 + $1 }),
        "-": Operation.binary({ $0 - $1 }),
        "=": Operation.equals
    ]
    
    private var pbo: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
                case .constant(let constant):
                    currentOperation.firstOperand = constant
                    currentOperation.secondOperand = nil
                    currentOperation.unaryFunction = nil
                    currentOperation.binaryFunction = nil
                    currentOperation.description = symbol
                    accumulator = constant
                case .unary(let function):
                    if accumulator != nil {
                        currentOperation.firstOperand = accumulator
                        currentOperation.secondOperand = nil
                        currentOperation.unaryFunction = function
                        currentOperation.binaryFunction = nil
                        currentOperation.description = symbol
                        accumulator = function(accumulator!)
                    }
                case .binary(let function):
                    if accumulator != nil {
                        currentOperation.firstOperand = accumulator
                        currentOperation.secondOperand = nil
                        currentOperation.unaryFunction = nil
                        currentOperation.binaryFunction = function
                        currentOperation.description = symbol
                        pbo = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                        hasOperationPending = true
                    }
                case .equals:
                    performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if accumulator != nil {
            currentOperation.secondOperand = accumulator
            accumulator = pbo?.perform(with: accumulator!)
            hasOperationPending = false
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator != nil ? accumulator : 0
        }
    }
    
    mutating func clear() {
        accumulator = nil;
        pbo = nil
    }
}

private func fatorial(_ n: Double) -> Double {
    return n <= 0 ? 1 : n * fatorial(n - 1)
}
