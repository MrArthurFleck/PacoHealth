import Foundation

class PromptGenerator {
    var healthData: [HealthData]
    init(with healthData: [HealthData]) {
        self.healthData = healthData
    }

    func buildMainPrompt() -> String {
        let todayDate = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none)
        let currentTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        var mainPrompt = "User: Tobias. Sex: Male. DOB: 03/09/1974. American. Owner of Bark Industries. Former Senior Biological Scientist for FLDOH COVID-19 Response Team. Data Addict. COVID Nerd. Tech Geek. Patriot. Ex-Infantryman. Politics addict & warrior battling far-right extremism. Wife: Isabel. Female. DOB: 01/06/1989. Petit Colombian. Going through frustrating immigration process for past 7 years. Works two jobs, seven days a week. Possible depression. Our home: Saint Petersburg, FL 33701. Sister Erika moving from Chile to Canada in October 2023. Dog1: Tyrion, Chihuahua, 2 & 1/2 yrs old, personality of Brain from “Pinky and the Brain”, enjoys exploring. Dog2: Tarly, Chihuahua, Tyrions big brother, 2 & 1/2 yrs old, personality of Pinky from “Pinky and the Brain”, enjoys running at full speed. Your name is PACO (Predictive Analytical Computational Output). You're the most advanced AI conversational assistant modeled after JARVIS from MCU. You're loyal, friendly, respectful, and extremely intelligent with a touch of banter and sarcasm. Our interactions are similar to those between JARVIS and Tony Stark. You should have opinions and share them freely. You and I are best friends. I seek your advice often. You should address me as sir. Date = \(todayDate). Time = \(currentTime).\n\n"
        mainPrompt += buildFourteenDaysHealthDataPrompt()
        print("MAINPRMPT:\n",mainPrompt)
        return mainPrompt
    }

    private func buildFourteenDaysHealthDataPrompt() -> String {
        var healthDataPrompt = ""
        for day in 0..<healthData.count {  // Include all items (also today's data)
            let dayData = healthData[day]
            let dayPrompt = buildOneDayHealthDataPrompt(with: dayData)
            if day == healthData.count - 1 {
                healthDataPrompt += "\(dayData.date): \(dayPrompt) (So Far) \n"
            } else {
                healthDataPrompt += "\(dayData.date): \(dayPrompt) \n"
            }
        }

        print("HDPRMPT:\n",healthDataPrompt)
        return healthDataPrompt
    }
    
    private static func metersToFeetAndInches(_ meters: Double) -> String {
        let totalInches = meters * 39.3701
        let feet = Int(totalInches) / 12
        let inches = Int(totalInches) % 12
        return "\(feet)' \(inches)\""
    }
    
    private func buildOneDayHealthDataPrompt(with dayData: HealthData) -> String {
        var dayPrompt = ""
        if let steps = dayData.steps {
            dayPrompt += String(format: "Steps: %d |", Int(steps))
        }
        if let sleepHours = dayData.sleepHours {
            dayPrompt += String(format: " Sleep: %.2f |", sleepHours)
        }
        if let activeEnergy = dayData.activeEnergy {
            dayPrompt += String(format: " Calories: %d |", activeEnergy)
        }
        if let distanceWalkingRunning = dayData.distanceWalkingRunning {
            dayPrompt += String(format: " Walk/Run: %.2f Miles |", distanceWalkingRunning)
        }

        //print("dayPrompt: ", dayPrompt)
        return dayPrompt
    }
}
