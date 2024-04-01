import UIKit

final class StatisticServiceImplementation: StatisticService {
  
  private enum Keys: String {
    case correct, total, bestGame, gamesCount
  }
  private let userDefaults = UserDefaults.standard
  
  var totalAccuracy: Double {
    get {
      guard let data = userDefaults.data(forKey: Keys.total.rawValue),
            let recordTotalAccuracy = try? JSONDecoder().decode(Double.self, from: data) else {
        return 0
      }
      return recordTotalAccuracy
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        return
      }
      userDefaults.set(data, forKey: Keys.total.rawValue)
    }
  }
  
  var gamesCount: Int {
    get {
      guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
            let recordGamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
        return 0
      }
      return recordGamesCount
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        return
      }
      userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
    }
  }
  
  var bestGame: GameRecord {
    get {
      guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
        return GameRecord(correct: 0, total: 0, date: Date())
      }
      return record
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        return
      }
      userDefaults.set(data, forKey: Keys.bestGame.rawValue)
    }
    
  }
  
  func store(correct count: Int, total amount: Int) {
    gamesCount += 1
    
    let newTotalAccuracy = Double(count) / Double(amount)
    totalAccuracy = (totalAccuracy * Double(gamesCount - 1) + newTotalAccuracy) / Double(gamesCount)
    
    let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
    
    if newGameRecord.newRecord(newRecord: bestGame) {
      bestGame = newGameRecord
    }
  }
}
