================================================================================
FILE: build_and_run.txt
MODULE 1 | Segments 1.1 & 1.2 — Integration Pipeline
Engineer: Chijioke Ekwebelem

HOW TO USE THIS FILE:
  1. Read each section header carefully.
  2. Create the corresponding file in your project directory manually.
  3. Copy the code under each header into that new file.
  4. Follow the "Build Steps" section at the bottom to compile and run.

PROJECT DIRECTORY STRUCTURE TO CREATE:
  module1_cv/
  ├── CMakeLists.txt          <-- Contents from === CMAKE CONFIG === section
  ├── src/
  │   └── main_cv.cpp         <-- Your already-generated C++ engine file
  ├── bindings/
  │   └── bindings.cpp        <-- Contents from === PYBIND11 WRAPPER === section
  └── build/                  <-- Create this empty directory yourself
================================================================================


================================================================================
=== CMAKE CONFIG ===
File to create: module1_cv/CMakeLists.txt
================================================================================

# cmake_minimum_required: Guards against users running an outdated CMake.
# If their CMake is older than 3.18, the build stops with a clear error.
# VERSION 3.18 is the minimum that handles CUDA + Pybind11 reliably.
cmake_minimum_required(VERSION 3.18)

# project() names your project and declares the language(s) used.
# CXX = C++. CMake uses this to locate and configure the right compiler (g++).
project(Module1_CV CXX)

# Forces the C++17 standard across ALL targets in this project.
# Pybind11 and modern OpenCV both require at least C++14; 17 is the sweet spot.
set(CMAKE_CXX_STANDARD 17)

# Makes C++17 non-optional. If the compiler doesn't support it, build fails
# with a clear error instead of silently falling back to an older standard.
set(CMAKE_CXX_STANDARD_REQUIRED ON)


# ---- FIND OPENCV ------------------------------------------------------------

# Searches your system for OpenCVConfig.cmake (installed when you ran
# `sudo make install` after compiling OpenCV from source in Segment 1.1).
# Populates: OpenCV_INCLUDE_DIRS and OpenCV_LIBS automatically.
# REQUIRED: halts build immediately if OpenCV is not found.
find_package(OpenCV REQUIRED)

# Prints the found OpenCV version to the terminal during cmake configuration.
# Useful sanity check — confirms you're linking against YOUR source-built
# version and not some stale system package.
message(STATUS "OpenCV version found: ${OpenCV_VERSION}")


# ---- FIND PYBIND11 ----------------------------------------------------------

# Searches for Pybind11's CMake config. Pybind11 must be installed:
#   pip install pybind11  (installs the headers + CMake files into your venv)
# OR: git clone and add_subdirectory it.
# REQUIRED: halts build if not found.
find_package(pybind11 REQUIRED)


# ---- TARGET 1: STANDALONE C++ EXECUTABLE ------------------------------------

# Declares an executable build target named "module1_demo".
# CMake will compile src/main_cv.cpp and link it into a binary called
# `module1_demo` inside your build/ directory.
add_executable(module1_demo
    src/main_cv.cpp
)

# Tells the compiler WHERE to find OpenCV's .hpp header files when it sees
# #include <opencv2/...> inside main_cv.cpp.
# OpenCV_INCLUDE_DIRS is populated by find_package(OpenCV REQUIRED) above.
target_include_directories(module1_demo PRIVATE
    ${OpenCV_INCLUDE_DIRS}
)

# Tells the LINKER which compiled .so library files contain the actual
# implementations of cv::imread, cv::Mat, etc.
# PRIVATE means these libraries are only linked into this target, not
# propagated to anything that might depend on module1_demo.
target_link_libraries(module1_demo PRIVATE
    ${OpenCV_LIBS}
)


# ---- TARGET 2: PYBIND11 PYTHON MODULE ---------------------------------------

# pybind11_add_module is a special CMake function from Pybind11.
# It creates a SHARED LIBRARY (.so on Linux) that Python can import directly.
# "cv_module" is the name — Python will import it as: import cv_module
# It compiles bindings/bindings.cpp into the importable Python module.
pybind11_add_module(cv_module
    bindings/bindings.cpp
)

# The bindings code calls OpenCV functions, so it needs the same headers
# and link targets as the main executable.
target_include_directories(cv_module PRIVATE
    ${OpenCV_INCLUDE_DIRS}
)

target_link_libraries(cv_module PRIVATE
    ${OpenCV_LIBS}
)


================================================================================
=== PYBIND11 WRAPPER ===
File to create: module1_cv/bindings/bindings.cpp
================================================================================

// pybind11/pybind11.h: Core Pybind11 machinery — the PYBIND11_MODULE macro,
// the `py::module_` type, and all argument/return type plumbing.
#include <pybind11/pybind11.h>

// pybind11/stl.h: Enables automatic conversion between C++ STL types
// (std::vector, std::string, std::map) and their Python equivalents
// (list, str, dict). Without this, returning a std::string to Python would fail.
#include <pybind11/stl.h>

// numpy.h: Enables zero-copy conversion between cv::Mat and numpy arrays.
// This is the bridge that lets Python receive OpenCV image data as a numpy
// array without re-allocating memory.
#include <pybind11/numpy.h>

#include <opencv2/core.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <string>

// Alias the pybind11 namespace as `py` — standard convention in all Pybind11
// codebases. Lets us write py::str instead of pybind11::str.
namespace py = pybind11;


// ---------------------------------------------------------------------------
// WRAPPER FUNCTION: get_opencv_version
// Exposes the OpenCV version string to Python.
// Returns std::string — pybind11/stl.h auto-converts this to Python str.
// ---------------------------------------------------------------------------
std::string get_opencv_version()
{
    // CV_VERSION is a preprocessor macro set at OpenCV compile time.
    // It returns a const char* (raw C string) — std::string() wraps it safely.
    return std::string(CV_VERSION);
}


// ---------------------------------------------------------------------------
// WRAPPER FUNCTION: get_build_info
// Returns the full OpenCV build information string to Python.
// ---------------------------------------------------------------------------
std::string get_build_info()
{
    return cv::getBuildInformation();
}


// ---------------------------------------------------------------------------
// WRAPPER FUNCTION: blur_image_path
// Takes an image path string, applies Gaussian blur, saves result, returns
// a status string. Demonstrates full C++ image pipeline callable from Python.
// ---------------------------------------------------------------------------
std::string blur_image_path(const std::string& input_path, const std::string& output_path)
{
    cv::Mat img = cv::imread(input_path, cv::IMREAD_COLOR);

    if (img.empty())
        return "ERROR: Could not load image from path: " + input_path;

    cv::Mat blurred;
    cv::GaussianBlur(img, blurred, cv::Size(5, 5), 0);
    cv::imwrite(output_path, blurred);

    // std::to_string() converts numeric types to std::string — like Python's str().
    return "OK: Blurred image saved. Size: "
           + std::to_string(img.cols) + "x" + std::to_string(img.rows);
}


// ---------------------------------------------------------------------------
// PYBIND11_MODULE: The Entry Point of the Python Extension
//
// PYBIND11_MODULE(name, variable) is a MACRO that generates the C function
// Python calls when you do `import cv_module`. It's the handshake between
// the Python interpreter and your compiled C++ code.
//
// `cv_module` — MUST match exactly the target name in pybind11_add_module()
//               in CMakeLists.txt AND is the name Python uses to import it.
// `m`         — A local variable of type py::module_ representing the module
//               itself. You call methods on `m` to register functions and classes.
// ---------------------------------------------------------------------------
PYBIND11_MODULE(cv_module, m)
{
    // m.doc() sets the Python module's docstring — visible via help(cv_module).
    m.doc() = "Module 1 CV bindings: OpenCV build info and image processing.";

    // m.def() registers a C++ function as a callable Python function.
    // Arg 1: Python-side name (what Python calls it — can differ from C++ name).
    // Arg 2: C++ function pointer (the actual function to call).
    // Arg 3: docstring for the function — visible via help(cv_module.function).
    m.def("get_opencv_version", &get_opencv_version,
          "Returns the OpenCV version string.");

    m.def("get_build_info", &get_build_info,
          "Returns the full OpenCV compile-time configuration report.");

    // py::arg() gives Python argument names to C++ positional parameters.
    // This lets Python callers use: blur_image(input_path="a.jpg", output_path="b.png")
    m.def("blur_image", &blur_image_path,
          py::arg("input_path"), py::arg("output_path"),
          "Blurs an image file and saves it. Returns a status string.");
}


================================================================================
=== PYTHON TEST SCRIPT ===
File to create: module1_cv/test_bindings.py
Run from: module1_cv/build/ directory (where cv_module.so was built)
================================================================================

# sys.path manipulation tells Python's import system where to look for modules.
# Our cv_module.so was compiled into build/, so we add build/ to the path.
# In production you'd install the module system-wide via `pip install -e .`
import sys
import os

# os.path.dirname(__file__) gets the directory of THIS script.
# We navigate to the build/ directory relative to the script location.
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "build"))

# Now Python can find cv_module.so in the build/ directory.
import cv_module

print("=" * 60)
print("  MODULE 1 — PYTHON INTEGRATION TEST")
print("=" * 60)

# Call our C++ function through the Pybind11 bridge.
# This executes compiled C++ code directly — no Python overhead on the CV work.
version = cv_module.get_opencv_version()
print(f"\n[VERSION] OpenCV version (from C++): {version}")

# Retrieve and print the full build info — verify CUDA, GStreamer flags.
build_info = cv_module.get_build_info()
print("\n[BUILD INFO] (searching for key flags...)\n")

# Parse the build info string in Python to surface the lines we care about.
for line in build_info.splitlines():
    line_stripped = line.strip()
    # Surface the most critical robotics build flags from the report.
    for keyword in ["CUDA", "cuDNN", "GStreamer", "OpenCV modules", "Version"]:
        if keyword in line_stripped:
            print(f"  {line_stripped}")
            break

print("\n[BLUR TEST]")
# Test the blur pipeline. Pass any .jpg on your system or create a test image.
# Adjust the path below to point to a real image file on your machine.
test_image = "test_image.jpg"
output_image = "output_blurred_from_python.png"

result = cv_module.blur_image(input_path=test_image, output_path=output_image)
print(f"  Result: {result}")

print("\n[DONE] Integration test complete.")


================================================================================
=== BUILD STEPS ===
Run these commands in your terminal from the module1_cv/ directory.
================================================================================

STEP 1 — CREATE THE PROJECT STRUCTURE:
  mkdir -p module1_cv/src module1_cv/bindings module1_cv/build
  # Move your main_cv.cpp into src/
  mv main_cv.cpp module1_cv/src/
  # Create CMakeLists.txt, bindings/bindings.cpp, test_bindings.py from above

STEP 2 — CONFIGURE WITH CMAKE (from inside build/ directory):
  cd module1_cv/build
  cmake .. -DCMAKE_BUILD_TYPE=Release
  # Expected output: "OpenCV version found: 4.x.x" confirms source build was found.

STEP 3 — COMPILE (uses all CPU cores):
  make -j$(nproc)
  # Produces two artifacts in build/:
  #   module1_demo         (standalone C++ executable)
  #   cv_module.cpython-*.so  (Python-importable shared library)

STEP 4 — RUN THE C++ EXECUTABLE:
  ./module1_demo
  # Runs without an image — uses synthetic Mat. Shows full build info.
  # To run with a real image:
  ./module1_demo /path/to/your/image.jpg

STEP 5 — RUN THE PYTHON INTEGRATION TEST (from build/ directory):
  cd module1_cv/build
  python3 ../test_bindings.py

STEP 6 — VERIFY CUDA WAS COMPILED IN:
  # In the build info output, look for lines containing:
  #   CUDA: YES (or the CUDA version number)
  #   cuDNN: YES
  #   GStreamer: YES
  # If you see NO for any of these, your cmake configuration in Segment 1.1
  # did not pass the flag correctly. Rerun cmake with:
  #   cmake .. -DWITH_CUDA=ON -DWITH_CUDNN=ON -DWITH_GSTREAMER=ON -DCMAKE_BUILD_TYPE=Release

================================================================================
END OF FILE
================================================================================