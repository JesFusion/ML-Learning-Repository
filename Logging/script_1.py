import os
import sys
import time
import uuid
import queue
import logging 
import subprocess
import logging.config
import logging.handlers
from contextvars import ContextVar
from pythonjsonlogger import jsonlogger
import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

log_dir = 'logs'

def clear():
    if True:
        subprocess.run('clear', shell = True)

clear()

os.makedirs(
    name = log_dir,
    exist_ok = True
)




batch_prediction = [

    {
        'requestID': 'RQ-291',
        'userID': 'USER-39',
        'experimentID': 'EXP-PHOENIX-V1.3.5',
        'the_model_version': 'v2.3',
        'inp_shape': (312, 200), # inp_shape = input shape
        'exp_shape': (312, 200), # exp_shape = expected shape
        'model_confidence': 0.89,
        'featureVECT': [0.341, 0.12, 0.732, 0.291]
    },

    {
        'requestID': 'RQ-607',
        'userID': 'USER-45',
        'experimentID': 'EXP-PHOENIX-V2.0.4',
        'the_model_version': 'v1.0',
        'inp_shape': (312, 419), # intentional shape mismatch
        'exp_shape': (312, 302),
        'model_confidence': 0.72,
        'featureVECT': [0.3, 0.7, 0.1, 0.5]
    },

    {
        'requestID': 'RQ-681',
        'userID': 'USER-72',
        'experimentID': 'EXP-PHOENIX-V3.5.4',
        'the_model_version': 'v4.3',
        'inp_shape': (312, 200),
        'exp_shape': (312, 200),
        'model_confidence': 0.22, # intentional low confidence threshold
        'featureVECT': [0.9, 0.1, 0.2, 0.8]
    },

    {
        'requestID': 'RQ-308',
        'userID': 'USER-25',
        'experimentID': 'EXP-PHOENIX-V7.0.9',
        'the_model_version': 'v1.8',
        'inp_shape': (312, 200),
        'exp_shape': (312, 200),
        'model_confidence': 0.42,
        'featureVECT': [0.5, 0.5, 0.5, 0.5]
    },

    {
        'requestID': 'RQ-197',
        'userID': 'USER-82',
        'experimentID': 'EXP-PHOENIX-V5.1.2',
        'the_model_version': 'v4.7',
        'inp_shape': (128, 200), # intentional shape mismatch
        'exp_shape': (391, 200),
        'model_confidence': 0.97,
        'featureVECT': [0.2, 0.8, 0.6, 0.3]
    },
]


the_confidence_threshold = 0.50




def shape_validator(
    InputShape,
    ExpectedShape
):
    
    if InputShape != ExpectedShape:

        raise ValueError(
            f"Shape mismatch: received {InputShape}, model expects {ExpectedShape}"
        )







# ===================================== SEGMENT 1.1: THE ANATOMY OF A RECORD =====================================


class HandlerThatInspectsRecords(logging.Handler):

    def emit(self, record):
        print("\n  ┌─ LogRecord.__dict__ Anatomy ─────────────────────────────────")

        for atrribute_name, atrribute_value in sorted(
            record.__dict__.items()
        ):
            print(f"  │  {atrribute_name:<15} = {atrribute_value}")
        
        print("  └───────────────────────────────────────────────────────────────")



logger_for_anatomy = logging.getLogger(
    name = 'AnatomyDemoLogger'
)

logger_for_anatomy.setLevel(
    level = logging.DEBUG # you can just set this to 10
    # CRITICAL = 50
    # ERROR = 40
    # WARNING = 30
    # INFO = 20
    # DEBUG = 10
    # NOTSET = 0
)

logger_for_anatomy.propagate = False

logger_for_anatomy.addHandler(
    hdlr = HandlerThatInspectsRecords()
)



print("\nfiring anatomy_logger.info() — Catch and expose the raw LogRecord:\n")

logger_for_anatomy.info(
    msg = 'Prediction batch has been received',
    extra = {
        'requestID': batch_prediction[0]['requestID']
    }
)

"""


  ┌─ LogRecord.__dict__ Anatomy ─────────────────────────────────
  │  args            = ()
  │  created         = 1777289216.8057432
  │  exc_info        = None
  │  exc_text        = None
  │  filename        = script_1.py
  │  funcName        = <module>
  │  levelname       = INFO
  │  levelno         = 20
  │  lineno          = 206
  │  module          = script_1
  │  msecs           = 805.0
  │  msg             = Prediction batch has been received
  │  name            = AnatomyDemoLogger
  │  pathname        = /ml/ML-Learning-Repository/Logging/script_1.py
  │  process         = 70268
  │  processName     = MainProcess
  │  relativeCreated = 344.1305160522461
  │  requestID       = RQ-291
  │  stack_info      = None
  │  taskName        = None
  │  thread          = 139447480217728
  │  threadName      = MainThread
  └───────────────────────────────────────────────────────────────

"""


log = logger_for_anatomy

log.handlers.clear()

five_log_levels = logging.StreamHandler(
    stream = sys.stdout
)

five_log_levels.setLevel(
    level = logging.DEBUG
)

five_log_levels.setFormatter(
    fmt = logging.Formatter(
        fmt = "\nLine %(lineno)s,\n%(levelname)s Level,\nOutput ::: %(message)s"
    )
)


log.addHandler(
    hdlr = five_log_levels
)



clear()

log.debug(
    msg = "Internal state: batch_size = 5, device = cpu, dtype = float32"
)

log.info(
    msg = "Training run started. Experiment: exp_phoenix_v3, Model: v3.1"
)

log.warning(
    msg = "Low confidence on req_003: 0.31 < threshold 0.50"
)



log.error(
    msg = "Shape mismatch on req_002: (128,512) vs expected (128,256)"
)

log.critical(
    msg = "Prediction server OOM. Shutting down all inference workers"
)


log.handlers.clear()

# clear()


#... ==============================================================================
#... SEGMENT 1.2: BASIC CONFIGURATION (basicConfig)
#... [Logging-1.2.A] logging.basicConfig()
#... [Logging-1.2.B] level= threshold
#... [Logging-1.2.C] filename= file output
#... [Logging-1.2.D] stream= target
#... [Logging-1.2.E] format= string
#... [Logging-1.2.F–I] Format directives: asctime, name, levelname, message
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 1.2: BASIC CONFIGURATION (basicConfig)")
# print("=" * 72)

#... [HOW]: Purge root logger handlers BEFORE calling basicConfig.
#...        basicConfig [Logging-1.2.A] is a no-op if ANY handler already exists
#...        on the root logger. This reset makes the call effective.
#... [WATCH OUT]: This is the #1 basicConfig gotcha in production. A library you
#...              imported (e.g. gunicorn, celery) may have already called
#...              basicConfig. Your subsequent call silently does NOTHING. This
#...              causes the "why aren't my logs appearing?" confusion that wastes
#...              hours. Always check logging.root.handlers before debugging.
# for existing_handler in logging.root.handlers[:]:
    # logging.root.removeHandler(hdlr=existing_handler)

#... [WHAT]: basicConfig() performs one-shot configuration of the root logger.
#... [WHY]:  Fastest path from zero to a working logger. Fine for scripts and
#...         quick debugging. NOT appropriate for production applications — use
#...         dictConfig (Segment 2.3) when you care about your career.
# logging.basicConfig(
    # level=logging.DEBUG,
    #... [HOW]: format= [Logging-1.2.E] is a percent-style template string.
    #...        %(asctime)s [1.2.F] = timestamp, %(name)s [1.2.G] = logger name,
    #...        %(levelname)s [1.2.H] = severity, %(message)s [1.2.I] = your text.
    # format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    # datefmt="%Y-%m-%d %H:%M:%S",
    #... [HOW]: filename= [Logging-1.2.C] redirects output from stderr to a file.
    # filename="logs/segment_1_2_basic.log",
    # filemode="w",   # 'w' overwrites; use 'a' in production to APPEND
# )

# print("\n  [basicConfig DEMO] Writing first 2 records to logs/segment_1_2_basic.log")
# print("  (Open the file after running to see the formatted output)\n")

# root_logger = logging.getLogger()
# root_logger.info(
    # msg=f"Batch processing started. Total records: {len(PREDICTION_BATCH)}"
# )
# root_logger.debug(
    # msg=(
        # f"First record metadata: id={PREDICTION_BATCH[0]['request_id']}, "
        # f"confidence={PREDICTION_BATCH[0]['confidence']}, "
        # f"shape={PREDICTION_BATCH[0]['input_shape']}"
    # )
# )

#... [HOW]: Demonstrate the LEVEL THRESHOLD GATE [Logging-1.2.B].
#...        Raising the level to WARNING causes every subsequent DEBUG and INFO
#...        call to be silently discarded BEFORE reaching any handler.
# root_logger.setLevel(level=logging.WARNING)
# root_logger.debug(
    # msg="[INVISIBLE] This DEBUG is silently killed by the WARNING threshold gate."
# )
# root_logger.info(
    # msg="[INVISIBLE] This INFO is also killed. The gate blocks both."
# )
# root_logger.warning(
    # msg="[VISIBLE]   This WARNING clears the gate and writes to the file."
# )
# print("  Level gate raised to WARNING. The DEBUG and INFO calls above were discarded.")
# print("  Open logs/segment_1_2_basic.log — the [INVISIBLE] lines are NOT there.\n")

#... [WHAT ELSE]: basicConfig also accepts: handlers= (a list of pre-built handler
#...              objects to attach directly), encoding= (file encoding, e.g.
#...              'utf-8'), and errors= (encoding error handling strategy). The
#...              older fileConfig() function loads logging config from a .ini file
#...              — avoid it for new projects in favor of dictConfig (Segment 2.3).

#... Reset for next segment
# root_logger.setLevel(level=logging.DEBUG)
# for existing_handler in logging.root.handlers[:]:
    # logging.root.removeHandler(hdlr=existing_handler)


#... ==============================================================================
#... SEGMENT 1.3: HANDLERS — THE DELIVERY SYSTEM
#... [Logging-1.3.A] logging.Handler base class
#... [Logging-1.3.B] StreamHandler
#... [Logging-1.3.C] FileHandler
#... [Logging-1.3.D] handler.setLevel()
#... [Logging-1.3.E] logger.addHandler()
#... [Logging-1.3.F] Publisher/Subscriber Pattern
#... ==============================================================================
# print("=" * 72)
# print("  SEGMENT 1.3: HANDLERS — The Publisher/Subscriber Delivery System")
# print("=" * 72)

#... [WHAT]: A named inference-pipeline logger with TWO handlers:
#...         - StreamHandler: Terminal output, ERROR and above only.
#...         - FileHandler:   Disk output, DEBUG and above (everything).
#... [WHY]:  This is the canonical "noisy file, quiet terminal" production pattern.
#...         Operators glance at the terminal and only see fires. Engineers audit
#...         the file and see the complete history. One logger, two subscribers.
#...         This is the Publisher/Subscriber pattern [Logging-1.3.F] in practice.
# inference_logger = logging.getLogger(name="inference_pipeline")
# inference_logger.setLevel(level=logging.DEBUG)  # Logger gate: wide open
# inference_logger.propagate = False              # Don't bubble up to root

#... --- SUBSCRIBER 1: StreamHandler [Logging-1.3.B] → Terminal (ERROR+) ---
#... [HOW]: handler.setLevel() [Logging-1.3.D] creates a SECOND independent gate
#...        below the logger's own gate. Logger gate passes DEBUG+. StreamHandler
#...        gate passes only ERROR+. The result: only errors reach the terminal.
# terminal_handler = logging.StreamHandler(stream=sys.stdout)
# terminal_handler.setLevel(level=logging.ERROR)
# terminal_handler.setFormatter(
    # fmt=logging.Formatter(fmt="  [TERMINAL | %(levelname)s] %(message)s")
# )

#... --- SUBSCRIBER 2: FileHandler [Logging-1.3.C] → Disk (DEBUG+, everything) ---
#... [HOW]: The FileHandler's level is DEBUG (lowest), so it accepts every record
#...        the logger itself passes. Nothing is filtered here — this is the
#...        "complete black box recording" for the hard drive.
# file_handler = logging.FileHandler(
    # filename="logs/segment_1_3_all_levels.log",
    # mode="w",
    # encoding="utf-8",
# )
# file_handler.setLevel(level=logging.DEBUG)
# file_handler.setFormatter(
    # fmt=logging.Formatter(
        # fmt="%(asctime)s | %(name)s | %(levelname)-8s | %(message)s",
        # datefmt="%H:%M:%S",
    # )
# )

#... [HOW]: addHandler() [Logging-1.3.E] subscribes the handler to the logger.
#...        After both calls, ONE logger.info() call fans out to both handlers.
# inference_logger.addHandler(hdlr=terminal_handler)
# inference_logger.addHandler(hdlr=file_handler)

# print("\n  [HANDLER DEMO] Dual-handler logger: StreamHandler (ERROR+) and FileHandler (DEBUG+)\n")

# for record in PREDICTION_BATCH:
    #... INFO goes to FILE ONLY (StreamHandler gate blocks it at the terminal)
    # inference_logger.info(
        # msg=f"Processing {record['request_id']} for {record['user_id']}"
    # )
    # if record["input_shape"] != record["expected_shape"]:
        #... ERROR goes to BOTH: terminal prints it, file records it
        # inference_logger.error(
            # msg=(
                # f"Shape mismatch — {record['request_id']}: "
                # f"received {record['input_shape']}, expected {record['expected_shape']}"
            # )
        # )
    # elif record["confidence"] < CONFIDENCE_THRESHOLD:
        #... WARNING goes to FILE ONLY (StreamHandler gate blocks it)
        # inference_logger.warning(
            # msg=(
                # f"Low confidence prediction — {record['request_id']}: "
                # f"{record['confidence']:.2f} < threshold {CONFIDENCE_THRESHOLD}"
            # )
        # )
    # else:
        #... INFO goes to FILE ONLY
        # inference_logger.info(
            # msg=f"  -> {record['request_id']} OK. confidence={record['confidence']:.2f}"
        # )

# print(
    # "\n  ERRORs appeared above (terminal handler fires for ERROR+)."
    # "\n  Open logs/segment_1_3_all_levels.log to see ALL levels including DEBUG and INFO."
# )

#... [WHAT ELSE]: Other standard Handler types include:
#...   - SMTPHandler: emails a record to a configured address (ideal for CRITICAL alerts)
#...   - SysLogHandler: ships to the OS /dev/log syslog (standard on Linux servers)
#...   - HTTPHandler: HTTP GETs or POSTs a record to a web endpoint
#...   - MemoryHandler: buffers records in RAM and flushes in bulk to another handler
#...   - NTEventLogHandler: writes to the Windows Event Log (Windows only)


#... ==============================================================================
#... SEGMENT 2.1: LOG ROTATION — DISK SPACE SAFETY
#... [Logging-2.1.A] RotatingFileHandler
#... [Logging-2.1.B] TimedRotatingFileHandler
#... [Logging-2.1.C] maxBytes=
#... [Logging-2.1.D] backupCount=
#... [Logging-2.1.E] when=
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 2.1: LOG ROTATION — Disk Space Safety")
# print("=" * 72)

#... [WHAT]: Configure two rotating handlers on a fresh named logger.
#...         One rotates on file size. One rotates on a time schedule.
#... [WHY]:  An unrotated log file in a high-throughput system WILL crash your
#...         server when the disk fills up. This is not theoretical — it has taken
#...         down production systems at real companies. The fix is 3 lines of code.

# rotation_logger = logging.getLogger(name="rotation_demo")
# rotation_logger.setLevel(level=logging.DEBUG)
# rotation_logger.propagate = False

#... --- SIZE-BASED ROTATION: RotatingFileHandler [Logging-2.1.A] ---
#... [HOW]: maxBytes [Logging-2.1.C] triggers rollover when file hits that size.
#...        backupCount [Logging-2.1.D] caps the number of archived .log.1, .log.2
#...        etc. files kept on disk. Total max disk usage = maxBytes * backupCount.
#... [WATCH OUT]: maxBytes=1024 is intentionally TINY here so you can SEE the
#...              rotation happen during this demo. In production use 10MB:
#...              maxBytes=10 * 1024 * 1024. Setting maxBytes=0 disables rotation
#...              entirely and lets the file grow forever — DON'T do this.
# size_rotating_handler = logging.handlers.RotatingFileHandler(
    # filename="logs/rotating_size.log",
    # mode="a",
    # maxBytes=1024,
    # backupCount=3,
    # encoding="utf-8",
# )
# size_rotating_handler.setFormatter(
    # fmt=logging.Formatter(fmt="%(asctime)s | %(levelname)s | %(message)s")
# )

#... --- TIME-BASED ROTATION: TimedRotatingFileHandler [Logging-2.1.B] ---
#... [HOW]: when= [Logging-2.1.E] sets the rollover schedule using string codes.
#...        'midnight' = roll at 00:00 each day. backupCount=7 = keep one week.
#...        The archived files get a date suffix: rotating_timed.log.2024-10-27
#... [WATCH OUT]: If your server is NOT in UTC (most Ubuntu cloud VMs ARE UTC),
#...              always pass utc=True. Otherwise, rotations happen at midnight
#...              LOCAL server time, which can be unpredictable across timezones.
# timed_rotating_handler = logging.handlers.TimedRotatingFileHandler(
    # filename="logs/rotating_timed.log",
    # when="midnight",
    # interval=1,
    # backupCount=7,
    # encoding="utf-8",
    # utc=True,
# )
# timed_rotating_handler.setFormatter(
    # fmt=logging.Formatter(fmt="%(asctime)s | %(levelname)s | %(message)s")
# )

# rotation_logger.addHandler(hdlr=size_rotating_handler)
# rotation_logger.addHandler(hdlr=timed_rotating_handler)

# print(
    # "\n  [ROTATION DEMO] Writing 20 lines to trigger size-based rotation "
    # "(maxBytes=1KB for demo visibility).\n"
# )
# for line_index in range(20):
    # rotation_logger.info(
        # msg=(
            # f"Rotation stress-test line {line_index + 1:02d} | "
            # f"experiment=exp_phoenix_v3 | batch={line_index} | "
            # f"record={PREDICTION_BATCH[line_index % 5]['request_id']}"
        # )
    # )

# print(
    # "  Check the logs/ directory. You should see rotating_size.log and rotating_size.log.1"
    # "\n  (rollover triggered at 1KB). rotating_timed.log rolls at midnight UTC automatically."
# )

#... [WHAT ELSE]: Both handlers support delay=True (don't open the file until the
#...              first emit — useful if you're not sure the log path will be
#...              written to). TimedRotatingFileHandler also supports atTime=
#...              (a datetime.time object) to set the exact rollover clock time
#...              instead of defaulting to midnight of the interval.


#... ==============================================================================
#... SEGMENT 2.2: STRUCTURED LOGGING — JSON FORMAT
#... [Logging-2.2.A] python-json-logger library
#... [Logging-2.2.B] JsonFormatter
#... [Logging-2.2.C] extra= parameter for additional fields
#... [Logging-2.2.D] O(1) JSON query vs O(n) regex
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 2.2: STRUCTURED LOGGING — JSON Format")
# print("=" * 72)

# if not JSON_LOGGER_AVAILABLE:
    # print(
        # "\n  [SKIPPED] python-json-logger not installed."
        # "\n  Run: pip install python-json-logger\n"
    # )
# else:
    #... [WHAT]: A logger that emits every record as a single-line JSON object
    #...         instead of a human-readable formatted string.
    #... [WHY]:  Log aggregation platforms (Datadog, Splunk, CloudWatch, Elasticsearch)
    #...         are machines. They parse JSON natively. A query for model_id="v3.1"
    #...         on an indexed JSON field is O(1) [Logging-2.2.D]. The same search
    #...         on a plain-text log file requires regex-scanning every line — O(n).
    #...         At 100 million log lines per day, this is the difference between
    #...         a 50ms query and a 45-minute one.
    # json_logger = logging.getLogger(name="json_inference")
    # json_logger.setLevel(level=logging.DEBUG)
    # json_logger.propagate = False

    #... [HOW]: JsonFormatter [Logging-2.2.B] is a drop-in replacement for the
    #...        standard Formatter. The fmt string here declares which standard
    #...        LogRecord fields appear as JSON keys. Any extra= fields are ALSO
    #...        automatically serialized as top-level JSON keys.
    # json_formatter = jsonlogger.JsonFormatter(
        # fmt="%(asctime)s %(name)s %(levelname)s %(message)s"
    # )

    # json_file_handler = logging.FileHandler(
        # filename="logs/segment_2_2_structured.jsonl",
        # mode="w",
        # encoding="utf-8",
    # )
    # json_file_handler.setFormatter(fmt=json_formatter)

    #... Also stream JSON to terminal so you can SEE the output live
    # json_terminal_handler = logging.StreamHandler(stream=sys.stdout)
    # json_terminal_handler.setFormatter(fmt=json_formatter)

    # json_logger.addHandler(hdlr=json_file_handler)
    # json_logger.addHandler(hdlr=json_terminal_handler)

    # print("\n  [JSON DEMO] Each log line is a parseable JSON object:\n")

    # for record in PREDICTION_BATCH:
        # if record["input_shape"] != record["expected_shape"]:
            #... [HOW]: extra= [Logging-2.2.C] merges arbitrary key-value pairs
            #...        directly into the LogRecord. JsonFormatter serializes them
            #...        as top-level JSON keys — making them queryable in Datadog.
            # json_logger.error(
                # msg="Shape mismatch detected",
                # extra={
                    # "request_id":    record["request_id"],
                    # "model_version": record["model_version"],
                    # "input_shape":   str(record["input_shape"]),
                    # "expected_shape":str(record["expected_shape"]),
                # },
            # )
        # elif record["confidence"] < CONFIDENCE_THRESHOLD:
            # json_logger.warning(
                # msg="Low confidence prediction",
                # extra={
                    # "request_id": record["request_id"],
                    # "confidence": record["confidence"],
                    # "model_id":   record["model_version"],
                # },
            # )
        # else:
            # json_logger.info(
                # msg="Prediction OK",
                # extra={
                    # "request_id": record["request_id"],
                    # "confidence": record["confidence"],
                # },
            # )

    #... [WATCH OUT]: extra= key names must NOT collide with built-in LogRecord
    #...              attribute names: 'name', 'msg', 'args', 'levelname',
    #...              'levelno', 'pathname', 'filename', 'module', 'exc_info',
    #...              'exc_text', 'stack_info', 'lineno', 'funcName', 'created',
    #...              'msecs', 'relativeCreated', 'thread', 'threadName',
    #...              'processName', 'process', 'message', 'asctime'.
    #...              Colliding keys silently corrupt your LogRecord at runtime.
    #...              Use domain-specific prefixes: "ml_model_id", "req_correlation_id".
    # print("\n  Open logs/segment_2_2_structured.jsonl to see the machine-readable output.")


#... ==============================================================================
#... SEGMENT 2.3: DICTCONFIG — SEPARATING CONFIGURATION FROM CODE
#... [Logging-2.3.A] logging.config.dictConfig()
#... [Logging-2.3.B] version key
#... [Logging-2.3.C] formatters key
#... [Logging-2.3.D] handlers key
#... [Logging-2.3.E] loggers key
#... [Logging-2.3.F] disable_existing_loggers key
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 2.3: dictConfig — Configuration as Code")
# print("=" * 72)

#... [WHAT]: A complete logging configuration defined as a Python dictionary.
#...         Passed to dictConfig() in one call to configure the entire logging
#...         system atomically: formatters, handlers, and named loggers.
#... [WHY]:  Django, FastAPI, Gunicorn, and every serious Python framework configure
#...         logging this way. The config lives in settings files or YAML — not
#...         hardcoded in business logic. Swap dev vs prod with one env variable.
#...         Zero code changes. This is the SysAdmin standard.
# LOGGING_CONFIG = {
    #... [HOW]: version [Logging-2.3.B] is mandatory. Always 1. It's a
    #...        forward-compatibility contract with the logging config schema.
    # "version": 1,

    #... [WATCH OUT]: disable_existing_loggers [Logging-2.3.F] defaults to True
    #...              in the stdlib. True silently KILLS all previously configured
    #...              loggers — including third-party library loggers (boto3,
    #...              sqlalchemy, httpx). ALWAYS set this to False unless you have
    #...              a very specific, documented reason. "Why did my boto3 logs
    #...              disappear after adding logging config?" — this is why.
    # "disable_existing_loggers": False,

    #... [HOW]: formatters [Logging-2.3.C] is a dict of named formatter configs.
    #...        Handlers reference them by name. This prevents you from repeating
    #...        the same format string in every handler definition.
    # "formatters": {
        # "standard": {
            # "format":  "%(asctime)s | %(name)s | %(levelname)-8s | %(message)s",
            # "datefmt": "%Y-%m-%d %H:%M:%S",
        # },
        # "minimal": {
            # "format": "  [%(levelname)s] %(message)s",
        # },
    # },

    #... [HOW]: handlers [Logging-2.3.D] is a dict of named handler configs.
    #...        Each entry specifies the class, level, formatter, and any handler-
    #...        specific keyword arguments (filename, maxBytes, etc.).
    # "handlers": {
        # "console": {
            # "class":     "logging.StreamHandler",
            # "level":     "WARNING",
            # "formatter": "minimal",
            # "stream":    "ext://sys.stdout",
        # },
        # "app_file": {
            # "class":      "logging.handlers.RotatingFileHandler",
            # "level":      "DEBUG",
            # "formatter":  "standard",
            # "filename":   "logs/segment_2_3_app.log",
            # "maxBytes":   5242880,  # 5MB
            # "backupCount": 3,
            # "encoding":   "utf-8",
        # },
    # },

    #... [HOW]: loggers [Logging-2.3.E] maps logger names to their config.
    #...        Configuring "app" here means ALL loggers whose names start with
    #...        "app." (app.inference, app.training, app.preprocessing) are
    #...        children of this logger and inherit its configuration.
    # "loggers": {
        # "app": {
            # "level":     "DEBUG",
            # "handlers":  ["console", "app_file"],
            # "propagate": False,
        # },
    # },
# }

# logging.config.dictConfig(config=LOGGING_CONFIG)

#... [HOW]: app.inference is a CHILD of "app". It has no handlers of its own
#...        but propagate=True (the default), so its records travel up to "app"
#...        and are handled there by both the console and file handlers.
# dictconfig_logger = logging.getLogger(name="app.inference")

# print("\n  [dictConfig DEMO] app.inference logger inherits config from 'app' parent.\n")

# for record in PREDICTION_BATCH[:3]:
    # dictconfig_logger.debug(
        # msg=f"dictConfig DEBUG: preprocessing {record['request_id']}"
    # )
    # dictconfig_logger.info(
        # msg=f"dictConfig INFO:  {record['request_id']} dispatched to model v3.1"
    # )
    # if record["input_shape"] != record["expected_shape"]:
        # dictconfig_logger.error(
            # msg=f"dictConfig ERROR: Shape mismatch on {record['request_id']}"
        # )
    # elif record["confidence"] < CONFIDENCE_THRESHOLD:
        # dictconfig_logger.warning(
            # msg=f"dictConfig WARN:  Low confidence on {record['request_id']}: "
                # f"{record['confidence']:.2f}"
        # )

# print(
    # "\n  WARNING+ visible above (console handler). "
    # "Full DEBUG trail in logs/segment_2_3_app.log."
# )

#... [WHAT ELSE]: In a real project, LOGGING_CONFIG is loaded from a YAML file:
#...              import yaml; dictConfig(yaml.safe_load(open("logging.yaml")))
#...              This lets ops teams edit log verbosity with a text editor, no
#...              Python knowledge required, no code deployment needed.
#...              The older fileConfig() reads from a .ini / ConfigParser file —
#...              it predates dictConfig and lacks support for arbitrary handler
#...              kwargs. Avoid it for all new projects.


#... ==============================================================================
#... SEGMENT 3.1: CONTEXTUAL LOGGING — "WHO DONE IT?"
#... [Logging-3.1.A] logging.LoggerAdapter
#... [Logging-3.1.B] LoggerAdapter.process()
#... [Logging-3.1.C] extra= dict (adapter context)
#... [Logging-3.1.D] Contextual Metadata Injection pattern
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 3.1: CONTEXTUAL LOGGING — Log Adapters & Metadata Injection")
# print("=" * 72)

#... [WHAT]: A LoggerAdapter subclass that automatically injects experiment-level
#...         metadata (experiment_id, model_version, epoch) into EVERY log call
#...         made through it, without the caller ever typing those fields.
#... [WHY]:  A training run generates 10,000 log lines. You need experiment_id
#...         on every single one to query them in Elasticsearch. Passing
#...         extra={"experiment_id": "exp_phoenix_v3"} manually on every
#...         logger.info() call is fragile, verbose, and someone always forgets
#...         it on the exact line that matters. The adapter automates this.
#...         Set it once at the start of the training run. Forget about it.
# class MLOpsAdapter(logging.LoggerAdapter):
    #... [WHAT]: process() [Logging-3.1.B] is the single override point.
    #...         It intercepts every log call, merges the adapter's context
    #...         dict into kwargs["extra"], and returns the enriched (msg, kwargs).
    #... [HOW]:  dict unpacking (**) lets caller-supplied extra fields coexist
    #...         with adapter context. If both have the same key, the CALLER wins
    #...         (right-side of unpack). This allows per-call overrides.
    # def process(self, msg, kwargs):
        # existing_extra  = kwargs.get("extra", {})
        # kwargs["extra"] = {**self.extra, **existing_extra}
        # return msg, kwargs

#... [HOW]: Wrap the existing "app.training" named logger in the adapter.
#...        The adapter is NOT a new logger — it's a proxy that enriches calls
#...        before forwarding them. The underlying "app.training" logger still
#...        handles propagation, level filtering, and handler routing normally.
# base_training_logger = logging.getLogger(name="app.training")

#... [HOW]: extra= [Logging-3.1.C] is the persistent context dict. Every log
#...        call through this adapter will carry these fields automatically.
#...        This is [Logging-3.1.D] Contextual Metadata Injection in practice.
# training_adapter = MLOpsAdapter(
    # logger=base_training_logger,
    # extra={
        # "experiment_id": "exp_phoenix_v3",
        # "model_version": "v3.1",
        # "epoch":          42,
    # },
# )

# print(
    # "\n  [ADAPTER DEMO] experiment_id, model_version, epoch injected on EVERY call."
    # "\n  The caller never types those fields. Check logs/segment_2_3_app.log:\n"
# )

# for record in PREDICTION_BATCH:
    #... [HOW]: The caller writes a simple info() call. The adapter silently
    #...        enriches it with experiment context before it hits the handlers.
    # training_adapter.info(
        # msg=f"Adapter: dispatched {record['request_id']} for {record['user_id']}"
    # )
    # if record["confidence"] < CONFIDENCE_THRESHOLD:
        #... [HOW]: Caller can add PER-CALL extra fields. These coexist with the
        #...        adapter context due to the dict merge in process().
        # training_adapter.warning(
            # msg=f"Adapter WARNING: low confidence on {record['request_id']}",
            # extra={"confidence_score": record["confidence"]},
        # )

#... [WATCH OUT]: The extra= keys injected by the adapter are stored in the
#...              LogRecord.__dict__ but only APPEAR in the output if your
#...              Formatter's format string explicitly includes %(experiment_id)s,
#...              %(model_version)s etc. Without those placeholders, the data is
#...              stored silently. In JSON logging (Segment 2.2), extra fields
#...              automatically appear as top-level JSON keys — no format change
#...              needed. This is one more reason JSON logging is the MLOps standard.


#... ==============================================================================
#... SEGMENT 3.2: EXCEPTION TRACING
#... [Logging-3.2.A] logger.exception()
#... [Logging-3.2.B] logger.error()
#... [Logging-3.2.C] exc_info= parameter
#... [Logging-3.2.D] Stack Trace Capture mechanism
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 3.2: EXCEPTION TRACING — logger.exception() vs logger.error()")
# print("=" * 72)

#... [WHAT]: Demonstrates the critical difference between logger.error() and
#...         logger.exception() when handling exceptions inside except blocks.
#... [WHY]:  Your model retraining job runs at 3AM via cron. A shape mismatch
#...         crashes the run. Without logger.exception(), your log says "Training
#...         failed." With it, your log contains the exact file, exact line,
#...         exact numpy operation, exact tensor shapes — before you've even
#...         opened your laptop. This is the difference between 10 minutes and
#...         3 hours of post-mortem debugging.

# exception_logger = logging.getLogger(name="app.exception_demo")
#... [HOW]: "app.exception_demo" is a child of "app", so it inherits the
#...        console (WARNING+) and rotating file (DEBUG+) handlers from dictConfig.

# print(
    # "\n  [EXCEPTION DEMO] Triggering intentional ShapeErrors from PREDICTION_BATCH."
    # "\n  Comparing logger.error() (no traceback) vs logger.exception() (full autopsy):\n"
# )

# for record in PREDICTION_BATCH:
    # try:
        # _validate_shape(
            # input_shape=record["input_shape"],
            # expected_shape=record["expected_shape"],
        # )
        # exception_logger.info(
            # msg=f"{record['request_id']}: Shape validation PASSED."
        # )
    # except ValueError as shape_error:
        #... [HOW]: logger.error() [Logging-3.2.B] logs the message text at ERROR
        #...        severity but DROPS the stack trace entirely. Use this ONLY when
        #...        the error context is already fully captured elsewhere, or when
        #...        a clean summary message is all you need.
        # exception_logger.error(
            # msg=(
                # f"[error() — no traceback] {record['request_id']} "
                # f"failed: {shape_error}"
            # )
        # )

        #... [HOW]: logger.exception() [Logging-3.2.A] is functionally identical
        #...        to logger.error(exc_info=True) [Logging-3.2.C]. It internally
        #...        calls sys.exc_info() [Logging-3.2.D] to capture the active
        #...        exception's type, value, and traceback object, then serializes
        #...        the full call stack into the LogRecord.
        #... [WATCH OUT]: ONLY call logger.exception() from INSIDE an active except
        #...              block. Calling it outside one logs "NoneType: None" as
        #...              the traceback, which is useless noise and actively
        #...              misleading during a 3AM incident response.
        # exception_logger.exception(
            # msg=(
                # f"[exception() — full autopsy] {record['request_id']} "
                # f"traceback captured:"
            # )
        # )

# print(
    # "\n  Open logs/segment_2_3_app.log and search for 'full autopsy'."
    # "\n  You will see the complete Python traceback embedded in the log record."
# )

#... [WHAT ELSE]: exc_info=True [Logging-3.2.C] can be passed to any severity
#...              level — logger.warning(..., exc_info=True) captures a traceback
#...              at WARNING severity, not just ERROR. Useful when an exception is
#...              "expected but worth noting."
#...              stack_info=True is a DIFFERENT parameter that logs the CURRENT
#...              call stack even when there is NO active exception — useful for
#...              tracing logic flow through complex code without intentionally
#...              crashing. These two parameters are independent and can be
#...              combined.


#... ==============================================================================
#... SEGMENT 3.3: MODULE-LEVEL LOGGERS (__name__)
#... [Logging-3.3.A] logging.getLogger(__name__)
#... [Logging-3.3.B] __name__ magic variable
#... [Logging-3.3.C] Logger Hierarchy / Propagation
#... [Logging-3.3.D] logger.propagate attribute
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 3.3: MODULE-LEVEL LOGGERS — Hierarchical Logging with __name__")
# print("=" * 72)

#... [WHAT]: Simulates the __name__-based logger pattern [Logging-3.3.A] as it
#...         would appear in a real multi-file MLOps project. In production,
#...         every Python file would start with:
#...             logger = logging.getLogger(__name__)
#...         where __name__ evaluates to that file's fully qualified module path.
#... [WHY]:  When an error fires in a running system with 30 Python files, "ERROR"
#...         tells you nothing. "app.pipeline.preprocessing — ERROR" tells you
#...         exactly which file to open. This is the pattern that makes logging
#...         useful in a multi-module codebase.

#... [HOW]: __name__ [Logging-3.3.B] in preprocessing.py would evaluate to
#...        "app.pipeline.preprocessing". We replicate that name manually here
#...        since everything lives in one script.
# preprocessing_logger  = logging.getLogger(name="app.pipeline.preprocessing")
# inference_mod_logger  = logging.getLogger(name="app.models.inference")

#... [HOW]: propagate=True [Logging-3.3.D] is the DEFAULT for all loggers.
#...        Making it explicit here is a teaching choice, not a necessary one.
#...        With propagate=True, records travel UP the logger tree [Logging-3.3.C]
#...        toward the root until a logger with handlers is found.
# preprocessing_logger.propagate = True
# inference_mod_logger.propagate = True

# print("\n  [HIERARCHY] Logger propagation tree:\n")
# print("    root")
# print("    └── app                                 ← handlers: console + rotating file")
# print("        ├── app.pipeline")
# print("        │   └── app.pipeline.preprocessing  ← NO handlers, propagates UP to 'app'")
# print("        └── app.models")
# print("            └── app.models.inference         ← NO handlers, propagates UP to 'app'\n")

# for record in PREDICTION_BATCH[:3]:
    #... Simulates preprocessing.py firing a log
    # preprocessing_logger.info(
        # msg=f"[preprocessing.py] Normalizing features for {record['request_id']}"
    # )
    # preprocessing_logger.debug(
        # msg=f"[preprocessing.py] Feature vector: {record['feature_vector']}"
    # )
    #... Simulates inference.py firing a log
    # if record["input_shape"] != record["expected_shape"]:
        # inference_mod_logger.error(
            # msg=(
                # f"[inference.py] FORWARD PASS FAILED on {record['request_id']}: "
                # f"shape error {record['input_shape']} != {record['expected_shape']}"
            # )
        # )
    # else:
        # inference_mod_logger.info(
            # msg=(
                # f"[inference.py] Prediction complete — {record['request_id']}, "
                # f"conf={record['confidence']:.2f}"
            # )
        # )

# print(
    # "  WARNING+ in terminal. Open logs/segment_2_3_app.log and observe the %(name)s"
    # "\n  column — you can see EXACTLY which 'module' each record came from."
# )

#... [WATCH OUT]: If you configure BOTH a child logger AND its parent with handlers,
#...              and the child has propagate=True (the default), every log record
#...              fires TWICE: once through the child's handler, once through the
#...              parent's handler. This is the "duplicate log entries" bug that
#...              confuses everyone eventually. Fix: set propagate=False on any
#...              logger that has its own handlers attached.


#... ==============================================================================
#... SEGMENT 4.1: ASYNCHRONOUS LOGGING — NON-BLOCKING I/O
#... [Logging-4.1.A] queue.Queue
#... [Logging-4.1.B] QueueHandler
#... [Logging-4.1.C] QueueListener
#... [Logging-4.1.D] QueueListener.start()
#... [Logging-4.1.E] QueueListener.stop()
#... [Logging-4.1.F] Producer-Consumer Pattern
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 4.1: ASYNC LOGGING — QueueHandler & QueueListener")
# print("=" * 72)

#... [WHAT]: Configures a non-blocking logging pipeline using the
#...         QueueHandler / QueueListener pair.
#... [WHY]:  Disk I/O is orders of magnitude slower than RAM operations. In a
#...         synchronous logging setup, every logger.info() call in a FastAPI
#...         request handler BLOCKS the request thread until the disk write
#...         completes. At 10,000 req/s this adds measurable latency to every
#...         single user response. The QueueHandler pattern eliminates this:
#...         the main thread's cost is a single O(1) in-memory queue.put().
#...         The slow disk I/O happens in a background daemon thread.

#... --- Step 1: The Real I/O Handler (slow, lives in the background thread) ---
# async_file_handler = logging.handlers.RotatingFileHandler(
    # filename="logs/segment_4_1_async.log",
    # mode="w",
    # maxBytes=5242880,
    # backupCount=3,
    # encoding="utf-8",
# )
# async_file_handler.setFormatter(
    # fmt=logging.Formatter(
        # fmt="%(asctime)s | %(name)s | %(levelname)-8s | %(message)s"
    # )
# )

#... --- Step 2: The Queue — the thread-safe RAM buffer [Logging-4.1.A] ---
#... [HOW]: maxsize=-1 (or 0) means the queue has unlimited capacity.
#...        In production, you may set a maxsize to apply backpressure — if
#...        the queue fills up, queue.put() blocks until space frees. This
#...        trades non-blocking behavior for backpressure resistance.
#... [WATCH OUT]: An unbounded queue under extreme load CAN exhaust RAM if the
#...              background consumer can't keep up with the producer. Monitor
#...              your queue depth in production with queue.qsize().
# log_queue = queue.Queue(maxsize=-1)

#... --- Step 3: QueueHandler — the fast in-process relay [Logging-4.1.B] ---
#... [HOW]: Attaching this to the logger replaces all slow I/O handlers.
#...        The logger's emit() now does: LogRecord -> queue.put() -> DONE.
#...        O(1). Nanoseconds. The main thread is instantly free.
# queue_handler = logging.handlers.QueueHandler(queue=log_queue)

#... --- Step 4: QueueListener — the background consumer thread [Logging-4.1.C] ---
#... [HOW]: QueueListener wraps the REAL handlers (async_file_handler) and runs
#...        them in a background daemon thread. It dequeues LogRecords and
#...        forwards them to each real handler at whatever pace disk I/O allows.
#...        This is the Producer-Consumer Pattern [Logging-4.1.F].
#... [WATCH OUT]: respect_handler_level=True makes the QueueListener honor each
#...              real handler's own level filter. Set to False and it ignores
#...              handler-level filters (it still respects the logger's level).
# queue_listener = logging.handlers.QueueListener(
    # log_queue,
    # async_file_handler,
    # respect_handler_level=True,
# )

# async_logger = logging.getLogger(name="async_inference")
# async_logger.setLevel(level=logging.DEBUG)
# async_logger.propagate = False
# async_logger.addHandler(hdlr=queue_handler)

#... --- Step 5: Start the background thread [Logging-4.1.D] ---
# queue_listener.start()

# print(
    # "\n  [ASYNC DEMO] Main thread dispatches all 5 records. Background thread handles I/O.\n"
# )

# dispatch_start = time.perf_counter()
# for record in PREDICTION_BATCH:
    #... [HOW]: This call takes nanoseconds — it puts the LogRecord on the queue
    #...        and returns immediately. The main thread never touches disk.
    # async_logger.info(
        # msg=f"Async: dispatched {record['request_id']} to background I/O thread"
    # )
    # if record["input_shape"] != record["expected_shape"]:
        # async_logger.error(
            # msg=(
                # f"Async ERROR: Shape mismatch on {record['request_id']}: "
                # f"{record['input_shape']} vs {record['expected_shape']}"
            # )
        # )
    # elif record["confidence"] < CONFIDENCE_THRESHOLD:
        # async_logger.warning(
            # msg=f"Async WARNING: Low confidence on {record['request_id']}: "
                # f"{record['confidence']:.2f}"
        # )
# dispatch_elapsed = time.perf_counter() - dispatch_start

# print(
    # f"  5 records dispatched to queue in {dispatch_elapsed * 1000:.4f}ms "
    # "(near-zero main thread cost)."
# )

#... --- Step 6: Stop the listener cleanly [Logging-4.1.E] ---
#... [HOW]: stop() signals the background thread to drain every remaining record
#...        from the queue before terminating. No records are lost.
#... [WATCH OUT]: Forgetting to call stop() on application shutdown is a SILENT
#...              log-loss bug. The last N records in the queue at shutdown time
#...              are discarded with zero error messages. Register stop() with
#...              atexit.register() or FastAPI's @app.on_event("shutdown") hook.
# queue_listener.stop()
# print(
    # "  QueueListener stopped cleanly. All queued records flushed to disk."
    # "\n  Check logs/segment_4_1_async.log\n"
# )

#... [WHAT ELSE]: For Python 3.12+, QueueListener gained support for
#...              queue_class= parameter, allowing you to swap queue.Queue for
#...              queue.SimpleQueue (faster, no qsize(), no join()) in simple
#...              scenarios. asyncio.Queue is NOT compatible with QueueListener
#...              — for a fully async pipeline (asyncio-native), you need a
#...              custom handler that uses asyncio event loop integration.


#... ==============================================================================
#... SEGMENT 4.2: CORRELATION IDs — DISTRIBUTED TRACING
#... [Logging-4.2.A] uuid.uuid4()
#... [Logging-4.2.B] uuid module
#... [Logging-4.2.C] contextvars.ContextVar
#... [Logging-4.2.D] Correlation ID Injection Pattern
#... ==============================================================================
# print("=" * 72)
# print("  SEGMENT 4.2: CORRELATION IDs — Distributed Request Tracing")
# print("=" * 72)

#... [WHAT]: Generates a UUID [Logging-4.2.A] per simulated request and injects
#...         it into every log line for that request via a ContextVar-backed adapter.
#... [WHY]:  A single user request touches: API Gateway → Feature Service →
#...         Model Inference → Prediction DB → Monitoring. Logs are scattered
#...         across 5 processes. The Correlation ID is the one search term that
#...         reconstructs the full timeline across all of them. This is the
#...         lightweight, DIY version of tools like Jaeger and AWS X-Ray.

#... [HOW]: ContextVar [Logging-4.2.C] provides a per-execution-context slot.
#...        Unlike a global variable (which is shared across ALL concurrent
#...        requests and causes race conditions), each request's async context
#...        has its own isolated ContextVar slot.
#... [WATCH OUT]: threading.local() is thread-safe but NOT async-safe. In a
#...              FastAPI / asyncio application, two concurrent requests running
#...              on the same thread would share the same threading.local() slot
#...              and corrupt each other's correlation_id. Always use ContextVar
#...              in async contexts. Period.
# correlation_id_var: ContextVar[str] = ContextVar(
    # "correlation_id",
    # default="no-correlation-id",
# )


#... [WHAT]: A LoggerAdapter that automatically reads the current ContextVar
#...         value and injects it as correlation_id into every log record.
#... [WHY]:  The [Logging-4.2.D] Correlation ID Injection Pattern means that
#...         request-handling code NEVER manually passes the correlation_id.
#...         The middleware sets the ContextVar once. The adapter reads it
#...         automatically on every log call downstream.
# class CorrelationAdapter(logging.LoggerAdapter):
    # def process(self, msg, kwargs):
        # existing_extra  = kwargs.get("extra", {})
        # kwargs["extra"] = {
            # **existing_extra,
            # "correlation_id": correlation_id_var.get(),
        # }
        # return msg, kwargs


# corr_base_logger = logging.getLogger(name="distributed.inference")
# corr_base_logger.setLevel(level=logging.DEBUG)
# corr_base_logger.propagate = False

#... [HOW]: The formatter MUST include %(correlation_id)s for it to appear in
#...        text output. In JSON logging (Segment 2.2), it appears automatically.
# corr_stream_handler = logging.StreamHandler(stream=sys.stdout)
# corr_stream_handler.setLevel(level=logging.DEBUG)
# corr_stream_handler.setFormatter(
    # fmt=logging.Formatter(
        # fmt="  %(asctime)s | corr=%(correlation_id)s | %(levelname)-8s | %(message)s",
        # datefmt="%H:%M:%S",
    # )
# )
# corr_base_logger.addHandler(hdlr=corr_stream_handler)

# corr_logger = CorrelationAdapter(logger=corr_base_logger, extra={})

# print(
    # "\n  [CORRELATION ID DEMO] Each simulated request gets a unique UUID passport."
    # "\n  Every log line for that request carries the same UUID:\n"
# )

# for record in PREDICTION_BATCH:
    #... [HOW]: This simulates the API Gateway entry-point middleware.
    #...        In a real FastAPI app: correlation_id_var.set(str(uuid.uuid4()))
    #...        runs in an @app.middleware("http") function before routing.
    # request_uuid = str(uuid.uuid4())
    # ctx_token    = correlation_id_var.set(request_uuid)  # Bind UUID to this context

    # corr_logger.info(
        # msg=f"REQUEST IN  | {record['request_id']} from {record['user_id']}"
    # )
    # if record["input_shape"] != record["expected_shape"]:
        # corr_logger.error(
            # msg=(
                # f"SHAPE FAIL  | {record['request_id']}: "
                # f"{record['input_shape']} != {record['expected_shape']}"
            # )
        # )
    # else:
        # corr_logger.info(
            # msg=(
                # f"PREDICTION  | {record['request_id']}: "
                # f"conf={record['confidence']:.2f}"
            # )
        # )
    # corr_logger.info(
        # msg=f"REQUEST OUT | {record['request_id']} complete"
    # )

    #... [HOW]: Reset the ContextVar after the request finishes. In FastAPI,
    #...        the ASGI request scope handles this automatically when the
    #...        request context exits. Manual reset here for cleanliness.
    # correlation_id_var.reset(ctx_token)

# print(
    # "\n  Search any log aggregator for one UUID above → get the complete"
    # "\n  REQUEST IN → SHAPE FAIL / PREDICTION → REQUEST OUT timeline for that request."
# )


#... ==============================================================================
#... SEGMENT 4.3: EXTERNAL AGGREGATION — SENTRY & ELK SIMULATION
#... [Logging-4.3.A] sentry_sdk.init()
#... [Logging-4.3.B] DSN (Data Source Name)
#... [Logging-4.3.C] sentry_sdk logging integration
#... [Logging-4.3.D] before_send hook
#... [Logging-4.3.E] ELK Stack (conceptual)
#... [Logging-4.3.F] Mock Centralized Handler
#... ==============================================================================
# print("\n" + "=" * 72)
# print("  SEGMENT 4.3: EXTERNAL AGGREGATION — Sentry & ELK Mock")
# print("=" * 72)

#... ─────────────────────────────────────────────────────────────────────────────
#... PART A: MOCK CENTRALIZED HANDLER — ELK SIMULATION [Logging-4.3.E/F]
#... ─────────────────────────────────────────────────────────────────────────────

#... [WHAT]: A custom Handler subclass that simulates shipping a log record to
#...         a centralized aggregation platform (e.g. Elasticsearch in an ELK stack
#...         [Logging-4.3.E]: Elasticsearch + Logstash + Kibana).
#... [WHY]:  In production, logs from 50 microservices on 50 servers can't live
#...         in 50 different files. A centralized store makes your entire fleet
#...         searchable from one Kibana dashboard. This mock [Logging-4.3.F]
#...         validates your payload structure locally — no cloud account, no
#...         network, no infrastructure — before you connect the real thing.
# class MockCentralizedHandler(logging.Handler):
    # DESTINATION = "elasticsearch:9200/index/ml-logs"

    #... [HOW]: emit() receives the LogRecord. We call self.format() to render it,
    #...        then build a simulated HTTP POST payload. In production, replace
    #...        the print() with: requests.post(url=ES_ENDPOINT, json=payload)
    # def emit(self, record):
        # rendered_log = self.format(record=record)
        # simulated_payload = {
            # "destination":   self.DESTINATION,
            # "log_level":     record.levelname,
            # "logger_name":   record.name,
            # "timestamp":     record.created,
            # "message_body":  rendered_log,
        # }
        # print(
            # f"  [MOCK → ELK] dest={simulated_payload['destination']} | "
            # f"level={simulated_payload['log_level']} | "
            # f"msg={record.getMessage()}"
        # )

# mock_elk_logger = logging.getLogger(name="elk_simulation")
# mock_elk_logger.setLevel(level=logging.WARNING)
# mock_elk_logger.propagate = False

# mock_handler = MockCentralizedHandler()
# mock_handler.setFormatter(
    # fmt=logging.Formatter(
        # fmt="%(asctime)s %(levelname)s %(name)s %(message)s"
    # )
# )
# mock_elk_logger.addHandler(hdlr=mock_handler)

# print("\n  [ELK MOCK] Simulating log shipping to Elasticsearch (WARNING+ events):\n")

# for record in PREDICTION_BATCH:
    # if record["input_shape"] != record["expected_shape"]:
        # mock_elk_logger.error(
            # msg=(
                # f"Shape mismatch | request={record['request_id']} | "
                # f"got={record['input_shape']} | expected={record['expected_shape']}"
            # )
        # )
    # elif record["confidence"] < CONFIDENCE_THRESHOLD:
        # mock_elk_logger.warning(
            # msg=(
                # f"Low confidence | request={record['request_id']} | "
                # f"conf={record['confidence']:.2f} | threshold={CONFIDENCE_THRESHOLD}"
            # )
        # )

#... ─────────────────────────────────────────────────────────────────────────────
#... PART B: SENTRY SDK — REAL-TIME ERROR ALERTING [Logging-4.3.A–D]
#... ─────────────────────────────────────────────────────────────────────────────
# print()
# if not SENTRY_AVAILABLE:
    # print(
        # "  [SENTRY SKIPPED] sentry-sdk not installed. Run: pip install sentry-sdk"
        # "\n"
        # "\n  Once installed and your DSN is configured, sentry_sdk.init() registers"
        # "\n  a global exception hook. Every unhandled exception in your Python app"
        # "\n  is automatically captured with its full traceback and shipped to the"
        # "\n  Sentry platform, which sends a push notification to your phone."
        # "\n  Zero log-parsing. Zero dashboards. You get paged directly."
    # )
# else:
    #... [WHAT]: sentry_sdk.init() [Logging-4.3.A] bootstraps the Sentry client.
    #...         It registers global exception hooks so every unhandled exception
    #...         is automatically captured without any explicit try/except.
    #... [WHY]:  Sentry is the highest immediate ROI observability tool for early
    #...         MLOps. The moment your model server throws an unhandled exception
    #...         at 3AM, Sentry sends you a push notification with the full
    #...         traceback, the user context, the environment tag, the release
    #...         commit hash, and how many other users hit the same error.
    #... [WATCH OUT]: The DSN [Logging-4.3.B] is a secret. Replace the placeholder
    #...              below with your DSN from: sentry.io → Project → Settings →
    #...              Client Keys. NEVER commit a real DSN to a public GitHub repo.
    #...              Store it in an environment variable: os.environ["SENTRY_DSN"]
    # sentry_sdk.init(
        # dsn="YOUR_SENTRY_DSN_HERE",   # <- Replace with real DSN from sentry.io
        #... [HOW]: LoggingIntegration [Logging-4.3.C] hooks Sentry into Python's
        #...        logging system. INFO+ become breadcrumbs (context trail).
        #...        ERROR+ become full Sentry Issues that trigger alerts.
        # integrations=[
            # LoggingIntegration(
                # level=logging.INFO,         # Capture INFO+ as breadcrumbs
                # event_level=logging.ERROR,  # Capture ERROR+ as Sentry Issues
            # )
        # ],
        # traces_sample_rate=1.0,
        #... [HOW]: before_send [Logging-4.3.D] is a callback that intercepts every
        #...        error event before transmission. Use it to scrub PII (user emails,
        #...        IP addresses, API keys from tracebacks) or enrich events with
        #...        extra deployment context. Return None to DROP the event entirely.
        # before_send=lambda event, hint: event,  # Pass-through; add PII scrubbing here
        # environment="development",
        # release="exp_phoenix_v3@3.1.0",
    # )

    # sentry_logger = logging.getLogger(name="sentry_demo")
    # sentry_logger.setLevel(level=logging.DEBUG)

    # print(
        # "  [SENTRY DEMO] Triggering a shape mismatch. In production, Sentry"
        # "\n  would alert your phone within seconds.\n"
    # )
    # try:
        # _validate_shape(
            # input_shape=PREDICTION_BATCH[1]["input_shape"],
            # expected_shape=PREDICTION_BATCH[1]["expected_shape"],
        # )
    # except ValueError:
        #... [HOW]: With Sentry initialized and LoggingIntegration active,
        #...        logger.exception() ships the full traceback BOTH to your
        #...        log file AND to the Sentry dashboard simultaneously.
        # sentry_logger.exception(
            # msg="[SENTRY] Shape validation failed during batch inference."
        # )
        # print("  In a live deployment: Sentry would now alert you on your phone.")

    #... [WHAT ELSE]: sentry_sdk.capture_exception(e) manually ships a caught
    #...              exception. sentry_sdk.capture_message("msg", level="warning")
    #...              manually ships a text event. The release= and environment=
    #...              parameters in init() tag every event with the git commit and
    #...              deployment stage, so you know which version of the code broke.
    #...              Sentry also has first-class integrations for FastAPI, Django,
    #...              Celery, SQLAlchemy, and Redis — all auto-instrument with zero
    #...              extra code beyond sentry_sdk.init().


#... ==============================================================================
# print("\n" + "=" * 72)
# print("  ALL 12 SEGMENTS COMPLETE.")
# print("=" * 72)
# print()
# print("  FILES WRITTEN TO logs/ :")
# print("    segment_1_2_basic.log           <- basicConfig output     (Seg 1.2)")
# print("    segment_1_3_all_levels.log      <- Dual-handler output    (Seg 1.3)")
# print("    rotating_size.log[.1 .2 .3]     <- Size-rotated files     (Seg 2.1)")
# print("    rotating_timed.log              <- Time-rotated file      (Seg 2.1)")
# print("    segment_2_2_structured.jsonl    <- JSON structured logs   (Seg 2.2)")
# print("    segment_2_3_app.log             <- dictConfig output      (Seg 2.3+)")
# print("    segment_4_1_async.log           <- QueueHandler output    (Seg 4.1)")
# print()
# print("  INSTALL CHECK (if any segment was skipped):")
# print("    pip install python-json-logger sentry-sdk")
# print()
# print("  When the script runs clean, head to The Crucible.")
# print("=" * 72)