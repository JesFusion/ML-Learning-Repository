// 'package' is how Go bundles related code files together into a single unit. 'main' is a special keyword that tells the Go compiler, "Hey, this is the exact starting point of our entire program!"
package main

// 'import' lets us borrow built-in tools that other people wrote (kind of like downloading apps on your phone). The '(' opens up our shopping list of tools we want to bring in.
import (
	// The "context" tool helps us manage timeouts, deadlines, and cancel long-running tasks. We're grabbing it to use later.
	"context"
	// "errors" gives us a standard way to create and manage error messages when things inevitably break.
	"errors"
	// "fmt" stands for 'format'. It's our go-to, everyday tool for printing text out to the screen.
	"fmt"
	// "io" stands for input/output. It provides basic blueprints for reading streams of data (like files or network traffic) and writing data.
	"io"
	// "strings" provides handy utilities for chopping up, searching, or combining pieces of text.
	"strings"
	// "sync" gives us locks and counters. We use it to safely control traffic when multiple tasks are running at the exact same time.
	"sync"
	// "sync/atomic" is a sub-tool of sync for extremely fast, low-level, safe math operations.
	"sync/atomic"
	// "time" lets us check the clock, pause the program, and measure durations.
	"time"
	// "unsafe" lets us break Go's strict memory safety rules to talk directly to the computer's raw memory. I moved this up here from the bottom of your file because Go strictly requires all imports at the top!
	"unsafe"
// ')' closes our import shopping list.
)

// 'type' lets us invent our very own custom blueprint for data. 'BuildArtifact' is the name we chose. 'struct' means it's a container holding a collection of different pieces of data together (like a real-world object). '{' opens the container's blueprint.
type BuildArtifact struct {
	// 'BinaryPath' is the name of our first piece of data. 'string' is a basic type that holds plain text (like a word or sentence).
	BinaryPath string
	// We already know 'string' holds text. Here we add another text container named 'ModuleName'.
	ModuleName string
	// Adding a third text container, this one named 'Version'.
	Version    string
	// 'Timestamp' is the name. We use the 'time' tool we imported to use its 'Time' blueprint, which holds an exact moment in history (like a digital watch).
	Timestamp  time.Time
	// 'IsStatic' is the name. 'bool' is short for boolean, a type that acts like a light switch—it can only ever hold 'true' or 'false'.
	IsStatic   bool
// '}' closes the blueprint for our BuildArtifact container.
}

// We know 'type' and 'struct'. We're creating another custom container shape named 'WorkspaceLayout'. '{' opens its block.
type WorkspaceLayout struct {
	// Adding a text field named 'CmdDir' to our new struct.
	CmdDir      string
	// Adding another text field named 'PkgDir'.
	PkgDir      string
	// Adding a third text field named 'InternalDir'.
	InternalDir string
	// Adding a fourth text field named 'VendorDir'.
	VendorDir   string
// '}' closes the WorkspaceLayout struct block.
}

// Creating a massive new struct blueprint named 'TypeSystemDemo' to hold examples of every basic data type.
type TypeSystemDemo struct {
	// 'IntValue' is the name. 'int' holds positive or negative whole numbers (like 1, 0, or -5). The computer decides how big it can be based on your operating system.
	IntValue      int
	// 'int8' is a tiny whole number that only takes up 8 bits of memory (it can only hold numbers from -128 to 127).
	Int8Value     int8
	// 'int32' is a medium whole number taking 32 bits of memory.
	Int32Value    int32
	// 'int64' is a massive whole number taking 64 bits of memory.
	Int64Value    int64
	// 'byte' is exactly what it sounds like: one single byte of data. It's actually just a nickname for a positive-only 8-bit number (0 to 255).
	ByteValue     byte
	// 'uint' means Unsigned Integer. "Unsigned" is math-speak for "no negative signs allowed". It only holds positive whole numbers and zero.
	UintValue     uint
	// 'uint64' is a massive positive-only whole number taking 64 bits of memory.
	UintValue64   uint64

	// 'float32' holds numbers with decimal points (like 3.14). The '32' means it uses 32 bits of memory.
	Float32Value float32
	// 'float64' is a bigger, more precise decimal number taking 64 bits. This is the default decimal type in Go.
	Float64Value float64

	// We know 'bool' acts like a true/false light switch. This creates a switch named 'BoolValue'.
	BoolValue   bool
	// Creating a text container named 'StringValue'.
	StringValue string

	// 'rune' is Go's special nickname for a single character or letter (like 'A' or an emoji like '😎'). Behind the scenes, it's just an int32 number representing a code.
	RuneValue rune
// Closing the TypeSystemDemo struct blueprint.
}

// 'func' creates a reusable block of action (a function or a recipe). 'DemonstrateVariableDeclaration' is the name we gave it. '()' holds inputs we want to pass in (it's empty because we don't need any). '{' opens the recipe's steps.
func DemonstrateVariableDeclaration() {
	// 'var' creates a new variable (a storage box). 'age' is the box's name. 'int' means it holds whole numbers. '=' assigns a value. '25' is the number we put inside.
	var age int = 25
	// We know 'var', 'string', and '='. Here we create a text box named 'name' and put "Alice" inside.
	var name string = "Alice"

	// Creating a decimal box named 'balance'. Since we didn't use '=' to put anything inside, Go automatically puts a '0.0' in it. Go never leaves boxes empty!
	var balance float64
	// Creating a true/false box named 'isActive'. Because we didn't set it, Go defaults it to 'false'.
	var isActive bool
	// Creating a text box named 'username'. Since we didn't set it, Go defaults to an empty string "".
	var username string
	// Creating a whole number box named 'count'. Go defaults it to 0.
	var count int
	// '*' before a type means it's a "pointer"—it doesn't hold the data itself, but rather the memory address (like a treasure map) of where an 'int' lives. Since we didn't set it, Go defaults to 'nil' (a blank map).
	var ptr *int

	// ':=' is a super handy shortcut! It creates a box AND fills it at the same time without needing the 'var' keyword or the type. Go just guesses the type based on what we put in. Here, it sees text, so it makes 'message' a string box holding "Hello, Go!".
	message := "Hello, Go!"
	// Using the ':=' shortcut again. Go sees a whole number, so it makes 'value' an int holding 42.
	value := 42
	// Using the ':=' shortcut. Go sees a decimal, so it makes 'pi' a float64 holding 3.14159.
	pi := 3.14159

	// 'const' creates a constant—a special box whose value can NEVER be changed once it's set (it's carved in stone). Here we lock the name 'MaxRetries' to the number 3.
	const MaxRetries = 3
	// Locking the name 'APITimeout' to a mathematical calculation. '30' is multiplied by 'time.Second' (a built-in duration from our time tool) to equal 30 seconds.
	const APITimeout = 30 * time.Second
	// Creating a stone-carved decimal constant named 'PI' holding 3.14159265359.
	const PI = 3.14159265359

	// Using ':=' to create 'defaultInt' and fill it with 10. Go infers it's an int.
	defaultInt := 10
	// Using ':=' to create 'defaultFloat' and fill it with 10.5. Go infers it's a float64.
	defaultFloat := 10.5
	// Using ':=' to create 'defaultString' and fill it with "text". Go infers it's a string.
	defaultString := "text"
	// Single quotes '' around a letter tells Go this is a single character. We use ':=' to save 'A' into 'defaultRune'. Go infers it's a rune.
	defaultRune := 'A'
	// '1 + 2i' is complex math (real and imaginary parts). We use ':=' to store it in 'defaultComplex'. Go infers it's a 'complex128' type.
	defaultComplex := 1 + 2i

	// Creating a standard whole number box named 'intVal' and setting it to 100.
	var intVal int = 100
	// 'float64()' acts as a conversion machine. We toss our 'intVal' inside, and it spits out a decimal version. We save that into 'floatVal' using ':='.
	floatVal := float64(intVal)
	// We're using our 'fmt' tool's 'Sprintf' machine. It formats text behind the scenes without printing it. "%d" is a secret code that means "plug a whole number in right here". We plug in 'intVal' and save the resulting string into 'stringVal'.
	stringVal := fmt.Sprintf("%d", intVal)

	// '_' is a special black hole called the blank identifier. Go gets really mad if we create variables and don't use them, so we assign 'age' to the black hole to quiet the compiler errors.
	_ = age
	// Tossing 'name' into the black hole.
	_ = name
	// Tossing 'balance' into the black hole.
	_ = balance
	// Tossing 'isActive' into the black hole.
	_ = isActive
	// Tossing 'username' into the black hole.
	_ = username
	// Tossing 'count' into the black hole.
	_ = count
	// Tossing 'ptr' into the black hole.
	_ = ptr
	// Tossing 'message' into the black hole.
	_ = message
	// Tossing 'value' into the black hole.
	_ = value
	// Tossing 'pi' into the black hole.
	_ = pi
	// Tossing 'MaxRetries' into the black hole.
	_ = MaxRetries
	// Tossing 'APITimeout' into the black hole.
	_ = APITimeout
	// Tossing 'PI' into the black hole.
	_ = PI
	// Tossing 'defaultInt' into the black hole.
	_ = defaultInt
	// Tossing 'defaultFloat' into the black hole.
	_ = defaultFloat
	// Tossing 'defaultString' into the black hole.
	_ = defaultString
	// Tossing 'defaultRune' into the black hole.
	_ = defaultRune
	// Tossing 'defaultComplex' into the black hole.
	_ = defaultComplex
	// Tossing 'floatVal' into the black hole.
	_ = floatVal
	// Tossing 'stringVal' into the black hole.
	_ = stringVal
// '}' closes our DemonstrateVariableDeclaration function's recipe block.
}

// Creating a new function named 'DemonstrateOperators' with no inputs. '{' opens the block.
func DemonstrateOperators() {
	// The ',' comma lets us do two things at once! We are creating two boxes, 'a' and 'b', and using ':=' to put 10 in 'a' and 3 in 'b'.
	a, b := 10, 3
	// '+' does simple addition. We add 'a' and 'b' and save it in 'sum'.
	sum := a + b
	// '-' does subtraction. Saving the result in 'diff'.
	diff := a - b
	// '*' does multiplication. Saving the result in 'product'.
	product := a * b
	// '/' does division. Since 'a' and 'b' are whole numbers, it chops off any decimals and just gives us the whole number part. Saves in 'quotient'.
	quotient := a / b
	// '%' is the modulo operator. It divides the numbers but ONLY gives us the remainder. (10 divided by 3 leaves a remainder of 1). Saves in 'remainder'.
	remainder := a % b

	// '>' checks if the left side is strictly bigger than the right side. This answers a true/false question and saves it in 'isGreater'.
	isGreater := a > b
	// '==' checks if two things are exactly equal (don't confuse it with '=' which forces a value into a box). Saves true/false in 'isEqual'.
	isEqual := a == b
	// '!=' checks if two things are NOT equal. Saves true/false in 'isNotEqual'.
	isNotEqual := a != b
	// '<=' checks if the left side is less than OR equal to the right side. Saves true/false in 'isLessOrEqual'.
	isLessOrEqual := a <= b

	// '()' groups things together for math-like order. '&&' means AND (both the left and right side must be true). We check if 'a' is over 18 AND under 100, saving it in 'isAdult'.
	isAdult := (a > 18) && (a < 100)
	// '||' means OR (only one side needs to be true). We check if false OR true is true, and save it in 'isWeekend'.
	isWeekend := false || true
	// '!' means NOT (it flips true to false, and false to true). We check if 'a' is greater than 50, then flip that result, saving it in 'isNotValid'.
	isNotValid := !(a > 50)

	// Creating two new variables 'x' and 'y', filling them with 5 and 3.
	x, y := 5, 3
	// '&' is a bitwise AND. It looks at the microscopic 1s and 0s of the numbers and compares them. We do this to 'x' and 'y' and save it in 'bitwiseAnd'.
	bitwiseAnd := x & y
	// '|' is a bitwise OR. It compares the raw 1s and 0s using OR logic. Saves in 'bitwiseOr'.
	bitwiseOr := x | y
	// '^' is a bitwise XOR (exclusive OR). It compares the raw bits. Saves in 'bitwiseXor'.
	bitwiseXor := x ^ y
	// '<<' shifts all the microscopic 1s and 0s to the left by 1 space, effectively multiplying the number by 2. Saves in 'leftShift'.
	leftShift := x << 1
	// '>>' shifts the bits to the right, effectively dividing by 2. Saves in 'rightShift'.
	rightShift := x >> 1

	// Tossing our addition result into the black hole so Go doesn't complain.
	_ = sum
	// Tossing our subtraction result into the black hole.
	_ = diff
	// Tossing our multiplication result into the black hole.
	_ = product
	// Tossing our division result into the black hole.
	_ = quotient
	// Tossing our remainder result into the black hole.
	_ = remainder
	// Tossing our greater-than check into the black hole.
	_ = isGreater
	// Tossing our equal-to check into the black hole.
	_ = isEqual
	// Tossing our not-equal check into the black hole.
	_ = isNotEqual
	// Tossing our less-than-or-equal check into the black hole.
	_ = isLessOrEqual
	// Tossing our AND logic check into the black hole.
	_ = isAdult
	// Tossing our OR logic check into the black hole.
	_ = isWeekend
	// Tossing our NOT logic check into the black hole.
	_ = isNotValid
	// Tossing our bitwise AND result into the black hole.
	_ = bitwiseAnd
	// Tossing our bitwise OR result into the black hole.
	_ = bitwiseOr
	// Tossing our bitwise XOR result into the black hole.
	_ = bitwiseXor
	// Tossing our left shift result into the black hole.
	_ = leftShift
	// Tossing our right shift result into the black hole.
	_ = rightShift
// Closing the DemonstrateOperators function.
}

// Creating a new function named 'DemonstrateControlFlow'. '{' opens the block.
func DemonstrateControlFlow() {
	// Creating a variable 'age' and setting it to 25.
	age := 25
	// 'if' makes a decision. '>=' means greater than or equal to. We check if 'age' is 18 or older, and '{' opens the block of code to run ONLY if that's true.
	if age >= 18 {
		// Using our 'fmt' tool's 'Println' machine. It prints the text "Adult" to the screen and automatically drops down to a new line.
		fmt.Println("Adult")
	// '} else if' means "if the first check was false, try this brand new check instead". We check if 'age' is 13 or older, opening a new block.
	} else if age >= 13 {
		// Printing "Teen" if they are between 13 and 17.
		fmt.Println("Teen")
	// '} else' means "if absolutely all the other checks failed, just run this fallback code". Opens the final block.
	} else {
		// Printing "Child" as our fallback.
		fmt.Println("Child")
	// Closing the entire if/else chain block.
	}

	// Creating a variable 'day' holding the text "Monday".
	day := "Monday"
	// 'switch' is a much cleaner way to write many 'if' checks against a single thing. We tell it to inspect the 'day' variable. '{' opens the switch block.
	switch day {
	// 'case' provides a specific matching scenario for the switch. ':' marks the end of the scenario. If 'day' perfectly matches "Monday", "Tuesday", OR "Wednesday", we do what follows.
	case "Monday", "Tuesday", "Wednesday":
		// Printing "Weekday" if one of the cases matched.
		fmt.Println("Weekday")
	// Giving the switch another scenario: if 'day' is "Saturday" or "Sunday".
	case "Saturday", "Sunday":
		// Printing "Weekend".
		fmt.Println("Weekend")
	// 'default' is the switch's version of 'else'. If none of the cases above matched, we run this.
	default:
		// Printing "Unknown".
		fmt.Println("Unknown")
	// Closing the switch block.
	}

	// Creating a variable 'score' and setting it to 85.
	score := 85
	// We can use 'switch' completely empty! It acts like a giant, super clean 'if/else' chain where each case is its own true/false math check.
	switch {
	// Our first true/false scenario: is the score 90 or higher?
	case score >= 90:
		// Printing "Grade A".
		fmt.Println("Grade A")
	// Our second scenario: is the score 80 or higher?
	case score >= 80:
		// Printing "Grade B".
		fmt.Println("Grade B")
	// Our fallback scenario if all the above score checks failed.
	default:
		// Printing "Below B".
		fmt.Println("Below B")
	// Closing the empty switch block.
	}

	// 'for' creates a loop (a way to repeat actions). This line has three parts separated by ';'. First, we set 'i' to 0. Second, we say "keep looping as long as 'i' is less than 5". Third, 'i++' means "add 1 to 'i' at the end of every loop". '{' opens the loop block.
	for i := 0; i < 5; i++ {
		// We aren't actually doing anything in this loop, so we throw 'i' into the black hole so Go doesn't yell at us.
		_ = i
	// Closing the for loop.
	}

	// Creating a variable 'count' set to 0.
	count := 0
	// We can also use 'for' like a simple while loop. We just give it one rule: "keep looping as long as 'count' is less than 3".
	for count < 3 {
		// 'count++' takes the current value of count and adds 1 to it.
		count++
	// Closing the condition-only for loop.
	}

	// Creating a true/false variable named 'shouldBreak' and setting it to true.
	shouldBreak := true
	// A 'for' loop with absolutely no rules will run forever infinitely until we force it to stop.
	for {
		// Checking if 'shouldBreak' is true.
		if shouldBreak {
			// 'break' is an emergency exit door. It immediately stops and jumps completely out of the closest loop.
			break
		// Closing the if block.
		}
	// Closing the infinite for loop.
	}

	// '[]string' creates a dynamic list (called a slice) of text strings. We use '{...}' to instantly fill it with "apple", "banana", and "cherry", saving it to 'items'.
	items := []string{"apple", "banana", "cherry"}
	// 'range' is a special tool that goes through a collection one by one. Each loop, it hands us two things: the position number (saving to 'idx') and the actual text there (saving to 'item').
	for idx, item := range items {
		// Tossing the position number into the black hole.
		_ = idx
		// Tossing the text item into the black hole.
		_ = item
	// Closing the range loop.
	}

	// 'map[string]int' is a dictionary. It maps a text key to a number value. We fill it with two entries: Alice (90) and Bob (85), saving it to 'scores'.
	scores := map[string]int{"Alice": 90, "Bob": 85}
	// Ranging over a dictionary hands us the text key ('name') and the number value ('score'). Note: Go randomizes the order dictionaries loop in!
	for name, score := range scores {
		// Tossing the key into the black hole.
		_ = name
		// Tossing the value into the black hole.
		_ = score
	// Closing the dictionary range loop.
	}

	// If we only care about the second thing 'range' hands us (the value), we can put our black hole '_' directly in the first slot where the index usually goes!
	for _, val := range items {
		// Tossing the value into the black hole.
		_ = val
	// Closing the range loop.
	}

	// 'defer' hits the pause button on an action. It tells Go "Don't run this line right now; wait until the absolute very end of this function, right before we leave, and THEN run it." Think of it like adding a chore to a list you have to do before leaving the house.
	defer fmt.Println("Third (deferred last)")
	// Adding another chore to the defer list. Note: Defer lists run backwards! The last thing you deferred runs first.
	defer fmt.Println("Second (deferred middle)")
	// This line DOES NOT have defer, so it runs immediately right now.
	fmt.Println("First (immediate)")
// Closing the DemonstrateControlFlow function.
}

// Creating a new function named 'DemonstratePointerBasics'.
func DemonstratePointerBasics() {
	// Creating a variable named 'ptr' that acts as a treasure map (pointer) pointing to wherever an 'int' is buried in memory.
	var ptr *int
	// Creating a normal variable 'value' holding 42.
	value := 42
	// '&' means "find the memory address of". We find exactly where 'value' lives in the computer and hand that map over to 'ptr'.
	ptr = &value

	// Putting a '*' in FRONT of a pointer variable means "follow the map and dig up the treasure". We go to the address in 'ptr', dig up the 42, and save it in a new variable 'derefValue'.
	derefValue := *ptr
	// Tossing our dug-up treasure into the black hole.
	_ = derefValue

	// Creating a new map pointing to an integer, but leaving it blank (so it equals 'nil').
	var nilPtr *int
	// Checking if our map is actually pointing to something before we try to follow it. (Following a blank map will crash your whole program!)
	if nilPtr != nil {
		// If it's not blank, follow the map and toss the treasure into the black hole.
		_ = *nilPtr
	// Closing the if block.
	}

	// Creating a variable 'original' holding 10.
	original := 10
	// By default, Go makes copies. We are taking the 10 from 'original', photocopying it, and handing the copy to 'byValue'.
	byValue := original
	// We change the copy to 20.
	byValue = 20
	// Tossing 'original' into the black hole. Because we only changed the photocopy, 'original' is completely safe and is still 10.
	_ = original
// Closing the DemonstratePointerBasics function.
}

// Creating a new function named 'modifyByPointer'. Instead of taking a normal integer, the input '(ptr *int)' means it expects a treasure map pointing to an integer.
func modifyByPointer(ptr *int) {
	// We follow the map to the original location and forcefully overwrite whatever is buried there with the number 100.
	*ptr = 100
// Closing the modifyByPointer function.
}

// Creating a new function named 'DemonstrateMemoryAllocation'.
func DemonstrateMemoryAllocation() {
	// 'new()' asks the computer to carve out a fresh, empty spot in memory for a specific type (an 'int' here) and gives us the map (pointer) to that spot.
	intPtr := new(int)
	// We follow the map to the newly carved out spot and put 42 there.
	*intPtr = 42

	// 'make()' sets up complex hollow containers (like lists or dictionaries) and makes them ready to use. '[]int' means a list of integers. '5' is the starting size, and '10' is the maximum size it can hold before it has to expand.
	slice := make([]int, 5, 10)
	// Using 'make()' to prepare a completely empty dictionary that maps text strings to numbers.
	myMap := make(map[string]int)
	// 'chan int' creates a channel (a secure pipe for separate tasks to pass integers to each other). 'make()' builds the pipe and gives it space to hold 5 numbers at once.
	myChan := make(chan int, 5)

	// Creating a simple variable. Since it's trapped inside this function, Go stores it in temporary memory called the 'stack', which cleans itself up instantly when the function ends.
	stackVar := 100

	// We use 'new()' to create space for a string. Because we might pass this map around, Go puts it in long-term memory called the 'heap', which has to be cleaned up by a garbage collector later.
	heapPtr := new(string)
	// Following our long-term map and putting text inside.
	*heapPtr = "heap-allocated"

	// Tossing our int pointer into the black hole.
	_ = intPtr
	// Tossing our list into the black hole.
	_ = slice
	// Tossing our dictionary into the black hole.
	_ = myMap
	// Tossing our channel pipe into the black hole.
	_ = myChan
	// Tossing our temporary variable into the black hole.
	_ = stackVar
	// Tossing our long-term pointer into the black hole.
	_ = heapPtr
// Closing the DemonstrateMemoryAllocation function.
}

// Creating a new function named 'DemonstrateArrays'.
func DemonstrateArrays() {
	// '[5]int' creates a rigid array (a fixed-size list). The '5' means it can hold exactly 5 integers, no more, no less. Go fills it with zeros.
	var arr [5]int
	// '[' and ']' let us access specific slots in the list. Note: Computers start counting at 0! We put 10 in the very first slot (slot 0).
	arr[0] = 10
	// We put 50 in the 5th slot (slot 4).
	arr[4] = 50

	// Creating an array holding exactly 3 items and filling it with 1, 2, and 3 instantly.
	original := [3]int{1, 2, 3}
	// Making a complete photocopy of the original array.
	copy := original
	// Changing the first slot of our photocopy to 999.
	copy[0] = 999
	// Tossing the original into the black hole. It is completely unaffected and still starts with 1.
	_ = original

	// Using our range tool to loop through every slot in our first array.
	for idx, val := range arr {
		// Tossing the position index into the black hole.
		_ = idx
		// Tossing the value at that position into the black hole.
		_ = val
	// Closing the array range loop.
	}
	// Tossing our modified copy into the black hole.
	_ = copy
// Closing the DemonstrateArrays function.
}

// Creating a custom blueprint named 'SliceAnatomy' to explain what a dynamic list actually looks like under the hood.
type SliceAnatomy struct {
	// 'unsafe.Pointer' uses the unsafe tool we imported to make a raw memory map that bypasses Go's safety checks. This map points to the hidden fixed array acting as the backbone of our list.
	ptr      unsafe.Pointer
	// This tracks how many items are currently sitting in the list.
	length   int
	// This tracks how big the hidden backbone array actually is before we run out of room.
	capacity int
// Closing the SliceAnatomy struct.
}

// Creating a new function named 'DemonstrateSlices'.
func DemonstrateSlices() {
	// Empty brackets '[]' create a slice—a dynamic list that can shrink and grow. We fill it with 1 through 5.
	slice := []int{1, 2, 3, 4, 5}

	// Grabbing the item in the very first slot and saving it.
	firstElem := slice[0]
	// 'len()' is a built-in tool that counts exactly how many items are currently in our list.
	length := len(slice)
	// 'cap()' counts the total capacity (how much room is left in the hidden backbone array before it needs to expand).
	capacity := cap(slice)

	// 'append()' adds new items to the very end of a slice. If there isn't enough room, it quietly builds a bigger backbone array behind the scenes. We add 6 and 7, and save the updated list over the old one.
	slice = append(slice, 6, 7)

	// Creating a completely empty dynamic list of integers.
	var dynamicSlice []int
	// Setting up a loop to run 100 times.
	for i := 0; i < 100; i++ {
		// Adding the current loop number to the end of our dynamic list. It will automatically grow larger and larger as needed.
		dynamicSlice = append(dynamicSlice, i)
	// Closing the growth loop.
	}

	// We use 'make()' to prepare a brand new list, and tell it to make it exactly the same length as our original 'slice'.
	dest := make([]int, len(slice))
	// 'copy()' takes everything from the source (on the right) and carefully pastes it into the destination (on the left). It tells us how many items it successfully copied.
	copied := copy(dest, slice)
	// Tossing the count of copied items into the black hole.
	_ = copied

	// Creating a new list with 1, 2, 3.
	slice1 := []int{1, 2, 3}
	// Creating 'slice2' by assigning it 'slice1'. Watch out! For dynamic lists, Go does NOT make a photocopy. Both names are now pointing to the exact same hidden backbone array.
	slice2 := slice1
	// We change the first slot in 'slice2' to 999.
	slice2[0] = 999
	// Tossing 'slice1' into the black hole. Because they share the same backbone, slice1's first slot is ALSO magically 999 now!
	_ = slice1

	// Creating a new list 0 through 5.
	original := []int{0, 1, 2, 3, 4, 5}
	// The ':' lets us chop a list up! We say "give me a new view starting at slot 2, and stopping right before slot 5". It creates a window looking at the same backbone array.
	resliced := original[2:5]
	// Changing the first slot of our new window.
	resliced[0] = 999
	// Tossing the original into the black hole. Because the window looked at the original backbone, the original is changed too!
	_ = original

	// Tossing our first element variable into the black hole.
	_ = firstElem
	// Tossing our length variable into the black hole.
	_ = length
	// Tossing our capacity variable into the black hole.
	_ = capacity
	// Tossing our massive dynamic list into the black hole.
	_ = dynamicSlice
	// Tossing our copied list into the black hole.
	_ = dest
// Closing the DemonstrateSlices function.
}

// Creating a new function named 'DemonstrateMaps'.
func DemonstrateMaps() {
	// Using 'make()' to build an empty dictionary that maps text keys to integer values.
	myMap := make(map[string]int)
	// We open the dictionary to the page for "alice" and write the number 90 there.
	myMap["alice"] = 90
	// We open the page for "bob" and write 85.
	myMap["bob"] = 85

	// When we look up a key in a dictionary, it actually hands us TWO things: the value, and a true/false flag telling us if that key actually exists in the dictionary. We save both.
	score, exists := myMap["alice"]
	// Looking up "charlie" who isn't there. It hands us a 0 (the default fallback for an integer) and 'false'.
	missing, found := myMap["charlie"]
	// Tossing Alice's score into the black hole.
	_ = score
	// Tossing Alice's existence flag into the black hole.
	_ = exists
	// Tossing Charlie's fallback score into the black hole.
	_ = missing
	// Tossing Charlie's existence flag into the black hole.
	_ = found

	// 'delete()' is a tool that permanently erases an entry from a dictionary. We wipe the page for "alice" completely clean.
	delete(myMap, "alice")

	// Ranging over our dictionary, saving the text key and number value.
	for key, val := range myMap {
		// Tossing the key into the black hole.
		_ = key
		// Tossing the value into the black hole.
		_ = val
	// Closing the dictionary loop.
	}
// Closing the DemonstrateMaps function.
}

// Defining a custom container blueprint named 'User'.
type User struct {
	// Adding an integer box named 'ID'.
	ID        int
	// Adding a text box named 'Name'.
	Name      string
	// Adding another text box named 'Email'.
	Email     string
	// Adding an integer box named 'Age'.
	Age       int
	// Adding a time-stamp box named 'CreatedAt'.
	CreatedAt time.Time
// Closing the User struct block.
}

// Defining a custom container blueprint named 'Admin'.
type Admin struct {
	// By simply writing the name of another struct ('User') without giving it a field name, we "embed" it. This means 'Admin' instantly inherits every single field inside 'User' as if they were its own!
	User
	// Adding a true/false switch named 'IsAdmin'.
	IsAdmin   bool
	// Adding a dynamic list of strings named 'Permissions'.
	Permissions []string
// Closing the Admin struct block.
}

// Creating a new function named 'DemonstrateStructs'.
func DemonstrateStructs() {
	// We are creating a brand new, physical 'User' object based on our blueprint, and opening '{' to start filling out its fields right now.
	user := User{
		// Setting the ID field to 1. Note the ',' at the end of every line!
		ID:        1,
		// Setting the Name field to "Alice".
		Name:      "Alice",
		// Setting the Email field.
		Email:     "alice@example.com",
		// Setting the Age field.
		Age:       28,
		// Using the 'time' tool's 'Now()' machine to instantly get the exact current time and save it.
		CreatedAt: time.Now(),
	// Closing the creation of our new User object.
	}

	// A '.' lets us reach inside a struct and grab a specific field. We reach into 'user', grab the 'Name', and save it to a new variable.
	name := user.Name
	// We can also use '.' to change a field. We reach into 'user' and update 'Age' to 29.
	user.Age = 29

	// Creating a brand new 'Admin' object based on our blueprint.
	admin := Admin{
		// We have to fill out the embedded 'User' struct first. Opening its block.
		User: User{
			// Setting the User's ID.
			ID:   2,
			// Setting the User's Name.
			Name: "Bob",
			// Setting the User's Age.
			Age:  35,
		// Closing the embedded User object.
		},
		// Setting the Admin's true/false switch.
		IsAdmin:     true,
		// Filling the Permissions list with three text strings.
		Permissions: []string{"read", "write", "delete"},
	// Closing the creation of our Admin object.
	}
	// Because 'User' was embedded, its fields were promoted. This means we can reach straight into 'admin' and ask for 'Name' without having to dig through the 'User' layer first!
	adminName := admin.Name
	// Reaching straight into 'admin' to grab the 'ID'.
	adminID := admin.ID

	// Tossing our extracted name into the black hole.
	_ = name
	// Tossing our entire user object into the black hole.
	_ = user
	// Tossing our entire admin object into the black hole.
	_ = admin
	// Tossing the admin's name into the black hole.
	_ = adminName
	// Tossing the admin's ID into the black hole.
	_ = adminID
// Closing the DemonstrateStructs function.
}

// Defining a custom container blueprint named 'Product'.
type Product struct {
	// The `` backticks at the end create a "struct tag". It's a sticky note for other programs telling them how to read this field. This tells JSON readers to call this field "id".
	ID       int    `json:"id"`
	// Telling JSON readers to call this field "name".
	Name     string `json:"name"`
	// Telling JSON readers to call this "price", but "omitempty" means "if this field is completely empty/zero, just pretend it doesn't exist".
	Price    float64 `json:"price,omitempty"`
	// The "-" tag tells JSON readers to completely ignore this field and keep it totally secret.
	Internal string `json:"-"`
// Closing the Product struct block.
}

// Creating a new function named 'DemonstrateStrings'.
func DemonstrateStrings() {
	// Creating a standard text string.
	str := "Hello, Go!"
	// Grabbing the very first slot [0] of a string actually hands us the raw 'byte' number representing that letter, NOT the letter itself.
	firstByte := str[0]
	// 'len()' counts how many raw bytes make up the string, not necessarily the number of letters (emoji can take up multiple bytes!).
	length := len(str)

	// Using range on a string is smarter; it decodes the raw bytes and hands us the actual letters (runes) one by one.
	for idx, runeVal := range str {
		// Tossing the byte index into the black hole.
		_ = idx
		// Tossing the decoded letter into the black hole.
		_ = runeVal
	// Closing the string range loop.
	}

	// Creating an empty string box.
	var slowConcat string
	// Looping 100 times.
	for i := 0; i < 100; i++ {
		// '+=' takes whatever is in 'slowConcat', adds an "x" to the end, and saves it. But behind the scenes, Go has to photocopy the ENTIRE string every single loop! It's very slow.
		slowConcat += "x"
	// Closing the slow loop.
	}

	// We use the 'strings' tool we imported to create a 'Builder'. Think of it as a super-efficient notepad where we can jot things down fast without photocopying.
	var builder strings.Builder
	// Looping 100 times.
	for i := 0; i < 100; i++ {
		// We tell our notepad to quickly jot down an "x". This is much faster!
		builder.WriteString("x")
	// Closing the efficient loop.
	}
	// When we are totally done jotting things down, we ask the notepad to print out one final, complete string.
	efficientConcat := builder.String()

	// Tossing our raw byte into the black hole.
	_ = firstByte
	// Tossing our length into the black hole.
	_ = length
	// Tossing our slowly built string into the black hole.
	_ = slowConcat
	// Tossing our efficiently built string into the black hole.
	_ = efficientConcat
// Closing the DemonstrateStrings function.
}

// A function definition that takes inputs. Inside '()', 'a int' and 'b int' are the inputs it requires. The 'int' at the very end tells Go this recipe will spit out (return) an integer when it's done.
func BasicFunction(a int, b int) int {
	// 'return' is the final step of the recipe. It spits the answer back out to whoever called the function. Here it hands back the result of adding a and b.
	return a + b
// Closing the BasicFunction.
}

// Multiple inputs of the exact same type can share the type name at the end ('denominator int' applies to 'numerator' too). The '(int, error)' means it returns TWO separate things: a number and an error object.
func MultipleReturns(numerator, denominator int) (int, error) {
	// Making sure we don't accidentally do math that explodes the universe (dividing by zero).
	if denominator == 0 {
		// We use the 'errors' tool's 'New()' machine to create a custom error message. We return 0 for the number, and our fresh error message for the error.
		return 0, errors.New("division by zero")
	// Closing the check.
	}
	// If the math is safe, we divide them and return the answer. We return 'nil' (blank) for the error because nothing went wrong!
	return numerator / denominator, nil
// Closing the MultipleReturns function.
}

// The '...int' is a variadic parameter. It's magic that says "you can hand me as many integers as you want, separated by commas, and I will neatly pack them all into a list named 'nums' for you".
func VariadicFunction(nums ...int) int {
	// Setting up a starting sum of 0.
	sum := 0
	// Looping through our packed list of numbers.
	for _, num := range nums {
		// Adding each number to our running total.
		sum += num
	// Closing the variadic loop.
	}
	// Spitting the final total back out.
	return sum
// Closing the VariadicFunction.
}

// Creating a new function named 'DemonstrateFunctions'.
func DemonstrateFunctions() {
	// We can create a function with absolutely no name (an anonymous function) and instantly save it into a box named 'add' using ':='!
	add := func(a, b int) int {
		// Returning the sum.
		return a + b
	// Closing the anonymous function.
	}
	// Now we can use the 'add' box like a normal function, passing in 3 and 4!
	result := add(3, 4)

	// Creating a counter variable set to 0.
	counter := 0
	// Creating another nameless function. Because it's created INSIDE this block, it can secretly reach out and touch the 'counter' variable we just made! This is called a "closure".
	increment := func() {
		// Reaching out and adding 1 to 'counter'.
		counter++
	// Closing the closure function.
	}
	// We run the nameless function. 'counter' magically becomes 1.
	increment()
	// Run it again. 'counter' becomes 2.
	increment()

	// Tossing our addition result into the black hole.
	_ = result
	// Tossing our final counter number into the black hole.
	_ = counter
// Closing the DemonstrateFunctions function.
}

// Putting '(u User)' before the function name turns this normal function into a "method". It means this action belongs strictly to the 'User' struct blueprint. However, it only receives a PHOTOCOPY of the user (named 'u'), so changes won't be permanent.
func (u User) DisplayInfo() string {
	// Using our formatting tool. '%s' means "plug text in here", and '%d' means "plug a number in here". We plug in the user's name and age.
	return fmt.Sprintf("%s (%d)", u.Name, u.Age)
// Closing the method.
}

// Putting a '*' inside '(u *User)' means this method expects a treasure map to the ORIGINAL user, not a photocopy. Any changes we make here will be absolutely permanent!
func (u *User) IncrementAge() {
	// Checking if our treasure map is actually pointing to a real user.
	if u != nil {
		// Permanently adding 1 to the original user's age.
		u.Age++
	// Closing the check.
	}
// Closing the pointer method.
}

// Defining a custom blueprint named 'ServerConfig' to hold network settings.
type ServerConfig struct {
	// Text container for the host address.
	Host        string
	// Number container for the port.
	Port        int
	// Time duration container for how long to wait before giving up.
	Timeout     time.Duration
	// Number container for connection limits.
	MaxConnections int
// Closing the ServerConfig struct.
}

// We are inventing a brand new type named 'ServerOption'. But it's not a struct; it's a blueprint for a specific KIND of function. Any function that matches this shape (takes a pointer to a ServerConfig) can be called a 'ServerOption'.
type ServerOption func(*ServerConfig)

// This function takes a host string and returns one of those special 'ServerOption' functions we just invented.
func WithHost(host string) ServerOption {
	// Returning a nameless function that knows how to find the original config and change its host field.
	return func(cfg *ServerConfig) {
		// Changing the host.
		cfg.Host = host
	// Closing the returned function.
	}
// Closing WithHost.
}

// Takes a port number and returns a ServerOption function.
func WithPort(port int) ServerOption {
	// Returning the function.
	return func(cfg *ServerConfig) {
		// Changing the port.
		cfg.Port = port
	// Closing the returned function.
	}
// Closing WithPort.
}

// Takes a timeout duration and returns a ServerOption function.
func WithTimeout(timeout time.Duration) ServerOption {
	// Returning the function.
	return func(cfg *ServerConfig) {
		// Changing the timeout.
		cfg.Timeout = timeout
	// Closing the returned function.
	}
// Closing WithTimeout.
}

// A constructor function. The '...ServerOption' means it accepts an endless list of those special functions we made, packing them into a list named 'options'. It spits out a pointer to a fully built ServerConfig.
func NewServer(options ...ServerOption) *ServerConfig {
	// We create a fresh ServerConfig with reasonable default values, and grab the map (pointer) to it using '&'.
	cfg := &ServerConfig{
		// Default host.
		Host:           "localhost",
		// Default port.
		Port:           8080,
		// Default timeout of 30 seconds.
		Timeout:        30 * time.Second,
		// Default max connections.
		MaxConnections: 100,
	// Closing the default configuration creation.
	}
	// We loop through the list of special customization functions the user handed us.
	for _, opt := range options {
		// We execute each customization function, handing it the map to our config so it can tweak whatever it wants.
		opt(cfg)
	// Closing the customization loop.
	}
	// Spitting out the map to our fully built and customized configuration.
	return cfg
// Closing NewServer.
}

// A function showing what NOT to do. Takes a list of file paths.
func DeferInLoopsAntipattern(filePaths []string) {
	// Looping through the file paths.
	for _, path := range filePaths {
		// Pretending to open a file. It hands us the file and maybe an error.
		file, _ := openFile(path)
		// WARNING: Putting 'defer' inside a loop is dangerous! It adds the 'Close' chore to the list, but the chores don't run until the ENTIRE function ends. If you loop 10,000 times, you'll have 10,000 files left open sucking up memory!
		defer file.Close()
	// Closing the dangerous loop.
	}
// Closing the antipattern function.
}

// A function showing the SAFE way to do it.
func DeferInLoopsCorrect(filePaths []string) {
	// Looping through the file paths.
	for _, path := range filePaths {
		// We create a nameless function and INSTANTLY run it by putting '()' at the end of the block.
		func() {
			// Opening the file.
			file, _ := openFile(path)
			// Because we are inside a tiny nameless function, the 'defer' chore will run the second this tiny function ends, safely closing the file immediately!
			defer file.Close()
		// '}()' closes the nameless function and immediately executes it.
		}()
	// Closing the safe loop.
	}
// Closing the correct function.
}

// A fake helper function just to make the code above compile. It takes a text path and returns an 'io.Closer' interface and an error.
func openFile(path string) (io.Closer, error) {
	// Spitting out blanks.
	return nil, nil
// Closing openFile.
}

// 'interface' defines a contract or a job description. It doesn't write ANY actual code; it just sets rules. It says "I don't care what kind of struct you are, but if you claim to be a 'Reader', you MUST have a method named 'Read' that looks exactly like this."
type Reader interface {
	// The exact rule: a method named Read that takes a byte slice and returns an int and an error.
	Read(p []byte) (n int, err error)
// Closing the Reader contract.
}

// Defining another job description contract named 'Writer'.
type Writer interface {
	// The rule: must have a Write method.
	Write(p []byte) (n int, err error)
// Closing the Writer contract.
}

// Defining a contract named 'ErrorInterface'. (This is actually exactly how Go's built-in errors work behind the scenes!)
type ErrorInterface interface {
	// The rule: must have an Error method that returns a string.
	Error() string
// Closing the contract.
}

// Defining a contract named 'Stringer'. (Used by the fmt printing tool to know how to print custom structs).
type Stringer interface {
	// The rule: must have a String method that returns a string.
	String() string
// Closing the contract.
}

// Here we give our 'User' struct a method named 'String' that returns a string. By doing this, 'User' automatically signed the 'Stringer' contract without even realizing it!
func (u User) String() string {
	// Returning a nicely formatted text description of the user.
	return fmt.Sprintf("User{ID: %d, Name: %s}", u.ID, u.Name)
// Closing the String method.
}

// This function accepts an 'interface{}'. An empty interface has zero rules! That means it acts like a generic cardboard box that can accept absolutely ANY data type in the universe.
func DemonstrateTypeAssertion(r interface{}) {
	// '.(string)' is a type assertion. It's like ripping open the generic cardboard box. It means "I strongly believe 'r' is hiding a string inside, and I demand you pull it out". If it's NOT a string, the program violently crashes!
	strValue := r.(string)
	// Tossing our extracted string into the black hole.
	_ = strValue

	// Adding ', ok' makes ripping the box open completely safe. If it's not a string, it simply sets 'ok' to false instead of crashing. We use ';' to check if 'ok' is true on the exact same line!
	if val, ok := r.(string); ok {
		// If 'ok' was true, we safely use the extracted value and toss it in the black hole.
		_ = val
	// Closing the safe assertion block.
	}
// Closing the DemonstrateTypeAssertion function.
}

// A function accepting a generic cardboard box named 'value'.
func DemonstrateTypeSwitch(value interface{}) {
	// '.(type)' is a magical switch. Instead of guessing what's in the box, it opens the box, looks at the true underlying data type, and saves the naked data into 'v'.
	switch v := value.(type) {
	// Scenario: Is the data inside a string?
	case string:
		// We print it out safely.
		fmt.Printf("String: %s\n", v)
	// Scenario: Is the data inside an integer?
	case int:
		// We print the number.
		fmt.Printf("Integer: %d\n", v)
	// Scenario: Is the data inside a decimal?
	case float64:
		// We print the decimal.
		fmt.Printf("Float: %f\n", v)
	// Fallback scenario: If it's none of the above.
	default:
		// We admit we don't know what it is.
		fmt.Printf("Unknown type\n")
	// Closing the magical type switch block.
	}
// Closing the DemonstrateTypeSwitch function.
}

// Creating a completely empty custom blueprint to explain how interfaces work inside the computer's brain.
type InterfaceValue struct {
// Closing the empty struct.
}

// Creating a new function named 'DemonstrateNilInterface'.
func DemonstrateNilInterface() {
	// We create a generic cardboard box named 'reader'. Inside the box, we put a treasure map (pointer) to a 'strings.Reader', but we leave the map blank (nil).
	var reader interface{} = (*strings.Reader)(nil)

	// We check if the cardboard box itself is empty.
	if reader == nil {
		// Printing if it's empty.
		fmt.Println("reader is nil")
	// Fallback block.
	} else {
		// The box is NOT empty! It contains a blank map! This is a huge trap for beginners. A box holding a blank map is still a box holding something!
		fmt.Println("reader is NOT nil (holds a nil *strings.Reader)")
	// Closing the if/else chain.
	}
// Closing the DemonstrateNilInterface function.
}

// This function expects ANY object that signed the 'Reader' contract we made earlier. We don't care what the object actually is, as long as it has a Read method!
func ProcessData(r Reader) string {
	// We use 'make' to create a list of bytes 1024 slots long to use as an empty bucket.
	buf := make([]byte, 1024)
	// We blindly tell whatever object got passed in to execute its Read method, filling our bucket with data.
	r.Read(buf)
	// We convert the raw bucket of bytes into a readable string and spit it out.
	return string(buf)
// Closing ProcessData.
}

// Defining a new contract named 'ReadCloser'.
type ReadCloser interface {
	// By just typing the name of the 'Reader' contract, we embed it! Now, to be a ReadCloser, you MUST sign the rules for Reader...
	Reader
	// ...AND you must sign the rules for the built-in 'io.Closer' contract too!
	io.Closer
// Closing the ReadCloser contract.
}

// We use the 'errors' tool to create a stone-carved, global error message. This is highly useful so our entire program can check for this exact specific failure.
var ErrNotFound = errors.New("resource not found")
// Creating another global, reusable error message.
var ErrUnauthorized = errors.New("unauthorized access")

// Defining a custom container named 'ValidationError' to hold specific details about why something failed.
type ValidationError struct {
	// A text field for which specific input box failed validation.
	Field   string
	// A text field for the detailed excuse of why it failed.
	Message string
// Closing ValidationError.
}

// We give our ValidationError struct a method named 'Error' that spits out a string. Because of this, it secretly signed the universal 'error' contract and is now an official Go error!
func (e ValidationError) Error() string {
	// We format a nice message combining the field and the excuse.
	return fmt.Sprintf("validation error on field '%s': %s", e.Field, e.Message)
// Closing the error method.
}

// A function demonstrating the most common error pattern in Go. Returns a standard error object.
func idiomatic_if_err_not_nil() error {
	// Creating some fake data text.
	data := "42"
	// We pretend to run a machine that turns text into numbers. It hands us the number ('num') and an error object ('err').
	num, err := parseNumber(data)
	// We check if the error object is NOT empty (meaning something exploded).
	if err != nil {
		// If it exploded, we immediately hit the eject button and toss the exact same error back up to whoever called us!
		return err
	// Closing the error check.
	}
	// If we survived, we toss the number into the black hole.
	_ = num
	// We return 'nil' (blank) because absolutely nothing went wrong.
	return nil
// Closing the function.
}

// A helper function pretending to parse numbers. It returns a number and an error.
func parseNumber(s string) (int, error) {
	// Checking if the text they gave us is completely empty.
	if len(s) == 0 {
		// If it is, we return 0 and create a fresh error message complaining about it.
		return 0, errors.New("empty string")
	// Closing the check.
	}
	// If it's fine, we return 42 and 'nil' for the error.
	return 42, nil
// Closing parseNumber.
}

// A function to show how to stack errors like Russian nesting dolls.
func DemonstrateErrorWrapping() error {
	// Creating a base error pretending the database died.
	underlying := errors.New("database connection failed")
	// The '%w' inside the format text is special. It means "wrap"! It takes our database error and wraps it safely inside a brand new, broader error message.
	wrapped := fmt.Errorf("failed to fetch user: %w", underlying)

	// 'errors.Is()' is a detective tool. It carefully unpacks the nested error doll and checks if our specific 'underlying' database error is hiding anywhere inside!
	if errors.Is(wrapped, underlying) {
		// Printing if it found the hidden error.
		fmt.Println("Found underlying error")
	// Closing the Is check.
	}

	// Creating an empty blueprint of our custom validation error.
	var valErr ValidationError
	// 'errors.As()' is another detective tool. It digs through the nested error doll looking for a specific type of error (ValidationError). If it finds it, it copies the data into our empty blueprint (using the '&' map).
	if errors.As(wrapped, &valErr) {
		// Safely printing the specific field from the extracted custom error.
		fmt.Printf("Validation error: %s\n", valErr.Field)
	// Closing the As check.
	}

	// Spitting out the massive nested error.
	return wrapped
// Closing DemonstrateErrorWrapping.
}

// A function showing how to stop ugly, deeply nested 'if' code.
func DemonstrateEarlyReturns(age, income int) string {
	// We do a quick check right at the door. Is the age under 18?
	if age < 18 {
		// Immediately kick them out and return a message. No need to keep reading code.
		return "Must be 18 or older"
	// Closing the first guard check.
	}

	// Another quick check at the door. Is income under 20,000?
	if income < 20000 {
		// Kick them out immediately.
		return "Income must be at least 20000"
	// Closing the second guard check.
	}

	// If they survived all the bouncer checks at the door, they get to the happy path!
	return "Approved"
// Closing DemonstrateEarlyReturns.
}

// A function simulating how professionals log errors.
func ProductionErrorLogging(requestID string, err error) {
	// Checking if an error actually happened.
	if err != nil {
		// Printing out a detailed log. '%v' just dumps the raw value, and '%T' is a secret code that asks "what specific data TYPE is this?".
		fmt.Printf(
			"[ERROR] RequestID: %s | Error: %v | Type: %T\n",
			requestID,
			err,
			err,
		)
	// Closing the log check.
	}
// Closing ProductionErrorLogging.
}

// Creating a new function named 'DemonstrateGoroutines'.
func DemonstrateGoroutines() {
	// The 'go' keyword is absolute magic. It takes the nameless function next to it and blasts it off onto a completely separate, independent train track. It runs at the same time as everything else without making anyone wait!
	go func() {
		// Printing a message from our independent train track.
		fmt.Println("Running in a goroutine")
	// '}()' closes and instantly launches the function.
	}()

	// The problem is, our main track finishes instantly and might close the program before the separate track even has a chance to print! So we use the 'time' tool to force the main track to sleep for 1 second to wait. (This is a hacky way to wait).
	time.Sleep(1 * time.Second)
// Closing DemonstrateGoroutines.
}

// Showing the proper, safe way to wait for multiple tracks to finish.
func SafeGoroutineWaiting() {
	// Using our sync tool to create a 'WaitGroup', which acts exactly like a tally counter at a club door.
	var wg sync.WaitGroup
	// We add 3 to the tally counter, telling it "Expect exactly 3 workers to run".
	wg.Add(3)

	// Looping 3 times.
	for i := 1; i <= 3; i++ {
		// Blasting off a nameless worker onto a separate track, and handing it the loop number 'i'.
		go func(num int) {
			// We defer calling 'Done()'. When this worker track reaches the very end, it subtracts 1 from the tally counter to say "I'm finished!".
			defer wg.Done()
			// Printing the worker's number.
			fmt.Printf("Goroutine %d\n", num)
		// Closing and instantly launching the worker track, passing 'i' into it.
		}(i)
	// Closing the creation loop.
	}

	// 'Wait()' locks the main track down. It absolutely refuses to move past this line until the tally counter hits zero.
	wg.Wait()
// Closing SafeGoroutineWaiting.
}

// Creating a new function named 'DemonstrateUnbufferedChannels'.
func DemonstrateUnbufferedChannels() {
	// 'chan int' creates a channel—a secure PVC pipe that separate tracks (goroutines) use to safely pass integers to each other. We use 'make' to build the pipe.
	ch := make(chan int)

	// Blasting off a separate track.
	go func() {
		// The '<-' arrow is magical. When it points AT the channel, it means "shove this value into the pipe". Because this pipe has no storage space, this track completely freezes right here until someone else on the other side is ready to catch the number!
		ch <- 42
	// Closing and launching.
	}()

	// When '<-' is placed IN FRONT of the channel, it means "stand at the end of the pipe with a bucket and wait". It catches the 42 and puts it in 'value'.
	value := <-ch
	// Tossing the caught value into the black hole.
	_ = value
// Closing DemonstrateUnbufferedChannels.
}

// Creating a new function to show pipes with storage space.
func DemonstrateBufferedChannels() {
	// We build a pipe, but the '2' at the end means "give this pipe a holding tank that can store 2 numbers at once".
	ch := make(chan int, 2)

	// We shove a 1 into the pipe. Because there is a holding tank, it doesn't freeze! It just drops the 1 in the tank and moves on.
	ch <- 1
	// Shoving a 2 into the tank.
	ch <- 2
	// WARNING! We try to shove a 3, but the tank is completely full! Now it freezes, waiting for someone to empty the tank.

	// Standing at the end of the pipe to catch the oldest number (1) out of the tank.
	_ = <-ch

	// Because we removed the 1, there is room again! The frozen line above can finally drop the 3 in.
	ch <- 3
// Closing DemonstrateBufferedChannels.
}

// A function demanding a channel pipe as input. But the '<-chan' means it is completely locked down to be RECEIVE ONLY. You can only catch things out of it; you can never shove things in.
func ConsumerDirectional(ch <-chan int) {
	// Catching a value out of the pipe.
	value := <-ch
	// Tossing it into the black hole.
	_ = value
// Closing ConsumerDirectional.
}

// The 'chan<-' means this pipe is SEND ONLY. You can only shove things in; you can't read from it.
func ProducerDirectional(ch chan<- int) {
	// Shoving 42 into the pipe.
	ch <- 42
// Closing ProducerDirectional.
}

// Creating a new function named 'RangeOverChannels'.
func RangeOverChannels() {
	// Building a standard pipe.
	ch := make(chan int)

	// Blasting off a separate track.
	go func() {
		// Looping from 1 to 5.
		for i := 1; i <= 5; i++ {
			// Shoving the loop number into the pipe.
			ch <- i
		// Closing the loop.
		}
		// 'close()' permanently shuts the pipe down. No more data can ever be sent in. This signals the person waiting on the other side that the delivery is completely over.
		close(ch)
	// Closing and launching.
	}()

	// 'range' isn't just for lists! Ranging over a channel means "stand here and catch every single thing that comes out of the pipe, one by one, until someone permanently closes it".
	for val := range ch {
		// Printing whatever popped out of the pipe.
		fmt.Println(val)
	// Closing the channel range loop.
	}
// Closing RangeOverChannels.
}

// Creating a new function named 'GoroutineLifecycle'.
func GoroutineLifecycle() {
	// Building a pipe with a 1-item holding tank.
	ch := make(chan int, 1)

	// Blasting off a track.
	go func() {
		// Setting up a result.
		result := 42
		// Shoving it in the tank.
		ch <- result
	// Closing and launching.
	}()

	// Catching the result and tossing it in the black hole.
	_ = <-ch
// Closing GoroutineLifecycle.
}

// An antipattern function showing how to completely ruin your memory.
func GoroutineLeakAntipattern() {
	// Building a pipe.
	ch := make(chan int)

	// Blasting off a track.
	go func() {
		// We tell this track to stand at the pipe with a bucket and wait for a value. BUT... nothing is ever sent! So this separate track freezes here forever, taking up memory until the computer crashes. This is a "Goroutine Leak"!
		_ = <-ch
	// Closing and launching.
	}()
// Closing the antipattern.
}

// Creating a function named 'DemonstrateMutex'.
func DemonstrateMutex() {
	// 'sync.Mutex' is a physical lock. When multiple separate tracks try to touch the exact same variable, a Mutex ensures only one person holds the key at a time, preventing massive data collisions.
	var mu sync.Mutex
	// Creating a simple counter set to 0.
	counter := 0

	// Creating a tally counter for our workers.
	var wg sync.WaitGroup
	// Telling the tally counter to expect 2 workers.
	wg.Add(2)

	// Blasting off Worker 1.
	go func() {
		// Worker 1 promises to subtract 1 from the tally when it finishes.
		defer wg.Done()
		// Looping 100 times.
		for i := 0; i < 100; i++ {
			// 'Lock()' grabs the key. If Worker 2 already has the key, Worker 1 completely freezes here and waits until Worker 2 drops it.
			mu.Lock()
			// Now that we securely have the key, we safely add 1 to the counter.
			counter++
			// 'Unlock()' drops the key so Worker 2 can grab it.
			mu.Unlock()
		// Closing the 100 loop.
		}
	// Closing and launching Worker 1.
	}()

	// Blasting off Worker 2.
	go func() {
		// Worker 2 promises to check out when done.
		defer wg.Done()
		// Looping 100 times.
		for i := 0; i < 100; i++ {
			// Grabbing the key.
			mu.Lock()
			// Safely updating the shared counter.
			counter++
			// Dropping the key.
			mu.Unlock()
		// Closing the 100 loop.
		}
	// Closing and launching Worker 2.
	}()

	// Locking the main track until both workers are totally finished.
	wg.Wait()
	// Printing the final, safe, uncorrupted counter.
	fmt.Printf("Counter: %d (expected 200)\n", counter)
// Closing DemonstrateMutex.
}

// Creating a function to show a different kind of lock.
func DemonstrateRWMutex() {
	// 'sync.RWMutex' is a Read/Write lock. It's smart: it allows thousands of people to 'Read' at the exact same time without locking, but if someone wants to 'Write', it kicks everyone out and locks the door!
	var rw sync.RWMutex
	// Building an empty dictionary.
	data := make(map[string]int)

	// Looping to create 5 readers.
	for i := 0; i < 5; i++ {
		// Blasting off Reader tracks.
		go func(id int) {
			// 'RLock()' grabs a Read-Only key. Multiple readers can grab this key simultaneously!
			rw.RLock()
			// Promising to drop the Read key when done.
			defer rw.RUnlock()
			// Checking the dictionary safely.
			_ = data["key"]
		// Closing and launching the reader.
		}(i)
	// Closing the reader creation loop.
	}

	// Blasting off a Writer track.
	go func() {
		// 'Lock()' is the master Write key. It waits for all readers to finish, grabs the master key, and blocks ANYONE else from looking until it's done.
		rw.Lock()
		// Promising to drop the master key.
		defer rw.Unlock()
		// Safely writing to the dictionary without readers seeing halfway-finished data.
		data["key"] = 42
	// Closing and launching the writer.
	}()

	// Hacky sleep to wait for them to finish.
	time.Sleep(100 * time.Millisecond)
// Closing DemonstrateRWMutex.
}

// Function to demonstrate the WaitGroup we've been using.
func DemonstrateWaitGroup() {
	// Setting up the tally counter.
	var wg sync.WaitGroup

	// Looping 3 times.
	for i := 1; i <= 3; i++ {
		// It's safer to add to the tally BEFORE we launch the track!
		wg.Add(1)

		// Blasting off a worker track.
		go func(num int) {
			// Subtracting from the tally when done.
			defer wg.Done()
			// Printing worker number.
			fmt.Printf("Worker %d\n", num)
		// Closing and launching worker.
		}(i)
	// Closing the loop.
	}

	// Waiting for the tally to hit zero.
	wg.Wait()
// Closing DemonstrateWaitGroup.
}

// Defining a custom container named 'Singleton'. (A pattern where only ONE of these objects should ever exist in the universe).
type Singleton struct {
	// Text field for value.
	value string
// Closing Singleton.
}

// Creating two global variables in a block.
var (
	// A map pointing to our single instance.
	instance *Singleton
	// 'sync.Once' is a magical trigger button. It guarantees that the code attached to it will absolutely only run ONE single time, no matter how many thousands of tracks mash the button.
	once     sync.Once
// Closing the global block.
}

// A function to get our single object.
func GetSingleton() *Singleton {
	// 'Do()' is the trigger button. We attach a nameless function to it. Only the very first track to arrive will run this function; everyone else will just get skipped.
	once.Do(func() {
		// Building the one and only instance.
		instance = &Singleton{value: "initialized"}
	// Closing the Do function.
	})
	// Returning the single instance.
	return instance
// Closing GetSingleton.
}

// A function showing how data races happen (when two tracks crash into each other).
func DemonstrateRaceDetection() {
	// Creating an empty number.
	var x int

	// Blasting off track 1.
	go func() {
		// Track 1 violently forces a 1 into 'x' without using locks!
		x = 1
	// Closing track 1.
	}()

	// Blasting off track 2.
	go func() {
		// Track 2 violently reads 'x' at the exact same microsecond! CRASH! Data corruption.
		_ = x
	// Closing track 2.
	}()

	// Hacky wait.
	time.Sleep(100 * time.Millisecond)
// Closing DemonstrateRaceDetection.
}

// A function demonstrating atomic operations.
func DemonstrateAtomics() {
	// Creating a massive 64-bit integer.
	var counter int64

	// 'atomic' is a super low-level tool. It reaches straight into the CPU to add 1 to the counter so blindingly fast that it's physically impossible for two tracks to crash into each other. It's faster than using a Mutex lock!
	atomic.AddInt64(&counter, 1)
	// Atomically adding 1 again.
	atomic.AddInt64(&counter, 1)

	// Atomically reading the number safely.
	value := atomic.LoadInt64(&counter)

	// Atomically forcefully writing 100 into the counter safely.
	atomic.StoreInt64(&counter, 100)

	// A highly advanced move: "Look at the counter. IF it is exactly 100, then change it to 200 safely." Returns true if it worked.
	swapped := atomic.CompareAndSwap(&counter, 100, 200)
	// Tossing the true/false result into the black hole.
	_ = swapped
// Closing DemonstrateAtomics.
}

// Creating a new function for Contexts.
func DemonstrateContextBasics() {
	// 'context.Background()' builds the master root context. It's an invisible clipboard passed around the program that never cancels and never dies. Every other context builds off of this one.
	ctx := context.Background()

	// 'context.WithCancel()' takes our master clipboard and builds a new linked one. It hands us the new clipboard ('ctx') AND a panic button ('cancel') we can push to kill any task holding this clipboard!
	ctx, cancel := context.WithCancel(ctx)
	// We promise to ALWAYS hit the panic button right before we leave to clean up memory.
	defer cancel()

	// Blasting off a task on a separate track.
	go func() {
		// 'select' is a race track for channel pipes. It listens to multiple pipes at once, and whichever pipe spits out data first, wins!
		select {
		// 'Done()' gives us a pipe that instantly opens if someone pushes the panic button.
		case <-ctx.Done():
			// Printing if the panic button was pushed.
			fmt.Println("Context canceled")
		// 'time.After()' gives us a pipe that waits 5 seconds and then spits out data. If 5 seconds pass before the panic button is pushed, this side wins!
		case <-time.After(5 * time.Second):
			// Printing if we timed out.
			fmt.Println("Timeout")
		// Closing the select race.
		}
	// Closing and launching the track.
	}()

	// The main track sleeps for 1 second.
	time.Sleep(1 * time.Second)
	// We manually press the panic button! This instantly triggers the 'Done()' pipe inside the select race above!
	cancel()
	// Hacky sleep to let the print happen.
	time.Sleep(100 * time.Millisecond)
// Closing DemonstrateContextBasics.
}

// Function showing automatic timeouts.
func DemonstrateContextWithTimeout() error {
	// 'WithTimeout' creates a clipboard that has a built-in time bomb. We set it to automatically press its own panic button after exactly 2 seconds.
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	// Promise to clean up.
	defer cancel()

	// Creating a holding tank pipe for our result.
	result := make(chan int, 1)

	// Blasting off a slow task.
	go func() {
		// The slow task sleeps for 3 whole seconds.
		time.Sleep(3 * time.Second)
		// It tries to shove 42 into the pipe.
		result <- 42
	// Closing and launching the slow task.
	}()

	// Setting up the select race between our result pipe and our time bomb.
	select {
	// Did the slow task finish and shove a number in the pipe?
	case val := <-result:
		// Print it if it won.
		fmt.Printf("Got result: %d\n", val)
		// Return no errors.
		return nil
	// Did the 2-second time bomb explode first?
	case <-ctx.Done():
		// The bomb won. We create an error wrapping the bomb's specific excuse ('ctx.Err()') and return it.
		return fmt.Errorf("operation timeout: %w", ctx.Err())
	// Closing the select race.
	}
// Closing DemonstrateContextWithTimeout.
}

// Function showing absolute deadlines.
func DemonstrateContextWithDeadline() {
	// We use the time tool to figure out the exact clock time 2 seconds from right now.
	deadline := time.Now().Add(2 * time.Second)
	// 'WithDeadline' creates a time bomb that explodes at that exact clock time, rather than a stopwatch duration.
	ctx, cancel := context.WithDeadline(context.Background(), deadline)
	// Promise to clean up.
	defer cancel()

	// Tossing the context into the black hole.
	_ = ctx
// Closing DemonstrateContextWithDeadline.
}

// Function showing how clipboards cascade.
func DemonstrateCancellationPropagation() {
	// Creating a parent clipboard with a panic button.
	parentCtx, parentCancel := context.WithCancel(context.Background())
	// Promise to clean up parent.
	defer parentCancel()

	// We create a child clipboard linked directly to the parent clipboard.
	childCtx, childCancel := context.WithCancel(parentCtx)
	// Promise to clean up child.
	defer childCancel()

	// Blasting off a track holding the CHILD clipboard.
	go func() {
		// Watching the pipes.
		select {
		// If the child clipboard's panic button is pushed.
		case <-childCtx.Done():
			// Print message.
			fmt.Println("Child context canceled (from parent)")
		// Closing select.
		}
	// Closing and launching.
	}()

	// We press the PARENT panic button! Because the child is linked, the signal cascades down and instantly crushes the child clipboard too!
	parentCancel()
	// Hacky sleep.
	time.Sleep(100 * time.Millisecond)
// Closing DemonstrateCancellationPropagation.
}

// A standard rule in Go: always pass the 'ctx' clipboard as the very first input to major functions.
func ProcessRequest(ctx context.Context, data string) error {
	// 'Err()' checks if the clipboard's panic button has already been pushed before we even start working.
	if err := ctx.Err(); err != nil {
		// If it has, immediately give up and hand the error back.
		return err
	// Closing the check.
	}

	// If we're good, pass the clipboard down into the next function doing the real work.
	return doWork(ctx, data)
// Closing ProcessRequest.
}

// The worker function receiving the clipboard.
func doWork(ctx context.Context, data string) error {
	// Select race.
	select {
	// Checking the panic pipe.
	case <-ctx.Done():
		// Give up if panicked.
		return ctx.Err()
	// 'default' in a select means "if no pipes are ready immediately right this second, just run this block and don't freeze".
	default:
		// Doing the actual work here, returning no errors.
		return nil
	// Closing select.
	}
// Closing doWork.
}

// We invent a custom type just for context keys so they never accidentally collide.
type contextKey string

// We create a constant key named 'userIDKey'.
const userIDKey contextKey = "userID"

// Function showing how clipboards carry hidden data.
func DemonstrateContextValues() {
	// 'WithValue' takes a clipboard and tapes a secret sticky note to it! The note has a key ('userIDKey') and a value ("user-123").
	ctx := context.WithValue(context.Background(), userIDKey, "user-123")

	// We ask the clipboard for the sticky note. It hands back a generic cardboard box, so we have to use '.(string)' to safely rip it open and confirm it's text.
	if userID, ok := ctx.Value(userIDKey).(string); ok {
		// If it's there and it's text, we print it.
		fmt.Printf("User ID: %s\n", userID)
	// Closing the extraction check.
	}
// Closing DemonstrateContextValues.
}

// Function showing an advanced tool for grouping errors.
func DemonstrateErrGroup() error {
	// Setting up a 5-second time bomb clipboard.
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	// Promise to clean up.
	defer cancel()

	// Building a pipe holding 2 errors.
	results := make(chan error, 2)

	// Blasting off track 1.
	go func() {
		// Track 1 does work and shoves 'nil' (no errors) into the pipe.
		results <- nil
	// Closing track 1.
	}()

	// Blasting off track 2.
	go func() {
		// Track 2 shoves 'nil' in.
		results <- nil
	// Closing track 2.
	}()

	// Looping exactly twice to catch both answers out of the pipe.
	for i := 0; i < 2; i++ {
		// Catching the error and checking if it's NOT blank.
		if err := <-results; err != nil {
			// If one broke, we immediately fail out.
			return err
		// Closing the check.
		}
	// Closing the catch loop.
	}

	// Tossing the time bomb into the black hole.
	_ = ctx
	// Returning safely.
	return nil
// Closing DemonstrateErrGroup.
}

// Function demonstrating a massive worker pool pattern.
func DemonstrateWorkerPool() {
	// We decide we want exactly 3 workers handling our jobs.
	numWorkers := 3
	// Building a job pipe with a holding tank of 10.
	jobs := make(chan int, 10)
	// Building a results pipe with a holding tank of 10 text strings.
	results := make(chan string, 10)
	// Setting up our club door tally counter.
	var wg sync.WaitGroup

	// Looping to create our 3 workers.
	for w := 1; w <= numWorkers; w++ {
		// Adding 1 to the tally counter for each worker.
		wg.Add(1)
		// Blasting off the worker track and handing it its ID number.
		go func(workerID int) {
			// Promising to subtract from the tally when it dies.
			defer wg.Done()
			// The worker stands at the job pipe and catches EVERY job that comes through, one by one, until the pipe is shut.
			for job := range jobs {
				// The worker formats a text receipt of the job.
				result := fmt.Sprintf("Worker %d processed job %d", workerID, job)
				// Shoves the receipt into the results pipe.
				results <- result
			// Closing the job catch loop.
			}
		// Closing and launching the worker.
		}(w)
	// Closing the worker creation loop.
	}

	// Blasting off a MANAGER track.
	go func() {
		// Manager creates 10 jobs.
		for i := 1; i <= 10; i++ {
			// Manager shoves the job into the pipe for the workers to fight over.
			jobs <- i
		// Closing manager loop.
		}
		// Manager permanently closes the job pipe. This tells all the workers to pack up and go home once they finish their current task!
		close(jobs)
	// Closing manager track.
	}()

	// Blasting off a CLEANER track.
	go func() {
		// Cleaner waits until the tally counter hits zero (meaning all workers have finally gone home).
		wg.Wait()
		// Only THEN does the cleaner permanently shut the results pipe!
		close(results)
	// Closing cleaner track.
	}()

	// The main program stands at the results pipe catching receipts until the cleaner shuts it.
	for result := range results {
		// Tossing receipts in the black hole.
		_ = result
	// Closing results loop.
	}
// Closing DemonstrateWorkerPool.
}

// Function to safely clean up memory leaks.
func DemonstrateGoroutineLeakPrevention() error {
	// 2-second time bomb.
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	// Clean up.
	defer cancel()

	// 'struct{}' is an absolutely empty container taking up ZERO bytes of memory. We build a pipe that passes empty containers around just to act as pure signal flags.
	done := make(chan struct{})

	// Blasting off track.
	go func() {
		// Freezes here waiting for the time bomb panic button.
		<-ctx.Done()
		// Once panicked, shoves a zero-byte signal into the pipe.
		done <- struct{}{}
	// Closing track.
	}()

	// Select race.
	select {
	// Waiting for the zero-byte signal.
	case <-done:
		// Safe cleanup.
		return nil
	// Or waiting 5 seconds.
	case <-time.After(5 * time.Second):
		// If we wait 5 seconds, it means the 2-second bomb failed, and the track is still frozen! Memory leak!
		return fmt.Errorf("goroutine did not exit")
	// Closing race.
	}
// Closing DemonstrateGoroutineLeakPrevention.
}

// The 'main' function is the sacred starting point. When you hit 'Run', the computer skips everything else and dives straight in here!
func main() {
	// Printing a nice header.
	fmt.Println("========== Segment 1: Go Environment & Development Setup ==========")
	// Spawning an artifact container and tossing it in the black hole.
	_ = BuildArtifact{
		// Setting string.
		BinaryPath: "/usr/local/bin/myapp",
		// Setting string.
		ModuleName: "github.com/user/myapp",
		// Setting string.
		Version:    "1.0.0",
		// Setting time.
		Timestamp:  time.Now(),
		// Setting bool.
		IsStatic:   true,
	// Closing artifact.
	}
	// Printing summary.
	fmt.Println("Build artifact and workspace organization demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 2: Core Language Syntax & Type System ==========")
	// Calling our variable recipe.
	DemonstrateVariableDeclaration()
	// Calling our operator recipe.
	DemonstrateOperators()
	// Calling our control flow recipe.
	DemonstrateControlFlow()
	// Summary.
	fmt.Println("Variables, operators, and control flow demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 3: Pointers & Memory Fundamentals ==========")
	// Call pointer basics.
	DemonstratePointerBasics()
	// Call memory alloc.
	DemonstrateMemoryAllocation()
	// Summary.
	fmt.Println("Pointers and memory allocation demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 4: Composite Types Deep Dive ==========")
	// Call arrays.
	DemonstrateArrays()
	// Call slices.
	DemonstrateSlices()
	// Call maps.
	DemonstrateMaps()
	// Call structs.
	DemonstrateStructs()
	// Call strings.
	DemonstrateStrings()
	// Summary.
	fmt.Println("Arrays, slices, maps, structs, and strings demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 5: Functions & Methods ==========")
	// Call funcs.
	DemonstrateFunctions()
	// Building our server configuration passing in custom option functions.
	config := NewServer(WithHost("0.0.0.0"), WithPort(8080))
	// '%v' is a magical format code that means "just look at the data and figure out the best way to print it". We print our config.
	fmt.Printf("Server config: %v\n", config)
	// Summary.
	fmt.Println("Functions, methods, and functional options demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 6: Interfaces & Polymorphism ==========")
	// Call type assertion.
	DemonstrateTypeAssertion("hello")
	// Call type switch.
	DemonstrateTypeSwitch(42)
	// Call nil interface.
	DemonstrateNilInterface()
	// Summary.
	fmt.Println("Interfaces and polymorphism demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 7: Error Handling Patterns ==========")
	// We run our error check, pull the error out, and immediately check if it's not blank using ';' on the same line!
	if err := idiomatic_if_err_not_nil(); err != nil {
		// If an error bubbled up, we print it using '%v'.
		fmt.Printf("Error: %v\n", err)
	// Closing the check.
	}
	// Calling early returns and throwing the answer in the black hole.
	_ = DemonstrateEarlyReturns(20, 50000)
	// Summary.
	fmt.Println("Error handling patterns demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 8: Goroutines & Channels ==========")
	// Call waiting.
	SafeGoroutineWaiting()
	// Call channels.
	RangeOverChannels()
	// Summary.
	fmt.Println("Goroutines and channels demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 9: Synchronization & Race Detection ==========")
	// Call Mutex.
	DemonstrateMutex()
	// Call wait group.
	DemonstrateWaitGroup()
	// Call atomics.
	DemonstrateAtomics()
	// Summary.
	fmt.Println("Synchronization primitives demonstrated.\n")

	// Header.
	fmt.Println("========== Segment 10: Advanced Concurrency with Context ==========")
	// Call contexts.
	DemonstrateContextBasics()
	// Call timeout, toss error.
	_ = DemonstrateContextWithTimeout()
	// Call err group, toss error.
	_ = DemonstrateErrGroup()
	// Call worker pool.
	DemonstrateWorkerPool()
	// Summary.
	fmt.Println("Context, cancellation, and worker pools demonstrated.\n")

	// Final success message.
	fmt.Println("========== All segments completed successfully ==========")
// Closing the main function, terminating the entire program. Great job making it to the end!
}