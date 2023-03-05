import Darwin
import Tagged

public enum Flags {
  public enum InputTag {}
  public enum OutputTag {}
  public enum ControlTag {}
  public enum LocalTag {}
  
  /// Input flags - software input processing
  public typealias Input = Tagged<InputTag, UInt>
  
  /// Onput flags - software output processing
  public typealias Output = Tagged<OutputTag, UInt>
  
  /// Control flags - hardware control of terminal.
  public typealias Control = Tagged<ControlTag, UInt>
  
  ///  Local flags - dumping ground for other state
  public typealias Local = Tagged<LocalTag, UInt>
}

public enum InputKey: CaseIterable {
  case ignoreBreak
  /// Map BREAK to SIGINTR.
  case breakToSIGINTR
  /// Ignore (discard) parity errors.
  case ignoreParityErrors
  /// Mark parity and framing errors.
  case markParityAndFramingErrors
  /// Enable checking of parity errors.
  case enableParityErrosCheck
  /// Strip 8th bit off chars.
  case stripEightBitOffChars
  /// Map NL into CR.
  case mapNewlineToCarriageReturn
  /// Ignore CR.
  case ignoreCarriageReturn
  /// Map CR to NL (ala CRMOD).
  case mapCarriageReturnToNewline
  /// Enable output flow control.
  case enableOutputFlowControl
  /// Enable input flow control.
  case enableInputFlowControl
  /// Any char will restart after stop.
  case restartAnyCharAfterStop
#if canImport(Darwin)
  /// Ring bell on input queue full.
  case ringBellOnInputQueueFull
  /// Maintain state for UTF-8 VERASE.
  case maintainStateForUtf8VERASE
#endif
}

public enum OutputKey: CaseIterable {
  /// Enable following output processing.
  case enableFollowingOutputProcessing
  /// Map NL to CR-NL (ala CRMOD).
  case mapNewlineToCarriageReturnNewline
#if canImport(Darwin)
  /// Expand tabs to spaces.
  case expandTabToSpaces
  /// Discard EOT's (^D) on output).
  case discardEndOfTransmission
#endif
}

public enum ControlKey: CaseIterable {
#if canImport(Darwin)
  /// Ignore control flags.
  case ignoreControlFlags
#endif
  /// Character size mask.
  case characterSizeMask
  /// 5 bits (pseudo).
  case fiveBits
  /// 6 bits.
  case sixBits
  /// 7 bits.
  case sevenBits
  /// 8 bits.
  case eightBits
  /// Send 2 stop bits.
  case sendTwoStopBits
  /// Enable receiver
  case enableReceiver
  /// Parity enable.
  case enableParity
  /// Odd parity, else even.
  case oddParity
  /// Hang up on last close.
  case hangUpOnLastClose
  /// Ignore modem status lines.
  case ignoreModemStatusLines
#if canImport(Darwin)
  /// CTS flow control of output.
  case CTSFlowControlOfOutput
  /// RTS flow control of input.
  case RTSFlowControlOfInput
  /// CTS flow control of output and RTS flow control of input.
  case CTSFlowControlOfOutputAndRTSFlowControlOfInput
  /// DTR flow control of input.
  case DTRFlowControlOfInput
  /// DSR flow control of output.
  case DSRFlowControlOfOutput
  /// DCD flow control of output.
  case DCDFlowControlOfOutput
  /// Old name for CCAR_OFLOW.
  case MDMBUF
#endif
}

public enum LocalKey: CaseIterable {
#if canImport(Darwin)
  /// Visual erase for line kill.
  case echoke
#endif
  /// Visually erase chars.
  case echoe
  /// Echo NL after line kill.
  case echok
  /// Enable echoing.
  case echo
  /// Echo NL even if ECHO is off.
  case echoNL
#if canImport(Darwin)
  /// Visual erase mode for hardcopy .
  case echoPrt
  /// Echo control chars as ^(Char).
  case echoCtl
#endif
  /// Enable signals INTR, QUIT, [D]SUSP.
  case enableSignals
  /// Canonicalize input lines.
  case canonicalize
#if canImport(Darwin)
  /// Use alternate WERASE algorithm.
  case altWERASE
#endif
  /// Enable DISCARD and LNEXT.
  case iexten
#if canImport(Darwin)
  /// External processing.
  case extProc
#endif
  /// Stop background jobs from output.
  case toStop
#if canImport(Darwin)
  /// Output being flushed (state) .
  case flushOutput
  /// No kernel output from VSTATUS .
  case noKernInfo
  /// XXX retype pending input (state).
  case pendin
#endif
  /// Don't flush after interrupt.
  case noFlush
}

public typealias InputFlags = Dictionary<InputKey, Flags.Input>
public typealias OutputFlags = Dictionary<OutputKey, Flags.Output>
public typealias ControlFlags = Dictionary<ControlKey, Flags.Control>
public typealias LocalFlags = Dictionary<LocalKey, Flags.Local>

extension Dictionary where Key == InputKey, Value == Flags.Input {
  public static var `default`: Self {
    var inputs = Self()
    
    for key in InputKey.allCases {
      switch key {
      case .ignoreBreak:
        inputs[key] = 0x00000001
      case .breakToSIGINTR:
        inputs[key] = 0x00000002
      case .ignoreParityErrors:
        inputs[key] = 0x00000004
      case .markParityAndFramingErrors:
        inputs[key]  = 0x00000008
      case .enableParityErrosCheck:
        inputs[key] = 0x00000010
      case .stripEightBitOffChars:
        inputs[key] = 0x00000020
      case .mapNewlineToCarriageReturn:
        inputs[key] = 0x00000040
      case .ignoreCarriageReturn:
        inputs[key] = 0x00000080
      case .mapCarriageReturnToNewline:
        inputs[key] = 0x00000100
      case .enableOutputFlowControl:
        inputs[key] = 0x00000200
      case .enableInputFlowControl:
        inputs[key] = 0x00000400
      case .restartAnyCharAfterStop:
        inputs[key] = 0x00000800
      case .ringBellOnInputQueueFull:
        inputs[key] = 0x00002000
      case .maintainStateForUtf8VERASE:
        inputs[key] = 0x00004000
      }
    }
    return inputs
  }
  
  public static func decompose(_ flags: tcflag_t) -> Self {
    var selected = Self()
    for (key, value) in Self.`default` {
      if value.rawValue & flags == value.rawValue {
        selected[key] = value
      }
    }
    return selected
  }
  
  public static func recompose(_ flags: Self) -> tcflag_t {
    flags.values.reduce(tcflag_t(0)) { $0 | $1.rawValue }
  }
  
  public mutating func enable(_ flags: [InputKey]) {
    flags
      .filter { !self.keys.contains($0) }
      .forEach { key in
        self[key] = Self.`default`[key]
      }
  }
  
  public mutating func disable(_ flags: [InputKey]) {
    flags
      .filter { self.keys.contains($0) }
      .forEach { key in
        self[key] = nil
      }
  }
}

extension Dictionary where Key == OutputKey, Value == Flags.Output {
  public static var `default`: Self {
    var outputs = Self()
    
    for key in OutputKey.allCases {
      switch key {
      case .enableFollowingOutputProcessing:
        outputs[key] = 0x00000001
      case .mapNewlineToCarriageReturnNewline:
        outputs[key] = 0x00000002
      case .expandTabToSpaces:
        outputs[key] = 0x00000004
      case .discardEndOfTransmission:
        outputs[key] = 0x00000008
      }
    }
    
    return outputs
  }
  
  public static func decompose(_ flags: tcflag_t) -> Self {
    var selected = Self()
    for (key, value) in Self.`default` {
      if value.rawValue & flags == value.rawValue {
        selected[key] = value
      }
    }
    return selected
  }
  
  public static func recompose(_ flags: Self) -> tcflag_t {
    flags.values.reduce(tcflag_t(0)) { $0 | $1.rawValue }
  }
  
  public mutating func enable(_ flags: [OutputKey]) {
    flags
      .filter { !self.keys.contains($0) }
      .forEach { key in
        self[key] = Self.`default`[key]
      }
  }
  
  public mutating func disable(_ flags: [OutputKey]) {
    flags
      .filter { self.keys.contains($0) }
      .forEach { key in
        self[key] = nil
      }
  }
  
}

extension Dictionary where Key == ControlKey, Value == Flags.Control {
  public static var `default`: Self {
    var controls = Self()
    
    for key in ControlKey.allCases {
      switch key {
      case .ignoreControlFlags:
        controls[key] = 0x00000001
      case .characterSizeMask:
        controls[key] = 0x00000300
      case .fiveBits:
        controls[key] = 0x00000000
      case .sixBits:
        controls[key] = 0x00000100
      case .sevenBits:
        controls[key] = 0x00000200
      case .eightBits:
        controls[key] = 0x00000300
      case .sendTwoStopBits:
        controls[key] = 0x00000400
      case .enableReceiver:
        controls[key] = 0x00000800
      case .enableParity:
        controls[key] = 0x00001000
      case .oddParity:
        controls[key] = 0x00002000
      case .hangUpOnLastClose:
        controls[key] = 0x00004000
      case .ignoreModemStatusLines:
        controls[key] = 0x00008000
      case .CTSFlowControlOfOutput:
        controls[key] = 0x00010000
      case .RTSFlowControlOfInput:
        controls[key] = 0x00020000
      case .CTSFlowControlOfOutputAndRTSFlowControlOfInput:
        controls[key] = Tagged<Flags.ControlTag, UInt>(
          controls[.CTSFlowControlOfOutput]!.rawValue |
          controls[.RTSFlowControlOfInput]!.rawValue
        )
      case .DTRFlowControlOfInput:
        controls[key] = 0x00040000
      case .DSRFlowControlOfOutput:
        controls[key] = 0x00080000
      case .DCDFlowControlOfOutput:
        controls[key] = 0x00100000
      case .MDMBUF:
        controls[key] = 0x00100000
      }
    }
    return controls
  }
  
  public static func decompose(_ flags: tcflag_t) -> Self {
    var selected = Self()
    for (key, value) in Self.`default` {
      if value.rawValue & flags == value.rawValue {
        selected[key] = value
      }
    }
    return selected
  }
  
  public static func recompose(_ flags: Self) -> tcflag_t {
    flags.values.reduce(tcflag_t(0)) { $0 | $1.rawValue }
  }
  
  public mutating func enable(_ flags: [ControlKey]) {
    flags
      .filter { !self.keys.contains($0) }
      .forEach { key in
        self[key] = Self.`default`[key]
      }
  }
  
  public mutating func disable(_ flags: [ControlKey]) {
    flags
      .filter { self.keys.contains($0) }
      .forEach { key in
        self[key] = nil
      }
  }
}

extension Dictionary where Key == LocalKey, Value == Flags.Local {
  public static var `default`: Self {
    var locals = Self()
    
    for key in LocalKey.allCases {
      switch key {
      case .echoke:
        locals[key] = 0x00000001
      case .echoe:
        locals[key] = 0x00000002
      case .echok:
        locals[key] = 0x00000004
      case .echo:
        locals[key] = 0x00000008
      case .echoNL:
        locals[key] = 0x00000010
      case .echoPrt:
        locals[key] = 0x00000020
      case .echoCtl:
        locals[key] = 0x00000040
      case .enableSignals:
        locals[key] = 0x00000080
      case .canonicalize:
        locals[key] = 0x00000100
      case .altWERASE:
        locals[key] = 0x00000200
      case .iexten:
        locals[key] = 0x00000400
      case .extProc:
        locals[key] = 0x00000800
      case .toStop:
        locals[key] = 0x00400000
      case .flushOutput:
        locals[key] = 0x00800000
      case .noKernInfo:
        locals[key] = 0x02000000
      case .pendin:
        locals[key] = 0x20000000
      case .noFlush:
        locals[key] = 0x80000000
      }
    }
    
    return locals
  }
  
  public static func decompose(_ flags: tcflag_t) -> Self {
    var selected = Self()
    for (key, value) in Self.`default` {
      if value.rawValue & flags == value.rawValue {
        selected[key] = value
      }
    }
    return selected
  }
  
  public static func recompose(_ flags: Self) -> tcflag_t {
    flags.values.reduce(tcflag_t(0)) { $0 | $1.rawValue }
  }
  
  public mutating func enable(_ flags: [LocalKey]) {
    flags
      .filter { !self.keys.contains($0) }
      .forEach { key in
        self[key] = Self.`default`[key]
      }
  }
  
  public mutating func disable(_ flags: [LocalKey]) {
    flags
      .filter { self.keys.contains($0) }
      .forEach { key in
        self[key] = nil
      }
  }
}

public enum ChangeOption: Int32  {
  /// Make change immediate.
  case now = 0
  /// Drain output, then change.
  case drain = 1
  /// Drain output, flush input.
  case flush = 2
#if canImport(Darwin)
  /// Flag - don't alter h.w. state.
  case soft = 0x10
#endif
}

public enum ControlCharacterKey: Int32, CaseIterable {
  case endOfFile = 0
  case endOfLine = 1
#if canImport(Darwin)
  case endOfLine2 = 2
#endif
  case erase = 3
#if canImport(Darwin)
  case wErase = 4
#endif
  case kill = 5
#if canImport(Darwin)
  case reprint = 6
#endif
  case interrupt = 8
  case quit = 9
  case suspend = 10
#if canImport(Darwin)
  case dSuspdend = 11
#endif
  case start = 12
  case stop = 13
#if canImport(Darwin)
  case lNext = 14
  case discard = 15
#endif
  case min = 16
  case time = 17
#if canImport(Darwin)
  case status = 18
#endif
  case nccs = 20
}

/// Terminal control characters.
public typealias ControlCharacters = Dictionary<ControlCharacterKey, UInt8>

public typealias Speed = UInt

/// Tuple entries
/// - 0 VEOF
/// - 1 VEOL
/// - 2 VEOL2
/// - 3 VERASE
/// - 4 VWERASE
/// - 5 VKILL
/// - 6 VREPRINT
/// - 8 VINTR
/// - 9 VQUIT
/// - 10 VSUSP
/// - 11 VDSUSP
/// - 12 VSTART
/// - 13 VSTOP
/// - 14 VLNEXT
/// - 16 VMIN
/// - 17 VTIME
/// - 18 VSTATUS
/// - 19 NCCS
public typealias C_CC = (
  cc_t, cc_t, cc_t, cc_t, cc_t,
  cc_t, cc_t, cc_t, cc_t, cc_t,
  cc_t, cc_t, cc_t, cc_t, cc_t,
  cc_t, cc_t, cc_t, cc_t, cc_t
)

extension Dictionary where Key == ControlCharacterKey, Value == UInt8 {
  public var toCControlCharacters: C_CC  {
    var result: C_CC = (
      cc_t(0), cc_t(0), cc_t(0), cc_t(0), cc_t(0),
      cc_t(0), cc_t(0), cc_t(0), cc_t(0), cc_t(0),
      cc_t(0), cc_t(0), cc_t(0), cc_t(0), cc_t(0),
      cc_t(0), cc_t(0), cc_t(0), cc_t(0), cc_t(0)
    )
    
    for key in ControlCharacterKey.allCases {
      switch key {
      case .endOfFile:
        result.0 = self[key] ?? 0
      case .endOfLine:
        result.2 = self[key] ?? 0
      case .endOfLine2:
        result.3 = self[key] ?? 0
      case .erase:
        result.4 = self[key] ?? 0
      case .wErase:
        result.5 = self[key] ?? 0
      case .kill:
        result.6 = self[key] ?? 0
      case .reprint:
        result.7 = self[key] ?? 0
      case .interrupt:
        result.8 = self[key] ?? 0
      case .quit:
        result.9 = self[key] ?? 0
      case .suspend:
        result.10 = self[key] ?? 0
      case .dSuspdend:
        result.11 = self[key] ?? 0
      case .start:
        result.12 = self[key] ?? 0
      case .stop:
        result.13 = self[key] ?? 0
      case .lNext:
        result.14 = self[key] ?? 0
      case .discard:
        result.15 = self[key] ?? 0
      case .min:
        result.16 = self[key] ?? 0
      case .time:
        result.17 = self[key] ?? 0
      case .status:
        result.18 = self[key] ?? 0
      case .nccs:
        result.19 = self[key] ?? 0
      }
    }
    
    return result
  }
}

extension Dictionary where Key == ControlCharacterKey, Value == UInt8 {
  public init(_ cControlCharasters: C_CC) {
    var result = Self()
    
    for key in ControlCharacterKey.allCases {
      switch key {
        
      case .endOfFile:
        result[key] = cControlCharasters.0
      case .endOfLine:
        result[key] = cControlCharasters.1
      case .endOfLine2:
        result[key] = cControlCharasters.2
      case .erase:
        result[key] = cControlCharasters.3
      case .wErase:
        result[key] = cControlCharasters.4
      case .kill:
        result[key] = cControlCharasters.5
      case .reprint:
        result[key] = cControlCharasters.6
      case .interrupt:
        result[key] = cControlCharasters.8
      case .quit:
        result[key] = cControlCharasters.9
      case .suspend:
        result[key] = cControlCharasters.10
      case .dSuspdend:
        result[key] = cControlCharasters.11
      case .start:
        result[key] = cControlCharasters.12
      case .stop:
        result[key] = cControlCharasters.13
      case .lNext:
        result[key] = cControlCharasters.14
      case .discard:
        result[key] = cControlCharasters.15
      case .min:
        result[key] = cControlCharasters.16
      case .time:
        result[key] = cControlCharasters.17
      case .status:
        result[key] = cControlCharasters.18
      case .nccs:
        result[key] = cControlCharasters.19
      }
    }
    
    self = result
  }
}


