import Darwin
import SystemPackage
import Termcaps

public struct Terminal {
  public var inputFd: FileDescriptor
  private var savedAttributes: Termios
  
  public init(
    attributes: Termios,
    option: ChangeOption,
    inputFd: FileDescriptor = FileDescriptor.standardInput,
    terminalEnvVariable: String
  ) throws {
    var termtype = ""
    do {
      termtype = try getEnvironmentValue(for: terminalEnvVariable)
    } catch {
      throw TermCapError.type("Terminal environment variable \(terminalEnvVariable) not found.")
    }
    
    guard TermCap.entry(for: termtype) != nil else {
      throw TermCapError.entry("No database entry found for terminal \(terminalEnvVariable)")
    }
    
    self.inputFd = inputFd
    self.savedAttributes = attributes
    try setTerminalAttributes(from: self.inputFd, with: option, using: attributes)
  }
  
  public func setAttributes(_ option: ChangeOption) throws {
    try setTerminalAttributes(
      from: self.inputFd,
      with: option,
      using: self.savedAttributes
    )
  }
  
  public func restoreSavedAttributes(_ option: ChangeOption) throws {
    try setTerminalAttributes(
      from: self.inputFd,
      with: option,
      using: self.savedAttributes
    )
  }
}

extension Terminal {
  /// Default Terminal using the TERM environment variable.
  public static func term(attributes: Termios) throws -> Self {
    return try Terminal(
      attributes: attributes,
      option: .drain,
      terminalEnvVariable: "TERM"
    )
  }
}
