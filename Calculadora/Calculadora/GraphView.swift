//
//  GraphView.swift
//  Calculadora
//
//  Created by Cleofas Pereira on 15/07/17.
//  Copyright © 2017 IESB - Instituto de Educação Superior de Brasília. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func getY(_ sender: GraphView) -> Double?
}

@IBDesignable
class GraphView: UIView {
    weak var dataSource: GraphViewDataSource?

    @IBInspectable
    var colorAxes: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable
    var colorFunction: UIColor = UIColor.blue {
        didSet {
        setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var scaleGraph: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let pointsPerUnit: CGFloat = 1.0
    
    var currentUnitX: Double?
    
    var centerGraph: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY )
    }
    
    var minXPoint: CGFloat {
        return -centerGraph.x
    }
    
    var maxXPoint: CGFloat {
        return bounds.width - centerGraph.x
    }
    
    private func convertToPoints(unitX: CGFloat) -> CGFloat {
        return (unitX * scaleGraph * pointsPerUnit) + centerGraph.x
    }
    
    private func convertToPoints(unitY: CGFloat) -> CGFloat {
        return -(unitY * scaleGraph * pointsPerUnit) + centerGraph.y
    }
    
    private func convertToPoints(pointX: CGFloat) -> CGFloat {
        return pointX + centerGraph.x
    }
    
    private func convertToUnit(pointX: CGFloat) -> CGFloat {
        return pointX/(scaleGraph * pointsPerUnit)
    }
    
    private func plotAxes() {
        let graphAxes: AxesDrawer = AxesDrawer(color: colorAxes, contentScaleFactor: contentScaleFactor)
        graphAxes.drawAxes(in: bounds,
                           origin: centerGraph,
                           pointsPerUnit: pointsPerUnit * scaleGraph)
    }
    
    private func plotFunction() {
        if dataSource != nil {
            let functionPath = UIBezierPath()
            
            currentUnitX = Double(convertToUnit(pointX: minXPoint))
            if let currentUnitY = dataSource!.getY(self) {
                functionPath.move(to: CGPoint(x: convertToPoints(pointX: minXPoint),
                                              y: convertToPoints(unitY: CGFloat(currentUnitY)))
                )

                
                for currentXPoint in stride(from: minXPoint, through: maxXPoint, by: pointsPerUnit) {
                    currentUnitX = Double(convertToUnit(pointX: currentXPoint))
                    if let currentUnitY = dataSource!.getY(self) {
                        functionPath.addLine(to: CGPoint(x: convertToPoints(pointX: currentXPoint),
                                                         y: convertToPoints(unitY: CGFloat(currentUnitY)))
                        )
                    }
                }
                colorFunction.set()
                functionPath.stroke()
            }
        }
    }
    
    private func plot() {
        var itIsPlotingPortionOfGraph: Bool = false
        let functionPath = UIBezierPath()
        
        if dataSource != nil {
            for currentXPoint in stride(from: minXPoint, through: maxXPoint, by: pointsPerUnit) {
                currentUnitX = Double(convertToUnit(pointX: currentXPoint))
                if let currentUnitY = dataSource!.getY(self) {
                    if currentUnitY.isFinite {
                        var currentYPoint = convertToPoints(unitY: CGFloat(currentUnitY))
                        if bounds.maxY.isLess(than: currentYPoint) {
                            currentYPoint = bounds.maxY
                        } else if currentYPoint.isLess(than: bounds.minY) {
                            currentYPoint = bounds.minY
                        }
                        if itIsPlotingPortionOfGraph {
                            functionPath.addLine(to: CGPoint(x: convertToPoints(pointX: currentXPoint), y: currentYPoint))
                        } else {
                            functionPath.move(to: CGPoint(x: convertToPoints(pointX: currentXPoint), y: currentYPoint))
                            itIsPlotingPortionOfGraph = true
                        }
                        
                    } else if itIsPlotingPortionOfGraph {
                        colorFunction.set()
                        functionPath.stroke()
                        itIsPlotingPortionOfGraph = false
                    }
                    
                } else if itIsPlotingPortionOfGraph {
                    colorFunction.set()
                    functionPath.stroke()
                    itIsPlotingPortionOfGraph = false
                }
            }
            if itIsPlotingPortionOfGraph {
                colorFunction.set()
                functionPath.stroke()
                itIsPlotingPortionOfGraph = false
            }
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        plotAxes()
        plot()
       
    }
}
