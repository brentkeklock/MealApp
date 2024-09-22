import SwiftUI

/// Displays all meals in a single category.
struct CategoryView: View {
  let categoryName: String
  @State private var categoryResult = AsyncResult<[Meal]>()

  var body: some View {
    List(categoryResult.value ?? []) { meal in
      NavigationLink {
        MealView(mealID: meal.id)
      } label: {
        HStack {
          AsyncImage(url: meal.thumbnail) { phase in
            phase.image?
              .resizable()
              .scaledToFit()
          }
          .frame(width: 75, height: 75)
          Text(meal.name)
        }
      }
      .listRowSeparator(.hidden)
    }
    .overlay {
      if categoryResult.value == nil {
        if categoryResult.state == .inProgress {
          ProgressView()
            .controlSize(.large)
        } else if categoryResult.state == .failure {
          ContentUnavailableView(
            "Error",
            systemImage: "exclamationmark.triangle",
            description: Text("An error occurred when loading the meals"))
        }
      }
    }
    .navigationTitle(categoryName)
    .navigationBarTitleDisplayMode(.inline)
    .listStyle(.plain)
    .task {
      await categoryResult.loadIfNeeded {
        try await MealLoader.shared.loadCategory(name: categoryName)
      }
    }
    .refreshable {
      await categoryResult.refresh {
        try await MealLoader.shared.loadCategory(name: categoryName)
      }
    }
  }
}
