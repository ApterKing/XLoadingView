//
//  XLoadingView.swift
//  LegalData
//
//  Created by wangcong on 2018/11/23.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

enum XLoadingViewState: String {
    case success = "加载成功"
    case error = "加载失败，请检查网络"
    case loading = "加载中..."
    case empty = "暂无数据"
}

@objc protocol XLoadingViewDelegate: NSObjectProtocol {
    
    // 点击事件
    @objc optional func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool
    @objc optional func loadingViewDidTapped(_ loadingView: XLoadingView)
    
    // 设置提示
    @objc optional func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage?
    @objc optional func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString?
    
}

public class XLoadingView: UIView {
    
    // 加载
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.addSubview(loadingImageView)
        view.addSubview(loadingShadowImageView)
        return view
    }()
    private lazy var loadingImageView: UIImageView = {
        let imgv = UIImageView()
        if let path = Bundle.main.path(forResource: String(format: "icon_loading@%.0fx", UIScreen.main.scale), ofType: ".png") {
            imgv.image = UIImage(contentsOfFile: path)
        }
        imgv.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 24, height: 24))
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    private lazy var loadingShadowImageView: UIImageView = {
        let imgv = UIImageView()
        if let path = Bundle.main.path(forResource: String(format: "icon_loading_shadow@%.0fx", UIScreen.main.scale), ofType: ".png") {
            imgv.image = UIImage(contentsOfFile: path)
        }
        imgv.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 12))
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    
    // 提示
    private lazy var contentView: UIView = {
        let view = UIView()
        view.addSubview(promptImageView)
        view.addSubview(promptLabel)
        return view
    }()
    private lazy var promptImageView: UIImageView = {
        let imgv = UIImageView()
        if let path = Bundle.main.path(forResource: String(format: "icon_prompt@%.0fx", UIScreen.main.scale), ofType: ".png") {
            imgv.image = UIImage(contentsOfFile: path)
        }
        imgv.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 120, height: 120))
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    private lazy var promptLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.darkGray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var timer: CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(_animate))
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
        if #available(iOS 10, *) {
            displayLink.preferredFramesPerSecond = 40
        } else {
            displayLink.frameInterval = 40
        }
        displayLink.isPaused = true
        return displayLink
    }()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(_tapAction))
        return gesture
    }()
    private var isUp = true
    
    /// MARK: outter
    var delegate: XLoadingViewDelegate? {
        didSet {
            if delegate?.loadingViewShouldEnableTap?(self) ?? false {
                contentView.addGestureRecognizer(tapGesture)
            }
        }
    }
    var state: XLoadingViewState = .loading {
        didSet {
            _resetState()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        addSubview(loadingView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        promptImageView.frame = CGRect(origin: CGPoint(x: (contentView.width - promptImageView.width) / 2.0, y: (contentView.height - promptImageView.height) / 2.0 - 10), size: promptImageView.frame.size)
        promptLabel.frame = CGRect(x: 0, y: promptImageView.y + promptImageView.height, width: contentView.width, height: 20)
        
        loadingView.frame = CGRect(x: (width - 40) / 2.0, y: (height - 80) / 2.0, width: 40, height: 80)
        loadingShadowImageView.frame = CGRect(origin: CGPoint(x: (loadingView.width - loadingShadowImageView.width) / 2.0, y: loadingView.height - loadingShadowImageView.height), size: loadingShadowImageView.frame.size)
        loadingImageView.frame = CGRect(origin: CGPoint(x: (loadingView.width - loadingImageView.width) / 2.0, y: loadingShadowImageView.y - loadingImageView.height), size: loadingImageView.frame.size)
        
        _resetState()
    }
    
    deinit {
        timer.invalidate()
    }
}

extension XLoadingView {
    
    @objc private func _resetState() {
        if state == .loading {
            timer.isPaused = false
            contentView.isHidden = true
            loadingView.isHidden = false
        } else {
            timer.isPaused = true
            contentView.isHidden = false
            loadingView.isHidden = true
        }
        
        if let image = delegate?.loadingViewPromptImage?(self) {
            promptImageView.image = image
        } else if let path = Bundle.main.path(forResource: String(format: "icon_prompt@%.0fx", UIScreen.main.scale), ofType: ".png") {
            promptImageView.image = UIImage(contentsOfFile: path)
        }
        
        if let text = delegate?.loadingViewPromptText?(self) {
            promptLabel.attributedText = text
        } else {
            promptLabel.text = state.rawValue
        }
    }
    
    @objc private func _tapAction() {
        delegate?.loadingViewDidTapped?(self)
    }
    
    // 这里不使用UIView隐式动画的原因是，多个loadingView时，存在动画中断
    @objc private func _animate() {
        
        var step: CGFloat = 10
        if #available(iOS 10, *) {
            step = (loadingView.height - loadingShadowImageView.height) / CGFloat(timer.preferredFramesPerSecond) * 1.5
        } else {
            step = (loadingView.height - loadingShadowImageView.height) / CGFloat(timer.frameInterval) * 1.5
        }
        
        loadingImageView.y = loadingImageView.y + (isUp ? -step : step)
        let scale = loadingImageView.y / (loadingView.height - loadingShadowImageView.height - loadingImageView.height) / 2.0
        loadingShadowImageView.transform = CGAffineTransform(scaleX: 0.7 + scale, y: 0.7 + scale)
        if isUp {
            isUp = loadingImageView.y > 0
        } else {
            isUp = loadingImageView.y > loadingView.height - loadingShadowImageView.height - loadingImageView.height
        }
    }
    
}
