import Foundation


enum HealthDataFetcherError: Error {
    case healthDataNotAvailable
    case invalidObjectType
    case resultsNotFound
    case authorizationFailed
}
