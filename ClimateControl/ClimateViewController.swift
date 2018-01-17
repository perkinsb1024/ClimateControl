//
//  ClimateViewController.swift
//  ClimateControl
//
//  Created by Ben Perkins on 12/28/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//

import Cocoa
import WebKit

class ClimateViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var zoomLabel: NSTextField!
    var zoom: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebPage(withUrl: "https://home.nest.com")
        //loadWebPage(withUrl: "http://ryanve.com/lab/dimensions/")
        webView.allowsMagnification = true
        
    }
    
    func loadWebPage(withUrl string: String) {
        let url = URL(string: string)
        guard let safeUrl = url else {
            print("Invalid URL")
            return;
        }
        webView.load(URLRequest(url: safeUrl))
        
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Start loading")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Finish loading")
    }
    
    @IBAction func reloadButtonPressed(_ sender: NSButton) {
        loadWebPage(withUrl: "https://home.nest.com")
    }
    
    @IBAction func logOutButtonPressed(_ sender: NSButton) {
        loadWebPage(withUrl: "https://home.nest.com/login")
    }
    
    @IBAction func handleZoomSlider(_ sender: NSSlider) {
        let triggerEvent = NSApplication.shared.currentEvent
        var zoom = sender.doubleValue
        if(zoom < 0.25) {
            zoom = 0.25
        }
        else if(zoom > 2) {
            zoom = 2
        }
        if(zoom >= 0.9 && zoom <= 1.1) {
            zoom = 1
        }
        sender.doubleValue = zoom
        webView.magnification = CGFloat(zoom)
        if(triggerEvent?.type == .leftMouseUp) {
            zoomLabel.stringValue = "Zoom"
        }
        else {
            zoomLabel.stringValue = String.localizedStringWithFormat("%0.2f", zoom)
        }
        //        let script = "document.body.style.zoom = \(zoom)"
        //        let script =
        //            "var viewport = document.querySelector(\"meta[name=viewport]\");" +
        //        "viewport.setAttribute('content', 'width=device-width, initial-scale=\(zoom), user-scalable=0');"
        //        webView.evaluateJavaScript(script) { (result, error) in
        //            if error != nil {
        //                print(error!.localizedDescription)
        //            }
        //        }
        //        webView.enclosingScrollView!.magnification = CGFloat(zoom)
        //        webView.setMagnification(CGFloat(zoom), centeredAt: CGPoint(x: 0, y: 0))
    }
    
}

extension ClimateViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> ClimateViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "ClimateViewController")
        //3.
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? ClimateViewController else
        {
            fatalError("Why cant I find ClimateViewController? - Check Main.storyboard")
        }
        return viewController
    }
}
