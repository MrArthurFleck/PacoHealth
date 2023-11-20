import HealthKit
import SpeziOnboarding
import SpeziOpenAI
import SwiftUI


/// Displays an multi-step onboarding flow for the HealthGPT Application.
struct OnboardingFlow: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            Welcome()
            Disclaimer()
            OpenAIAPIKey()
            OpenAIModelSelection()
            if HKHealthStore.isHealthDataAvailable() {
                HealthKitPermissions()
            }
        }
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(!completedOnboardingFlow)
    }
}


#if DEBUG
struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlow()
    }
}
#endif
