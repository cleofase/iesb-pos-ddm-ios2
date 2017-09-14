//
//  TriangleView.swift
//  Triangle
//
//  Created by Cleofas Pereira on 14/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

@IBDesignable
class TriangleView: UIView {
    private let ratio: CGFloat = 0.7
    
    private var aVertex: CGPoint {
        return CGPoint(x: CGFloat(bounds.width * (1 - ratio) / 2),
                       y: CGFloat(bounds.height * (1 - ratio) / 2))
    }
    
    private var bVertex: CGPoint {
        return CGPoint(x: CGFloat(bounds.width / 2),
                       y: CGFloat(bounds.height * (1 + ratio) / 2))
    }
    
    private var cVertex: CGPoint {
        return CGPoint(x: CGFloat(bounds.width * (1 + ratio) / 2),
                       y: CGFloat(bounds.height * (1 - ratio) / 2))
    }
    
    private var triangleCenter: CGPoint {
        return CGPoint(x: CGFloat(bounds.width / 2), y: CGFloat(bounds.height / 2))
    }
    
    private func pathForTriangle() -> UIBezierPath {
        let path = UIBezierPath()
        
        path.move(to: aVertex)
        path.addLine(to: bVertex)
        path.addLine(to: cVertex)
        path.close()
        
        return path
    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        pathForTriangle().stroke()
    }
}
