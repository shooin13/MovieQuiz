import UIKit

struct GameRecord: Codable {
  let correct: Int
  let total: Int
  let date: Date
  
  private func newRecord(newRecord: GameRecord) -> Bool {
    correct > newRecord.correct
  }
  
  init(correct: Int, total: Int, date: Date) {
    self.correct = correct
    self.total = total
    self.date = date
  }
}
