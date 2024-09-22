import SwiftUI

/// Displays a single meal with its ingredients and instructions.
struct MealView: View {
  let mealID: String
  @State private var mealResult = AsyncResult<Meal>()

  var body: some View {
    List {
      if let meal = mealResult.value {
        Section("Ingredients") {
          if meal.ingredients.isEmpty {
            Text("No ingredients listed")
          } else {
            ForEach(meal.ingredients) { ingredient in
              HStack {
                Text(ingredient.name)
                Spacer()
                Text(ingredient.amount)
              }
            }
          }
        }
        Section("Instructions") {
          Text(meal.instructions ?? "No instructions listed")
        }
      }
    }
    .overlay {
      if mealResult.value == nil {
        if mealResult.state == .inProgress {
          ProgressView()
            .controlSize(.large)
        } else if mealResult.state == .failure {
          ContentUnavailableView(
            "Error",
            systemImage: "exclamationmark.triangle",
            description: Text("An error occurred when loading the meal"))
        }
      }
    }
    .navigationTitle(mealResult.value?.name ?? "")
    .task {
      await mealResult.loadIfNeeded {
        try await MealLoader.shared.loadMeal(id: mealID)
      }
    }
    .refreshable {
      await mealResult.refresh {
        try await MealLoader.shared.loadMeal(id: mealID)
      }
    }
  }
}
