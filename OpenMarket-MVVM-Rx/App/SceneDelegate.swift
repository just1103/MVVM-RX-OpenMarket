import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var flowCoordinator: FlowCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let navigationController = UINavigationController()
        window?.rootViewController = navigationController
        
        let flowCoordinator = FlowCoordinator(navigationController: navigationController)
        flowCoordinator.start()
        
        window?.makeKeyAndVisible()
    }
}
