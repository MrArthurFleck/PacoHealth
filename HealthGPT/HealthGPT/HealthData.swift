import Foundation


struct HealthData: Codable {
    var date: String
    var steps: Double?
    var activeEnergy: Int?
    var bodyMass: Double?
    var sleepHours: Double?
    var heartRate: Double?
    var distanceWalkingRunning: Double?
}
