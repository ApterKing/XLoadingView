//
//  ViewController.swift
//  LoadingView
//
//  Created by wangcong on 2018/11/23.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let loading = XLoadingView(frame: UIScreen.main.bounds)
        loading.delegate = self
        loading.state = .error
        view.addSubview(loading)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: XLoadingViewDelegate {
    
    func loadingViewShouldEnableTap(_ loadingView: XLoadingView) -> Bool {
        return true
    }
    
    func loadingViewDidTapped(_ loadingView: XLoadingView) {
        loadingView.state = .loading
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
            loadingView.state = .error
        }
    }
    
    func loadingViewPromptImage(_ loadingView: XLoadingView) -> UIImage? {
        return UIImage(named: "icon_prompt")
    }
    
    func loadingViewPromptText(_ loadingView: XLoadingView) -> NSAttributedString? {
        switch loadingView.state {
        case .error:
            return NSAttributedString(string: "网络未连接，点击重新加载", attributes: [NSAttributedStringKey.foregroundColor: UIColor.darkGray])
        default:
            return nil
        }
    }
    
}
