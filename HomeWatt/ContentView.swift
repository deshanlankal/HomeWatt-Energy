
import SwiftUI

struct ContentView: View {

    @State private var authViewModel = AuthViewModel()

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if horizontalSizeClass == .regular {
                    MainSidebarView()
                } else {
                    MainTabView()
                }
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .environment(authViewModel)
    }
}

#Preview {
    ContentView()
}
