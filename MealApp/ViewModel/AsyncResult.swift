import Foundation
import Observation
import OSLog

/// An asynchronously loaded result which supports various states needed for displaying a user-
/// friendly UI. For example, while the async request is in progress, a loading indicator can be
/// displayed by the UI.
@MainActor
@Observable
class AsyncResult<Value: Sendable> {
  /// Various states of the async request.
  enum State {
    case notStarted
    case inProgress
    case success
    case failure
  }

  /// The value from the most recent successful async request.
  private(set) var value: Value? = nil
  /// The current state of the async request.
  private(set) var state = State.notStarted

  /// Loads the underlying value by performing an async request if a previous request hasn't already
  /// occurred. Updates the `value` and `state` properties accordingly.
  /// - Parameter body: A closure that generates the underlying value.
  func loadIfNeeded(body: @Sendable () async throws -> Value) async {
    await performRequest(refresh: false, body: body)
  }

  /// Refreshes the underlying value by performing another async request regardless whether a
  /// previous request has occurred. Updates the `value` and `state` properties accordingly.
  /// - Parameter body: A closure that generates the underlying value.
  func refresh(body: @Sendable () async throws -> Value) async {
    await performRequest(refresh: true, body: body)
  }

  /// Performs the async request for the `loadIfNeeded` or `refresh` methods.
  /// - Parameters:
  ///   - refresh: Whether this is a refresh or not.
  ///   - body: A closure that generates the underlying value.
  private func performRequest(refresh: Bool, body: @Sendable () async throws -> Value) async {
    if state == .inProgress { return }
    guard state == .notStarted || refresh else { return }

    state = .inProgress
    Logger().trace("Request in progress")
    
    do {
      value = try await body()
      state = .success
      Logger().trace("Request succeeded")
    } catch {
      state = .failure
      Logger().debug("Request failed: \(error)")
    }
  }
}
