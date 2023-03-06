import Darwin
import SystemPackage
import Termcaps

extension Int32 {
  public static let standardInput = 0
  public static let standardOutput = 1
  public static let standardError = 2
}

public struct Terminal {
  private var savedAttributes: Termios
  
  public init(
    attributes: Termios,
    option: ChangeOption,
    terminalEnvVariable: String
  ) throws {
    var termtype = ""
    do {
      termtype = try getEnvironmentValue(for: terminalEnvVariable)
    } catch {
      throw TermCapError.type("Terminal environment variable \(terminalEnvVariable) not found.")
    }
    
    guard Termcap.entry(for: termtype) != nil else {
      throw TermCapError.entry("No database entry found for terminal \(terminalEnvVariable)")
    }
    
    self.savedAttributes = attributes
    try setTerminalAttributes(
      from: FileDescriptor.standardInput,
      with: option,
      using: attributes
    )
  }
  
  public func print(_ str: String) throws -> Int {
    try FileDescriptor.standardOutput.writeAll(str[...].utf8)
  }
  
  public func print<S: Sequence>(
    _ sequence: S
  ) throws -> Int where S.Element == UInt8 {
    try FileDescriptor.standardOutput.writeAll(sequence)
  }
  
  public func read(into buffer: UnsafeMutableRawBufferPointer) throws -> Int {
    try FileDescriptor.standardInput.read(into: buffer)
  }
  
  public func setAttributes(_ option: ChangeOption) throws {
    try setTerminalAttributes(
      from: FileDescriptor.standardOutput,
      with: option,
      using: self.savedAttributes
    )
  }
  
  public func restoreSavedAttributes(_ option: ChangeOption) throws {
    try setTerminalAttributes(
      from: FileDescriptor.standardOutput,
      with: option,
      using: self.savedAttributes
    )
  }
}

//#if canImport(SystemPackage)
//extension Terminal {
//  public init
//}
//#endif

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
