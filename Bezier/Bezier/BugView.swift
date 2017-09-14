//
//  BugView.swift
//  Bezier
//
//  Created by Cleofas Pereira on 14/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

@IBDesignable
class BugView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 0.5
    
    @IBInspectable
    var widthRatio: CGFloat = 0.5 // razão da largura da joaninha em relação à altura
    
    private var bodyHeight: CGFloat {
        return (bounds.width <= bounds.height) ? scale * bounds.width/widthRatio : scale * bounds.height
    }
    
    private var bodyWidth: CGFloat {
        return bodyHeight * widthRatio
    }
    
    var centerBody: CGPoint {
        return CGPoint(x: CGFloat(bounds.width / 2), y: CGFloat(bounds.height / 2))
    }
    
    private func drawHead() {
        let ratioHead: CGFloat = 0.2
        let centerHead: CGPoint = CGPoint(x: centerBody.x, y: centerBody.y - bodyHeight/2)
        let radiusHead: CGFloat = ratioHead * bodyWidth
        
        let path = UIBezierPath()
        path.addArc(withCenter: centerHead, radius: radiusHead, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        UIColor.white.setFill()
        path.fill()
        path.stroke()
        
    }
    
    private func drawBody() {
        let resolutionBody = 36
        let arc: CGFloat = 2 * CGFloat.pi / CGFloat(resolutionBody)
        let radiusX: CGFloat = bodyWidth/2
        let radiusY: CGFloat = bodyHeight/2
        
        var angle = CGFloat.pi / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: radiusX * cos(angle) + centerBody.x,
                              y: -radiusY * sin(angle) + centerBody.y))
        
        for _ in 1...resolutionBody {
            angle+=arc
            path.addLine(to: CGPoint(x: radiusX * cos(angle) + centerBody.x,
                                     y: -radiusY * sin(angle) + centerBody.y))
        }
        UIColor.white.setFill()
        path.fill()
        path.stroke()
    }
    
    private func drawSpots() {
        let resolutionBody = 8
        let ratioSpreadSpot: CGFloat = 0.66
        let ratioRadiusSpot: CGFloat = 0.2
        let arc: CGFloat = 2 * CGFloat.pi / CGFloat(resolutionBody)
        let radiusX: CGFloat = ratioSpreadSpot * bodyWidth/2
        let radiusY: CGFloat = ratioSpreadSpot * bodyHeight/2
        
        var centerSpot: CGPoint!
        var radiusSpot: CGFloat!
        
        var angle = 3 * CGFloat.pi / 2
        
        UIColor.white.setFill()
        
        for _ in 1..<resolutionBody {
            angle+=arc
            centerSpot = CGPoint(x: radiusX * cos(angle) + centerBody.x,
                                 y: -radiusY * sin(angle) + centerBody.y)
            radiusSpot = ratioRadiusSpot * (fabs(radiusX * cos(angle)) + radiusX)
            
            let path = UIBezierPath()
            path.addArc(withCenter: centerSpot, radius: radiusSpot, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
            path.fill()
            path.close()
            path.stroke()
            
        }
    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        drawHead()
        drawBody()
        // pathForWings
        // pathForAntennas
        // pathForLegs
        
        drawSpots()
    }
}
