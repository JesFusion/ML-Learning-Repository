package main

import (
	// "context"
	// "errors"
	"fmt"
	// "io"
	// "strings"
	// "sync"
	// "sync/atomic"
	"time"
	// "unsafe"
)












// ===================================== SEGMENT 1: Go Environment & Development Setup =====================================

type ArtifactCreation struct{
	PathToTheBinary string

	NameOfModule string

	SemanticVersion string

	BinaryBuildTime time.Time

	IsItStaticLinked bool
}



type LayoutOfTheWorkspace struct {
	CommandDirectory string

	PackageDirectory string

	InternalDirectory string

	VendorDirectory string
}











// ===================================== SEGMENT 2: Core Language Syntax & Type System =====================================


type DataTypesInGo struct {
	
	IntegerType int

	Int8DataType int8

	Int32DataType int32
	
	Int64DataType int64

	UintDataType uint
	
	ByteDataType byte // alias for uint8

	Uint64DataType uint64

	// Float32 // DataType

	Float32DataType float32

	Float64DataType float64

	BooleanDataType bool

	string_data_type string

	rune_data_type rune //  for one single unicode character
}





func Segment2Function() {
	
	// fmt.Println("\n\n")
	
	var jesse_age int8 = 20

	var user_name string = "Jesse"
	
	fmt.Printf("%s is %d years old\n", user_name, jesse_age)


	var remaining_money float64

	var is_jesse_cool bool = true

	var this_boolean bool
	
	var goodness_name string = "Goodness Nwachukwu Chimdindu"



	fmt.Printf(`Remaining Money defaults to %v

Is Jesse cool? %v

Default value of this_boolean: %v

goodness name is %v
	`,
		remaining_money,
		is_jesse_cool,
		this_boolean,
		goodness_name,
	)

	var empty_string string

	var empty_integer int

	var empty_pointer *int

	fmt.Printf(`
Default Value of Empty String: %v

Default Value of Empty Integer: %v

Default Value of Empty Pointer: %v

	`, 
		empty_string,
		empty_integer,
		empty_pointer,
	)

	var2 := "This is a cup"

	integer2 := 2026

	pi_value := 3.142894228462842847

	const constant_value = 20

	const api_timeout_duration = 45 * time.Second

	fmt.Printf("Duration to API Timeout is %v", api_timeout_duration)

	const value_of_PI = 3.14159265359

	int_guess := 192

	float_guess := 102.3243

	string_guess := "kettle"

	rune_guess := 'l' // Using single quotes automatically tells Go to treat this as a single 'rune' character

	complex_number_guess := 2.3 - 0.45i

	float_value := float64(integer2)

	float_2 := float32(jesse_age)

	string_conversion := fmt.Sprintf("Jesse is %d years old", jesse_age)


	_ = int_guess

	_ = var2

	_ = pi_value
	
	_ = float_guess

	_ = string_guess
	
	_ = rune_guess

	_ = complex_number_guess

	_ = float_value

	_ = float_2

	_ = string_conversion






}










func main() {
	
	Segment2Function()

}














































































































































































































































































