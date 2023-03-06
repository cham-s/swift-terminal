import Terminal

//public enum ActionCharacter {
//  case escape
//  case ignore
//  case printable([UInt8])
//}
//
//extension ActionCharacter {
//  public init(_ bytes: [UInt8]) {
//    switch bytes {
//    case .escape: self = .escape
//    case .newLine: self = .printable(bytes)
//      
//    case let bs where bs.count == 1 &&  bs.first! < 32:
//      self = .ignore
//      
//    case .downArrow, .upArrow, .leftArrow, .rightArrow:
//      self = .ignore
//      
//    default: self = .printable(bytes)
//    }
//  }
//}

