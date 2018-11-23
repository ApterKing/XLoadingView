//
//  UIView+Extension.swift
//  Swift-X
//
//  Created by wangcong on 22/03/2017.
//  Copyright © 2017 ApterKing. All rights reserved.
//

import UIKit

// MARK: FirstViewController
public extension UIView {
    var firstViewController: UIViewController? {
        get {
            for view in sequence(first: self.superview, next: { $0?.superview }) {
                if let responder = view?.next, responder.isKind(of: UIViewController.self) {
                    return responder as? UIViewController
                }
            }
            return nil
        }
    }
}

// MARK: Frame
public extension UIView {
    
    public var x: CGFloat {
        get { return frame.x }
        set { frame.x = newValue }
    }
    
    public var y: CGFloat {
        get { return frame.y }
        set { frame.y = newValue }
    }
    
    public var width: CGFloat {
        get { return frame.width }
        set { frame.width = newValue }
    }
    
    public var height: CGFloat {
        get { return frame.height }
        set { frame.height = newValue }
    }
    
    public var top: CGFloat {
        get { return y }
        set { y = newValue }
    }
    
    public var left: CGFloat {
        get { return x }
        set { x = newValue }
    }
    
    public var bottom: CGFloat {
        get { return y + height }
        set { y = newValue - height }
    }
    
    public var right: CGFloat {
        get { return x + width }
        set { x = newValue - width }
    }
}

// MARK: Round
public extension UIView {
    
    public func round(byRoundingCorners: UIRectCorner = UIRectCorner.allCorners, cornerRadi: CGFloat) {
        self.round(byRoundingCorners: byRoundingCorners, cornerRadii: CGSize(width: cornerRadi, height: cornerRadi))
    }
    
    public func round(byRoundingCorners: UIRectCorner = UIRectCorner.allCorners, cornerRadii: CGSize) {
        guard let maskLayer = self.layer.mask else {
            let rect = self.bounds
            let bezierPath = UIBezierPath(roundedRect: rect,
                                          byRoundingCorners: byRoundingCorners,
                                          cornerRadii: cornerRadii)
            defer {
                bezierPath.close()
            }
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = bezierPath.cgPath
            self.layer.mask = shapeLayer
            self.layer.masksToBounds = true
            return
        }
    }
}

// MARK: UIView 快照
public extension UIView {
    
    public var snapshotImage: UIImage? {
        return snapshot()
    }
    
    public func snapshot(rect: CGRect = CGRect.zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        var snapRect = rect
        if __CGSizeEqualToSize(rect.size, CGSize.zero) {
            snapRect = calculateSnapshotRect()
        }
        UIGraphicsBeginImageContextWithOptions(snapRect.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        self.drawHierarchy(in: snapRect, afterScreenUpdates: false)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 计算UIView所显示内容Rect
    func calculateSnapshotRect() -> CGRect {
        var targetRect = self.bounds
        if let scrollView = self as? UIScrollView {
            let contentInset = scrollView.contentInset
            let contentSize = scrollView.contentSize
            
            targetRect.origin.x = contentInset.left
            targetRect.origin.y = contentInset.top
            targetRect.size.width = targetRect.size.width  - contentInset.left - contentInset.right > contentSize.width ? targetRect.size.width  - contentInset.left - contentInset.right : contentSize.width
            targetRect.size.height = targetRect.size.height - contentInset.top - contentInset.bottom > contentSize.height ? targetRect.size.height  - contentInset.top - contentInset.bottom : contentSize.height
        }
        return targetRect
    }
    
}
