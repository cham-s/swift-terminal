# swift-terminal

Swift package containing utilities to help build applications using the terminal.
They are essentially wrappers around C libraries (termios.h, termcap.h) arranged to be used in Swift.

- Note: The code is experimental and not intend to be used in a production environment.

## Terminal
The Terminal module provides helpers to modifify the behavior of the terminal, such as:
  - Disabling echo of character when typing
  - Control the flow of read and output
  - And more

## Termcaps
The Termcaps library provides helpers to take advandages of the terminal capabilities, such as:
 - Moving, hiding cursor
 - Cleaning the screen
 - And more
 
 TODO: Add more documentation

