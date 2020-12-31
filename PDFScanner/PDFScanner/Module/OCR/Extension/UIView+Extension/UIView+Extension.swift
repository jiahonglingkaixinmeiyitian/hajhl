
import UIKit

extension UIView {
    
    //  x
    var x: CGFloat {
        
        get {
            
            return frame.origin.x
        }
        set (newVal) {
            
            var tempFrame: CGRect = frame
            tempFrame.origin.x = newVal
            frame = tempFrame
        }
    }
    
    //  y
    var y: CGFloat {
        
        get {
            
            return frame.origin.y
        }
        set (newVal) {
            
            var tempFrame: CGRect = frame
            tempFrame.origin.y = newVal
            frame = tempFrame
        }
    }
    
    //  width
    var width: CGFloat {
        
        get {
            
            return frame.size.width
        }
        set (newVal) {
            
            var tempFrame: CGRect = frame
            tempFrame.size.width = newVal
            frame = tempFrame
        }
    }
    
    var size: CGSize {
        
        get {
            
            return frame.size
        }
        set (newVal) {
            
            var tempFrame: CGRect = frame
            tempFrame.size = newVal
            frame = tempFrame
        }
    }
    
    //  height
    var height: CGFloat {
        
        get {
            
            return frame.size.height
        }
        set (newVal) {
            
            var tempFrame: CGRect = frame
            tempFrame.size.height = newVal
            frame = tempFrame
        }
    }
    
    //  left
    var left: CGFloat {
        
        get {
            
            return x
        }
        set (newVal) {
            
            x = newVal
        }
    }
    
    //  right
    var right : CGFloat {
        
        get {
            
            return x + width
        }
        
        set(newVal) {
            
            x = newVal - width
        }
    }
    
    //  top
    var top : CGFloat {
        
        get {
            
            return y
        }
        
        set(newVal) {
            
            y = newVal
        }
    }
    
    //  bottom
    var bottom : CGFloat {
        
        get {
            
            return y + height
        }
        
        set(newVal) {
            
            y = newVal - height
        }
    }
    
    //  centerX
    var centerX : CGFloat {
        
        get {
            
            return center.x
        }
        
        set(newVal) {
            
            center = CGPoint(x: newVal, y: center.y)
        }
    }
    
    //  centerY
    var centerY : CGFloat {
        
        get {
            
            return center.y
        }
        
        set(newVal) {
            
            center = CGPoint(x: center.x, y: newVal)
        }
    }
    
    //  middleX
    var middleX : CGFloat {
        
        get {
            
            return width / 2
        }
    }
    
    //  middleY
    var middleY : CGFloat {
        
        get {
            
            return height / 2
        }
    }
    
    //  middlePoint
    var middlePoint : CGPoint {
        
        get {
            
            return CGPoint(x: middleX, y: middleY)
        }
    }
    
    //  rightBottomPoint
    var rightBottomPoint : CGPoint {
        
        get {
            
            return CGPoint(x: width, y: height)
        }
    }
    
    class func loadXib<T>(owner:Any? = nil)->T? where T:UIView{
        if let view = Bundle.main.loadNibNamed(T.getClassName(), owner: owner, options: nil)?.first as? T{
            return view
        }
        return nil
    }
    
    class func loadXib(anyClass:AnyClass, owner:Any? = nil)->UIView?{
        if let view = Bundle.main.loadNibNamed(NSObject.getClassName(anyClass: anyClass), owner: owner, options: nil)?.first as? UIView{
            return view
        }
        return nil
    }
    
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    func removeAllSubviews() {
        
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
}



