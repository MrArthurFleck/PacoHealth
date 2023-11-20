/// Constants shared across the HealthGPT Application to access
/// storage information including the `AppStorage` and `SceneStorage`
enum StorageKeys {
    // MARK: - Onboarding
    /// A `Bool` flag indicating of the onboarding was completed.
    static let onboardingFlowComplete = "onboardingFlow.complete"
    /// A `Step` flag indicating the current step in the onboarding process.
    static let onboardingFlowStep = "onboardingFlow.step"
    /// An `AIModel` flag indicating the OpenAI model to use
    static let openAIModel = "openAI.model"
}
