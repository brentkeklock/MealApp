import Foundation

/// A single query result containing zero or more meals as returned by the themealdb.com API.
struct JSONResult: Codable {
  var meals: [JSONMeal]?
}
