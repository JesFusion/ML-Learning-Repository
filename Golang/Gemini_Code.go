// ==============================================================================================
// GO PROGRAM STRUCTURE & PACKAGE DECLARATION
// ==============================================================================================

// [WHAT IS THIS LINE] package main
// [MEANING] Declares that this file belongs to the "main" package
// [WHY IMPORTANT] Go programs start execution in the main() function of the main package
// [KEY CONCEPT] Every Go file must belong to exactly one package
// [SPECIAL RULE] The main package is special - it's where your program execution begins
// [EXAMPLE] If this was a library, you might write: package mylib
package main

// ==============================================================================================
// IMPORT BLOCK - Bringing in External Code (Standard Library)
// ==============================================================================================

// [WHAT ARE IMPORTS] Like #include in C/C++; they bring in pre-built code packages
// [SYNTAX] import ("package1"; "package2") groups multiple imports together
// [STANDARD LIBRARY] Go comes with batteries included - these are built-in packages

import (
	// [PACKAGE] context = Used for managing cancellation, timeouts, and request scoping
	// [USE CASE] When you have goroutines or long-running operations that need cancellation
	// [EXAMPLE] If your HTTP server receives a request, context passes info through the call chain
	"context"

	// [PACKAGE] errors = Tools for creating and working with error values
	// [USE CASE] Creating custom error messages, wrapping errors
	// [EXAMPLE] errors.New("something went wrong") creates a basic error
	"errors"

	// [PACKAGE] fmt = "format" - printing and formatting strings
	// [USE CASE] Printing to console, formatting strings
	// [EXAMPLE] fmt.Println("Hello") prints and adds newline
	// [METHODS] Println (print with newline), Printf (formatted printing), Sprintf (format to string)
	"fmt"

	// [PACKAGE] io = Input/Output interfaces and utilities
	// [USE CASE] Reading/writing data in a type-safe way
	// [EXAMPLE] io.Closer is an interface for things you can close (files, connections)
	"io"

	// [PACKAGE] strings = Operations on string values
	// [USE CASE] Manipulating strings (split, join, contains, etc.)
	// [EXAMPLE] strings.Contains("hello", "ell") returns true
	"strings"

	// [PACKAGE] sync = Synchronization primitives (mutual exclusion, waiting)
	// [USE CASE] When multiple goroutines access shared data
	// [EXAMPLE] sync.Mutex prevents concurrent access to shared variables
	"sync"

	// [PACKAGE] sync/atomic = Atomic operations (thread-safe without locks)
	// [USE CASE] Incrementing counters safely without using mutex
	// [EXAMPLE] atomic.AddInt64() increments a 64-bit int safely
	"sync/atomic"

	// [PACKAGE] time = Date, time, and duration functionality
	// [USE CASE] Measuring durations, getting current time, sleeping, timeouts
	// [EXAMPLE] time.Now() gets current time, time.Sleep(1*time.Second) waits 1 second
	"time"
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
type BuildArtifact struct {
	// [FIELD] BinaryPath - where the binary file lives on disk
	// [TYPE] string - sequence of characters (immutable UTF-8 bytes)
	BinaryPath string
	
	// [FIELD] ModuleName - the module name (from go.mod)
	// [TYPE] string - typically like "github.com/username/projectname"
	ModuleName string
	
	// [FIELD] Version - semantic versioning (e.g., "1.0.0", "1.2.3")
	// [TYPE] string - helps track which version of code was compiled
	Version string
	
	// [FIELD] Timestamp - when the binary was built
	// [TYPE] time.Time - built-in Go type for dates/times
	Timestamp time.Time
	
	// [FIELD] IsStatic - whether binary is statically linked
	// [TYPE] bool - true or false
	// [WHAT IS STATIC LINKING] Binary contains all dependencies; can run anywhere
	// [CONTRAST] Dynamic linking - binary depends on external libraries on the system
	IsStatic bool
}

// [WHAT IS THIS STRUCT] WorkspaceLayout shows typical Go project structure
// [WHY IMPORTANT] Organizing code makes it maintainable and conventional
type WorkspaceLayout struct {
	// [FIELD] CmdDir - directory for executable entry points
	// [CONVENTION] src/cmd/ contains main packages that become executables
	CmdDir string
	
	// [FIELD] PkgDir - directory for public library code
	// [CONVENTION] src/pkg/ or just individual package directories
	PkgDir string
	
	// [FIELD] InternalDir - code only used within this project
	// [CONVENTION] internal/ directory (Go prevents importing this from external projects)
	InternalDir string
	
	// [FIELD] VendorDir - local copy of dependencies
	// [CONVENTION] vendor/ directory (optional, for offline builds)
	VendorDir string
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
type TypeSystemDemo struct {
	// [COMMENT EXPLAINING INTEGERS]
	// Go has many integer types. "int" size depends on your system (32 or 64 bits).
	// Use specific sizes (int32, int64) when interoperating with C or binary formats.
	
	// [TYPE] int - signed integer (could be 32 or 64 bits depending on platform)
	// [USE WHEN] Size doesn't matter; this is the default
	IntValue int
	
	// [TYPE] int8 - signed integer, exactly 8 bits
	// [RANGE] -128 to 127
	// [USE WHEN] Saving space, working with bytes
	Int8Value int8
	
	// [TYPE] int32 - signed integer, exactly 32 bits  
	// [RANGE] about -2 billion to 2 billion
	// [USE WHEN] Fixed size needed, C interop
	Int32Value int32
	
	// [TYPE] int64 - signed integer, exactly 64 bits
	// [RANGE] about -9 quintillion to 9 quintillion  
	// [USE WHEN] Very large numbers, Unix timestamps
	Int64Value int64
	
	// [TYPE] byte - alias for uint8 (unsigned, 0 to 255)
	// [USE WHEN] Working with binary data, character codes
	// [SPECIAL] "byte" is preferred over "uint8" for readability
	ByteValue byte
	
	// [TYPE] uint - unsigned integer (like int but always positive)
	// [RANGE] 0 to very large number (depends on platform)
	UintValue uint
	
	// [TYPE] uint64 - unsigned integer, exactly 64 bits
	// [RANGE] 0 to about 18 quintillion
	// [USE WHEN] Large positive numbers, IDs, bit flags
	UintValue64 uint64

	// [COMMENT ABOUT FLOATS]
	// Floating-point numbers follow IEEE 754 standard (like other languages)
	// Precision is limited! Don't use for financial calculations (use big.Decimal instead)
	
	// [TYPE] float32 - 32-bit IEEE 754 floating point
	// [PRECISION] About 6-7 decimal digits
	// [USE WHEN] Saving space (graphics, scientific computing)
	Float32Value float32
	
	// [TYPE] float64 - 64-bit IEEE 754 floating point
	// [PRECISION] About 15 decimal digits
	// [DEFAULT] When you write 3.14, Go assumes float64
	// [USE WHEN] Default choice for floats; most scientific/financial work
	Float64Value float64

	// [COMMENT ABOUT BOOLEANS]
	// Booleans are simple: true or false. Used in if statements and conditions.
	// They don't implicitly convert to int (unlike C).
	
	// [TYPE] bool - true or false
	// [DEFAULT VALUE] false (when declared without initialization)
	// [KEY DIFFERENCE] In C, if(1) is true; in Go, you must use if(true)
	BoolValue bool
	
	// [COMMENT ABOUT STRINGS]
	// Strings in Go are immutable byte sequences (UTF-8 encoded)
	// This means: once created, they can't change (but you can create new ones)
	// Immutability enables efficient sharing and is safe for concurrent access
	
	// [TYPE] string - immutable sequence of UTF-8 bytes
	// [DEFAULT VALUE] "" (empty string)
	// [INDEXING] s[0] gets the first BYTE (not character for non-ASCII)
	// [LENGTH] len(s) returns bytes (not characters for multi-byte UTF-8)
	StringValue string

	// [COMMENT ABOUT RUNES]
	// "rune" is Go's way of representing a single Unicode character
	// It's an alias for int32 (which can hold any Unicode code point)
	// Use rune when you care about individual characters, not bytes
	
	// [TYPE] rune - represents single Unicode character (alias for int32)
	// [USE WHEN] Iterating over strings character-by-character
	// [EXAMPLE] 'A' is a rune with value 65
	// [DIFFERENCE FROM BYTE] Rune can be any Unicode char; byte is just 0-255
	RuneValue rune
}

// [FUNC] This is a function - a reusable block of code
// [MEANING] DemonstrateVariableDeclaration = function name (what it does)
// [SYNTAX] func functionName() { body } is the Go function syntax
// [PARAMETERS] () - empty means this function takes no arguments
// [RETURN TYPE] No return type specified, so returns nothing (void in C terms)
// [EXECUTION] Called from main() as: DemonstrateVariableDeclaration()
func DemonstrateVariableDeclaration() {
	// [WHAT LINE IS THIS] var age int = 25
	// [var KEYWORD] Declares a variable (mutable storage)
	// [age] Variable name (what you call it when you use it)
	// [int] Type (what kind of data it holds)
	// [= 25] Initial value (what it starts out as)
	// [READING IT] "Declare a variable named 'age' of type 'int' and assign it the value 25"
	var age int = 25
	
	// [SIMILAR DECLARATION] name is a string variable with initial value "Alice"
	var name string = "Alice"

	// [WHAT IS A ZERO VALUE] When you declare without assigning a value
	// Go sets it to the "zero value" for that type:
	// - int/float/byte: 0
	// - bool: false
	// - string: "" (empty)
	// - pointer: nil (means "points to nothing")
	
	// [ZERO VALUE EXAMPLE] balance starts as 0.0 (even though we don't say = 0.0)
	var balance float64    // Defaults to 0.0
	
	// [ZERO VALUE EXAMPLE] isActive starts as false
	var isActive bool      // Defaults to false
	
	// [ZERO VALUE EXAMPLE] username starts as empty string ""
	var username string    // Defaults to ""
	
	// [ZERO VALUE EXAMPLE] count starts as 0
	var count int          // Defaults to 0
	
	// [ZERO VALUE EXAMPLE] ptr starts as nil (null pointer)
	var ptr *int           // Defaults to nil (the * means it's a pointer)

	// [SHORT DECLARATION] := operator (only works inside functions!)
	// [WHAT IT DOES] Declares AND initializes variable
	// [TYPE INFERENCE] Go figures out the type from the value on the right
	// [SYNTAX] variableName := value
	// [READING IT] "create message variable, initialize to 'Hello, Go!', let Go figure out type"
	message := "Hello, Go!"  // Go infers this is a string
	
	// [TYPE INFERENCE] Go sees 42 is an int, so value is int type
	value := 42
	
	// [TYPE INFERENCE] Go sees 3.14159 is a float, so pi is float64 type
	pi := 3.14159

	// [IMPORTANT WARNING] These lines tell you about Go rules
	// [RULE] := only works INSIDE functions
	// [WHERE IT FAILS] At the top level of your program (package scope), you must use var
	// [WHY] At package level, code isn't executing yet; only function-level code is executed

	// [CONST KEYWORD] Constants are like variables but CAN'T CHANGE after declaration
	// [KEY DIFFERENCE FROM VAR] const must have a compile-time constant value
	// [WHAT IS COMPILE-TIME] Value must be known before the program runs
	// [EXAMPLE] You can't do: const x int = getUserInput() because that's a runtime value
	
	// [CONST EXAMPLE] MaxRetries is a constant (can't change it later)
	const MaxRetries = 3
	
	// [CONST WITH TYPE] APITimeout is a constant with explicit type
	// [TIME CALCULATIONS] time.Second is a built-in duration (1 second)
	// [MULTIPLICATION] 30 * time.Second means 30 times one second = 30 seconds
	const APITimeout = 30 * time.Second
	
	// [CONST PI] Mathematical constant - doesn't change
	const PI = 3.14159265359

	// [WHAT IS TYPE INFERENCE] Go looks at what you assign and guesses the type
	// [WHY THIS IS GOOD] Less typing, but still type-safe (checked at compile-time)
	
	// [INFERENCE EXAMPLE 1] The number 10 looks like an int
	defaultInt := 10                    // inferred as type int
	
	// [INFERENCE EXAMPLE 2] The number 10.5 has decimal, must be float64
	defaultFloat := 10.5                // inferred as type float64
	
	// [INFERENCE EXAMPLE 3] Text in quotes is always string
	defaultString := "text"             // inferred as type string
	
	// [INFERENCE EXAMPLE 4] Single character in single quotes is rune
	defaultRune := 'A'                  // inferred as type rune (NOT byte)
	
	// [INFERENCE EXAMPLE 5] Complex number (with 'i' for imaginary)
	defaultComplex := 1 + 2i            // inferred as type complex128

	// [WHAT IS TYPE CONVERSION] Taking value of one type and changing it to another
	// [WHY NEEDED] Sometimes you have int but function wants float64
	// [SYNTAX] TargetType(value) converts value to TargetType
	// [KEY RULE] Go does NOT automatically convert types (unlike C)
	// [EXAMPLE] int 100 doesn't automatically become float64 100.0; must be explicit
	
	// [DECLARING VARIABLE] intVal is int type with value 100
	var intVal int = 100
	
	// [CONVERSION] float64(intVal) means "take intVal and convert to float64"
	// [RESULT] Creates a new float64 value, doesn't modify intVal
	floatVal := float64(intVal) // Convert int to float64
	
	// [CONVERSION VIA FORMATTING] Sprintf formats as string
	// [EXAMPLE] %d means "format as decimal integer"
	// [RESULT] "100" (string) instead of 100 (number)
	stringVal := fmt.Sprintf("%d", intVal) // Convert int to string via formatting

	// [WHAT ARE THESE LINES] Using blank identifier _ to prevent "unused variable" errors
	// [WHY GO COMPLAINS] Go considers unused variables as potential bugs
	// [SOLUTION] Assign to _ to suppress the warning
	// [USE CASE] When you need a variable for demonstration but won't use it
	_ = age
	_ = name
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
func DemonstrateOperators() {
	// [MULTIPLE ASSIGNMENT] Create two variables in one line
	// [SYNTAX] a, b := value1, value2
	// [RESULT] a=10, b=3
	a, b := 10, 3
	
	// [ARITHMETIC OPERATOR] + (addition)
	// [RESULT] 10 + 3 = 13
	sum := a + b        // 13
	
	// [ARITHMETIC OPERATOR] - (subtraction)
	// [RESULT] 10 - 3 = 7
	diff := a - b       // 7
	
	// [ARITHMETIC OPERATOR] * (multiplication)
	// [RESULT] 10 * 3 = 30
	product := a * b    // 30
	
	// [ARITHMETIC OPERATOR] / (division)
	// [IMPORTANT] If both are integers, result is integer (10/3 = 3, not 3.33)
	// [EXPLANATION] This is integer division; drops the decimal part
	quotient := a / b   // 3 (not 3.33, because both operands are ints)
	
	// [ARITHMETIC OPERATOR] % (modulo/remainder)
	// [WHAT IT DOES] Gives remainder after division
	// [EXAMPLE] 10 divided by 3 is 3 remainder 1, so 10%3 = 1
	remainder := a % b  // 1

	// [COMPARISON OPERATORS] Check if something is true or false
	// [RESULT TYPE] Always returns bool (true or false)
	
	// [COMPARISON] > (greater than)
	// [RESULT] Is 10 > 3? Yes, so true
	isGreater := a > b      // true
	
	// [COMPARISON] == (equals)
	// [RESULT] Is 10 == 3? No, so false
	// [NOTE] Single = assigns; double == compares
	isEqual := a == b       // false
	
	// [COMPARISON] != (not equal)
	// [RESULT] Is 10 != 3? Yes (they're different), so true
	isNotEqual := a != b    // true
	
	// [COMPARISON] <= (less than or equal)
	// [RESULT] Is 10 <= 3? No, so false
	isLessOrEqual := a <= b // false

	// [LOGICAL OPERATORS] Combine boolean values
	// [RESULT] Always returns bool
	
	// [LOGICAL OPERATOR] && (AND)
	// [MEANING] Both sides must be true for result to be true
	// [EVALUATION] (10 > 18) is false AND (10 < 100) is true → false AND true = false
	// [SHORT CIRCUIT] If left side is false, right side isn't even evaluated
	isAdult := (a > 18) && (a < 100)  // false && true = false
	
	// [LOGICAL OPERATOR] || (OR)
	// [MEANING] At least one side must be true for result to be true
	// [EVALUATION] false OR true = true
	// [SHORT CIRCUIT] If left side is true, right side isn't evaluated
	isWeekend := false || true         // false || true = true
	
	// [LOGICAL OPERATOR] ! (NOT)
	// [MEANING] Flips true to false, false to true
	// [EVALUATION] Is 10 > 50? No (false). NOT false = true
	isNotValid := !(a > 50)            // !(false) = true

	// [BITWISE OPERATORS] Work on binary representations
	// [WHEN TO USE] Low-level operations, bit flags, protocols
	// [BINARY REPRESENTATION] 5 is 0101, 3 is 0011
	
	// [NEW VARIABLES] x and y for bitwise demos
	x, y := 5, 3              // binary: 0101, 0011
	
	// [BITWISE] & (AND each bit)
	// [HOW IT WORKS] Bit is 1 only if BOTH inputs are 1
	//   0101 & 0011 = 0001 (only position 0 has 1 in both)
	// [RESULT] 0001 = 1
	bitwiseAnd := x & y       // 0001 = 1
	
	// [BITWISE] | (OR each bit)
	// [HOW IT WORKS] Bit is 1 if AT LEAST ONE input is 1
	//   0101 | 0011 = 0111 (positions 0,1,2 have at least one 1)
	// [RESULT] 0111 = 7
	bitwiseOr := x | y        // 0111 = 7
	
	// [BITWISE] ^ (XOR - exclusive or)
	// [HOW IT WORKS] Bit is 1 if inputs DIFFER
	//   0101 ^ 0011 = 0110 (positions 1,2 differ)
	// [RESULT] 0110 = 6
	bitwiseXor := x ^ y       // 0110 = 6
	
	// [BITWISE] << (left shift)
	// [HOW IT WORKS] Move all bits left, fill with zeros
	//   0101 << 1 = 1010 (moved left 1 position)
	// [EFFECT] Equivalent to multiplying by 2^n (where n is shift amount)
	// [RESULT] 1010 = 10
	leftShift := x << 1       // 1010 = 10
	
	// [BITWISE] >> (right shift)
	// [HOW IT WORKS] Move all bits right, fill with zeros (for unsigned)
	//   0101 >> 1 = 0010 (moved right 1 position)
	// [EFFECT] Equivalent to dividing by 2^n
	// [RESULT] 0010 = 2
	rightShift := x >> 1      // 0010 = 2

	// [PREVENT UNUSED WARNINGS] Again using _ to suppress warnings
	_ = sum
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
func DemonstrateControlFlow() {
	// [WHAT LINE IS THIS] age := 25
	// [DECLARATION] Creating variable age, type is inferred as int, value is 25
	age := 25
	
	// [IF STATEMENT] "if condition { do this }"
	// [SYNTAX] No parentheses required (unlike C)
	// [BRACES] Mandatory - Go requires them even for single statement
	// [EXECUTION] Code in braces runs only if condition is true
	if age >= 18 {
		// [FUNCTION CALL] fmt.Println prints to console with newline
		// [STRING] Text in quotes is a string literal
		fmt.Println("Adult")
	} else if age >= 13 {
		// [ELSE IF] Checked only if previous condition was false
		// [CHAINING] You can chain many else if conditions
		fmt.Println("Teen")
	} else {
		// [ELSE] Runs if no previous condition was true
		fmt.Println("Child")
	}

	// [SWITCH STATEMENT] More readable than many if/else statements
	// [SYNTAX] switch value { case option1: ... case option2: ... }
	// [HOW IT WORKS] Compares value against each case
	
	day := "Monday"  // Variable to switch on
	switch day {
	// [CASE] If day equals "Monday", "Tuesday", or "Wednesday"
	// [SYNTAX] case val1, val2, val3: means "any of these values"
	case "Monday", "Tuesday", "Wednesday":
		fmt.Println("Weekday")
	// [ANOTHER CASE] If day equals "Saturday" or "Sunday"
	case "Saturday", "Sunday":
		fmt.Println("Weekend")
	// [DEFAULT] If none of the cases match
	// [PURPOSE] Fallback behavior, like else
	default:
		fmt.Println("Unknown")
	}

	// [SWITCH WITHOUT EXPRESSION] Using switch like if/else
	// [SYNTAX] switch { case condition1: ... case condition2: ... }
	// [BENEFIT] More readable when testing different conditions
	
	score := 85  // Variable holding a score
	switch {
	// [CASE] First condition checked
	case score >= 90:
		fmt.Println("Grade A")
	// [CASE] Only checked if above was false
	case score >= 80:
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
	for i := 0; i < 5; i++ {
		// [WHAT HAPPENS] First iteration: i=0, body runs
		//                 Second iteration: i=1, body runs
		//                 ... continues until i=5 (condition fails)
		_ = i  // Use i (can do anything here)
	}

	// [WHILE-STYLE FOR LOOP] Just condition, no init or post
	// [SYNTAX] for condition { body }
	// [USAGE] When you don't know iteration count beforehand
	
	count := 0  // Initialize counter
	for count < 3 {
		// [MANUAL INCREMENT] Must increment inside loop
		count++
	}

	// [INFINITE FOR LOOP] No condition at all
	// [SYNTAX] for { body }
	// [EXECUTION] Runs forever unless you use break
	
	shouldBreak := true  // Control variable
	for {
		// [BREAK STATEMENT] Exits the loop
		// [PURPOSE] Only way to exit infinite loop
		if shouldBreak {
			break
		}
	}

	// [RANGE LOOP OVER SLICE] Iterating over a list/collection
	// [SYNTAX] for index, value := range collection { ... }
	// [INDEX] Position in the collection (starts at 0)
	// [VALUE] The actual element at that position
	
	items := []string{"apple", "banana", "cherry"}  // List of strings
	for idx, item := range items {
		// [ITERATION 1] idx=0, item="apple"
		// [ITERATION 2] idx=1, item="banana"
		// [ITERATION 3] idx=2, item="cherry"
		_ = idx
		_ = item
	}

	// [RANGE LOOP OVER MAP] Iterating over key-value pairs
	// [SYNTAX] for key, value := range map { ... }
	// [ORDER] Random! Map iteration order is intentionally shuffled
	// [WHY RANDOM] Prevents code depending on order (which would break on other computers)
	
	scores := map[string]int{"Alice": 90, "Bob": 85}  // Map of names to scores
	for name, score := range scores {
		// [NAME] The key (e.g., "Alice")
		// [SCORE] The value (e.g., 90)
		_ = name
		_ = score
	}

	// [DISCARDING RANGE VALUES] Sometimes you only need one part
	// [SYNTAX] for _, value := range collection (underscore ignores index)
	// [WHY UNDERSCORE] Go compiler warns about unused variables
	
	for _, val := range items {
		// [UNDERSCORE] Means "I don't care about the index"
		_ = val
	}

	// [DEFER STATEMENT] "Run this code when the function exits"
	// [SYNTAX] defer statement
	// [KEY PROPERTY] LIFO - Last In, First Out (like a stack)
	// [USE CASE] Cleanup code (close files, release locks, etc.)
	
	// [DEFER 1] This will run 3rd (when function returns)
	defer fmt.Println("Third (deferred last)")
	
	// [DEFER 2] This will run 2nd (after defer above but before function exit)
	defer fmt.Println("Second (deferred middle)")
	
	// [IMMEDIATE EXECUTION] This runs immediately (1st)
	fmt.Println("First (immediate)")
	
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
func DemonstratePointerBasics() {
	// [VARIABLE DECLARATION] Declare a pointer to int
	// [SYNTAX] var ptr *int
	// [MEANING] ptr can hold the ADDRESS of an int
	// [ZERO VALUE] nil (null/nothing)
	// [VISUAL] ptr: [nil]  (not pointing anywhere yet)
	var ptr *int        // Pointer to int; zero value is nil
	
	// [CREATE A VALUE] Create an int variable with value 42
	// [VISUAL] value: [42]
	value := 42
	
	// [ADDRESS-OF OPERATOR] & gets the address of a variable
	// [SYNTAX] &variable gives you the address
	// [RESULT] ptr now points to value
	// [VISUAL] value: [42], ptr: [pointing to value]
	ptr = &value        // & means "address of value"

	// [DEREFERENCE OPERATOR] * accesses the value a pointer points to
	// [SYNTAX] *pointer gives you the value at that address
	// [RESULT] derefValue gets the value at the address ptr points to
	// [VISUAL] We look through ptr to find value, which is 42
	derefValue := *ptr  // derefValue = 42
	_ = derefValue

	// [NIL POINTER DANGER] Accessing nil pointer causes panic (crash)
	// [WHAT IS NIL] Like null in other languages - "points to nothing"
	
	var nilPtr *int  // Declared but not initialized - is nil
	// [SAFETY CHECK] ALWAYS check before dereferencing
	// [IF CHECK] "if nilPtr is not nil"
	if nilPtr != nil {
		// [SAFE DEREFERENCE] Only executed if nilPtr is not nil
		_ = *nilPtr // Safe: only executed if nilPtr is not nil
	}

	// [PASS BY VALUE] Regular variable copying
	original := 10       // Variable with value 10
	byValue := original  // Create a COPY of original
	byValue = 20         // Change the copy
	_ = original         // Still 10 (unaffected)
}

// [HELPER FUNCTION] Receives a pointer and modifies the original
// [PARAMETER] *int - this function expects a pointer to int
// [MODIFICATION] Changes affect the original variable
func modifyByPointer(ptr *int) {
	// [DEREFERENCE AND ASSIGN] *ptr = 100
	// [MEANING] "Go to the address ptr points to, and store 100 there"
	// [EFFECT] Original variable's value changes!
	*ptr = 100
}

// [FUNCTION] Shows memory allocation with new() and make()
// [BIG CONCEPT] Some data lives on stack (automatic cleanup), some on heap (garbage collected)
func DemonstrateMemoryAllocation() {
	// [NEW BUILTIN] Allocates memory, returns a pointer
	// [SYNTAX] new(Type)
	// [WHAT IT DOES] Allocates zeroed memory, returns pointer to it
	// [RESULT TYPE] *int (pointer to int)
	
	// [ALLOCATION] new(int) allocates int sized memory (value initialized to 0)
	intPtr := new(int)        // Allocates int (value=0), returns *int
	
	// [DEREFERENCE AND ASSIGN] Dereference the pointer and assign new value
	*intPtr = 42              // Dereference and assign
	
	// [MAKE BUILTIN] Allocates and initializes slices, maps, and channels
	// [WHY NEW AND MAKE] Two different allocation strategies for different types
	// [SYNTAX] make(Type, size, capacity) for slices
	
	// [MAKE SLICE] Creates a dynamic array (list)
	// [LENGTH] 5 - currently has 5 elements (all zero-valued)
	// [CAPACITY] 10 - room for up to 10 elements before needing reallocation
	slice := make([]int, 5, 10)   // Slice with length 5, capacity 10
	
	// [MAKE MAP] Creates a hash table for key-value pairs
	// [INITIALIZATION] Ready to store data immediately
	myMap := make(map[string]int) // Map (no size pre-allocation)
	
	// [MAKE CHANNEL] Creates a communication pipe between goroutines
	// [CAPACITY] 5 - can hold up to 5 messages before sender blocks
	myChan := make(chan int, 5)   // Buffered channel with capacity 5

	// [STACK ALLOCATION] Local variables are allocated on the stack
	// [EFFICIENCY] Very fast, automatic cleanup when scope ends
	// [LIMITATION] Size must be known at compile time
	
	stackVar := 100 // Allocated on stack
	_ = stackVar    // No need to manually free - cleaned up automatically

	// [HEAP ALLOCATION] Data lives longer than the function
	// [GARBAGE COLLECTION] Go automatically frees memory when no longer needed
	// [EFFICIENCY] Slower than stack but allows dynamic data
	
	heapPtr := new(string) // Allocated on heap, survives function return
	*heapPtr = "heap-allocated"

	// [PREVENT UNUSED WARNINGS]
	_ = intPtr
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
func DemonstrateArrays() {
	// [ARRAY DECLARATION] Fixed size array of ints
	// [SYNTAX] var arr [5]int
	// [SIZE] 5 - can always hold exactly 5 elements
	// [ZERO VALUES] All elements start as 0
	// [VISUAL] arr: [0, 0, 0, 0, 0]
	
	var arr [5]int           // Array of 5 ints, zero-initialized to [0,0,0,0,0]
	
	// [ARRAY INDEXING] Access element at position 0 (first element)
	// [SYNTAX] arr[index] = value
	// [ZERO-INDEXED] First element is at index 0, not 1
	arr[0] = 10
	
	// [ANOTHER ASSIGNMENT] Element at index 4 (last element in 5-element array)
	arr[4] = 50

	// [ARRAY COPYING] When you assign an array, the whole thing is copied
	// [RESULT] original and copy are independent
	// [PERFORMANCE NOTE] Copying large arrays is slow; use slices instead
	
	original := [3]int{1, 2, 3}  // Array literal with values [1,2,3]
	copy := original             // Entire array is copied
	copy[0] = 999                // Change the copy
	_ = original                 // Still [1, 2, 3] - original unchanged!

	// [ARRAY ITERATION] Loop over array elements
	for idx, val := range arr {
		// [IDX] Position: 0, 1, 2, 3, 4
		// [VAL] Value: arr[idx]
		_ = idx
		_ = val
	}
	_ = copy
}

// [TYPE] SliceAnatomy shows internal structure (conceptual, not directly accessible)
// [WHAT IS UNSAFE] The unsafe package is dangerous; used here just to show structure
type SliceAnatomy struct {
	// [FIELD] Pointer to the first element in the underlying array
	// [UNSAFE.POINTER] Generic pointer type (avoid in real code!)
	ptr unsafe.Pointer // Points to first element in backing array
	
	// [FIELD] Number of elements currently in the slice
	// [RANGE] Can access indices 0 to length-1
	length int            // Number of usable elements
	
	// [FIELD] Total elements allocated (may be more than length)
	// [GROWTH] When appending, if length reaches capacity, a new array is allocated
	capacity int            // Total allocated elements in backing array
}

// [FUNCTION] Demonstrates slices - dynamic-size views over arrays
// [KEY POINT] Slices are flexible like lists; arrays are fixed like in C
func DemonstrateSlices() {
	// [SLICE LITERAL] Create a slice with initial values
	// [SYNTAX] []Type{values...} (no size in brackets!)
	// [RESULT] Length=5 (number of elements), Capacity=5 (room allocated)
	
	slice := []int{1, 2, 3, 4, 5} // Length=5, capacity=5

	// [SLICE INDEXING] Get first element (like arrays)
	firstElem := slice[0]       // 1
	
	// [BUILT-IN LEN] Get the length (number of elements)
	length := len(slice)        // 5
	
	// [BUILT-IN CAP] Get the capacity (room before reallocation needed)
	capacity := cap(slice)      // 5

	// [APPEND BUILTIN] Add elements to end of slice
	// [SYNTAX] slice = append(slice, elements...)
	// [KEY POINT] append returns a new slice (might reallocate)
	// [WARNING] Must assign back: slice = append(slice, ...)
	
	slice = append(slice, 6, 7) // May reallocate if capacity exceeded

	// [APPEND AND GROWTH] Go uses smart growth strategy
	// [STRATEGY] For small slices, double capacity (2x); for large, grow ~25% (1.25x)
	// [BENEFIT] Amortizes reallocation cost over time
	
	var dynamicSlice []int  // Start with empty slice
	for i := 0; i < 100; i++ {
		dynamicSlice = append(dynamicSlice, i)
		// Capacity grows logarithmically, not linearly
	}

	// [COPY BUILTIN] Copy elements from source to destination
	// [SYNTAX] copy(destination, source)
	// [RETURNS] Number of elements copied
	// [KEY DIFFERENCE] copy() does NOT grow destination; copies min(len(src), len(dst))
	
	dest := make([]int, len(slice))  // Pre-allocate destination
	copied := copy(dest, slice)      // Returns number of elements copied
	_ = copied

	// [SLICE SHARING DANGER] Multiple slices can point to the same underlying array
	// [CONSEQUENCE] Changing one affects the other!
	// [SOLUTION] Use copy() to get independent data
	
	slice1 := []int{1, 2, 3}  // Create slice
	slice2 := slice1          // slice2 shares backing array with slice1
	slice2[0] = 999           // MUTATES THE SHARED UNDERLYING ARRAY!
	_ = slice1                // [999, 2, 3] -- affected by slice2's mutation!

	// [SLICE RESLICING] Create a new view of the same underlying array
	// [SYNTAX] slice[low:high]
	// [RANGE] Includes low, excludes high (like in Python)
	// [RESULT] New slice, same underlying array
	
	original := []int{0, 1, 2, 3, 4, 5}  // Original slice
	resliced := original[2:5]             // Elements at indices 2, 3, 4 (not 5)
	resliced[0] = 999                     // Changes original[2]
	_ = original                          // [0, 1, 999, 3, 4, 5] - CHANGED!

	_ = firstElem
	_ = length
	_ = capacity
	_ = dynamicSlice
	_ = dest
}

// [FUNCTION] Demonstrates maps - unordered key-value collections
// [KEY PROPERTY] Maps are reference types (assignments share the same underlying hash table)
// [NOT THREAD-SAFE] Multiple goroutines reading/writing to same map = crash
func DemonstrateMaps() {
	// [MAP CREATION] Create empty map
	// [SYNTAX] make(map[KeyType]ValueType)
	// [RESULT] Empty hash table, ready for inserts
	
	myMap := make(map[string]int) // Empty map, ready for inserts
	
	// [MAP INSERTION] Add key-value pairs
	// [SYNTAX] map[key] = value
	myMap["alice"] = 90  // Key "alice", value 90
	myMap["bob"] = 85    // Key "bob", value 85

	// [COMMA-OK IDIOM] Safe way to get values from map
	// [WHY NEEDED] Map lookup returns value AND whether key exists
	// [SYNTAX] value, ok := map[key]
	// [OK] true if key found, false if missing
	// [VALUE] Actual value if found, zero value if missing
	
	// [LOOKUP 1] Key exists - "alice" is in the map
	score, exists := myMap["alice"] // score=90, exists=true
	
	// [LOOKUP 2] Key missing - "charlie" is not in the map
	missing, found := myMap["charlie"] // missing=0 (zero int value), found=false
	_ = score
	_ = exists
	_ = missing
	_ = found

	// [MAP DELETION] Remove key and value
	// [SYNTAX] delete(map, key)
	// [RESULT] Key no longer in map
	
	delete(myMap, "alice") // Removes key and value

	// [WARNING COMMENT] Explaining why maps aren't thread-safe
	// [DANGER] Concurrent reads and writes cause data corruption and panics
	// [SOLUTION] Use sync.Mutex to protect map access in concurrent code

	// [MAP ITERATION] Loop over all key-value pairs
	// [SYNTAX] for key, value := range map { ... }
	// [ORDER] Random! Iteration order is shuffled each time
	// [WHY RANDOM] Prevents code depending on iteration order
	
	for key, val := range myMap {
		// [KEY] The map key (string in this case)
		// [VAL] The map value (int in this case)
		_ = key
		_ = val
	}
}

// [STRUCT] Groups related data into one composite type
// [FIELDS] Named members with types
// [USE CASE] Represent a real-world entity (User, Product, etc.)
type User struct {
	// [FIELD] ID - unique identifier
	ID int
	
	// [FIELD] Name - user's name
	Name string
	
	// [FIELD] Email - user's email
	Email string
	
	// [FIELD] Age - user's age
	Age int
	
	// [FIELD] CreatedAt - when account was created
	CreatedAt time.Time
}

// [STRUCT] Embedding - one struct contains another
// [PROMOTION] Embedded fields are "promoted" - accessible directly
type Admin struct {
	// [EMBEDDED] User struct (without a field name!)
	// [EFFECT] All User fields become available on Admin
	User      // Embedded User struct (promoted fields)
	
	// [REGULAR FIELD] Whether this user is an admin
	IsAdmin   bool
	
	// [REGULAR FIELD] List of permissions for this admin
	Permissions []string
}

// [FUNCTION] Shows struct creation and access
func DemonstrateStructs() {
	// [STRUCT LITERAL] Create struct with explicit field names
	// [SYNTAX] StructName{ Field1: value1, Field2: value2 }
	// [ADVANTAGE] Clear which value goes in which field
	
	user := User{
		ID:        1,                    // Set ID to 1
		Name:      "Alice",              // Set Name to "Alice"
		Email:     "alice@example.com",  // Set Email
		Age:       28,                   // Set Age
		CreatedAt: time.Now(),           // Set CreatedAt to current time
	}

	// [FIELD ACCESS] Get value from struct field
	// [SYNTAX] structValue.fieldName
	name := user.Name  // Get Name field: "Alice"
	
	// [FIELD MUTATION] Change struct field
	user.Age = 29 // Change Age from 28 to 29

	// [EMBEDDED STRUCT] Create struct with embedded User
	admin := Admin{
		User: User{     // Nested struct initialization
			ID:   2,
			Name: "Bob",
			Age:  35,
		},
		IsAdmin:     true,                        // Set IsAdmin field
		Permissions: []string{"read", "write", "delete"},  // Set permissions
	}
	
	// [PROMOTED FIELD ACCESS] Access embedded field directly
	// [HOW IT WORKS] Admin.Name is automatically forwarded to Admin.User.Name
	adminName := admin.Name      // Promoted field access (goes through embedding)
	adminID := admin.ID          // Same promotion mechanism

	_ = name
	_ = user
	_ = admin
	_ = adminName
	_ = adminID
}

// [STRUCT WITH TAGS] Metadata for fields used by libraries
// [TAGS] Backtick-delimited strings after field type
// [LIBRARIES] encoding/json, database/sql use tags for mapping
type Product struct {
	// [TAG] json:"id" - when converting to JSON, use field name "id"
	ID       int    `json:"id"`
	
	// [TAG] json:"name" - when converting to JSON, use field name "name"
	Name     string `json:"name"`
	
	// [TAG] json:"price,omitempty" - omit field in JSON if zero value (0 or "")
	Price    float64 `json:"price,omitempty"`
	
	// [TAG] json:"-" - completely ignore this field in JSON (never include)
	Internal string `json:"-"`
}

// [FUNCTION] Shows string operations
// [KEY PROPERTY] Strings are immutable - once created, can't change them
// [WHY IMMUTABLE] Enables safe sharing, prevents subtle bugs
func DemonstrateStrings() {
	// [STRING LITERAL] Create string with double quotes
	str := "Hello, Go!"  // Text string
	
	// [BYTE INDEXING] Get byte at position 0
	// [IMPORTANT] Returns byte (0-255), not character
	// [EXAMPLE] 'H' has byte value 72
	firstByte := str[0]      // Indexing returns byte, not rune: 'H' = 72
	
	// [LEN BUILTIN] Get length in BYTES (not characters)
	// [WARNING] For multi-byte UTF-8 chars, len() != number of characters
	// [EXAMPLE] "Ñ" is 1 character but 2 bytes
	length := len(str)       // Length in bytes (not characters)

	// [RANGE ITERATION] Iterate over characters (runes)
	// [KEY DIFFERENCE] range gives runes, not bytes!
	// [IDX] Byte position (not character position)
	// [RUNEVAL] Unicode code point (int32)
	
	for idx, runeVal := range str {
		// [IDX] 0, 5, 6, 7, 8, 9, 10
		// [RUNEVAL] Unicode values of each character
		_ = idx          // Byte index (not character index)
		_ = runeVal      // Unicode code point (int32)
	}

	// [SLOW CONCATENATION] Using += in a loop
	// [PROBLEM] += creates new string each time (O(n^2) complexity!)
	// [EXAMPLE] First iteration: copies 0, adds "x" → copies 1
	//           Second iteration: copies 1, adds "x" → copies 2
	//           ... leads to exponential work
	
	var slowConcat string  // Empty string
	for i := 0; i < 100; i++ {
		slowConcat += "x"  // Inefficient: copies entire string each iteration
	}

	// [EFFICIENT CONCATENATION] Using strings.Builder
	// [HOW IT WORKS] Buffer writes in memory, then convert to string once
	// [PERFORMANCE] O(n) instead of O(n^2)
	
	var builder strings.Builder  // String builder (efficient buffer)
	for i := 0; i < 100; i++ {
		builder.WriteString("x")  // Efficient: buffers each write
	}
	efficientConcat := builder.String() // Single conversion to string

	_ = firstByte
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
func BasicFunction(a int, b int) int {
	// [RETURN] Returns the sum of a and b
	return a + b
}

// [FUNCTION] Returns multiple values
// [WHY USEFUL] Go encourages (result, error) pattern
// [RETURNS] (int, error) - either a result or an error
// [CONVENTION] Error is always last return value
func MultipleReturns(numerator, denominator int) (int, error) {
	// [ERROR CHECK] If denominator is 0, division would fail
	if denominator == 0 {
		// [RETURN ERROR] Return zero value and an error
		// [errors.New()] Creates a basic error message
		return 0, errors.New("division by zero")
	}
	// [SUCCESS CASE] Return the result and nil (no error)
	// [NIL] Means "no error occurred"
	return numerator / denominator, nil
}

// [FUNCTION] Accepts variable number of arguments
// [VARIADIC] ...Type means "zero or more of this type"
// [PARAMETER] nums ...int receives slice of ints
// [USAGE] VariadicFunction(1) or VariadicFunction(1,2,3,4,5) both work
func VariadicFunction(nums ...int) int {
	// [LOOP] Iterate over all arguments
	sum := 0
	for _, num := range nums {
		sum += num
	}
	return sum
}

// [FUNCTION] Demonstrates anonymous functions (closures)
// [ANONYMOUS FUNCTION] Function without a name, assigned to variable
// [CLOSURE] Function capturing variables from enclosing scope
func DemonstrateFunctions() {
	// [ANONYMOUS FUNCTION] Create unnamed function, assign to variable
	// [SYNTAX] add := func(a, b int) int { return a + b }
	// [EXECUTION] add(3, 4) calls the function
	
	add := func(a, b int) int {
		return a + b
	}
	result := add(3, 4) // Call the anonymous function

	// [CLOSURE] Anonymous function that captures external variable
	// [CAPTURE] counter variable is captured by reference
	// [MUTATION] Changes to counter affect the original
	
	counter := 0  // Variable in outer scope
	increment := func() {
		counter++  // Closure captures 'counter' by reference (can modify it)
	}
	increment()    // counter is now 1
	increment()    // counter is now 2
	_ = result
	_ = counter
}

// [METHOD] Function attached to a type (receiver)
// [SYNTAX] func (receiver ReceiverType) MethodName() ReturnType
// [RECEIVER] (u User) - method is "on" User type
// [VALUE RECEIVER] Receives a COPY of the struct
// [MUTATIONS] Don't affect original struct
func (u User) DisplayInfo() string {
	// [METHOD BODY] Can access fields via u.fieldName
	return fmt.Sprintf("%s (%d)", u.Name, u.Age)
}

// [METHOD WITH POINTER RECEIVER] Receives address of struct
// [SYNTAX] func (receiver *ReceiverType) MethodName()
// [POINTER RECEIVER] Receives a POINTER to the struct
// [MUTATIONS] Changes affect the original struct!
func (u *User) IncrementAge() {
	// [NIL CHECK] Ensure pointer is not nil
	if u != nil {
		u.Age++  // Dereference and increment
	}
}

// [STRUCT] Configuration for a server
// [FIELDS] Settings that control server behavior
type ServerConfig struct {
	Host           string        // Server hostname
	Port           int           // Server port
	Timeout        time.Duration // Request timeout
	MaxConnections int           // Max concurrent connections
}

// [TYPE DEFINITION] ServerOption is a function type
// [SYNTAX] type Name func(params) returnType
// [USAGE] Functions that match this signature are ServerOption type
// [PURPOSE] Implements "functional options" pattern
type ServerOption func(*ServerConfig)

// [FUNCTION] Returns a ServerOption that sets the host
// [PATTERN] Factory function - returns a configured function
// [CLOSURE] Inner function captures host parameter
func WithHost(host string) ServerOption {
	return func(cfg *ServerConfig) {
		cfg.Host = host
	}
}

// [FUNCTION] Returns a ServerOption that sets the port
func WithPort(port int) ServerOption {
	return func(cfg *ServerConfig) {
		cfg.Port = port
	}
}

// [FUNCTION] Returns a ServerOption that sets the timeout
func WithTimeout(timeout time.Duration) ServerOption {
	return func(cfg *ServerConfig) {
		cfg.Timeout = timeout
	}
}

// [FUNCTION] Constructor using functional options pattern
// [BENEFITS] Default values, optional parameters, clean API
// [HOW IT WORKS] Take variadic options, apply each one to config
func NewServer(options ...ServerOption) *ServerConfig {
	// [DEFAULT CONFIG] Create with sensible defaults
	cfg := &ServerConfig{
		Host:           "localhost",
		Port:           8080,
		Timeout:        30 * time.Second,
		MaxConnections: 100,
	}
	// [APPLY OPTIONS] Each option function modifies the config
	for _, opt := range options {
		opt(cfg)  // Apply each option
	}
	return cfg
}

// [ANTIPATTERN] Showing what NOT to do with defer in loops
// [PROBLEM] defer stacks up; cleanup doesn't happen until function exits
// [CONSEQUENCE] If loop runs 1000 times, 1000 defers accumulate = memory leak
func DeferInLoopsAntipattern(filePaths []string) {
	// [WRONG PATTERN] Do NOT do this!
	for _, path := range filePaths {
		file, _ := openFile(path) // Hypothetical function
		defer file.Close()        // ACCUMULATES! All defers execute at end
		// If processing 1000 files, 1000 defers stack up = memory leak
	}
}

// [FUNCTION] Correct pattern for deferred cleanup in loops
// [SOLUTION] Wrap loop body in function so each iteration has own defer stack
func DeferInLoopsCorrect(filePaths []string) {
	// [CORRECT PATTERN] Wrap in anonymous function
	for _, path := range filePaths {
		func() {
			file, _ := openFile(path)
			defer file.Close()  // Executes at end of inner function
		}()  // Immediately call the function
	}
}

// [FUNCTION] Helper for opening files (placeholder)
// [RETURN TYPE] io.Closer - anything that has a Close() method
// [INTERFACE] Any type implementing Close() is acceptable
func openFile(path string) (io.Closer, error) {
	return nil, nil
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
type Reader interface {
	Read(p []byte) (n int, err error)
}

// [INTERFACE] Writer - contract for types that can write
type Writer interface {
	Write(p []byte) (n int, err error)
}

// [COMMENT] Mentioning standard library interface
// [io.Reader] Official interface in standard library - same signature

// [INTERFACE] Custom error interface
// [BUILT-IN] Go has built-in error type, but here we show the concept
// [METHOD] Error() returns string description of error
type ErrorInterface interface {
	Error() string
}

// [INTERFACE] Stringer - contract for types with string representation
// [BENEFIT] Let's you customize how types print
// [BUILT-IN] Part of fmt package
type Stringer interface {
	String() string
}

// [METHOD] String() implements Stringer for User type
// [EFFECT] User can be used anywhere Stringer is expected
func (u User) String() string {
	return fmt.Sprintf("User{ID: %d, Name: %s}", u.ID, u.Name)
}

// [FUNCTION] Demonstrates type assertion - extracting concrete type from interface
// [PARAMETER] r interface{} - accepts ANY type
// [TYPE ASSERTION] r.(string) means "treat r as string"
// [DANGER] Panics if r is not actually a string
func DemonstrateTypeAssertion(r interface{}) {
	// [UNSAFE ASSERTION] Direct assertion - panics if wrong type
	// [SYNTAX] value := interfaceValue.(ConcreteType)
	// [IF ASSERTION FAILS] Panic! Program crashes
	strValue := r.(string)  // This will panic if r is not a string
	_ = strValue

	// [SAFE ASSERTION] Using comma-ok idiom
	// [SYNTAX] value, ok := interfaceValue.(ConcreteType)
	// [OK] true if assertion succeeded, false otherwise
	// [NO PANIC] Returns a bool instead of crashing
	if val, ok := r.(string); ok {
		_ = val  // Safe to use val - we know it's a string
	}
}

// [FUNCTION] Type switch - branching on interface type
// [SYNTAX] switch value.(type) { case TypeName: ... }
// [USE CASE] Cleaner than multiple type assertions
func DemonstrateTypeSwitch(value interface{}) {
	// [TYPE SWITCH] Switch based on the concrete type
	// [SYNTAX] switch v := value.(type)
	// [V VARIABLE] v holds the value cast to the matched type
	
	switch v := value.(type) {
	// [CASE STRING] If value is actually a string
	case string:
		fmt.Printf("String: %s\n", v)
	// [CASE INT] If value is actually an int
	case int:
		fmt.Printf("Integer: %d\n", v)
	// [CASE FLOAT64] If value is actually a float64
	case float64:
		fmt.Printf("Float: %f\n", v)
	// [DEFAULT] None of the above types
	default:
		fmt.Printf("Unknown type\n")
	}
}

// [STRUCT] Conceptual representation of interface internals
// [NOT ACCESSIBLE] This structure is internal; can't access directly
// [PURPOSE] Shows how interface values work at runtime
type InterfaceValue struct {
	// Conceptually (not directly accessible):
	// - pointer to type descriptor
	// - pointer to concrete value
}

// [FUNCTION] Demonstrates interface internals
// [KEY CONCEPT] nil interface differs from interface holding nil value
// [PITFALL] Comparing to nil can give surprising results
func DemonstrateNilInterface() {
	// [INTERFACE HOLDING NIL] Create interface with nil *strings.Reader
	// [SYNTAX] (*strings.Reader)(nil) - explicitly create nil of that type
	// [RESULT] Interface is not nil (holds a type), but value is nil
	var reader interface{} = (*strings.Reader)(nil)
	
	// [COMPARISON] Is reader equal to nil?
	if reader == nil {
		// [NOT EXECUTED] This branch doesn't run
		fmt.Println("reader is nil")
	} else {
		// [EXECUTED] This runs because interface has a type descriptor
		fmt.Println("reader is NOT nil (holds a nil *strings.Reader)")
	}
	// Output: reader is NOT nil
	// Reason: interface stores (type, value) pair; type is set even if value is nil
}

// [FUNCTION] Accepts interface, enables flexibility
// [PARAMETER] r Reader - any type implementing Read() works
// [DESIGN PRINCIPLE] Accept interfaces, return concrete types
func ProcessData(r Reader) string {
	// [BENEFIT] Caller can pass File, strings.Reader, or any Reader
	buf := make([]byte, 1024)
	r.Read(buf)
	return string(buf)
}

// [INTERFACE] Embedding other interfaces
// [COMPOSITION] ReadCloser is both Reader and Closer
// [BENEFIT] Smaller interfaces are easier to implement
type ReadCloser interface {
	Reader
	io.Closer  // Embedded interface (brings in Close method)
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
var ErrNotFound = errors.New("resource not found")

// [ANOTHER SENTINEL] Another predefined error
var ErrUnauthorized = errors.New("unauthorized access")

// [CUSTOM ERROR TYPE] Struct implementing error interface
// [BENEFIT] Can attach data to error (not just a message)
type ValidationError struct {
	// [FIELD] Field name that failed validation
	Field   string
	
	// [FIELD] Error message
	Message string
}

// [METHOD] Makes ValidationError implement error interface
// [SYNTAX] Any type with Error() string method is an error
func (e ValidationError) Error() string {
	return fmt.Sprintf("validation error on field '%s': %s", e.Field, e.Message)
}

// [FUNCTION] Shows idiomatic error checking
// [PATTERN] if err != nil { return err } (check immediately after operation)
func idiomatic_if_err_not_nil() error {
	// [WHY CHECK IMMEDIATELY] Early detection prevents bad state propagating
	// [PATTERN] if err != nil { return err } - bubble up the error
	
	data := "42"
	num, err := parseNumber(data)
	if err != nil {
		// [ERROR CASE] Propagate error up the call stack
		return err
	}
	// [SUCCESS CASE] Continue with num
	_ = num
	return nil
}

// [HELPER FUNCTION] Parse string to number
func parseNumber(s string) (int, error) {
	// [CHECK INPUT] Guard clause - validate input
	if len(s) == 0 {
		return 0, errors.New("empty string")
	}
	return 42, nil
}

// [FUNCTION] Demonstrates error wrapping (Go 1.13+)
// [WRAPPING] Preserve error chain while adding context
// [BENEFIT] errors.Is() and errors.As() can unwrap
func DemonstrateErrorWrapping() error {
	// [UNDERLYING ERROR] Original error
	underlying := errors.New("database connection failed")
	
	// [WRAPPING ERROR] Add context while preserving original
	// [%w VERB] Wraps error (enables Is/As unwrapping)
	wrapped := fmt.Errorf("failed to fetch user: %w", underlying)
	
	// [errors.Is()] Check if error or any wrapped error equals target
	// [USE CASE] Generic error handling without type assertion
	if errors.Is(wrapped, underlying) {
		fmt.Println("Found underlying error")
	}

	// [errors.As()] Unwrap until finding specific type
	// [USE CASE] Handle specific error types with type-specific logic
	var valErr ValidationError
	if errors.As(wrapped, &valErr) {
		// [FOUND] valErr holds the ValidationError from wrapped chain
		fmt.Printf("Validation error: %s\n", valErr.Field)
	}

	return wrapped
}

// [FUNCTION] Guard clauses reduce nesting
// [PATTERN] Return early on error conditions
// [BENEFIT] Happy path is at bottom, not deeply nested
func DemonstrateEarlyReturns(age, income int) string {
	// [GUARD 1] Check first precondition, return early if fails
	// [BENEFIT] Avoids nested if/else hell
	if age < 18 {
		return "Must be 18 or older"
	}

	// [GUARD 2] Check another precondition
	if income < 20000 {
		return "Income must be at least 20000"
	}

	// [HAPPY PATH] All guards passed, do actual work
	return "Approved"
}

// [FUNCTION] Production error logging pattern
// [PRACTICE] Include request ID, user ID, error details, stack trace
// [BENEFIT] Makes debugging failures in production possible
func ProductionErrorLogging(requestID string, err error) {
	// [IF CHECK] Only log if there's an error
	if err != nil {
		// [FORMATTED OUTPUT] Print context-rich error info
		fmt.Printf(
			"[ERROR] RequestID: %s | Error: %v | Type: %T\n",
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
func DemonstrateGoroutines() {
	// [GO KEYWORD] Launch goroutine (non-blocking)
	// [SYNTAX] go functionCall()
	// [EXECUTION] Runs concurrently with rest of function
	// [RETURNS IMMEDIATELY] Doesn't wait for goroutine to finish
	go func() {
		fmt.Println("Running in a goroutine")
	}()

	// [PROBLEM] main() might exit before goroutine runs
	// [CONSEQUENCE] Goroutine gets killed when main exits
	// [SOLUTION] Use channel or WaitGroup to wait
	
	time.Sleep(1 * time.Second)  // Hacky: sleep to wait for goroutine
}

// [FUNCTION] Safe goroutine waiting with WaitGroup
// [WAITGROUP] Counter-based synchronization primitive
// [HOW IT WORKS] Add() increments counter, Done() decrements, Wait() blocks until 0
func SafeGoroutineWaiting() {
	// [WAITGROUP] Create a WaitGroup
	var wg sync.WaitGroup
	
	// [ADD] Tell WaitGroup to expect 3 goroutines
	wg.Add(3)

	// [LOOP] Launch 3 goroutines
	for i := 1; i <= 3; i++ {
		// [GO] Launch goroutine
		go func(num int) {
			// [DEFER DONE] Ensure Done() runs even if goroutine panics
			defer wg.Done()  // Decrement counter when done
			fmt.Printf("Goroutine %d\n", num)
		}(i)  // Pass i as argument (important! See closure pitfall)
	}

	// [WAIT] Block until all 3 Done() calls complete
	wg.Wait()  // Block until counter reaches 0
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
func DemonstrateUnbufferedChannels() {
	// [MAKE CHANNEL] Create unbuffered channel of ints
	// [BUFFERING] No buffering - send/receive must happen at same time
	ch := make(chan int)  // Unbuffered channel

	// [LAUNCH GOROUTINE] Send value from another goroutine
	go func() {
		// [SEND] ch <- 42 blocks until someone receives
		ch <- 42           // Sends 42; blocks until someone receives
	}()

	// [RECEIVE] Block until value available
	// [RESULT] When goroutine sends, this unblocks and gets 42
	value := <-ch         // Receives 42; unblocks the goroutine
	_ = value
}

// [FUNCTION] Buffered channels - store messages without receiver
// [BUFFERED] Has capacity - send only blocks when buffer full
// [USE CASE] Decoupling senders from receivers
func DemonstrateBufferedChannels() {
	// [MAKE BUFFERED] Create channel with capacity 2
	// [CAPACITY] Can hold 2 values without blocking sender
	ch := make(chan int, 2)  // Buffered channel with capacity 2
	
	// [SEND 1] First send succeeds immediately (buffer not full)
	ch <- 1  // Buffer: [1]
	
	// [SEND 2] Second send succeeds (buffer still has room)
	ch <- 2  // Buffer: [1, 2]
	
	// [SEND 3] Third send would block (buffer is full)
	// (If we tried: ch <- 3, would block until someone receives)
	
	// [RECEIVE] Get values from channel
	v1 := <-ch  // v1 = 1, buffer: [2]
	v2 := <-ch  // v2 = 2, buffer: []
	
	_ = v1
	_ = v2
}

// [FUNCTION] Range over channels - loop until closed
// [IDIOM] for val := range ch processes values until channel closes
// [WHEN TO CLOSE] Sender closes after no more values will be sent
func RangeOverChannels() {
	// [MAKE CHANNEL] Create channel
	ch := make(chan int, 5)

	// [SEND VALUES] Send some integers
	go func() {
		ch <- 1
		ch <- 2
		ch <- 3
		close(ch)  // CLOSE channel (sender closes when done)
	}()

	// [RANGE LOOP] Loops until channel is closed and empty
	for val := range ch {
		// [LOOP] Runs for each value, exits when channel closes
		_ = val
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
func DemonstrateMutex() {
	// [SHARED DATA] Variable accessed by multiple goroutines
	count := 0
	
	// [MUTEX] Lock protecting count
	var mu sync.Mutex
	
	// [GOROUTINE 1] Increments count
	go func() {
		mu.Lock()    // Wait until lock available
		count++      // Now safe to modify count
		mu.Unlock()  // Release lock
	}()
	
	// [GOROUTINE 2] Increments count
	go func() {
		mu.Lock()    // Wait until lock available
		count++      // Now safe to modify count
		mu.Unlock()  // Release lock
	}()
	
	// [WAIT FOR BOTH] Sleep to let goroutines finish
	time.Sleep(100 * time.Millisecond)
	_ = count
}

// [FUNCTION] WaitGroup - coordinating multiple goroutines
// [PATTERN] Add() before launching, Done() when complete, Wait() for all to finish
func DemonstrateWaitGroup() {
	// [WAITGROUP] Synchronization primitive
	var wg sync.WaitGroup
	
	// [ADD] Tell WaitGroup to expect 2 goroutines
	wg.Add(2)

	// [GOROUTINE 1] Do work
	go func() {
		defer wg.Done()  // Mark this goroutine as done
		fmt.Println("Task 1")
	}()

	// [GOROUTINE 2] Do work
	go func() {
		defer wg.Done()  // Mark this goroutine as done
		fmt.Println("Task 2")
	}()

	// [WAIT] Block until both Done() calls made
	wg.Wait()
}

// [FUNCTION] Atomic operations - thread-safe without locks
// [ADVANTAGE] More efficient than mutex for simple counters
// [PACKAGE] sync/atomic provides atomic operations
func DemonstrateAtomics() {
	// [ATOMIC COUNTER] 64-bit integer with atomic operations
	var counter int64
	
	// [ATOMIC ADD] Increment safely without mutex
	// [SYNTAX] atomic.AddInt64(&variable, increment)
	// [RESULT] counter is now 1 (thread-safe)
	atomic.AddInt64(&counter, 1)
	
	// [ATOMIC LOAD] Read value safely
	val := atomic.LoadInt64(&counter)
	_ = val
	
	// [ATOMIC STORE] Write value safely
	atomic.StoreInt64(&counter, 5)
}

// ==============================================================================================
// SEGMENT 10: Advanced Concurrency with Context
// ==============================================================================================
// [CONTEXT] Manages cancellation, timeouts, and request-scoped data
// [USE CASE] Coordinating goroutines, timing out long operations
// [CONVENTION] Context is always the first parameter

// [FUNCTION] Context basics - request-scoped values
func DemonstrateContextBasics() {
	// [CONTEXT.BACKGROUND()] Root context (never cancels)
	// [USE CASE] Starting point for all contexts
	ctx := context.Background()
	_ = ctx
}

// [FUNCTION] Context with timeout - auto-cancel after duration
func DemonstrateContextWithTimeout() error {
	// [WITHCANCEL] Create cancellable context
	// [TIMEOUT] Auto-cancels after 3 seconds
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	
	// [DEFER CANCEL] Always cancel to release resources
	defer cancel()

	_ = ctx
	return nil
}

// [FUNCTION] Context with deadline - absolute time cancellation
func DemonstrateContextWithDeadline() {
	// [DEADLINE] Specify absolute time to stop
	deadline := time.Now().Add(2 * time.Second)
	
	// [WITHDEADLINE] Create context with deadline
	ctx, cancel := context.WithDeadline(context.Background(), deadline)
	defer cancel()

	_ = ctx
}

// [FUNCTION] Cancellation propagation - parent to children
// [HIERARCHY] Child contexts inherit parent's cancellation
func DemonstrateCancellationPropagation() {
	// [PARENT CONTEXT] Create cancellable parent
	parentCtx, parentCancel := context.WithCancel(context.Background())
	defer parentCancel()

	// [CHILD CONTEXT] Derived from parent
	// [INHERITANCE] Canceling parent cascades to child
	childCtx, childCancel := context.WithCancel(parentCtx)
	defer childCancel()

	// [GOROUTINE] Child context waiting for cancellation
	go func() {
		select {
		case <-childCtx.Done():  // Triggered when parent or child cancels
			fmt.Println("Child context canceled (from parent)")
		}
	}()

	// [CANCEL PARENT] Cascades to child
	parentCancel()  // Child automatically receives cancellation
	time.Sleep(100 * time.Millisecond)
}

// [FUNCTION] Context parameter convention - passing through call stack
// [PATTERN] Contexts flow through function calls
func ProcessRequest(ctx context.Context, data string) error {
	// [CHECK CONTEXT] See if already cancelled
	// [Err()] Returns error if context is cancelled
	if err := ctx.Err(); err != nil {
		return err
	}

	// [PASS FORWARD] Share context with downstream functions
	return doWork(ctx, data)
}

// [HELPER FUNCTION] Receiving context
func doWork(ctx context.Context, data string) error {
	// [SELECT] Wait for channel or context cancellation
	select {
	case <-ctx.Done():  // Context cancelled or timed out
		return ctx.Err()  // Return the cancellation error
	default:
		// Do work
		return nil
	}
}

// [TYPE] Context key for storing values
// [PATTERN] Define custom type for keys to avoid collisions
type contextKey string

// [CONSTANT] Key for storing user ID in context
const userIDKey contextKey = "userID"

// [FUNCTION] Context values - passing metadata
// [USE CASE] Request ID, user ID, credentials without changing signatures
func DemonstrateContextValues() {
	// [WITHVALUE] Store data in context
	ctx := context.WithValue(context.Background(), userIDKey, "user-123")

	// [RETRIEVE] Get value from context with type assertion
	if userID, ok := ctx.Value(userIDKey).(string); ok {
		fmt.Printf("User ID: %s\n", userID)
	}
}

// [FUNCTION] Error group - coordinating multiple goroutines with errors
// [BENEFIT] One goroutine error cancels others
func DemonstrateErrGroup() error {
	// [WITHCONTEXT] Create group with shared context
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	// [ERROR CHANNEL] Collect errors from goroutines
	results := make(chan error, 2)

	// [GOROUTINE 1] Do work
	go func() {
		// Simulate work
		results <- nil
	}()

	// [GOROUTINE 2] Do work
	go func() {
		// Simulate work
		results <- nil
	}()

	// [COLLECT ERRORS] Check results from goroutines
	for i := 0; i < 2; i++ {
		if err := <-results; err != nil {
			return err  // Return first error
		}
	}

	_ = ctx
	return nil
}

// [FUNCTION] Worker pool pattern - bounded concurrency
// [BENEFIT] Limits max concurrent operations
// [PATTERN] Fixed number of workers consume jobs from queue
func DemonstrateWorkerPool() {
	// [CONSTANTS] Pool configuration
	numWorkers := 3  // Max 3 workers at a time
	
	// [CHANNELS] Job and result communication
	jobs := make(chan int, 10)      // Queue of jobs (buffered)
	results := make(chan string, 10) // Results from workers
	
	// [WAITGROUP] Track worker completion
	var wg sync.WaitGroup

	// [LAUNCH WORKERS] Create fixed number of workers
	for w := 1; w <= numWorkers; w++ {
		// [ADD] Tell WaitGroup to expect this worker
		wg.Add(1)
		
		// [GOROUTINE] Worker loop
		go func(workerID int) {
			// [DEFER] Mark done when worker exits
			defer wg.Done()
			
			// [RANGE JOBS] Loop until jobs channel closes
			for job := range jobs {
				// [DO WORK] Process job
				result := fmt.Sprintf("Worker %d processed job %d", workerID, job)
				results <- result
			}
		}(w)
	}

	// [JOB PRODUCER] Send jobs to pool
	go func() {
		// [SEND JOBS] Queue 10 jobs
		for i := 1; i <= 10; i++ {
			jobs <- i
		}
		// [CLOSE CHANNEL] Signal no more jobs
		close(jobs)  // Signal workers to stop
	}()

	// [RESULT COLLECTOR] Collect results when all workers done
	go func() {
		// [WAIT] Block until all workers done
		wg.Wait()
		// [CLOSE RESULTS] Signal consumer to stop
		close(results)
	}()

	// [CONSUME RESULTS] Process results
	for result := range results {
		_ = result
	}
}

// [FUNCTION] Prevent goroutine leaks - ensuring goroutines exit
// [DANGER] Goroutines left running consume memory
// [SOLUTION] Use context for graceful shutdown
func DemonstrateGoroutineLeakPrevention() error {
	// [CONTEXT WITH TIMEOUT] Auto-cancel after 2 seconds
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	// [DONE CHANNEL] Signal goroutine completion
	done := make(chan struct{})

	// [GOROUTINE] Exits when context cancels
	go func() {
		// [WAIT FOR CANCELLATION] Block until context cancels
		<-ctx.Done()
		// [SIGNAL DONE] Tell main we exited
		done <- struct{}{}  // Signal completion
	}()

	// [SELECT] Wait for goroutine exit or timeout
	select {
	case <-done:  // Goroutine exited successfully
		return nil
	case <-time.After(5 * time.Second):  // Goroutine didn't exit in time
		return fmt.Errorf("goroutine did not exit")
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


	// [FORMATTED OUTPUT] Section header using fmt.Println
	fmt.Println("========== Segment 1: Go Environment & Development Setup ==========")
	
	// [STRUCT LITERAL] Create BuildArtifact instance
	_ = BuildArtifact{
		BinaryPath: "/usr/local/bin/myapp",  // Binary location
		ModuleName: "github.com/user/myapp", // Module name
		Version:    "1.0.0",                 // Semantic version
		Timestamp:  time.Now(),              // Current time
		IsStatic:   true,                    // Statically linked
	}
	fmt.Println("Build artifact and workspace organization demonstrated.\n")

	fmt.Println("========== Segment 2: Core Language Syntax & Type System ==========")
	// [FUNCTION CALLS] Execute demonstration functions
	DemonstrateVariableDeclaration()  // Show variables
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
	config := NewServer(WithHost("0.0.0.0"), WithPort(8080))
	fmt.Printf("Server config: %v\n", config)
	fmt.Println("Functions, methods, and functional options demonstrated.\n")

	fmt.Println("========== Segment 6: Interfaces & Polymorphism ==========")
	DemonstrateTypeAssertion("hello")  // Show type assertions
	DemonstrateTypeSwitch(42)          // Show type switches
	DemonstrateNilInterface()          // Show interface gotchas
	fmt.Println("Interfaces and polymorphism demonstrated.\n")

	fmt.Println("========== Segment 7: Error Handling Patterns ==========")
	// [ERROR HANDLING] Call function that may return error
	if err := idiomatic_if_err_not_nil(); err != nil {
		fmt.Printf("Error: %v\n", err)
	}
	_ = DemonstrateEarlyReturns(20, 50000)
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
import "unsafe"