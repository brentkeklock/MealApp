import Foundation

/// A single meal returned by the MealLoader.
struct Meal: Identifiable {
  let id: String
  var name: String
  var thumbnail: URL?
  var instructions: String?
  var ingredients: [Ingredient]
}
