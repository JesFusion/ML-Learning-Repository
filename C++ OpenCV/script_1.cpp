// =============================================================================
// FILE: main_cv.cpp
// MODULE 1 | Segments 1.1 & 1.2
// Engineer: Chijioke Ekwebelem
// Purpose : Validate your OpenCV source build, inspect its compile-time flags,
//           and demonstrate foundational cv::Mat memory mechanics.
// =============================================================================


// --- WHAT IS #include? -------------------------------------------------------
// In Python you wrote:  import cv2
// In C++ you write:     #include <opencv2/core.hpp>
// The `#include` is a PREPROCESSOR DIRECTIVE. Before your code compiles,
// a pre-processor literally copy-pastes the contents of the named header file
// right here. That header file contains the DECLARATIONS (the "menu") of every
// function and class OpenCV provides.
// The angle brackets < > mean: "look for this file in the system-wide include
// directories" (the paths we set with target_include_directories in CMake).
// Quote marks " " would mean: "look in my own project folder first."
// -----------------------------------------------------------------------------
#include <opencv2/core.hpp>       // cv::Mat, cv::getBuildInformation(), core types
#include <opencv2/imgcodecs.hpp>  // cv::imread(), cv::imwrite() — image file I/O
#include <opencv2/imgproc.hpp>    // cv::cvtColor(), cv::GaussianBlur() — processing

// --- WHAT IS #include <iostream>? -------------------------------------------
// This is the C++ STANDARD LIBRARY header for console I/O.
// `std::cout` (console output) is the C++ equivalent of Python's print().
// `std::endl` flushes the buffer and adds a newline — like print()'s \n.
// -----------------------------------------------------------------------------
#include <iostream>

// --- WHAT IS #include <string>? ----------------------------------------------
// In Python, strings are first-class citizens. In C++ they are NOT built-in.
// You must include this header to use std::string (the safe, managed string
// class). Without it, you'd be stuck with raw C-style char arrays — a
// one-way ticket to buffer overflow hell.
// -----------------------------------------------------------------------------
#include <string>


// =============================================================================
// FUNCTION: inspect_build
// PURPOSE : Prints the compile-time configuration of your OpenCV build.
//           This is your PROOF that WITH_CUDA, WITH_GSTREAMER, etc. were
//           actually enabled during your cmake configuration (Segment 1.1).
//
// --- WHAT IS `void`? ---------------------------------------------------------
// In Python, a function that returns nothing implicitly returns None.
// In C++, you MUST explicitly declare the return type. `void` means:
// "this function returns absolutely nothing."
// -----------------------------------------------------------------------------
void inspect_build()
{
    // std:: is the NAMESPACE for the C++ Standard Library.
    // A namespace is a named scope that prevents name collisions.
    // Think of it like a Python module prefix: just as you write cv2.imread()
    // to say "imread from the cv2 module", you write std::cout to say
    // "cout from the std namespace."
    std::cout << "========================================" << std::endl;
    std::cout << "  OPENCV BUILD INSPECTION (Segment 1.1) " << std::endl;
    std::cout << "========================================" << std::endl;

    // cv:: is OpenCV's namespace. Same concept as std:: but for OpenCV.
    // cv::getBuildInformation() returns a single std::string containing the
    // FULL compile-time report of your OpenCV build — every flag you passed
    // to CMake is recorded here. This is how you verify WITH_CUDA=ON actually
    // worked. Look for "CUDA: YES" and "GStreamer: YES" in the output.
    std::cout << cv::getBuildInformation() << std::endl;
}


// =============================================================================
// FUNCTION: demonstrate_mat_memory
// PURPOSE : Show how cv::Mat works as a smart, reference-counted image
//           container — the most important object you will use in ALL of
//           your robotics vision code.
//
// --- WHAT IS `const std::string&`? -------------------------------------------
// `std::string` — a managed string object (safe, resizable, no raw pointers).
// `const`       — a PROMISE to the compiler: "I will NOT modify this variable
//                 inside this function." Passing const data is a best practice
//                 that prevents accidental mutation. Python has no equivalent
//                 concept — everything is mutable by default.
// `&`           — this is a REFERENCE. Without the &, C++ would make a full
//                 COPY of the string every time you call this function.
//                 With the &, you're passing the memory ADDRESS of the original
//                 string — zero copying, maximum speed. Think of it like Python
//                 passing an object by reference (which Python always does
//                 for mutable objects), but in C++ you have to be EXPLICIT.
// So `const std::string& image_path` means:
//   "Give me a reference to a string I promise not to change."
// This pattern (const T&) is THE standard way to pass non-primitive objects
// into C++ functions efficiently.
// -----------------------------------------------------------------------------
void demonstrate_mat_memory(const std::string& image_path)
{
    std::cout << "\n========================================" << std::endl;
    std::cout << "  CV::MAT MEMORY DEMO (Segment 1.2)    " << std::endl;
    std::cout << "========================================" << std::endl;

    // -------------------------------------------------------------------------
    // STEP 1: LOAD AN IMAGE INTO A cv::Mat
    // -------------------------------------------------------------------------
    // cv::Mat is OpenCV's core image/matrix container. In Python, cv2.imread()
    // returned a NumPy array. Here, it returns a cv::Mat object.
    //
    // cv::Mat WHAT IT IS:
    //   Internally, cv::Mat holds a pointer to a contiguous block of heap
    //   memory where pixel data lives, plus metadata (rows, cols, type).
    //   It uses REFERENCE COUNTING — multiple Mat objects can point to the
    //   same pixel data, and the data is only freed when the last Mat
    //   referencing it goes out of scope. This is similar to Python's
    //   reference counting on objects.
    //
    // ARGUMENT BREAKDOWN for cv::imread:
    //   Arg 1 (filename) : std::string — path to the image file on disk.
    //   Arg 2 (flags)    : int — how to decode the image.
    //                      cv::IMREAD_COLOR     = load as 3-channel BGR (default).
    //                      cv::IMREAD_GRAYSCALE = load as 1-channel grayscale.
    //                      cv::IMREAD_UNCHANGED = load as-is, including alpha.
    //   NOTE: OpenCV stores color images as BGR (Blue, Green, Red), NOT RGB.
    //   This is a historical quirk that will bite you when you interface with
    //   other libraries (like matplotlib) that expect RGB. You've been warned.
    // -------------------------------------------------------------------------
    cv::Mat image = cv::imread(image_path, cv::IMREAD_COLOR);

    // -------------------------------------------------------------------------
    // STEP 2: VALIDATE THE LOAD — ALWAYS CHECK FOR EMPTY MATS
    // -------------------------------------------------------------------------
    // In Python, cv2.imread() returns None on failure and you'd check `if img`.
    // In C++, cv::imread() returns an EMPTY cv::Mat on failure — it does NOT
    // throw an exception. An empty Mat has no pixel data. If you call any
    // operation on it (like .rows or .cols), you get UNDEFINED BEHAVIOR —
    // which means random crashes, silent data corruption, or worse.
    //
    // `.empty()` is a method on cv::Mat that returns true if the Mat has no
    // data. This check is NON-NEGOTIABLE in production code. If your robot's
    // camera feed drops and you skip this check, your autonomous system
    // crashes. We never skip this check.
    // -------------------------------------------------------------------------
    if (image.empty())
    {
        // std::cerr is the STANDARD ERROR stream. It behaves like std::cout
        // but writes to stderr instead of stdout. Use cerr for error messages
        // so they can be redirected independently in production pipelines.
        std::cerr << "[ERROR] Failed to load image: " << image_path << std::endl;
        std::cerr << "[INFO]  Switching to synthetic Mat for the demo." << std::endl;

        // --- SYNTHETIC MAT CREATION -------------------------------------------
        // When no real image is available, we create a Mat programmatically.
        //
        // ARGUMENT BREAKDOWN for cv::Mat constructor:
        //   Arg 1 (rows)  : int — number of rows (image height in pixels).
        //   Arg 2 (cols)  : int — number of columns (image width in pixels).
        //   Arg 3 (type)  : int — encodes BOTH the data type of each element
        //                   AND the number of channels.
        //                   CV_8UC3 breaks down as:
        //                     CV_   = OpenCV type prefix
        //                     8U    = 8-bit Unsigned integer (values 0–255)
        //                     C3    = 3 Channels (BGR)
        //                   Other common types:
        //                     CV_8UC1  = 8-bit, 1 channel (grayscale)
        //                     CV_32FC1 = 32-bit float, 1 channel (depth maps)
        //                     CV_64FC1 = 64-bit double, 1 channel
        //   Arg 4 (scalar): cv::Scalar — the fill value for all pixels.
        //                   cv::Scalar(B, G, R) sets all pixels to that color.
        //                   Here: B=100, G=150, R=200 — a muted blue-ish tone.
        // ----------------------------------------------------------------------
        image = cv::Mat(480, 640, CV_8UC3, cv::Scalar(100, 150, 200));

        std::cout << "[INFO]  Created synthetic 640x480 BGR Mat." << std::endl;
    }

    // -------------------------------------------------------------------------
    // STEP 3: INSPECT MAT METADATA
    // -------------------------------------------------------------------------
    // These are MEMBER VARIABLES (properties) of the cv::Mat object.
    // The `.` dot operator accesses members of an object — same as Python.
    //
    // `.rows`     — number of rows = image height.
    // `.cols`     — number of columns = image width.
    // `.channels()` — number of color channels (1=grayscale, 3=BGR, 4=BGRA).
    //               This is a METHOD (function on the object), hence the ().
    // `.type()`   — returns an int encoding the data type + channel count.
    //               Raw number is opaque; use it for type comparisons.
    // `.total()`  — total number of ELEMENTS (pixels): rows * cols.
    // `.elemSize()` — bytes per element: for CV_8UC3, this is 3 bytes (1 per channel).
    // `.total() * .elemSize()` — total bytes allocated for pixel data.
    //               For a 640x480 BGR image: 640 * 480 * 3 = 921,600 bytes ≈ 0.9 MB.
    //               Knowing this matters when you're streaming 60fps — that's
    //               55 MB/s of data your pipeline must process without copying.
    // ----------------------------------------------------------------------
    std::cout << "\n[MAT INFO]" << std::endl;
    std::cout << "  Dimensions     : " << image.cols << " x " << image.rows << " (W x H)" << std::endl;
    std::cout << "  Channels       : " << image.channels() << std::endl;
    std::cout << "  Type code      : " << image.type() << " (CV_8UC3 = " << CV_8UC3 << ")" << std::endl;
    std::cout << "  Total pixels   : " << image.total() << std::endl;
    std::cout << "  Bytes/pixel    : " << image.elemSize() << std::endl;
    std::cout << "  Total RAM used : " << (image.total() * image.elemSize()) / 1024 << " KB" << std::endl;

    // -------------------------------------------------------------------------
    // STEP 4: DEMONSTRATE REFERENCE COUNTING (Shallow Copy)
    // -------------------------------------------------------------------------
    // THIS IS THE #1 SOURCE OF BUGS FOR PYTHON DEVS NEW TO OPENCV C++.
    //
    // When you do:  cv::Mat mat_b = mat_a;
    // You do NOT get a new image. You get a new Mat HEADER pointing to the
    // SAME pixel data in memory. Modifying mat_b's pixels modifies mat_a's
    // pixels too. The reference count increments by 1.
    //
    // This is exactly like Python's: list_b = list_a (both point to same list).
    // -------------------------------------------------------------------------
    cv::Mat shallow_copy = image;  // Both 'shallow_copy' and 'image' share pixel data

    std::cout << "\n[REFERENCE COUNT DEMO]" << std::endl;
    // `.u` is the internal UMatData pointer; if not null, `u->refcount` shows
    // how many Mat headers are currently sharing this pixel buffer.
    if (image.u != nullptr)
    {
        std::cout << "  Ref count after shallow copy: " << image.u->refcount
                  << " (2 headers, 1 buffer)" << std::endl;
    }

    // -------------------------------------------------------------------------
    // STEP 5: DEMONSTRATE .clone() (Deep Copy)
    // -------------------------------------------------------------------------
    // `.clone()` allocates a BRAND NEW pixel buffer and copies all data into it.
    // Now gray_image is fully independent. Changing one does NOT affect the other.
    // This is the C++ equivalent of numpy's array.copy().
    //
    // ARGUMENT BREAKDOWN for cv::cvtColor:
    //   Arg 1 (src)  : cv::Mat — the source image (input).
    //   Arg 2 (dst)  : cv::Mat& — the destination Mat (output). Note the `&`
    //                  (reference): cvtColor WRITES the result INTO this Mat.
    //                  This is the standard OpenCV output pattern — functions
    //                  write results to a passed-in reference, not a return value.
    //   Arg 3 (code) : int — the color conversion code.
    //                  cv::COLOR_BGR2GRAY converts 3-channel BGR to 1-channel
    //                  grayscale using the formula:
    //                  gray = 0.114*B + 0.587*G + 0.299*R
    //                  (Weighted because human eyes are more sensitive to green.)
    // -------------------------------------------------------------------------
    cv::Mat gray_image;  // Declare an EMPTY Mat — no memory allocated yet.
    cv::cvtColor(image, gray_image, cv::COLOR_BGR2GRAY);  // cvtColor allocates gray_image internally.

    std::cout << "\n[DEEP COPY + GRAYSCALE CONVERSION]" << std::endl;
    std::cout << "  Original channels : " << image.channels() << " (BGR)" << std::endl;
    std::cout << "  Grayscale channels: " << gray_image.channels() << " (single channel)" << std::endl;
    std::cout << "  Grayscale RAM     : " << (gray_image.total() * gray_image.elemSize()) / 1024
              << " KB (1/3 of color image)" << std::endl;

    // -------------------------------------------------------------------------
    // STEP 6: APPLY A GAUSSIAN BLUR & SAVE OUTPUT
    // -------------------------------------------------------------------------
    // GaussianBlur convolves the image with a Gaussian kernel — a smoothing
    // operation that reduces noise. In robotics, you apply this BEFORE edge
    // detection to prevent noise spikes from being mistaken for edges.
    //
    // ARGUMENT BREAKDOWN for cv::GaussianBlur:
    //   Arg 1 (src)        : cv::Mat — input image.
    //   Arg 2 (dst)        : cv::Mat& — output Mat (written in-place by reference).
    //   Arg 3 (ksize)      : cv::Size — kernel dimensions (width, height).
    //                        MUST be odd and positive. (5,5) = 5x5 kernel.
    //                        Larger kernel = stronger blur = more noise removal
    //                        but also more loss of fine detail.
    //   Arg 4 (sigmaX)     : double — Gaussian standard deviation in X direction.
    //                        Controls the "spread" of the blur. If 0, OpenCV
    //                        auto-calculates it from ksize.
    //   Arg 5 (sigmaY)     : double — Gaussian std dev in Y. If 0, same as sigmaX.
    //   Arg 6 (borderType) : int — how to handle pixels at image edges.
    //                        cv::BORDER_DEFAULT reflects the border — the safest
    //                        and most common choice.
    // -------------------------------------------------------------------------
    cv::Mat blurred_image;
    cv::GaussianBlur(image, blurred_image, cv::Size(5, 5), 0, 0, cv::BORDER_DEFAULT);

    // cv::imwrite saves the Mat to disk as an image file.
    // The format is determined by the file extension.
    // Returns: bool — true if save succeeded, false if it failed.
    //
    // ARGUMENT BREAKDOWN for cv::imwrite:
    //   Arg 1 (filename) : std::string — output path including extension.
    //   Arg 2 (img)      : cv::Mat    — the image data to write.
    bool saved = cv::imwrite("output_blurred.png", blurred_image);

    if (saved)
        std::cout << "\n[OUTPUT] Blurred image saved to: output_blurred.png" << std::endl;
    else
        std::cerr << "\n[ERROR] Failed to write output_blurred.png" << std::endl;

    // -------------------------------------------------------------------------
    // STEP 7: SCOPE-BASED MEMORY MANAGEMENT (RAII)
    // -------------------------------------------------------------------------
    // In Python, garbage collection handles memory for you.
    // In C++, cv::Mat uses RAII (Resource Acquisition Is Initialization).
    //
    // RAII means: the DESTRUCTOR of cv::Mat (its cleanup function) is called
    // AUTOMATICALLY when the Mat variable goes OUT OF SCOPE — i.e., when the
    // function ends, or when the enclosing `{ }` block ends.
    //
    // The destructor decrements the reference count. When ref count hits 0,
    // the pixel buffer is freed from heap memory. No `del`, no `free()`,
    // no manual cleanup needed. This is C++'s answer to Python's GC —
    // deterministic, predictable, and zero-overhead.
    //
    // WHEN THIS FUNCTION RETURNS:
    //   `image`, `shallow_copy`, `gray_image`, `blurred_image` all go out of scope.
    //   Their destructors fire automatically. All heap memory is released.
    //   No memory leak. This is what production-grade C++ looks like.
    // -------------------------------------------------------------------------
    std::cout << "\n[MEMORY] All cv::Mat objects will auto-release on function exit." << std::endl;
    std::cout << "[MEMORY] RAII: No manual free() needed. C++ handles it." << std::endl;
}


// =============================================================================
// FUNCTION: main
// PURPOSE : Entry point of the C++ program. Every C++ program must have
//           exactly one `main` function. It's the equivalent of Python's
//           `if __name__ == '__main__':` block.
//
// RETURN TYPE `int`:
//   `main` must return an int — the EXIT CODE to the operating system.
//   Convention: return 0 = success, return 1 (or any non-zero) = failure.
//   This is how shell scripts know if your program succeeded:
//   `./my_program && echo "OK"` only prints "OK" if main() returned 0.
//
// PARAMETERS `int argc, char** argv`:
//   argc = argument count (how many command-line args were passed).
//   argv = argument values (array of C-style strings — the actual args).
//   Equivalent to Python's sys.argv. We use them here to let the user
//   optionally pass an image path as a command-line argument.
// =============================================================================
int main(int argc, char** argv)
{
    // -------------------------------------------------------------------------
    // PHASE 1: BUILD INSPECTION (Segment 1.1 Verification)
    // -------------------------------------------------------------------------
    inspect_build();

    // -------------------------------------------------------------------------
    // PHASE 2: MAT MEMORY DEMO (Segment 1.2 Application)
    // -------------------------------------------------------------------------
    // Ternary operator: condition ? value_if_true : value_if_false
    // This is identical to Python's: x = a if condition else b
    // If the user passed an argument (argc > 1), use argv[1] as image path.
    // argv[1] is a raw C-string (char*). We wrap it in std::string() for safety.
    // Otherwise, default to "test_image.jpg" in the current directory.
    // -------------------------------------------------------------------------
    std::string image_path = (argc > 1) ? std::string(argv[1]) : "test_image.jpg";

    std::cout << "\n[MAIN] Using image path: " << image_path << std::endl;

    demonstrate_mat_memory(image_path);

    std::cout << "\n[MAIN] Module 1 demo complete. Returning exit code 0." << std::endl;

    // Return 0 to the OS — signals successful execution.
    return 0;
}