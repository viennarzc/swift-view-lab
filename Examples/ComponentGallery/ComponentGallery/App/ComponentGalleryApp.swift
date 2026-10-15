import SwiftUI

@main
struct ComponentGalleryApp: App {
    var body: some Scene {
        WindowGroup {
            CatalogView()
                .tint(.indigo)
        }
    }
}
