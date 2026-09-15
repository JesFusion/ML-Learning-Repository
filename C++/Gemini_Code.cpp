// ================================================================================
// C++ FOR ROBOTICS: SEGMENT 1.2, 1.3, 1.4 BUILD
// Variables, Types, Operators, and Control Flow in Production
// ================================================================================

// 💡 CodeDude: `#include` tells the preprocessor to copy-paste the contents of a library right here before compiling.
// 💡 CodeDude: `<iostream>` is the standard Input/Output Stream library. It gives us the tools to print text to the console (like std::cout).
#include <iostream>
// 💡 CodeDude: `<cstdint>` gives us fixed-width integers (like uint8_t). This guarantees that our data sizes remain exactly the same no matter what CPU runs this code.
#include <cstdint>
// 💡 CodeDude: `<iomanip>` provides Input/Output Manipulators. We use it to format our terminal output neatly (like printing numbers in hex format).
#include <iomanip>

// [WHAT]
// Namespace to avoid polluting global scope; idiomatic in large robotics codebases
// [WHY]
// Prevents naming conflicts when integrating multiple hardware driver libraries
// [HOW]
// All mock hardware functions and types live inside this namespace

// 💡 CodeDude: `namespace RobotHW` creates a named scope. Think of it like a folder. It ensures our "MotorState" doesn't clash with another "MotorState" from an external library.
namespace RobotHW {

    // ============================================================================
    // SEGMENT 1.2: VARIABLES, TYPES, AND BIT-WIDTH DISCIPLINE
    // ============================================================================
    // [WHAT]
    // Fixed-width integer types from <cstdint> for guaranteed hardware register compatibility
    // [WHY]
    // Platform-dependent types (int, long) cause portability nightmares across x86, ARM, bare-metal
    // [HOW]
    // Define all sensor data structures using uint8_t, int16_t, uint32_t, etc. with explicit bit-widths

    // [PREPROCESSOR DIRECTIVE MEANING]
    // constexpr = Compile-time constant; compiler evaluates at build-time, not runtime
    // Zero cost on actual hardware (value is inlined wherever used)

    // 💡 CodeDude: `constexpr` means "calculate this before the program even runs". It costs zero CPU cycles during execution.
    // 💡 CodeDude: `uint16_t` is an unsigned (positive only) 16-bit integer. `MAX_MOTOR_RPM` is the variable name, assigned the value `4000`.
    constexpr uint16_t MAX_MOTOR_RPM = 4000;
    // 💡 CodeDude: Another compile-time constant, unsigned 16-bit, representing the minimum RPM (0).
    constexpr uint16_t MIN_MOTOR_RPM = 0;
    // 💡 CodeDude: `uint8_t` is an unsigned 8-bit integer (max value 255). Perfect for small numbers like a motor count.
    constexpr uint8_t NUM_MOTORS = 4;
    // 💡 CodeDude: The max PWM value, fitting perfectly into an 8-bit unsigned integer (255 is the literal max of 8 bits).
    constexpr uint8_t MOTOR_PWM_MAX = 255;

    // [WHAT]
    // Mock motor state structure modeling a real DC brushed motor's internal state
    // [WHY]
    // Encapsulates fixed-width types in a struct to verify sizeof() and memory footprint
    // [HOW]
    // Each member is a fixed-width type guaranteed portable across platforms

    // 💡 CodeDude: `struct` is a blueprint for a custom data type. It lets us bundle a bunch of related variables together into a single, neat package.
    struct MotorState {
        // 💡 CodeDude: `uint16_t` guarantees 2 bytes of memory are allocated for the target speed.
        uint16_t target_rpm;         // [CPP-Robotics-1.2.H] uint16_t: 0–65,535 RPM
        // 💡 CodeDude: Same here, 2 bytes for the measured speed.
        uint16_t current_rpm;        // Actual measured speed via encoder
        // 💡 CodeDude: `uint8_t` takes exactly 1 byte. Represents Pulse Width Modulation (0 to 255).
        uint8_t pwm_duty;            // [CPP-Robotics-1.2.F] uint8_t: 0–255 (0–100% duty cycle)
        // 💡 CodeDude: `int16_t` is a SIGNED 16-bit integer. Signed means it can go negative, which is crucial if the motor spins backwards!
        int16_t encoder_ticks;       // [CPP-Robotics-1.2.I] int16_t: signed encoder position delta
        // 💡 CodeDude: 1 byte representing raw binary data straight from the hardware registers.
        uint8_t status_byte;         // Hardware register snapshot (will parse with bitwise ops)
        // 💡 CodeDude: `bool` is a true/false flag. It usually takes 1 byte of memory under the hood.
        bool fault_flag;             // [CPP-Robotics-1.2.E] bool: hardware operation success/failure
    // 💡 CodeDude: The semicolon here is mandatory. It tells the compiler "I'm done defining this blueprint."
    };

    // [WHAT]
    // Global array of motor states (one per motor); static means internal linkage (file-scoped)
    // [WHY]
    // Simulates persistent hardware state across loop iterations (real scenario: ISR updates these)
    // [HOW]
    // static initializes once; static duration means values persist until program exit

    // 💡 CodeDude: `static` here means this memory is allocated once and lives forever until the program dies. It's also restricted to this specific file.
    // 💡 CodeDude: `MotorState motors[NUM_MOTORS]` creates an array (a list) holding 4 instances of our custom struct.
    // 💡 CodeDude: The `{ {..}, {..} }` syntax is an initializer list, setting the default values for each struct in the array right out of the gate.
    static MotorState motors[NUM_MOTORS] = {
        // 💡 CodeDude: Initializing Motor 0: 0 target, 0 current, 0 PWM, 0 ticks, 0x00 hex status, false fault flag.
        {0, 0, 0, 0, 0x00, false},   // Motor 0: idle, no faults
        // 💡 CodeDude: Initializing Motor 1 with the same default zeroes.
        {0, 0, 0, 0, 0x00, false},   // Motor 1: idle, no faults
        // 💡 CodeDude: Initializing Motor 2.
        {0, 0, 0, 0, 0x00, false},   // Motor 2: idle, no faults
        // 💡 CodeDude: Initializing Motor 3.
        {0, 0, 0, 0, 0x00, false},   // Motor 3: idle, no faults
    // 💡 CodeDude: Semicolon ends the array initialization.
    };

    // [WHAT]
    // Mock hardware status byte from a CAN bus or SPI register
    // Bit layout: [7:4] = ERROR_CODE | [3:0] = MOTOR_STATUS
    // [WHY]
    // Real sensor packets arrive this way; firmware must parse bit fields
    // [HOW]
    // Global variable representing latest hardware register value; updated by ISR in real code

    // 💡 CodeDude: Creating a single static byte to pretend it's a piece of hardware. `0x23` is hexadecimal format.
    // 💡 CodeDude: In binary, 0x23 is exactly `00100011`.
    static uint8_t sensor_status_register = 0x23;  // 0010_0011 binary: error bits + status bits

    // [WHAT]
    // Mock encoder raw tick data from a quadrature encoder
    // [WHY]
    // Sensors produce integer counts; must convert to RPM using scaling
    // [HOW]
    // uint16_t large enough for typical encoder tick rates (0–65,535 ticks per sample)

    // 💡 CodeDude: A static 16-bit integer holding dummy data (512) for our simulated encoder.
    static uint16_t encoder_raw_counts = 512;      // Raw encoder sample

    // [WHAT]
    // Scaling constant to convert raw encoder ticks to RPM
    // [WHY]
    // constexpr ensures compile-time evaluation; no runtime division in tight loops
    // [HOW]
    // Pre-compute scale factor (ticks-per-revolution × sample-rate) offline

    // 💡 CodeDude: `constexpr float` creates a compile-time decimal number. The `f` at the end of `0.5f` tells the compiler "this is explicitly a float, not a double".
    constexpr float ENCODER_COUNTS_TO_RPM = 0.5f;  // Assumes 1024 ticks/rev, 2 samples/sec

    // ============================================================================
    // Mock hardware read function: simulates SPI/CAN register read
    // ===================================================
    // [WHAT]
    // Mock function that returns the latest sensor status byte from hardware register
    // [WHY]
    // Isolates hardware I/O (slow, non-deterministic) from firmware logic
    // [HOW]
    // In real code, this would do: return *(volatile uint32_t*)0x40020010 (memory-mapped I/O)

    // 💡 CodeDude: This defines a function named `read_motor_status_register`. It expects an 8-bit `motor_id` as input, and promises to return an 8-bit unsigned integer (`uint8_t`) back to whoever called it.
    uint8_t read_motor_status_register(uint8_t motor_id) {
        // [WATCH OUT]
        // Real code would use volatile to prevent compiler from caching the register value
        // Compiler without volatile would optimize: uint8_t status = register; while (status == old) {...}
        // Infinite loop because compiler "knows" register can't change without assignment
        
        // 💡 CodeDude: `return` immediately exits the function and spits this variable's value back out to the caller.
        return sensor_status_register;
    // 💡 CodeDude: Closing brace signals the end of the function's scope.
    }

    // [WHAT]
    // Mock function to read encoder ticks from motor
    // [WHY]
    // Encoder is critical feedback for speed/position control
    // [HOW]
    // Real code would read hardware counter register; we simulate with static variable

    // 💡 CodeDude: Function declaration. Returns a 16-bit int, takes an 8-bit motor ID.
    uint16_t read_encoder_ticks(uint8_t motor_id) {
        // 💡 CodeDude: Spits out our mock data (512).
        return encoder_raw_counts;
    // 💡 CodeDude: Ends the function.
    }

    // ============================================================================
    // SEGMENT 1.3: OPERATORS, EXPRESSIONS, AND BITWISE HARDWARE CONTROL
    // ============================================================================
    // [WHAT]
    // Extract motor status code from lower 4 bits of status_byte using bitwise AND
    // [WHY]
    // Hardware registers are packed (multiple fields in one byte); must use bitmasking
    // [HOW]
    // AND with 0x0F (0000_1111) isolates bits [3:0]; higher bits become zero

    // [FUNCTION MEANING]
    // extract_motor_status() = Isolates motor status bits from CAN/SPI register byte

    // 💡 CodeDude: Function definition returning an 8-bit unsigned integer, taking an 8-bit status byte as input.
    uint8_t extract_motor_status(uint8_t status_byte) {
        // [CPP-Robotics-1.3.A] & = Bitwise AND; mask to get lower 4 bits
        // 💡 CodeDude: The bitwise AND `&` compares two binary numbers. If both bits are 1, the result is 1. Otherwise, 0. 
        // 💡 CodeDude: By ANDing with `0x0F` (which is `00001111`), we forcefully crush the top 4 bits to zeroes, leaving only the bottom 4 bits intact. We save this into `status_code`.
        uint8_t status_code = status_byte & 0x0F;  // 0x23 & 0x0F = 0x03 (00000011)
        
        // 💡 CodeDude: Gives the isolated bits back to the caller.
        return status_code;
    // 💡 CodeDude: End of function.
    }

    // [WHAT]
    // Extract error code from upper 4 bits of status_byte using shift + mask
    // [WHY]
    // Error state is in bits [7:4]; must shift right to align for interpretation
    // [HOW]
    // Shift right 4 positions, then mask lower 4 bits of result

    // 💡 CodeDude: Function to grab the upper half of a byte.
    uint8_t extract_error_code(uint8_t status_byte) {
        // [CPP-Robotics-1.3.F] >> = Right shift; shifts bits right by N positions (divide by 2^N)
        // 0x23 >> 4 = 0x02 (shifted right 4 positions)
        // Then & 0x0F ensures we have only 4 bits (redundant here but good practice)
        
        // 💡 CodeDude: First, `(status_byte >> 4)` pushes all the bits to the right by 4 spaces. The old top 4 bits are now the bottom 4 bits!
        // 💡 CodeDude: Then we bitwise AND `&` with `0x0F` just to be absolutely safe and ensure the top 4 bits are zeroes. We assign this to `error_code`.
        uint8_t error_code = (status_byte >> 4) & 0x0F;
        
        // 💡 CodeDude: Returns our perfectly isolated error code.
        return error_code;
    // 💡 CodeDude: End of function.
    }

    // [WHAT]
    // Set a specific bit in a GPIO register without affecting others
    // [WHY]
    // Motor enable/disable is often a single GPIO pin; must not toggle unrelated pins
    // [HOW]
    // OR with a mask containing 1 in the target position; all other bits unchanged

    // 💡 CodeDude: `void` means this function returns absolutely nothing.
    // 💡 CodeDude: The `&` in `uint8_t& gpio_register` is critical! It means "Pass by Reference". We aren't working with a copy; we are directly modifying the original variable handed to this function.
    void set_gpio_pin(uint8_t& gpio_register, uint8_t pin_number) {
        // [CPP-Robotics-1.3.B] |= = Bitwise OR assignment; sets bits
        // (1 << pin_number) creates mask with 1 in position pin_number (e.g., 1 << 2 = 0x04)
        // OR with existing register: if bit was 0, becomes 1; if 1, stays 1
        
        // 💡 CodeDude: `(1 << pin_number)` takes binary `00000001` and slides the `1` to the left. If pin_number is 2, it becomes `00000100`.
        // 💡 CodeDude: `|=` is Bitwise OR Assignment. It overlays our shifted '1' onto the register. Any bit that is a 1 in either number becomes a 1. It turns the pin ON without touching the others.
        // 💡 CodeDude: `(uint8_t)` explicitly casts the math result back to an 8-bit unsigned integer to keep the compiler happy.
        gpio_register |= (uint8_t)(1 << pin_number);
    // 💡 CodeDude: End of function.
    }

    // [WHAT]
    // Clear a specific bit in a GPIO register
    // [WHY]
    // Motor disable requires clearing a single control pin
    // [HOW]
    // AND with the complement of a mask (clears target bit, preserves others)

    // 💡 CodeDude: Another `void` function utilizing Pass by Reference (`&`).
    void clear_gpio_pin(uint8_t& gpio_register, uint8_t pin_number) {
        // [CPP-Robotics-1.3.D] ~ = Bitwise NOT; inverts all bits
        // [CPP-Robotics-1.3.G] &= = Bitwise AND assignment; clears bits
        // ~(1 << pin_number) = NOT(mask) = all 1s except target position
        // AND with register: target bit becomes 0; others unchanged
        
        // 💡 CodeDude: `(1 << pin_number)` makes our target bit 1. The bitwise NOT `~` flips EVERYTHING. So `00000100` becomes `11111011`.
        // 💡 CodeDude: `&=` is Bitwise AND Assignment. Applying `11111011` with AND means all the `1`s leave existing bits alone, but the one `0` forces the target bit to turn OFF.
        gpio_register &= (uint8_t)(~(1 << pin_number));
    // 💡 CodeDude: End of function.
    }

    // [WHAT]
    // Toggle a bit (1→0, 0→1) in a control register using XOR
    // [WHY]
    // ISR might need to toggle a heartbeat LED or acknowledge interrupt
    // [HOW]
    // XOR with a mask flips the target bit; leaves others unchanged

    // 💡 CodeDude: Void function, modifying the passed-in reference.
    void toggle_bit(uint8_t& register_value, uint8_t bit_position) {
        // [CPP-Robotics-1.3.C] ^ = Bitwise XOR; toggles bits
        // (1 << bit_position) = mask with 1 in target position
        // XOR: 1 XOR 1 = 0, 0 XOR 1 = 1 (toggles)
        
        // 💡 CodeDude: `^=` is Bitwise XOR Assignment. Exclusive OR (XOR) says "If the bits are DIFFERENT, the result is 1. If they are the SAME, result is 0."
        // 💡 CodeDude: By XORing against a shifted `1`, if the current bit is 1, it becomes 0. If it's 0, it becomes 1. A perfect toggle switch!
        register_value ^= (uint8_t)(1 << bit_position);
    // 💡 CodeDude: End of function.
    }

    // [WHAT]
    // Compute PWM duty cycle from error signal using scaling (arithmetic + bitwise)
    // [WHY]
    // PID output (error) must be scaled to PWM register value (0–255)
    // [HOW]
    // Multiply error by gain, clamp to valid range, cast to uint8_t

    // 💡 CodeDude: Function returning an 8-bit unsigned int. Takes a signed 16-bit error (can be negative) and a floating-point gain.
    uint8_t compute_pwm_from_error(int16_t error, float proportional_gain) {
        // [CPP-Robotics-1.3.N] * = Arithmetic multiplication; scales error by gain
        // 💡 CodeDude: Standard multiplication. We multiply our error by our tuning dial (`proportional_gain`) and store it as a decimal (`float`).
        float pwm_float = error * proportional_gain;
        
        // [CPP-Robotics-1.2.V] static_cast<T>() = Safe type conversion
        // Convert float to int32_t for comparison (avoid float-to-uint8_t narrowing)
        // 💡 CodeDude: `static_cast<int32_t>` tells C++ to explicitly and safely convert our float into a 32-bit signed integer. This chops off any decimal points.
        int32_t pwm_int = static_cast<int32_t>(pwm_float);
        
        // Clamp to [0, 255] range (prevent overflow)
        // [WATCH OUT]
        // Overflow in PWM duty cycle calculation is silent killer in motor control
        // Without clamping: error=500, gain=1.0 → pwm_float=500.0 → cast to uint8_t wraps to garbage
        
        // 💡 CodeDude: `if` statement checks a condition. If `pwm_int` is less than 0, we forcefully set it to 0. (Can't have negative power in this context).
        if (pwm_int < 0) pwm_int = 0;
        // 💡 CodeDude: If `pwm_int` is greater than 255 (our hardware limit), we cap it at exactly 255. This is called "clamping".
        if (pwm_int > 255) pwm_int = 255;
        
        // 💡 CodeDude: Now that we know it's safely between 0 and 255, we `static_cast` it to a tiny 8-bit unsigned int and return it.
        return static_cast<uint8_t>(pwm_int);
    // 💡 CodeDude: End of function.
    }

    // ============================================================================
    // SEGMENT 1.4: CONTROL FLOW FOR REAL-TIME DECISION LOGIC
    // ============================================================================
    // [WHAT]
    // Robot state enumeration: discrete states the motor controller can occupy
    // [WHY]
    // State machines eliminate spaghetti if/else chains; clear state transitions
    // [HOW]
    // enum class prevents accidental implicit conversions; scoped names (RobotState::RUNNING)

    // 💡 CodeDude: `enum class` creates a strongly-typed list of constants. You can't accidentally mix these up with regular numbers.
    // 💡 CodeDude: `: uint8_t` is the "underlying type". It forces the compiler to store these states taking up only 1 byte of memory.
    enum class RobotState : uint8_t {
        // 💡 CodeDude: Assigns the human-readable label `IDLE` to the underlying value of 0.
        IDLE            = 0,  // Motors disabled; waiting for command
        // 💡 CodeDude: Label `RUNNING` equals 1.
        RUNNING         = 1,  // Normal operation; executing setpoint
        // 💡 CodeDude: Label `FAULT` equals 2.
        FAULT           = 2,  // Error detected (stall, overheat, sensor loss); safe mode
        // 💡 CodeDude: Label `EMERGENCY_STOP` equals 3.
        EMERGENCY_STOP  = 3   // E-stop triggered; immediate power cutoff
    // 💡 CodeDude: Semicolon is required to finish the enum definition.
    };

    // [WHAT]
    // Global robot state variable; updated by control loop and ISRs
    // [WHY]
    // Single source of truth for what the robot is doing; read in every control iteration
    // [HOW]
    // static duration means value persists across loop iterations

    // 💡 CodeDude: Creates a static (long-living, file-scoped) variable named `current_state` of type `RobotState`.
    // 💡 CodeDude: We initialize it right away to `RobotState::IDLE` using the `::` scope resolution operator.
    static RobotState current_state = RobotState::IDLE;

    // [FUNCTION MEANING]
    // check_motor_faults() = Examines sensor data to detect fault conditions (stall, overheat)
    // [WHAT]
    // Detect fault conditions from sensor status and encoder feedback
    // [WHY]
    // Early detection prevents hardware damage; allows graceful shutdown
    // [HOW]
    // Compare sensor readings against thresholds using if/else if chain

    // 💡 CodeDude: A function returning a `bool` (true/false).
    // 💡 CodeDude: The `const` in `const MotorState&` is a promise: "I will read this data, but I swear I won't change it." The `&` means we read the original directly, avoiding a memory-heavy copy.
    bool check_motor_faults(uint8_t motor_id, const MotorState& motor) {
        // 💡 CodeDude: Calls our extraction function and stores the result in an 8-bit integer.
        uint8_t error_code = extract_error_code(motor.status_byte);
        
        // [CPP-Robotics-1.4.B] else if = Chained conditional for multi-way fault detection
        // [WATCH OUT]
        // Order matters: check most critical faults first (safety interlocks)
        
        // [CPP-Robotics-1.3.S] < = Less-than comparison; boundary checking
        // 💡 CodeDude: The `if` keyword evaluates a condition. `>` is the greater-than operator. We check if they requested more RPMs than the hardware physically supports.
        if (motor.target_rpm > MAX_MOTOR_RPM) {
            // Command exceeds hardware limit
            // 💡 CodeDude: `std::cout` prints to terminal. We chain strings and variables together using `<<`. We cast `motor_id` to an `(int)` so the console prints it as a number instead of a weird ASCII character.
            std::cout << "    [FAULT] Motor " << (int)motor_id << ": target RPM (" << motor.target_rpm << ") exceeds MAX (" << MAX_MOTOR_RPM << ")\n";
            // 💡 CodeDude: `return true;` instantly exits the function, signaling that a fault WAS found.
            return true;
        // 💡 CodeDude: Closes the scope of the first `if` block.
        }
        
        // [CPP-Robotics-1.3.R] != = Inequality comparison; detect sensor loss
        // 💡 CodeDude: `else if` runs ONLY if the first `if` was false. `!=` means "is NOT equal to". We are checking if the hardware reported any errors.
        else if (error_code != 0) {
            // Non-zero error code from hardware (sensor fault, CAN timeout, overheat)
            // 💡 CodeDude: Prints out the specific hardware error code to the console.
            std::cout << "    [FAULT] Motor " << (int)motor_id << ": hardware error code " << (int)error_code << "\n";
            // 💡 CodeDude: Exits and reports a fault.
            return true;
        // 💡 CodeDude: Closes the scope of this `else if`.
        }
        
        // [CPP-Robotics-1.3.T] > = Greater-than comparison; threshold detection
        // 💡 CodeDude: Another `else if` fallback. Checks if the physical motor is spinning dangerously fast (runaway).
        else if (motor.current_rpm > MAX_MOTOR_RPM) {
            // Measured speed exceeds limit (speed runaway)
            // 💡 CodeDude: Alerts the terminal.
            std::cout << "    [FAULT] Motor " << (int)motor_id << ": current RPM (" << motor.current_rpm << ") exceeds max\n";
            // 💡 CodeDude: Exits and reports a fault.
            return true;
        // 💡 CodeDude: Closes the scope.
        }
        
        // [CPP-Robotics-1.4.C] else = Default case; all checks passed
        // 💡 CodeDude: `else` is the catch-all. If EVERYTHING above was false, this block executes.
        else {
            // 💡 CodeDude: Exits and reports false (meaning NO faults found, everything is perfectly fine).
            return false;
        // 💡 CodeDude: Closes the `else` scope.
        }
    // 💡 CodeDude: Ends the `check_motor_faults` function.
    }

    // [FUNCTION MEANING]
    // update_motor_pwm() = Compute PWM command from error and write to hardware
    // [WHAT]
    // Core control loop: read encoder, compute error, apply PWM
    // [WHY]
    // Runs at 1 kHz; tight loop; every instruction counts for determinism
    // [HOW]
    // if/else for state dispatch; switch for error handling inside RUNNING state

    // 💡 CodeDude: A `void` function handling the core math for a specific motor and setpoint.
    void update_motor_pwm(uint8_t motor_id, uint16_t setpoint_rpm) {
        // 💡 CodeDude: We create a reference (`&`) named `motor` that points directly to the specific motor inside our global array `motors[motor_id]`. This saves typing and avoids copying.
        MotorState& motor = motors[motor_id];
        
        // Update encoder reading
        // 💡 CodeDude: Calls our mock function to grab hardware data and stores it in `raw_counts`.
        uint16_t raw_counts = read_encoder_ticks(motor_id);
        // 💡 CodeDude: Safely casts that unsigned count into a signed 16-bit integer, storing it in the motor's struct.
        motor.encoder_ticks = static_cast<int16_t>(raw_counts);
        
        // Convert encoder counts to RPM using fixed-point approximation
        // [CPP-Robotics-1.3.N] * = Multiplication; scaling factor
        // 💡 CodeDude: Multiplies the raw counts by our float conversion factor (0.5f). Then `static_cast` neatly chops off the decimals and stores it as an unsigned 16-bit int.
        motor.current_rpm = static_cast<uint16_t>(raw_counts * ENCODER_COUNTS_TO_RPM);
        
        // Store latest status register snapshot
        // 💡 CodeDude: Grabs the hardware byte and stores it inside our struct.
        motor.status_byte = read_motor_status_register(motor_id);
        
        // Compute error term (signed: negative if too slow, positive if too fast)
        // [CPP-Robotics-1.3.M] - = Subtraction; error computation (setpoint - measurement)
        // 💡 CodeDude: We cast both unsigned RPMs to signed `int16_t` BEFORE subtracting. Why? If you subtract a big unsigned number from a small one, it wraps around to a massive positive number! Signed math allows negative error values.
        int16_t speed_error = static_cast<int16_t>(setpoint_rpm) - static_cast<int16_t>(motor.current_rpm);
        
        // Apply PID proportional term (simplified: P only)
        // 💡 CodeDude: A compile-time float constant for our "P" tuning dial.
        constexpr float PROPORTIONAL_GAIN = 0.1f;
        // 💡 CodeDude: Calls our complex clamping function from earlier, saving the safe 0-255 result directly into the struct's `pwm_duty` variable.
        motor.pwm_duty = compute_pwm_from_error(speed_error, PROPORTIONAL_GAIN);
        
        // Fault detection
        // 💡 CodeDude: Finally, runs our safety check function. It evaluates to true or false, and updates the struct's `fault_flag` immediately.
        motor.fault_flag = check_motor_faults(motor_id, motor);
    // 💡 CodeDude: Ends the `update_motor_pwm` function.
    }

    // [FUNCTION MEANING]
    // run_state_machine() = FSM dispatcher; executes behavior based on current_state
    // [WHAT]
    // Robot state machine: IDLE → RUNNING (on command) → FAULT (on error) → IDLE (on reset)
    // [WHY]
    // Clear state transitions prevent undefined behavior in safety-critical code
    // [HOW]
    // switch statement compiles to jump table (O(1) dispatch); no chain of if/else

    // 💡 CodeDude: Main loop function. No inputs, no returns. It just drives the robot's logic.
    void run_state_machine() {
        // [CPP-Robotics-1.4.D] switch = Multi-way branching on enum value
        // Compiler generates jump table: current_state determines which case executes
        // Much faster than if/else if chain (especially with 4+ states)
        
        // 💡 CodeDude: `switch` looks at the value of `current_state`. Instead of evaluating conditions one by one, the compiler creates a map and jumps directly to the matching `case` block. Super fast!
        switch (current_state) {
            
            // [CPP-Robotics-1.4.E] case = Label for a specific enum value
            // 💡 CodeDude: If `current_state` is `IDLE`, execution instantly jumps to here. The `{` creates a local scope for this case.
            case RobotState::IDLE: {
                // Motors are disabled; waiting for user command
                // 💡 CodeDude: Prints our current state to the console.
                std::cout << "    [STATE] IDLE: Motors disabled. Waiting for command...\n";
                
                // In real code: check for joystick input or network command
                // Simulate: if we see a target setpoint, transition to RUNNING
                // 💡 CodeDude: Checks if the user told Motor 0 to move.
                if (motors[0].target_rpm > 0) {
                    // 💡 CodeDude: Assignment operator `=`. We change the global state to `RUNNING`. On the next cycle, the switch statement will jump to a different case!
                    current_state = RobotState::RUNNING;
                    // 💡 CodeDude: Logs the transition.
                    std::cout << "    [TRANSITION] IDLE → RUNNING\n";
                // 💡 CodeDude: Ends the `if` block.
                }
                // [CPP-Robotics-1.4.J] break = Exit switch case
                // 💡 CodeDude: `break;` is CRUCIAL. It tells the code to escape the `switch` statement immediately. If you forget this, it "falls through" and starts executing the `RUNNING` case code directly below it!
                break;  
            // 💡 CodeDude: Ends the `IDLE` case scope.
            }
            
            // 💡 CodeDude: If `current_state` is `RUNNING`, it jumps here.
            case RobotState::RUNNING: {
                // Normal operation: update all motor PWM commands
                // 💡 CodeDude: Logs our state.
                std::cout << "    [STATE] RUNNING: Executing motor commands...\n";
                
                // [CPP-Robotics-1.4.I] for = Counter-controlled loop; iterate over motors
                // [WATCH OUT]
                // Nested loops in real-time path; every iteration matters
                // Compiler unrolling this loop with -O3 helps avoid pipeline stalls
                
                // 💡 CodeDude: A classic `for` loop. We create a counter `i` starting at 0. It repeats as long as `i < NUM_MOTORS`. After every loop, `i++` increments `i` by 1.
                for (uint8_t i = 0; i < NUM_MOTORS; i++) {
                    // 💡 CodeDude: Calls our big math function, passing the loop counter `i` as the motor ID, and that specific motor's target RPM.
                    update_motor_pwm(i, motors[i].target_rpm);
                    
                    // Check if this motor faulted
                    // 💡 CodeDude: Reads the boolean flag we just calculated. If it's true, we have a huge problem.
                    if (motors[i].fault_flag) {
                        // 💡 CodeDude: Immediately kicks the robot into the `FAULT` state.
                        current_state = RobotState::FAULT;
                        // 💡 CodeDude: Logs the failure and which motor caused it.
                        std::cout << "    [TRANSITION] RUNNING → FAULT (motor " << (int)i << " faulted)\n";
                        // 💡 CodeDude: `break;` here is inside a loop, so it breaks OUT of the `for` loop early! We don't bother calculating the rest of the motors because the robot is already dead.
                        break;  // Exit loop; handle fault in next iteration
                    // 💡 CodeDude: Closes the `if` block.
                    }
                // 💡 CodeDude: Closes the `for` loop.
                }
                // 💡 CodeDude: The switch `break;`. Prevents falling through into the `FAULT` case code below.
                break;
            // 💡 CodeDude: Ends the `RUNNING` case scope.
            }
            
            // 💡 CodeDude: If `current_state` is `FAULT`, jump here.
            case RobotState::FAULT: {
                // Safe shutdown: disable all motors, log diagnostics
                // 💡 CodeDude: Logging.
                std::cout << "    [STATE] FAULT: Disabling motors. Diagnostics:\n";
                
                // [CPP-Robotics-1.4.I] for = Loop over all motors
                // 💡 CodeDude: Another `for` loop traversing all 4 motors.
                for (uint8_t i = 0; i < NUM_MOTORS; i++) {
                    // 💡 CodeDude: `.` is the member access operator. We dive into the struct and forcefully zero out its target.
                    motors[i].target_rpm = 0;     // Clear setpoint
                    // 💡 CodeDude: Forcefully kill power (PWM = 0).
                    motors[i].pwm_duty = 0;       // PWM = 0 (motor off)
                    // 💡 CodeDude: Clear the fault flag so we can eventually recover.
                    motors[i].fault_flag = false; // Clear flag for next reset
                // 💡 CodeDude: Closes the cleanup `for` loop.
                }
                
                // In real code: write diagnostics to EEPROM, notify master controller via CAN
                // 💡 CodeDude: Console log.
                std::cout << "    [ACTION] All motors disabled. Awaiting reset command...\n";
                
                // Transition back to IDLE only on explicit reset (e.g., watchdog timeout, manual reset)
                // Simulate: always reset after one iteration for demo
                // 💡 CodeDude: Magically transitioning back to `IDLE` to keep our demo moving.
                current_state = RobotState::IDLE;
                // 💡 CodeDude: Console log.
                std::cout << "    [TRANSITION] FAULT → IDLE (auto-reset for demo)\n";
                // 💡 CodeDude: Escapes the switch statement.
                break;
            // 💡 CodeDude: Closes the `FAULT` case scope.
            }
            
            // 💡 CodeDude: The worst case scenario. Total system E-stop.
            case RobotState::EMERGENCY_STOP: {
                // E-stop triggered: immediate power cutoff, no cleanup
                // 💡 CodeDude: Panic log.
                std::cout << "    [STATE] EMERGENCY_STOP: Power cut. Manual restart required.\n";
                
                // Disable all motors immediately (no graceful deceleration)
                // 💡 CodeDude: Loop over motors.
                for (uint8_t i = 0; i < NUM_MOTORS; i++) {
                    // 💡 CodeDude: Cut power instantly. Notice we don't bother clearing errors or targets here. The robot is completely locked up on purpose.
                    motors[i].pwm_duty = 0;
                // 💡 CodeDude: Ends the loop.
                }
                
                // Halt further execution (in real code, loop exits, ISRs stop firing)
                // For demo: stay in EMERGENCY_STOP forever
                // 💡 CodeDude: Escapes switch. Because we never change `current_state`, the next cycle will jump right back into `EMERGENCY_STOP`.
                break;
            // 💡 CodeDude: Closes the `EMERGENCY_STOP` case scope.
            }
            
            // [CPP-Robotics-1.4.F] default = Fallback case if state is undefined
            // [WATCH OUT]
            // Catching unhandled state values (sign of bugs in state machine)
            
            // 💡 CodeDude: `default:` is the safety net. If memory corrupts and `current_state` somehow becomes '99', it falls in here instead of crashing the processor.
            default: {
                // 💡 CodeDude: Prints a loud error, casting the bad state to an integer so we can see what garbage number caused it.
                std::cout << "    [ERROR] Unknown state: " << static_cast<int>(current_state) << "\n";
                // 💡 CodeDude: Forcibly shoves the system back to a known, safe state (`IDLE`).
                current_state = RobotState::IDLE;  // Safe fallback
                // 💡 CodeDude: Escapes switch.
                break;
            // 💡 CodeDude: Closes `default` scope.
            }
        // 💡 CodeDude: Closes the entire `switch` statement.
        }
    // 💡 CodeDude: Closes the `run_state_machine` function.
    }

// 💡 CodeDude: Closes our `RobotHW` folder/namespace scope.
}  // namespace RobotHW

// ============================================================================
// MAIN: Demonstration of Segments 1.2, 1.3, 1.4 in Production Context
// ============================================================================

// 💡 CodeDude: `int main()` is the starting line! Every C++ program begins its execution exactly here. It returns an integer back to the Operating System when it finishes.
int main() {
    // 💡 CodeDude: Generates a string of 80 equal signs for a pretty header, then prints a newline (`\n`).
    std::cout << "\n" << std::string(80, '=') << "\n";
    // 💡 CodeDude: Prints standard string text.
    std::cout << "C++ ROBOTICS: SEGMENTS 1.2, 1.3, 1.4 DEMONSTRATION\n";
    // 💡 CodeDude: More string printing.
    std::cout << "Variables, Types, Operators, Control Flow\n";
    // 💡 CodeDude: Bottom border of the header block.
    std::cout << std::string(80, '=') << "\n\n";

    // ========================================================================
    // SEGMENT 1.2 DEMONSTRATION: Variables, Types, Bit-Width Discipline
    // ========================================================================
    // 💡 CodeDude: Prints a dashed line for section separation.
    std::cout << "\n" << std::string(80, '-') << "\n";
    // 💡 CodeDude: Prints text.
    std::cout << "SEGMENT 1.2: VARIABLES, TYPES, AND BIT-WIDTH DISCIPLINE\n";
    // 💡 CodeDude: Prints dashed line.
    std::cout << std::string(80, '-') << "\n";
    // 💡 CodeDude: Prints the [WHAT] context to the terminal.
    std::cout << "[WHAT] Verifying fixed-width integer types and struct memory footprint\n";
    // 💡 CodeDude: Prints the [WHY] context.
    std::cout << "[WHY] Platform-dependent types (int, long) break portability\n";
    // 💡 CodeDude: Prints the [HOW] context.
    std::cout << "[HOW] Using <cstdint> types with guaranteed bit-widths\n\n";

    // 💡 CodeDude: Prints text.
    std::cout << "Fixed-Width Type Sizes (guaranteed across all platforms):\n";
    // 💡 CodeDude: The `sizeof()` operator is evaluated at compile-time. It returns exactly how many bytes of memory a specific data type consumes.
    std::cout << "  uint8_t:  " << sizeof(uint8_t) << " byte  (0–255)\n";
    // 💡 CodeDude: Printing the size of signed 16-bit int.
    std::cout << "  int16_t:  " << sizeof(int16_t) << " bytes (–32,768 to 32,767)\n";
    // 💡 CodeDude: Printing size of unsigned 16-bit int.
    std::cout << "  uint16_t: " << sizeof(uint16_t) << " bytes (0–65,535)\n";
    // 💡 CodeDude: Printing size of unsigned 32-bit int.
    std::cout << "  uint32_t: " << sizeof(uint32_t) << " bytes (0 to ~4 billion)\n";
    // 💡 CodeDude: Printing size of signed 32-bit int.
    std::cout << "  int32_t:  " << sizeof(int32_t) << " bytes (–2 billion to 2 billion)\n\n";

    // 💡 CodeDude: Prints text header.
    std::cout << "MotorState Struct Memory Layout:\n";
    // 💡 CodeDude: `sizeof(RobotHW::MotorState)` checks the memory footprint of our custom struct. The compiler might sneak in hidden padding bytes!
    std::cout << "  sizeof(MotorState) = " << sizeof(RobotHW::MotorState) << " bytes\n";
    // 💡 CodeDude: Explaining the memory offset of our first variable (2 bytes).
    std::cout << "    uint16_t target_rpm       @ offset 0 (2 bytes)\n";
    // 💡 CodeDude: Explaining offset of the second variable.
    std::cout << "    uint16_t current_rpm      @ offset 2 (2 bytes)\n";
    // 💡 CodeDude: Explaining offset of the third variable.
    std::cout << "    uint8_t  pwm_duty         @ offset 4 (1 byte)\n";
    // 💡 CodeDude: Explaining offset of the fourth variable.
    std::cout << "    int16_t  encoder_ticks    @ offset 6 (2 bytes)\n";
    // 💡 CodeDude: Explaining offset of the fifth variable.
    std::cout << "    uint8_t  status_byte      @ offset 8 (1 byte)\n";
    // 💡 CodeDude: Explaining offset of the boolean flag.
    std::cout << "    bool     fault_flag       @ offset 9 (1 byte)\n";
    // 💡 CodeDude: Explaining that the compiler sneaks in 1 byte of padding to align the memory block nicely for the CPU.
    std::cout << "    [padding]                         (1 byte, compiler-inserted alignment)\n";
    // 💡 CodeDude: Prints the total math.
    std::cout << "  Total: 12 bytes (includes 1 byte padding for alignment)\n\n";

    // 💡 CodeDude: Prints warning about padding.
    std::cout << "[WATCH OUT] Without #pragma pack(1), struct may have hidden padding\n";
    // 💡 CodeDude: Prints explanation of why padding is dangerous when talking directly to raw hardware packets.
    std::cout << "  This breaks binary compatibility with sensor packets from hardware\n\n";

    // Demonstrate constexpr: compile-time constant evaluation
    // 💡 CodeDude: Prints text.
    std::cout << "Compile-Time Constants (constexpr):\n";
    // 💡 CodeDude: Reaches into our namespace using `::` and prints out the hardcoded `MAX_MOTOR_RPM` value.
    std::cout << "  MAX_MOTOR_RPM = " << RobotHW::MAX_MOTOR_RPM << " (evaluated at compile-time)\n";
    // 💡 CodeDude: Grabs the PWM max. Note the `(int)` cast. If we didn't cast it, `std::cout` would interpret a `uint8_t` as an ASCII character, printing a weird symbol instead of "255".
    std::cout << "  MOTOR_PWM_MAX = " << (int)RobotHW::MOTOR_PWM_MAX << " (zero runtime cost)\n\n";

    // ========================================================================
    // SEGMENT 1.3 DEMONSTRATION: Operators, Bitwise Hardware Control
    // ========================================================================
    // 💡 CodeDude: Divider line.
    std::cout << "\n" << std::string(80, '-') << "\n";
    // 💡 CodeDude: Section title.
    std::cout << "SEGMENT 1.3: OPERATORS, EXPRESSIONS, AND BITWISE HARDWARE CONTROL\n";
    // 💡 CodeDude: Divider line.
    std::cout << std::string(80, '-') << "\n";
    // 💡 CodeDude: Prints [WHAT] context.
    std::cout << "[WHAT] Parsing hardware status byte using bitwise operations\n";
    // 💡 CodeDude: Prints [WHY] context.
    std::cout << "[WHY] Sensor packets are bit-packed for efficiency\n";
    // 💡 CodeDude: Prints [HOW] context.
    std::cout << "[HOW] Using &, |, ^, <<, >> to extract and manipulate bit fields\n\n";

    // 💡 CodeDude: We create a local 8-bit integer and copy the value from our simulated hardware register into it.
    uint8_t status = RobotHW::sensor_status_register;
    // 💡 CodeDude: `std::hex` tells the console "print the next numbers in base-16 (hexadecimal)". `std::setw(2)` and `std::setfill('0')` ensure it prints as a two-digit number like "03" instead of just "3".
    std::cout << "Raw Status Byte: 0x" << std::hex << std::setw(2) << std::setfill('0') << (int)status << " (binary: ";
    // 💡 CodeDude: A `for` loop designed to print exactly 8 binary bits. We start `i` at 7 and count down to 0 using `i--`.
    for (int i = 7; i >= 0; i--) {
        // 💡 CodeDude: Inside the loop, `(status >> i)` shifts the target bit all the way to the right edge. `& 1` acts as a mask, hiding everything else. This prints a single '1' or '0'.
        std::cout << ((status >> i) & 1);
    // 💡 CodeDude: Ends the binary printing loop.
    }
    // 💡 CodeDude: `std::dec` tells the console "go back to printing normal base-10 numbers now."
    std::cout << ")\n" << std::dec;

    // Extract bit fields
    // 💡 CodeDude: Calls our bitwise AND function and stores the result locally.
    uint8_t motor_status = RobotHW::extract_motor_status(status);
    // 💡 CodeDude: Calls our bitshift+AND function and stores the result locally.
    uint8_t error_code = RobotHW::extract_error_code(status);

    // 💡 CodeDude: Prints text.
    std::cout << "\nBit Field Extraction (using & and >>):\n";
    // 💡 CodeDude: Prints our extracted variables. Notice how we cast to `(int)` to avoid ASCII character confusion, and use `std::hex` and `std::dec` to flip between hex and decimal display modes mid-sentence!
    std::cout << "  Motor Status Code (bits [3:0]): 0x" << std::hex << (int)motor_status << std::dec << " (status #" << (int)motor_status << ")\n";
    // 💡 CodeDude: Prints the extracted error code in both hex and decimal formats.
    std::cout << "  Error Code (bits [7:4]):        0x" << std::hex << (int)error_code << std::dec << " (error #" << (int)error_code << ")\n\n";

    // 💡 CodeDude: Prints warning.
    std::cout << "[WATCH OUT] Bit shifting on signed types has platform-dependent behavior\n";
    // 💡 CodeDude: Prints explanation of the warning.
    std::cout << "  Always use unsigned types (uint8_t) for bitwise operations\n\n";

    // Demonstrate GPIO manipulation
    // 💡 CodeDude: Prints header.
    std::cout << "GPIO Pin Manipulation (using |, &, ~, ^):\n";
    // 💡 CodeDude: Initializes a fresh, blank 8-bit integer (all zeroes).
    uint8_t gpio_register = 0x00;
    // 💡 CodeDude: Prints out the baseline 0x00 state.
    std::cout << "  Initial GPIO register: 0x" << std::hex << (int)gpio_register << std::dec << "\n";

    // 💡 CodeDude: Calls our pass-by-reference function. Pin 2 will be set to 1.
    RobotHW::set_gpio_pin(gpio_register, 2);  // Set pin 2
    // 💡 CodeDude: Prints the result. It should now show 0x04.
    std::cout << "  After set_gpio_pin(gpio, 2): 0x" << std::hex << (int)gpio_register << std::dec << "\n";

    // 💡 CodeDude: Calls function again. Pin 5 is set to 1, while Pin 2 REMAINS 1!
    RobotHW::set_gpio_pin(gpio_register, 5);  // Set pin 5
    // 💡 CodeDude: Prints result. Should be 0x24.
    std::cout << "  After set_gpio_pin(gpio, 5): 0x" << std::hex << (int)gpio_register << std::dec << "\n";

    // 💡 CodeDude: Calls our clear function. Forces pin 2 back to 0.
    RobotHW::clear_gpio_pin(gpio_register, 2);  // Clear pin 2
    // 💡 CodeDude: Prints result. Should revert to 0x20.
    std::cout << "  After clear_gpio_pin(gpio, 2): 0x" << std::hex << (int)gpio_register << std::dec << "\n";

    // 💡 CodeDude: Calls the XOR toggle. Since pin 5 is currently ON, XOR will turn it OFF.
    RobotHW::toggle_bit(gpio_register, 5);  // Toggle pin 5
    // 💡 CodeDude: Prints result. Should be back to 0x00.
    std::cout << "  After toggle_bit(gpio, 5): 0x" << std::hex << (int)gpio_register << std::dec << "\n\n";

    // PWM calculation with overflow protection
    // 💡 CodeDude: Prints text header.
    std::cout << "PWM Duty Cycle Calculation (with overflow protection):\n";
    // 💡 CodeDude: Sets up a signed 16-bit dummy error value of 150.
    int16_t error = 150;  // Speed error: target - actual
    // 💡 CodeDude: Local compile-time float constant.
    constexpr float gain = 0.5f;
    // 💡 CodeDude: Triggers our math function, mapping the output into `pwm`.
    uint8_t pwm = RobotHW::compute_pwm_from_error(error, gain);
    // 💡 CodeDude: Prints the raw inputs.
    std::cout << "  Error: " << error << " RPM, Gain: " << gain << "\n";
    // 💡 CodeDude: Shows what the decimal math *would* be (150 * 0.5 = 75.0).
    std::cout << "  Raw PWM value: " << (float)error * gain << "\n";
    // 💡 CodeDude: Shows the final integer result after clamping and casting.
    std::cout << "  Clamped PWM (0–255): " << (int)pwm << "\n";
    // 💡 CodeDude: Prints a warning.
    std::cout << "  [WATCH OUT] Without clamping, overflow produces garbage PWM\n\n";

    // ========================================================================
    // SEGMENT 1.4 DEMONSTRATION: Control Flow, State Machines, Faults
    // ========================================================================
    // 💡 CodeDude: Divider line.
    std::cout << "\n" << std::string(80, '-') << "\n";
    // 💡 CodeDude: Header text.
    std::cout << "SEGMENT 1.4: CONTROL FLOW FOR REAL-TIME DECISION LOGIC\n";
    // 💡 CodeDude: Divider line.
    std::cout << std::string(80, '-') << "\n";
    // 💡 CodeDude: Context logging.
    std::cout << "[WHAT] Robot state machine with fault detection\n";
    // 💡 CodeDude: Context logging.
    std::cout << "[WHY] Clear state transitions prevent spaghetti code\n";
    // 💡 CodeDude: Context logging.
    std::cout << "[HOW] Using switch statement for O(1) state dispatch\n\n";

    // Scenario 1: IDLE state
    // 💡 CodeDude: Header text.
    std::cout << "\n=== CONTROL LOOP ITERATION 1: IDLE STATE ===\n";
    // 💡 CodeDude: We manually force the global state to `IDLE` to start the demo.
    RobotHW::current_state = RobotHW::RobotState::IDLE;
    // 💡 CodeDude: Print text.
    std::cout << "Current State: IDLE\n";
    // 💡 CodeDude: Show that Motor 0 is currently commanding 0 RPM.
    std::cout << "Motor 0 Target RPM: " << RobotHW::motors[0].target_rpm << "\n";
    // 💡 CodeDude: We trigger our switch statement function once!
    RobotHW::run_state_machine();

    // Scenario 2: Transition to RUNNING
    // 💡 CodeDude: Header text.
    std::cout << "\n=== CONTROL LOOP ITERATION 2: COMMAND RECEIVED ===\n";
    // 💡 CodeDude: Print text.
    std::cout << "Setting Motor 0 target RPM to 2000\n";
    // 💡 CodeDude: We reach directly into the array and modify all 4 target RPMs.
    RobotHW::motors[0].target_rpm = 2000;
    // 💡 CodeDude: Setting target.
    RobotHW::motors[1].target_rpm = 1500;
    // 💡 CodeDude: Setting target.
    RobotHW::motors[2].target_rpm = 1000;
    // 💡 CodeDude: Setting target.
    RobotHW::motors[3].target_rpm = 500;
    // 💡 CodeDude: We run the loop again. Because Motor 0's target is > 0, the internal logic will switch us to `RUNNING`!
    RobotHW::run_state_machine();

    // Scenario 3: RUNNING state with normal operation
    // 💡 CodeDude: Header text.
    std::cout << "\n=== CONTROL LOOP ITERATION 3: RUNNING NORMALLY ===\n";
    // 💡 CodeDude: We fake some incoming encoder data.
    RobotHW::encoder_raw_counts = 1024;  // Simulate encoder feedback
    // 💡 CodeDude: We ensure the simulated hardware registers are clear of errors.
    RobotHW::sensor_status_register = 0x00;  // No errors
    // 💡 CodeDude: Run the loop! The switch statement instantly routes us to the `RUNNING` case this time.
    RobotHW::run_state_machine();

    // Scenario 4: Detect fault (error code in sensor)
    // 💡 CodeDude: Header text.
    std::cout << "\n=== CONTROL LOOP ITERATION 4: FAULT DETECTED ===\n";
    // 💡 CodeDude: Print text.
    std::cout << "Simulating hardware error: sensor timeout\n";
    // 💡 CodeDude: We explicitly inject a fake error byte into our simulated hardware.
    RobotHW::sensor_status_register = 0x25;  // Error code = 2 (sensor timeout)
    // 💡 CodeDude: Run the loop. The PID math will fire, but then `check_motor_faults` will catch the 0x25 byte, flip the fault flag, and force us into `FAULT` mode.
    RobotHW::run_state_machine();

    // Scenario 5: FAULT state
    // 💡 CodeDude: Header text.
    std::cout << "\n=== CONTROL LOOP ITERATION 5: FAULT STATE ===\n";
    // 💡 CodeDude: Run the loop. It routes directly to the `FAULT` case, disabling the motors and setting the state back to `IDLE`.
    RobotHW::run_state_machine();

    // Scenario 6: Back to IDLE (auto-reset for demo)
    // 💡 CodeDude: Header text.
    std::cout << "\n=== CONTROL LOOP ITERATION 6: RECOVERED TO IDLE ===\n";
    // 💡 CodeDude: One final run to prove we are back where we started safely.
    RobotHW::run_state_machine();

    // 💡 CodeDude: Bottom divider.
    std::cout << "\n" << std::string(80, '=') << "\n";
    // 💡 CodeDude: Ending text.
    std::cout << "END OF DEMONSTRATION\n";
    // 💡 CodeDude: Bottom divider.
    std::cout << std::string(80, '=') << "\n\n";

    // 💡 CodeDude: Prints summary header.
    std::cout << "SUMMARY:\n";
    // 💡 CodeDude: Prints summary points.
    std::cout << "1. SEGMENT 1.2: Fixed-width types guarantee portability across ARM, x86, bare-metal\n";
    // 💡 CodeDude: Prints summary points.
    std::cout << "2. SEGMENT 1.3: Bitwise operators enable efficient hardware register parsing\n";
    // 💡 CodeDude: Prints summary points.
    std::cout << "3. SEGMENT 1.4: State machines provide clear, safe control flow for robotics\n\n";

    // 💡 CodeDude: Prints pattern header.
    std::cout << "PRODUCTION PATTERNS DEMONSTRATED:\n";
    // 💡 CodeDude: Prints pattern point.
    std::cout << "  • Use constexpr for compile-time hardware constants (zero cost)\n";
    // 💡 CodeDude: Prints pattern point.
    std::cout << "  • Clamp arithmetic results to prevent overflow (PWM duty cycle bug)\n";
    // 💡 CodeDude: Prints pattern point.
    std::cout << "  • Always use unsigned types for bitwise operations\n";
    // 💡 CodeDude: Prints pattern point.
    std::cout << "  • Switch statements for state dispatch (faster than if/else chains)\n";
    // 💡 CodeDude: Prints pattern point.
    std::cout << "  • Fault detection in tight loops (critical for safety)\n";
    // 💡 CodeDude: Prints pattern point.
    std::cout << "  • Fixed-width types for cross-platform portability\n\n";

    // 💡 CodeDude: The main function returns an integer. Returning '0' is the universal signal to the operating system that our program finished successfully without crashing.
    return 0;
// 💡 CodeDude: The final curly brace, closing out the `int main()` function and concluding the entire file!
}