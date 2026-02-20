import logging
import sys

class LoggingPrint:
    def __init__(
        self,

        name = "app_logger", 

        log_file = None, 

        level = logging.DEBUG,

        formatter_fmt = '[{asctime}] [{name}] {levelname}: {message}',

        formatter_datefmt = '%Y/%m/%d, %I:%M %p',
        
        formatter_style = '{'
    ):
        
        self.logger = logging.getLogger(name)
        
        self.logger.setLevel(level)
        
        # Clear existing handlers to prevent duplicate logs if re-initialized
        if self.logger.hasHandlers():
            self.logger.handlers.clear()

        # 1. Setup Formatter (Modern Style)
        self.formatter = logging.Formatter(
            fmt = formatter_fmt,
            datefmt = formatter_datefmt,
            style = formatter_style
        )

        # 2. Handler: Terminal (Always included)
        self.console_handler = logging.StreamHandler(stream = sys.stdout)

        self.console_handler.setFormatter(self.formatter)

        self.logger.addHandler(self.console_handler)

        # 3. Handler: File (Optional)
        if log_file:
            self.file_handler = logging.FileHandler(log_file)
            self.file_handler.setFormatter(self.formatter)
            self.logger.addHandler(self.file_handler)

    def __call__(self, message, level=logging.INFO):
        """Allows the class instance to be called like a function."""
        self.logger.log(level, message)

    def add_custom_handler(self, handler, formatter=None):
        """Flexibility to add any custom handler (e.g., RotatingFile, Socket)."""
        if formatter:
            handler.setFormatter(formatter)
        else:
            handler.setFormatter(self.formatter)
        self.logger.addHandler(handler)

# --- Usage ---

# 1. Standard usage (Terminal only)
print = LoggingPrint(name="ML_Pipeline")
print("Loading dataset...") # Defaults to INFO

# 2. Multi-destination (Terminal + File)
# Note: We name it print_to_file to avoid conflicting with the first one 
# unless we specifically want to override it.
print = LoggingPrint(name="System", log_file="pipeline.log")
print("Starting training process...", level=logging.INFO)
print("Something looks off in the weights...", level=logging.WARNING)
print("CRITICAL: GPU OVERHEATING!", level=logging.CRITICAL)
