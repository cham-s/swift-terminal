import Terminal
import Termcaps

public enum ActionCharacter {
  case escape
  case ignore
  case printable([UInt8])
}

extension ActionCharacter {
  public init(_ bytes: [UInt8]) {
    switch bytes {
    case .escape: self = .escape
    case .newLine: self = .printable(bytes)
      
    case let bs where bs.count == 1 &&  bs.first! < 32:
      self = .ignore
      
    case .downArrow, .upArrow, .leftArrow, .rightArrow:
      self = .ignore
      
    default: self = .printable(bytes)
    }
  }
}

struct EchoApp {
  var terminal: Terminal
  
  func run() throws {
    try self.clear()
    try self.greetings()
    
    var buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 4, alignment: 4)
    defer { buffer.deallocate() }
    reading: while true {
      buffer.initializeMemory(as: UInt8.self, repeating: .zero)
      _ = try self.terminal.read(into: buffer)
      
      let bytes = buffer.prefix(while: { $0 != 0 })
      let action = ActionCharacter(bytes.filter { $0 != 0 })
      switch action {
      case .escape:
        break reading
        
      case .ignore:
        // Ignore the input
        break
      case let .printable(bts):
        _ = try self.terminal.print(bts)
      }
    }
    
    try self.clear()
    try self.terminal.restoreSavedAttributes(.drain)
  }
  
  private func clear() throws {
    try Termcap.execute([(.clearScreen, .origin, 1)])
  }
  
  private func greetings() throws {
    try Termcap.execute((.clearScreen, .origin, 1))
    let lines = ["Hello!\n", "Echo Your Thoughts\n", "Press Escape to quit\n"]
    
    try zip(lines, lines.indices)
      .forEach { (line, i) in
        if i == 1 {
          try Termcap.execute((.reverseVideoOn, .origin, 1))
        }
        _ = try self.terminal.print(line)
        if i == 1 {
          try Termcap.execute((.appeareanceModeOff, .origin, 1))
        }
      }
  }
}

var attributes = try terminalAttributes(from: .standardInput)

attributes.localFlags.disable([.canonicalize, .echo])
attributes.controlCharacters[.time] = 1
attributes.controlCharacters[.min] = 0

let terminal = try Terminal(
  attributes: attributes,
  option: .drain,
  terminalEnvVariable: "TERM"
)

let app = EchoApp(terminal: terminal)

try app.run()

print("Bye!")
