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
        print("no value stored for totalAccuracy")
        return 0
      }
      return recordTotalAccuracy
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        print("impossible to save totalAccuracy")
        return
      }
      userDefaults.set(data, forKey: Keys.total.rawValue)
      print("totalAccuracy set")
    }
  }
  
  var gamesCount: Int {
    get {
      guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
            let recordGamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
        print("no value stored for gamesCount")
        return 0
      }
      print("gamesCount get")
      return recordGamesCount
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        print("impossible to save gamesCount")
        return
      }
      userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
      print("gamesCount set")
    }
  }
  
  var bestGame: GameRecord {
    get {
      guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
        print("no value stored for bestGame")
        return GameRecord(correct: 0, total: 0, date: Date())
      }
      print("bestGame get")
      return record
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue) else {
        print("impossible to save bestGame")
        return
      }
      userDefaults.set(data, forKey: Keys.bestGame.rawValue)
      print("bestGame set")
    }
    
  }
  
  //реализовать функцию сохранения лучшего результата store — с проверкой на то, что новый результат лучше сохранённого в UserDefaults
  
  func store(correct count: Int, total amount: Int) {
    gamesCount += 1
    
    let newTotalAccuracy = Double(count) / Double(amount)
    totalAccuracy = (totalAccuracy * Double(gamesCount - 1) + newTotalAccuracy) / Double(gamesCount)
    
    guard count > bestGame.correct  else {
      return
    }
    
    let newBestGame = GameRecord(correct: count, total: amount, date: Date())
    bestGame = newBestGame
    print("new bestgame stored")
    
  }
}
