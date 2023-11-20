import HealthKit
import Spezi
import SpeziHealthKit
import SpeziOpenAI
import SwiftUI


class HealthGPTAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: HealthGPTStandard()) {
            OpenAIComponent()
            HealthDataInterpreter()
            if HKHealthStore.isHealthDataAvailable() {
                healthKit
            }
        }
    }


    private var healthKit: HealthKit {
        HealthKit {
            CollectSamples(
                [
                    HKQuantityType(.stepCount),
                    HKQuantityType(.activeEnergyBurned),
//                    HKQuantityType(.appleExerciseTime),
//                    HKQuantityType(.bodyMass),
                    HKQuantityType(.distanceWalkingRunning),
                    HKCategoryType(.sleepAnalysis)
                ],
                deliverySetting: .manual()
            )
        }
    }
}
