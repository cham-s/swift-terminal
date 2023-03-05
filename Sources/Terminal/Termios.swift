import Darwin
import SystemPackage

/// Structure containing setting values to modify the behavior of the terminal
public struct Termios {
  public var inputFlags: InputFlags
  public var outputFlags: OutputFlags
  public var controlFlags: ControlFlags
  public var localFlags: LocalFlags
  public var controlCharacters: ControlCharacters
  public var inputSpeed: Speed
  public var outputSpeed: Speed
  
  public init(
    inputFlags: InputFlags,
    outputFlags: OutputFlags,
    controlFlags: ControlFlags,
    localFlags: LocalFlags,
    controlCharacters: ControlCharacters,
    inputSpeed: Speed,
    outputSpeed: Speed
  ) {
    self.inputFlags = inputFlags
    self.outputFlags = outputFlags
    self.controlFlags = controlFlags
    self.localFlags = localFlags
    self.controlCharacters = controlCharacters
    self.inputSpeed = inputSpeed
    self.outputSpeed = outputSpeed
  }
}

public typealias StandardDescriptors = (
  input: FileDescriptor,
  output: FileDescriptor,
  error: FileDescriptor
)

extension Termios: Equatable { }


extension Termios {
  /// From a C termios to a more Swift like Termios.
  public init(cTermios: termios) {
    let inputFlags = InputFlags.decompose(cTermios.c_iflag)
    let outputFlags = OutputFlags.decompose(cTermios.c_oflag)
    let controlFlags = ControlFlags.decompose(cTermios.c_cflag)
    let localFlags = LocalFlags.decompose(cTermios.c_lflag)
    let controlCharacters = ControlCharacters.init(cTermios.c_cc)
    
    self = .init(
      inputFlags: inputFlags,
      outputFlags: outputFlags,
      controlFlags: controlFlags,
      localFlags: localFlags,
      controlCharacters: controlCharacters,
      inputSpeed: cTermios.c_ispeed,
      outputSpeed: cTermios.c_ospeed
    )
  }
  
  /// From a Swift like Termios to a C termios type expected by c syscalls.
  public var toCTermios: termios {
    var result = termios()
    
    result.c_iflag = InputFlags.recompose(self.inputFlags)
    result.c_oflag = OutputFlags.recompose(self.outputFlags)
    result.c_cflag = ControlFlags.recompose(self.controlFlags)
    result.c_lflag = LocalFlags.recompose(self.localFlags)
    result.c_cc = self.controlCharacters.toCControlCharacters
    result.c_ispeed = self.inputSpeed
    result.c_ospeed = self.outputSpeed
    
    return result
  }
}

extension Termios {
  /// Disables the default terminal behavior by canceling echo of characters..
  /// - Note: The size of the buffer provided by the read syscall is what triggers each number of character to read, not newline.
  public static func disableDefaultBehavior() throws -> Self {
    var attributes = try terminalAttributes(from: FileDescriptor.standardInput)
    
    attributes.localFlags.disable([.canonicalize, .echo])
    
    attributes.controlCharacters[.time] = 1
    attributes.controlCharacters[.min] = 0
    
    return attributes
  }
}
