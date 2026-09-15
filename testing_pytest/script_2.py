import time
import pytest
import logging
import numpy as np
import os
import pandas as pd
from sqlalchemy import create_engine
np.random.seed(10)





def test_learning(): # for a function to be tested, it must start with 'test_'
    """
    This is a valid test function because it starts with 'test_'.
    Pytest will find this and run it.
    """
    
    status = "active"

    assert status == "active"


def see_if_ignore():

    """
    WARNING: This will NOT run!
    This is a common junior mistake. You write the code, but forget the naming convention.
    """

    the_status = 'not-available'

    assert the_status == 'available' # this function would have failed if it ran, but it won't run



class TestCheckCoolness: # tests can be grouped in to classes.
    # They must start with "Test" (take note of the capital 'T')
    # The class must not have an __init__ method

    def test_for_coolness(self):

        """
        This method is valid because class starts with 'Test' and method starts with 'test_'
        """

        current_status = "cool"

        assert current_status == "cool"




class UntestedClass:

    """
    This class is IGNORED because it doesn't start with 'Test'.
    """

    def test_bad_class(): # This test method won't run even though it started with 'test_'

        assert True




































































































class TestSegment2_2:

    # using assert to test equality
    def test_equality(self):

        prev_status = "cool"

        current_status = 'cool'

        assert prev_status == current_status


    # using assert to test strings/lists
    def test_string_existence(self):

        # Checking if a specific log message exists in a log stream...

        log = "Error: Model failed to converge in 100 epochs"

        keyword = 'converge in 100'

        assert keyword in log # "in" checks if a substring exists

    
    # using assert to test booleans
    def test_boolean_values(self):

        is_cool = True # validation

        assert is_cool # this implicitly checks "is True"

    


def test_if_member():

    rand_gen = np.random.default_rng(seed=42)

    array = rand_gen.random(10000).round(2)


    the_list = array.tolist()

    the_set = set(the_list)

    value = 8881.2219

    t_1 = time.time()

    assert value not in the_list

    t_2 = time.time()

    assert value not in the_set

    t_3 = time.time()

    list_time = t_2 - t_1
    set_time = t_3 - t_2

    print(f'''
List Time: {list_time}

Set Time: {set_time}

Is set time less than list time: {set_time < list_time}
    ''')

test_if_member()




# ===================================== INTROSPECTION =====================================

# Pytest performs Introspection.
# It rewrites your code on the fly before running it

def test_intrsopection_on_lists():

    list_a = [1, True, "Jesse"]

    list_b = list_a.copy()

    list_b[2] = "is cool"

    assert list_a == list_b




































































































# ===================================== MAIN CODE =====================================



type_err_message = "Input shape must be a Tuple."

def image_shape_validation(tuple_shape: tuple):

    """
    Ensures image is 3-dimensional (Height, Width, Channels).
    Raises ValueError if dimensions are wrong.
    """

    if not isinstance(tuple_shape, tuple): # enforcing type strictness

        raise TypeError(type_err_message)
    
    if len(tuple_shape) != 3: # enforcing dimension strictness

        raise ValueError(f"Expected 3 dimensions, got {len(tuple_shape)} dimensions.")

    return True




# ===================================== TEST CODE =====================================




def test_image_shape_validation_bad_shape():

    # testing with right type but wrong shape
    err_shape = (21, 23)

    with pytest.raises(ValueError): # the following is meant to fail and return a ValueError. If it doesn't, FAIL THE TEST!

        image_shape_validation(tuple_shape = err_shape)



def test_image_shape_validation_bad_type():
    
    # testing with right shape but wrong type
    err_type = [12, 12, 12]

    with pytest.raises(TypeError):

        image_shape_validation(tuple_shape = err_type)



def test_image_shape_validation_check_shape_error_message():

    err_shape = (2, 1, 2, 2)


    with pytest.raises(
        expected_exception = ValueError,
        
        # We are checking if the string "Expected 3 dimensions" appears in the error.
        match = rf"Expected 3 dimensions, got {len(err_shape)} dimensions." # match=r"..." takes a Regular Expression (Regex).
    ):
        
        image_shape_validation(tuple_shape = err_shape)



def test_image_shape_validation_check_type_error_message():

    err_type = [1, 2, 3]

    with pytest.raises(
        expected_exception = TypeError, # checking for TypeError, not ValueError

        match = rf"{type_err_message}"
    ):
        
        image_shape_validation(tuple_shape = err_type)










































































































# INTRO TO FIXTURES

# ===================================== OLD METHOD =====================================


def test_validation_old_method():

    """
    We're manually creating a dictionary for every single test
    
    While it's easy to pull out the dictionary from a function and let all functions use it, the point is that there are sometimes that we're forced to create the same thing over and over again in all our test functions, but pytest has a solution to this
    """

    dataset = {

    "id": 1,
    
    "username": "jesse_billionaire",
    
    "role": "admin"
    }


    assert dataset['role'] == 'admin'




def test_id_old_method():

    """
    We're duplicating the dataset dictionary again!


    If we change the structure of dataset later, we have to fix it in 50 places.
    """

    dataset = {

    "id": 1,
    
    "username": "jesse_billionaire",
    
    "role": "admin"
    }


    assert dataset['id'] > 0.3





# ===================================== NEW METHOD (PYTEST SOLUTION) =====================================


@pytest.fixture
def a_single_user(): # this is a FIXTURE function
    # It acts as a 'factory' that delivers data to any test that asks for it.
    
    """
    Returns:
        dict: A standard user dictionary.
    """

    # we'll define the data in one place, and use it in other functions

    the_data = {

    "id": 1,
    
    "username": "jesse_billionaire",
    
    "role": "admin"
    }

    return the_data



def test_validation_new_method(a_single_user): # We pass 'a_single_user' as an argument    
    # Pytest sees the argument name, finds the fixture with the matching name, runs it, and injects the return value into 'a_single_user' as a variable

    assert a_single_user['role'] == 'admin'



def test_id_new_method(a_single_user): # we're reusing the same FIXTURE

    assert a_single_user['id'] < 2






















































































# ===================================== THE PROBLEM - COPY-PASTE HELL (What NOT to do) =====================================

def calculate_age_category(user):
    """
    Business logic function that categorizes users by age.
    
    Args:
        user (dict): Dictionary containing user data with 'age' key
    
    Returns:
        str: Age category ('minor', 'adult', 'senior')
    """
    # Extract the age value from the user dictionary
    age = user["age"]
    
    # Business logic: categorize based on age thresholds
    if age < 18:
        return "minor"
    elif age < 65:
        return "adult"
    else:
        return "senior"


def format_name(user):
    """
    Formats user's name to uppercase.
    
    Args:
        user (dict): Dictionary containing user data with 'name' key
    
    Returns:
        str: Uppercase version of the name
    """
    # .upper() is a string method that converts all characters to uppercase
    # We're using it to standardize name formatting across the system
    return user["name"].upper()


def validate_email(user):
    """
    Validates if user has an email field.
    
    Args:
        user (dict): Dictionary containing user data
    
    Returns:
        bool: True if email exists and is not empty, False otherwise
    """
    # .get() is used instead of direct key access to avoid KeyError
    # The second argument ('') is the default value if 'email' key doesn't exist
    # This is defensive programming - assume the key might be missing
    email = user.get("email", "")
    
    # bool(email) returns False if email is empty string, None, or doesn't exist
    return bool(email)



# ===================================== BAD APPROACH: Duplicating user creation in every test =====================================

def test_user_age_BAD_APPROACH():
    """
    Test age categorization logic.
    
    PROBLEM: We're creating the user dictionary manually here.
    If we have 50 tests, we write this line 50 times.
    """
    # Creating a user dictionary from scratch
    # This is WASTEFUL because we repeat this in every test
    user = {"name": "Jesse", "age": 25, "email": "jesse@futo.edu.ng"}
    
    # The actual test logic - checking if 25-year-old is categorized as 'adult'
    assert calculate_age_category(user) == "adult"


def test_user_name_BAD_APPROACH():
    """
    Test name formatting logic.
    
    PROBLEM: SAME user dictionary created again. Pure duplication.
    """
    # COPY-PASTE from previous test - this is technical debt
    user = {"name": "Jesse", "age": 25, "email": "jesse@futo.edu.ng"}
    
    # Check if name gets converted to uppercase correctly
    assert format_name(user) == "JESSE"


def test_user_email_BAD_APPROACH():
    """
    Test email validation logic.
    
    PROBLEM: THIRD time creating the same dictionary!
    """
    # ANOTHER copy-paste. If we need to change user structure, we edit 3+ places
    user = {"name": "Jesse", "age": 25, "email": "jesse@futo.edu.ng"}
    
    # Check if email validation works (should return True since email exists)
    assert validate_email(user) is True


# ===================================== THE SOLUTION - FIXTURES (The Professional Way) =====================================

@pytest.fixture
def sample_user():
    """
    FIXTURE: A factory function that produces a pre-configured user object.
    
    The @pytest.fixture decorator tells Pytest:
    "This is not a test function. This is a RESOURCE PROVIDER."
    
    How it works:
    1. When a test function has 'sample_user' in its parameter list,
       Pytest automatically calls THIS function
    2. Pytest takes the return value and injects it into the test
    3. The test never calls sample_user() manually - Pytest handles it
    
    This is DEPENDENCY INJECTION:
    - The test DEPENDS on having a user object
    - Instead of creating it manually, the test REQUESTS it
    - Pytest INJECTS it automatically
    
    Returns:
        dict: A standardized user dictionary for testing
    """
    # This dictionary is created ONCE per test that requests this fixture
    # We define the user structure in ONE place
    return {
        "name": "Jesse",  # Sample name for testing
        "age": 25,  # Sample age - chosen to test 'adult' category
        "email": "jesse@futo.edu.ng"  # Valid email for validation tests
    }



# ===================================== GOOD APPROACH: Using the fixture =====================================

def test_user_age(sample_user):
    """
    Test age categorization using fixture.
    
    MAGIC HAPPENING:
    1. Pytest sees 'sample_user' in the parameter list
    2. Pytest looks for a fixture named 'sample_user'
    3. Pytest runs the sample_user() function
    4. Pytest injects the returned dictionary into this test
    5. We never wrote sample_user = sample_user() manually
    
    Args:
        sample_user: Automatically injected by Pytest (not manually passed)
    """
    # sample_user is already available - we didn't create it
    # This is DEPENDENCY INJECTION in action
    result = calculate_age_category(sample_user)
    
    # Assert that a 25-year-old is categorized as 'adult'
    assert result == "adult"


def test_user_name(sample_user):
    """
    Test name formatting using fixture.
    
    Args:
        sample_user: Same fixture, AUTOMATICALLY provided again by Pytest
    """
    # SAME fixture, DIFFERENT test
    # Pytest re-runs the fixture function to get a fresh user object
    result = format_name(sample_user)
    
    # Assert that "Jesse" becomes "JESSE" when formatted
    assert result == "JESSE"


def test_user_email(sample_user):
    """
    Test email validation using fixture.
    
    Args:
        sample_user: Third test using the same fixture
    """
    # STILL using the same fixture definition
    # No copy-paste, no duplication
    result = validate_email(sample_user)
    
    # Assert that validation returns True for a valid email
    assert result is True


# ===================================== MULTIPLE FIXTURES - COMPOSABILITY =====================================

@pytest.fixture
def admin_user():
    """
    Fixture for an admin user with elevated privileges.
    
    WHY separate fixture:
    Some tests need regular users, some need admins.
    We can have multiple fixtures and choose which one each test needs.
    
    Returns:
        dict: Admin user with role field
    """
    return {
        "name": "Admin Jesse",
        "age": 30,
        "email": "admin@futo.edu.ng",
        "role": "admin"  # Additional field for admin-specific tests
    }


@pytest.fixture
def minor_user():
    """
    Fixture for a user under 18 years old.
    
    WHY separate fixture:
    Age-boundary testing requires users of different ages.
    Instead of parametrizing (coming later), we can use different fixtures.
    
    Returns:
        dict: User under 18 years old
    """
    return {
        "name": "Young Jesse",
        "age": 16,  # Under 18 - should be categorized as 'minor'
        "email": "young@futo.edu.ng"
    }


def test_minor_classification(minor_user):
    """
    Test that users under 18 are classified as minors.
    
    Args:
        minor_user: Different fixture than previous tests
    """
    # Using a DIFFERENT fixture (minor_user instead of sample_user)
    # Pytest knows which fixture to inject based on the parameter name
    result = calculate_age_category(minor_user)
    
    # Assert that a 16-year-old is categorized as 'minor'
    assert result == "minor"


def test_admin_has_role(admin_user):
    """
    Test that admin user has role field.
    
    Args:
        admin_user: Yet another fixture for admin-specific tests
    """
    # Using the admin_user fixture instead of sample_user
    # This demonstrates MULTIPLE fixtures coexisting in the same test file
    
    # Assert that admin user has a 'role' key in the dictionary
    assert "role" in admin_user
    
    # Assert that the role value is 'admin'
    assert admin_user["role"] == "admin"


# ===================================== FIXTURES THAT RETURN COMPLEX OBJECTS =====================================

class DatabaseConnection:
    """
    Mock database connection class for demonstration.
    
    In real MLOps, this would be SQLAlchemy Session or psycopg2 connection.
    """
    
    def __init__(self, host, port):
        """
        Initialize database connection.
        
        Args:
            host (str): Database host address
            port (int): Database port number
        """
        self.host = host
        self.port = port
        self.connected = True  # Simulate active connection
    
    def query(self, sql):
        """
        Execute a SQL query.
        
        Args:
            sql (str): SQL query string
        
        Returns:
            str: Mock query result
        """
        # In real code, this would execute actual SQL
        # Here we just return a mock result
        return f"Result for: {sql}"
    
    def close(self):
        """Close the database connection."""
        self.connected = False


@pytest.fixture
def db_connection():
    """
    Fixture that returns a complex object (not just a dict).
    
    This demonstrates that fixtures can return ANY Python object:
    - Class instances
    - Database connections
    - API clients
    - File handles
    - Anything your tests need
    
    Returns:
        DatabaseConnection: Mock database connection object
    """
    # Create a database connection object with test credentials
    # host='localhost' means connect to local test database
    # port=5432 is the default PostgreSQL port
    connection = DatabaseConnection(host="localhost", port=5432)
    
    # Return the connection object to the test
    # The test receives this EXACT object instance
    return connection


def test_database_query(db_connection):
    """
    Test that database queries work correctly.
    
    Args:
        db_connection: DatabaseConnection instance injected by Pytest
    """
    # db_connection is a DatabaseConnection object (not a dict this time)
    # This shows fixtures can provide ANY type of object
    
    # Execute a query using the injected connection
    result = db_connection.query("SELECT * FROM users")
    
    # Assert that we got a result back (not None)
    assert result is not None
    
    # Assert that result contains the query we sent
    assert "SELECT * FROM users" in result


def test_database_connection_status(db_connection):
    """
    Test that database connection is active.
    
    Args:
        db_connection: Same DatabaseConnection instance (fresh for this test)
    """
    # Check the connected status attribute
    # This should be True for a newly created connection
    assert db_connection.connected is True


# ===================================== FIXTURES WITH PARAMETERS (Advanced Pattern) =====================================
@pytest.fixture
def user_with_custom_age():
    """
    Fixture factory that returns a function.
    
    WHY: Sometimes you need a fixture that can be CONFIGURED per test.
    Instead of returning data directly, we return a FUNCTION that creates data.
    
    This is the "Factory Fixture" pattern.
    
    Returns:
        function: A function that takes age and returns a user dict
    """
    def _make_user(age):
        """
        Internal factory function that creates users with custom ages.
        
        Args:
            age (int): The age to assign to the user
        
        Returns:
            dict: User dictionary with specified age
        """
        return {
            "name": "Jesse",
            "age": age,  # Age is now CONFIGURABLE by the test
            "email": "jesse@futo.edu.ng"
        }
    
    # Return the FUNCTION itself (not the result of calling it)
    # The test will call this function with its desired age
    return _make_user


def test_senior_classification(user_with_custom_age):
    """
    Test that users 65+ are classified as seniors.
    
    Args:
        user_with_custom_age: A FUNCTION that creates users with custom ages
    """
    # user_with_custom_age is a FUNCTION (not a dict)
    # We CALL it with age=70 to get a 70-year-old user
    senior_user = user_with_custom_age(70)
    
    # Now test the classification with a senior user
    result = calculate_age_category(senior_user)
    
    # Assert that a 70-year-old is categorized as 'senior'
    assert result == "senior"


def test_boundary_adult(user_with_custom_age):
    """
    Test the exact boundary between adult and senior (age 65).
    
    Args:
        user_with_custom_age: Same factory function
    """
    # Create a user at the exact boundary age
    # age=64 should still be 'adult', not 'senior'
    boundary_user = user_with_custom_age(64)
    
    result = calculate_age_category(boundary_user)
    
    # Assert that 64 is still classified as 'adult'
    assert result == "adult"




















































































































# ===================================== Performing logging operations =====================================

path_to_file = "/home/jesfusion/Documents/ml/ML-Learning-Repository/logs/print.log"


pytest_logger = logging.getLogger(name = 'Pytest Learning')

pytest_logger.setLevel(level = logging.DEBUG)

terminal = logging.StreamHandler()

terminal.setLevel(
    level = logging.INFO
)

terminal.setFormatter(
    fmt = logging.Formatter(
        fmt = "%(message)s"
    )
)


file = logging.FileHandler(
    filename = path_to_file,
    mode = 'w'
)

file.setLevel(
    level = logging.DEBUG
)

file.setFormatter(
    fmt = logging.Formatter(
        fmt = "{asctime} ::: {name} ::: {levelname} ::: [{filename}: line {lineno}]\n{message}\n\n",

        datefmt = "%Y/%m/%d, %I:%M %p",

        style = '{' # options are '%', '$' or '{' (check things to note)
    )
)

# adding the two handlers to our logger...

handlers = [terminal, file]

for handler in range(len(handlers)):

    pytest_logger.addHandler(hdlr = handlers[handler])



def print(item):

    return pytest_logger.info(item)























































































































np.random.seed(seed = 20) # Sets the random seed to 20 to ensure reproducible random numbers

# ===================================== SEGMENT 2.2: SETUP AND TEARDOWN (yield) =====================================

@pytest.fixture # Decorator marking the following function as a pytest fixture

def temp_file_creation(): # Defines a fixture function to create and yield a temporary file
    # SETUP PHASE: Everything before the 'yield' statement runs before the test starts.
    path_to_file = "/home/jesfusion/Documents/ml/ML-Learning-Repository/Pytest/temporary_file.log" # Sets the hardcoded file path string

    file_content = np.random.randn(16, 19) # Generates a 16x19 array of normally distributed random numbers

    with open( # Opens a file context manager to handle file operations safely
        file = path_to_file, # Specifies the file path to open
        mode = 'w' # Sets the file mode to 'w' (write), overwriting if it exists
    ) as file: # Assigns the opened file object to the variable 'file'

        file.write(f"{file_content}") # Converts the numpy array to a string and writes it to the file

    pytest_logger.debug(f"Temporary file created at: {path_to_file}") # Logs a debug message confirming file creation

    # The 'yield' keyword pauses this fixture and hands control (and the file path) over to the test.
    yield path_to_file # Yields the file path to the test function that requested it

    # TEARDOWN PHASE: Everything after the 'yield' runs after the test finishes, ensuring cleanup.
    if os.path.exists( # Checks if the file path actually exists on the disk
        path = path_to_file # Passes the file path to the os.path.exists function
    ): # Ends the condition check for file existence
        
        os.remove(path = path_to_file) # Deletes the file from the operating system

        pytest_logger.debug(f'Temporary file deleted at "{path_to_file}"') # Logs a debug message confirming file deletion





@pytest.fixture # Decorator marking the database_connection function as a pytest fixture

def database_connection(): # Defines a fixture to handle database connections
    # Setup: Create engine and establish a connection
    database_engine = create_engine(os.environ.get('POSTGRE_ML_CONNECT')) # Creates an SQLAlchemy engine using an environment variable

    conn = database_engine.connect() # Establishes a live connection from the engine

    pytest_logger.debug("Successfully connected to database!") # Logs a debug message for successful connection

    # Provide the connection object to the test
    yield conn # Yields the connection object to the test function

    # Teardown: Safely close the connection regardless of whether the test passed or failed
    conn.close() # Closes the database connection to free up resources

    pytest_logger.debug("Successfully closed database connection!") # Logs a debug message confirming the connection is closed










# ===================================== SEGMENT 2.3: FIXTURE SCOPES =====================================

# 'function' scope is the default. This fixture executes from scratch for EVERY individual test that requests it.
@pytest.fixture(scope = 'function') # explicitly sets the fixture scope to 'function' (runs per test)

def resource_at_function_scope(): # Defines a fixture meant to demonstrate function scope

    the_resource = { # Initializes a dictionary representing a mock resource
        
        "name": "FunctionResource",  # Sets the 'name' key of the mock resource
        
        "call_count": 0 # Initializes a counter to track how many times it is used/modified
    } # Closes the dictionary definition

    pytest_logger.debug(f'Function scope created: \n{the_resource}') # Logs the creation of the function-scoped resource

    yield the_resource # Hands the resource dictionary over to the requesting test


    pytest_logger.debug(f"Function Scope '{the_resource['name']}' Destroyed!") # Logs the destruction/teardown of the resource





# 'session' scope means this fixture runs exactly ONCE for the entire test suite run. 
# All tests requesting it will share the exact same instance in memory.
@pytest.fixture( # Starts the fixture decorator
    scope = 'session' # Sets the scope to 'session' so it is shared across all tests in the run
) # Closes the fixture decorator

def resource_at_session_scope(): # Defines a fixture meant to demonstrate session scope

    time.sleep(0.4) # Simulates a slow setup process by pausing execution for 0.4 seconds

    database_engine = { # Initializes a dictionary to mock a database engine
        "type": "PostgresEngine", # Sets the 'type' key to describe the mock engine

        "pool_size": 5, # Sets a mock connection pool size

        "queries_run": 0 # Initializes a counter to track queries run during the session
    } # Closes the mock database engine dictionary

    pytest_logger.debug(f"Database Engine Ready: {database_engine['type']}") # Logs that the session-scoped engine is ready

    yield database_engine # Yields the session-shared engine dictionary to tests

    pytest_logger.debug(f"Shutting Down engine with {database_engine['queries_run']} queries passed") # Logs the teardown and total queries run



# 'module' scope means this fixture runs exactly ONCE per Python file (module).
# Tests inside this file share the state, but tests in other files would get a fresh instance.
@pytest.fixture(scope = 'module') # Sets the scope to 'module', shared by all tests in this specific file

def resource_at_module_scope(): # Defines a fixture meant to demonstrate module scope

    pytest_logger.debug("Loading app config for module...") # Logs the start of the module setup

    test_config = { # Initializes a dictionary to mock application configuration
        "app_name": "ProPlex", # Sets the application name
        "version": "3.0.11", # Sets the application version
        "db_host": "localhost", # Sets the mock database host
        "debug": False # Sets the debug flag
    } # Closes the config dictionary

    yield test_config # Yields the configuration dictionary to the tests in this module

    pytest_logger.debug("Unloaded config for the module!") # Logs the teardown of the module configuration







# ===================================== SEGMENT 3.1: CONFTEST.PY =====================================

"""

conftest.py is a magic file pytest auto-discovers.
  Fixtures defined there are available to ALL tests in the same directory
  and ALL subdirectories — with ZERO import statements needed.

In a real project, the fixtures below would NOT be in this file.
They would live in conftest.py at the project root.
We're keeping them here purely for a self-contained learning script.

REAL PROJECT STRUCTURE:
  project_root/
  ├── conftest.py <-- global_auth_client, global_db_engine live here
  ├── pytest.ini
  └── tests/
      ├── conftest.py <-- test-suite-wide fixtures live here
      ├── unit/
      │   ├── conftest.py   <-- unit-test-only fixtures live here
      │   └── test_models.py
      └── integration/
          ├── conftest.py   <-- integration-test-only fixtures live here
          └── test_api.py

"""

@pytest.fixture(scope = 'session') # Decorates a global fixture with session scope

def global_authenticated_HTTP_client(): # Defines a fixture to simulate an authenticated HTTP client

    pytest_logger.info("Initializing global authentication client...") # Logs the initialization of the auth client

    authentication_client = { # Initializes a dictionary representing the HTTP client

        "base_url": "https://localhost:2006", # Sets the mock base URL

        "token": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", # Sets a mock JWT token

        "headers": {"HTTP Authorization": "Bearer test_token_jesse_123"}, # Sets the authorization headers

        "is_authenticated": True, # Sets a boolean flag indicating authentication success
    } # Closes the auth client dictionary

    pytest_logger.info(f"Authentication client ready with url: {authentication_client['base_url']}") # Logs that the client is ready

    yield authentication_client # Yields the client to the requesting tests

    authentication_client['is_authenticated'] = False # Mocks the logout/cleanup process by setting auth to False

    pytest_logger.info("Authentication client closed!") # Logs the teardown of the auth client






@pytest.fixture(scope = 'module') # Decorates a fixture representing a database record with module scope

def database_record(): # Defines a fixture to mock a user record from a database

    pytest_logger.info("Creating user record...") # Logs the creation of the record

    the_user = { # Initializes a dictionary representing the user data
        "id": "usr_001", # Sets the user ID
        "name": "Jesse Ekwebelem", # Sets the user name
        "role": "Machine Learning Engineer", # Sets the user role
        "email": "jesse@gmail.com", # Sets the user email
        "is_active": True, # Sets the active status flag
    } # Closes the user dictionary
    
    yield the_user # Yields the user record to the requesting tests

    pytest_logger.info("User record cleaned up!") # Logs the teardown of the user record





# Requesting the fixture by naming it in the test parameters automatically executes it
def test_temporary_file_existence(temp_file_creation): # Defines a test that relies on the temp_file_creation fixture

    # The value of 'temp_file_creation' here is whatever was yielded by the fixture (the file path)
    file_path = temp_file_creation # Assigns the yielded file path to a local variable

    pytest_logger.debug(f'Checking if file exists at "{file_path}"...') # Logs the start of the existence check

    assert os.path.exists( # Asserts that the file path exists on the disk
        path = file_path # Passes the local file_path to os.path.exists
    ), "Temporary file was not created!" # Provides an error message if the assertion fails

    with open(file = file_path) as the_file: # Opens the file to read its contents

        the_file_content = the_file.read() # Reads the entire file content into a string variable

    # Verifying that the numpy array data was actually written to the file
    assert """1.44652159e+00 -3.76858470e-01 -1.28474253e-01 -4.77532686e-01
  -1.22202480e-01  2.07655008e-01 -1.49265894e-01  1.02086503e+00
   1.97192189e+00  """ in the_file_content, f"Array missing in temp file {file_path}" # Asserts that specific numbers exist in the string
    

    pytest_logger.debug(f'File Content at "{file_path}" verified!') # Logs success if the file content assertion passes
    




def test_connection_to_database(database_connection): # Defines a test that requires the database_connection fixture

    conn = database_connection # Assigns the yielded connection object to a local variable

    dataset = pd.read_sql_query( # Uses pandas to execute a SQL query and load it into a DataFrame
        sql = "SELECT * FROM  breast_cancer_dataset", # Specifies the SQL query string
        con = conn         # Provides the connection object to pandas
    ) # Closes the read_sql_query function call

    # Validating the expected number of rows returned from the database query
    assert len(dataset) == 569 # Asserts that the resulting DataFrame has exactly 569 rows

    pytest_logger.debug("Number of rows confirmed in breast cancer dataset!") # Logs a success message after the assertion







# ===================================== Fixture Scopes Testing =====================================


# function scope testing...

def test_function_scope_1(resource_at_function_scope): # First test to demonstrate function scoping

    resource = resource_at_function_scope # Grabs the yielded dictionary from the function-scoped fixture

    resource['call_count'] += 1 # Increments the call_count to mutate the dictionary

    pytest_logger.debug(f"Call count for test_function_scope_1 after mutation: {resource['call_count']}") # Logs the mutated count

    # Because this is a function-scoped fixture, call_count starts at 0 for THIS test.
    assert resource['call_count'] == 1 # Asserts that the count is exactly 1



def test_function_scope_2(resource_at_function_scope): # Second test to demonstrate function scoping

    resource2 = resource_at_function_scope # Grabs the dictionary; it will be a brand new instance because of function scope

    resource2['call_count'] += 1 # Increments the new instance's count from 0 to 1

    pytest_logger.debug(f"Call count for test_function_scope_2 after mutation: {resource2['call_count']}") # Logs the mutated count

    # Notice how this also asserts 1! The fixture was completely recreated for this second test,
    # proving that function-scoped fixtures do not share state between tests.
    assert resource2['call_count'] == 1 # Asserts the count is 1, confirming state was not shared





# session scope testing...


def test_session_scope_1(resource_at_session_scope): # First test to demonstrate session scoping

    session_resource = resource_at_session_scope # Grabs the session-scoped dictionary

    session_resource['queries_run'] += 1 # Increments the queries_run counter

    pytest_logger.debug(f"Query # {session_resource['queries_run']} on engine: {session_resource['type']}") # Logs the incremented value

    assert session_resource['queries_run'] == 1 # Asserts the count is 1 for the first run


def test_session_scope_2(resource_at_session_scope): # Second test to demonstrate session scoping

    session_resource2 = resource_at_session_scope # Grabs the SAME dictionary instance as the previous test

    session_resource2['queries_run'] += 1 # Increments the counter, which starts at 1 this time

    pytest_logger.debug(f"Query # {session_resource2['queries_run']} on engine: {session_resource2['type']}") # Logs the incremented value

    # Because this fixture is session-scoped, it remembers the mutation from test_session_scope_1.
    # Shared state means 'queries_run' is now 2!
    assert session_resource2['queries_run'] == 2 # Asserts the count is 2, proving shared state across the session





# module scope testing...

def test_configuration_app_name(resource_at_module_scope): # First test to demonstrate module scoping

    m_resource = resource_at_module_scope # Grabs the module-scoped configuration dictionary

    pytest_logger.debug("Verifying app name from configuration...") # Logs intent to verify app name


    assert m_resource['app_name'] == 'ProPlex' # Asserts the app name matches the initial dictionary value

    pytest_logger.debug(f'App name "{m_resource['app_name']} confirmed') # Logs confirmation of the original app name

    pytest_logger.debug("Changing app name...") # Logs intent to mutate the dictionary

    # We are mutating the module-scoped dictionary here.
    m_resource['app_name'] = 'Skittle' # Changes the app name in the shared dictionary

    pytest_logger.debug(f"App name changed to {m_resource['app_name']}") # Logs the new app name






def test_configuration_version(resource_at_module_scope): # Second test to demonstrate module scoping

    m_resource2 = resource_at_module_scope # Grabs the SAME module-scoped configuration dictionary

    pytest_logger.debug("Verifying app version...") # Logs intent to check the version

    assert m_resource2['version'] == "3.0.11" # Asserts the version matches the original value

    pytest_logger.debug("Confirming app name change...") # Logs intent to check the mutated app name

    # Proving module-scope: This test sees the 'Skittle' change made by the previous test
    # because they share the same fixture instance.
    assert m_resource2['app_name'] == 'Skittle' # Asserts the app name is Skittle, proving state is shared within the module









# ===================================== SEGMENT 3.1: CONFTEST.PY =====================================

def test_authentication_client(global_authenticated_HTTP_client): # Test to verify the mock auth client fixture

    auth = global_authenticated_HTTP_client # Grabs the auth client dictionary

    pytest_logger.info(f"Authentication status: {auth["is_authenticated"]}") # Logs the boolean auth status

    assert auth['is_authenticated'] is True # Asserts that the client is authenticated

    assert "HTTP Authorization" in auth['headers'] # Asserts that the expected header key exists

    pytest_logger.info(f"Is Auth header present? {auth['headers']["HTTP Authorization"] == "Bearer test_token_jesse_123"}") # Logs a boolean check of the header value





# Pytest allows you to request multiple fixtures in a single test simply by adding them to the parameters
def test_database_record( # Starts defining a test that requires multiple fixtures
    database_record, # Requests the module-scoped user record fixture
    global_authenticated_HTTP_client # Requests the session-scoped auth client fixture
): # Ends the parameter list
    
    authentication = global_authenticated_HTTP_client # Assigns the auth client to a local variable

    record = database_record # Assigns the user record to a local variable

    pytest_logger.info(f"User: {record['name']} ::: Role: {record['role']}") # Logs the user's name and role

    assert record['role'] == "Machine Learning Engineer" # Asserts the user's role matches expectations

    assert record['is_active'] is True # Asserts the user's active status is True

    pytest_logger.info(f"MLOps Engineer career confirmed with token {authentication['token']}") # Logs a success message utilizing data from both fixtures





def test_authentication_client_correct_base_url(global_authenticated_HTTP_client): # Test to verify the URL of the auth client

    auth = global_authenticated_HTTP_client # Grabs the auth client dictionary

    pytest_logger.info(f"Base URL: {auth['base_url']}") # Logs the base URL

    # String assertions using standard Python string methods
    assert auth['base_url'].startswith('https') # Asserts the URL starts with https, checking for secure protocol

    assert '2006' in auth['base_url'] # Asserts that the port 2006 is present in the URL string

    pytest_logger.info("Base URL is valid AWS Server: CONFIRMED!") # Logs confirmation of the URL




def test_user_email_domain(database_record): # Test to verify the user record's email

    rec = database_record # Grabs the user record dictionary

    pytest_logger.info(f"Email: {rec['email']}") # Logs the user's email address

    assert rec['email'].endswith('@gmail.com') # Asserts that the email belongs to the gmail domain

    pytest_logger.info("User is using a valid gmail address!") # Logs confirmation of the email domain











