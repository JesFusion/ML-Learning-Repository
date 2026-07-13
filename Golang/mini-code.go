
// // 'package' is how Go bundles related code files together into a single unit. 'main' is a special keyword that tells the Go compiler, "Hey, this is the exact starting point of our entire program!"
// package main

// // 'import' lets us borrow built-in tools that other people wrote (kind of like downloading apps on your phone). The '(' opens up our shopping list of tools we want to bring in.
// import (
// 	// The "context" tool helps us manage timeouts, deadlines, and cancel long-running tasks. We're grabbing it to use later.
// 	"context"
// 	// "errors" gives us a standard way to create and manage error messages when things inevitably break.
// 	"errors"
// 	// "fmt" stands for 'format'. It's our go-to, everyday tool for printing text out to the screen.
// 	"fmt"
// 	// "io" stands for input/output. It provides basic blueprints for reading streams of data (like files or network traffic) and writing data.
// 	"io"
// 	// "strings" provides handy utilities for chopping up, searching, or combining pieces of text.
// 	"strings"
// 	// "sync" gives us locks and counters. We use it to safely control traffic when multiple tasks are running at the exact same time.
// 	"sync"
// 	// "sync/atomic" is a sub-tool of sync for extremely fast, low-level, safe math operations.
// 	"sync/atomic"
// 	// "time" lets us check the clock, pause the program, and measure durations.
// 	"time"
// 	// "unsafe" lets us break Go's strict memory safety rules to talk directly to the computer's raw memory. I moved this up here from the bottom of your file because Go strictly requires all imports at the top!
// 	"unsafe"
// // ')' closes our import shopping list.
// )

// // 'type' lets us invent our very own custom blueprint for data. 'BuildArtifact' is the name we chose. 'struct' means it's a container holding a collection of different pieces of data together (like a real-world object). '{' opens the container's blueprint.

// type BuildArtifact struct {
// 	// 'BinaryPath' is the name of our first piece of data. 'string' is a basic type that holds plain text (like a word or sentence).
// 	BinaryPath string // CodeDude: In Go, strings are technically read-only slices of bytes under the hood. You can't change individual letters once set!
// 	// We already know 'string' holds text. Here we add another text container named 'ModuleName'.
// 	ModuleName string // CodeDude: Grouping related data in a struct like this is much cleaner than passing a dozen separate variables around.
// 	// Adding a third text container, this one named 'Version'.
// 	Version string // CodeDude: Text strings are wrapped in double quotes in Go, like "v1.0.0".
// 	// 'Timestamp' is the name. We use the 'time' tool we imported to use its 'Time' blueprint, which holds an exact moment in history (like a digital watch).
// 	Timestamp time.Time // CodeDude: You'll use this constantly for logging when events happen, or measuring how long a function takes to run.
// 	// 'IsStatic' is the name. 'bool' is short for boolean, a type that acts like a light switch—it can only ever hold 'true' or 'false'.
// 	IsStatic bool // CodeDude: Booleans default to 'false' in memory if you create the struct but forget to flip the switch.
// 	// '}' closes the blueprint for our BuildArtifact container.
// } // CodeDude: Closing the blueprint. Think of a struct as a custom LEGO set. You define the pieces here, and build it later!

// // We know 'type' and 'struct'. We're creating another custom container shape named 'WorkspaceLayout'. '{' opens its block.
// type WorkspaceLayout struct {
// 	// Adding a text field named 'CmdDir' to our new struct.
// 	CmdDir string // CodeDude: Struct field names starting with a Capital letter mean they are "Exported" (public)—other packages can see them!
// 	// Adding another text field named 'PkgDir'.
// 	PkgDir string // CodeDude: If you named this 'pkgDir' (lowercase 'p'), it would be private and invisible to outside files.
// 	// Adding a third text field named 'InternalDir'.
// 	InternalDir string // CodeDude: Memory is laid out sequentially for structs, so these strings will sit right next to each other in RAM.
// 	// Adding a fourth text field named 'VendorDir'.
// 	VendorDir string // CodeDude: This structure is commonly used to organize standard Go project folders.
// 	// '}' closes the WorkspaceLayout struct block.
// } // CodeDude: Closing the WorkspaceLayout blueprint.

// // Creating a massive new struct blueprint named 'TypeSystemDemo' to hold examples of every basic data type.
// type TypeSystemDemo struct {
// 	// 'IntValue' is the name. 'int' holds positive or negative whole numbers (like 1, 0, or -5). The computer decides how big it can be based on your operating system.
// 	IntValue int // CodeDude: On a 64-bit computer, this automatically acts exactly like an int64. On an older 32-bit machine, it's an int32.
// 	// 'int8' is a tiny whole number that only takes up 8 bits of memory (it can only hold numbers from -128 to 127).
// 	Int8Value int8 // CodeDude: Great for saving memory if you know the number will never go past 127 (like a volume slider from 0-100).
// 	// 'int32' is a medium whole number taking 32 bits of memory.
// 	Int32Value int32 // CodeDude: This is standard for things like counting loops in many languages (often just called 'int' in Java/C#).
// 	// 'int64' is a massive whole number taking 64 bits of memory.
// 	Int64Value int64 // CodeDude: You'd use this for massive numbers, like counting views on a viral YouTube video or database ID keys.
// 	// 'byte' is exactly what it sounds like: one single byte of data. It's actually just a nickname for a positive-only 8-bit number (0 to 255).
// 	ByteValue byte // CodeDude: Whenever you read a file from your hard drive or download an image, it comes in as a massive slice of these bytes!
// 	// 'uint' means Unsigned Integer. "Unsigned" is math-speak for "no negative signs allowed". It only holds positive whole numbers and zero.
// 	UintValue uint // CodeDude: Perfect for things that logically can never be negative, like someone's physical age or a file size.
// 	// 'uint64' is a massive positive-only whole number taking 64 bits of memory.
// 	UintValue64 uint64 // CodeDude: The absolute biggest positive whole number you can natively store in standard Go (up to ~18 quintillion!).

// 	// 'float32' holds numbers with decimal points (like 3.14). The '32' means it uses 32 bits of memory.
// 	Float32Value float32 // CodeDude: Uses less memory, but can lose precision on super long decimals (rounding errors).
// 	// 'float64' is a bigger, more precise decimal number taking 64 bits. This is the default decimal type in Go.
// 	Float64Value float64 // CodeDude: Always default to float64 for math to avoid weird decimal bugs, unless you are strictly optimizing 3D game engines!

// 	// We know 'bool' acts like a true/false light switch. This creates a switch named 'BoolValue'.
// 	BoolValue bool // CodeDude: The workhorse of decision-making. Usually generated by asking questions like "is 5 > 3?".
// 	// Creating a text container named 'StringValue'.
// 	StringValue string // CodeDude: Go handles emojis and foreign alphabets beautifully right out of the box thanks to built-in UTF-8 encoding.

// 	// 'rune' is Go's special nickname for a single character or letter (like 'A' or an emoji like '😎'). Behind the scenes, it's just an int32 number representing a code.
// 	RuneValue rune // CodeDude: Think of 'rune' as a single Unicode character. 'A' is stored as the number 65, 'B' is 66, and so on.
// 	// Closing the TypeSystemDemo struct blueprint.
// } // CodeDude: End of the massive type demo blueprint!

// // 'func' creates a reusable block of action (a function or a recipe). 'DemonstrateVariableDeclaration' is the name we gave it. '()' holds inputs we want to pass in (it's empty because we don't need any). '{' opens the recipe's steps.
// func DemonstrateVariableDeclaration() { // CodeDude: Functions encapsulate logic. When called, everything inside this block executes top-to-bottom.
// 	// 'var' creates a new variable (a storage box). 'age' is the box's name. 'int' means it holds whole numbers. '=' assigns a value. '25' is the number we put inside.
// 	var age int = 25 // CodeDude: This is the explicit, formal way to declare variables. It's safe, extremely readable, but a bit wordy.
// 	// We know 'var', 'string', and '='. Here we create a text box named 'name' and put "Alice" inside.
// 	var name string = "Alice" // CodeDude: The Go compiler is smart enough to know "Alice" is text, so typing 'string' is technically optional here.

// 	// Creating a decimal box named 'balance'. Since we didn't use '=' to put anything inside, Go automatically puts a '0.0' in it. Go never leaves boxes empty!
// 	var balance float64 // CodeDude: This automatic filling is called the "zero value". It zeroes out memory for safety, unlike older languages like C where memory stays filled with random garbage!
// 	// Creating a true/false box named 'isActive'. Because we didn't set it, Go defaults it to 'false'.
// 	var isActive bool // CodeDude: If you need a switch to start off 'true', you HAVE to assign it yourself.
// 	// Creating a text box named 'username'. Since we didn't set it, Go defaults to an empty string "".
// 	var username string // CodeDude: Note that an empty string "" is totally different from 'nil' (nothingness). It still takes up a tiny bit of memory!
// 	// Creating a whole number box named 'count'. Go defaults it to 0.
// 	var count int // CodeDude: This zero-value trick is amazing for loops—you don't have to manually write 'count = 0' to start!
// 	// '*' before a type means it's a "pointer"—it doesn't hold the data itself, but rather the memory address (like a treasure map) of where an 'int' lives. Since we didn't set it, Go defaults to 'nil' (a blank map).
// 	var ptr *int // CodeDude: Pointers are powerful! They let you share the exact same data box across different functions instead of making heavy copies of data.

// 	// ':=' is a super handy shortcut! It creates a box AND fills it at the same time without needing the 'var' keyword or the type. Go just guesses the type based on what we put in. Here, it sees text, so it makes 'message' a string box holding "Hello, Go!".
// 	message := "Hello, Go!" // CodeDude: ':=' is called a "short variable declaration". It is the most common way to make variables inside functions. It's fast to type!
// 	// Using the ':=' shortcut again. Go sees a whole number, so it makes 'value' an int holding 42.
// 	value := 42 // CodeDude: Go assumes you want a standard 'int' (not int8 or int32) when you hand it a whole number like this.
// 	// Using the ':=' shortcut. Go sees a decimal, so it makes 'pi' a float64 holding 3.14159.
// 	pi := 3.14159 // CodeDude: Go defaults to 'float64' for raw decimals because precision is usually more important than saving a few bytes of memory.

// 	// 'const' creates a constant—a special box whose value can NEVER be changed once it's set (it's carved in stone). Here we lock the name 'MaxRetries' to the number 3.
// 	const MaxRetries = 3 // CodeDude: Constants are created at "compile time" (when you build the app), making them incredibly fast and memory-efficient.
// 	// Locking the name 'APITimeout' to a mathematical calculation. '30' is multiplied by 'time.Second' (a built-in duration from our time tool) to equal 30 seconds.
// 	const APITimeout = 30 * time.Second // CodeDude: 'time.Second' is actually just a massive int64 number secretly representing 1 billion nanoseconds!
// 	// Creating a stone-carved decimal constant named 'PI' holding 3.14159265359.
// 	const PI = 3.14159265359 // CodeDude: Since we didn't give it a type, this is an "untyped constant". It freely adapts into float32 or float64 depending on how you use it later.

// 	// Using ':=' to create 'defaultInt' and fill it with 10. Go infers it's an int.
// 	defaultInt := 10 // CodeDude: The ':=' shortcut ONLY works inside functions. If you want a variable hanging out at the top of the file, you must use 'var'.
// 	// Using ':=' to create 'defaultFloat' and fill it with 10.5. Go infers it's a float64.
// 	defaultFloat := 10.5 // CodeDude: This inference engine is what makes Go feel like a dynamically typed language (like Python), while keeping the safety of strict types!
// 	// Using ':=' to create 'defaultString' and fill it with "text". Go infers it's a string.
// 	defaultString := "text" // CodeDude: Simple, fast, and clean string allocation.
// 	// Single quotes '' around a letter tells Go this is a single character. We use ':=' to save 'A' into 'defaultRune'. Go infers it's a rune.
// 	defaultRune := 'A' // CodeDude: Pay close attention to the quotes! 'A' (single) is a number/rune. "A" (double) is a string. Big difference in Go!
// 	// '1 + 2i' is complex math (real and imaginary parts). We use ':=' to store it in 'defaultComplex'. Go infers it's a 'complex128' type.
// 	defaultComplex := 1 + 2i // CodeDude: Go has built-in support for complex numbers right out of the box, which is a rare treat for mathematicians and engineers!

// 	// Creating a standard whole number box named 'intVal' and setting it to 100.
// 	var intVal int = 100 // CodeDude: Setting up a test dummy for our type-conversion experiments below.
// 	// 'float64()' acts as a conversion machine. We toss our 'intVal' inside, and it spits out a decimal version. We save that into 'floatVal' using ':='.
// 	floatVal := float64(intVal) // CodeDude: Go requires EXPLICIT conversions. It will NEVER secretly convert an int to a float behind your back. You must command it!
// 	// We're using our 'fmt' tool's 'Sprintf' machine. It formats text behind the scenes without printing it. "%d" is a secret code that means "plug a whole number in right here". We plug in 'intVal' and save the resulting string into 'stringVal'.
// 	stringVal := fmt.Sprintf("%d", intVal) // CodeDude: 'Sprintf' builds a string and holds it in memory, whereas 'Println' shoots it straight to your console screen.

// 	// '_' is a special black hole called the blank identifier. Go gets really mad if we create variables and don't use them, so we assign 'age' to the black hole to quiet the compiler errors.
// 	_ = age // CodeDude: Go enforces strict rules against unused variables to prevent memory leaks and keep your compiled app as small as physically possible.
// 	// Tossing 'name' into the black hole.
// 	_ = name // CodeDude: The compiler literally ignores anything assigned to '_', deleting it from the final compiled app entirely.
// 	// Tossing 'balance' into the black hole.
// 	_ = balance // CodeDude: It's a great tool when you are half-way through writing code and want to test it without the compiler screaming at you.
// 	// Tossing 'isActive' into the black hole.
// 	_ = isActive // CodeDude: Keeping the strict Go compiler perfectly happy!
// 	// Tossing 'username' into the black hole.
// 	_ = username // CodeDude: Into the void it goes.
// 	// Tossing 'count' into the black hole.
// 	_ = count // CodeDude: Goodbye, unused integer!
// 	// Tossing 'ptr' into the black hole.
// 	_ = ptr // CodeDude: Discarding the pointer.
// 	// Tossing 'message' into the black hole.
// 	_ = message // CodeDude: Throwing away our greeting.
// 	// Tossing 'value' into the black hole.
// 	_ = value // CodeDude: Deleting 42.
// 	// Tossing 'pi' into the black hole.
// 	_ = pi // CodeDude: Fun fact: 'math.Pi' is actually built into Go's math package, so you rarely need to type it out manually!
// 	// Tossing 'MaxRetries' into the black hole.
// 	_ = MaxRetries // CodeDude: Even constants will trigger the strict compiler if left unused!
// 	// Tossing 'APITimeout' into the black hole.
// 	_ = APITimeout // CodeDude: Tossing our duration.
// 	// Tossing 'PI' into the black hole.
// 	_ = PI // CodeDude: Yeet the constant.
// 	// Tossing 'defaultInt' into the black hole.
// 	_ = defaultInt // CodeDude: Clearing the deck.
// 	// Tossing 'defaultFloat' into the black hole.
// 	_ = defaultFloat // CodeDude: Clearing more memory.
// 	// Tossing 'defaultString' into the black hole.
// 	_ = defaultString // CodeDude: Bye bye text.
// 	// Tossing 'defaultRune' into the black hole.
// 	_ = defaultRune // CodeDude: Throwing out 'A'.
// 	// Tossing 'defaultComplex' into the black hole.
// 	_ = defaultComplex // CodeDude: Erasing imaginary numbers.
// 	// Tossing 'floatVal' into the black hole.
// 	_ = floatVal // CodeDude: Tossing our converted float.
// 	// Tossing 'stringVal' into the black hole.
// 	_ = stringVal // CodeDude: Tossing our formatted string.
// 	// '}' closes our DemonstrateVariableDeclaration function's recipe block.
// } // CodeDude: And we're done with variables! The garbage collector will now sweep up and delete all this data from RAM since the function is over.

// // Creating a new function named 'DemonstrateOperators' with no inputs. '{' opens the block.
// func DemonstrateOperators() { // CodeDude: Time to do some math and logic operations!
// 	// The ',' comma lets us do two things at once! We are creating two boxes, 'a' and 'b', and using ':=' to put 10 in 'a' and 3 in 'b'.
// 	a, b := 10, 3 // CodeDude: This "multiple assignment" is heavily used in Go, especially when functions return two things at once (like a result and an error code).
// 	// '+' does simple addition. We add 'a' and 'b' and save it in 'sum'.
// 	sum := a + b // CodeDude: Standard arithmetic.
// 	// '-' does subtraction. Saving the result in 'diff'.
// 	diff := a - b // CodeDude: Standard subtraction.
// 	// '*' does multiplication. Saving the result in 'product'.
// 	product := a * b // CodeDude: Standard multiplication.
// 	// '/' does division. Since 'a' and 'b' are whole numbers, it chops off any decimals and just gives us the whole number part. Saves in 'quotient'.
// 	quotient := a / b // CodeDude: This is called integer truncation. It rounds towards zero. So 10/3 becomes exactly 3, not 3.333.
// 	// '%' is the modulo operator. It divides the numbers but ONLY gives us the remainder. (10 divided by 3 leaves a remainder of 1). Saves in 'remainder'.
// 	remainder := a % b // CodeDude: Modulo is famously used by programmers to figure out if a number is even or odd (num % 2 == 0 means it's even).

// 	// '>' checks if the left side is strictly bigger than the right side. This answers a true/false question and saves it in 'isGreater'.
// 	isGreater := a > b // CodeDude: Relational operators (>, <, ==) ALWAYS evaluate to a boolean (true or false).
// 	// '==' checks if two things are exactly equal (don't confuse it with '=' which forces a value into a box). Saves true/false in 'isEqual'.
// 	isEqual := a == b // CodeDude: Mixing up '==' (comparison) and '=' (assignment) is a classic rookie bug, watch out!
// 	// '!=' checks if two things are NOT equal. Saves true/false in 'isNotEqual'.
// 	isNotEqual := a != b // CodeDude: The '!' bang character generally means "NOT" or "OPPOSITE" in programming.
// 	// '<=' checks if the left side is less than OR equal to the right side. Saves true/false in 'isLessOrEqual'.
// 	isLessOrEqual := a <= b // CodeDude: Evaluates to true if 'a' is strictly smaller, OR if they are an exact identical match.

// 	// '()' groups things together for math-like order. '&&' means AND (both the left and right side must be true). We check if 'a' is over 18 AND under 100, saving it in 'isAdult'.
// 	isAdult := (a > 18) && (a < 100) // CodeDude: '&&' uses "short-circuit logic". If the left side is false, the computer doesn't even bother wasting time checking the right side!
// 	// '||' means OR (only one side needs to be true). We check if false OR true is true, and save it in 'isWeekend'.
// 	isWeekend := false || true // CodeDude: '||' also short-circuits! If the left side is true, it immediately returns true without checking the right side.
// 	// '!' means NOT (it flips true to false, and false to true). We check if 'a' is greater than 50, then flip that result, saving it in 'isNotValid'.
// 	isNotValid := !(a > 50) // CodeDude: Inverts the result. Since 'a' (10) is NOT greater than 50, the check is false. The '!' flips it, making 'isNotValid' true!

// 	// Creating two new variables 'x' and 'y', filling them with 5 and 3.
// 	x, y := 5, 3 // CodeDude: Time for bit magic! 5 in binary is '0101', and 3 is '0011'. Let's compare their microscopic bits!
// 	// '&' is a bitwise AND. It looks at the microscopic 1s and 0s of the numbers and compares them. We do this to 'x' and 'y' and save it in 'bitwiseAnd'.
// 	bitwiseAnd := x & y // CodeDude: 0101 AND 0011 = 0001 (which is 1 in decimal). Only bits that are '1' in BOTH numbers survive the collision.
// 	// '|' is a bitwise OR. It compares the raw 1s and 0s using OR logic. Saves in 'bitwiseOr'.
// 	bitwiseOr := x | y // CodeDude: 0101 OR 0011 = 0111 (which is 7 in decimal). If a bit is '1' in EITHER number, it survives!
// 	// '^' is a bitwise XOR (exclusive OR). It compares the raw bits. Saves in 'bitwiseXor'.
// 	bitwiseXor := x ^ y // CodeDude: 0101 XOR 0011 = 0110 (which is 6). Bits survive ONLY if they are DIFFERENT in the two numbers. Same bits annihilate!
// 	// '<<' shifts all the microscopic 1s and 0s to the left by 1 space, effectively multiplying the number by 2. Saves in 'leftShift'.
// 	leftShift := x << 1 // CodeDude: Shifting 0101 left becomes 1010 (which is 10). It's a hyper-fast hardware way to multiply by powers of 2!
// 	// '>>' shifts the bits to the right, effectively dividing by 2. Saves in 'rightShift'.
// 	rightShift := x >> 1 // CodeDude: Shifting 0101 right becomes 0010 (which is 2). A hyper-fast hardware division!

// 	// Tossing our addition result into the black hole so Go doesn't complain.
// 	_ = sum // CodeDude: Silencing the unused variable alarm.
// 	// Tossing our subtraction result into the black hole.
// 	_ = diff // CodeDude: Silencing diff.
// 	// Tossing our multiplication result into the black hole.
// 	_ = product // CodeDude: Silencing product.
// 	// Tossing our division result into the black hole.
// 	_ = quotient // CodeDude: Silencing quotient.
// 	// Tossing our remainder result into the black hole.
// 	_ = remainder // CodeDude: Silencing remainder.
// 	// Tossing our greater-than check into the black hole.
// 	_ = isGreater // CodeDude: Blank identifiers everywhere to keep the build succeeding.
// 	// Tossing our equal-to check into the black hole.
// 	_ = isEqual // CodeDude: The compiler strictly enforces hygiene!
// 	// Tossing our not-equal check into the black hole.
// 	_ = isNotEqual // CodeDude: Dumping into the void.
// 	// Tossing our less-than-or-equal check into the black hole.
// 	_ = isLessOrEqual // CodeDude: Voiding it out.
// 	// Tossing our AND logic check into the black hole.
// 	_ = isAdult // CodeDude: Voiding the boolean.
// 	// Tossing our OR logic check into the black hole.
// 	_ = isWeekend // CodeDude: Voiding the weekend check.
// 	// Tossing our NOT logic check into the black hole.
// 	_ = isNotValid // CodeDude: Voiding the validity check.
// 	// Tossing our bitwise AND result into the black hole.
// 	_ = bitwiseAnd // CodeDude: Deleting our bit magic.
// 	// Tossing our bitwise OR result into the black hole.
// 	_ = bitwiseOr // CodeDude: Deleting more bit magic.
// 	// Tossing our bitwise XOR result into the black hole.
// 	_ = bitwiseXor // CodeDude: Erasing the XOR result.
// 	// Tossing our left shift result into the black hole.
// 	_ = leftShift // CodeDude: Scrubbing the left shift.
// 	// Tossing our right shift result into the black hole.
// 	_ = rightShift // CodeDude: Scrubbing the right shift.
// 	// Closing the DemonstrateOperators function.
// } // CodeDude: End of math operations! Memory is cleaned up automatically by Go's Garbage Collector.

// // Creating a new function named 'DemonstrateControlFlow'. '{' opens the block.
// func DemonstrateControlFlow() { // CodeDude: Control flow dictates the roadmap your program takes based on dynamic data!
// 	// Creating a variable 'age' and setting it to 25.
// 	age := 25 // CodeDude: Setting up a test subject to pass through our logic gates.
// 	// 'if' makes a decision. '>=' means greater than or equal to. We check if 'age' is 18 or older, and '{' opens the block of code to run ONLY if that's true.
// 	if age >= 18 { // CodeDude: Notice there are no parentheses around the condition like in Java or C? Go drops them to keep the code visually clean!
// 		// Using our 'fmt' tool's 'Println' machine. It prints the text "Adult" to the screen and automatically drops down to a new line.
// 		fmt.Println("Adult") // CodeDude: 'Println' handles adding the invisible newline character ('\n') for us automatically.
// 		// '} else if' means "if the first check was false, try this brand new check instead". We check if 'age' is 13 or older, opening a new block.
// 	} else if age >= 13 { // CodeDude: The 'else if' MUST start on the exact same line as the closing bracket '}'. The compiler will literally crash if you put it on a new line!
// 		// Printing "Teen" if they are between 13 and 17.
// 		fmt.Println("Teen") // CodeDude: Executes only if the >= 18 check above failed, but this >= 13 check passes.
// 		// '} else' means "if absolutely all the other checks failed, just run this fallback code". Opens the final block.
// 	} else { // CodeDude: The absolute final fallback safety net.
// 		// Printing "Child" as our fallback.
// 		fmt.Println("Child") // CodeDude: If nothing above was true, this code is guaranteed to run.
// 		// Closing the entire if/else chain block.
// 	} // CodeDude: Exiting the if/else decision tree.

// 	// Creating a variable 'day' holding the text "Monday".
// 	day := "Monday" // CodeDude: Setting up a string for our switch statement test.
// 	// 'switch' is a much cleaner way to write many 'if' checks against a single thing. We tell it to inspect the 'day' variable. '{' opens the switch block.
// 	switch day { // CodeDude: Switches in Go are safer than in C/C++; they automatically stop after a match. They DON'T accidentally fall through to the next case!
// 	// 'case' provides a specific matching scenario for the switch. ':' marks the end of the scenario. If 'day' perfectly matches "Monday", "Tuesday", OR "Wednesday", we do what follows.
// 	case "Monday", "Tuesday", "Wednesday": // CodeDude: You can neatly stack multiple conditions on a single line separated by commas.
// 		// Printing "Weekday" if one of the cases matched.
// 		fmt.Println("Weekday") // CodeDude: Once this runs, the switch instantly exits. No need to manually type 'break' like in older languages!
// 		// Giving the switch another scenario: if 'day' is "Saturday" or "Sunday".
// 	case "Saturday", "Sunday": // CodeDude: Our weekend checker.
// 		// Printing "Weekend".
// 		fmt.Println("Weekend") // CodeDude: Yay, weekend logic!
// 		// 'default' is the switch's version of 'else'. If none of the cases above matched, we run this.
// 	default: // CodeDude: The catch-all bucket. If 'day' was accidentally set to "Pizza", it would hit this bucket.
// 		// Printing "Unknown".
// 		fmt.Println("Unknown") // CodeDude: Good place to put error handling or fallback logic.
// 		// Closing the switch block.
// 	} // CodeDude: Ending the switch.

// 	// Creating a variable 'score' and setting it to 85.
// 	score := 85 // CodeDude: Test variable for our final switch style.
// 	// We can use 'switch' completely empty! It acts like a giant, super clean 'if/else' chain where each case is its own true/false math check.
// 	switch { // CodeDude: A tagless switch! It evaluates each case top-to-bottom. The first one that results in 'true' wins.
// 	// Our first true/false scenario: is the score 90 or higher?
// 	case score >= 90: // CodeDude: Math logic right inside the case line!
// 		// Printing "Grade A".
// 		fmt.Println("Grade A") // CodeDude: Top marks, but skipped because 85 is not >= 90.
// 		// Our second scenario: is the score 80 or higher?
// 	case score >= 80: // CodeDude: This gets evaluated next since the one above failed.
// 		// Printing "Grade B".
// 		fmt.Println("Grade B") // CodeDude: This will print since 85 >= 80 is TRUE!
// 		// Our fallback scenario if all the above score checks failed.
// 	default: // CodeDude: Our ultimate fallback.
// 		// Printing "Below B".
// 		fmt.Println("Below B") // CodeDude: Study harder logic!
// 		// Closing the empty switch block.
// 	} // CodeDude: Ending the tagless switch.

// 	// 'for' creates a loop (a way to repeat actions). This line has three parts separated by ';'. First, we set 'i' to 0. Second, we say "keep looping as long as 'i' is less than 5". Third, 'i++' means "add 1 to 'i' at the end of every loop". '{' opens the loop block.
// 	for i := 0; i < 5; i++ { // CodeDude: This is the classic 3-part C-style for loop: Initialize, Condition check, Post-loop action.
// 		// We aren't actually doing anything in this loop, so we throw 'i' into the black hole so Go doesn't yell at us.
// 		_ = i // CodeDude: The loop runs 5 times (0, 1, 2, 3, 4). On the 6th try, 'i' is 5, the condition fails, and the loop ends!
// 		// Closing the for loop.
// 	} // CodeDude: End of classic for loop.

// 	// Creating a variable 'count' set to 0.
// 	count := 0 // CodeDude: Preparing a variable for a while-style loop.
// 	// We can also use 'for' like a simple while loop. We just give it one rule: "keep looping as long as 'count' is less than 3".
// 	for count < 3 { // CodeDude: Fun fact: Go completely dropped the 'while' keyword! We just use 'for' with a single condition to do the exact same job.
// 		// 'count++' takes the current value of count and adds 1 to it.
// 		count++ // CodeDude: Incrementing the counter inside the loop so we don't accidentally cause an infinite loop!
// 		// Closing the condition-only for loop.
// 	} // CodeDude: End of while-style loop.

// 	// Creating a true/false variable named 'shouldBreak' and setting it to true.
// 	shouldBreak := true // CodeDude: A control flag to trigger our escape hatch.
// 	// A 'for' loop with absolutely no rules will run forever infinitely until we force it to stop.
// 	for { // CodeDude: A completely blank 'for' loop spins forever. Commonly used for web servers waiting for requests or background game loops!
// 		// Checking if 'shouldBreak' is true.
// 		if shouldBreak { // CodeDude: Checking our escape condition.
// 			// 'break' is an emergency exit door. It immediately stops and jumps completely out of the closest loop.
// 			break // CodeDude: BOOM! We rip the ripcord, parachute out of the infinite loop, and land safely on the line just below the loop.
// 			// Closing the if block.
// 		} // CodeDude: End if.
// 		// Closing the infinite for loop.
// 	} // CodeDude: End infinite loop block.

// 	// '[]string' creates a dynamic list (called a slice) of text strings. We use '{...}' to instantly fill it with "apple", "banana", and "cherry", saving it to 'items'.
// 	items := []string{"apple", "banana", "cherry"} // CodeDude: Slices are like arrays, but dynamic—they can grow or shrink as you add/remove data, making them far more flexible!
// 	// 'range' is a special tool that goes through a collection one by one. Each loop, it hands us two things: the position number (saving to 'idx') and the actual text there (saving to 'item').
// 	for idx, item := range items { // CodeDude: 'range' is Go's secret weapon. It cleanly and safely iterates over slices, arrays, maps, and even concurrency channels!
// 		// Tossing the position number into the black hole.
// 		_ = idx // CodeDude: Tossing the position number (0, 1, or 2).
// 		// Tossing the text item into the black hole.
// 		_ = item // CodeDude: Tossing the string text ("apple", "banana", "cherry").
// 		// Closing the range loop.
// 	} // CodeDude: End of slice iteration.

// 	// 'map[string]int' is a dictionary. It maps a text key to a number value. We fill it with two entries: Alice (90) and Bob (85), saving it to 'scores'.
// 	scores := map[string]int{"Alice": 90, "Bob": 85} // CodeDude: Maps act like hash tables. They are incredibly fast for looking up a value if you know the exact key.
// 	// Ranging over a dictionary hands us the text key ('name') and the number value ('score'). Note: Go randomizes the order dictionaries loop in!
// 	for name, score := range scores { // CodeDude: The intentional order scrambling prevents lazy programmers from relying on map order. If you want ordered data, use a slice!
// 		// Tossing the key into the black hole.
// 		_ = name // CodeDude: Tossing "Alice" / "Bob".
// 		// Tossing the value into the black hole.
// 		_ = score // CodeDude: Tossing 90 / 85.
// 		// Closing the dictionary range loop.
// 	} // CodeDude: End of map iteration.

// 	// If we only care about the second thing 'range' hands us (the value), we can put our black hole '_' directly in the first slot where the index usually goes!
// 	for _, val := range items { // CodeDude: Using the blank identifier directly in the 'range' output. Super clean syntax!
// 		// Tossing the value into the black hole.
// 		_ = val // CodeDude: Just grabbing the fruit string and tossing it.
// 		// Closing the range loop.
// 	} // CodeDude: End value-only range.

// 	// 'defer' hits the pause button on an action. It tells Go "Don't run this line right now; wait until the absolute very end of this function, right before we leave, and THEN run it." Think of it like adding a chore to a list you have to do before leaving the house.
// 	defer fmt.Println("Third (deferred last)") // CodeDude: Defers are pushed onto a stack. They execute Last-In-First-Out (LIFO). So this runs absolutely last!
// 	// Adding another chore to the defer list. Note: Defer lists run backwards! The last thing you deferred runs first.
// 	defer fmt.Println("Second (deferred middle)") // CodeDude: Defers are mostly used to safely close files or shut down database connections so you never accidentally forget!
// 	// This line DOES NOT have defer, so it runs immediately right now.
// 	fmt.Println("First (immediate)") // CodeDude: This executes right away because it isn't deferred.
// 	// Closing the DemonstrateControlFlow function.
// } // CodeDude: The function ends here! But wait... RIGHT before we actually exit this bracket, all our deferred functions finally fire off!