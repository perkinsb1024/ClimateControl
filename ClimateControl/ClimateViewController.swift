//
//  ClimateViewController.swift
//  ClimateControl
//
//  Created by Ben Perkins on 12/28/17.
//  Copyright © 2017 Ben Perkins. All rights reserved.
//
// Thanks to the following tutorials:
//  - Make a menubar app: https://www.raywenderlich.com/165853/menus-popovers-menu-bar-apps-macos
//  - Launch program at startup: https://theswiftdev.com/2017/10/27/how-to-launch-a-macos-app-at-login/

import Cocoa
import WebKit
import ServiceManagement

class ClimateViewController: NSViewController, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var zoomLabel: NSTextField!
    var zoom: CGFloat = 1
    var settingsMenu = NSMenu()
    var startAtLoginMenuItem = NSMenuItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appVersion = getAppVersionString(longForm: false)
        loadWebPage(withUrl: "https://home.nest.com")
        
        // Create settings menu
        startAtLoginMenuItem = NSMenuItem(title: "Start with computer", action: #selector(toggleStartAtLogin), keyEquivalent: "")
        settingsMenu.addItem(startAtLoginMenuItem)
        settingsMenu.addItem(NSMenuItem(title: "About (\(appVersion))", action: #selector(showAbout), keyEquivalent: ""))
        settingsMenu.addItem(NSMenuItem.separator())
        settingsMenu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: ""))
        
        let startAtLogin = UserDefaults.standard.bool(forKey: "startAtLogin")
        startAtLoginMenuItem.state = startAtLogin ? .on : .off
        print("Start at login: \(startAtLogin)")
    }
    
    func getAppVersionString(longForm includeBundle: Bool) -> String {
        let appInfo = Bundle.main.infoDictionary
        let shortVersionString = appInfo?["CFBundleShortVersionString"] as? String
        let bundleVersion = appInfo?["CFBundleVersion"] as? String
        if includeBundle {
            return "Version \(shortVersionString ?? "0.0") (Build \(bundleVersion ?? "0"))"
        }
        return "v\(shortVersionString ?? "0.0")"
    }
    
    @objc func toggleStartAtLogin() {
        let startAtLogin = startAtLoginMenuItem.state
        let newState = (startAtLogin == NSControl.StateValue.on) ? NSControl.StateValue.off : NSControl.StateValue.on
        let shouldStartAtLogin = (newState == NSControl.StateValue.on)
        startAtLoginMenuItem.state = shouldStartAtLogin ? NSControl.StateValue.on : NSControl.StateValue.off
        UserDefaults.standard.setValue(shouldStartAtLogin, forKey: "startAtLogin")
        print("Start at login: \(shouldStartAtLogin)")
        setStartAtLogin(shouldStartAtLogin)
    }
    
    @objc func showAbout() {
        (NSApplication.shared.delegate as? AppDelegate)?.closePopover(sender: nil)
        let versionStringLong = getAppVersionString(longForm: true)
        let titleString = "ClimateControl - \(versionStringLong)"
        let byString = "Written by Ben Perkins\n"
        
        let thanksString1 = "Thanks to the following tutorials:"
        let thanksString2 = " - www.raywenderlich.com/165853"
        let thanksString3 = " - www.github.com/theswiftdev/macos-launch-at-login-app"
        
        let alert = NSAlert()
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Give Feedback")
        alert.messageText = "\(titleString)"
        alert.informativeText = "\(byString)\n\(thanksString1)\n\(thanksString2)\n\(thanksString3)"
        let buttonClicked = alert.runModal()
        
        if(buttonClicked == .alertSecondButtonReturn) {
            giveFeedback()
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func giveFeedback() {
        let appVersion = getAppVersionString(longForm: true).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Unknown"
        let osVersion = (ProcessInfo.processInfo.operatingSystemVersionString).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Unknown"
        let mailto = "mailto:engineersighted+climatecontrol@gmail.com?Subject=Feedback%20for%20ClimateControl&Body=%0A%0A---------------------------------------------%0APlease%20provide%20your%20feedback%20for%20ClimateControl%20above%20this%20line%0AIf%20you%20are%20submitting%20a%20bug%20report%2C%20please%20include%3A%0A%20-%20Steps%20to%20reproduce%20the%20bug%0A%20-%20How%20often%20it%20occurs%20%28rarely%2C%20sometimes%2C%20always%29%0A%20-%20A%20screenshot%2C%20if%20relevant%20%28press%20command+shift+3%20to%20save%20a%20screenshot%20to%20your%20desktop%29%0A---------------------------------------------%0ADiagnostic%20information%3A%0A%20-%20App%20version%3A%20\(appVersion)%0A%20-%20MacOS%20Version%3A%20\(osVersion)"
        let url = URL(string:mailto)
        if let url = url {
            NSWorkspace.shared.open(url)
        } else {
            print("invalid URL");
        }
    }
    
    func setStartAtLogin(_ shouldStart: Bool) {
        let launcherAppId = "com.benperkins.ClimateLauncher"
        let runningApps = NSWorkspace.shared.runningApplications
        let launcherIsRunning = !runningApps.filter { $0.bundleIdentifier == launcherAppId }.isEmpty
        
        print("Setting SMLoginItemSetEnabled to: \(shouldStart)")
        let response = SMLoginItemSetEnabled(launcherAppId as CFString, shouldStart)
        print("SMLoginItemSetEnabled response: \(response)")
        
        if launcherIsRunning {
            DistributedNotificationCenter.default().post(name: .killLauncher,
                                                         object: Bundle.main.bundleIdentifier!)
        }
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
    
    @IBAction func handleSettingButtonClick(_ sender: NSButton) {
        print("Settings")
        
//        NSMenu.popUpContextMenu(settingsMenu, with: NSEvent.mouseEvent(with: NSEvent.EventType.leftMouseDown, location: NSPoint(x: 800, y: -800), modifierFlags: NSEvent.ModifierFlags.control, timestamp: TimeInterval(), windowNumber: 0, context: nil, eventNumber: 0, clickCount: 1, pressure: 1)!, for: self.view)
        
        // [theMenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
        settingsMenu.popUp(positioning: nil, at: NSPoint(x: NSEvent.mouseLocation.x, y: NSEvent.mouseLocation.y - 20), in: nil)
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
