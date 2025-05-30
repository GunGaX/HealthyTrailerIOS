//
//  UIApplicationExtensions.swift
//  HealthyTrailer
//
//  Created by Dmytro Savka on 09.11.2023.
//

import SwiftUI

extension UIApplication {
    static private var statusBarCache = CGFloat()
    static private var bottomBarCache = CGFloat()
    
    static var statusBarHeight: CGFloat {
        let window = shared.keyWindow
        
        let height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        statusBarCache = max(statusBarCache, height)
        
        return statusBarCache
    }
    
    static var bottomBarHeight: CGFloat {
        let window = UIApplication.shared.keyWindow
        
        let height = window?.safeAreaInsets.bottom ?? 0
        bottomBarCache = max(bottomBarCache, height)
        
        return bottomBarCache
    }
    
    static var windowInterfaceOrientation: UIInterfaceOrientation {
        return UIApplication.shared.keyWindow?.windowScene?.interfaceOrientation ?? .portrait
     }
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        return viewController
    }
}

struct ScreenUtils {
    static var width: CGFloat { UIScreen.main.bounds.width }
    static var height: CGFloat { UIScreen.main.bounds.height }
    static var safeAreaHeight: CGFloat { height - statusBarHeight - bottomBarHeight }
    static var statusBarHeight: CGFloat { UIApplication.statusBarHeight }
    static var bottomBarHeight: CGFloat { UIApplication.bottomBarHeight }
    static var isVerySmallDisplay: Bool { height < 700 }
    static var isSmallDisplay: Bool { height < 815 }
}

extension UIApplication {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? self.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }
}
