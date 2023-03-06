# swift-terminal

Swift package containing utilities to help build applications using the terminal.
They are essentially wrappers around C libraries (termios.h, termcap.h) arranged to be used in Swift.

- Note: The code is experimental and not intended to be used in a production environment.

## Terminal
The Terminal module provides helpers to modifify the behavior of the terminal, such as:
  - Disabling echo of character when typing
  - Control the flow of read and output
  - And many more
  
As an example the Terminal type can be used as a dependency to another type

```swift
import Terminal

// Define standard file descriptors
extension Int32 {
  public static let standardInput = 0
  public static let standardOutput = 1
  public static let standardError = 2
}

// Get the attributes from the current session terminal
var attributes = try terminalAttributes(from: .standardInput)

// The `disable` operator takes a list of options to be disabled.
// Here we want to disable:
// - printing each character read
// - triggering a read when newline is detected (Enter is pressed)
attributes.localFlags.disable([.canonicalize, .echo])

// Case C in Footnote 1- below
attributes.controlCharacters[.time] = 1
attributes.controlCharacters[.min] = 0

// The option indicates how we want the changes to be performed.
// Here we want to drain output then perform changes.
let terminal = try Terminal(
  attributes: attributes,
  option: .drain,
  terminalEnvVariable: "TERM"
)
```

## Termcaps
The Termcaps library provides helpers to take advandages of the terminal capabilities, such as:
 - Moving, hiding cursor
 - Cleaning the screen
 - And many more
 
 ```swift
import Termcaps

/// Termcap is an enum acting as a namespace to host termcap commands to execute on the terminal
/// `execute` is a convinient function for executing a list of commands.
/// A FullCommand is tuple with:
/// - a command
/// - a location
/// - a number of lines affected by the command

// Clear the screen
try Termcap.execute((.clearScreen, .origin, 1))

let lines = ["Hello!\n", "Echo Your Thoughts:\n", "Press Escape to quit\n"]

// Decorate and print the line
try zip(lines, lines.indices)
  .forEach { (line, i) in
    if i == 1 {
      // Activate reverse video
      try Termcap.execute((.reverseVideoOn, .origin, 1))
    }
    try terminal.inputFd.writeAll(line[...].utf8)
    if i == 1 {
      // Desactivate all decoration
      try Termcap.execute((.appeareanceModeOff, .origin, 1))
    }
  }


 ```
 
### FootNotes

#### 1- Noncanonical Mode Input Processing 
  
```
   Case C: MIN = 0, TIME > 0
     In this case, since MIN = 0, TIME no longer represents an inter-byte timer.  It now serves as a read timer that is activated as soon as the read function is processed.  A read is satisfied as soon as a single byte is received or the read timer expires.  Note
     that in this case if the timer expires, no bytes are returned.  If the timer does not expire, the only way the read can be satisfied is if a byte is received.  In this case the read will not block indefinitely waiting for a byte; if no byte is received within
     TIME*0.1 seconds after the read is initiated, the read returns a value of zero, having read no data.  If data is in the buffer at the time of the read, the timer is started as if data had been received immediately after the read.

```
     
— Excerpt from BSD 4 ```man termios```

TODO: 
  - Add more documentation
  - Add more concrete runable examples

