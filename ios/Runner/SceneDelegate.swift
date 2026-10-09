import Flutter
import UIKit
import FirebaseAuth

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    var unhandledContexts: Set<UIOpenURLContext> = []
    for context in URLContexts {
      if !Auth.auth().canHandle(context.url) {
        unhandledContexts.insert(context)
      }
    }
    if !unhandledContexts.isEmpty {
      super.scene(scene, openURLContexts: unhandledContexts)
    }
  }
}

