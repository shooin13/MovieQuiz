import Foundation

final class StatisticServiceImplementation: StatisticService {
  
  private enum Keys: String {
    case correct, total, bestGame, gamesCount
  }
  
  private let userDefaults = UserDefaults.standard
  
  var totalCorrect: Int {
    get {
      return userDefaults.integer(forKey: Keys.correct.rawValue)
    }
    set {
      return userDefaults.set(newValue, forKey: Keys.correct.rawValue)
    }
  }
  
  var totalAccuracy: Double {
    get {
      return userDefaults.double(forKey: Keys.total.rawValue)
    }
    set {
      return userDefaults.set(newValue, forKey: Keys.total.rawValue)
    }
    
  }
  
  var gamesCount: Int {
    get {
      return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }
    set {
      return userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
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
    totalCorrect += count
    
    let totalAvailablePoints = 10 * gamesCount
    
    let newTotalAccuracy = Double(totalCorrect) / Double(totalAvailablePoints)
    totalAccuracy = newTotalAccuracy
    
    let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
    
    if newGameRecord.newRecord(newRecord: bestGame) {
      bestGame = newGameRecord
    }
  }
}
