import Darwin
import SystemPackage

/// Get  attributes of the current session terminal.
public func tcgetattributes(
  _ fd: Int32,
  _ termios: UnsafeMutablePointer<termios>!
) throws {
  try fromCFunctionError(name: "tcgetattr") {
    tcgetattr(fd, termios)
  }
}

/// Get  attributes of the current session terminal in a shape of a Termios structure.
public func terminalAttributes(
  from fd: FileDescriptor
) throws -> Termios {
  var current = termios()
  try tcgetattributes(fd.rawValue, &current)
  return Termios(cTermios: current)
}

/// Set attributes of the current session terminal.
public func tcsetattributes(
  _ fd: Int32,
  _ option: Int32,
  _ termios: UnsafeMutablePointer<termios>!
) throws {
  try fromCFunctionError(name: "tcsetattr") {
    tcsetattr(fd, option, termios)
  }
}

/// Set attributes of the current session terminal.
public func setTerminalAttributes(
  from fd: FileDescriptor,
  with command: ChangeOption,
  using termios: Termios
) throws {
  var termios = termios.toCTermios
  try tcsetattributes(fd.rawValue, command.rawValue, &termios)
}
