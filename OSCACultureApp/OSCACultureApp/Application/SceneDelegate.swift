//
//  SceneDelegate.swift
//  OSCACultureApp
//
//  Created by Stephan Breidenbach on 21.09.22.
//

import UIKit
import OSCAEssentials

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?
  
  lazy var oscaCultureAppFlow: OSCACultureAppFlow = {
    guard let window = window,
          let _ = window.rootViewController,
          let appDI = self.appDI
    else { fatalError("The Application Flow coordinator is not properly initialized") }
    
    let coordinator = appDI
      .makeOSCACultureAppFlowDI()
      .makeOSCACultureAppFlow( window: window,
                               onDismissed: oscaCultureAppFlowOnDismissed)
    return coordinator
  }()
  
  let oscaCultureAppFlowOnDismissed: (() -> Void) = {
#if DEBUG
    print("OSCACoreAppFlowOnDismissed: \(#function)")
#endif
  }// end let oscaCultureAppFlowOnDismissed
  
  var appDI: OSCACultureAppDI?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    guard let windowScene = (scene as? UIWindowScene) else { return }
    self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
    guard let window = self.window else {
      fatalError("The Application's main window is not properly initialized")
    }// end guard
    window.windowScene = windowScene
    
    let navigationController = UINavigationController()
    
    window.rootViewController = navigationController
    
    self.appDI = OSCACultureAppDI.create()
    
    self.oscaCultureAppFlow
      .present(animated: true,
               onDismissed: self.oscaCultureAppFlowOnDismissed)
    window.makeKeyAndVisible()
  }// end func scene will connect to session with options

  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func sceneDidDisconnect

  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func sceneDidBecomeActive

  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func sceneWillResignActive

  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func sceneWillEnterForeground

  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func sceneDidEnterBackground
}// end class SceneDelegate

