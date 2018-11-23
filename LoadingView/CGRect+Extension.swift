//
//  CGRect+Extension.swift
//  Swift-X
//
//  Created by wangcong on 23/03/2017.
//  Copyright © 2017 ApterKing. All rights reserved.
//

import CoreGraphics

public extension CGRect {
    
    public var x: CGFloat {
        get { return origin.x }
        set { origin.x = newValue }
    }
    
    public var y: CGFloat {
        get { return origin.y }
        set { origin.y = newValue }
    }
    
    public var width: CGFloat {
        get { return size.width }
        set { size.width = newValue }
    }
    
    public var height: CGFloat {
        get { return size.height }
        set { size.height = newValue }
    }
    
}
