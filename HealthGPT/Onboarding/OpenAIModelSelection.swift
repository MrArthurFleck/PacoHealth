import SpeziOnboarding
import SpeziOpenAI
import SwiftUI


struct OpenAIModelSelection: View {
    @EnvironmentObject private var onboardingNavigationPath: OnboardingNavigationPath
    
    
    var body: some View {
        OpenAIModelSelectionOnboardingStep {
            onboardingNavigationPath.nextStep()
        }
    }
}
