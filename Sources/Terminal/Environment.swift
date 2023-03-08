import Darwin

/// The environment of the current running process in a form of a dictionary of key-value pair.
public func currentEnvironment() -> [String: String] {
  withUnsafePointer(to: environ) { pointer in
    var environment: [String: String] = [:]
    var a = 0
    while let s = pointer.pointee.advanced(by: a).pointee {
      let str = String(cString: s)
      guard let equalIndex = str.firstIndex(of: "=") else {
        a += 1
        continue
      }
      let key = String(str.prefix(upTo: equalIndex))
      let value = String(str[str.index(after: equalIndex)...])
      environment[key] = value
      a += 1
    }
    return environment
  }
}

/// Gets the value of a given environment variable.
public func getEnvironmentValue(for key: String) throws -> String {
  try fromCFunctionNullStringError(name: "getenv") {
    getenv(key)
  }
}

/// Sets the a value for a given environment variable.
public func setEnvironmentValue(
  _ v: String,
  for key: String,
  overwrite: Bool
) throws {
  try fromCFunctionError(name: "setenv") {
    setenv(key, v, overwrite ? 1 : 0)
  }
}

/// Unsets the a value for a given environment variable.
public func unsetEnvironmentValue(for key: String) throws {
  try fromCFunctionError(name: "unsetenv") {
    unsetenv(key)
  }
}
