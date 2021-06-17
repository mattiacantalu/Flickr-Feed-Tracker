import Foundation

extension Int {
     func inRange(_ range: Range<Int>) -> Bool {
         range ~= self
     }
 }
