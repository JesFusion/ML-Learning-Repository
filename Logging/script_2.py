import logging
import os




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












