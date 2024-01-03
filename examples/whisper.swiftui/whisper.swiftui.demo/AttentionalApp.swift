import SwiftUI


@main
struct AttentionalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView().environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
        }
    }
}
