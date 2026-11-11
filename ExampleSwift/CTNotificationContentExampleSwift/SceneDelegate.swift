import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()

        connectionOptions.urlContexts.forEach { urlContext in
            handle(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        URLContexts.forEach { urlContext in
            handle(urlContext.url)
        }
    }

    private func handle(_ url: URL) {
        print("SCENEDELEGATE: open url \(url)")
        showAlert(message: "SCENEDELEGATE: open url \(url)")
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Deeplink", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        window?.rootViewController?.present(alertController, animated: true)
    }
}
