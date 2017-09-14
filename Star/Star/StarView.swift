//
//  StarView.swift
//  Star
//
//  Created by Cleofas Pereira on 14/09/17.
//  Copyright © 2017 Cleofas Pereira. All rights reserved.
//

import UIKit

@IBDesignable
class StarView: UIView {
    
    @IBInspectable
    var scale: CGFloat = 0.9
    
    @IBInspectable
    var fase: CGFloat = 0.0
    
    @IBInspectable
    var bright: CGFloat = 0.9
    
    @IBInspectable
    var points: Int = 5
    
    
    private var starRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private var starCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    
    private func pathForStar(_ points: Int, _ center: CGPoint, _ radius: CGFloat, _ bright: CGFloat, _ faseAngle: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        var angle: CGFloat = faseAngle * CGFloat.pi / 180 // Converte angulo de grau para radiano
        let starPoints = points < 2 ? 2 : points // Quantidade mínima de pontas que a estrela pode ter é 2
        let arc: CGFloat = CGFloat.pi / CGFloat(starPoints)
        let brightRatio: CGFloat = bright < 0 ? 0 : (bright > 1 ? 1 : bright) // A taxa de brilho deve estar entre 0 e 1
        
        path.move(to: CGPoint(x: center.x + radius * cos(angle),
                              y: center.y - radius * sin(angle )))
        
        for vertex in 1...(2*starPoints) {
            let vertexRadius = radius - (radius * brightRatio * CGFloat(vertex % 2))
            angle+=arc
            path.addLine(to: CGPoint(x: center.x + vertexRadius * cos(angle),
                                     y: center.y - vertexRadius * sin(angle )))
            
        }
        return path
    }
    
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        pathForStar(points, starCenter, starRadius, bright, fase).stroke()
    }
}
