import os
import json
import time
import yaml
import logging
import numpy as np
import logging.config
import logging.handlers
from pythonjsonlogger import jsonlogger




# ===================================== SEGMENT 1.1 — THE ANATOMY OF A RECORD =====================================


"""
logging.basicConfig() — One-shot configuration for the root logger.

level=logging.DEBUG: Sets the minimum severity threshold to DEBUG (level 10). This means ALL messages (DEBUG and above) will be shown.

format=: The string template for each log line. Each %(...)s token maps directly to an attribute on the LogRecord object Python creates behind the scenes when you call a log method
"""
logging.basicConfig(
    level = logging.DEBUG,

    format = """Date: %(asctime)s
User: %(name)s
Log Level: %(levelname)s
Name of File: %(filename)s
Line Number: %(lineno)d
Log Message: %(message)s
"""
)


# making use of the root logger to demonstrate...

log = logging.getLogger()


segment_1_1 = False

if segment_1_1:

    # .debug() fires a DEBUG-level (10) LogRecord.
    #  Use Case: Use this for internal narration during development — variable states, loop iterations, function entry/exit. NEVER leave these on in production
    log.debug("DEBUG: Input tensor shape is (1000, 14). Entering preprocessing.")

    # .info() fires an INFO-level (20) LogRecord.
    #  Use Case: Normal operational milestones. 'Model loaded', 'Server started', 'Job done'
    log.info("INFO: Model v2.3.1 loaded successfully from /models/prod/.")

    # .warning() fires a WARNING-level (30) LogRecord.
    #  Use Case: Nothing broke, but something smells wrong. Low confidence scores, deprecated API usage, retrying a failed connection
    log.warning("WARNING: Prediction confidence is 0.38. Below the 0.50 threshold.")

    # .error() fires an ERROR-level (40) LogRecord.
    #  Use Case: Something broke, but the logs is still alive. A single request failed but the server is still serving other requests
    log.error("ERROR: Database write failed for user_id=9921. Retrying in 5s.")

    # .critical() fires a CRITICAL-level (50) LogRecord.
    #  Use Case: The building is on fire. GPU out of memory, disk full, service crash. Page the on-call engineer NOW
    log.critical("CRITICAL: GPU memory exhausted. Training job terminated. All progress lost.")






# ===================================== SEGMENT 1.2 — basicConfig (THE QUICK-START) =====================================

for present_handler in log.handlers[:]:

    log.removeHandler(hdlr = present_handler) # .removeHandler() detaches a handler from the logger.

    present_handler.close() # .close() releases the file/stream resource the handler was holding




def reset_logger(the_logging: logging):


    for hdl in the_logging.handlers[:]:

        the_logging.removeHandler(hdlr = hdl) # .removeHandler() detaches a handler from the logger.

        hdl.close() # .close() releases the file/stream resource the handler was holding



# In production, you don't want DEBUG/INFO flooding your logs with noise.
#  Setting level=WARNING means only WARNING (30), ERROR (40), CRITICAL (50) get through.
#  DEBUG and INFO are silently dropped before they even reach any handler

log_format = "%(asctime)s ::: %(levelname)s ::: %(message)s\n"

logging.basicConfig(
    level = logging.WARNING,

    format = log_format
)


segment_1_2 = False

if segment_1_2:

    logging.debug("This is DEBUG! (Should be blind)")

    logging.info("This is info! (Should also be blind)")

    logging.warning("This is WARNING! (Should be seen)")

    logging.error("This is ERROR! (Should be seen)")

    logging.warning('This is CRITICAL! (Should be seen)')



for handler in log.handlers[:]:

    log.removeHandler(hdlr = handler)

    handler.close()


log_path = 'logs/logs.log'

logging.basicConfig(
    level = logging.DEBUG,
    filename = log_path,
    filemode = "w",
    format = "%(name)s ::: %(message)s\n"
)


# Firing logs now. You will NOT see them in the terminal (they go to file)

if segment_1_2:

    logging.debug("Secret DEBUG message — written to logs.log, invisible in terminal.")

    logging.info("INFO message — also in logs.log.")

    logging.error("ERROR message — also in logs.log.")



    # os.path.exists() checks if a file path exists on disk. Returns True/False
    if os.path.exists(path = log_path):
        print("logs.log was created on disk. Contents:\n")
        
        # open() with mode='r' opens the file for reading.
        #  .read() loads the entire file content as a single string
        with open(file = log_path, mode = "r") as log_file:

            print(log_file.read())

    else:
        print("ERROR: logs.log was not found. Something went wrong.")







# ===================================== SEGMENT 1.3 — HANDLERS (THE DELIVERY SYSTEM) =====================================


"""
basicConfig is a convenience wrapper — it can only target ONE destination.

Handlers give us full control. We create them manually and attach them to a named logger (not the root logger). This is the pattern we use from now on.

The architecture:
   Named Logger  ──publishes──►  StreamHandler  ──►  Terminal (ERROR+ only)
                 ──publishes──►  FileHandler    ──►  full_history.log (DEBUG+)

Same logger. Same .debug()/.error() calls. Two subscribers. Different filters
"""



# resetting the root logger...

reset_logger(the_logging = log)



# creating a named logger
'''
logging.getLogger(name='ml_pipeline') creates a NAMED logger

Named loggers are isolated from the root logger and from each other.
The name is what appears in the %(name)s slot of your format string.

Convention in real projects: use __name__ (the module's filename)

logging.getLogger(__name__)

'''

log_han_fmt = logging.getLogger(name = 'Model_Train_Script')


# we set the level to DEBUG to ensure that all logs reaches the handlers, where they can filter them based on their settings...

log_han_fmt.setLevel(level = logging.DEBUG)


# logging.Formatter() creates a reusable format template object.
#  We build two — one verbose (for file), one clean (for terminal)

formatter_for_file = logging.Formatter(
    fmt = "{asctime} ::: {name} ::: {levelname} ::: [{filename}: line {lineno}] ::: {message}",

    datefmt = "%Y/%m/%d, %I:%M %p",

    style = '{' # options are '%', '$' or '{' (check things to note)
)


formatter_for_terminal = logging.Formatter(
    fmt = '${levelname} ==> ${message}',

    style = '$'
)


# ===================================== HANDLER 1: StreamHandler (Terminal, ERROR and above only) =====================================

"""
logging.StreamHandler() sends log records to a stream — by default stderr.
 
We only want errors surfaced in the terminal. Developers don't need to see DEBUG/INFO noise while watching the screen


.setLevel() on the HANDLER sets a second-level filter.
Even though the logger passes DEBUG+ through, this handler ignores anything below ERROR (40). Only ERROR and CRITICAL reach the terminal
"""

terminal_handler = logging.StreamHandler()

terminal_handler.setLevel(level = logging.ERROR)

terminal_handler.setFormatter(fmt = formatter_for_terminal)





# ===================================== HANDLER 2: FileHandler (Disk, EVERYTHING from DEBUG up) =====================================

# creating a file handler...

"""
logging.FileHandler() writes log records to a file on disk.

filename='full_history.log': The target file path.

mode='w': Write mode -> creates fresh file each run
"""

log_file_handler = logging.FileHandler(
    filename = log_path,
    mode = 'w'
)


log_file_handler.setLevel(level = logging.DEBUG)

log_file_handler.setFormatter(fmt = formatter_for_file)



# attaching both handlers to our logger

log_han_fmt.addHandler(hdlr = terminal_handler) # adding terminal handler

log_han_fmt.addHandler(hdlr = log_file_handler) # adding file handler




"""
Named logger 'Model_Train_Script' configured with StreamHandler + FileHandler

StreamHandler threshold: ERROR+  |  FileHandler threshold: DEBUG+
Firing all 5 levels now. ONLY ERROR and CRITICAL appear below:
"""


log_han_fmt.debug("DEBUG: Loading dataset from /data/real_estate/train.csv")
log_han_fmt.info("INFO: Feature engineering complete. 47 features retained.")
log_han_fmt.warning("WARNING: 3 rows had null bedroom counts. Imputed with median.")
log_han_fmt.error("ERROR: Model prediction returned NaN for input vector [0, 0, 0, 0].")
log_han_fmt.critical("CRITICAL: Inference service ran out of memory. Shutting down.")








































































































































# Sets the directory path where log files for segment 2.1 will be stored into a variable named 'log_dir'.
log_dir = "./logs/Segment_2_1/"
# Defines the specific base filename for the log file, storing it in 'log_filename'.
log_filename = "Segment_2_1_logs.log"
# Joins the directory and filename using the OS-specific path separator to create a complete target path for logging.
full_path = os.path.join(log_dir, log_filename)

# Requests a specific logger instance named 'log_FZ_rotate' from the logging system and assigns it to 'log_file_size_rotator'.
log_file_size_rotator = logging.getLogger(name = 'log_FZ_rotate')

# Sets the minimum severity threshold for this specific logger to DEBUG, meaning it will process all log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL).
log_file_size_rotator.setLevel(
    # Explicitly assigns the level parameter to the logging.DEBUG constant.
    level = logging.DEBUG
# Closes the setLevel method call.
)


# Initializes a Formatter object that determines the exact text layout of every log message produced by this logger.
the_formatter = logging.Formatter(
    # Defines the format string structure: Timestamp ::: Logger Name ::: Severity Level ::: The actual log message followed by a newline.
    fmt = "%(asctime)s ::: %(name)s ::: %(levelname)s ::: %(message)s\n"
# Closes the Formatter instantiation.
)




# ===================================== Segment 2.1: Log Rotation (Disk Space Safety) =====================================


# ===================================== PART A: RotatingFileHandler (Size-Based Rotation) =====================================

# Initializes a RotatingFileHandler to manage log files that automatically "roll over" when they reach a certain size.
file_size_handler = logging.handlers.RotatingFileHandler(
    # Tells the handler exactly which file path to write its log data into.
    filename = full_path,

    mode = 'w', # could be 'w' for write (delete everything and write yours) or 'a' for append (add yours at the bottom)
    # Sets the maximum allowed size for a single log file to 1500 bytes before it triggers the creation of a new file.
    maxBytes = 1500,
    # Instructs the handler to keep a maximum of 3 older backup log files before permanently deleting the oldest ones.
    backupCount = 3
# Closes the RotatingFileHandler instantiation.
)

# Sets the minimum severity threshold specifically for this file handler to INFO, meaning it will ignore DEBUG messages.
file_size_handler.setLevel(level = logging.INFO)



# Binds the previously created text formatter ('the_formatter') to this file handler so logs are written in the desired format.
file_size_handler.setFormatter(fmt = the_formatter)


# Attaches the fully configured size-based file handler to our designated logger instance.
log_file_size_rotator.addHandler(
    # Explicitly maps our handler object to the 'hdlr' parameter.
    hdlr = file_size_handler
# Closes the addHandler method call.
)


# Disables propagation to prevent this logger's messages from bubbling up to higher-level loggers and causing duplicate outputs.
log_file_size_rotator.propagate = False


# Creates a convenient shorthand alias named 'logger' that references the 'log_file_size_rotator' object.
logger = log_file_size_rotator


# Starts a for loop that will execute 39 times, assigning the current iteration number to the variable 'log_no'.
for log_no in range(1, 40):

    # Emits an INFO-level log message using the shorthand logger inside each loop iteration.
    logger.info(
        # Uses an f-string with a %d placeholder to inject 'log_no', and formats a random numpy float to 3 decimal places for a mock confidence score.
        f"Prediction job #%d completed. Confidence = {(np.random.rand()):.3f}. Model=v2.3.1.", log_no
    # Closes the logger.info method call.
    )


# Explicitly closes the file handler to ensure all buffered data is written and system file locks are released.
file_size_handler.close() # closing the handler...


# Checking the files...
# Uses a list comprehension to dynamically build a list of all rotated log files currently residing in the log directory.
files_rotated = [
    # Iterates over each string filename retrieved from the target directory.
    file for file in os.listdir(
        # Passes the designated logging directory path into os.listdir to scan its contents.
        path = log_dir
    # Filters the results to only include files that begin with the exact base log filename we defined earlier.
    ) if file.startswith(log_filename)
# Closes the list comprehension.
]


# Begins a loop to process the collected log filenames, using the built-in sorted() function to order them.
for file in sorted(
# Passes our list of rotated filenames into the sorted function.
files_rotated,
    # Uses the built-in 'len' function as the sorting key, so files with shorter names (like the base file) appear before longer names.
    key = len
# Closes the sorted function call and starts the loop body.
):
    # Calculates the exact size of the current file in bytes and stores it in 'size_of_file'.
    size_of_file = os.path.getsize(
        # Constructs the required absolute file path by joining the directory and the current filename string.
        filename = os.path.join(log_dir, file)
    # Closes the os.path.getsize function call.
    )


    # Prints the filename (formatted to a minimum width of 30 characters for alignment) alongside its byte size.
    print(f'{file:<30} => {size_of_file} bytes')


# Prints a blank line to the console to visually separate the outputs of Part A and Part B.
print()


# ===================================== PART B: TimedRotatingFileHandler (Time-Based Rotation) =====================================


# Requests a new, specific logger instance named "Time-Based Handler" to manage time-based rotation examples.
timed_rotating_logger = logging.getLogger(name = "Time-Based Handler")

# Sets the minimum threshold for this new logger to DEBUG, allowing it to process all levels of logging data.
timed_rotating_logger.setLevel(level = logging.DEBUG)



"""
WHAT: logging.handlers.TimedRotatingFileHandler() rotates based on elapsed time.

Parameter Breakdown:
filename='rotating_timed.log' : The active log file.
when='s': Rotation interval unit.
's' = seconds (demo only).
Production values:
'midnight' = every day at midnight
'h' = every hour
'W0' = every Monday (W0=Mon ... W6=Sun)
interval=2: How many 'when' units between rotations.
interval=2, when='s' means rotate every 2 seconds.
interval=1, when='midnight' means rotate daily.

backupCount=3, Keep the last 3 rotated files.

"""

# Redefines the log filename specifically for this segment to keep time-based logs separate from size-based logs.
log_filename = 'Segment_2_1_logs_timed.log'

# Reconstructs the complete file path using the same directory but the new time-based filename.
full_path = os.path.join(log_dir, log_filename)


# Initializes a TimedRotatingFileHandler which will automatically shift log files based on strict time intervals.
timed_rotating_handler = logging.handlers.TimedRotatingFileHandler(
    # Specifies the target file path for the active log file.
    filename = full_path,
    # Sets the unit of time measurement for rotation to 's' (seconds) for demonstration purposes.
    when = 's', # s = seconds
    # Defines the interval magnitude as 2, combining with 'when' to trigger a rotation exactly every 2 seconds.
    interval = 2, # create a new file every 2 seconds
    # Configures the handler to retain up to 4 historical backup files before permanently deleting the oldest.
    backupCount = 4
# Closes the TimedRotatingFileHandler instantiation.
)



# Sets the specific log severity threshold for this handler to DEBUG, ensuring it captures all emitted messages.
timed_rotating_handler.setLevel(
    # Explicitly assigns the level parameter to the logging.DEBUG constant.
    level = logging.DEBUG
# Closes the setLevel method call.
)

# Binds the previously created standardized text formatter to ensure these timed logs match the visual structure of the others.
timed_rotating_handler.setFormatter(fmt = the_formatter)

# Attaches the fully configured time-based handler to our specific "Time-Based Handler" logger.
timed_rotating_logger.addHandler(hdlr = timed_rotating_handler)

# Disables propagation to stop these logs from automatically bubbling up to the root logger and printing twice.
timed_rotating_logger.propagate = False


# Initiates a for loop that will run 3 times, simulating distinct bursts of logging activity over time.
for log_burst in range(1, 4):


    # Emits an INFO-level log containing a multi-line format string to simulate a complex training epoch summary.
    timed_rotating_logger.info(f"""Level: #%d
ID: #%d-A-LOG-FILE
Training Epoch complete with loss at {(np.random.randn()):.3f}
""",
    # Injects the current burst number into the first '%d' formatting placeholder in the string above.
    log_burst,
    
    # Injects the current burst number into the second '%d' formatting placeholder in the string above.
    log_burst
    # Closes the timed_rotating_logger.info method call.
    )

    # Prints a console message indicating the burst was fired and that the script will intentionally pause.
    print(f"Log Burst #{log_burst} fired. Sleeping 2.5 seconds to cross the rotation boundary...")

    # Forcefully pauses the script's execution for 2.5 seconds to artificially exceed the handler's 2-second rotation threshold.
    time.sleep(2.5)



# Closes the time-based file handler to cleanly finish writing operations and release associated file locks.
timed_rotating_handler.close()


# checking files...

# Generates a list of all time-rotated log files in the directory by scanning and filtering filenames.
files_timed = [
    # Loops through every file found inside the logging directory path.
    file for file in os.listdir(path = log_dir) if file.startswith(log_filename)
# Closes the list comprehension.
]

# Prints the raw list of found timed log files to the console inside a multi-line formatted string.
print(f"""
Files Obtained:
{files_timed}
""")


# Iterates over the collected list of timed files, sorting them by filename length for a cleaner visual output.
for file in sorted(files_timed, key = len):

    # Calculates the byte size of the currently iterated timed log file.
    FSZ = os.path.getsize(
        # Builds the necessary absolute path required by the getsize function.
        filename = os.path.join(log_dir, file)
    # Closes the os.path.getsize function call.
    )

    # Prints the filename (padded to 30 characters) and its corresponding size in bytes to the terminal.
    print(f"{file:<30} => {FSZ} bytes")



"""
Note the timestamp suffix on rotated files (YYYY-MM-DD_HH-MM-SS)

In production with when='midnight', suffix is just YYYY-MM-DD

A DevOps engineer can now archive 'last_week.log' by date. No guessing
"""



# ===================================== Segment 2.2: Structured Logging (JSON) =====================================



# Creates a new logger named 'Logging with JSON' specifically to demonstrate outputting logs as structured JSON data.
JSON_logger = logging.getLogger(
    # Passes the desired name string to identify this logger instance.
    name = 'Logging with JSON'
# Closes the getLogger method call.
)

# Sets the operational threshold for the JSON logger to DEBUG so it will capture absolutely all log levels.
JSON_logger.setLevel(level = logging.DEBUG)

# Reassigns the 'log_dir' variable to point to a new subdirectory dedicated entirely to the JSON logging examples.
log_dir = "./logs/Segment_2_2/"

# Initializes a JsonFormatter, a special tool from the 'pythonjsonlogger' library that structures logs as JSON objects.
the_JSON_formatter = jsonlogger.JsonFormatter(
    # Specifies which standard logging fields (time, level, name, message) should be included as keys in the JSON object.
    fmt = "%(asctime)s %(levelname)s %(name)s %(message)s",

    datefmt = "%Y-%m-%dT%H:%M:%S" # datefmt controls the format of the 'asctime' timestamp value in the JSON output. ISO 8601 format is used here because Datadog, Splunk, and CloudWatch all parse it automatically without any custom configuration
# Closes the JsonFormatter instantiation.
)

# Defines a specific filename ending in '.jsonl' (JSON Lines), which is a standard format for streaming JSON log records.
log_filename = "Segment_2_2_logs.jsonl"

# Joins the new directory and the '.jsonl' filename to formulate the absolute path for the JSON log file.
full_path = os.path.join(log_dir, log_filename)


# Creates a standard FileHandler that will write our fully formatted JSON strings directly to the target disk file.
JSON_HANDLER = logging.FileHandler(
    # Provides the calculated path indicating where the file should be saved.
    filename = full_path,
    # Uses 'w' (write) mode so the file is freshly overwritten each time this demonstration script runs.
    mode = 'w'
# Closes the FileHandler instantiation.
)

# Restricts this specific file handler to only process log events that are at INFO level or higher.
JSON_HANDLER.setLevel(level = logging.INFO)

# Crucially attaches our specialized 'JsonFormatter' to this handler, transforming the output text into actual JSON structure.
JSON_HANDLER.setFormatter(fmt = the_JSON_formatter)

# Creates a standard StreamHandler to additionally output log messages directly to the terminal (stdout) for real-time visibility.
JSON_stream_handler = logging.StreamHandler()

# Allows the console stream handler to print everything, including highly detailed DEBUG level messages.
JSON_stream_handler.setLevel(level = logging.DEBUG)

# Defines a plain-text formatter specifically for the console so terminal output doesn't become overly cluttered with raw JSON.
t_format = logging.Formatter(
    # Dictates that the console will simply print the raw message text followed by a new line.
    fmt = '{message}\n',
    # Explicitly defines the format style as '{', which tells Python to use curly brace substitution instead of '%' substitution.
    style = '{'
# Closes the Formatter instantiation.
)

# Binds the plain-text console formatter to the stream handler.
JSON_stream_handler.setFormatter(
    # Explicitly assigns our format object to the 'fmt' parameter.
    fmt = t_format,
# Closes the setFormatter method call.
)


# Attaches the configured console handler to our JSON logger, enabling text output to the screen.
JSON_logger.addHandler(hdlr = JSON_stream_handler)

# Attaches the configured JSON file handler to the same logger, simultaneously enabling JSON output to the file.
JSON_logger.addHandler(hdlr = JSON_HANDLER)

# Stops this logger's messages from propagating up the chain, keeping the output strictly isolated to its own handlers.
JSON_logger.propagate = False

# Assigns a shorter, more convenient variable name ('json_log') to reference our fully configured JSON logger.
json_log = JSON_logger


# Triggers an INFO-level log message to simulate a routine successful operation within the system.
json_log.info(
    # The human-readable string describing the primary action that took place.
    "Model v2.3.1 loaded successfully from /models/prod/",

    # Leverages the 'extra' keyword to inject a dictionary of custom, structured metadata into the final JSON payload.
    extra = {
        # Dynamically generates a random 2x3 numpy array, extracts the first row as a standard Python list, and logs it as "Gradients".
        "Gradients": np.random.randn(2, 3).tolist()[0]
    # Closes the 'extra' metadata dictionary.
    }
# Closes the json_log.info method call.
)


# Triggers a WARNING-level log message to simulate a scenario where the application detects sub-optimal performance.
json_log.warning(
    # The primary warning string alerting developers to a low confidence score.
    "Prediction confidence below threshold.",

    # Injects contextual metadata to help developers trace exactly why the warning occurred.
    extra = {
        # Records the specific version of the machine learning model active at the time.
        "model_version": 'v2.3.1',

        # Computes a simulated confidence score, rounds it to 3 decimal places, and records it.
        'confidence': round(np.random.rand(), 3),

        # Computes a simulated threshold requirement and records it for comparison against the confidence score.
        "threshold": round(np.random.rand(), 3)
    # Closes the 'extra' metadata dictionary.
    }
# Closes the json_log.warning method call.
)




# Triggers an ERROR-level log message to signify a major calculation failure within the mock application logic.
json_log.error(
    # The primary error text indicating that mathematical operations yielded an invalid 'Not-a-Number' result.
    "Prediction returned NaN for input vector",

    # Attaches critical debugging context directly into the JSON structure so the error can be reproduced and fixed.
    extra = {
        # Logs the model version where the error occurred.
        'model_version': 'v2.3.1',

        # Logs the specific integer ID of the user whose request caused the crash.
        'user_id': 9933,

        # Logs the structural dimensions (shape) of the input data that triggered the mathematical failure.
        'shape_of_input': [[13, 34]]
    # Closes the 'extra' metadata dictionary.
    }
# Closes the json_log.error method call.
)


# Opens a traditional try-except block to intentionally execute flawed code and demonstrate automated exception logging.
try:

    # Purposely attempts to add an integer to a string, an illegal operation in Python that immediately raises an exception.
    p = 1 + "23"

# Explicitly catches the TypeError that is guaranteed to be raised by the illegal addition operation above.
except TypeError:
    
    """
    logger.exception() is identical to logger.error() but it automatically
    captures the current exception's full stack trace via exc_info=True

    python-json-logger serializes the traceback into an 'exc_info' field in the JSON object — fully structured and searchable.
    """

    # Evaluates a static 'True' condition to create a scoped block of code for modifying handler states.
    if True:

        # i don't want JSON_stream_handler to print the error on the terminal
        
        # Manually closes the console stream handler to temporarily suppress output to the terminal screen.
        JSON_stream_handler.close()

        # Completely detaches the stream handler from the logger so the impending massive stack trace only goes to the JSON file.
        json_log.removeHandler(hdlr = JSON_stream_handler)


    # Calls the exception() method, which logs at the ERROR level and automatically appends the entire traceback to the payload.
    json_log.exception(
        # The base error string containing a lighthearted developer-to-developer message.
        "Can't add an integer and a string together. This isn't bash Fool!",

        # Appends custom structural metadata alongside the automated traceback data.
        extra = {
            # Injects a mocked model version indicating where this bug might exist.
            'model_version': 'v1.0-34',

            # Injects the mocked training epoch during which the crash happened.
            'epoch': 33
        # Closes the 'extra' metadata dictionary.
        },

        exc_info = True # it's true by default, but i'm just adding it because, you know, I'm cool
    # Closes the json_log.exception method call.
    )

    # add the handler back for procceding code...
    # Re-attaches the console stream handler so any future logging operations will once again appear in the terminal.
    json_log.addHandler(hdlr = JSON_stream_handler)


# closing handler...

# Formally closes the JSON FileHandler to ensure all remaining data buffers are flushed and properly written to the disk.
JSON_HANDLER.close()



# Opens the newly created JSON lines file in read mode to programmatically parse and verify the logs we just generated.
with open(
    # Targets the exact file path where the JSON logs were just written.
    file = full_path,
    # Specifies 'r' (read) access mode.
    mode = 'r'
# Contextually aliases the opened file object as 'log_jsonl_file'.
) as log_jsonl_file:
    
    # Iterates over the file line-by-line, utilizing enumerate to keep track of line numbers starting from index 1.
    for line_no, line in enumerate(
        # Treats the file object as an iterable, where each iteration yields one line of text (one complete JSON object).
        iterable = log_jsonl_file,
        # Starts the enumeration counter at 1 for human-readable indexing rather than Python's default of 0.
        start = 1
    # Closes the enumerate function parameters and enters the loop body.
    ):
        
        # converting JSON back to python dict...

        # Utilizes the json.loads method to deserialize the raw string payload back into a native Python dictionary structure.
        json_to_dict = json.loads(
            # Strips whitespace and newline characters from the edges of the line string to ensure safe JSON parsing.
            s = line.strip()
        # Closes the json.loads method call.
        )

        # Uses the configured JSON logger to output the successfully parsed dictionary back into the console for inspection.
        json_log.info(
            # Uses a multi-line f-string to clearly label the record number and display the nicely formatted parsed data.
            f"""
Record {line_no}:
{json.dumps(
    # Feeds the newly recreated Python dictionary into json.dumps to convert it back to a string format.
    obj = json_to_dict,
    # Applies an indentation of 2 spaces, making the deeply nested JSON structure visually hierarchical and readable.
    indent = 2
# Closes the json.dumps formatting call.
)}
        """ # Closes the massive multi-line f-string.
        ) # Closes the json_log.info method call.








# ===================================== Segment 2.3: dictConfig (The Configuration File) =====================================

"""
# ===================================== YAML file (dictConfig.yaml) =====================================

# Specifies the schema version for the Python logging configuration dictionary; '1' is the only currently supported version.
version: 1

# Ensures that any loggers created before this configuration is loaded are kept active rather than being disabled.
disable_existing_loggers: false


# Begins the section defining the layout, structure, and text formatting of log messages.
formatters:
  
  # Names a custom formatting template ('file_format') intended for standard plain-text log files.
  file_format:
    # Sets the exact string layout for file logs, including timestamp, logger name, level, filename, line number, and the core message.
    format: "{asctime} ::: {name} ::: {levelname} ::: [{filename}: line {lineno}] ::: {message}\n"

    # Instructs the formatter to represent the {asctime} variable in a Day/Month/Year, 12-hour format with AM/PM.
    datefmt: "%d/%m/%Y, %I:%M:%S %p"

    # Indicates that this specific format string uses modern Python curly-brace substitution instead of the default '%' style.
    style: '{'

  # Names a simpler, custom formatting template ('terminal_format') intended for console output.
  terminal_format:

    # Sets the layout for console logs, omitting timestamps for a cleaner view and utilizing the older '%' substitution style.
    format: "%(name)s, %(levelname)s => %(message)s\n"

    # datefmt: 

  # Names a specialized formatting template ('json_format') designed to output logs as fully structured JSON data.
  json_format:

    # Think of the () key like a "Use My Own Tool" button.

    # (): "Go find this specific tool called JsonFormatter inside the pythonjsonlogger package."
    
    # format: "When you make the tool, tell it to include the time, the error level, the name, and the message in every log."
    
    # datefmt: "Also, make sure the time looks exactly like this: Year-Month-Day and Hour-Minute-Second."

    # Uses the special '()' key to inject a custom class, effectively instantiating the third-party JsonFormatter object.
    (): pythonjsonlogger.jsonlogger.JsonFormatter # we tell dictConfig to import the JsonFormatter class

    # Dictates which standard log record attributes the JsonFormatter should extract and convert into key-value pairs in the JSON structure.
    format: "%(asctime)s %(levelname)s %(name)s %(message)s"

    # Sets the specific date/time format for the timestamp attribute inside the generated JSON object.
    datefmt: "%d/%m/%Y, %I:%M:%S %p"
  


# Begins the section defining 'handlers', which are responsible for routing log messages to their final destinations (files, terminal, etc.).
handlers:

  # Names a specific handler configuration ('terminal_handler') intended to print logs visibly to the console screen.
  terminal_handler:

    # Tells the logging system to instantiate Python's built-in StreamHandler class for this component.
    class: logging.StreamHandler

    # Configures this console handler to ignore DEBUG logs and only display INFO-level logs and above.
    level: INFO

    # Links this handler to the 'terminal_format' text layout defined in the 'formatters' section above.
    formatter: terminal_format

    # Uses the 'ext://' prefix to dynamically resolve Python's standard output stream (the terminal screen) at runtime.
    stream: ext://sys.stdout

  
  # Names a specific handler configuration ('file_handler') intended to save standard plain-text logs persistently to the disk.
  file_handler:

    # Tells the logging system to instantiate Python's built-in FileHandler class to manage writing to a file.
    class: logging.FileHandler

    # Links this file handler to the highly detailed 'file_format' layout defined earlier.
    formatter: file_format

    # Specifies the exact relative file path where these plain-text logs should be saved.
    filename: './logs/print.log'

    # Configures the plain-text file handler to only record logs that are INFO-level or more severe.
    level: INFO

    # Instructs the file handler to open the log file in 'write' mode, meaning it will overwrite the file from scratch every time the script runs.
    mode: w

  # Names a specific handler configuration ('jsonl_handler') intended to save structured JSON logs to the disk.
  jsonl_handler:
    
    # Links this specialized handler to the 'json_format', which utilizes the third-party JSON builder.
    formatter: json_format

    # Ensures the JSON log file is also opened in 'write' mode, refreshing the file completely upon script execution.
    mode: w

    # Specifies the dedicated output file path for the JSON-formatted log lines.
    filename: './logs/Segment_2_2/Segment_2_2_logs.jsonl'

    # Configures this specific handler to capture absolutely everything routed to it, including the lowest-level DEBUG messages.
    level: DEBUG

    # Tells the system to use the standard FileHandler class, which simply writes the formatted JSON strings to the specified disk path.
    class: logging.FileHandler



# Begins the section where individual, named loggers are defined and wired up to their respective handlers.
loggers:

  # Configures a specific logger instance named 'predictions_logger', making it available when the application calls `logging.getLogger('predictions_logger')`.
  predictions_logger:

    # Sets the base severity threshold for 'predictions_logger' to DEBUG, allowing it to process all message types it receives.
    level: DEBUG

    # Routes any log messages emitted by 'predictions_logger' to both the terminal screen and the plain-text disk file.
    handlers: [terminal_handler, file_handler]

    # Prevents 'predictions_logger' messages from bubbling up to the root logger, avoiding duplicate entries if the root logger also has handlers.
    propagate: false

  
  # Configures another specific logger instance named 'training_logger'.
  training_logger:

    # Sets the baseline severity threshold for 'training_logger' to INFO, meaning any DEBUG messages sent to it will be immediately discarded.
    level: INFO

    # Routes 'training_logger' messages to the plain-text file AND the JSON lines file simultaneously.
    handlers: [file_handler, jsonl_handler]

    # Stops 'training_logger' messages from ascending to the root logger, keeping its outputs strictly isolated to its assigned handlers.
    propagate: false

# Configures the master 'root' logger, which sits at the absolute top of the logging hierarchy and acts as a catch-all for undefined loggers.
root:

  #  Any logger not explicitly defined above propagates up here.
  
  # WARNING threshold keeps noisy third-party library logs suppressed

  # Restricts the root logger to only process WARNING, ERROR, or CRITICAL messages, effectively filtering out standard system chatter from unconfigured sources.
  level: WARNING

  # Attaches the console handler to the root logger, ensuring that critical unhandled warnings or errors always print to the terminal screen.
  handlers: [terminal_handler]

"""



# Establishes a boolean control flag that dictates whether the code will attempt to load an external YAML configuration.
yaml_dictConfig_import = True

# Checks the flag; since it is True, it allows the script to proceed with configuring loggers via an external file.
if yaml_dictConfig_import:

    # Uses a context manager to securely open the external YAML file containing the centralized logging configuration.
    with open(
        # Specifies the exact relative path to the configuration file on the system.
        file = './Logging/dictConfig.yaml',
        # Requests 'r' (read) mode so the file is only parsed, never accidentally modified.
        mode = 'r'
    # Aliases the active file stream as the variable 'config_file'.
    ) as config_file:
        
        # converting YAML file to python dictionary...

        # Passes the raw file stream into yaml.safe_load, which securely parses the YAML text into a structured Python dictionary.
        yaml_dictConfig = yaml.safe_load(stream = config_file)

    
    # Passes the fully parsed dictionary directly to dictConfig, which instantly builds all loggers, formatters, and handlers defined within.
    logging.config.dictConfig(config = yaml_dictConfig)



# Retrieves the 'predictions_logger' instance, which was entirely constructed and configured behind the scenes by the YAML dictConfig above.
pred_logger = logging.getLogger(name = 'predictions_logger')


# Retrieves the 'training_logger' instance, which was similarly constructed and configured by the YAML dictConfig.
tr_logger = logging.getLogger(name = 'training_logger')


# Emits an INFO-level message via the 'training_logger' to demonstrate logging standard operational events.
tr_logger.info(
    # The primary action text indicating a prediction request came in.
    "Prediction request received!",

    # Attaches metadata that the YAML-configured JSON handler (if attached) will parse and include in its output.
    extra = {
        # Records the integer ID of the user requesting the prediction.
        "user_id": 1042,
         
        # Records the number of data features the user sent in their request payload.
        "input_features": 47
    # Closes the 'extra' metadata dictionary.
    }
# Closes the tr_logger.info method call.
)


# Emits a WARNING-level message via the 'training_logger', verifying the logger correctly processes elevated severity levels.
tr_logger.warning(
    # A generic mocked string serving as the core warning message.
    "jesse is an MLOps Engineer",

    # Attaches further arbitrary metadata to demonstrate structured payload handling at different log levels.
    extra = {
        # Logs a mock status key-value pair.
        'status': 'cool',

        # Logs a mock age key-value pair.
        "age": 20
    # Closes the 'extra' metadata dictionary.
    }
# Closes the tr_logger.warning method call.
)


# Emits a WARNING-level message through the separate 'predictions_logger' to simulate detecting an anomaly during model training.
pred_logger.warning(
    # The warning text suggesting that the model might be memorizing data (overfitting) at a specific epoch.
    "Validation loss increased. Possible overfitting at epoch 12."
# Closes the pred_logger.warning method call.
)

# Emits an ERROR-level message through the 'predictions_logger' to simulate a fatal, system-crashing event.
pred_logger.error(
    # The error text stating that the hardware ran out of memory, terminating the job.
    "Training job failed. OOM error on GPU."
# Closes the pred_logger.error method call.
)












