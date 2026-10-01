import os
import json
import numpy as np
import time
import yaml
import logging
import logging.handlers
import logging.config
from pythonjsonlogger import jsonlogger







# ===================================== SEGMENT 1.1 — THE ANATOMY OF A RECORD =====================================


"""
logging.basicConfig() — One-shot configuration for the root logger.

level=logging.DEBUG: Sets the minimum severity threshold to DEBUG (level 10). This means ALL messages (DEBUG and above) will be shown.

format=: The string template for each log line. Each %(...)s token maps directly to an attribute on the LogRecord object Python creates behind the scenes when you call a log method
"""

# Calls logging.basicConfig() to perform one-time, convenience configuration of the root logger's default behavior globally
# This function creates and attaches a default handler (StreamHandler by default, or FileHandler if filename= is specified) to the root logger
logging.basicConfig(
    # Sets the root logger's severity threshold to DEBUG (level 10); all messages at DEBUG level and above (INFO, WARNING, ERROR, CRITICAL) pass to handlers
    level = logging.DEBUG,

    # Defines the LogRecord-to-string template using %(...)s substitution style; each %(key)s is replaced with LogRecord.key attribute at runtime
    # asctime = timestamp (formatted per dateformat), name = logger name, levelname = severity name, filename = source file, lineno = source line, message = log text
    format = """Date: %(asctime)s
User: %(name)s
Log Level: %(levelname)s
Name of File: %(filename)s
Line Number: %(lineno)d
Log Message: %(message)s
"""
)


# Text comment: the root logger instance is retrieved and used to demonstrate the five severity levels below
# making use of the root logger to demonstrate...

# Calls logging.getLogger() with no arguments to retrieve the root logger instance (top of the logging hierarchy)
# The root logger is the parent of all named loggers; all messages propagate up to it unless propagate=False is set
log = logging.getLogger()


segment_1_1 = False

if segment_1_1:

    # .debug() fires a DEBUG-level (10) LogRecord.
    #  Use Case: Use this for internal narration during development — variable states, loop iterations, function entry/exit. NEVER leave these on in production
    # Calls the .debug(msg) method on the root logger, creating a LogRecord with severity DEBUG (10) and the provided message string
    # At runtime: LogRecord is created, passed to logger level check (DEBUG >= DEBUG: True), then forwarded to all attached handlers
    log.debug("DEBUG: Input tensor shape is (1000, 14). Entering preprocessing.")

    # .info() fires an INFO-level (20) LogRecord.
    #  Use Case: Normal operational milestones. 'Model loaded', 'Server started', 'Job done'
    # Calls the .info(msg) method on the root logger, creating a LogRecord with severity INFO (20) and the provided message string
    # At runtime: LogRecord is created, passed to logger level check (INFO >= DEBUG: True), then forwarded to all attached handlers
    log.info("INFO: Model v2.3.1 loaded successfully from /models/prod/.")

    # .warning() fires a WARNING-level (30) LogRecord.
    #  Use Case: Nothing broke, but something smells wrong. Low confidence scores, deprecated API usage, retrying a failed connection
    # Calls the .warning(msg) method on the root logger, creating a LogRecord with severity WARNING (30) and the provided message string
    # At runtime: LogRecord is created, passed to logger level check (WARNING >= DEBUG: True), then forwarded to all attached handlers for formatting/output
    log.warning("WARNING: Prediction confidence is 0.38. Below the 0.50 threshold.")

    # .error() fires an ERROR-level (40) LogRecord.
    #  Use Case: Something broke, but the logs is still alive. A single request failed but the server is still serving other requests
    # Calls the .error(msg) method on the root logger, creating a LogRecord with severity ERROR (40) and the provided message string
    # At runtime: LogRecord is created, passed to logger level check (ERROR >= DEBUG: True), then routed to handlers for display
    log.error("ERROR: Database write failed for user_id=9921. Retrying in 5s.")

    # .critical() fires a CRITICAL-level (50) LogRecord.
    #  Use Case: The building is on fire. GPU out of memory, disk full, service crash. Page the on-call engineer NOW
    # Calls the .critical(msg) method on the root logger, creating a LogRecord with severity CRITICAL (50) and the provided message string
    # At runtime: LogRecord is created, passed to logger level check (CRITICAL >= DEBUG: True), then transmitted to all handlers with highest urgency
    log.critical("CRITICAL: GPU memory exhausted. Training job terminated. All progress lost.")






# ===================================== SEGMENT 1.2 — basicConfig (THE QUICK-START) =====================================

# Initiates a for loop iterating over log.handlers[:] — a shallow copy of all handler objects currently attached to the log logger
# The [:] slice creates a copy to safely modify the original list during iteration (preventing "list changed size during iteration" errors)
for present_handler in log.handlers[:]:

    # Calls the .removeHandler(hdlr=...) method on the logger, detaching the specified handler from the logger's internal handlers list
    # At runtime: The handler is unlinked from the logger; it will no longer receive LogRecords from this logger
    log.removeHandler(hdlr = present_handler) # .removeHandler() detaches a handler from the logger.

    # Calls the .close() method on the handler object, releasing underlying system resources (file descriptors, stream buffers, network connections)
    # At runtime: FileHandler flushes buffered log data to disk, closes the file handle; StreamHandler may flush stderr/stdout buffers
    present_handler.close() # .close() releases the file/stream resource the handler was holding




# Defines a reusable function named reset_logger that accepts a logging module or logger object as a parameter
# This function cleanly detaches all handlers from a logger and releases their resources, preparing it for reconfiguration
def reset_logger(the_logging: logging):

    # Initiates a for loop iterating over the_logging.handlers[:] — a shallow copy of all handlers attached to the passed logging/logger object
    # The [:] slice protects the original list from concurrent modification during iteration
    for hdl in the_logging.handlers[:]:

        # Calls .removeHandler() on the logger, severing the handler from the logger's internal handlers list
        # At runtime: LogRecords will no longer be delivered to this handler
        the_logging.removeHandler(hdlr = hdl) # .removeHandler() detaches a handler from the logger.

        # Calls .close() on the handler, cleanly releasing system resources and flushing any buffered data
        # At runtime: File handlers close file descriptors; stream handlers flush output buffers
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


# Text comment explaining the purpose of creating Formatter objects for reuse across multiple handlers
# logging.Formatter() creates a reusable format template object.
#  We build two — one verbose (for file), one clean (for terminal)

# Calls logging.Formatter() constructor to create a Formatter object that will render LogRecords as formatted text strings
# This Formatter will be attached to the FileHandler to produce detailed, verbose output
formatter_for_file = logging.Formatter(
    # Specifies fmt parameter using '{...}' style (set by style='{' below), which uses Python's str.format() method for placeholder substitution
    # At runtime: LogRecord attributes (asctime, name, levelname, filename, lineno, message) are extracted and inserted into this template
    fmt = "{asctime} ::: {name} ::: {levelname} ::: [{filename}: line {lineno}] ::: {message}",

    # Specifies datefmt parameter, which defines the time format applied to the %(asctime)s/%(asctime)d placeholder
    # Format string "%Y/%m/%d, %I:%M %p" = Year/Month/Day, 12-hour:Minute AM/PM
    datefmt = "%Y/%m/%d, %I:%M %p",

    # Specifies the style parameter as '{', instructing the Formatter to use Python's str.format() syntax for placeholder substitution
    # options are '%', '$' or '{' (check things to note)
    style = '{' # options are '%', '$' or '{' (check things to note)
)


# Calls logging.Formatter() constructor to create a second Formatter object with simpler, cleaner format for terminal/console output
formatter_for_terminal = logging.Formatter(
    # Specifies fmt parameter using '$' style (set by style='$' below), which uses Python's string.Template syntax for substitution
    # At runtime: LogRecord attributes (levelname, message) are extracted and substituted into this minimalist template
    fmt = '${levelname} ==> ${message}',

    # Specifies the style parameter as '$', instructing the Formatter to use string.Template (shell-like) substitution
    style = '$'
)


# ===================================== HANDLER 1: StreamHandler (Terminal, ERROR and above only) =====================================

"""
logging.StreamHandler() sends log records to a stream — by default stderr.
 
We only want errors surfaced in the terminal. Developers don't need to see DEBUG/INFO noise while watching the screen


.setLevel() on the HANDLER sets a second-level filter.
Even though the logger passes DEBUG+ through, this handler ignores anything below ERROR (40). Only ERROR and CRITICAL reach the terminal
"""

# Calls logging.StreamHandler() constructor with no arguments to create a StreamHandler that outputs to sys.stderr by default
# At runtime: This handler receives LogRecords from its parent logger, applies its own level filter, formats them, and writes to stderr/stdout
terminal_handler = logging.StreamHandler()

# Calls the .setLevel() method on the handler, setting its severity threshold to ERROR (level 40)
# At runtime: This handler will only process LogRecords with severity ERROR (40), CRITICAL (50); DEBUG/INFO/WARNING are silently dropped at handler level
# Note: This is a SECOND-LEVEL filter; the logger itself has already filtered at its own level, now the handler filters again
terminal_handler.setLevel(level = logging.ERROR)

# Calls the .setFormatter() method, attaching the previously created formatter_for_terminal to this handler
# At runtime: When this handler receives a LogRecord, it uses this formatter to convert the LogRecord object into a formatted text string before output
terminal_handler.setFormatter(fmt = formatter_for_terminal)





# ===================================== HANDLER 2: FileHandler (Disk, EVERYTHING from DEBUG up) =====================================

# Text comment: a file-based handler is being instantiated
# creating a file handler...

"""
logging.FileHandler() writes log records to a file on disk.

filename='full_history.log': The target file path.

mode='w': Write mode -> creates fresh file each run
"""

# Calls logging.FileHandler() constructor to create a FileHandler that writes LogRecords to a file on disk
# At runtime: This handler opens the specified file, receives LogRecords from its parent logger, formats them, and appends them to the file
log_file_handler = logging.FileHandler(
    # Specifies the filename parameter, which is the file path where logs will be written (log_path was set to 'logs/logs.log' earlier)
    filename = log_path,
    # Specifies mode='w', which opens the file in write mode (truncates existing content, starts fresh on each run)
    # Alternative: mode='a' for append (adds logs to end of existing file without truncating)
    mode = 'w'
)


# Calls the .setLevel() method on the FileHandler, setting its severity threshold to DEBUG (level 10)
# At runtime: This handler will accept and write all LogRecords with severity DEBUG (10) and above (INFO, WARNING, ERROR, CRITICAL)
# Unlike the StreamHandler above (which filters at ERROR), this FileHandler captures everything for comprehensive disk-based history
log_file_handler.setLevel(level = logging.DEBUG)

# Calls the .setFormatter() method, attaching the previously created formatter_for_file to this handler
# At runtime: When this handler receives a LogRecord, it uses this verbose formatter to render it as text (with timestamp, logger name, level, line number) before writing to disk
log_file_handler.setFormatter(fmt = formatter_for_file)



# Text comment: both handlers (StreamHandler and FileHandler) are now being attached to the logger
# attaching both handlers to our logger

# Calls the .addHandler() method on the named logger 'Model_Train_Script', registering the terminal_handler
# At runtime: When this logger emits a LogRecord, it will be passed to both its parent's handlers AND this terminal_handler
# The terminal_handler will evaluate the LogRecord against its ERROR-level threshold and output to stderr if it passes
log_han_fmt.addHandler(hdlr = terminal_handler) # adding terminal handler

# Calls the .addHandler() method on the named logger 'Model_Train_Script', registering the log_file_handler
# At runtime: When this logger emits a LogRecord, it will now also be passed to this file_handler in addition to the terminal_handler
# The file_handler will evaluate the LogRecord against its DEBUG-level threshold and write to disk if it passes
log_han_fmt.addHandler(hdlr = log_file_handler) # adding file handler




"""
Named logger 'Model_Train_Script' configured with StreamHandler + FileHandler

StreamHandler threshold: ERROR+  |  FileHandler threshold: DEBUG+
Firing all 5 levels now. ONLY ERROR and CRITICAL appear below:
"""

# Calls the .debug() method on the named logger, creating a LogRecord with DEBUG severity (10)
# At runtime: Logger level check (DEBUG >= DEBUG: True) passes; LogRecord forwarded to both handlers
# StreamHandler filter: DEBUG < ERROR: FILTERED OUT, not displayed on terminal
# FileHandler filter: DEBUG >= DEBUG: ACCEPTED, written to file
log_han_fmt.debug("DEBUG: Loading dataset from /data/real_estate/train.csv")

# Calls the .info() method on the named logger, creating a LogRecord with INFO severity (20)
# At runtime: Logger level check (INFO >= DEBUG: True) passes; LogRecord forwarded to both handlers
# StreamHandler filter: INFO < ERROR: FILTERED OUT, not displayed on terminal
# FileHandler filter: INFO >= DEBUG: ACCEPTED, written to file
log_han_fmt.info("INFO: Feature engineering complete. 47 features retained.")

# Calls the .warning() method on the named logger, creating a LogRecord with WARNING severity (30)
# At runtime: Logger level check (WARNING >= DEBUG: True) passes; LogRecord forwarded to both handlers
# StreamHandler filter: WARNING < ERROR: FILTERED OUT, not displayed on terminal
# FileHandler filter: WARNING >= DEBUG: ACCEPTED, written to file
log_han_fmt.warning("WARNING: 3 rows had null bedroom counts. Imputed with median.")

# Calls the .error() method on the named logger, creating a LogRecord with ERROR severity (40)
# At runtime: Logger level check (ERROR >= DEBUG: True) passes; LogRecord forwarded to both handlers
# StreamHandler filter: ERROR >= ERROR: ACCEPTED, formatted and displayed on terminal
# FileHandler filter: ERROR >= DEBUG: ACCEPTED, formatted and written to file
log_han_fmt.error("ERROR: Model prediction returned NaN for input vector [0, 0, 0, 0].")

# Calls the .critical() method on the named logger, creating a LogRecord with CRITICAL severity (50)
# At runtime: Logger level check (CRITICAL >= DEBUG: True) passes; LogRecord forwarded to both handlers
# StreamHandler filter: CRITICAL >= ERROR: ACCEPTED, formatted and displayed on terminal
# FileHandler filter: CRITICAL >= DEBUG: ACCEPTED, formatted and written to file
log_han_fmt.critical("CRITICAL: Inference service ran out of memory. Shutting down.")








































































































































# Assigns the string "./logs/Segment_2_1/" to log_dir variable, specifying the directory path where rotation segment log files will be stored
# At runtime: os.makedirs() or file operations will use this path to create/write log files
log_dir = "./logs/Segment_2_1/"

# Assigns the string "Segment_2_1_logs.log" to log_filename variable, specifying the base name for the primary log file
# At runtime: When rotation occurs, backup files will be named with numeric suffixes (e.g., Segment_2_1_logs.log.1, .log.2)
log_filename = "Segment_2_1_logs.log"

# Calls os.path.join() to construct a complete, OS-portable file path by joining log_dir and log_filename
# At runtime: On Unix/Linux this produces "./logs/Segment_2_1/Segment_2_1_logs.log"; on Windows the path separators adjust accordingly
full_path = os.path.join(log_dir, log_filename)

# Calls logging.getLogger(name='log_FZ_rotate') to retrieve or create a named logger with that specific name
# At runtime: This creates an isolated logger instance separate from the root logger; its messages will not propagate unless explicitly configured
log_file_size_rotator = logging.getLogger(name = 'log_FZ_rotate')

# Calls the .setLevel() method on the named logger, setting its severity threshold to DEBUG (level 10)
# At runtime: All LogRecords with severity DEBUG and above (INFO, WARNING, ERROR, CRITICAL) will pass this logger's level filter and be forwarded to attached handlers
log_file_size_rotator.setLevel(
    # Explicitly assigns the level parameter to the logging.DEBUG constant (numeric value 10)
    level = logging.DEBUG
# Closes the setLevel method call.
)


# Calls logging.Formatter() to create a Formatter object that will define how LogRecords are converted to text strings
# This formatter is reusable and will be attached to rotation handlers
the_formatter = logging.Formatter(
    # Defines the format string using %(...)s substitution style; includes asctime (timestamp), name (logger name), levelname (severity), and message
    # At runtime: Each LogRecord will be rendered as: "TIMESTAMP ::: logger_name ::: LEVEL ::: log message\n"
    fmt = "%(asctime)s ::: %(name)s ::: %(levelname)s ::: %(message)s\n"
# Closes the Formatter instantiation.
)




# ===================================== Segment 2.1: Log Rotation (Disk Space Safety) =====================================


# ===================================== PART A: RotatingFileHandler (Size-Based Rotation) =====================================

# Calls logging.handlers.RotatingFileHandler() constructor to create a handler that automatically rotates log files based on file size
# At runtime: When the log file reaches maxBytes, the handler renames it as a backup (.1, .2, .3) and creates a new primary log file
file_size_handler = logging.handlers.RotatingFileHandler(
    # Specifies the filename parameter, which is the path to the active (primary) log file
    # At runtime: LogRecords are written to this file until it reaches maxBytes
    filename = full_path,

    # Specifies mode='w', which opens the file in write mode (truncates existing file, starts fresh)
    # Alternative: mode='a' appends to existing file without truncating
    # At runtime: The active log file is opened/created in the specified mode
    mode = 'w', # could be 'w' for write (delete everything and write yours) or 'a' for append (add yours at the bottom)
    
    # Specifies maxBytes parameter (in bytes), which sets the maximum size the primary log file can reach before rotation triggers
    # At runtime: When file size >= 1500 bytes, the handler immediately closes the current file, renames it (.1), and opens a new primary file
    maxBytes = 1500,
    
    # Specifies backupCount parameter (number of backup files), which sets the maximum number of rotated backup files to keep
    # At runtime: If there are 3 backups and a 4th rotation occurs, the oldest backup (.3) is deleted permanently
    backupCount = 3
# Closes the RotatingFileHandler instantiation.
)

# Calls the .setLevel() method on the RotatingFileHandler, setting its severity threshold to INFO (level 20)
# At runtime: This handler will only write LogRecords with severity INFO (20) and above (WARNING, ERROR, CRITICAL)
# DEBUG messages are silently discarded at the handler level (even if the logger passed them through)
file_size_handler.setLevel(level = logging.INFO)



# Calls the .setFormatter() method on the RotatingFileHandler, attaching the previously created formatter
# At runtime: Every LogRecord passed to this handler is formatted using the_formatter before being written to the file
file_size_handler.setFormatter(fmt = the_formatter)


# Calls the .addHandler() method on the 'log_file_size_rotator' logger, registering this RotatingFileHandler
# At runtime: When this logger emits a LogRecord, it will be forwarded to this handler for level checking, formatting, and file writing (with rotation)
log_file_size_rotator.addHandler(
    # Explicitly passes the file_size_handler handler object to the 'hdlr' parameter
    hdlr = file_size_handler
# Closes the addHandler method call.
)


# Sets the propagate attribute to False on the 'log_file_size_rotator' logger
# At runtime: LogRecords emitted by this logger will NOT bubble up to parent loggers (preventing duplicate outputs in parent handlers)
# Default behavior (propagate=True) causes messages to propagate up the logger hierarchy, potentially causing duplicate logging
log_file_size_rotator.propagate = False


# Creates a convenient shorthand alias named 'logger' that references the 'log_file_size_rotator' object
# At runtime: Using logger.info() is equivalent to log_file_size_rotator.info(), reducing verbosity in the loop
logger = log_file_size_rotator


# Calls range(1, 40) to create an iterable of integers 1 through 39, initiating a for loop that iterates 39 times
# At runtime: Each iteration assigns the current iteration number to log_no and executes the loop body
for log_no in range(1, 40):

    # Calls the .info() method on the logger, emitting an INFO-level LogRecord
    # At runtime: The logger passes the LogRecord to its level filter (INFO >= DEBUG: passes), then to the RotatingFileHandler
    # The RotatingFileHandler checks its own level (INFO >= INFO: passes), then checks file size and rotates if needed, then formats and writes the message
    logger.info(
        # Uses an f-string (Python 3.6+) to dynamically build the log message
        # f"...{expression}..." evaluates the Python expression inside {...} and inserts the result as a string
        # At runtime: np.random.rand() generates a random float [0, 1), formatted to 3 decimal places using {:.3f}
        f"Prediction job #%d completed. Confidence = {(np.random.rand()):.3f}. Model=v2.3.1.", log_no
    # Closes the logger.info method call.
    )


# Calls the .close() method on the RotatingFileHandler, cleanly closing the active log file and flushing buffered data
# At runtime: All buffered LogRecords are written to disk, the file handle is released, and system resources are freed
file_size_handler.close() # closing the handler...


# Text comment indicating that the generated log files are now being inspected
# Checking the files...

# Uses a list comprehension to dynamically build a list of all rotated log files currently residing in the log directory
# At runtime: Filters all files in log_dir to include only those whose names start with log_filename
files_rotated = [
    # Iterates over each filename string returned by os.listdir() (the filenames in the directory, not full paths)
    file for file in os.listdir(
        # Calls os.listdir(path=...) to retrieve a list of all filenames in the specified directory
        # At runtime: Returns all filenames (base file, .1, .2, .3, etc.) and any other files in that directory
        path = log_dir
    # Applies the filter condition: only include files whose names start with log_filename
    # At runtime: Filters out any non-log files and keeps only Segment_2_1_logs.log, .log.1, .log.2, etc.
    ) if file.startswith(log_filename)
# Closes the list comprehension.
]


# Begins a loop to process the collected log filenames, using the built-in sorted() function to order them by length
# At runtime: sorted() arranges files by ascending name length, so the primary file appears first
for file in sorted(
# Passes our list of rotated filenames into the sorted function for ordering
files_rotated,
    # Uses the built-in 'len' function as the sorting key for sorted(), so files with shorter names (like Segment_2_1_logs.log) appear before .log.1, .log.2, .log.3
    key = len
# Closes the sorted function call and starts the loop body.
):
    # Calls os.path.getsize(filename=...) to retrieve the file size in bytes
    # At runtime: Returns the exact byte count of the specified file
    size_of_file = os.path.getsize(
        # Calls os.path.join(log_dir, file) to construct the complete file path from directory and filename
        # At runtime: Produces "./logs/Segment_2_1/filename" for each file in files_rotated
        filename = os.path.join(log_dir, file)
    # Closes the os.path.getsize function call.
    )


    # Calls print() with an f-string to output the filename and its size in bytes
    # At runtime: {file:<30} left-aligns the filename in a 30-character field; {size_of_file} inserts the byte count
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



# Declares a boolean flag variable that controls whether the YAML dictConfig file should be loaded and applied
# At runtime: This flag can be set to False to skip the external configuration and use only the programmatically defined loggers above
yaml_dictConfig_import = True

# Conditional statement that checks if yaml_dictConfig_import is True; if so, the external YAML configuration file will be loaded and applied
if yaml_dictConfig_import:

    # Calls open() with a context manager (with statement) to safely open and read the YAML configuration file
    # The context manager ensures automatic file closure even if an error occurs, preventing resource leaks
    with open(
        # Specifies file='./Logging/dictConfig.yaml', the relative path to the external YAML configuration file on disk
        # At runtime: Python opens this file for reading if it exists; raises FileNotFoundError if not found
        file = './Logging/dictConfig.yaml',
        # Specifies mode='r' (read mode), which opens the file for reading only (no modifications)
        # At runtime: File content is readable through the file object; any write attempt would raise an error
        mode = 'r'
    # Assigns the open file object to the variable config_file within the with block scope
    ) as config_file:
        
        # Text comment indicating that the YAML content will be converted to a Python dictionary
        # converting YAML file to python dictionary...

        # Calls yaml.safe_load(stream=...) to securely parse the YAML file content into a Python dictionary
        # safe_load prevents arbitrary code execution (unlike yaml.load without Loader=safe) by only constructing basic Python objects
        # At runtime: YAML syntax (key: value pairs, lists, nested structures) is converted to Python dict/list/str/int objects
        yaml_dictConfig = yaml.safe_load(stream = config_file)

    
    # Calls logging.config.dictConfig(config=...) to programmatically configure the entire logging system from the dictionary
    # dictConfig is the powerful bridge between configuration data and active logger/handler/formatter objects
    # At runtime: dictConfig reads the dictionary structure and creates all loggers, handlers, formatters, and their connections automatically
    # This single call replaces manually calling logging.Formatter(), logging.StreamHandler(), logger.addHandler(), etc.
    logging.config.dictConfig(config = yaml_dictConfig)



# Calls logging.getLogger(name='predictions_logger') to retrieve the 'predictions_logger' instance previously configured by dictConfig in the YAML
# At runtime: If the logger was already created by dictConfig, this retrieves the existing instance; if not, a new logger is created but without handlers
pred_logger = logging.getLogger(name = 'predictions_logger')


# Calls logging.getLogger(name='training_logger') to retrieve the 'training_logger' instance previously configured by dictConfig in the YAML
# At runtime: If the logger was already created by dictConfig, this retrieves the existing instance with its pre-configured handlers and level
tr_logger = logging.getLogger(name = 'training_logger')


# Calls the .info() method on the training_logger, emitting an INFO-level LogRecord with structured metadata
# At runtime: LogRecord created with severity INFO (20), passes logger level check, forwarded to all attached handlers (file_handler, jsonl_handler per YAML)
# The extra={...} parameter adds arbitrary key-value pairs that structured formats (like JSON) can parse and include
tr_logger.info(
    # The primary action text indicating a prediction request came in
    "Prediction request received!",

    # Specifies the extra=... parameter to pass structured metadata that will be included in the LogRecord as custom attributes
    # At runtime: These key-value pairs are accessible via LogRecord.user_id and LogRecord.input_features; JSON handlers will include them in the JSON output
    extra = {
        # Records the integer ID of the user requesting the prediction
        "user_id": 1042,
         
        # Records the number of data features the user sent in their request payload
        "input_features": 47
    # Closes the 'extra' metadata dictionary.
    }
# Closes the tr_logger.info method call.
)


# Calls the .warning() method on the training_logger, emitting a WARNING-level LogRecord with additional structured metadata
# At runtime: LogRecord created with severity WARNING (30), passes trainer_logger level check (INFO <= WARNING: passes), forwarded to handlers
tr_logger.warning(
    # A generic mocked string serving as the core warning message
    "jesse is an MLOps Engineer",

    # Specifies the extra=... parameter to attach structured metadata at the WARNING level
    # At runtime: These key-value pairs are added to the LogRecord as custom attributes; JSON handlers serialize them
    extra = {
        # Logs a mock status key-value pair
        'status': 'cool',

        # Logs a mock age key-value pair
        "age": 20
    # Closes the 'extra' metadata dictionary.
    }
# Closes the tr_logger.warning method call.
)


# Calls the .warning() method on the predictions_logger, emitting a WARNING-level LogRecord
# At runtime: LogRecord created with severity WARNING (30), passes predictions_logger level check (DEBUG <= WARNING: passes), forwarded to handlers (terminal_handler, file_handler per YAML)
pred_logger.warning(
    # The warning text suggesting that the model might be memorizing data (overfitting) at a specific epoch
    "Validation loss increased. Possible overfitting at epoch 12."
# Closes the pred_logger.warning method call.
)

# Calls the .error() method on the predictions_logger, emitting an ERROR-level LogRecord
# At runtime: LogRecord created with severity ERROR (40), passes logger level check, forwarded to both terminal_handler and file_handler per YAML
# terminal_handler (level INFO) accepts ERROR; file_handler (level INFO) accepts ERROR; both output this critical event
pred_logger.error(
    # The error text stating that the hardware ran out of memory, terminating the job
    "Training job failed. OOM error on GPU."
# Closes the pred_logger.error method call.
)








