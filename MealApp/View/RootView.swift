import SwiftUI

struct RootView: View {
  var body: some View {
    NavigationStack {
      CategoryView(categoryName: "Dessert")
    }
  }
}
