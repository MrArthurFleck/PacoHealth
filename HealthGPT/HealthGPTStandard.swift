import Spezi
import SpeziHealthKit


actor HealthGPTStandard: Standard, ObservableObject, ObservableObjectProvider, HealthKitConstraint {
    func add(sample: HKSample) async { }
    func remove(sample: HKDeletedObject) async { }
}
