import Foundation

extension HealthDataFetcher {
    func fetchAndProcessHealthData() async throws -> [HealthData] {
        try await requestAuthorization()
        
        let calendar = Calendar.current
        let today = Date()
        var healthData: [HealthData] = []
        
        for day in 0...13 {
            guard let endDate = calendar.date(byAdding: .day, value: -day, to: today) else { continue }
            healthData.append(
                HealthData(
                    date: DateFormatter.localizedString(from: endDate, dateStyle: .short, timeStyle: .none)
                )
            )
        }
        
        healthData = healthData.reversed()
        
        async let stepCounts = fetchLastTwoWeeksStepCount()
        async let sleepHours = fetchLastTwoWeeksSleep()
        async let caloriesBurned = fetchLastTwoWeeksActiveEnergy()
        async let distanceWalkingRunning = fetchLastTwoWeeksDistanceWalkingRunning()
        
        let fetchedStepCounts = try await stepCounts
        let fetchedSleepHours = try await sleepHours
        let fetchedCaloriesBurned = try await caloriesBurned
        let fetchedDistanceWalkingRunning = try await distanceWalkingRunning

        let minDays = [
            fetchedStepCounts.count,
            fetchedSleepHours.count,
            fetchedCaloriesBurned.count,
            fetchedDistanceWalkingRunning.count,
        ].min() ?? 0
        
        for day in 0..<minDays {
            healthData[day].steps = fetchedStepCounts[day]
            healthData[day].sleepHours = fetchedSleepHours[day]
            healthData[day].activeEnergy = fetchedCaloriesBurned[day]
            healthData[day].distanceWalkingRunning = fetchedDistanceWalkingRunning[day]
        }
        
        return healthData
    }
}
