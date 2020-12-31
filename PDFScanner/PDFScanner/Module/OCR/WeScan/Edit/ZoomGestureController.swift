//
//  ZoomGestureController.swift
//  WeScan
//
//  Created by Bobo on 5/31/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

final class ZoomGestureController {
    
    private let image: UIImage
    private let quadView: QuadrilateralView
    private var previousPanPosition: CGPoint?
    private var closestCorner: CornerPosition?
    private var beganHandle: EditScanHandleView?

    init(image: UIImage, quadView: QuadrilateralView) {
        self.image = image
        self.quadView = quadView
    }

    @objc func handle(pan: UIGestureRecognizer) {
        guard let drawnQuad = quadView.quad else {
            return
        }
        
        switch pan.state {
        case .began:
            //
            processBeganState(gesture: pan)
        case .changed:
            //
            processChangedState(gesture: pan, drawnQuad: drawnQuad)
        case .ended, .cancelled, .failed:
            //
            self.previousPanPosition = nil
            self.closestCorner = nil
            quadView.resetHighlightedCornerViews()
            
            // handle
            beganHandle?.fillShape(isFilled: false)
            beganHandle = nil
            
        default:
            break
        }

        
    }
    
    private func processBeganState(gesture: UIGestureRecognizer) {
        
        let view = gesture.view
        let loc = gesture.location(in: view)
        let subview = view?.hitTest(loc, with: nil)
        // 特殊处理handle
        beganHandle = subview as? EditScanHandleView
        beganHandle?.fillShape(isFilled: true)
    }
    
    private func processChangedState(gesture: UIGestureRecognizer, drawnQuad: Quadrilateral) {
        
        if let beganHandle = beganHandle {
            
            processHandleChangedState(gesture: gesture, handleView: beganHandle)
        } else {
            
            processCornerChangedState(gesture: gesture, drawnQuad: drawnQuad)
        }
        
    }
    
    private func processHandleChangedState(gesture: UIGestureRecognizer, handleView: EditScanHandleView) {
        
        let cornerViews = quadView.cornerViewsForHandlePosition(position: handleView.position)
        
        var position = gesture.location(in: quadView)
        // 手柄移动同一时刻只支持水平和垂直方向
        if handleView.position == .top ||
            handleView.position == .bottom {
            position.x = 0
        } else {
            position.y = 0
        }

        let previousPanPosition = self.previousPanPosition ?? position

        let offset = CGAffineTransform(translationX: position.x - previousPanPosition.x, y: position.y - previousPanPosition.y)
        
        for cornerView in cornerViews {
            let draggedCornerViewCenter = cornerView.center.applying(offset)
            quadView.moveCorner(cornerView: cornerView, atPoint: draggedCornerViewCenter)
        }
        
        self.previousPanPosition = position

    }
    
    private func processCornerChangedState(gesture: UIGestureRecognizer, drawnQuad: Quadrilateral) {
        
        let position = gesture.location(in: quadView)
        
        let previousPanPosition = self.previousPanPosition ?? position
        let closestCorner = self.closestCorner ?? position.closestCornerFrom(quad: drawnQuad)
        
        let offset = CGAffineTransform(translationX: position.x - previousPanPosition.x, y: position.y - previousPanPosition.y)
        let cornerView = quadView.cornerViewForCornerPosition(position: closestCorner)
        let draggedCornerViewCenter = cornerView.center.applying(offset)
        
        quadView.moveCorner(cornerView: cornerView, atPoint: draggedCornerViewCenter)
        
        self.previousPanPosition = position
        self.closestCorner = closestCorner
        
//        let scale = image.size.width / quadView.bounds.size.width
//        let scaledDraggedCornerViewCenter = CGPoint(x: draggedCornerViewCenter.x * scale, y: draggedCornerViewCenter.y * scale)
//        guard let zoomedImage = image.scaledImage(atPoint: scaledDraggedCornerViewCenter, scaleFactor: 2.5, targetSize: quadView.bounds.size) else {
//            return
//        }
        
//        quadView.highlightCornerAtPosition(position: closestCorner, with: zoomedImage)
    }
    
}
