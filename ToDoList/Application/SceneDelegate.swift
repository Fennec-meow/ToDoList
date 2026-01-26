import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        
        let listViewController = TaskListRouter.createModule()
        
        let navigationController = UINavigationController(rootViewController: listViewController)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypBlack
        appearance.titleTextAttributes = [.foregroundColor: UIColor.ypWhite]
        appearance.shadowColor = .clear
        
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.tintColor = .ypYellow
        navigationController.navigationBar.isHidden = true 
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
