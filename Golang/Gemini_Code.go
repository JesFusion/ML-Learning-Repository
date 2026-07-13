// ==============================================================================================
// GO PROGRAM STRUCTURE & PACKAGE DECLARATION
// ==============================================================================================

// [WHAT IS THIS LINE] package main
// [MEANING] Declares that this file belongs to the "main" package
// [WHY IMPORTANT] Go programs start execution in the main() function of the main package
// [KEY CONCEPT] Every Go file must belong to exactly one package
// [SPECIAL RULE] The main package is special - it's where your program execution begins
// [EXAMPLE] If this was a library, you might write: package mylib
package main // [Gemini] 'package' bundles related code files together. 'main' is a special name telling Go, "This is the starting point of an application we can run!"

// ==============================================================================================
// IMPORT BLOCK - Bringing in External Code (Standard Library)
// ==============================================================================================

// [WHAT ARE IMPORTS] Like #include in C/C++; they bring in pre-built code packages
// [SYNTAX] import ("package1"; "package2") groups multiple imports together
// [STANDARD LIBRARY] Go comes with batteries included - these are built-in packages

import ( // [Gemini] 'import' lets us borrow code written by others, similar to 'import pandas as pd' in Python. The parentheses let us grab multiple tools at once without repeating the keyword.
	// [PACKAGE] context = Used for managing cancellation, timeouts, and request scoping
	// [USE CASE] When you have goroutines or long-running operations that need cancellation
	// [EXAMPLE] If your HTTP server receives a request, context passes info through the call chain
	"context" // [Gemini] A built-in tool to handle deadlines and cancel running tasks. Here, we're loading it into our program.

	// [PACKAGE] errors = Tools for creating and working with error values
	// [USE CASE] Creating custom error messages, wrapping errors
	// [EXAMPLE] errors.New("something went wrong") creates a basic error
	"errors" // [Gemini] Provides tools for dealing with things that go wrong. We import it to build custom error messages later.

	// [PACKAGE] fmt = "format" - printing and formatting strings
	// [USE CASE] Printing to console, formatting strings
	// [EXAMPLE] fmt.Println("Hello") prints and adds newline
	// [METHODS] Println (print with newline), Printf (formatted printing), Sprintf (format to string)
	"fmt" // [Gemini] Short for "format". This is our main tool for printing text to the screen, much like Python's print() function.

	// [PACKAGE] io = Input/Output interfaces and utilities
	// [USE CASE] Reading/writing data in a type-safe way
	// [EXAMPLE] io.Closer is an interface for things you can close (files, connections)
	"io" // [Gemini] Stands for Input/Output. It gives us standard ways to read from files, network connections, or data streams.

	// [PACKAGE] strings = Operations on string values
	// [USE CASE] Manipulating strings (split, join, contains, etc.)
	// [EXAMPLE] strings.Contains("hello", "ell") returns true
	"strings" // [Gemini] A toolbox specifically for searching, splitting, and manipulating text data.

	// [PACKAGE] sync = Synchronization primitives (mutual exclusion, waiting)
	// [USE CASE] When multiple goroutines access shared data
	// [EXAMPLE] sync.Mutex prevents concurrent access to shared variables
	"sync" // [Gemini] Helps safely coordinate multiple tasks running at the exact same time so they don't overwrite each other's data.

	// [PACKAGE] sync/atomic = Atomic operations (thread-safe without locks)
	// [USE CASE] Incrementing counters safely without using mutex
	// [EXAMPLE] atomic.AddInt64() increments a 64-bit int safely
	"sync/atomic" // [Gemini] A sub-package of 'sync' for doing math operations safely while multiple tasks run simultaneously.

	// [PACKAGE] time = Date, time, and duration functionality
	// [USE CASE] Measuring durations, getting current time, sleeping, timeouts
	// [EXAMPLE] time.Now() gets current time, time.Sleep(1*time.Second) waits 1 second
	"time" // [Gemini] Handles clocks, calendars, delays, and timers.
)

// ==============================================================================================
// SEGMENT 1: Go Environment & Development Setup
// ==============================================================================================
// [IMPORTANT CONCEPT] Segment 1 covers concepts that aren't directly in code
// [TOPICS COVERED]
//   - GOROOT: Directory where Go itself is installed (system-wide)
//   - GOPATH: (old) Workspace for Go code (deprecated, use modules instead)
//   - GOBIN: Where compiled executables are placed
//   - go.mod: File declaring your project's name and dependencies
//   - go.sum: File with SHA256 hashes ensuring dependency reproducibility
//   - Go Modules: Modern dependency management (replaces old GOPATH)
//   - Compilation: Go compiles to single static binary (no runtime dependency!)
//   - Cross-compilation: Easy to compile for different OS/architecture

// [WHAT IS THIS STRUCT] BuildArtifact represents a compiled binary
// [WHY CREATE THIS] Demonstrates Go's compilation model (static, single-file binaries)
// [STRUCT FIELDS] Named data grouped together
type BuildArtifact struct { // [Gemini] 'type' creates a brand new blueprint for data. 'struct' groups different variables together. Think of it exactly like defining a Class in Python, or a single row layout in a Pandas DataFrame!
	// [FIELD] BinaryPath - where the binary file lives on disk
	// [TYPE] string - sequence of characters (immutable UTF-8 bytes)
	BinaryPath string // [Gemini] 'string' means text. This line creates a text field to hold the file's location.
	
	// [FIELD] ModuleName - the module name (from go.mod)
	// [TYPE] string - typically like "github.com/username/projectname"
	ModuleName string // [Gemini] Another text field, this one storing the name of the module.
	
	// [FIELD] Version - semantic versioning (e.g., "1.0.0", "1.2.3")
	// [TYPE] string - helps track which version of code was compiled
	Version string // [Gemini] Text field for holding version numbers like "1.0".
	
	// [FIELD] Timestamp - when the binary was built
	// [TYPE] time.Time - built-in Go type for dates/times
	Timestamp time.Time // [Gemini] 'time.Time' is a specific data type from our 'time' import. This records the exact moment the file was built.
	
	// [FIELD] IsStatic - whether binary is statically linked
	// [TYPE] bool - true or false
	// [WHAT IS STATIC LINKING] Binary contains all dependencies; can run anywhere
	// [CONTRAST] Dynamic linking - binary depends on external libraries on the system
	IsStatic bool // [Gemini] 'bool' (boolean) holds just 'true' or 'false'. This acts as a yes/no switch.
}

// [WHAT IS THIS STRUCT] WorkspaceLayout shows typical Go project structure
// [WHY IMPORTANT] Organizing code makes it maintainable and conventional
type WorkspaceLayout struct { // [Gemini] Creating another custom blueprint named WorkspaceLayout to hold multiple folder names.
	// [FIELD] CmdDir - directory for executable entry points
	// [CONVENTION] src/cmd/ contains main packages that become executables
	CmdDir string // [Gemini] Text container for the command directory path.
	
	// [FIELD] PkgDir - directory for public library code
	// [CONVENTION] src/pkg/ or just individual package directories
	PkgDir string // [Gemini] Text container for the package directory path.
	
	// [FIELD] InternalDir - code only used within this project
	// [CONVENTION] internal/ directory (Go prevents importing this from external projects)
	InternalDir string // [Gemini] Text container for the internal directory path.
	
	// [FIELD] VendorDir - local copy of dependencies
	// [CONVENTION] vendor/ directory (optional, for offline builds)
	VendorDir string // [Gemini] Text container for the vendor directory path.
}

// ==============================================================================================
// SEGMENT 2: Core Language Syntax & Type System
// ==============================================================================================
// [BIG CONCEPT] Everything in Go has a TYPE. Understanding types is fundamental.
// [KEY PRINCIPLE] Go is statically typed - types are checked at compile-time, not runtime
// [ZERO VALUES] Every type has a default value when declared:
//   - int/float/bool/string default to 0, false, or ""
//   - pointers default to nil (like NULL in other languages)

// [WHAT IS THIS STRUCT] TypeSystemDemo shows all basic Go types
// [WHY LEARN TYPES FIRST] Types prevent bugs; Go catches type mismatches before runtime
type TypeSystemDemo struct { // [Gemini] Setting up a blueprint to showcase all the different flavors of data Go can handle.
	// [COMMENT EXPLAINING INTEGERS]
	// Go has many integer types. "int" size depends on your system (32 or 64 bits).
	// Use specific sizes (int32, int64) when interoperating with C or binary formats.
	
	// [TYPE] int - signed integer (could be 32 or 64 bits depending on platform)
	// [USE WHEN] Size doesn't matter; this is the default
	IntValue int // [Gemini] 'int' stores whole numbers (positive or negative). This is your standard go-to number type.
	
	// [TYPE] int8 - signed integer, exactly 8 bits
	// [RANGE] -128 to 127
	// [USE WHEN] Saving space, working with bytes
	Int8Value int8 // [Gemini] A tiny integer that uses barely any memory, good for very small numbers.
	
	// [TYPE] int32 - signed integer, exactly 32 bits  
	// [RANGE] about -2 billion to 2 billion
	// [USE WHEN] Fixed size needed, C interop
	Int32Value int32 // [Gemini] A medium-sized integer.
	
	// [TYPE] int64 - signed integer, exactly 64 bits
	// [RANGE] about -9 quintillion to 9 quintillion  
	// [USE WHEN] Very large numbers, Unix timestamps
	Int64Value int64 // [Gemini] A massive integer, perfect for huge datasets or tracking time in milliseconds since 1970.
	
	// [TYPE] byte - alias for uint8 (unsigned, 0 to 255)
	// [USE WHEN] Working with binary data, character codes
	// [SPECIAL] "byte" is preferred over "uint8" for readability
	ByteValue byte // [Gemini] 'byte' is a small positive-only number (0-255), representing raw data chunks like image pixels in ML computer vision tasks!
	
	// [TYPE] uint - unsigned integer (like int but always positive)
	// [RANGE] 0 to very large number (depends on platform)
	UintValue uint // [Gemini] 'uint' means Unsigned Integer. It's an 'int' that literally cannot be negative.
	
	// [TYPE] uint64 - unsigned integer, exactly 64 bits
	// [RANGE] 0 to about 18 quintillion
	// [USE WHEN] Large positive numbers, IDs, bit flags
	UintValue64 uint64 // [Gemini] A massive positive-only integer.

	// [COMMENT ABOUT FLOATS]
	// Floating-point numbers follow IEEE 754 standard (like other languages)
	// Precision is limited! Don't use for financial calculations (use big.Decimal instead)
	
	// [TYPE] float32 - 32-bit IEEE 754 floating point
	// [PRECISION] About 6-7 decimal digits
	// [USE WHEN] Saving space (graphics, scientific computing)
	Float32Value float32 // [Gemini] 'float32' holds numbers with decimal points. Often used in ML models where slight precision loss is okay to save RAM (like PyTorch's float32).
	
	// [TYPE] float64 - 64-bit IEEE 754 floating point
	// [PRECISION] About 15 decimal digits
	// [DEFAULT] When you write 3.14, Go assumes float64
	// [USE WHEN] Default choice for floats; most scientific/financial work
	Float64Value float64 // [Gemini] 'float64' is a high-precision decimal number. It's Go's default choice for decimals.

	// [COMMENT ABOUT BOOLEANS]
	// Booleans are simple: true or false. Used in if statements and conditions.
	// They don't implicitly convert to int (unlike C).
	
	// [TYPE] bool - true or false
	// [DEFAULT VALUE] false (when declared without initialization)
	// [KEY DIFFERENCE] In C, if(1) is true; in Go, you must use if(true)
	BoolValue bool // [Gemini] Field to store a true/false condition.
	
	// [COMMENT ABOUT STRINGS]
	// Strings in Go are immutable byte sequences (UTF-8 encoded)
	// This means: once created, they can't change (but you can create new ones)
	// Immutability enables efficient sharing and is safe for concurrent access
	
	// [TYPE] string - immutable sequence of UTF-8 bytes
	// [DEFAULT VALUE] "" (empty string)
	// [INDEXING] s[0] gets the first BYTE (not character for non-ASCII)
	// [LENGTH] len(s) returns bytes (not characters for multi-byte UTF-8)
	StringValue string // [Gemini] Field to store text.

	// [COMMENT ABOUT RUNES]
	// "rune" is Go's way of representing a single Unicode character
	// It's an alias for int32 (which can hold any Unicode code point)
	// Use rune when you care about individual characters, not bytes
	
	// [TYPE] rune - represents single Unicode character (alias for int32)
	// [USE WHEN] Iterating over strings character-by-character
	// [EXAMPLE] 'A' is a rune with value 65
	// [DIFFERENCE FROM BYTE] Rune can be any Unicode char; byte is just 0-255
	RuneValue rune // [Gemini] 'rune' holds a single text character, like 'J' or an emoji '🚀'.
}

// [FUNC] This is a function - a reusable block of code
// [MEANING] DemonstrateVariableDeclaration = function name (what it does)
// [SYNTAX] func functionName() { body } is the Go function syntax
// [PARAMETERS] () - empty means this function takes no arguments
// [RETURN TYPE] No return type specified, so returns nothing (void in C terms)
// [EXECUTION] Called from main() as: DemonstrateVariableDeclaration()
func DemonstrateVariableDeclaration() { // [Gemini] 'func' defines an action or a recipe. This acts just like 'def' in Python to create a reusable block of code.
	// [WHAT LINE IS THIS] var age int = 25
	// [var KEYWORD] Declares a variable (mutable storage)
	// [age] Variable name (what you call it when you use it)
	// [int] Type (what kind of data it holds)
	// [= 25] Initial value (what it starts out as)
	// [READING IT] "Declare a variable named 'age' of type 'int' and assign it the value 25"
	var age int = 25 // [Gemini] 'var' creates a container. We name it 'age', enforce that it must be an 'int', and put '25' inside it.
	
	// [SIMILAR DECLARATION] name is a string variable with initial value "Alice"
	var name string = "Alice" // [Gemini] Creating a text container named 'name' and filling it with "Alice".

	// [WHAT IS A ZERO VALUE] When you declare without assigning a value
	// Go sets it to the "zero value" for that type:
	// - int/float/byte: 0
	// - bool: false
	// - string: "" (empty)
	// - pointer: nil (means "points to nothing")
	
	// [ZERO VALUE EXAMPLE] balance starts as 0.0 (even though we don't say = 0.0)
	var balance float64    // Defaults to 0.0 // [Gemini] If we don't give it a value right away, Go safely defaults numbers to 0 instead of leaving unpredictable garbage memory.
	
	// [ZERO VALUE EXAMPLE] isActive starts as false
	var isActive bool      // Defaults to false // [Gemini] Booleans default to false if empty.
	
	// [ZERO VALUE EXAMPLE] username starts as empty string ""
	var username string    // Defaults to "" // [Gemini] Text defaults to absolutely empty (no characters).
	
	// [ZERO VALUE EXAMPLE] count starts as 0
	var count int          // Defaults to 0 // [Gemini] Integers default to 0.
	
	// [ZERO VALUE EXAMPLE] ptr starts as nil (null pointer)
	var ptr *int // Defaults to nil (the * means it's a pointer) // [Gemini] We haven't learned pointers yet, but if you don't assign them, they default to 'nil' (Go's version of Python's 'None').

	// [SHORT DECLARATION] := operator (only works inside functions!)
	// [WHAT IT DOES] Declares AND initializes variable
	// [TYPE INFERENCE] Go figures out the type from the value on the right
	// [SYNTAX] variableName := value
	// [READING IT] "create message variable, initialize to 'Hello, Go!', let Go figure out type"
	message := "Hello, Go!"  // Go infers this is a string // [Gemini] `:=` is a magic shortcut. It creates the variable AND figures out the data type automatically so we don't have to write 'var' or 'string'.
	
	// [TYPE INFERENCE] Go sees 42 is an int, so value is int type
	value := 42 // [Gemini] Using the shortcut to create an int.
	
	// [TYPE INFERENCE] Go sees 3.14159 is a float, so pi is float64 type
	pi := 3.14159 // [Gemini] Using the shortcut to create a float64.

	// [IMPORTANT WARNING] These lines tell you about Go rules
	// [RULE] := only works INSIDE functions
	// [WHERE IT FAILS] At the top level of your program (package scope), you must use var
	// [WHY] At package level, code isn't executing yet; only function-level code is executed

	// [CONST KEYWORD] Constants are like variables but CAN'T CHANGE after declaration
	// [KEY DIFFERENCE FROM VAR] const must have a compile-time constant value
	// [WHAT IS COMPILE-TIME] Value must be known before the program runs
	// [EXAMPLE] You can't do: const x int = getUserInput() because that's a runtime value
	
	// [CONST EXAMPLE] MaxRetries is a constant (can't change it later)
	const MaxRetries = 3 // [Gemini] 'const' stands for constant. It locks the value permanently. If you try to change MaxRetries later, the program will refuse to run.
	
	// [CONST WITH TYPE] APITimeout is a constant with explicit type
	// [TIME CALCULATIONS] time.Second is a built-in duration (1 second)
	// [MULTIPLICATION] 30 * time.Second means 30 times one second = 30 seconds
	const APITimeout = 30 * time.Second // [Gemini] Creating a locked variable using the 'time' tool we imported earlier.
	
	// [CONST PI] Mathematical constant - doesn't change
	const PI = 3.14159265359 // [Gemini] Locking the math value of PI.

	// [WHAT IS TYPE INFERENCE] Go looks at what you assign and guesses the type
	// [WHY THIS IS GOOD] Less typing, but still type-safe (checked at compile-time)
	
	// [INFERENCE EXAMPLE 1] The number 10 looks like an int
	defaultInt := 10                    // inferred as type int // [Gemini] Another shortcut example.
	
	// [INFERENCE EXAMPLE 2] The number 10.5 has decimal, must be float64
	defaultFloat := 10.5                // inferred as type float64 // [Gemini] Automatically assigning float64.
	
	// [INFERENCE EXAMPLE 3] Text in quotes is always string
	defaultString := "text"             // inferred as type string // [Gemini] Automatically assigning string.
	
	// [INFERENCE EXAMPLE 4] Single character in single quotes is rune
	defaultRune := 'A'                  // inferred as type rune (NOT byte) // [Gemini] Using single quotes automatically tells Go to treat this as a single 'rune' character.
	
	// [INFERENCE EXAMPLE 5] Complex number (with 'i' for imaginary)
	defaultComplex := 1 + 2i            // inferred as type complex128 // [Gemini] Go even supports complex numbers out of the box for advanced math!

	// [WHAT IS TYPE CONVERSION] Taking value of one type and changing it to another
	// [WHY NEEDED] Sometimes you have int but function wants float64
	// [SYNTAX] TargetType(value) converts value to TargetType
	// [KEY RULE] Go does NOT automatically convert types (unlike C)
	// [EXAMPLE] int 100 doesn't automatically become float64 100.0; must be explicit
	
	// [DECLARING VARIABLE] intVal is int type with value 100
	var intVal int = 100 // [Gemini] Standard variable setup.
	
	// [CONVERSION] float64(intVal) means "take intVal and convert to float64"
	// [RESULT] Creates a new float64 value, doesn't modify intVal
	floatVal := float64(intVal) // Convert int to float64 // [Gemini] Wrapping a variable in a type name converts it. Here we explicitly turn an int into a float, just like float(x) in Python.
	
	// [CONVERSION VIA FORMATTING] Sprintf formats as string
	// [EXAMPLE] %d means "format as decimal integer"
	// [RESULT] "100" (string) instead of 100 (number)
	stringVal := fmt.Sprintf("%d", intVal) // Convert int to string via formatting // [Gemini] We use 'fmt' to secretly "print" the number into a new string text variable instead of to the screen.

	// [WHAT ARE THESE LINES] Using blank identifier _ to prevent "unused variable" errors
	// [WHY GO COMPLAINS] Go considers unused variables as potential bugs
	// [SOLUTION] Assign to _ to suppress the warning
	// [USE CASE] When you need a variable for demonstration but won't use it
	_ = age // [Gemini] Go is strict! If you create a variable and don't use it, it throws an error. The underscore `_` is a trash can. It tells Go "I know I'm not using this, throw it away and don't complain."
	_ = name // [Gemini] Trashing unused variables for the demo.
	_ = balance
	_ = isActive
	_ = username
	_ = count
	_ = ptr
	_ = message
	_ = value
	_ = pi
	_ = MaxRetries
	_ = APITimeout
	_ = PI
	_ = defaultInt
	_ = defaultFloat
	_ = defaultString
	_ = defaultRune
	_ = defaultComplex
	_ = floatVal
	_ = stringVal
}

// [FUNCTION] DemonstrateOperators shows how to do math and comparisons
// [WHAT ARE OPERATORS] Symbols that perform actions on values (+, -, *, etc.)
// [CATEGORIES] Arithmetic (+-*), comparison (==<>), logical (&&||!), bitwise (&|^)
func DemonstrateOperators() { // [Gemini] Setting up a new action block to practice math.
	// [MULTIPLE ASSIGNMENT] Create two variables in one line
	// [SYNTAX] a, b := value1, value2
	// [RESULT] a=10, b=3
	a, b := 10, 3 // [Gemini] We can use the shortcut `:=` to create multiple variables at once. 'a' gets 10, 'b' gets 3.
	
	// [ARITHMETIC OPERATOR] + (addition)
	// [RESULT] 10 + 3 = 13
	sum := a + b        // 13 // [Gemini] Addition operator `+`.
	
	// [ARITHMETIC OPERATOR] - (subtraction)
	// [RESULT] 10 - 3 = 7
	diff := a - b       // 7 // [Gemini] Subtraction operator `-`.
	
	// [ARITHMETIC OPERATOR] * (multiplication)
	// [RESULT] 10 * 3 = 30
	product := a * b    // 30 // [Gemini] Multiplication operator `*`.
	
	// [ARITHMETIC OPERATOR] / (division)
	// [IMPORTANT] If both are integers, result is integer (10/3 = 3, not 3.33)
	// [EXPLANATION] This is integer division; drops the decimal part
	quotient := a / b   // 3 (not 3.33, because both operands are ints) // [Gemini] Division operator `/`. Because both numbers are whole integers, Go cuts off any decimal remainder.
	
	// [ARITHMETIC OPERATOR] % (modulo/remainder)
	// [WHAT IT DOES] Gives remainder after division
	// [EXAMPLE] 10 divided by 3 is 3 remainder 1, so 10%3 = 1
	remainder := a % b  // 1 // [Gemini] Modulo operator `%` acts as a math divider, but it only returns the leftovers/remainder.

	// [COMPARISON OPERATORS] Check if something is true or false
	// [RESULT TYPE] Always returns bool (true or false)
	
	// [COMPARISON] > (greater than)
	// [RESULT] Is 10 > 3? Yes, so true
	isGreater := a > b      // true // [Gemini] Checking "is 'a' strictly bigger than 'b'?". Results in a boolean true/false.
	
	// [COMPARISON] == (equals)
	// [RESULT] Is 10 == 3? No, so false
	// [NOTE] Single = assigns; double == compares
	isEqual := a == b       // false // [Gemini] Double equals `==` checks if things are identical. (Single `=` is only for putting data into variables!)
	
	// [COMPARISON] != (not equal)
	// [RESULT] Is 10 != 3? Yes (they're different), so true
	isNotEqual := a != b    // true // [Gemini] The `!` means "Not". So `!=` asks "Are these two things NOT identical?".
	
	// [COMPARISON] <= (less than or equal)
	// [RESULT] Is 10 <= 3? No, so false
	isLessOrEqual := a <= b // false // [Gemini] Checking "is 'a' less than OR exactly the same as 'b'?".

	// [LOGICAL OPERATORS] Combine boolean values
	// [RESULT] Always returns bool
	
	// [LOGICAL OPERATOR] && (AND)
	// [MEANING] Both sides must be true for result to be true
	// [EVALUATION] (10 > 18) is false AND (10 < 100) is true → false AND true = false
	// [SHORT CIRCUIT] If left side is false, right side isn't even evaluated
	isAdult := (a > 18) && (a < 100)  // false && true = false // [Gemini] `&&` requires BOTH conditions to be true to succeed. (Just like 'and' in Python).
	
	// [LOGICAL OPERATOR] || (OR)
	// [MEANING] At least one side must be true for result to be true
	// [EVALUATION] false OR true = true
	// [SHORT CIRCUIT] If left side is true, right side isn't evaluated
	isWeekend := false || true         // false || true = true // [Gemini] `||` acts like a bouncer checking VIP lists: if AT LEAST ONE condition is true, it succeeds. (Like 'or' in Python).
	
	// [LOGICAL OPERATOR] ! (NOT)
	// [MEANING] Flips true to false, false to true
	// [EVALUATION] Is 10 > 50? No (false). NOT false = true
	isNotValid := !(a > 50)            // !(false) = true // [Gemini] `!` reverses a boolean. True becomes false, false becomes true.

	// [BITWISE OPERATORS] Work on binary representations
	// [WHEN TO USE] Low-level operations, bit flags, protocols
	// [BINARY REPRESENTATION] 5 is 0101, 3 is 0011
	
	// [NEW VARIABLES] x and y for bitwise demos
	x, y := 5, 3              // binary: 0101, 0011 // [Gemini] Creating two new variables for some low-level computer math.
	
	// [BITWISE] & (AND each bit)
	// [HOW IT WORKS] Bit is 1 only if BOTH inputs are 1
	//   0101 & 0011 = 0001 (only position 0 has 1 in both)
	// [RESULT] 0001 = 1
	bitwiseAnd := x & y       // 0001 = 1 // [Gemini] A single `&` compares data at the raw binary level (1s and 0s). Only keeps 1s where both numbers have a 1.
	
	// [BITWISE] | (OR each bit)
	// [HOW IT WORKS] Bit is 1 if AT LEAST ONE input is 1
	//   0101 | 0011 = 0111 (positions 0,1,2 have at least one 1)
	// [RESULT] 0111 = 7
	bitwiseOr := x | y        // 0111 = 7 // [Gemini] A single `|` compares binary and keeps 1s if EITHER number has a 1.
	
	// [BITWISE] ^ (XOR - exclusive or)
	// [HOW IT WORKS] Bit is 1 if inputs DIFFER
	//   0101 ^ 0011 = 0110 (positions 1,2 differ)
	// [RESULT] 0110 = 6
	bitwiseXor := x ^ y       // 0110 = 6 // [Gemini] `^` compares binary and keeps 1s ONLY if the numbers differ at that spot.
	
	// [BITWISE] << (left shift)
	// [HOW IT WORKS] Move all bits left, fill with zeros
	//   0101 << 1 = 1010 (moved left 1 position)
	// [EFFECT] Equivalent to multiplying by 2^n (where n is shift amount)
	// [RESULT] 1010 = 10
	leftShift := x << 1       // 1010 = 10 // [Gemini] `<<` shifts the binary 1s and 0s to the left. A hyper-fast way to multiply numbers.
	
	// [BITWISE] >> (right shift)
	// [HOW IT WORKS] Move all bits right, fill with zeros (for unsigned)
	//   0101 >> 1 = 0010 (moved right 1 position)
	// [EFFECT] Equivalent to dividing by 2^n
	// [RESULT] 0010 = 2
	rightShift := x >> 1      // 0010 = 2 // [Gemini] `>>` shifts the binary to the right. A hyper-fast way to divide numbers.

	// [PREVENT UNUSED WARNINGS] Again using _ to suppress warnings
	_ = sum // [Gemini] Trashing our demo variables again so the compiler doesn't yell at us!
	_ = diff
	_ = product
	_ = quotient
	_ = remainder
	_ = isGreater
	_ = isEqual
	_ = isNotEqual
	_ = isLessOrEqual
	_ = isAdult
	_ = isWeekend
	_ = isNotValid
	_ = bitwiseAnd
	_ = bitwiseOr
	_ = bitwiseXor
	_ = leftShift
	_ = rightShift
}

// [FUNCTION] DemonstrateControlFlow shows if/else, switch, for, and defer
// [WHAT IS CONTROL FLOW] Deciding which code to run based on conditions
// [KEY PRINCIPLE] Sequential by default (line by line) but can branch with if/switch
func DemonstrateControlFlow() { // [Gemini] Starting an action block to learn how to control the direction our program takes.
	// [WHAT LINE IS THIS] age := 25
	// [DECLARATION] Creating variable age, type is inferred as int, value is 25
	age := 25 // [Gemini] Shortcut variable creation.
	
	// [IF STATEMENT] "if condition { do this }"
	// [SYNTAX] No parentheses required (unlike C)
	// [BRACES] Mandatory - Go requires them even for single statement
	// [EXECUTION] Code in braces runs only if condition is true
	if age >= 18 { // [Gemini] `if` acts like a fork in the road. If the math is true, run the code inside the `{}` curly braces.
		// [FUNCTION CALL] fmt.Println prints to console with newline
		// [STRING] Text in quotes is a string literal
		fmt.Println("Adult") // [Gemini] Printing to the screen.
	} else if age >= 13 { // [Gemini] `else if` acts as a backup plan. Checked ONLY if the first 'if' failed.
		// [ELSE IF] Checked only if previous condition was false
		// [CHAINING] You can chain many else if conditions
		fmt.Println("Teen")
	} else { // [Gemini] `else` is the final safety net. It runs if literally everything above it failed.
		// [ELSE] Runs if no previous condition was true
		fmt.Println("Child")
	}

	// [SWITCH STATEMENT] More readable than many if/else statements
	// [SYNTAX] switch value { case option1: ... case option2: ... }
	// [HOW IT WORKS] Compares value against each case
	
	day := "Monday"  // Variable to switch on
	switch day { // [Gemini] `switch` is a much cleaner way to write a giant block of "if / else if / else if / else if". It tests the 'day' variable against multiple scenarios.
	// [CASE] If day equals "Monday", "Tuesday", or "Wednesday"
	// [SYNTAX] case val1, val2, val3: means "any of these values"
	case "Monday", "Tuesday", "Wednesday": // [Gemini] `case` represents a single scenario. Here we check three at once.
		fmt.Println("Weekday")
	// [ANOTHER CASE] If day equals "Saturday" or "Sunday"
	case "Saturday", "Sunday": // [Gemini] Checking weekend scenarios.
		fmt.Println("Weekend")
	// [DEFAULT] If none of the cases match
	// [PURPOSE] Fallback behavior, like else
	default: // [Gemini] `default` is the fallback net, exactly like 'else'.
		fmt.Println("Unknown")
	}

	// [SWITCH WITHOUT EXPRESSION] Using switch like if/else
	// [SYNTAX] switch { case condition1: ... case condition2: ... }
	// [BENEFIT] More readable when testing different conditions
	
	score := 85  // Variable holding a score
	switch { // [Gemini] A 'switch' with no specific variable to test just goes down the list checking conditions until it finds one that is true.
	// [CASE] First condition checked
	case score >= 90:
		fmt.Println("Grade A")
	// [CASE] Only checked if above was false
	case score >= 80: // [Gemini] Our score is 85, so this case hits and the program exits the switch!
		fmt.Println("Grade B")  // This one runs (85 >= 80)
	// [DEFAULT] If nothing matches
	default:
		fmt.Println("Below B")
	}

	// [C-STYLE FOR LOOP] Traditional loop with init, condition, post
	// [SYNTAX] for init; condition; post { body }
	// [EXECUTION FLOW]
	//   1. init runs once (i := 0)
	//   2. Check condition (i < 5) - if false, exit loop
	//   3. Run body (anything in braces)
	//   4. Run post (i++)
	//   5. Go back to step 2
	
	// [LOOP VARIABLE] i starts at 0
	for i := 0; i < 5; i++ { // [Gemini] `for` is how we repeat code. This setup has three parts: Start counting at 0 (`i := 0`), keep looping while `i` is less than 5, and add 1 to `i` after every loop (`i++`).
		// [WHAT HAPPENS] First iteration: i=0, body runs
		//                 Second iteration: i=1, body runs
		//                 ... continues until i=5 (condition fails)
		_ = i  // Use i (can do anything here) // [Gemini] Trashing `i` so it doesn't cause an unused variable error.
	}

	// [WHILE-STYLE FOR LOOP] Just condition, no init or post
	// [SYNTAX] for condition { body }
	// [USAGE] When you don't know iteration count beforehand
	
	count := 0  // Initialize counter
	for count < 3 { // [Gemini] Go doesn't have a 'while' loop like Python. We just use `for` with only one condition! It keeps running until the condition becomes false.
		// [MANUAL INCREMENT] Must increment inside loop
		count++ // [Gemini] `++` means add 1 to the variable. (Same as count += 1 in Python).
	}

	// [INFINITE FOR LOOP] No condition at all
	// [SYNTAX] for { body }
	// [EXECUTION] Runs forever unless you use break
	
	shouldBreak := true  // Control variable
	for { // [Gemini] A totally naked `for` will loop literally forever until the universe ends... or until we stop it manually!
		// [BREAK STATEMENT] Exits the loop
		// [PURPOSE] Only way to exit infinite loop
		if shouldBreak { // [Gemini] Standard if check.
			break // [Gemini] `break` is an emergency exit. It immediately smashes out of the loop and stops it from running.
		}
	}

	// [RANGE LOOP OVER SLICE] Iterating over a list/collection
	// [SYNTAX] for index, value := range collection { ... }
	// [INDEX] Position in the collection (starts at 0)
	// [VALUE] The actual element at that position
	
	items := []string{"apple", "banana", "cherry"}  // List of strings // [Gemini] We are creating a list of text here (called a "Slice").
	for idx, item := range items { // [Gemini] `range` is incredibly powerful. It acts just like Python's `enumerate()`. It unpacks the list, giving us the index position (0, 1, 2) AND the actual item ("apple", "banana").
		// [ITERATION 1] idx=0, item="apple"
		// [ITERATION 2] idx=1, item="banana"
		// [ITERATION 3] idx=2, item="cherry"
		_ = idx // [Gemini] Trashing the index variable.
		_ = item // [Gemini] Trashing the item variable.
	}

	// [RANGE LOOP OVER MAP] Iterating over key-value pairs
	// [SYNTAX] for key, value := range map { ... }
	// [ORDER] Random! Map iteration order is intentionally shuffled
	// [WHY RANDOM] Prevents code depending on order (which would break on other computers)
	
	scores := map[string]int{"Alice": 90, "Bob": 85}  // Map of names to scores // [Gemini] A 'map' is EXACTLY like a Python dictionary! Keys on the left, values on the right.
	for name, score := range scores { // [Gemini] When we use `range` on a map/dictionary, it gives us the Key and the Value instead of the index and item.
		// [NAME] The key (e.g., "Alice")
		// [SCORE] The value (e.g., 90)
		_ = name // [Gemini] Trashing demo vars.
		_ = score
	}

	// [DISCARDING RANGE VALUES] Sometimes you only need one part
	// [SYNTAX] for _, value := range collection (underscore ignores index)
	// [WHY UNDERSCORE] Go compiler warns about unused variables
	
	for _, val := range items { // [Gemini] Since we don't care about the index number right now, we use our trash can `_` so Go doesn't complain about unused variables!
		// [UNDERSCORE] Means "I don't care about the index"
		_ = val
	}

	// [DEFER STATEMENT] "Run this code when the function exits"
	// [SYNTAX] defer statement
	// [KEY PROPERTY] LIFO - Last In, First Out (like a stack)
	// [USE CASE] Cleanup code (close files, release locks, etc.)
	
	// [DEFER 1] This will run 3rd (when function returns)
	defer fmt.Println("Third (deferred last)") // [Gemini] `defer` tells Go: "Don't run this code now! Wait until this entire function is completely finished, and run it right before exiting."
	
	// [DEFER 2] This will run 2nd (after defer above but before function exit)
	defer fmt.Println("Second (deferred middle)") // [Gemini] If you stack multiple defers, they run in reverse order (Last In, First Out).
	
	// [IMMEDIATE EXECUTION] This runs immediately (1st)
	fmt.Println("First (immediate)") // [Gemini] Standard print, runs normally!
	
	// [OUTPUT] First, Second, Third
	// [WHY DEFER IS USEFUL] Ensures cleanup even if function panics
	// [EXAMPLE] defer file.Close() guarantees file closes, even on error
}

// ==============================================================================================
// SEGMENT 3: Pointers & Memory Fundamentals
// ==============================================================================================
// [BIG CONCEPT] Pointers are addresses of data in memory
// [WHY POINTERS] Pass data by reference (avoid copying), mutate function parameters
// [THE * SYMBOL] In type position (*int) means pointer; in value position (*p) dereferences

// [FUNCTION] Demonstrates what pointers are and how to use them
func DemonstratePointerBasics() { // [Gemini] Action block to learn Pointers! Think of pointers as GPS coordinates that point to where data lives on your computer's RAM.
	// [VARIABLE DECLARATION] Declare a pointer to int
	// [SYNTAX] var ptr *int
	// [MEANING] ptr can hold the ADDRESS of an int
	// [ZERO VALUE] nil (null/nothing)
	// [VISUAL] ptr: [nil]  (not pointing anywhere yet)
	var ptr *int        // Pointer to int; zero value is nil // [Gemini] Placing a `*` in front of a type creates a Pointer. This variable cannot hold an integer; it can only hold the MEMORY ADDRESS of an integer!
	
	// [CREATE A VALUE] Create an int variable with value 42
	// [VISUAL] value: [42]
	value := 42 // [Gemini] Creating a standard int variable.
	
	// [ADDRESS-OF OPERATOR] & gets the address of a variable
	// [SYNTAX] &variable gives you the address
	// [RESULT] ptr now points to value
	// [VISUAL] value: [42], ptr: [pointing to value]
	ptr = &value        // & means "address of value" // [Gemini] The `&` symbol acts like a GPS tracker. It extracts the raw memory address of 'value' and stores it inside 'ptr'.

	// [DEREFERENCE OPERATOR] * accesses the value a pointer points to
	// [SYNTAX] *pointer gives you the value at that address
	// [RESULT] derefValue gets the value at the address ptr points to
	// [VISUAL] We look through ptr to find value, which is 42
	derefValue := *ptr  // derefValue = 42 // [Gemini] When we use `*` on an existing pointer variable, it acts like a teleporter. It travels to the memory address and grabs the actual data sitting there.
	_ = derefValue

	// [NIL POINTER DANGER] Accessing nil pointer causes panic (crash)
	// [WHAT IS NIL] Like null in other languages - "points to nothing"
	
	var nilPtr *int  // Declared but not initialized - is nil // [Gemini] A pointer with no address assigned is 'nil'.
	// [SAFETY CHECK] ALWAYS check before dereferencing
	// [IF CHECK] "if nilPtr is not nil"
	if nilPtr != nil { // [Gemini] If we try to teleport to a 'nil' address, the program will violently crash! Always check if it's not nil first.
		// [SAFE DEREFERENCE] Only executed if nilPtr is not nil
		_ = *nilPtr // Safe: only executed if nilPtr is not nil // [Gemini] Safely teleporting to the address.
	}

	// [PASS BY VALUE] Regular variable copying
	original := 10       // Variable with value 10 // [Gemini] Creating a standard int.
	byValue := original  // Create a COPY of original // [Gemini] Normal assignment physically copies the data into a new RAM slot.
	byValue = 20         // Change the copy // [Gemini] Changing the copy.
	_ = original         // Still 10 (unaffected) // [Gemini] The original is totally safe because they live in different memory locations.
}

// [HELPER FUNCTION] Receives a pointer and modifies the original
// [PARAMETER] *int - this function expects a pointer to int
// [MODIFICATION] Changes affect the original variable
func modifyByPointer(ptr *int) { // [Gemini] This function demands a memory address (a pointer) instead of a copied value.
	// [DEREFERENCE AND ASSIGN] *ptr = 100
	// [MEANING] "Go to the address ptr points to, and store 100 there"
	// [EFFECT] Original variable's value changes!
	*ptr = 100 // [Gemini] We use the teleporter `*` to go directly to the original memory address and permanently overwrite the data there. It will affect the rest of the program!
}

// [FUNCTION] Shows memory allocation with new() and make()
// [BIG CONCEPT] Some data lives on stack (automatic cleanup), some on heap (garbage collected)
func DemonstrateMemoryAllocation() { // [Gemini] Let's look at how Go reserves memory.
	// [NEW BUILTIN] Allocates memory, returns a pointer
	// [SYNTAX] new(Type)
	// [WHAT IT DOES] Allocates zeroed memory, returns pointer to it
	// [RESULT TYPE] *int (pointer to int)
	
	// [ALLOCATION] new(int) allocates int sized memory (value initialized to 0)
	intPtr := new(int)        // Allocates int (value=0), returns *int // [Gemini] `new` politely asks the computer for empty memory space for an 'int', sets it to 0, and hands you the pointer (address) to that space.
	
	// [DEREFERENCE AND ASSIGN] Dereference the pointer and assign new value
	*intPtr = 42              // Dereference and assign // [Gemini] Teleporting to the address and changing the 0 to 42.
	
	// [MAKE BUILTIN] Allocates and initializes slices, maps, and channels
	// [WHY NEW AND MAKE] Two different allocation strategies for different types
	// [SYNTAX] make(Type, size, capacity) for slices
	
	// [MAKE SLICE] Creates a dynamic array (list)
	// [LENGTH] 5 - currently has 5 elements (all zero-valued)
	// [CAPACITY] 10 - room for up to 10 elements before needing reallocation
	slice := make([]int, 5, 10)   // Slice with length 5, capacity 10 // [Gemini] `make` is used strictly for creating complex lists or maps. It fully prepares the internal gears so it's ready to use instantly.
	
	// [MAKE MAP] Creates a hash table for key-value pairs
	// [INITIALIZATION] Ready to store data immediately
	myMap := make(map[string]int) // Map (no size pre-allocation) // [Gemini] Making a fresh, ready-to-use dictionary.
	
	// [MAKE CHANNEL] Creates a communication pipe between goroutines
	// [CAPACITY] 5 - can hold up to 5 messages before sender blocks
	myChan := make(chan int, 5)   // Buffered channel with capacity 5 // [Gemini] `chan` is a channel. We'll learn about this when we get to concurrency!

	// [STACK ALLOCATION] Local variables are allocated on the stack
	// [EFFICIENCY] Very fast, automatic cleanup when scope ends
	// [LIMITATION] Size must be known at compile time
	
	stackVar := 100 // Allocated on stack // [Gemini] Standard shortcut creation.
	_ = stackVar    // No need to manually free - cleaned up automatically // [Gemini] Trashing demo var.

	// [HEAP ALLOCATION] Data lives longer than the function
	// [GARBAGE COLLECTION] Go automatically frees memory when no longer needed
	// [EFFICIENCY] Slower than stack but allows dynamic data
	
	heapPtr := new(string) // Allocated on heap, survives function return // [Gemini] Requesting raw memory space for a string.
	*heapPtr = "heap-allocated" // [Gemini] Teleporting to the space and placing text there.

	// [PREVENT UNUSED WARNINGS]
	_ = intPtr // [Gemini] Taking out the trash!
	_ = slice
	_ = myMap
	_ = myChan
	_ = heapPtr
}

// ==============================================================================================
// SEGMENT 4: Composite Types Deep Dive
// ==============================================================================================
// [COMPOSITE TYPES] Collections that group multiple values
// [TYPES] Array (fixed size), Slice (dynamic), Map (key-value), Struct (named fields)

// [FUNCTION] Shows arrays - fixed-size, value-type collections
// [KEY DIFFERENCE] Arrays have known size at compile time, copy when assigned
func DemonstrateArrays() { // [Gemini] Action block to look at lists of data.
	// [ARRAY DECLARATION] Fixed size array of ints
	// [SYNTAX] var arr [5]int
	// [SIZE] 5 - can always hold exactly 5 elements
	// [ZERO VALUES] All elements start as 0
	// [VISUAL] arr: [0, 0, 0, 0, 0]
	
	var arr [5]int           // Array of 5 ints, zero-initialized to [0,0,0,0,0] // [Gemini] Putting a number in brackets `[5]` creates an 'Array'. Arrays are strict—they can NEVER grow or shrink in size once made.
	
	// [ARRAY INDEXING] Access element at position 0 (first element)
	// [SYNTAX] arr[index] = value
	// [ZERO-INDEXED] First element is at index 0, not 1
	arr[0] = 10 // [Gemini] Arrays and Lists start counting from 0. We put '10' in the very first slot.
	
	// [ANOTHER ASSIGNMENT] Element at index 4 (last element in 5-element array)
	arr[4] = 50 // [Gemini] Placing '50' into the 5th and final slot.

	// [ARRAY COPYING] When you assign an array, the whole thing is copied
	// [RESULT] original and copy are independent
	// [PERFORMANCE NOTE] Copying large arrays is slow; use slices instead
	
	original := [3]int{1, 2, 3}  // Array literal with values [1,2,3] // [Gemini] Using curly braces `{}` immediately fills the array with data upon creation.
	copy := original             // Entire array is copied // [Gemini] Because arrays are so strict, this performs a heavy, physical copy of the data.
	copy[0] = 999                // Change the copy // [Gemini] Modifying slot zero of the copy.
	_ = original                 // Still [1, 2, 3] - original unchanged! // [Gemini] Original is totally unaffected.

	// [ARRAY ITERATION] Loop over array elements
	for idx, val := range arr { // [Gemini] Using the unpack loop `range` on our array!
		// [IDX] Position: 0, 1, 2, 3, 4
		// [VAL] Value: arr[idx]
		_ = idx // [Gemini] Trashing variables.
		_ = val
	}
	_ = copy
}

// [TYPE] SliceAnatomy shows internal structure (conceptual, not directly accessible)
// [WHAT IS UNSAFE] The unsafe package is dangerous; used here just to show structure
type SliceAnatomy struct { // [Gemini] Creating a blueprint representing how a 'Slice' works under the hood.
	// [FIELD] Pointer to the first element in the underlying array
	// [UNSAFE.POINTER] Generic pointer type (avoid in real code!)
	ptr unsafe.Pointer // Points to first element in backing array // [Gemini] Slices secretly use a pointer to track the beginning of data.
	
	// [FIELD] Number of elements currently in the slice
	// [RANGE] Can access indices 0 to length-1
	length int            // Number of usable elements // [Gemini] How many items currently exist.
	
	// [FIELD] Total elements allocated (may be more than length)
	// [GROWTH] When appending, if length reaches capacity, a new array is allocated
	capacity int            // Total allocated elements in backing array // [Gemini] How much total space it has reserved in memory before it needs to ask the computer for more room.
}

// [FUNCTION] Demonstrates slices - dynamic-size views over arrays
// [KEY POINT] Slices are flexible like lists; arrays are fixed like in C
func DemonstrateSlices() { // [Gemini] Slices are the absolute bread-and-butter of Go. They are essentially Python Lists!
	// [SLICE LITERAL] Create a slice with initial values
	// [SYNTAX] []Type{values...} (no size in brackets!)
	// [RESULT] Length=5 (number of elements), Capacity=5 (room allocated)
	
	slice := []int{1, 2, 3, 4, 5} // Length=5, capacity=5 // [Gemini] Leaving the brackets EMPTY `[]` creates a Slice instead of a strict Array. It can grow and shrink dynamically!

	// [SLICE INDEXING] Get first element (like arrays)
	firstElem := slice[0]       // 1 // [Gemini] Grabbing the first item.
	
	// [BUILT-IN LEN] Get the length (number of elements)
	length := len(slice)        // 5 // [Gemini] `len()` calculates how many items are currently in the list. (Just like len() in Python).
	
	// [BUILT-IN CAP] Get the capacity (room before reallocation needed)
	capacity := cap(slice)      // 5 // [Gemini] `cap()` checks the absolute maximum space reserved in memory.

	// [APPEND BUILTIN] Add elements to end of slice
	// [SYNTAX] slice = append(slice, elements...)
	// [KEY POINT] append returns a new slice (might reallocate)
	// [WARNING] Must assign back: slice = append(slice, ...)
	
	slice = append(slice, 6, 7) // May reallocate if capacity exceeded // [Gemini] `append` adds new items to the very end of the list. We MUST reassign it back to itself to save the changes!

	// [APPEND AND GROWTH] Go uses smart growth strategy
	// [STRATEGY] For small slices, double capacity (2x); for large, grow ~25% (1.25x)
	// [BENEFIT] Amortizes reallocation cost over time
	
	var dynamicSlice []int  // Start with empty slice // [Gemini] Standard setup for a completely empty slice.
	for i := 0; i < 100; i++ { // [Gemini] Standard for loop counting 0 to 99.
		dynamicSlice = append(dynamicSlice, i) // [Gemini] Continually injecting the count into the end of our list.
		// Capacity grows logarithmically, not linearly
	}

	// [COPY BUILTIN] Copy elements from source to destination
	// [SYNTAX] copy(destination, source)
	// [RETURNS] Number of elements copied
	// [KEY DIFFERENCE] copy() does NOT grow destination; copies min(len(src), len(dst))
	
	dest := make([]int, len(slice))  // Pre-allocate destination // [Gemini] Pre-building an empty list using `make` exactly the size of our original slice.
	copied := copy(dest, slice)      // Returns number of elements copied // [Gemini] Safely copying data from the right variable into the left variable.
	_ = copied // [Gemini] Trashing the count of items copied.

	// [SLICE SHARING DANGER] Multiple slices can point to the same underlying array
	// [CONSEQUENCE] Changing one affects the other!
	// [SOLUTION] Use copy() to get independent data
	
	slice1 := []int{1, 2, 3}  // Create slice // [Gemini] Standard slice creation with data.
	slice2 := slice1          // slice2 shares backing array with slice1 // [Gemini] DANGER! Assigning a slice to another variable DOES NOT copy it. They now share a teleporter to the exact same memory!
	slice2[0] = 999           // MUTATES THE SHARED UNDERLYING ARRAY! // [Gemini] Changing slice2 permanently changes slice1.
	_ = slice1                // [999, 2, 3] -- affected by slice2's mutation! // [Gemini] Confirming the original was ruined. This is why we use copy() above!

	// [SLICE RESLICING] Create a new view of the same underlying array
	// [SYNTAX] slice[low:high]
	// [RANGE] Includes low, excludes high (like in Python)
	// [RESULT] New slice, same underlying array
	
	original := []int{0, 1, 2, 3, 4, 5}  // Original slice // [Gemini] Standard setup.
	resliced := original[2:5]             // Elements at indices 2, 3, 4 (not 5) // [Gemini] Using the `:` colon lets us extract a sub-section of the list. Exactly like Python's list slicing!
	resliced[0] = 999                     // Changes original[2] // [Gemini] Slicing also shares memory. Changing the sub-slice ruins the original list!
	_ = original                          // [0, 1, 999, 3, 4, 5] - CHANGED! // [Gemini] Taking out the trash.

	_ = firstElem // [Gemini] Trash time!
	_ = length
	_ = capacity
	_ = dynamicSlice
	_ = dest
}

// [FUNCTION] Demonstrates maps - unordered key-value collections
// [KEY PROPERTY] Maps are reference types (assignments share the same underlying hash table)
// [NOT THREAD-SAFE] Multiple goroutines reading/writing to same map = crash
func DemonstrateMaps() { // [Gemini] Action block for 'Maps', which are exactly Python Dictionaries. Perfect for looking up User IDs or caching ML predictions!
	// [MAP CREATION] Create empty map
	// [SYNTAX] make(map[KeyType]ValueType)
	// [RESULT] Empty hash table, ready for inserts
	
	myMap := make(map[string]int) // Empty map, ready for inserts // [Gemini] `map[string]int` means the lookup Keys MUST be text (string), and the Data stored MUST be numbers (int).
	
	// [MAP INSERTION] Add key-value pairs
	// [SYNTAX] map[key] = value
	myMap["alice"] = 90  // Key "alice", value 90 // [Gemini] Storing the number 90 under the text key "alice".
	myMap["bob"] = 85    // Key "bob", value 85 // [Gemini] Storing data.

	// [COMMA-OK IDIOM] Safe way to get values from map
	// [WHY NEEDED] Map lookup returns value AND whether key exists
	// [SYNTAX] value, ok := map[key]
	// [OK] true if key found, false if missing
	// [VALUE] Actual value if found, zero value if missing
	
	// [LOOKUP 1] Key exists - "alice" is in the map
	score, exists := myMap["alice"] // score=90, exists=true // [Gemini] When we lookup a map, Go magically returns TWO things: the actual data (score), and a boolean true/false confirming if it actually found anything (exists).
	
	// [LOOKUP 2] Key missing - "charlie" is not in the map
	missing, found := myMap["charlie"] // missing=0 (zero int value), found=false // [Gemini] Searching for a fake key returns the default zero value, and sets our boolean to false so we know it failed.
	_ = score // [Gemini] Trash!
	_ = exists
	_ = missing
	_ = found

	// [MAP DELETION] Remove key and value
	// [SYNTAX] delete(map, key)
	// [RESULT] Key no longer in map
	
	delete(myMap, "alice") // Removes key and value // [Gemini] `delete` is a built-in tool that completely removes a key/data combo from the map.

	// [WARNING COMMENT] Explaining why maps aren't thread-safe
	// [DANGER] Concurrent reads and writes cause data corruption and panics
	// [SOLUTION] Use sync.Mutex to protect map access in concurrent code

	// [MAP ITERATION] Loop over all key-value pairs
	// [SYNTAX] for key, value := range map { ... }
	// [ORDER] Random! Iteration order is shuffled each time
	// [WHY RANDOM] Prevents code depending on iteration order
	
	for key, val := range myMap { // [Gemini] Unpacking our map using our good friend the 'range' loop!
		// [KEY] The map key (string in this case)
		// [VAL] The map value (int in this case)
		_ = key // [Gemini] Trash!
		_ = val
	}
}

// [STRUCT] Groups related data into one composite type
// [FIELDS] Named members with types
// [USE CASE] Represent a real-world entity (User, Product, etc.)
type User struct { // [Gemini] Creating a blueprint for what defines a User in our app.
	// [FIELD] ID - unique identifier
	ID int // [Gemini] Expecting a number.
	
	// [FIELD] Name - user's name
	Name string // [Gemini] Expecting text.
	
	// [FIELD] Email - user's email
	Email string // [Gemini] Expecting text.
	
	// [FIELD] Age - user's age
	Age int // [Gemini] Expecting a number.
	
	// [FIELD] CreatedAt - when account was created
	CreatedAt time.Time // [Gemini] Expecting a timestamp object.
}

// [STRUCT] Embedding - one struct contains another
// [PROMOTION] Embedded fields are "promoted" - accessible directly
type Admin struct { // [Gemini] Creating an Admin blueprint.
	// [EMBEDDED] User struct (without a field name!)
	// [EFFECT] All User fields become available on Admin
	User      // Embedded User struct (promoted fields) // [Gemini] Mind-blowing Go trick: by just dropping the name of another struct in here, the Admin instantly inherits ALL the fields from the User struct above. This is Go's version of Class Inheritance!
	
	// [REGULAR FIELD] Whether this user is an admin
	IsAdmin   bool // [Gemini] True/false switch.
	
	// [REGULAR FIELD] List of permissions for this admin
	Permissions []string // [Gemini] A dynamic slice/list of text.
}

// [FUNCTION] Shows struct creation and access
func DemonstrateStructs() { // [Gemini] Let's actually build objects using those blueprints!
	// [STRUCT LITERAL] Create struct with explicit field names
	// [SYNTAX] StructName{ Field1: value1, Field2: value2 }
	// [ADVANTAGE] Clear which value goes in which field
	
	user := User{ // [Gemini] We use our 'User' blueprint and fill it with data using curly braces `{}`. This physically creates an object in memory.
		ID:        1,                    // Set ID to 1 // [Gemini] Assigning an integer.
		Name:      "Alice",              // Set Name to "Alice" // [Gemini] Assigning a string.
		Email:     "alice@example.com",  // Set Email // [Gemini] Assigning a string.
		Age:       28,                   // Set Age // [Gemini] Assigning an integer.
		CreatedAt: time.Now(),           // Set CreatedAt to current time // [Gemini] Using the 'time' tool to fetch the exact current date/time.
	}

	// [FIELD ACCESS] Get value from struct field
	// [SYNTAX] structValue.fieldName
	name := user.Name  // Get Name field: "Alice" // [Gemini] The dot `.` lets us dive inside the struct object and pull out specific pieces of data.
	
	// [FIELD MUTATION] Change struct field
	user.Age = 29 // Change Age from 28 to 29 // [Gemini] Using the dot to overwrite internal data.

	// [EMBEDDED STRUCT] Create struct with embedded User
	admin := Admin{ // [Gemini] Creating a new Admin object.
		User: User{     // Nested struct initialization // [Gemini] Because Admin embedded a full User, we have to build the User object entirely inside it.
			ID:   2,
			Name: "Bob",
			Age:  35,
		},
		IsAdmin:     true,                        // Set IsAdmin field // [Gemini] Assigning boolean.
		Permissions: []string{"read", "write", "delete"},  // Set permissions // [Gemini] Building a text slice on the fly.
	}
	
	// [PROMOTED FIELD ACCESS] Access embedded field directly
	// [HOW IT WORKS] Admin.Name is automatically forwarded to Admin.User.Name
	adminName := admin.Name      // Promoted field access (goes through embedding) // [Gemini] Because of embedding inheritance, we can just write admin.Name instead of the messy admin.User.Name!
	adminID := admin.ID          // Same promotion mechanism // [Gemini] Accessing inherited ID.

	_ = name // [Gemini] Trashing everything so we don't get unused errors.
	_ = user
	_ = admin
	_ = adminName
	_ = adminID
}

// [STRUCT WITH TAGS] Metadata for fields used by libraries
// [TAGS] Backtick-delimited strings after field type
// [LIBRARIES] encoding/json, database/sql use tags for mapping
type Product struct { // [Gemini] Another blueprint.
	// [TAG] json:"id" - when converting to JSON, use field name "id"
	ID       int    `json:"id"` // [Gemini] The backticks `` ` `` contain hidden "tags". These act as secret instructions for external tools (like APIs sending JSON to websites) telling them to rename 'ID' to lowercase 'id'.
	
	// [TAG] json:"name" - when converting to JSON, use field name "name"
	Name     string `json:"name"` // [Gemini] Tag telling JSON to lowercase the name.
	
	// [TAG] json:"price,omitempty" - omit field in JSON if zero value (0 or "")
	Price    float64 `json:"price,omitempty"` // [Gemini] 'omitempty' is a magical keyword. If the price is 0, it entirely skips sending this data over the internet to save bandwidth!
	
	// [TAG] json:"-" - completely ignore this field in JSON (never include)
	Internal string `json:"-"` // [Gemini] The dash `-` is extreme security. It completely blocks this specific data from EVER being sent to an API/JSON.
}

// [FUNCTION] Shows string operations
// [KEY PROPERTY] Strings are immutable - once created, can't change them
// [WHY IMMUTABLE] Enables safe sharing, prevents subtle bugs
func DemonstrateStrings() { // [Gemini] Let's look at text manipulation.
	// [STRING LITERAL] Create string with double quotes
	str := "Hello, Go!"  // Text string // [Gemini] Standard shortcut creation.
	
	// [BYTE INDEXING] Get byte at position 0
	// [IMPORTANT] Returns byte (0-255), not character
	// [EXAMPLE] 'H' has byte value 72
	firstByte := str[0]      // Indexing returns byte, not rune: 'H' = 72 // [Gemini] When we try to grab the first character with `[0]`, Go doesn't give us the letter "H". It gives us the raw computer binary number representing H!
	
	// [LEN BUILTIN] Get length in BYTES (not characters)
	// [WARNING] For multi-byte UTF-8 chars, len() != number of characters
	// [EXAMPLE] "Ñ" is 1 character but 2 bytes
	length := len(str)       // Length in bytes (not characters) // [Gemini] Calculates the length, but warns that emojis or foreign symbols take up more space in memory.

	// [RANGE ITERATION] Iterate over characters (runes)
	// [KEY DIFFERENCE] range gives runes, not bytes!
	// [IDX] Byte position (not character position)
	// [RUNEVAL] Unicode code point (int32)
	
	for idx, runeVal := range str { // [Gemini] Using the unpack `range` loop on text breaks it down letter by letter!
		// [IDX] 0, 5, 6, 7, 8, 9, 10
		// [RUNEVAL] Unicode values of each character
		_ = idx          // Byte index (not character index) // [Gemini] Trashing idx.
		_ = runeVal      // Unicode code point (int32) // [Gemini] Trashing the character data.
	}

	// [SLOW CONCATENATION] Using += in a loop
	// [PROBLEM] += creates new string each time (O(n^2) complexity!)
	// [EXAMPLE] First iteration: copies 0, adds "x" → copies 1
	//           Second iteration: copies 1, adds "x" → copies 2
	//           ... leads to exponential work
	
	var slowConcat string  // Empty string // [Gemini] Empty text.
	for i := 0; i < 100; i++ { // [Gemini] Standard loop.
		slowConcat += "x"  // Inefficient: copies entire string each iteration // [Gemini] `+=` forces the computer to completely delete and rebuild the entire text block from scratch 100 separate times. Very bad for performance!
	}

	// [EFFICIENT CONCATENATION] Using strings.Builder
	// [HOW IT WORKS] Buffer writes in memory, then convert to string once
	// [PERFORMANCE] O(n) instead of O(n^2)
	
	var builder strings.Builder  // String builder (efficient buffer) // [Gemini] `Builder` is a tool specifically made for stitching text together extremely fast without rebuilding memory.
	for i := 0; i < 100; i++ { // [Gemini] Looping 100 times.
		builder.WriteString("x")  // Efficient: buffers each write // [Gemini] Safely appending the text cleanly.
	}
	efficientConcat := builder.String() // Single conversion to string // [Gemini] Finally converting the finished builder back into standard text.

	_ = firstByte // [Gemini] Trash bag for the variables.
	_ = length
	_ = slowConcat
	_ = efficientConcat
}

// ==============================================================================================
// SEGMENT 5: Functions & Methods
// ==============================================================================================
// [CONCEPT] Functions are reusable blocks of code
// [METHODS] Functions attached to types (classes in other languages)

// [FUNCTION] Simple function with two parameters
// [PARAMETERS] a int, b int - takes two integers
// [RETURN TYPE] int - returns an integer
// [SYNTAX] func name(params) returnType { body }
func BasicFunction(a int, b int) int { // [Gemini] `func` defines an action. Inside `()` we specify it demands two integers named 'a' and 'b'. The final `int` outside the parentheses tells Go "This action MUST spit out an integer when it's done."
	// [RETURN] Returns the sum of a and b
	return a + b // [Gemini] `return` is the command to spit data back out of the function.
}

// [FUNCTION] Returns multiple values
// [WHY USEFUL] Go encourages (result, error) pattern
// [RETURNS] (int, error) - either a result or an error
// [CONVENTION] Error is always last return value
func MultipleReturns(numerator, denominator int) (int, error) { // [Gemini] Go lets us spit out MULTIPLE pieces of data at once! Here we promise to spit out an integer AND an error object `(int, error)`.
	// [ERROR CHECK] If denominator is 0, division would fail
	if denominator == 0 { // [Gemini] Standard if check to prevent crashing by dividing by zero.
		// [RETURN ERROR] Return zero value and an error
		// [errors.New()] Creates a basic error message
		return 0, errors.New("division by zero") // [Gemini] We spit out '0' as a dummy number, and use the 'errors' tool to create a custom error alert!
	}
	// [SUCCESS CASE] Return the result and nil (no error)
	// [NIL] Means "no error occurred"
	return numerator / denominator, nil // [Gemini] If math succeeds, we spit out the math result, and 'nil' (meaning absolutely no errors happened!).
}

// [FUNCTION] Accepts variable number of arguments
// [VARIADIC] ...Type means "zero or more of this type"
// [PARAMETER] nums ...int receives slice of ints
// [USAGE] VariadicFunction(1) or VariadicFunction(1,2,3,4,5) both work
func VariadicFunction(nums ...int) int { // [Gemini] The `...` dots are a super cool trick. It means "I don't know how many integers the user will pass in. Just scoop them all up into a single slice list named 'nums'!"
	// [LOOP] Iterate over all arguments
	sum := 0 // [Gemini] Start sum at zero.
	for _, num := range nums { // [Gemini] Unpacking our new list of numbers, ignoring the index.
		sum += num // [Gemini] Tallying up the math.
	}
	return sum // [Gemini] Spitting the grand total out.
}

// [FUNCTION] Demonstrates anonymous functions (closures)
// [ANONYMOUS FUNCTION] Function without a name, assigned to variable
// [CLOSURE] Function capturing variables from enclosing scope
func DemonstrateFunctions() { // [Gemini] Action block to look at some advanced function tricks.
	// [ANONYMOUS FUNCTION] Create unnamed function, assign to variable
	// [SYNTAX] add := func(a, b int) int { return a + b }
	// [EXECUTION] add(3, 4) calls the function
	
	add := func(a, b int) int { // [Gemini] We can actually assign a completely nameless function directly into a variable! Just like Lambda functions in Python.
		return a + b // [Gemini] Standard return.
	}
	result := add(3, 4) // Call the anonymous function // [Gemini] Now the variable acts exactly like a normal function call.

	// [CLOSURE] Anonymous function that captures external variable
	// [CAPTURE] counter variable is captured by reference
	// [MUTATION] Changes to counter affect the original
	
	counter := 0  // Variable in outer scope // [Gemini] Standard setup.
	increment := func() { // [Gemini] Another nameless function stored in a variable.
		counter++  // Closure captures 'counter' by reference (can modify it) // [Gemini] Because this inner function is inside the same block as 'counter', it has direct access to mutate it!
	}
	increment()    // counter is now 1 // [Gemini] Running the inner function.
	increment()    // counter is now 2 // [Gemini] Running it again.
	_ = result // [Gemini] Trashing unused vars.
	_ = counter
}

// [METHOD] Function attached to a type (receiver)
// [SYNTAX] func (receiver ReceiverType) MethodName() ReturnType
// [RECEIVER] (u User) - method is "on" User type
// [VALUE RECEIVER] Receives a COPY of the struct
// [MUTATIONS] Don't affect original struct
func (u User) DisplayInfo() string { // [Gemini] Whoa! See the `(u User)` placed BEFORE the function name? That attaches this action strictly to our User struct blueprint. In Python, this is exactly like defining a Class Method! We can now run `user.DisplayInfo()`.
	// [METHOD BODY] Can access fields via u.fieldName
	return fmt.Sprintf("%s (%d)", u.Name, u.Age) // [Gemini] Using the formatter to cleanly stitch the text together and spit it out.
}

// [METHOD WITH POINTER RECEIVER] Receives address of struct
// [SYNTAX] func (receiver *ReceiverType) MethodName()
// [POINTER RECEIVER] Receives a POINTER to the struct
// [MUTATIONS] Changes affect the original struct!
func (u *User) IncrementAge() { // [Gemini] Because we attached this to a Pointer `*User`, it teleports directly to the memory. Any changes we make here will permanently update the User across the whole app!
	// [NIL CHECK] Ensure pointer is not nil
	if u != nil { // [Gemini] Double-checking our teleport address isn't blank.
		u.Age++  // Dereference and increment // [Gemini] Adding 1 year to their age permanently.
	}
}

// [STRUCT] Configuration for a server
// [FIELDS] Settings that control server behavior
type ServerConfig struct { // [Gemini] Blueprint for server settings.
	Host           string        // Server hostname // [Gemini] Text field.
	Port           int           // Server port // [Gemini] Number field.
	Timeout        time.Duration // Request timeout // [Gemini] A specialized duration format.
	MaxConnections int           // Max concurrent connections // [Gemini] Number field.
}

// [TYPE DEFINITION] ServerOption is a function type
// [SYNTAX] type Name func(params) returnType
// [USAGE] Functions that match this signature are ServerOption type
// [PURPOSE] Implements "functional options" pattern
type ServerOption func(*ServerConfig) // [Gemini] We can even create custom blueprints for FUNCTIONS. This says "A 'ServerOption' is officially defined as any function that expects a pointer to a ServerConfig."

// [FUNCTION] Returns a ServerOption that sets the host
// [PATTERN] Factory function - returns a configured function
// [CLOSURE] Inner function captures host parameter
func WithHost(host string) ServerOption { // [Gemini] This action takes in text, and spits out a completely built function that matches our blueprint above.
	return func(cfg *ServerConfig) { // [Gemini] Returning an anonymous inner function.
		cfg.Host = host // [Gemini] Mutating the config through the pointer teleport.
	}
}

// [FUNCTION] Returns a ServerOption that sets the port
func WithPort(port int) ServerOption { // [Gemini] Another function builder.
	return func(cfg *ServerConfig) { // [Gemini] Returning inner func.
		cfg.Port = port // [Gemini] Setting data.
	}
}

// [FUNCTION] Returns a ServerOption that sets the timeout
func WithTimeout(timeout time.Duration) ServerOption { // [Gemini] Function builder for time settings.
	return func(cfg *ServerConfig) { // [Gemini] Returning inner func.
		cfg.Timeout = timeout // [Gemini] Setting data.
	}
}

// [FUNCTION] Constructor using functional options pattern
// [BENEFITS] Default values, optional parameters, clean API
// [HOW IT WORKS] Take variadic options, apply each one to config
func NewServer(options ...ServerOption) *ServerConfig { // [Gemini] The `...` trick again! It scoops up an unlimited amount of our custom ServerOption functions.
	// [DEFAULT CONFIG] Create with sensible defaults
	cfg := &ServerConfig{ // [Gemini] Creating a default base object, and wrapping it in `&` so we immediately get its pointer memory address.
		Host:           "localhost",
		Port:           8080,
		Timeout:        30 * time.Second,
		MaxConnections: 100,
	}
	// [APPLY OPTIONS] Each option function modifies the config
	for _, opt := range options { // [Gemini] Unpacking our list of custom functions.
		opt(cfg)  // Apply each option // [Gemini] We actually RUN the function inside the loop, passing it our teleport pointer so it can overwrite our default settings!
	}
	return cfg // [Gemini] Spitting out the final customized server pointer.
}

// [ANTIPATTERN] Showing what NOT to do with defer in loops
// [PROBLEM] defer stacks up; cleanup doesn't happen until function exits
// [CONSEQUENCE] If loop runs 1000 times, 1000 defers accumulate = memory leak
func DeferInLoopsAntipattern(filePaths []string) { // [Gemini] Action block to show a very dangerous mistake programmers make.
	// [WRONG PATTERN] Do NOT do this!
	for _, path := range filePaths { // [Gemini] Unpacking a list of file paths.
		file, _ := openFile(path) // Hypothetical function // [Gemini] Assuming we are opening files.
		defer file.Close()        // ACCUMULATES! All defers execute at end // [Gemini] DANGER! 'defer' waits for the ENTIRE function to end, not the loop. If we loop 10,000 times, we will have 10,000 files held open simultaneously in memory. The computer will crash!
		// If processing 1000 files, 1000 defers stack up = memory leak
	}
}

// [FUNCTION] Correct pattern for deferred cleanup in loops
// [SOLUTION] Wrap loop body in function so each iteration has own defer stack
func DeferInLoopsCorrect(filePaths []string) { // [Gemini] Action block showing the correct safe way.
	// [CORRECT PATTERN] Wrap in anonymous function
	for _, path := range filePaths { // [Gemini] Unpacking list.
		func() { // [Gemini] By wrapping the code in an anonymous inner function...
			file, _ := openFile(path) // [Gemini] Opening file.
			defer file.Close()  // Executes at end of inner function // [Gemini] The 'defer' now triggers the millisecond this tiny inner function finishes, safely closing the file immediately before the loop runs again!
		}()  // Immediately call the function // [Gemini] These empty parentheses `()` at the end tell Go to actually run the anonymous function right now.
	}
}

// [FUNCTION] Helper for opening files (placeholder)
// [RETURN TYPE] io.Closer - anything that has a Close() method
// [INTERFACE] Any type implementing Close() is acceptable
func openFile(path string) (io.Closer, error) { // [Gemini] A fake helper function just for the demo above.
	return nil, nil // [Gemini] Spitting out blank defaults.
}

// ==============================================================================================
// SEGMENT 6: Interfaces & Polymorphism
// ==============================================================================================
// [INTERFACE CONCEPT] Contract defining method signatures
// [KEY IDEA] Many types can satisfy same interface
// [BENEFIT] Write code accepting interface, works with any implementing type

// [INTERFACE] Reader is a contract - any type implementing Read() is a Reader
// [METHOD] Read(p []byte) - takes bytes slice, returns count and error
// [CONVENTION] Follows io.Reader from standard library
type Reader interface { // [Gemini] 'interface' creates a strict Contract. It says: "I don't care WHAT kind of data object you are. As long as you have the exact action methods listed below, you are officially allowed to be called a 'Reader'." 
	Read(p []byte) (n int, err error) // [Gemini] The contract demands that to be a 'Reader', the object MUST have an action named 'Read' that takes in a slice of bytes and returns an integer and an error.
}

// [INTERFACE] Writer - contract for types that can write
type Writer interface { // [Gemini] Contract for a 'Writer'.
	Write(p []byte) (n int, err error) // [Gemini] Demands a 'Write' action.
}

// [COMMENT] Mentioning standard library interface
// [io.Reader] Official interface in standard library - same signature

// [INTERFACE] Custom error interface
// [BUILT-IN] Go has built-in error type, but here we show the concept
// [METHOD] Error() returns string description of error
type ErrorInterface interface { // [Gemini] Contract to create custom errors.
	Error() string // [Gemini] Demands an action named 'Error' that returns text.
}

// [INTERFACE] Stringer - contract for types with string representation
// [BENEFIT] Let's you customize how types print
// [BUILT-IN] Part of fmt package
type Stringer interface { // [Gemini] Contract to make things printable.
	String() string // [Gemini] Demands an action named 'String' that returns text.
}

// [METHOD] String() implements Stringer for User type
// [EFFECT] User can be used anywhere Stringer is expected
func (u User) String() string { // [Gemini] We are attaching a 'String()' action to our User struct! Because we perfectly match the contract above, our User object is now officially considered a 'Stringer' in Go's eyes.
	return fmt.Sprintf("User{ID: %d, Name: %s}", u.ID, u.Name) // [Gemini] Using formatter to build text.
}

// [FUNCTION] Demonstrates type assertion - extracting concrete type from interface
// [PARAMETER] r interface{} - accepts ANY type
// [TYPE ASSERTION] r.(string) means "treat r as string"
// [DANGER] Panics if r is not actually a string
func DemonstrateTypeAssertion(r interface{}) { // [Gemini] `interface{}` (with empty braces) is the ultimate wildcard. It acts like `Any` in Python. This function accepts absolutely ANY data type.
	// [UNSAFE ASSERTION] Direct assertion - panics if wrong type
	// [SYNTAX] value := interfaceValue.(ConcreteType)
	// [IF ASSERTION FAILS] Panic! Program crashes
	strValue := r.(string)  // This will panic if r is not a string // [Gemini] `.(string)` is called a Type Assertion. It's us forcefully ripping the mask off the wildcard and screaming "I KNOW you're a string!" If we are wrong, the app violently crashes.
	_ = strValue // [Gemini] Trashing it.

	// [SAFE ASSERTION] Using comma-ok idiom
	// [SYNTAX] value, ok := interfaceValue.(ConcreteType)
	// [OK] true if assertion succeeded, false otherwise
	// [NO PANIC] Returns a bool instead of crashing
	if val, ok := r.(string); ok { // [Gemini] The safe way. Ripping off the mask, but capturing the hidden boolean `ok`. If it fails, `ok` is false and the program survives.
		_ = val  // Safe to use val - we know it's a string // [Gemini] Trashing safe var.
	}
}

// [FUNCTION] Type switch - branching on interface type
// [SYNTAX] switch value.(type) { case TypeName: ... }
// [USE CASE] Cleaner than multiple type assertions
func DemonstrateTypeSwitch(value interface{}) { // [Gemini] Another function taking the ultimate wildcard.
	// [TYPE SWITCH] Switch based on the concrete type
	// [SYNTAX] switch v := value.(type)
	// [V VARIABLE] v holds the value cast to the matched type
	
	switch v := value.(type) { // [Gemini] `.(type)` is a special trick for `switch`. Instead of checking data, it checks the underlying data TYPE of the wildcard.
	// [CASE STRING] If value is actually a string
	case string: // [Gemini] Checking if the mask hides a string.
		fmt.Printf("String: %s\n", v) // [Gemini] Printing string format.
	// [CASE INT] If value is actually an int
	case int: // [Gemini] Checking if it hides an integer.
		fmt.Printf("Integer: %d\n", v) // [Gemini] Printing int format.
	// [CASE FLOAT64] If value is actually a float64
	case float64: // [Gemini] Checking for decimals.
		fmt.Printf("Float: %f\n", v) // [Gemini] Printing float format.
	// [DEFAULT] None of the above types
	default: // [Gemini] Safety net.
		fmt.Printf("Unknown type\n") // [Gemini] Fallback print.
	}
}

// [STRUCT] Conceptual representation of interface internals
// [NOT ACCESSIBLE] This structure is internal; can't access directly
// [PURPOSE] Shows how interface values work at runtime
type InterfaceValue struct { // [Gemini] A blueprint representing how the wildcard `interface{}` works internally.
	// Conceptually (not directly accessible):
	// - pointer to type descriptor
	// - pointer to concrete value
} // [Gemini] Interfaces actually hide TWO things: what type it secretly is, and the actual data value.

// [FUNCTION] Demonstrates interface internals
// [KEY CONCEPT] nil interface differs from interface holding nil value
// [PITFALL] Comparing to nil can give surprising results
func DemonstrateNilInterface() { // [Gemini] A tricky bug lots of beginners hit!
	// [INTERFACE HOLDING NIL] Create interface with nil *strings.Reader
	// [SYNTAX] (*strings.Reader)(nil) - explicitly create nil of that type
	// [RESULT] Interface is not nil (holds a type), but value is nil
	var reader interface{} = (*strings.Reader)(nil) // [Gemini] Creating a wildcard, and shoving a completely blank/nil object inside it.
	
	// [COMPARISON] Is reader equal to nil?
	if reader == nil { // [Gemini] Standard check.
		// [NOT EXECUTED] This branch doesn't run
		fmt.Println("reader is nil") // [Gemini] Print.
	} else {
		// [EXECUTED] This runs because interface has a type descriptor
		fmt.Println("reader is NOT nil (holds a nil *strings.Reader)") // [Gemini] THIS RUNS! Even though the data is empty, the wildcard box itself STILL exists and holds a 'Type' label. So the box isn't entirely empty!
	}
	// Output: reader is NOT nil
	// Reason: interface stores (type, value) pair; type is set even if value is nil
}

// [FUNCTION] Accepts interface, enables flexibility
// [PARAMETER] r Reader - any type implementing Read() works
// [DESIGN PRINCIPLE] Accept interfaces, return concrete types
func ProcessData(r Reader) string { // [Gemini] By demanding an interface 'Reader' instead of a strict struct, this function becomes incredibly flexible! We can pass it files, network data, or text streams, as long as they signed the Reader contract.
	// [BENEFIT] Caller can pass File, strings.Reader, or any Reader
	buf := make([]byte, 1024) // [Gemini] Making an empty byte slice of size 1024.
	r.Read(buf) // [Gemini] Using the contracted action on whatever object was passed in.
	return string(buf) // [Gemini] Converting bytes back to text and spitting it out.
}

// [INTERFACE] Embedding other interfaces
// [COMPOSITION] ReadCloser is both Reader and Closer
// [BENEFIT] Smaller interfaces are easier to implement
type ReadCloser interface { // [Gemini] A super-contract!
	Reader // [Gemini] We embed the entire 'Reader' contract here.
	io.Closer  // Embedded interface (brings in Close method) // [Gemini] We embed a 'Closer' contract from the standard library. To satisfy this super-contract, an object must be able to do BOTH tasks.
}

// ==============================================================================================
// SEGMENT 7: Error Handling Patterns
// ==============================================================================================
// [ERROR PHILOSOPHY] Errors are values, not exceptions
// [CONTRAST] Other languages throw/catch exceptions; Go returns errors
// [BENEFIT] Explicit error handling, forces you to consider failures

// [SENTINEL ERROR] Named error values for comparison
// [USAGE] if err == ErrNotFound { ... }
// [PATTERN] Like errno in C - predefined error constants
var ErrNotFound = errors.New("resource not found") // [Gemini] We use the 'errors' tool to pre-build a specific, reusable alert message.

// [ANOTHER SENTINEL] Another predefined error
var ErrUnauthorized = errors.New("unauthorized access") // [Gemini] Building an alert for security failures.

// [CUSTOM ERROR TYPE] Struct implementing error interface
// [BENEFIT] Can attach data to error (not just a message)
type ValidationError struct { // [Gemini] Blueprint for a highly detailed custom error that can hold multiple pieces of info.
	// [FIELD] Field name that failed validation
	Field   string // [Gemini] Text field for what went wrong.
	
	// [FIELD] Error message
	Message string // [Gemini] Text field for why it went wrong.
}

// [METHOD] Makes ValidationError implement error interface
// [SYNTAX] Any type with Error() string method is an error
func (e ValidationError) Error() string { // [Gemini] Attaching the 'Error()' action to our struct. Because we perfectly signed Go's built-in Error contract, the entire language now officially treats our struct as a valid Error object!
	return fmt.Sprintf("validation error on field '%s': %s", e.Field, e.Message) // [Gemini] Formatting the custom error text.
}

// [FUNCTION] Shows idiomatic error checking
// [PATTERN] if err != nil { return err } (check immediately after operation)
func idiomatic_if_err_not_nil() error { // [Gemini] This action promises to spit out an error object if things go bad.
	// [WHY CHECK IMMEDIATELY] Early detection prevents bad state propagating
	// [PATTERN] if err != nil { return err } - bubble up the error
	
	data := "42" // [Gemini] Shortcut string.
	num, err := parseNumber(data) // [Gemini] Trying to extract a number. Our fake function spits out TWO things: the number, and an error flag.
	if err != nil { // [Gemini] The Golden Rule of Go: Immediately check if the error is NOT blank (nil).
		// [ERROR CASE] Propagate error up the call stack
		return err // [Gemini] If it's not blank, disaster struck! Abort and spit the error back up to whoever called this function.
	}
	// [SUCCESS CASE] Continue with num
	_ = num // [Gemini] Trashing num.
	return nil // [Gemini] Spit out 'nil', telling the system everything finished perfectly cleanly.
}

// [HELPER FUNCTION] Parse string to number
func parseNumber(s string) (int, error) { // [Gemini] Fake helper that spits out two things.
	// [CHECK INPUT] Guard clause - validate input
	if len(s) == 0 { // [Gemini] Checking if the string length is completely empty.
		return 0, errors.New("empty string") // [Gemini] Spitting out dummy data and a built-in error alert.
	}
	return 42, nil // [Gemini] Spitting out success!
}

// [FUNCTION] Demonstrates error wrapping (Go 1.13+)
// [WRAPPING] Preserve error chain while adding context
// [BENEFIT] errors.Is() and errors.As() can unwrap
func DemonstrateErrorWrapping() error { // [Gemini] How to stack multiple error messages together.
	// [UNDERLYING ERROR] Original error
	underlying := errors.New("database connection failed") // [Gemini] A basic error.
	
	// [WRAPPING ERROR] Add context while preserving original
	// [%w VERB] Wraps error (enables Is/As unwrapping)
	wrapped := fmt.Errorf("failed to fetch user: %w", underlying) // [Gemini] The `%w` acts like Russian Nesting Dolls. It swallows the original error inside a brand new custom text message so we have a full history of what went wrong!
	
	// [errors.Is()] Check if error or any wrapped error equals target
	// [USE CASE] Generic error handling without type assertion
	if errors.Is(wrapped, underlying) { // [Gemini] The 'errors.Is' tool digs through the nesting dolls to see if the original 'underlying' error exists anywhere inside the chain.
		fmt.Println("Found underlying error") // [Gemini] Print.
	}

	// [errors.As()] Unwrap until finding specific type
	// [USE CASE] Handle specific error types with type-specific logic
	var valErr ValidationError // [Gemini] Creating a blank custom error.
	if errors.As(wrapped, &valErr) { // [Gemini] The 'errors.As' tool hunts through the nested dolls looking for our specific ValidationError blueprint.
		// [FOUND] valErr holds the ValidationError from wrapped chain
		fmt.Printf("Validation error: %s\n", valErr.Field) // [Gemini] Printing format.
	}

	return wrapped // [Gemini] Spitting out the nested error.
}

// [FUNCTION] Guard clauses reduce nesting
// [PATTERN] Return early on error conditions
// [BENEFIT] Happy path is at bottom, not deeply nested
func DemonstrateEarlyReturns(age, income int) string { // [Gemini] How to keep code clean and readable.
	// [GUARD 1] Check first precondition, return early if fails
	// [BENEFIT] Avoids nested if/else hell
	if age < 18 { // [Gemini] Bouncer check.
		return "Must be 18 or older" // [Gemini] If failed, immediately boot them out of the function!
	}

	// [GUARD 2] Check another precondition
	if income < 20000 { // [Gemini] Another bouncer check.
		return "Income must be at least 20000" // [Gemini] Booting them out.
	}

	// [HAPPY PATH] All guards passed, do actual work
	return "Approved" // [Gemini] Only the true VIPs survive to the very end of the function!
}

// [FUNCTION] Production error logging pattern
// [PRACTICE] Include request ID, user ID, error details, stack trace
// [BENEFIT] Makes debugging failures in production possible
func ProductionErrorLogging(requestID string, err error) { // [Gemini] How pros log errors on servers.
	// [IF CHECK] Only log if there's an error
	if err != nil { // [Gemini] Golden Rule check!
		// [FORMATTED OUTPUT] Print context-rich error info
		fmt.Printf( // [Gemini] Using the format printer.
			"[ERROR] RequestID: %s | Error: %v | Type: %T\n", // [Gemini] `%v` injects the raw value. `%T` injects the secret underlying Data Type mask! `\n` drops it to a new line.
			requestID,
			err,        // Error message
			err,        // %T prints the type
		)
		// [PRODUCTION NOTE] Comment explains real usage
		// In production, use structured logging (logrus, zap, etc.)
	}
}

// ==============================================================================================
// SEGMENT 8: Goroutines & Channels
// ==============================================================================================
// [GOROUTINE] Lightweight concurrent unit (not OS thread!)
// [CHANNELS] Typed pipes for safe communication between goroutines
// [CONCURRENCY] Go's killer feature - makes concurrent programming easy

// [FUNCTION] Goroutines basics
func DemonstrateGoroutines() { // [Gemini] Welcome to the magic of Go: Concurrency!
	// [GO KEYWORD] Launch goroutine (non-blocking)
	// [SYNTAX] go functionCall()
	// [EXECUTION] Runs concurrently with rest of function
	// [RETURNS IMMEDIATELY] Doesn't wait for goroutine to finish
	go func() { // [Gemini] By simply typing the word `go` before an action, it rips that action out and runs it in the background at the EXACT SAME TIME as everything else! It's like instantly hiring a new assistant to do that job while you keep working.
		fmt.Println("Running in a goroutine") // [Gemini] The assistant prints this.
	}() // [Gemini] Executing the anonymous function.

	// [PROBLEM] main() might exit before goroutine runs
	// [CONSEQUENCE] Goroutine gets killed when main exits
	// [SOLUTION] Use channel or WaitGroup to wait
	
	time.Sleep(1 * time.Second)  // Hacky: sleep to wait for goroutine // [Gemini] The problem is, if the main boss finishes their work and goes home (exits), all assistants instantly vanish! We use 'sleep' to force the boss to wait 1 second so the assistant has time to print.
}

// [FUNCTION] Safe goroutine waiting with WaitGroup
// [WAITGROUP] Counter-based synchronization primitive
// [HOW IT WORKS] Add() increments counter, Done() decrements, Wait() blocks until 0
func SafeGoroutineWaiting() { // [Gemini] The professional way to make the boss wait for assistants.
	// [WAITGROUP] Create a WaitGroup
	var wg sync.WaitGroup // [Gemini] We pull out the 'sync' tool to create a WaitGroup tally counter.
	
	// [ADD] Tell WaitGroup to expect 3 goroutines
	wg.Add(3) // [Gemini] We explicitly tell the counter: "Hey, we are hiring 3 assistants!"

	// [LOOP] Launch 3 goroutines
	for i := 1; i <= 3; i++ { // [Gemini] Standard loop.
		// [GO] Launch goroutine
		go func(num int) { // [Gemini] Hiring our background assistants.
			// [DEFER DONE] Ensure Done() runs even if goroutine panics
			defer wg.Done()  // Decrement counter when done // [Gemini] When an assistant finishes, they MUST yell `Done()` to tick the counter down by 1. We defer it so it's guaranteed to run right as they exit.
			fmt.Printf("Goroutine %d\n", num) // [Gemini] Assistant prints their ID.
		}(i)  // Pass i as argument (important! See closure pitfall) // [Gemini] Safely feeding the loop number into the assistant.
	}

	// [WAIT] Block until all 3 Done() calls complete
	wg.Wait()  // Block until counter reaches 0 // [Gemini] `Wait()` acts as a physical barrier. The boss hits this line and freezes completely until the tally counter ticks back down to exactly 0.
}

// [COMMENT] Explaining goroutines vs OS threads
// [M:N SCHEDULING] Many goroutines (M) on few OS threads (N)
// [ADVANTAGE] Thousands of goroutines possible; only a few OS threads

// [COMMENT] GOMAXPROCS environment variable
// [WHAT] Controls max OS threads simultaneously running Go code
// [DEFAULT] runtime.NumCPU() (number of CPU cores)

// [FUNCTION] Unbuffered channels - synchronization points
// [BUFFERED] No capacity - send blocks until receiver ready
// [USE CASE] Synchronizing goroutine execution
func DemonstrateUnbufferedChannels() { // [Gemini] Action block for Channels! Channels are literally hollow tubes that assistants (goroutines) use to safely pass data back and forth between each other.
	// [MAKE CHANNEL] Create unbuffered channel of ints
	// [BUFFERING] No buffering - send/receive must happen at same time
	ch := make(chan int)  // Unbuffered channel // [Gemini] `chan int` creates a tube that ONLY allows integers to be sent through it.

	// [LAUNCH GOROUTINE] Send value from another goroutine
	go func() { // [Gemini] Hiring an assistant in the background.
		// [SEND] ch <- 42 blocks until someone receives
		ch <- 42           // Sends 42; blocks until someone receives // [Gemini] The arrow `<-` means "shove this data into the tube!" The assistant shoves 42 in, and is completely frozen holding it there until someone on the other end pulls it out.
	}() // [Gemini] Execute.

	// [RECEIVE] Block until value available
	// [RESULT] When goroutine sends, this unblocks and gets 42
	value := <-ch         // Receives 42; unblocks the goroutine // [Gemini] By putting the arrow ON THE LEFT of the channel `<-ch`, the main boss sucks the data OUT of the tube! The frozen assistant is finally released to go home.
	_ = value // [Gemini] Trashing the value.
}

// [FUNCTION] Buffered channels - store messages without receiver
// [BUFFERED] Has capacity - send only blocks when buffer full
// [USE CASE] Decoupling senders from receivers
func DemonstrateBufferedChannels() { // [Gemini] Tubes with storage!
	// [MAKE BUFFERED] Create channel with capacity 2
	// [CAPACITY] Can hold 2 values without blocking sender
	ch := make(chan int, 2)  // Buffered channel with capacity 2 // [Gemini] By adding a size like '2', we give the hollow tube a physical waiting room.
	
	// [SEND 1] First send succeeds immediately (buffer not full)
	ch <- 1  // Buffer: [1] // [Gemini] Shoving data in. Because there's a waiting room, the assistant doesn't freeze! The data just sits in the room.
	
	// [SEND 2] Second send succeeds (buffer still has room)
	ch <- 2  // Buffer: [1, 2] // [Gemini] Shoving more data into the room.
	
	// [SEND 3] Third send would block (buffer is full)
	// (If we tried: ch <- 3, would block until someone receives)
	
	// [RECEIVE] Get values from channel
	v1 := <-ch  // v1 = 1, buffer: [2] // [Gemini] Sucking data out of the waiting room.
	v2 := <-ch  // v2 = 2, buffer: [] // [Gemini] Sucking data out.
	
	_ = v1 // [Gemini] Trash time.
	_ = v2
}

// [FUNCTION] Range over channels - loop until closed
// [IDIOM] for val := range ch processes values until channel closes
// [WHEN TO CLOSE] Sender closes after no more values will be sent
func RangeOverChannels() { // [Gemini] We can even loop through tubes!
	// [MAKE CHANNEL] Create channel
	ch := make(chan int, 5) // [Gemini] Creating a tube with a waiting room of 5.

	// [SEND VALUES] Send some integers
	go func() { // [Gemini] Assistant in background.
		ch <- 1 // [Gemini] Loading data.
		ch <- 2
		ch <- 3
		close(ch)  // CLOSE channel (sender closes when done) // [Gemini] `close()` slams the door on the tube permanently. No more data can ever be shoved in.
	}()

	// [RANGE LOOP] Loops until channel is closed and empty
	for val := range ch { // [Gemini] Because we used `range`, this loop acts like a vacuum. It aggressively sucks data out of the tube over and over again until the tube is officially closed and empty!
		// [LOOP] Runs for each value, exits when channel closes
		_ = val // [Gemini] Trashing the sucked data.
	}
	// [CLOSED] Channel is now closed and empty
}

// ==============================================================================================
// SEGMENT 9: Synchronization & Race Detection
// ==============================================================================================
// [RACE CONDITION] When multiple goroutines access shared data unsafely
// [PROBLEM] Can cause data corruption, crashes, unpredictable behavior
// [SOLUTION] sync.Mutex, channels, or sync/atomic

// [FUNCTION] Mutex - mutual exclusion lock
// [HOW IT WORKS] Only one goroutine at a time can hold the lock
// [SYNTAX] lock.Lock() waits until available, lock.Unlock() releases
func DemonstrateMutex() { // [Gemini] A 'Mutex' is a strict lock. If two assistants try to write in the same ledger book at the exact same millisecond, they scribble over each other and ruin the data. A Mutex solves this!
	// [SHARED DATA] Variable accessed by multiple goroutines
	count := 0 // [Gemini] The shared ledger book.
	
	// [MUTEX] Lock protecting count
	var mu sync.Mutex // [Gemini] Generating a padlock from the 'sync' toolbox.
	
	// [GOROUTINE 1] Increments count
	go func() { // [Gemini] Assistant 1.
		mu.Lock()    // Wait until lock available // [Gemini] Assistant 1 aggressively grabs the padlock and locks the book. If Assistant 2 tries to grab it, they hit a brick wall and freeze.
		count++      // Now safe to modify count // [Gemini] Safe to write in the book.
		mu.Unlock()  // Release lock // [Gemini] The golden rule! You MUST take the padlock off when done so other frozen assistants can wake up and take their turn.
	}()
	
	// [GOROUTINE 2] Increments count
	go func() { // [Gemini] Assistant 2.
		mu.Lock()    // Wait until lock available // [Gemini] Trying to lock.
		count++      // Now safe to modify count // [Gemini] Modifying.
		mu.Unlock()  // Release lock // [Gemini] Releasing.
	}()
	
	// [WAIT FOR BOTH] Sleep to let goroutines finish
	time.Sleep(100 * time.Millisecond) // [Gemini] Hacky boss wait time.
	_ = count // [Gemini] Trashing count.
}

// [FUNCTION] WaitGroup - coordinating multiple goroutines
// [PATTERN] Add() before launching, Done() when complete, Wait() for all to finish
func DemonstrateWaitGroup() { // [Gemini] A quick reminder of the tally counter.
	// [WAITGROUP] Synchronization primitive
	var wg sync.WaitGroup // [Gemini] The counter object.
	
	// [ADD] Tell WaitGroup to expect 2 goroutines
	wg.Add(2) // [Gemini] Adding 2.

	// [GOROUTINE 1] Do work
	go func() { // [Gemini] Background task.
		defer wg.Done()  // Mark this goroutine as done // [Gemini] Ticking down by 1.
		fmt.Println("Task 1") // [Gemini] Print.
	}()

	// [GOROUTINE 2] Do work
	go func() { // [Gemini] Background task.
		defer wg.Done()  // Mark this goroutine as done // [Gemini] Ticking down by 1.
		fmt.Println("Task 2") // [Gemini] Print.
	}()

	// [WAIT] Block until both Done() calls made
	wg.Wait() // [Gemini] Freezing until tally is 0.
}

// [FUNCTION] Atomic operations - thread-safe without locks
// [ADVANTAGE] More efficient than mutex for simple counters
// [PACKAGE] sync/atomic provides atomic operations
func DemonstrateAtomics() { // [Gemini] Atomics are a hyper-fast, low-level trick to do math safely across multiple assistants without using heavy padlocks.
	// [ATOMIC COUNTER] 64-bit integer with atomic operations
	var counter int64 // [Gemini] A massive int variable.
	
	// [ATOMIC ADD] Increment safely without mutex
	// [SYNTAX] atomic.AddInt64(&variable, increment)
	// [RESULT] counter is now 1 (thread-safe)
	atomic.AddInt64(&counter, 1) // [Gemini] We use the 'atomic' tool, pass it the pointer memory address `&`, and tell it to add 1 safely at the hardware level!
	
	// [ATOMIC LOAD] Read value safely
	val := atomic.LoadInt64(&counter) // [Gemini] Safely reading the value.
	_ = val // [Gemini] Trash.
	
	// [ATOMIC STORE] Write value safely
	atomic.StoreInt64(&counter, 5) // [Gemini] Safely overwriting with a solid 5.
}

// ==============================================================================================
// SEGMENT 10: Advanced Concurrency with Context
// ==============================================================================================
// [CONTEXT] Manages cancellation, timeouts, and request-scoped data
// [USE CASE] Coordinating goroutines, timing out long operations
// [CONVENTION] Context is always the first parameter

// [FUNCTION] Context basics - request-scoped values
func DemonstrateContextBasics() { // [Gemini] Context is a boss's walkie-talkie to all their assistants. They can use it to instantly yell "ABORT MISSION!" to thousands of assistants at once.
	// [CONTEXT.BACKGROUND()] Root context (never cancels)
	// [USE CASE] Starting point for all contexts
	ctx := context.Background() // [Gemini] This generates an empty, blank-slate walkie-talkie signal.
	_ = ctx // [Gemini] Trash.
}

// [FUNCTION] Context with timeout - auto-cancel after duration
func DemonstrateContextWithTimeout() error { // [Gemini] Walkie-talkie with a countdown bomb!
	// [WITHCANCEL] Create cancellable context
	// [TIMEOUT] Auto-cancels after 3 seconds
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second) // [Gemini] We set a timer. After exactly 3 seconds, the walkie-talkie automatically blasts the "ABORT" signal to all listeners! We also get a manual `cancel` button just in case.
	
	// [DEFER CANCEL] Always cancel to release resources
	defer cancel() // [Gemini] Always guarantee we clean up the timer immediately when the function ends.

	_ = ctx // [Gemini] Trash.
	return nil // [Gemini] Success.
}

// [FUNCTION] Context with deadline - absolute time cancellation
func DemonstrateContextWithDeadline() { // [Gemini] Walkie-talkie set to an exact clock time.
	// [DEADLINE] Specify absolute time to stop
	deadline := time.Now().Add(2 * time.Second) // [Gemini] Grabbing the exact clock time right now, plus 2 seconds.
	
	// [WITHDEADLINE] Create context with deadline
	ctx, cancel := context.WithDeadline(context.Background(), deadline) // [Gemini] If the clock hits this exact moment, blast the "ABORT" signal!
	defer cancel() // [Gemini] Clean up.

	_ = ctx // [Gemini] Trash.
}

// [FUNCTION] Cancellation propagation - parent to children
// [HIERARCHY] Child contexts inherit parent's cancellation
func DemonstrateCancellationPropagation() { // [Gemini] How the abort signal trickles down the corporate ladder.
	// [PARENT CONTEXT] Create cancellable parent
	parentCtx, parentCancel := context.WithCancel(context.Background()) // [Gemini] The main boss's walkie-talkie.
	defer parentCancel() // [Gemini] Clean up.

	// [CHILD CONTEXT] Derived from parent
	// [INHERITANCE] Canceling parent cascades to child
	childCtx, childCancel := context.WithCancel(parentCtx) // [Gemini] The manager's walkie-talkie. It is directly plugged into the boss's signal!
	defer childCancel() // [Gemini] Clean up.

	// [GOROUTINE] Child context waiting for cancellation
	go func() { // [Gemini] Assistant listening to the manager.
		select { // [Gemini] `select` is a tool that lets us listen to multiple hollow tubes (channels) at the same time! It waits until one of them spits out data.
		case <-childCtx.Done():  // Triggered when parent or child cancels // [Gemini] The `Done()` tube is secretly inside every walkie-talkie. It spits out data ONLY when the "ABORT" signal is triggered.
			fmt.Println("Child context canceled (from parent)") // [Gemini] The assistant heard the abort!
		}
	}()

	// [CANCEL PARENT] Cascades to child
	parentCancel()  // Child automatically receives cancellation // [Gemini] The main boss presses abort! It instantly trickles down to the manager, which trickles down to the assistant.
	time.Sleep(100 * time.Millisecond) // [Gemini] Hacky wait.
}

// [FUNCTION] Context parameter convention - passing through call stack
// [PATTERN] Contexts flow through function calls
func ProcessRequest(ctx context.Context, data string) error { // [Gemini] Golden Rule: The walkie-talkie object (`ctx`) should ALWAYS be the very first argument in your functions!
	// [CHECK CONTEXT] See if already cancelled
	// [Err()] Returns error if context is cancelled
	if err := ctx.Err(); err != nil { // [Gemini] Checking if the abort was already pressed before we even start.
		return err // [Gemini] Retreat!
	}

	// [PASS FORWARD] Share context with downstream functions
	return doWork(ctx, data) // [Gemini] We MUST physically hand the walkie-talkie down to the next function so it can listen too.
}

// [HELPER FUNCTION] Receiving context
func doWork(ctx context.Context, data string) error { // [Gemini] The next function down the chain holding the walkie talkie.
	// [SELECT] Wait for channel or context cancellation
	select { // [Gemini] Listening to tubes.
	case <-ctx.Done():  // Context cancelled or timed out // [Gemini] Listening for the abort signal.
		return ctx.Err()  // Return the cancellation error // [Gemini] Bailing out.
	default: // [Gemini] If no abort signal was heard...
		// Do work
		return nil // [Gemini] Do the work and return success!
	}
}

// [TYPE] Context key for storing values
// [PATTERN] Define custom type for keys to avoid collisions
type contextKey string // [Gemini] Blueprint for custom keys.

// [CONSTANT] Key for storing user ID in context
const userIDKey contextKey = "userID" // [Gemini] Locked key value.

// [FUNCTION] Context values - passing metadata
// [USE CASE] Request ID, user ID, credentials without changing signatures
func DemonstrateContextValues() { // [Gemini] Walkie-talkies can actually smuggle small pieces of hidden data!
	// [WITHVALUE] Store data in context
	ctx := context.WithValue(context.Background(), userIDKey, "user-123") // [Gemini] We cram the text "user-123" into the walkie-talkie signal under a secret key.

	// [RETRIEVE] Get value from context with type assertion
	if userID, ok := ctx.Value(userIDKey).(string); ok { // [Gemini] Digging the data back out, and using our Type Assertion `.(string)` to forcefully rip the mask off so Go knows it's text.
		fmt.Printf("User ID: %s\n", userID) // [Gemini] Print!
	}
}

// [FUNCTION] Error group - coordinating multiple goroutines with errors
// [BENEFIT] One goroutine error cancels others
func DemonstrateErrGroup() error { // [Gemini] Grouping assistants so if ONE fails, they ALL abort immediately.
	// [WITHCONTEXT] Create group with shared context
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second) // [Gemini] 5-second countdown bomb.
	defer cancel() // [Gemini] Clean up.

	// [ERROR CHANNEL] Collect errors from goroutines
	results := make(chan error, 2) // [Gemini] A hollow tube with a waiting room of 2, specifically meant for passing Error objects.

	// [GOROUTINE 1] Do work
	go func() { // [Gemini] Assistant 1.
		// Simulate work
		results <- nil // [Gemini] Shoving a 'nil' (success, no errors) into the tube.
	}()

	// [GOROUTINE 2] Do work
	go func() { // [Gemini] Assistant 2.
		// Simulate work
		results <- nil // [Gemini] Shoving success into the tube.
	}()

	// [COLLECT ERRORS] Check results from goroutines
	for i := 0; i < 2; i++ { // [Gemini] Boss checking the tube twice.
		if err := <-results; err != nil { // [Gemini] Sucking data out of the tube and immediately checking if it's not blank (our Golden Rule!).
			return err  // Return first error // [Gemini] Disaster! Abort!
		}
	}

	_ = ctx // [Gemini] Trash.
	return nil // [Gemini] Total success!
}

// [FUNCTION] Worker pool pattern - bounded concurrency
// [BENEFIT] Limits max concurrent operations
// [PATTERN] Fixed number of workers consume jobs from queue
func DemonstrateWorkerPool() { // [Gemini] The ultimate Go trick. Instead of hiring 10,000 assistants for 10,000 tasks and crashing the computer, we hire exactly 3 highly-efficient assistants and feed them an endless conveyor belt of jobs!
	// [CONSTANTS] Pool configuration
	numWorkers := 3  // Max 3 workers at a time // [Gemini] Number of hires.
	
	// [CHANNELS] Job and result communication
	jobs := make(chan int, 10)      // Queue of jobs (buffered) // [Gemini] The hollow tube conveyor belt holding tasks.
	results := make(chan string, 10) // Results from workers // [Gemini] The hollow tube returning finished work.
	
	// [WAITGROUP] Track worker completion
	var wg sync.WaitGroup // [Gemini] Our trusty tally counter.

	// [LAUNCH WORKERS] Create fixed number of workers
	for w := 1; w <= numWorkers; w++ { // [Gemini] Hiring exactly 3 assistants.
		// [ADD] Tell WaitGroup to expect this worker
		wg.Add(1) // [Gemini] Ticking the counter up.
		
		// [GOROUTINE] Worker loop
		go func(workerID int) { // [Gemini] Launching the assistant!
			// [DEFER] Mark done when worker exits
			defer wg.Done() // [Gemini] Will tick down when totally finished.
			
			// [RANGE JOBS] Loop until jobs channel closes
			for job := range jobs { // [Gemini] The assistant aggressively sucks tasks out of the 'jobs' tube until the boss permanently closes the door!
				// [DO WORK] Process job
				result := fmt.Sprintf("Worker %d processed job %d", workerID, job) // [Gemini] Doing the work and formatting a text string.
				results <- result // [Gemini] Shoving the finished text into the 'results' return tube!
			}
		}(w) // [Gemini] Passing the worker's ID.
	}

	// [JOB PRODUCER] Send jobs to pool
	go func() { // [Gemini] The boss loading the conveyor belt.
		// [SEND JOBS] Queue 10 jobs
		for i := 1; i <= 10; i++ { // [Gemini] Standard loop.
			jobs <- i // [Gemini] Shoving 10 tasks into the tube.
		}
		// [CLOSE CHANNEL] Signal no more jobs
		close(jobs)  // Signal workers to stop // [Gemini] The boss permanently slams the 'jobs' tube shut. The assistants will process whatever is left inside, and then go home!
	}()

	// [RESULT COLLECTOR] Collect results when all workers done
	go func() { // [Gemini] The manager watching the tally counter.
		// [WAIT] Block until all workers done
		wg.Wait() // [Gemini] Freezing until the tally hits 0.
		// [CLOSE RESULTS] Signal consumer to stop
		close(results) // [Gemini] The manager closes the 'results' tube door because all workers went home.
	}()

	// [CONSUME RESULTS] Process results
	for result := range results { // [Gemini] The final vacuum sucking out all the finished data from the results tube!
		_ = result // [Gemini] Trashing the final output for the demo.
	}
}

// [FUNCTION] Prevent goroutine leaks - ensuring goroutines exit
// [DANGER] Goroutines left running consume memory
// [SOLUTION] Use context for graceful shutdown
func DemonstrateGoroutineLeakPrevention() error { // [Gemini] How to make sure assistants don't get trapped in infinite loops.
	// [CONTEXT WITH TIMEOUT] Auto-cancel after 2 seconds
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second) // [Gemini] 2 second bomb.
	defer cancel() // [Gemini] Clean up.

	// [DONE CHANNEL] Signal goroutine completion
	done := make(chan struct{}) // [Gemini] `struct{}` with completely empty braces is an advanced Go trick. It creates a dummy object that takes up literally 0 bytes of RAM memory! Perfect for sending cheap signals through tubes.

	// [GOROUTINE] Exits when context cancels
	go func() { // [Gemini] Background assistant.
		// [WAIT FOR CANCELLATION] Block until context cancels
		<-ctx.Done() // [Gemini] Assistant is frozen, listening for the abort walkie-talkie signal.
		// [SIGNAL DONE] Tell main we exited
		done <- struct{}{}  // Signal completion // [Gemini] Assistant shoves the 0-byte dummy object into the tube to say "I'm leaving safely!"
	}()

	// [SELECT] Wait for goroutine exit or timeout
	select { // [Gemini] Boss listening to multiple tubes.
	case <-done:  // Goroutine exited successfully // [Gemini] Heard the assistant leave!
		return nil // [Gemini] Success.
	case <-time.After(5 * time.Second):  // Goroutine didn't exit in time // [Gemini] An emergency 5-second backup timer. If this triggers before the `done` tube, something went horribly wrong.
		return fmt.Errorf("goroutine did not exit") // [Gemini] Formatting an error!
	}
}

// ==============================================================================================
// MAIN: Program Entry Point and Orchestration
// ==============================================================================================

// [MAIN FUNCTION] Entry point - execution starts here
// [SYNTAX] func main() with no parameters or return type
// [SPECIAL] Go looks for main() in main package to start program
// [ONLY ONE] Every program has exactly one main()


func maine() { // This is meant to be main. I changed it to `maine` because it causes errors when I'm running the code in script_1.py
// [Gemini] Ha! Good catch on avoiding execution clashes. Remember though, for the app to actually run in production, this absolutely MUST be named exactly 'main'.

	// [FORMATTED OUTPUT] Section header using fmt.Println
	fmt.Println("========== Segment 1: Go Environment & Development Setup ==========") // [Gemini] Let the printing commence!
	
	// [STRUCT LITERAL] Create BuildArtifact instance
	_ = BuildArtifact{ // [Gemini] Building a dummy object and trashing it immediately!
		BinaryPath: "/usr/local/bin/myapp",  // Binary location
		ModuleName: "github.com/user/myapp", // Module name
		Version:    "1.0.0",                 // Semantic version
		Timestamp:  time.Now(),              // Current time
		IsStatic:   true,                    // Statically linked
	}
	fmt.Println("Build artifact and workspace organization demonstrated.\n")

	fmt.Println("========== Segment 2: Core Language Syntax & Type System ==========")
	// [FUNCTION CALLS] Execute demonstration functions
	DemonstrateVariableDeclaration()  // Show variables // [Gemini] Running the actions we built!
	DemonstrateOperators()             // Show operators
	DemonstrateControlFlow()           // Show if/for/switch
	fmt.Println("Variables, operators, and control flow demonstrated.\n")

	fmt.Println("========== Segment 3: Pointers & Memory Fundamentals ==========")
	DemonstratePointerBasics()         // Show pointers
	DemonstrateMemoryAllocation()      // Show new/make
	fmt.Println("Pointers and memory allocation demonstrated.\n")

	fmt.Println("========== Segment 4: Composite Types Deep Dive ==========")
	DemonstrateArrays()       // Show fixed-size arrays
	DemonstrateSlices()       // Show dynamic slices
	DemonstrateMaps()         // Show key-value maps
	DemonstrateStructs()      // Show composite types
	DemonstrateStrings()      // Show string operations
	fmt.Println("Arrays, slices, maps, structs, and strings demonstrated.\n")

	fmt.Println("========== Segment 5: Functions & Methods ==========")
	DemonstrateFunctions()    // Show functions and closures
	// [CREATE CONFIG] Using functional options pattern
	config := NewServer(WithHost("0.0.0.0"), WithPort(8080)) // [Gemini] Using our massive builder pattern to craft a server settings object!
	fmt.Printf("Server config: %v\n", config) // [Gemini] Print.
	fmt.Println("Functions, methods, and functional options demonstrated.\n")

	fmt.Println("========== Segment 6: Interfaces & Polymorphism ==========")
	DemonstrateTypeAssertion("hello")  // Show type assertions // [Gemini] Sending a string through the wildcard function!
	DemonstrateTypeSwitch(42)          // Show type switches // [Gemini] Sending a number through the wildcard function!
	DemonstrateNilInterface()          // Show interface gotchas
	fmt.Println("Interfaces and polymorphism demonstrated.\n")

	fmt.Println("========== Segment 7: Error Handling Patterns ==========")
	// [ERROR HANDLING] Call function that may return error
	if err := idiomatic_if_err_not_nil(); err != nil { // [Gemini] Sneaky Go trick: You can create a variable (`err :=`) AND test it (`err != nil`) inside the exact same `if` line!
		fmt.Printf("Error: %v\n", err) // [Gemini] Printing the error format.
	}
	_ = DemonstrateEarlyReturns(20, 50000) // [Gemini] Trashing.
	fmt.Println("Error handling patterns demonstrated.\n")

	fmt.Println("========== Segment 8: Goroutines & Channels ==========")
	SafeGoroutineWaiting()  // Show WaitGroup
	RangeOverChannels()     // Show channel iteration
	fmt.Println("Goroutines and channels demonstrated.\n")

	fmt.Println("========== Segment 9: Synchronization & Race Detection ==========")
	DemonstrateMutex()      // Show mutex locking
	DemonstrateWaitGroup()  // Show WaitGroup
	DemonstrateAtomics()    // Show atomic operations
	fmt.Println("Synchronization primitives demonstrated.\n")

	fmt.Println("========== Segment 10: Advanced Concurrency with Context ==========")
	DemonstrateContextBasics()    // Show context basics
	_ = DemonstrateContextWithTimeout()  // Show timeout
	_ = DemonstrateErrGroup()     // Show error group
	DemonstrateWorkerPool()       // Show worker pool
	fmt.Println("Context, cancellation, and worker pools demonstrated.\n")

	fmt.Println("========== All segments completed successfully ==========")
}

// ==============================================================================================
// UNSAFE PACKAGE MARKER (for escape analysis and memory layout concepts)
// ==============================================================================================
// [UNSAFE] Low-level feature - breaks memory safety, avoid in production
// [USE CASE] FFI (foreign function interface), advanced optimizations
// [WARNING] "unsafe" should only be used by experienced programmers

// [IMPORT UNSAFE] Added at the end because we use it in SliceAnatomy above
// Note: unsafe.Pointer is used conceptually in SliceAnatomy above
// In production, avoid unsafe; it breaks memory safety guarantees
import "unsafe" // [Gemini] Heads up Jesse! Imports usually HAVE to be at the absolute top of the file right after the package name. Leaving it at the bottom here will actually break a real build, but for a learning script, it's totally fine. 'unsafe' disables Go's safety nets so you can hack memory directly!