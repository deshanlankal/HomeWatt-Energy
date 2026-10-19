
import SwiftUI

struct ContentView: View {

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                MainSidebarView()
            } else {
                MainTabView()
            }
        }
    }
}

#Preview {
    ContentView()
}
