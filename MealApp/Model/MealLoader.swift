import Foundation

/// Loads meal data from themealdb.com API.
final class MealLoader: Sendable {
  static let shared = MealLoader(session: .shared)
  private let session: URLSession

  init(session: URLSession) {
    self.session = session
  }

  enum Error: Swift.Error {
    case invalidCategoryURL(baseURL: String, categoryName: String)
    case invalidMealURL(baseURL: String, mealID: String)
    case cannotFindMeal(mealID: String)
  }

  /// Loads a single category from themealdb.com API.
  /// The returned meals are sorted alphabetically by name, and the meals are guaranteed to have
  /// unique IDs (to ensure SwiftUI components that use the ID work correctly, such as `List`).
  /// - Parameter name: The category name.
  /// - Returns: The array of meals for the category sorted alphabetically by name.
  /// - Throws: If an error occurs when loading the category. This can be a `MealLoader.Error` or an
  ///   error propagated from `URLSession` or `JSONDecoder`.
  func loadCategory(name: String) async throws -> [Meal] {
    let (data, _) = try await session.data(from: categoryURL(name: name))
    let jsonMeals = try JSONDecoder().decode(JSONResult.self, from: data).meals ?? []
    var mealIDs = Set<String>(minimumCapacity: jsonMeals.count)
    return jsonMeals
      .compactMap { Meal(jsonMeal: $0) }  // Convert to Meal discarding nil (invalid) values.
      .filter { mealIDs.insert($0.id).inserted }  // Dedupe IDs to guarantee meal IDs are unique.
      .sorted { $0.name.lowercased() < $1.name.lowercased() }  // Sort alphabetically by name.
  }

  /// Loads a single meal with its instructions and ingredients.
  /// - Parameter id: The meal ID.
  /// - Returns: The meal with its instructions and ingredients.
  /// - Throws: If an error occurs when loading the meal. This can be a `MealLoader.Error` or an
  ///   error propagated from `URLSession` or `JSONDecoder`.
  func loadMeal(id: String) async throws -> Meal {
    let (data, _) = try await session.data(from: mealURL(id: id))
    guard let jsonMeal = try JSONDecoder().decode(JSONResult.self, from: data).meals?.first,
          let meal = Meal(jsonMeal: jsonMeal) else {
      throw Error.cannotFindMeal(mealID: id)
    }
    return meal
  }

  /// Generates a URL for themealdb.com API that fetches a category.
  /// - Parameter name: The category name.
  /// - Returns: The category URL.
  /// - Throws: `MealLoader.Error.invalidCategoryURL` if a valid URL cannot be constructed.
  private func categoryURL(name: String) throws -> URL {
    let baseURL = "https://themealdb.com/api/json/v1/1/filter.php"
    var builder = URLComponents(string: baseURL)
    builder?.queryItems = [.init(name: "c", value: name)]
    guard let url = builder?.url else {
      throw Error.invalidCategoryURL(baseURL: baseURL, categoryName: name)
    }
    return url
  }

  /// Generates a URL for themealdb.com API that fetches a meal.
  /// - Parameter name: The meal ID.
  /// - Returns: The meal URL.
  /// - Throws: `MealLoader.Error.invalidMealURL` if a valid URL cannot be constructed.
  private func mealURL(id: String) throws -> URL {
    let baseURL = "https://themealdb.com/api/json/v1/1/lookup.php"
    var builder = URLComponents(string: baseURL)
    builder?.queryItems = [.init(name: "i", value: id)]
    guard let url = builder?.url else {
      throw Error.invalidMealURL(baseURL: baseURL, mealID: id)
    }
    return url
  }
}
