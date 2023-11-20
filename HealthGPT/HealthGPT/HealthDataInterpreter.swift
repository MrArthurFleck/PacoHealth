import Foundation
import Spezi
import SpeziOpenAI

class HealthDataInterpreter: DefaultInitializable, Component, ObservableObject, ObservableObjectProvider {
    @Dependency var openAIComponent = OpenAIComponent()
    var lastSpokenText: String?
    var speakTextClosure: ((String) -> Void)?
    var querying = false {
        willSet {
            _Concurrency.Task { @MainActor in
                objectWillChange.send()
            }
        }
    }
    
    var runningPrompt: [Chat] = [] {
        willSet {
            _Concurrency.Task { @MainActor in
                objectWillChange.send()
            }
        }
        didSet {
            _Concurrency.Task {
                if runningPrompt.last?.role == .user {
                    do {
                        try await queryOpenAI()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    required init() {}
    
    func generateMainPrompt() async throws {
        let healthDataFetcher = HealthDataFetcher()
        let healthData = try await healthDataFetcher.fetchAndProcessHealthData()
        let generator = PromptGenerator(with: healthData)
        let mainPrompt = generator.buildMainPrompt()
        runningPrompt = [Chat(role: .system, content: mainPrompt)]
    }
    
    func queryOpenAI() async throws {
        querying = true
        var accumulatedResponse: String = ""  // Reset the accumulated response
        let chatStreamResults = try await openAIComponent.queryAPI(withChat: runningPrompt)
        for try await chatStreamResult in chatStreamResults {
            for choice in chatStreamResult.choices {
                if let newContent = choice.delta.content {
                    accumulatedResponse += newContent  // Only append the new content
                }
            }
        }
        
        // Update the last message in runningPrompt
        if let lastMessage = runningPrompt.last, lastMessage.role == .assistant {
            runningPrompt[runningPrompt.count - 1] = Chat(role: .assistant, content: accumulatedResponse)
        } else {
            runningPrompt.append(Chat(role: .assistant, content: accumulatedResponse))
        }
        
        // Speak the accumulated response
        if !accumulatedResponse.isEmpty, accumulatedResponse != lastSpokenText {
            print("Accumulated response: \(accumulatedResponse)")
            DispatchQueue.main.async {
                self.speakTextClosure?(accumulatedResponse)
            }
            lastSpokenText = accumulatedResponse
        }
        
        querying = false
    }
    
}
