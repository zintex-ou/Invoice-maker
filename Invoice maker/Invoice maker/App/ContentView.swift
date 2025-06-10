import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Invoice Maker!")
                .font(.sans(style: .bold, size: 30))

            Text("Invoice Maker!")
                .font(.sans(style: .semiBold, size: 30))

            Text("Invoice Maker!")
                .font(.sans(style: .regular, size: 30))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
