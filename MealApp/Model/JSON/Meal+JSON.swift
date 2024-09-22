import Foundation

extension Meal {
  /// Initializes the Meal using a JSONMeal.
  /// - Parameter jsonMeal: The JSONMeal value.
  init?(jsonMeal: JSONMeal) {
    guard let id = jsonMeal.idMeal, !id.isEmpty else { return nil }
    guard let name = jsonMeal.strMeal, !name.isEmpty else { return nil }

    self.id = id
    self.name = name
    self.thumbnail = jsonMeal.strMealThumb
    self.instructions = jsonMeal.strInstructions
    self.ingredients = []

    let nameKeyPaths: [KeyPath<JSONMeal, String?>] = [
      \.strIngredient1,
      \.strIngredient2,
      \.strIngredient3,
      \.strIngredient4,
      \.strIngredient5,
      \.strIngredient6,
      \.strIngredient7,
      \.strIngredient8,
      \.strIngredient9,
      \.strIngredient10,
      \.strIngredient11,
      \.strIngredient12,
      \.strIngredient13,
      \.strIngredient14,
      \.strIngredient15,
      \.strIngredient16,
      \.strIngredient17,
      \.strIngredient18,
      \.strIngredient19,
      \.strIngredient20,
    ]
    let amountKeyPaths: [KeyPath<JSONMeal, String?>] = [
      \.strMeasure1,
      \.strMeasure2,
      \.strMeasure3,
      \.strMeasure4,
      \.strMeasure5,
      \.strMeasure6,
      \.strMeasure7,
      \.strMeasure8,
      \.strMeasure9,
      \.strMeasure10,
      \.strMeasure11,
      \.strMeasure12,
      \.strMeasure13,
      \.strMeasure14,
      \.strMeasure15,
      \.strMeasure16,
      \.strMeasure17,
      \.strMeasure18,
      \.strMeasure19,
      \.strMeasure20,
    ]

    for (nameKeyPath, amountKeyPath) in zip(nameKeyPaths, amountKeyPaths) {
      if let ingredientName = jsonMeal[keyPath: nameKeyPath], !ingredientName.isEmpty,
         let ingredientAmount = jsonMeal[keyPath: amountKeyPath], !ingredientAmount.isEmpty {
        self.ingredients.append(.init(name: ingredientName, amount: ingredientAmount))
      }
    }
  }
}
