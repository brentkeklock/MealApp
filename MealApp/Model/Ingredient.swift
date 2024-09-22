import Foundation

/// A single ingredient for a meal.
struct Ingredient: Identifiable {
  let id = UUID()
  var name: String
  var amount: String
}
