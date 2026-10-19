
import SwiftUI

struct ContentView: View {

    var body: some View {

        VStack(spacing: 20) {

            Image(systemName: "bolt.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("HomeWatt")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your Smart Energy Companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Get Started") {
                print("Get Started button tapped")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.top, 20)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ContentView()
}
