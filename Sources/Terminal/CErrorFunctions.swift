import Darwin

extension Int32 {
  public static let error = Self(-1)
  public static let success = Self(0)
}

public struct ErrnoError: Error {
  public let message: String
  
  public init(message: String) {
    self.message = message
  }
}

public func fromCFunctionError(
  name: String,
  _ f: @escaping () -> Int32
) throws {
  if f() == .error {
    throw ErrnoError(
      message: """
        Error from \(name) call.
        \(String(cString: strerror(errno)))
        """
    )
  }
}

public func fromCFunctionNullStringError(
  name: String,
  _ f: @escaping () -> UnsafeMutablePointer<CChar>?
) throws -> String {

  guard let str = f() else {
    throw ErrnoError(
      message: """
        Error from \(name) call.
        \(String(cString: strerror(errno)))
        """
    )
  }
  return String(cString: str)
}
