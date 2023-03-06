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

```Swift
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
    
    // [`Please check footnotes for Case C`](https://apple.com)
    attributes.controlCharacters[.time] = 1
    attributes.controlCharacters[.min] = 0
```

## Termcaps
The Termcaps library provides helpers to take advandages of the terminal capabilities, such as:
 - Moving, hiding cursor
 - Cleaning the screen
 - And many more
 
### FootNotes
#### 1- Noncanonical Mode Input Processing 
  
---
   Case A: MIN > 0, TIME > 0
     In this case TIME serves as an inter-byte timer and is activated after the first byte is received.  Since it is an inter-byte timer, it is reset after a byte is received.  The interaction between MIN and TIME is as follows:  as soon as one byte is received, the
     inter-byte timer is started.  If MIN bytes are received before the inter-byte timer expires (remember that the timer is reset upon receipt of each byte), the read is satisfied.  If the timer expires before MIN bytes are received, the characters received to that
     point are returned to the user.  Note that if TIME expires at least one byte is returned because the timer would not have been enabled unless a byte was received.  In this case (MIN > 0, TIME > 0) the read blocks until the MIN and TIME mechanisms are activated
     by the receipt of the first byte, or a signal is received.  If data is in the buffer at the time of the read(), the result is as if data had been received immediately after the read().

   Case B: MIN > 0, TIME = 0
     In this case, since the value of TIME is zero, the timer plays no role and only MIN is significant.  A pending read is not satisfied until MIN bytes are received (i.e., the pending read blocks until MIN bytes are received), or a signal is received.  A program
     that uses this case to read record-based terminal I/O may block indefinitely in the read operation.

   Case C: MIN = 0, TIME > 0
     In this case, since MIN = 0, TIME no longer represents an inter-byte timer.  It now serves as a read timer that is activated as soon as the read function is processed.  A read is satisfied as soon as a single byte is received or the read timer expires.  Note
     that in this case if the timer expires, no bytes are returned.  If the timer does not expire, the only way the read can be satisfied is if a byte is received.  In this case the read will not block indefinitely waiting for a byte; if no byte is received within
     TIME*0.1 seconds after the read is initiated, the read returns a value of zero, having read no data.  If data is in the buffer at the time of the read, the timer is started as if data had been received immediately after the read.

   Case D: MIN = 0, TIME = 0
     The minimum of either the number of bytes requested or the number of bytes currently available is returned without waiting for more bytes to be input.  If no characters are available, read returns a value of zero, having read no data.
     
— Excerpt from BSD 4 ```man termios```
 TODO: 
  - Add more documentation
  - Add more concrete runable examples

