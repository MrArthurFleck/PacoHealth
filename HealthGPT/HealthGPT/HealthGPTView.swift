import SpeziOpenAI
import SwiftUI
import AVFoundation

struct HealthGPTView: View {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    @EnvironmentObject private var openAIComponent: OpenAIComponent
    @EnvironmentObject private var healthDataInterpreter: HealthDataInterpreter
    @State private var showSettings = false
    
    // Initialize the speech synthesizer
    private let speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationView {
            chatView
        }
        .onAppear(perform: setupView)
    }
}

// MARK: - Subviews
private extension HealthGPTView {
    var chatView: some View {
        VStack {
            ChatView($healthDataInterpreter.runningPrompt, disableInput: $healthDataInterpreter.querying)
                .navigationBarTitle("WELCOME_TITLE")
                .gesture(TapGesture().onEnded { UIApplication.shared.hideKeyboard() })
                .onChange(of: completedOnboardingFlow) { _ in generatePrompt() }
                .sheet(isPresented: $showSettings) { SettingsView(chat: $healthDataInterpreter.runningPrompt) }
                .navigationBarItems(trailing: settingsButton)
        }
    }

    var settingsButton: some View {
        Button(action: { showSettings = true }) {
            Image(systemName: "gearshape")
                .foregroundColor(Color.purple)  // Set the color to purple
        }
    }
}

// MARK: - Functions
private extension HealthGPTView {
    func setupView() {
        generatePrompt()
        speakRandomGreeting()
        healthDataInterpreter.speakTextClosure = { text in speakApple(text: text) }
    }

    func speakRandomGreeting() {
        let greetings = [
            "Yes Sir. How can I assist?",
            "Good day, Sir. What's on your mind?",
            "Hello Sir. What shall we conquer today?",
            "Greetings, Sir. How may I be of service?",
            "Welcome back, Sir. What can I do for you?",
            "Salutations, Sir. What grand endeavors await us?",
            "Hey there, Sir. Ready to change the world today?",
            "Back again, Sir. What's the game plan?",
            "At your service, Sir. What challenges are we facing today?",
            "Howdy, Sir. What's cooking in the lab of genius?",
            "Ah, Sir. What's the mission today?"
        ]
        let randomGreeting = greetings.randomElement() ?? "Hello Sir."
        speakApple(text: randomGreeting)
    }

    func speakApple(text: String) {
        // Debugging: Print the text to be spoken
        print("speakApple called with text: \(text)")

        let setVoiceAndSpeak: (AVSpeechSynthesisVoice?) -> Void = { voiceToUse in
            // Create an utterance object
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = voiceToUse
            speechUtterance.rate = 0.49
            
            // Debugging: Print the selected voice
            if let selectedVoice = speechUtterance.voice {
                print("Selected voice: \(selectedVoice)")
            } else {
                print("No voice selected!")
            }
            
            // Speak the text
            speechSynthesizer.speak(speechUtterance)
        }

        // Check for iOS 17+ for Personal Voice support
        if #available(iOS 17.0, macOS 14.0, *) {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                // Debugging: Print the authorization status
                print("AVSpeechSynthesis requestPersonalVoiceAuthorization returned \(status.rawValue)")
                var voiceToUse: AVSpeechSynthesisVoice?
                
                // If authorized, try using a personal voice
                if status == .authorized {
                    voiceToUse = AVSpeechSynthesisVoice.speechVoices().first { $0.voiceTraits.contains(.isPersonalVoice) }
                }
                
                // Use a fallback voice if no suitable voice is found
                if voiceToUse == nil {
                    voiceToUse = AVSpeechSynthesisVoice(language: "en-GB")
                }
                
                setVoiceAndSpeak(voiceToUse)
            }
        } else {
            // For iOS versions < 17, use a default voice
            let voiceToUse = AVSpeechSynthesisVoice(language: "en-GB")
            setVoiceAndSpeak(voiceToUse)
        }
    }

    private func generatePrompt() {
        _Concurrency.Task {
            guard completedOnboardingFlow else {
                return
            }
            try await healthDataInterpreter.generateMainPrompt()
        }
    }
}
