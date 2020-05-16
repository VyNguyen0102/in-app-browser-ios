//
//  WebViewController.swift
//  In-app WebViewController
//
//  Created by Vy Nguyen on 4/9/20.
//  Copyright © 2020 VVLab. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var url: URL? = nil

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            self.backButton.addTarget(self.webView, action: #selector(WKWebView.goBack), for: .touchUpInside)
        }
    }
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton! {
        didSet {
            self.forwardButton.addTarget(self.webView, action: #selector(WKWebView.goForward), for: .touchUpInside)
        }
    }
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var backgroundView: UIView! {
        didSet {
            backgroundView.alpha = 0
        }
    }

    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            self.scrollView.delegate = self
        }
    }
    var scrollViewSync: Bool = false

    @IBOutlet weak var webView: WKWebView! {
        didSet {
            self.webView.scrollView.delegate = self
            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        }
    }

    convenience init(url: URL) {
        self.init(nibName: "WebViewController", bundle: nil)
        self.url = url
        self.modalPresentationStyle = .overCurrentContext
        self.view.backgroundColor = UIColor.clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            siteNameLabel.text = url.absoluteString
            webView.load(URLRequest.init(url: url))
        }
        scrollView.scrollRectToVisible(webView.frame, animated: true)
        self.backButton?.isEnabled = self.webView.canGoBack
        self.forwardButton?.isEnabled = self.webView.canGoForward
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? WKWebView {
            if keyPath == #keyPath(WKWebView.title) {
                self.siteNameLabel.text = self.webView.title
            } else if keyPath == #keyPath(WKWebView.canGoBack) {
                self.backButton?.isEnabled = self.webView.canGoBack
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                self.forwardButton?.isEnabled = self.webView.canGoForward
            } else if keyPath == #keyPath(WKWebView.estimatedProgress) {
                let newProgress = self.webView.estimatedProgress
                if Float(newProgress) > progressView.progress {
                    progressView.setProgress(Float(newProgress), animated: true)
                } else {
                    progressView.setProgress(Float(newProgress), animated: false)
                }
                if newProgress >= 1 { // delaying so that user can see progress view reach 100%
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                        self.progressView.isHidden = true
                    })
                } else {
                    progressView.isHidden = false
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.alpha = 1
        }
    }
    

    @IBAction func buttonCloseDidTap(_ sender: Any) {
        closeWithAnimation()
    }

    @IBAction func shareButtonDidTap(_ sender: Any) {
        guard let url = self.webView.url else {
            return
        }
        let sharedObjects:[AnyObject] = [url as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.shareButton
        self.present(activityViewController, animated: true, completion: nil)
    }
    func closeWithAnimation() {
        self.webView.stopLoading()
        self.backgroundView.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }
    func checkScrollViewOffset(isEndDrag: Bool = false) {
        if self.scrollView.contentOffset.y < -100.0 {
            self.closeWithAnimation()
        } else if isEndDrag {
            self.scrollView.setContentOffset(.zero, animated: true)
        }
    }
}

extension WebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            if scrollView.contentOffset.y > 0 {
                scrollView.contentOffset.y = 0
            }
            print("main scroll view did scroll scrollViewSync \(scrollViewSync)")
            backgroundView.alpha = 1 + ( scrollView.contentOffset.y / 100)
            if !scrollViewSync {
                checkScrollViewOffset()
            }
        } else {
            print(scrollView.contentOffset)
            if scrollViewSync && scrollView.contentOffset.y < 0 {
                self.scrollView.setContentOffset(CGPoint.init(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y + scrollView.contentOffset.y ), animated: false)
                scrollView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging\( scrollView.contentOffset)")
        if scrollView != self.scrollView {
            scrollViewSync = true
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging\( scrollView.contentOffset)")
        if scrollView != self.scrollView {
            scrollViewSync = false
            checkScrollViewOffset(isEndDrag: true)
        }
    }
}

