import HealthKit


class HealthDataFetcher {
    private let healthStore = HKHealthStore()
    
    /// Requests authorization to access the user's health data.
    ///
    /// - Returns: A `Bool` value indicating whether the authorization was successful.
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HKError(.errorHealthDataUnavailable)
        }
        
        let types: Set = [
            HKQuantityType(.stepCount),
            HKQuantityType(.appleExerciseTime),
//           HKQuantityType(.bodyMass),
            HKQuantityType(.distanceWalkingRunning),
//           HKQuantityType(.height),  // New type
            HKCategoryType(.sleepAnalysis),
        ]
        
        try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: types)
    }
    
    /// Fetches the user's health data for the specified quantity type identifier for the last two weeks.
    ///
    /// - Parameters:
    ///   - identifier: The `HKQuantityTypeIdentifier` representing the type of health data to fetch.
    ///   - unit: The `HKUnit` to use for the fetched health data values.
    ///   - options: The `HKStatisticsOptions` to use when fetching the health data.
    /// - Returns: An array of `Double` values representing the daily health data for the specified identifier.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksQuantityData(
        for identifier: HKQuantityTypeIdentifier,
        unit: HKUnit,
        options: HKStatisticsOptions
    ) async throws -> [Double] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            throw HealthDataFetcherError.invalidObjectType
        }
        
        let predicate = createLastTwoWeeksPredicate()
        
        let quantityLastTwoWeeks = HKSamplePredicate.quantitySample(
            type: quantityType,
            predicate: predicate
        )
        
        let query = HKStatisticsCollectionQueryDescriptor(
            predicate: quantityLastTwoWeeks,
            options: options,
            anchorDate: Date.startOfDay(),
            intervalComponents: DateComponents(day: 1)
        )
        
        let quantityCounts = try await query.result(for: healthStore)
        
        var dailyData = [Double]()
        
        quantityCounts.enumerateStatistics(
            from: Date().twoWeeksAgoStartOfDay(),
            to: Date.startOfDay()
        ) { statistics, _ in
            if let quantity = statistics.sumQuantity() {
                dailyData.append(quantity.doubleValue(for: unit))
            } else {
                dailyData.append(0)
            }
        }
        
        return dailyData
        
    }
    
    private static func metersToFeetAndInches(_ meters: Double) -> String {
        let totalInches = meters * 39.3701
        let feet = Int(totalInches) / 12
        let inches = Int(totalInches) % 12
        return "\(feet)' \(inches)\""
    }
    
    /// Fetches the user's DISTANCE WALK/RUN count data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily distance walked/ran in miles.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksDistanceWalkingRunning() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .distanceWalkingRunning,
            unit: HKUnit.mile(),
            options: [.cumulativeSum]
        )
    }
    
    /// Fetches the user's STEP count data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily step counts.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksStepCount() async throws -> [Double] {
        try await fetchLastTwoWeeksQuantityData(
            for: .stepCount,
            unit: HKUnit.count(),
            options: [.cumulativeSum]
        )
    }

    /// Fetches the user's CALORIES data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily active energy burned.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksActiveEnergy() async throws -> [Int] {
        let fetchedData = try await fetchLastTwoWeeksQuantityData(
            for: .activeEnergyBurned,
            unit: HKUnit.largeCalorie(),
            options: [.cumulativeSum]
        )
        // Round each value to the nearest whole number and convert to Int
        return fetchedData.map { Int(round($0)) }
    }

    /// Fetches the user's SLEEP data for the last two weeks.
    ///
    /// - Returns: An array of `Double` values representing daily sleep duration in hours.
    /// - Throws: `HealthDataFetcherError` if the data cannot be fetched.
    func fetchLastTwoWeeksSleep() async throws -> [Double] {
        var dailySleepData: [Double] = []
        
        // We go through all possible days in the last two weeks.
        for day in -14..<0 {
            // We start the calculation at 3 PM the previous day to 3 PM on the day in question.
            guard let startOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: day - 1), to: Date.startOfDay()),
                  let startOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: startOfSleepDay),
                  let endOfSleepDay = Calendar.current.date(byAdding: DateComponents(day: day), to: Date.startOfDay()),
                  let endOfSleep = Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: endOfSleepDay) else {
                dailySleepData.append(0)
                continue
            }
            
            
            let sleepType = HKCategoryType(.sleepAnalysis)
            let dateRangePredicate = HKQuery.predicateForSamples(withStart: startOfSleep, end: endOfSleep, options: .strictEndDate)
            let allAsleepValuesPredicate = HKCategoryValueSleepAnalysis.predicateForSamples(equalTo: HKCategoryValueSleepAnalysis.allAsleepValues)
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [dateRangePredicate, allAsleepValuesPredicate])
            let descriptor = HKSampleQueryDescriptor(
                predicates: [.categorySample(type: sleepType, predicate: compoundPredicate)],
                sortDescriptors: []
            )
            
            let results = try await descriptor.result(for: healthStore)

            var secondsAsleep = 0.0
            for result in results {
                secondsAsleep += result.endDate.timeIntervalSince(result.startDate)
            }
            
            // Append the hours of sleep for that date
            dailySleepData.append(secondsAsleep / (60 * 60))
        }
        
        return dailySleepData
        
    }

    private func createLastTwoWeeksPredicate() -> NSPredicate {
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -14), to: now) ?? Date()
        return HKQuery.predicateForSamples(withStart: startDate, end: now, options: [.strictStartDate, .strictEndDate])
    }

}
