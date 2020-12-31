//
//  BoardView.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/17.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class BoardView: UIView {

    @IBOutlet weak var leftTopIV: UIImageView!
    @IBOutlet weak var rightTopIV: UIImageView!
    @IBOutlet weak var rightBottomIV: UIImageView!
    @IBOutlet weak var leftBottomIV: UIImageView!
    @IBOutlet weak var borderView: UIView!
    
    enum RectanglePosition : Int{
        case leftTop = 0,rightTop,rightBottom,leftBottom
    }
    
    var contenView:UIView?{
        didSet{
            if let view = contenView{
                 oldValue?.removeFromSuperview()
                self.addSubview(view)
                view.mas_makeConstraints { (maker) in
                    maker?.edges.equalTo()(self)
                }
            }
        }
    }
    
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 2.0
    
    var isEdit:Bool = true{
        didSet{
            self.leftTopIV.isHidden = !isEdit
            self.rightTopIV.isHidden = self.leftTopIV.isHidden
            self.rightBottomIV.isHidden = self.leftTopIV.isHidden
//            self.leftBottomIV.isHidden = self.leftTopIV.isHidden
        }
    }
    
    var rectanglePositionClick:((_ type:RectanglePosition, _ boardView:BoardView)->Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.leftTopIV.tag = RectanglePosition.leftTop.rawValue
        self.leftTopIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ivClick(tapGR:))))
        self.rightTopIV.tag = RectanglePosition.rightTop.rawValue
        self.rightTopIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ivClick(tapGR:))))
        self.rightBottomIV.tag = RectanglePosition.rightBottom.rawValue
        self.rightBottomIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ivClick(tapGR:))))
        self.rightBottomIV.layer.cornerRadius = 10
        let rbView = UIView()
        rbView.layer.cornerRadius = 8
        rbView.backgroundColor = UIColor.colorWithHexString(colorString: "#2D4056")
        self.rightBottomIV.addSubview(rbView)
        rbView.mas_makeConstraints { (maker) in
            maker?.center.equalTo()(rbView.superview)
            maker?.size.equalTo()(CGSize(width: 16, height: 16))
        }
        self.rightBottomIV.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(viewDragScale(panGR:))))
        
//        self.leftBottomIV.tag = RectanglePosition.leftBottom.rawValue
//        self.leftBottomIV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ivClick(tapGR:))))
//        self.leftBottomIV.layer.cornerRadius = self.rightBottomIV.layer.cornerRadius
//        let lbView = UIView()
//        lbView.layer.cornerRadius = 8
//        lbView.backgroundColor = UIColor.colorWithHexString(colorString: "#2D4056")
//        self.leftBottomIV.addSubview(lbView)
//        lbView.mas_makeConstraints { (maker) in
//            maker?.center.equalTo()(lbView.superview)
//            maker?.size.equalTo()(CGSize(width: 16, height: 16))
//        }
//        self.leftBottomIV.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(viewDragScale(panGR:))))
        
        self.borderView.layer.borderColor = UIColor.colorWithHexString(colorString: "#2D4056").cgColor
        self.borderView.layer.borderWidth = 3
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(viewDrag(panGR:))))
    }

    @objc private func ivClick(tapGR:UITapGestureRecognizer){
        if let view = tapGR.view,let type = RectanglePosition(rawValue: view.tag){
            rectanglePositionClick?(type, self)
        }
    }
    
    @objc private func viewDragScale(panGR:UIPanGestureRecognizer){
        let transP = panGR.translation(in: self.superview)
        let scale = (transP.x + self.width)/self.width
        let transform = self.transform
        self.transform = self.transform.concatenating(CGAffineTransform(scaleX: scale, y: scale))
        if self.width/self.borderView.width < minScale || self.width/self.borderView.width > maxScale{
            self.transform = transform
        }
        panGR.setTranslation(CGPoint(x: 0, y: 0), in: self.superview)
    }
    
    @objc private func viewDrag(panGR:UIPanGestureRecognizer){
        let transP = panGR.translation(in: self.superview)
//        let transform = self.transform
        self.transform = self.transform.concatenating(CGAffineTransform(translationX: transP.x, y: transP.y))
//        if !self.superview!.bounds.contains(self.frame) {
//            self.transform = transform
//        }
        panGR.setTranslation(CGPoint(x: 0, y: 0), in: self.superview)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.hitPoint(point: point, in: self.leftTopIV){
            return self.leftTopIV
        }
        if self.hitPoint(point: point, in: self.rightTopIV){
            return self.rightTopIV
        }
        if self.hitPoint(point: point, in: self.rightBottomIV){
            return self.rightBottomIV
        }
//        if self.hitPoint(point: point, in: self.leftBottomIV){
//            return self.leftBottomIV
//        }
        
//        if let view = super.hitTest(point, with: event), view == self{
//            let p = point.applying(self.transform)
//            if CGRect(x: -10, y: -10, width: 20, height: 20).contains(point) {
//                return self.leftTopIV
//            }
//            if CGRect(x: 10, y: -10, width: 20, height: 20).contains(point) {
//                return self.rightTopIV
//            }
//            if CGRect(x: 10, y: 10, width: 20, height: 20).contains(point) {
//                return self.rightBottomIV
//            }
//        }
        
        return super.hitTest(point, with: event)
    }
    
    private func hitPoint(point: CGPoint, in view:UIView)->Bool{
        if view.bounds.contains(self.convert(point, to: view)) {
            return true
        }
        return false
    }
}
