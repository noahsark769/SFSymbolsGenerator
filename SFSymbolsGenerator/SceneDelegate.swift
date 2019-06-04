//
//  SceneDelegate.swift
//  SFSymbolsGenerator
//
//  Created by Noah Gilmore on 6/3/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit
import SwiftUI
import CoreImage

extension UIImage {

    func tinted(color: UIColor) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        guard let cgImage = cgImage else { return self }

        // flip the image
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)

        // multiply blend mode
        context.setBlendMode(.multiply)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)

        // create uiimage
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()

        return newImage

    }

}

extension FileManager {
    var documentsDirectory: URL {
        return self.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
}

struct StyledSystemImage {
    let style: UIUserInterfaceStyle
    let image: UIImage

    init(name: String, style: UIUserInterfaceStyle) {
        let image = UIImage(systemName: name)!
        let sizedImage = image.applyingSymbolConfiguration(UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50)))!
        self.image = style == .light ? sizedImage.tinted(color: .white) : sizedImage
        self.style = style
    }

    var filename: String {
        switch style {
        case .dark: return "dark.png"
        case .light: return "light.png"
        default: fatalError()
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: ContentView())
        self.window = window
        window.makeKeyAndVisible()

        for name in Symbols.symbols {
            self.export(name: name)
        }
    }

    // "waveform.path.badge.minus"
    func export(name: String) {
        let darkImage = StyledSystemImage(name: name, style: .dark)
        let lightImage = StyledSystemImage(name: name, style: .light)
        let destinationDirectory = FileManager.default.documentsDirectory
            .appendingPathComponent("export")
            .appendingPathComponent(name)
        try! FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)

        for image in [darkImage, lightImage] {
            let finalPath = destinationDirectory.appendingPathComponent(image.filename).path
            print("Exporting: \(name) to \(finalPath)")
            FileManager.default.createFile(
                atPath: finalPath,
                contents: image.image.pngData(),
                attributes: nil
            )
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

