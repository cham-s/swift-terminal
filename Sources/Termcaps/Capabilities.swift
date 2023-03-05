import Termlib
import SystemPackage

/// A subset of terminal command ids.
/// - More string commands available here:  https://www.gnu.org/software/termutils/manual/termcap-1.3/html_mono/termcap.html#SEC35
public enum Command: String {
  /// Clear the entire screen.
  case clearScreen = "cl"
  /// Move the cursor.
  case moveCursor = "cm"
  /// Hide the cursor.
  case hideCursor = "vi"
  /// DispalyCursor.
  case displayCursor = "ve"
  /// Move to last saved cursor position.
  case moveToLastSavedCursorPosition = "rc"
  /// Save the current cursor position.
  case saveCurrentCursorPosition = "sc"
  /// Width size.
  case columns = "col"
  /// Height size.
  case rows = "li"
  /// Turn on underlining.
  case underliningOn = "us"
  /// Turn off underlining.
  case underliningOff = "ue"
  /// Turn on reverseVideo.
  case reverseVideoOn = "mr"
  /// Turn off appearanceMode
  case appeareanceModeOff = "me"
}

/// Information necessary to perform a terminal command.
public typealias FullCommand = (
  command: Command,
  position: Position,
  affectedLines: Int
)

/// Position on a 2D coordinate system.
public struct Position {
  public var x, y: Int
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
  
  public static let origin = Self (x: 0, y: 0) 
}

public enum TermCapError: Error {
  case type(String)
  case entry(String)
  case putString(String)
}


// TODO: Maybe use class and save all buffers to be freed at deinit?
public enum TermCap {
  
  /// Get the string value of a given terminal command.
  public static func string(for command: String) -> String? {
    var buffer = [UnsafeMutablePointer<CChar>?]()
    var id = command
    return tgetstr(&id, &buffer)
      .map { String(cString: $0) }
  }
  
  /// Get the flag value of a given terminal capability.
  public static func flag(for id: String) -> Bool {
    var mutableId = id
    return tgetflag(&mutableId) == 1 ? true : false
  }
  
  /// Get the numeric value of a given terminal capability.
  public static func numeric(for id: String) -> Int? {
    var mutableId = id
    let value = tgetnum(&mutableId)
    guard value != -1 else {
      return nil
    }
    return Int(value)
  }
  
  /// Get the numeric value of a given terminal capability.
  /// - Note: This overload uses the Command type instead of plain String.
  public static func numeric(for id: Command) -> Int? {
    var mutableId = id.rawValue
    let value = tgetnum(&mutableId)
    guard value != -1 else {
      return nil
    }
    return Int(value)
  }
  
  public static func goto(
    command: String,
    horizontal: Int,
    vertical: Int
  ) -> String? {
    tgoto(command, Int32(horizontal), Int32(vertical))
      .map { String(cString: $0) }
  }
  
  // TODO: If needed add output function as parameter.
  public static func execute(
    _ commands: String,
    numberOfLines lines: Int = 1
  ) throws {
    func putChar (char: Int32) -> Int32 {
      do {
        try FileDescriptor.standardOutput.writeAll([UInt8(char)])
        return char
      } catch {
        return 0
      }
    }
    let ret = tputs(commands, Int32(lines), putChar)
    guard ret == 0 else {
      throw TermCapError
        .putString("Call of tputs(\(commands), \(lines), putChar) failed.")
    }
  }
  
  /// Streamline the three operations in one failable operation.
  /// - Search the encoded string command.
  /// - Perform a goto to move the cursor before executing the command.
  /// - Execute the command
  public static func execute(
    _ command: String,
    to position: Position = .init(x: 0, y: 0),
    affectedLines: Int = 1
  ) throws {
    try Self.string(for: command)
      .map { encodedCmd in
        try Self.goto(
          command: encodedCmd,
          horizontal: position.x,
          vertical: position.y
        )
        .map { command in
          try Self.execute(command, numberOfLines: affectedLines)
        }
      }
  }
  
  /// Streamline the three operations in one failable operation.
  /// - Search the encoded string command.
  /// - Perform a goto to move the cursor before executing the command.
  /// - Execute the command
  /// - Note: This overload uses the Command type instead of plain String.
  public static func execute(
    _ command: Command,
    to position: Position = .init(x: 0, y: 0),
    affectedLines: Int = 1
  ) throws {
    try Self.execute(
      command.rawValue,
      to: position,
      affectedLines: affectedLines
    )
  }
  
  public static func execute(
    _ commands: [FullCommand]
  ) throws {
    for c in commands {
      try Self.execute(
        c.command,
        to: c.position,
        affectedLines: c.affectedLines
      )
    }
  }
  
  public static func clearScreen() throws {
    try TermCap.execute(
      [
        (.hideCursor, .origin, 1),
        (.clearScreen, .origin, 1),
        (.moveCursor, .origin, 1),
      ]
    )
  }
}

extension TermCap {
  /// Check if a given terminal type is available.
  public static func entry(for terminalType: String) -> String? {

    var buf = Array<CChar>(repeating: 0, count: 2048)
    let returnValue = tgetent(&buf, terminalType)
    if returnValue == -1 {
      return nil
    }
    return String(cString: buf)
  }
}

