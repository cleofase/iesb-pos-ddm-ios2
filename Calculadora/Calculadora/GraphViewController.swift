//
//  GraphViewController.swift
//  Calculadora
//
//  Created by Cleofas Pereira on 15/07/17.
//  Copyright © 2017 IESB - Instituto de Educação Superior de Brasília. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    let drawableAreaRate: CGFloat = 3.0
    fileprivate var initialScaleOfGraph: CGFloat = 1.0
    
    private var graphBrain = GraphBrain()
    var operationForPloting: MathematicalOperation? {
        didSet{
            graphBrain.operation = operationForPloting
            graphNavigationItem.title = graphBrain.functionDescription()
        }
    }
    
    @IBOutlet weak var graphNavigationItem: UINavigationItem!
    @IBOutlet weak var graphScrollView: UIScrollView! {
        didSet {
            graphScrollView.minimumZoomScale = 0.5
            graphScrollView.maximumZoomScale = 5.0
            graphScrollView.delegate = self
        }
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.frame.size = CGSize(width: graphScrollView.bounds.width * drawableAreaRate, height: graphScrollView.bounds.height * drawableAreaRate)
            graphScrollView.contentSize = graphView.frame.size
            graphScrollView.addSubview(graphView)
            initialScaleOfGraph = graphView.scaleGraph
        }
    }

    func getY(_ sender: GraphView) -> Double? {
        return graphBrain.functionValue(whenX: sender.currentUnitX!)
    }
    
    private func centralizeGraph() {
        let offSetX = (graphScrollView.contentSize.width / 2) - (graphScrollView.bounds.midX)
        let offSetY = (graphScrollView.contentSize.height / 2) - (graphScrollView.bounds.midY)
        graphScrollView.setContentOffset(CGPoint(x: offSetX, y: offSetY), animated: false)
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        centralizeGraph()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        graphView.setNeedsDisplay()
    }
}

extension GraphViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return graphView
    }

    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if let graphView = view as? GraphView {
            graphView.scaleGraph =  initialScaleOfGraph * scale
            graphView.setNeedsDisplay()
        }
    }
}
