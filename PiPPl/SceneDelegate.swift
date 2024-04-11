//
//  SceneDelegate.swift
//  PiPPl
//
//  Created by 김민택 on 1/16/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)

        let localPlayerView = UINavigationController(rootViewController: LocalVideoGalleryViewController())
        let networkPlayerView = UINavigationController(rootViewController: NetworkPlayerViewController())
        let appInfoView = UINavigationController(rootViewController: AppInfoViewController())
        let views = [localPlayerView, networkPlayerView, appInfoView]
        configureBarAppearance(views)

        if UIDevice.current.systemName == "iOS" {
            let tabbar = UITabBarController()

            localPlayerView.tabBarItem = UITabBarItem(title: AppText.localVideo, image: UIImage(systemName: "play.square"), selectedImage: UIImage(systemName: "play.square.fill"))
            networkPlayerView.tabBarItem = UITabBarItem(title: AppText.networkVideo, image: UIImage(systemName: "globe"), selectedImage: UIImage(systemName: "globe"))
            appInfoView.tabBarItem = UITabBarItem(title: AppText.appInfo, image: UIImage(systemName: "info.circle"), selectedImage: UIImage(systemName: "info.circle.fill"))
            tabbar.setViewControllers(views, animated: true)

            window?.rootViewController = tabbar
        } else if UIDevice.current.systemName == "iPadOS" {
            let splitView = UISplitViewController(style: .doubleColumn)
            splitView.setViewController(ViewListViewController(), for: .primary)
            splitView.setViewController(localPlayerView, for: .secondary)

            window?.rootViewController = splitView
        }

        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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

    private func configureBarAppearance(_ views: [UINavigationController]) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        let toolBarAppearance = UIToolbarAppearance()
        toolBarAppearance.configureWithDefaultBackground()

        views.forEach {
            $0.navigationBar.standardAppearance = navBarAppearance
            $0.navigationBar.compactAppearance = navBarAppearance
            $0.navigationBar.compactScrollEdgeAppearance = navBarAppearance
            $0.navigationBar.scrollEdgeAppearance = navBarAppearance
            $0.toolbar.standardAppearance = toolBarAppearance
            $0.toolbar.compactAppearance = toolBarAppearance
            $0.toolbar.scrollEdgeAppearance = toolBarAppearance
            $0.toolbar.compactScrollEdgeAppearance = toolBarAppearance
        }
    }

}
