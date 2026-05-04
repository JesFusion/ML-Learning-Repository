import os
import sys
import json
import time
import pytest
import asyncio
import logging
import numpy as np
import pandas as pd
from unittest.mock import (
    Mock,
    MagicMock,
    patch,
    call,
    AsyncMock
)
from fastapi import FastAPI
import requests as requests_lib
from fastapi import HTTPException
from sqlalchemy import create_engine
from fastapi.testclient import TestClient



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













































































# ===================================== CODE_TO_TEST.pY =====================================




# A conditional statement that always evaluates to true, executing the block below.
if True:

    # Initializes a logger instance named "PyTorch Learning".
    log = logging.getLogger(name = "Pytest Learning")

    # Sets the minimum logging level to DEBUG to capture all log messages.
    log.setLevel(level = logging.DEBUG)

    # Creates a stream handler to send log output to the console.
    handler_1 = logging.StreamHandler()

    # Sets the stream handler's logging level to INFO.
    handler_1.setLevel(level = logging.INFO)

    # Defines a logging format that prints the message followed by a newline.
    format_1 = logging.Formatter(fmt = '\n\n%(name)s,\nFile: "%(filename)s", Line %(lineno)s,\nOutput ==> %(message)s\n')

    # Applies the defined format to the stream handler.
    handler_1.setFormatter(fmt = format_1)

    # Attaches the configured stream handler to the logger.
    log.addHandler(hdlr = handler_1)




# Defines a custom exception class inheriting from the base Exception class.
class ErrorFromInsufficientFunds(Exception):

    """
    Raised when a charge amount exceeds the allowed single-transaction limit.
    """

    # Placeholder body; no additional implementation needed beyond the docstring.
    pass


# Defines a custom exception class inheriting from ValueError.
class ErrorFromInvalidEmail(ValueError):

    """
    Raised when an email string fails format validation checks.
    """

    # Placeholder body; no additional implementation needed beyond the docstring.
    pass




# Defines the main payment processing class.
class PaymentProcessingClass:

    # Initializes a new instance of the payment processor.
    def __init__(self):
        
        # Sets the maximum allowed amount for a single transaction.
        self.transaction_limit = 10_000

    # Defines the method responsible for charging a given amount.
    def the_charge(
        self,
        the_amount,
        the_currency = 'USD'
    ):
        
        # Checks whether the provided amount is zero or negative.
        if the_amount <= 0:

            # Raises a ValueError if the charge amount is not positive.
            raise ValueError(f"Charge amount must be positive, got: {the_amount}")
        
        # Checks whether the amount exceeds the single-transaction limit.
        elif the_amount > self.transaction_limit:

            # Raises the custom insufficient funds error for over-limit amounts.
            raise ErrorFromInsufficientFunds(f"Amount {the_amount} exceeds single-transaction limit of {self.transaction_limit}")
        
        # Builds a dictionary representing a successful charge result.
        output = {
            "status": "charged",
            
            "amount": the_amount,
            
            "currency": the_currency
        }

        # Returns the charge result dictionary to the caller.
        return output
    

    # Defines the method that processes a refund for a given transaction.
    def refund_money(
        self,
        transactionID,
        the_amount
    ):
        
        # Checks whether the transaction ID is missing or empty.
        if not transactionID:

            # Raises a ValueError if no transaction ID was supplied.
            raise ValueError("transaction_id cannot be empty or None")
        
        # Checks whether the refund amount is zero or negative.
        if the_amount <= 0:

            # Raises a ValueError if the refund amount is not positive.
            raise ValueError(f"Refund amount must be positive, got: {the_amount}")
        
        
        # Builds a dictionary representing a successful refund result.
        output = {
            "status": "refunded",
            "transaction id": transactionID,
            "amount": the_amount
        }

        # Returns the refund result dictionary to the caller.
        return output
    

    # Defines the method that processes a list of transactions in bulk.
    def batch_processing(
        self,
        the_transactions
    ):
        
        # Initializes an empty list to collect each transaction's result.
        transaction_results = []


        # Iterates over each transaction in the provided list.
        for transaction in the_transactions:

            # Calls the_charge for the current transaction and stores the result.
            the_result = self.the_charge(
                the_amount = transaction['amount'],

                # Retrieves the currency from the transaction, defaulting to 'USD'.
                the_currency = transaction.get('currency', 'USD')
            )

            # Appends the current transaction's result to the results list.
            transaction_results.append(the_result)

        
        # Returns the list of all processed transaction results.
        return transaction_results
    




# Defines the class responsible for data validation logic.
class ClassThatValidatesData:

    # Defines the method that checks whether an email address is valid.
    def email_validation(
        self,
        the_Email
    ):
        
        # Checks whether the email value is falsy (None, empty string, etc.).
        if not the_Email:

            # Raises the custom email error if the email is empty or None.
            raise ErrorFromInvalidEmail("Email cannot be empty or None")
        

        # Checks whether the email value is of string type.
        if not isinstance(the_Email, str):

            # Raises the custom email error if the email is not a string.
            raise ErrorFromInvalidEmail(f"Email must be a string, got: {type(the_Email).__name__}")


        # Checks whether the '@' symbol is present in the email string.
        if '@' not in the_Email:

            # Raises the custom email error if '@' is missing from the email.
            raise ErrorFromInvalidEmail(f"Email must contain '@': received '{the_Email}'")
        

        # Checks whether the domain portion of the email contains a dot.
        if '.' not in the_Email.split('@')[-1]:

            # Raises the custom email error if the domain has no dot.
            raise ErrorFromInvalidEmail(f"Email domain must contain '.': received '{the_Email}'")
        
        # Returns True to indicate the email passed all validation checks.
        return True


    # Defines the method that applies a percentage discount to a price.
    def calculating_the_discount(
        self,
        price,
        discount_pct # discount_pct = discount percentage
    ):
        
        # Validates that the discount percentage is within the 0–100 range.
        if discount_pct < 0 or discount_pct > 100:

            # Raises a ValueError if the discount is outside the valid range.
            raise ValueError(f"Discount must be between 0 and 100, got: {discount_pct}")
        
        # Calculates the discounted price and rounds it to two decimal places.
        output = float(f"{(price * (1 - discount_pct / 100)):.2f}")

        # Returns the final discounted price.
        return output
    

    # Defines the method that checks whether a given text is a palindrome.
    def is_it_palindrome(
        self,
        input_text
    ):
        
        # Converts the input to lowercase and removes all spaces for comparison.
        cleaned_text = str(input_text).lower().replace(" ", "")


        # Returns True if the cleaned text reads the same forwards and backwards.
        return cleaned_text == cleaned_text[::-1]
    

    # Defines the method that computes summary statistics from a list of scores.
    def scores_summarization(
        self,
        the_scores
    ):
        
        # Checks whether the scores list is empty.
        if not the_scores:

            # Raises a ValueError if no scores were provided.
            raise ValueError("Scores list cannot be empty!")
        
        # Builds a dictionary of min, max, average, and count statistics.
        output = {
            "min": min(the_scores),

            "max": max(the_scores),

            "avg": round(
                sum(the_scores) / len(the_scores),

                ndigits = 2
            ),

            "count": len(the_scores)
        }

        # Returns the statistics dictionary.
        return output




# Defines a standalone function that fetches a live currency exchange rate.
def exchange_rate_fetching(
    Bcurrency, # Bcurrency = Base Currency

    Tcurrency # Tcurrency = Target Currency
):
    
    """
    Calls a live currency exchange API. NEVER call this real URL in tests.    
    """
    
    # Sends a GET request to the exchange rate API with the base and target currency.
    API_response = requests_lib.get(
        url = 'https://api.exchangerate.host/latest',

        params = {
            "base": Bcurrency,

            "symbols": Tcurrency
        },

        timeout = 5
    )

    # Parses the JSON body of the API response into a Python dictionary.
    output_data = API_response.json()

    # Extracts the specific target currency rate from the parsed response data.
    output = output_data['rates'][Tcurrency] # Tcurrency = 'EUR'

    # Returns the extracted exchange rate value.
    return output




# Defines a function that notifies an external payment gateway about a transaction.
def gateway_payment_notification(
    transID,
    the_amount,
    the_gateway_client
):
    
    """
    Notifies an external payment gateway. The gateway_client is injected
    so tests can pass a Mock directly — no patching required.
    """

    # Checks whether a transaction ID was provided.
    if not transID:

        # Raises a ValueError if the transaction ID is missing.
        raise ValueError("No value provided! Please provide a value")
    

    # Calls the gateway client's post method to send the notification payload.
    the_gateway_client.post(
        endpoint = '/notify',
        payload = {
            'transaction_id': transID,
            "amount": the_amount
        }
    )

    # Returns True to signal the notification was dispatched successfully.
    return True
    




# Defines an asynchronous function that simulates fetching a user's profile.
async def fetch_user_profile_async(
    uID, # uID = User ID
    HTTP_clt = None # HTTP_clt =  HTTP client
):    
    """
    Async function simulating an async HTTP call to a user-profile service.
    """

    # Yields control to the event loop with a zero delay, simulating async behavior.
    await asyncio.sleep(delay = 0)

    # Checks whether an HTTP client was injected for making real async calls.
    if HTTP_clt:

        # Awaits the async GET call to the user profile endpoint.
        the_result = await HTTP_clt.get(
            url = f"/users/{uID}"
        )

        # Returns the result received from the injected HTTP client.
        return the_result

    # Constructs a default mock profile dictionary when no client is provided.
    output = {
        'id': uID,
        'name': 'Jesse the Tester',
        'role': "MLOps Engineer"
    }
    
    # Returns the hardcoded default profile.
    return output




# ===================================== RANDOM FUNCTIONS TO BE USED IN SEGMENT 3.1 =====================================

# Defines a stub class simulating a database engine.
class creating_the_engine:

    # Accepts a database URL but performs no real initialization.
    def __init__(self, url):

        # Placeholder body; no engine setup implemented.
        pass

    # Stub method representing the teardown of the engine.
    def disposing_the_engine():

        # Placeholder body; no disposal logic implemented.
        pass


# Defines a stub class simulating a database session.
class session_creation:

    # Accepts a database engine binding but performs no real initialization.
    def __init__(self, bind):
        
        # Placeholder body; no session setup implemented.
        pass

    # Stub method representing a transaction rollback.
    def rollback():

        # Placeholder body; no rollback logic implemented.
        pass

    # Stub method representing closing the session.
    def close():

        # Placeholder body; no close logic implemented.
        pass


# Defines a stub class simulating an application initialization.
class app_initialization:

    # Accepts a configuration value but performs no real setup.
    def __init__(self, configuration):
        
        # Placeholder body; no app initialization logic implemented.
        pass




# Defines a module-level dictionary holding shared global state across tests.
GLOBAL_DICTIONARY = {
    'LastTransactionID': None,
    'RequestCount': 0
}




# Defines a simple function that always returns True.
def IS_JESSE_COOL():
    # Returns True unconditionally.
    return True


















# ===================================== CONFTEST.PY =====================================



# ===================================== SEGMENT 3.1: CONFTEST.PY =====================================




# Declares a session-scoped pytest fixture for a shared database engine.
@pytest.fixture(
    scope = 'session'
)
# Defines the fixture function that creates and tears down the database engine.
def database_engine():

    # Creates a stub engine instance pointing at the test database URL.
    d_engine = creating_the_engine(url = 'postgresql://localhost/test_db')

    # Yields the engine to any test that requests this fixture.
    yield d_engine

    # Calls dispose on the engine during session teardown.
    d_engine.disposing_the_engine()




# Declares a function-scoped fixture that depends on the database_engine fixture.
@pytest.fixture(scope = 'function')
# Defines the fixture function that creates and tears down a database session.
def database_session(database_engine):
    
    # Creates a stub session bound to the provided engine.
    the_session = session_creation(bind = database_engine)

    # Yields the session to the requesting test.
    yield the_session

    # Rolls back any changes made during the test.
    the_session.rollback()

    # Closes the session after rollback during teardown.
    the_session.close()



# Declares a session-scoped fixture for the application instance.
@pytest.fixture(scope = 'session')
# Defines the fixture function that initializes the test application.
def the_app():

    # Returns an initialized app configured for the 'testing' environment.
    return app_initialization(configuration = 'testing')



# Declares a session-scoped fixture that provides a test HTTP client.
@pytest.fixture(
    scope = 'session'
)
# Defines the fixture function that creates the FastAPI test client.
def the_client(the_app):

    # Conditionally imports TestClient only when this fixture runs.
    if True:

        # Imports the FastAPI TestClient for making test HTTP requests.
        from fastapi.testclient import TestClient

    
    # Returns a TestClient instance wrapping the app under test.
    return TestClient(app = the_app)




# ===================================== SEGMENT 3.2: REQUESTING FIXTURES FROM FIXTURES (CHAINING) =====================================

# Declares a module-scoped fixture that simulates an expensive database engine.
@pytest.fixture(scope = 'module')
# Defines the fixture function for the mock database engine.
def database_engine_fixture():
    # Creates a MagicMock to represent the database engine class.
    data_engine = MagicMock(name = 'DatabaseEngineClass')

    # Sets a fake database URL on the mock engine object.
    data_engine.url = "postgresql://localhost/test_database"

    # Sets a fake connection pool size on the mock engine object.
    data_engine.pool_size = 12

    log.debug("database_engine_fixture CREATED (module scope)")

    # Yields the mock engine to all tests in this module.
    yield data_engine

    log.debug("database_engine_fixture DISPOSED (module teardown)")




# Declares a function-scoped fixture that depends on the engine fixture.
@pytest.fixture(scope = 'function')
# Defines the fixture that creates a mock database session for each test.
def database_session_fixture(database_engine_fixture):

    # Creates a MagicMock to represent the database session class.
    data_session = MagicMock(name = 'DatabaseSessionClass')

    # this links the session to the engine
    data_session.bind = database_engine_fixture

    # Sets a flag indicating the session is currently active.
    data_session.is_active = True

    log.debug(f"database_session_fixture CREATED (bound to engine: {database_engine_fixture.url})")

    # Yields the configured mock session to the requesting test.
    yield data_session

    # Rolls back the mock session as part of teardown.
    data_session.rollback()

    log.debug("database_session_fixture ROLLED BACK and closed")




# Declares a function-scoped fixture that represents a payment repository.
@pytest.fixture
# Defines the fixture that builds a fake payment repository backed by the mock session.
def fixture_for_payment_repository(database_session_fixture):

    # Constructs the repository as a dictionary with a session and a lookup lambda.
    repository = {
        'session': database_session_fixture,

        # Defines an inline lambda that returns a fake transaction by ID.
        'FindByID': lambda transaction_id: {
            'id': transaction_id,

            'amount': 637
        }
    }

    # Returns the repository dictionary to the requesting test.
    return repository




# ===================================== SEGMENT 3.3: AUTOUSE FIXTURES =====================================


"""
The final fixture trick is autouse=True, which tells Pytest to inject a fixture into every test in its scope without being explicitly requested. Think of it as a background service that silently starts before every test.
The canonical use cases: resetting a global state variable before every test, patching the system clock to a fixed timestamp across the entire suite, or injecting a logging context. The power is real — you can enforce invariants globally without polluting every test signature. The danger is equally real: autouse fixtures are invisible. A new engineer reading a test has no indication that something is silently running. Used carelessly, it creates tests that mysteriously pass in isolation but fail when run together because of hidden shared state. Autouse is a power tool. Use it for cross-cutting infrastructure concerns, not business logic.
"""



# Declares a function-scoped fixture that runs automatically before every test.
@pytest.fixture(
    scope = 'function',
    autouse = True
)

# Defines the fixture that resets the shared global dictionary before each test.
def fixture_that_resets_global_state():

    # Resets the LastTransactionID key to None before each test runs.
    GLOBAL_DICTIONARY['LastTransactionID'] = None

    # Resets the RequestCount key to zero before each test runs.
    GLOBAL_DICTIONARY['RequestCount'] = 0

    # Pauses the fixture here, allowing teardown code below to run after the test.
    yield

    # If you only want autouse in a specific class, define the fixture INSIDE the class body. Its scope is then limited to that class's tests

















# ===================================== TEST_FUNCTIONS.PY =====================================


# ===================================== SEGMENT 1.1: PYTEST INSTALLATION & DISCOVERY =====================================


# Defines a test class to demonstrate pytest's class-based test discovery.
class TestPytestDemo:

    # Defines a test method verifying basic arithmetic equality.
    def test_InsideAClass(self):

        # Asserts that 4+5 equals 10-1 (both equal 9).
        assert (4 + 5) == (10 - 1)



    # Defines a second test method verifying string membership.
    def test_method_in_class_again(self):

        # Asserts that the substring 'jesse' appears in the full string.
        assert 'jesse' in 'jesse is cool'




# Defines a standalone test function following pytest's naming convention.
def test_naming_convention():

    # Creates a new instance of PaymentProcessingClass for this test.
    the_processor = PaymentProcessingClass()

    # Calls the_charge with a valid amount and stores the result.
    the_result = the_processor.the_charge(the_amount = 100)

    # assert the_result is not None

    # Asserts that the returned value is a dictionary.
    assert isinstance(the_result, dict)




# ===================================== SEGMENT 1.2: BASIC ASSERTIONS =====================================


# Defines a test that checks for inequality in charge output.
def test_assertion_on_inequality():
    
    # Creates a PaymentProcessingClass instance for this test.
    inequality_processor = PaymentProcessingClass()

    # Charges 300 EUR and stores the result.
    output = inequality_processor.the_charge(
        the_amount = 300,
        the_currency = 'EUR'
    )

    # Asserts that the returned currency is not the default 'USD'.
    assert output['currency'] != 'USD'

    log.debug(f"Equality check passed. Result: {output}")




# def test_assertion_on_


# Defines a test that checks for key membership in the charge result.
def test_assertion_on_membership():

    # Creates a PaymentProcessingClass instance for this test.
    membership_processor = PaymentProcessingClass()

    # Charges 340 USD and stores the result.
    the_result = membership_processor.the_charge(the_amount = 340)

    # Iterates over the expected keys to verify each is present in the result.
    for x in ['status', 'amount', 'currency']:

        # Asserts that each expected key exists in the result dictionary.
        assert x in the_result

    log.debug(f"Membership check passed. Keys present: {list(the_result.keys())}")




# Defines a test that verifies numeric comparisons on charge and score output.
def test_assertion_on_comparison():

    # Creates a PaymentProcessingClass instance for this test.
    comparison_processor = PaymentProcessingClass()

    # Charges 998 USD and stores the result.
    comparison_result = comparison_processor.the_charge(the_amount = 998)

    # Extracts the returned amount from the charge result.
    the_amount = comparison_result['amount']

    # Asserts that the amount is greater than zero.
    assert the_amount > 0

    # Asserts that the amount does not exceed the transaction limit.
    assert the_amount<= 10_000

    # Asserts that the amount is at least 100.
    assert the_amount >= 100

    # Creates a ClassThatValidatesData instance for score summary testing.
    the_validator = ClassThatValidatesData()


    # Calls scores_summarization with a sample list and stores the stats.
    comparison_summary = the_validator.scores_summarization(
        the_scores = [22, 56, 92, 912, 73]
    )

    # Asserts that the average score is higher than the minimum score.
    assert comparison_summary['avg'] > comparison_summary['min']

    # Asserts that the maximum score is at least as large as the average.
    assert comparison_summary['max'] >= comparison_summary['avg']

    log.debug(f"Comparison checks passed. Summary: {comparison_summary}")




# Defines a test that checks truthiness, palindrome logic, and float approximation.
def test_assertion_on_truthiness():

    # Creates a ClassThatValidatesData instance for truthiness checks.
    truthiness_validator = ClassThatValidatesData()

    # Validates a well-formed email address and stores the result.
    is_it_valid = truthiness_validator.email_validation(the_Email = 'jesfusionprox@gmail.com')

    # Asserts that the validation returned a truthy value.
    assert is_it_valid

    # Asserts that the phrase is correctly identified as a palindrome.
    assert truthiness_validator.is_it_palindrome(input_text = 'A man a plan a canal Panama')

    # Asserts that a non-palindrome string is correctly rejected.
    assert not truthiness_validator.is_it_palindrome(input_text = 'jessespark')

    # Asserts that 0.1 + 0.2 approximately equals 0.3 within floating-point tolerance.
    assert 0.1 + 0.2 == pytest.approx(expected = 0.3)   

    # Creates a dictionary with a float value for approximate comparison.
    a = {
        'number': 34.5
    }

    # Creates a second dictionary with a slightly different float value.
    b = {
        'number': 35
    }

    # Asserts that b approximately equals a within a 2% relative tolerance.
    assert b == pytest.approx(a, rel = 2e-2)

    
    # Asserts that 2.003 approximately equals 2 within a 1% relative tolerance.
    assert 2.003 == pytest.approx(expected = 2, rel = 1e-2)

    # Asserts that 45.649241 approximately equals 45 within a 2% relative tolerance.
    assert 45.649241 == pytest.approx(expected = 45, rel = 2e-2)

    log.debug("Truthiness checks passed!")




# ===================================== SEGMENT 1.3: HANDLING EXCEPTIONS =====================================



# Defines a test that verifies basic exception raising for invalid charge inputs.
def test_basic_raises():

    # Creates a PaymentProcessingClass instance for this test.
    raises_processor = PaymentProcessingClass()

    # Opens a context expecting a ValueError to be raised.
    with pytest.raises(expected_exception = ValueError):

        # Attempts a charge with a negative amount to trigger the error.
        raises_processor.the_charge(the_amount = -0.13)

    # Opens a context expecting the custom insufficient funds error.
    with pytest.raises(expected_exception = ErrorFromInsufficientFunds):

        # Attempts a charge far above the limit to trigger the custom error.
        raises_processor.the_charge(the_amount = 1_000_000)

    
    log.debug("pytest.raises(ValueError) & pytest.raises(ErrorFromInsufficientFunds) confirmed: negative and large amount rejected")




# Defines a test that verifies the 'match' parameter of pytest.raises.
def test_match_parameter_raises():

    # Creates a PaymentProcessingClass instance for this test.
    match_parameter_processor = PaymentProcessingClass()

    # Opens a context expecting a ValueError whose message matches the given regex.
    with pytest.raises(
        expected_exception = ValueError,
        match = "amount must be positive"
    ):
        
        # Attempts a charge with a negative amount to trigger the matched error.
        match_parameter_processor.the_charge(the_amount = -299.99)

    
    log.debug("match = parameter confirmed: error message regex matched")




# Defines a test that captures exception details using pytest.raises as a variable.
def test_captures_exception_info_raises():

    # Creates a PaymentProcessingClass instance for this test.
    exception_info_processor = PaymentProcessingClass()

    # Opens a context that captures exception details into 'exception_info'.
    with pytest.raises(
        expected_exception = ErrorFromInsufficientFunds
    ) as exception_info:
        
        # Stores an over-limit amount to use in the charge call.
        a = 1_009_345
        
        # Attempts a charge with the over-limit amount to trigger the error.
        exception_info_processor.the_charge(the_amount = a)

        # Asserts that the captured exception type is the custom error.
        assert exception_info.type is ErrorFromInsufficientFunds

        # Verifies the exception message matches the expected pattern.
        exception_info.match(rf"Amount {a} exceeds single-transaction limit of")

        log.debug(f"ExceptionInfo confirmed: {exception_info.value}")




# Defines a test that verifies exception class hierarchy with pytest.raises.
def test_exception_hierarchy_raises():

    # Creates a ClassThatValidatesData instance for hierarchy checking.
    exception_hierachy_validator = ClassThatValidatesData()


    # Opens a context expecting a ValueError (parent class of the custom error).
    with pytest.raises(ValueError):

        # Passes an invalid email to trigger the custom error as a ValueError.
        exception_hierachy_validator.email_validation(the_Email = 'jesseiscool')

    
    log.debug("Exception hierarchy confirmed: ErrorFromInvalidEmail caught as ValueError")




# ===================================== SEGMENT 2.1: INTRODUCTION TO FIXTURES =====================================



# Declares a basic pytest fixture for a payment processor instance.
@pytest.fixture
# Defines the fixture that returns a fresh PaymentProcessingClass instance.
def fixture_for_processing_payments():

    # Returns a new PaymentProcessingClass to any test that requests it.
    return PaymentProcessingClass()



# Declares a basic pytest fixture for a data validator instance.
@pytest.fixture
# Defines the fixture that returns a fresh ClassThatValidatesData instance.
def fixture_that_validates_data():

    # Returns a new ClassThatValidatesData to any test that requests it.
    return ClassThatValidatesData()




# Declares a fixture that provides a sample list of transactions for batch tests.
@pytest.fixture
# Defines the fixture function that builds the sample transaction data.
def fixture_that_provides_sample_transactions_data():

    # Builds a list of three sample transaction dictionaries.
    data = [
        {
            "amount": 812, 
            "currency": "USD"
        },

        {
            "amount": 258,
            "currency": "EUR"
        },

        {
            "amount": 369,  
            "currency": "GBP"
        },
    ]

    # Returns the sample transaction list to the requesting test.
    return data




# Defines a test that verifies a single fixture can be injected and used.
def test_basic_fixture_injection(fixture_for_processing_payments):

    # Assigns the injected fixture to a local variable for clarity.
    the_payment_processor = fixture_for_processing_payments
    
    # Charges 981 USD using the injected processor instance.
    output = the_payment_processor.the_charge(the_amount = 981)

    # Asserts that the charge result has a 'charged' status.
    assert output['status'] == 'charged'

    log.debug(f"Fixture injected. Result: {output}")




# Defines a test that verifies two fixtures can be injected and used independently.
def test_duplication_elimination_fixture(fixture_for_processing_payments, fixture_that_validates_data):

    # Assigns the payment processor fixture to a local variable.
    payment_processor = fixture_for_processing_payments

    # Assigns the data validator fixture to a local variable.
    data_validator = fixture_that_validates_data


    # Charges 400 USD using the injected processor.
    result_from_charge = payment_processor.the_charge(the_amount = 400)

    # Validates a real email address using the injected validator.
    email_validation = data_validator.email_validation(the_Email = 'workemailaddress73@gmail.com')


    # Asserts that the charge result has the correct amount.
    assert result_from_charge['amount'] == 400

    # Asserts that the email validation returned True.
    assert email_validation is True

    log.debug("Confirmed! Two fixtures resolved independently")




# Defines a placeholder test for the request object fixture concept.
def test_request_object_fixture():

    # Placeholder body; this test has no assertions yet.
    pass




# Declares a fixture that uses the pytest 'request' object for context awareness.
@pytest.fixture
# Defines the fixture that builds a context string containing the calling test's name.
def fixture_for_request_awareness(request):

    log.debug(f"Fixture called by test: {request.node.name}")

    # Builds a context string prefixed with 'context_for_' and the test's name.
    output = f"context_for_{request.node.name}"

    # Returns the context string to the requesting test.
    return output




# Defines a test that verifies the request-aware fixture delivers the expected prefix.
def test_using_fixture_for_request_awareness(fixture_for_request_awareness):

    # Asserts that the fixture value contains the expected prefix string.
    assert 'context_for_' in fixture_for_request_awareness




# ===================================== SEGMENT 2.2: SETUP AND TEARDOWN (YIELD) =====================================



# Declares a fixture that creates a temporary JSON file and cleans it up after the test.
@pytest.fixture
# Defines the fixture function for the temporary report file lifecycle.
def temporary_report_file_creator_fixture(tmp_path):

    # Builds the full path for the temporary JSON report file.
    report_file_path = tmp_path / 'the_payment_report.json'

    # Defines the dictionary content that will be written to the report file.
    the_report_data = {
        "batchID": "TX-001",
        "total": 712,
        "currency": "USD"
    }

    # Writes the serialized report data to the temp file as UTF-8 text.
    report_file_path.write_text(
        data = json.dumps(the_report_data),

        encoding = 'utf-8'
    )

    log.debug(f"SETUP: Created temp report at {report_file_path}")


    # Yields the temp file path to the requesting test.
    yield report_file_path


    # Checks whether the temp file still exists before attempting deletion.
    if report_file_path.exists():

        # Deletes the temporary file as part of fixture teardown.
        report_file_path.unlink()

        log.debug(f"TEARDOWN: Deleted temp report at {report_file_path}")




# Defines a test that reads and verifies content from the yielded temp file.
def test_file_creator_fixture_with_yield(temporary_report_file_creator_fixture):

    # Assigns the injected fixture path to a local variable.
    temp_file = temporary_report_file_creator_fixture

    # Asserts that the temporary file was actually created on disk.
    assert temp_file.exists()

    # Reads and parses the JSON content from the temporary file.
    file_content = json.loads(temp_file.read_text(encoding = 'utf-8'))

    # Asserts that the batchID in the file matches the expected value.
    assert file_content['batchID'] == 'TX-001'

    # Asserts that the total amount in the file matches the expected value.
    assert file_content['total'] == 712

    log.debug(f"Yield fixture confirmed. File content: {file_content}")




# Declares a fixture that wraps a processor with an audit log and yields both.
@pytest.fixture
# Defines the fixture function that instruments the charge method for auditing.
def processor_fixture_with_audit_log():

    # Creates an empty list to record each charge call's arguments.
    audit_log_list = []

    # Creates a fresh PaymentProcessingClass instance.
    the_processor = PaymentProcessingClass()

    # Saves a reference to the original, un-instrumented charge method.
    the_original_charge = the_processor.the_charge

    # Defines an inner wrapper function that logs each charge call.
    def charge_instrumented(
        _amount,
        currency_ = 'USD'
    ):
        
        # Delegates to the original charge method with the provided arguments.
        output = the_original_charge(
            the_amount = _amount,
            
            the_currency = currency_
        )

        # Appends the call's amount and currency to the audit log.
        audit_log_list.append({
            'amount': _amount,
            'currency': currency_
        })

        # Returns the original charge result to the caller.
        return output

    # Replaces the processor's charge method with the instrumented wrapper.
    the_processor.the_charge = charge_instrumented

    # Yields both the instrumented processor and the audit log list to the test.
    yield the_processor, audit_log_list

    log.debug(f"TEARDOWN: Audit log had {len(audit_log_list)} entries.\nclearing...")

    # Clears all entries from the audit log during fixture teardown.
    audit_log_list.clear()




# Defines a test that verifies the audit log fixture records calls correctly.
def test_processor_fixture_with_teardown(processor_fixture_with_audit_log):

    # Unpacks the yielded processor and audit log into named variables.
    PROCESSOR, AuditLog = processor_fixture_with_audit_log

    # Charges 231 USD using the instrumented processor.
    PROCESSOR.the_charge(_amount = 231)

    # Charges 912 NGN using the instrumented processor.
    PROCESSOR.the_charge(_amount = 912, currency_ = 'NGN')

    # Asserts that exactly two charges were recorded in the audit log.
    assert len(AuditLog) == 2

    # Asserts that the first log entry has the correct amount.
    assert AuditLog[0]['amount'] == 231

    log.debug(f"Teardown guarantee confirmed. Audit log: {AuditLog}")




# ===================================== SEGMENT 2.3: FIXTURE SCOPES =====================================


# Declares a module-scoped fixture that simulates sharing an expensive resource.
@pytest.fixture(
    scope = 'module'
)
# Defines the fixture function that creates and tears down a mock connection pool.
def fixture_that_shares_processor_pool():

    log.debug("MODULE-SCOPE SETUP: Simulating expensive connection pool creation...")

    # Builds a fake connection pool dictionary with an embedded processor.
    POOL = {
        'pool ID': 'POOL-213',
        'the_processor': PaymentProcessingClass(),
        'maximum connections': 50
    }

    # Yields the pool dictionary to all tests in the module.
    yield POOL

    log.debug("MODULE-SCOPE TEARDOWN: Closing connection pool...")



# Declares a session-scoped fixture that loads global test configuration once.
@pytest.fixture(
    scope = 'session'
)
# Defines the fixture function that creates and tears down the global config.
def global_config_fixture():

    log.debug("SESSION-SCOPE SETUP: Loading global configuration...")

    # Builds a global configuration dictionary for the test session.
    configuration = {
        'environment': 'test_verification',
        "api version": "v-O1-1.1.3",
        "maximum retries": 12,
    }

    # Yields the configuration to all tests in the session.
    yield configuration

    log.debug("SESSION-SCOPE TEARDOWN: Releasing global config.")




# Defines a first test to confirm the module-scoped pool fixture works correctly.
def test_fixture_that_shares_processor_pool(fixture_that_shares_processor_pool):

    # Asserts that the pool's ID matches the expected value.
    assert fixture_that_shares_processor_pool['pool ID'] == 'POOL-213'

    # Charges 521 USD using the processor embedded in the shared pool.
    output = fixture_that_shares_processor_pool['the_processor'].the_charge(the_amount = 521)

    # Asserts that the charge was successful.
    assert output['status'] == 'charged'
    
    log.debug("Module-scope fixture confirmed (first call).")




# Defines a second test to confirm the module-scoped fixture was NOT re-created.
def test_fixture_that_shares_processor_pool_2(fixture_that_shares_processor_pool): # The fixture was NOT re-created. Setup cost was paid exactly once

    # Asserts that the pool's maximum connections value is still 50.
    assert fixture_that_shares_processor_pool['maximum connections'] == 50

    log.debug("Module-scope fixture confirmed (second call; no re-setup)")




# Defines a test that verifies the session-scoped global config fixture.
def test_global_config_fixture(global_config_fixture):

    # Defines the expected keys to verify in the config dictionary.
    keys = ['environment', 'api version', 'maximum retries']

    # Defines the expected values corresponding to each key.
    values = ['test_verification', 'v-O1-1.1.3', 12]

    # Iterates over each key-value pair using an index.
    for x in range(len(keys)):

        # Asserts that each config value matches the expected value.
        assert global_config_fixture[keys[x]] == values[x]




# Defines a test that reads and asserts on the real conftest.py file content.
def test_the_explanation_of_conftest():

    # Builds the absolute file path to the conftest.py file on disk.
    temporary_path = os.path.join("/home/jesfusion/Documents/ml/ML-Learning-Repository/Pytest/", "conftest.py")

    # Opens the conftest.py file in read mode with UTF-8 encoding.
    with open(temporary_path, "r", encoding = 'utf-8') as the_file:

        # Reads the entire file content into a string variable.
        conftest_py_file = the_file.read()

    # Asserts that the file contains at least one pytest fixture declaration.
    assert 'pytest.fixture' in conftest_py_file

    # Asserts that the file includes at least one fixture scope definition.
    assert 'scope = ' in conftest_py_file




"""
===================================== PYTEST PROJECT STRUCTURE =====================================


   my_project/
    ├── src/
    │   └── myapp/
    │       ├── __init__.py
    │       ├── main.py
    │       └── database.py
    ├── tests/
    │   ├── conftest.py          ← Global fixtures (db_engine, client, app)
    │   ├── unit/
    │   │   ├── conftest.py      ← Unit-test-specific fixtures (mocks, stubs)
    │   │   └── test_validator.py
    │   └── integration/
    │       ├── conftest.py      ← Integration fixtures (real DB session)
    │       └── test_payments.py
    ├── pytest.ini
    └── pyproject.toml
"""




# Defines a test that asserts the fixture dependency chain resolves correctly.
def test_the_chain_of_fixtures(
    fixture_for_payment_repository,
    database_session_fixture,
    database_engine_fixture
):
    
    # Asserts that the repository's session is the exact same object as the session fixture.
    assert fixture_for_payment_repository['session'] is database_session_fixture

    # Asserts that the session fixture is bound to the engine fixture.
    assert database_session_fixture.bind is database_engine_fixture

    # Asserts that the engine fixture has the expected database URL.
    assert database_engine_fixture.url == "postgresql://localhost/test_database"

    # Calls the repository's lookup lambda with a fake transaction ID.
    transaction = fixture_for_payment_repository['FindByID']("TX-1.2-0")

    # Asserts that the returned transaction has the expected hardcoded amount.
    assert transaction['amount'] == 637

    log.debug("""
Dependency chain confirmed!

database_engine_fixture → database_session_fixture → fixture_for_payment_repository

Teardown will execute in REVERSE order: repository → session → engine
""")
    



# Defines a test that intentionally mutates the global dictionary.
def test_global_dictionary_modification():

    # Sets the LastTransactionID in the global dictionary to a test value.
    GLOBAL_DICTIONARY['LastTransactionID'] = 'Trs-2.3.1'

    # Sets the RequestCount in the global dictionary to a test value.
    GLOBAL_DICTIONARY['RequestCount'] = 432

    # Asserts that the mutation was applied correctly.
    assert GLOBAL_DICTIONARY['LastTransactionID'] == 'Trs-2.3.1'

    log.debug(f"State mutated: {GLOBAL_DICTIONARY}")



# Defines a test that verifies the autouse fixture reset the global state.
def test_fixture_that_resets_global_state_resetting_power():

    # Asserts that the LastTransactionID was reset to None by the autouse fixture.
    assert GLOBAL_DICTIONARY['LastTransactionID'] is None

    # Asserts that the RequestCount was reset to zero by the autouse fixture.
    assert GLOBAL_DICTIONARY['RequestCount'] == 0

    log.debug(f"State reset confirmed by autouse fixture: {GLOBAL_DICTIONARY}")




# ===================================== SEGMENT 4.1: @pytest.mark.parametrize DECORATOR =====================================


# Decorates the test with a parametrize marker supplying email/flag pairs.
@pytest.mark.parametrize(
    argnames = 'the_email, ShouldRaise',

    argvalues = [
        ('jesse@mlops.io', False),

        ("user@domain.com", False),

        ('', True),

        (None, True),

        ('bad-email-format', True),

        ("emailwithout@adot", True),
        
        ("@cooldomain.com", False),
        
        ('jesseis+1@today.com', False),
    ],
)

# Defines a parametrized test that checks email validation across multiple cases.
def test_parametrized_email_validation(the_email, ShouldRaise):

    # Creates a fresh ClassThatValidatesData instance for this parametrized case.
    the_validator = ClassThatValidatesData()

    # Checks whether this test case expects an exception to be raised.
    if ShouldRaise:

        # Opens a context expecting either the custom or base ValueError.
        with pytest.raises(
            expected_exception = (ErrorFromInvalidEmail, ValueError)
        ):
            
            # Passes the invalid email to trigger the expected exception.
            the_validator.email_validation(the_Email = the_email)

    # Handles the case where no exception is expected.
    else:

        # Asserts that a valid email returns True.
        assert the_validator.email_validation(the_Email = the_email) is True

    log.debug(f"Tested: {repr(the_email)} → raises = {ShouldRaise}")




# Decorates the test with discount parametrization across 25 price/discount/result cases.
@pytest.mark.parametrize(
    argnames = 'price_of_good, percentage_discount, expected_price',

    argvalues=[
        (100.0, 0, 100.0),
        (100.0, 10, 90.0),
        (200.0, 25, 150.0),
        (99.99, 50, 50.0),
        (100.0, 100, 0.0),
        (50.0, 10, 45.0),
        (80.0, 20, 64.0),
        (150.0, 30, 105.0),
        (300.0, 15, 255.0),
        (10.0, 5, 9.5),
        (1000.0, 1, 990.0),
        (40.0, 40, 24.0),
        (60.0, 60, 24.0),
        (500.0, 75, 125.0),
        (25.0, 10, 22.5),
        (19.99, 0, 19.99),
        (120.0, 50, 60.0),
        (85.0, 10, 76.5),
        (250.0, 20, 200.0),
        (45.0, 100, 0.0),
        (10.0, 50, 5.0),
        (90.0, 10, 81.0),
        (15.0, 20, 12.0),
        (2000.0, 5, 1900.0),
        (1.0, 10, 0.9)
    ],
)




# Defines a parametrized test that verifies the discount calculation across many cases.
def test_parametrized_discount_calculation(
    price_of_good,
    percentage_discount,
    expected_price,
    fixture_that_validates_data
):
    
    # Calls the discount method using the parametrized inputs.
    output = fixture_that_validates_data.calculating_the_discount(
        price = price_of_good,
        discount_pct = percentage_discount
    )

    # Asserts that the computed discount result matches the expected price within 1% tolerance.
    assert output == pytest.approx(
        expected = expected_price,
        rel = 1e-2
    )

    log.debug(f"{price_of_good} - {percentage_discount}% = {output} (expected {expected_price})")




# ===================================== SEGMENT 4.2: STACKING PARAMETRIZATION (CARTESIAN PRODUCTS) =====================================


# First parametrize decorator supplying four currency values.
@pytest.mark.parametrize(
    argnames = 'TheCurrency',

    argvalues = ['USD', 'NGN', 'EUR', "GBP"]
)



# Second parametrize decorator supplying three amount values, creating 12 combinations.
@pytest.mark.parametrize(
    argnames = 'money_amount',

    argvalues = [300, 4500, 5320]
)




# Defines a test that verifies all 12 currency-amount combinations produce valid charges.
def test_all_currency_amount_combinations(TheCurrency, money_amount):

    # Creates a fresh PaymentProcessingClass instance for this combination.
    currency_combination_processor = PaymentProcessingClass()

    # Charges the parametrized amount in the parametrized currency.
    the_result = currency_combination_processor.the_charge(
        the_amount = money_amount,

        the_currency = TheCurrency
    )

    # Defines the expected keys to check in the charge result.
    keys = ['status', 'amount', 'currency']

    # Defines the expected values corresponding to each key.
    values = ['charged', money_amount, TheCurrency]

    # Iterates over each key-value pair using an index.
    for x in range(len(keys)):

        # Asserts that the result value for each key matches the expected value.
        assert the_result[keys[x]] == values[x]

    log.debug(f"Cartesian case: amount = {money_amount}, currency = {TheCurrency}")




# ===================================== SEGMENT 4.3: DYNAMIC IDs =====================================




# Decorates the test with parametrize using pytest.param to assign human-readable IDs.
@pytest.mark.parametrize(
    argnames = 'TheAmount, Error, Description',

    argvalues = [
        # pytest.param(*values, id="description")

        # Defines a valid amount test case with a descriptive ID.
        pytest.param(
            231, None, 'Valid Amount value',

            id = 'Valid amount value'
        ),

        # Defines a zero-amount test case expected to raise a ValueError.
        pytest.param(
            0, ValueError, 'Zero Amount. Should be rejected',

            id = 'Zero amount. Should be rejected'
        ),

        # Defines a negative-amount test case expected to raise a ValueError.
        pytest.param(
            -1, ValueError, 'Negative Amount. Should be rejected',

            id = 'Negative Amount. Should be rejected'
        ),

        # Defines an over-limit amount test case expected to raise the custom error.
        pytest.param(
            23456, ErrorFromInsufficientFunds, 'Amount higher than set limit',

            id = "Amount higher than set limit"
        )
    ]
)




# Defines a parametrized test that checks charge behavior with human-readable IDs.
def test_charge_functions_with_parametrized_dynamic_IDs(
    TheAmount,
    Error,
    Description
):
    
    # Creates a fresh PaymentProcessingClass instance for this parametrized case.
    dynamic_id_processor = PaymentProcessingClass()

    # Handles the case where no exception is expected.
    if Error is None:

        # Charges the valid amount and stores the result.
        output = dynamic_id_processor.the_charge(
            the_amount = TheAmount
        )

        # Asserts that the charge was successful.
        assert output['status'] == 'charged'

    # Handles the case where a specific exception is expected.
    else:

        # Opens a context expecting the parametrized exception type.
        with pytest.raises(expected_exception = Error):

            # Attempts the charge to trigger the expected exception.
            dynamic_id_processor.the_charge(the_amount = TheAmount)

    log.debug(f"Dynamic ID case '{Description}' passed")




# ===================================== SEGMENT 5.1: BUILT-IN MARKERS (skip, skipif, xfail) =====================================


# skipping a test...
# Marks this test to be unconditionally skipped with a descriptive reason.
@pytest.mark.skip(
    reason = 'Placeholder: FX rate API credentials not yet configured in CI'
)


# Defines a test for live exchange rate fetching that is currently skipped.
def test_live_exchange_rate_fetching():

    # Calls the live exchange rate function to fetch the USD → EUR rate.
    output = exchange_rate_fetching(
        Bcurrency = 'USD',
        Tcurrency = 'EUR'
    )

    # Asserts that a positive rate was returned.
    assert output > 0




# skipping a test if a condition is met...

# Marks this test to be skipped conditionally when running on Windows.
@pytest.mark.skipif(
    condition = sys.platform == 'win32',
    # condition = sys.platform == 'linux',

    reason = "File path handling test is Unix-specific; skipped on Windows"
)


# Defines a test for Unix-specific file path handling behavior.
def test_file_path_handling_on_unix(tmp_path):

    # Builds a nested Unix file path inside the temporary directory.
    unix_file_path = tmp_path / 'reports' / 'log_output.json'

    # Creates all parent directories in the path, ignoring existing ones.
    unix_file_path.parent.mkdir(
        parents = True,
        exist_ok  = True
    )

    # Writes a minimal JSON string to the file at the created path.
    unix_file_path.write_text(
        data = '{"status": "ok"}',

        encoding = 'utf-8'
    )

    # Asserts that the file was successfully created on disk.
    assert unix_file_path.exists()

    log.debug(f"Unix path test passed on {sys.platform}")




# this test is expected to fail...


# Marks this test as expected to fail, allowing it to be reported without blocking the suite.
@pytest.mark.xfail(
    # Reports 'x' (xfailed) when it fails, 'X' (xpassed) if it suddenly passes which is a signal to remove the mark.

    reason = 'IS_JESSE_COOL() function is meant to return "True"',

    strict = False
)


# Defines an xfail test that checks the IS_JESSE_COOL function's return value.
def test_xfail_capabilities():

    # Asserts that IS_JESSE_COOL returns True.
    assert IS_JESSE_COOL() is True

    log.debug("xfail test ran successfully!")




# Marks this test as expected to fail specifically with the custom insufficient funds error.
@pytest.mark.xfail(
    raises = ErrorFromInsufficientFunds,

    reason = 'Refund above limit should trigger ErrorFromInsufficientFunds; behavior TBD',

    strict = False
)




# Defines an xfail test that attempts a refund with an amount above the transaction limit.
def test_xfail_with_raises():

    # Creates a PaymentProcessingClass instance for this xfail test.
    xfail_with_raises_processor = PaymentProcessingClass()

    # Attempts a refund with an amount far above any limit to provoke the expected error.
    xfail_with_raises_processor.refund_money(
        transactionID = 'TX-023',
        the_amount = 89322
    )

    log.debug("xfail with raises = filter confirmed")




# ===================================== SEGMENT 5.2: CUSTOM MARKERS =====================================



# Marks this test with the custom 'slow' marker to identify it as a long-running test.
@pytest.mark.slow
# Defines a slow test that verifies batch processing using fixtures.
def test_batch_processing_slow_fixture(
    fixture_for_processing_payments,
    fixture_that_provides_sample_transactions_data
):
    
    # Assigns the injected processor fixture to a local variable.
    the_payment_processor = fixture_for_processing_payments

    # Runs batch processing on the sample transaction data.
    output = the_payment_processor.batch_processing(
        the_transactions = fixture_that_provides_sample_transactions_data
    )

    # Asserts that all three transactions were processed.
    assert len(output) == 3

    # Asserts that every transaction result has a 'charged' status.
    assert all(x['status'] == 'charged' for x in output)

    log.debug(f"@slow test passed. {len(output)} transactions processed")




# Marks this test with the custom 'integration' marker.
@pytest.mark.integration
# Defines an integration test that performs a full charge-then-refund cycle.
def test_integration_custom_marker(fixture_for_processing_payments):

    # Charges 431 USD and stores the result.
    CHARGE = fixture_for_processing_payments.the_charge(the_amount = 431)

    # Issues a refund for the same amount using the stored transaction ID.
    refund_receipt = fixture_for_processing_payments.refund_money(
        the_amount = CHARGE['amount'],

        transactionID = 'TX-891'
    )

    # Asserts that the refund result has a 'refunded' status.
    assert refund_receipt['status'] == 'refunded'

    # Asserts that the refunded amount matches the original charge amount.
    assert refund_receipt['amount'] == 431

    log.debug(f"@integration test passed. Refund: {refund_receipt}")




# Marks this test as both 'slow' and parametrized with per-case marks.
@pytest.mark.slow
# Applies parametrization with three cases, one of which is marked xfail.
@pytest.mark.parametrize(
    argnames = 'input_value',

    argvalues = [
        # Defines a valid parametrized case with a descriptive ID.
        pytest.param(
            320,
            id = 'valid number: 320'
        ),

        # Defines an invalid (very negative) parametrized case with a descriptive ID.
        pytest.param(
            -32019,
            id = 'invalid number: -32019'
        ),

        # Defines an invalid parametrized case that is additionally marked xfail.
        pytest.param(
            -23,
            id = 'invalid number: -23',
            marks = pytest.mark.xfail
        )
    ]
)



# Defines a slow and parametrized test that checks both valid and error-triggering amounts.
def test_slow_and_parametrize_markers(input_value):

    # Creates a fresh PaymentProcessingClass instance for each parametrized case.
    slow_and_parametrize_processor = PaymentProcessingClass()

    # Checks whether the input value falls below the invalid threshold.
    if input_value < -24:

        # Opens a context expecting a ValueError for negative amounts.
        with pytest.raises(
            expected_exception = ValueError,

            match = 'Charge amount must be positive'
        ):
            
            # Attempts a charge with the negative amount to trigger the error.
            output = slow_and_parametrize_processor.the_charge(the_amount = input_value)

    # Handles the case where the input value is a valid charge amount.
    else:

        # Charges the valid input amount and stores the result.
        output = slow_and_parametrize_processor.the_charge(the_amount = input_value)

        # Asserts that the charge was successful.
        assert output['status'] == 'charged'

    log.debug(f"Parametrized case with per-case mark passed: amount = {input_value}")




# ===================================== SEGMENT 5.3: PYTEST.INI/PYPROJECT.TOML CONFIGURATION =====================================


"""
# Main entry point for pytest configuration in pyproject.toml
[tool.pytest.ini_options]


# Default CLI flags:
# -v: verbose output
# -s: allow print statements to show in console (shortcut for --capture=no)
# -m 'code_to_run': ONLY runs tests with this marker by default (be careful!)
# --tb=short: shows only a one-line traceback for failures
# --strict-markers: errors out if you use a marker not registered below

# because you included -m 'code_to_run' in addopts, pytest will only run tests with that marker every time you type the pytest command

# If you try to run a different test or a different marker, it will likely result in "No tests ran."

addopts = "-vsm 'code_to_run' --tb=short --strict-markers" 

# Tells pytest to only look inside this specific file for tests
testpaths = ["test_functions.py"]

# Registered markers to prevent "Unknown mark" warnings
markers = [
    "code_to_run: specific tests I want to run (Segment 6.1 and below)",

    "slow: Tests that make real network calls or process large datasets (>1s)",

    "integration: Tests that require live service infrastructure (DB, Redis, S3)",

    "gpu: Tests that require a CUDA-capable GPU to run",
    "flaky: Tests known to be non-deterministic: quarantined for investigation"
]

"""




# Defines a trivial test that always passes.
def test_jesse():

    log.debug("Jesse is cool")

    # Asserts an unconditional True value — this test always passes.
    assert True

    log.debug("Jesse is so cool")




# ===================================== SEGMENT 6.1: THE unittest.mock LIBRARY =====================================




# Defines a test that demonstrates basic Mock creation and call verification.
def test_unittest_mock():

    # Creates a Mock object representing a payment gateway.
    outlet = Mock(
        name = 'GatewayForPayment'
    )

    # Calls the mock's post method with a fake endpoint and payload.
    output = outlet.post(
        endpoint = '/charge',

        payload = {
            'amount': 521
        }
    )

    # Asserts that the post method was called at least once.
    assert outlet.post.called

    # Asserts that the post method was called exactly once.
    assert outlet.post.call_count == 1

    log.info(f"Mock.post called: {outlet.post.called}, count: {outlet.post.call_count}")




# Defines a test that verifies MagicMock supports the context manager protocol.
def test_MagicMock():

    # Creates a MagicMock representing a file handler.
    mock_file = MagicMock(
        name = 'FileHandler'
    )

    # Enters the mock as a context manager to simulate a 'with' block.
    with mock_file as mock_handler:

        # Writes fake binary data through the mock handler inside the context.
        mock_handler.write(b"payment data")

    
    # Asserts that __enter__ was called exactly once when entering the 'with' block.
    mock_file.__enter__.assert_called_once()

    # Asserts that __exit__ was called exactly once when leaving the 'with' block.
    mock_file.__exit__.assert_called_once()

    log.info("MagicMock __enter__/__exit__ confirmed: context manager protocol works")




# Defines a test that verifies mocking isolates the code under test from real network calls.
def test_isolation_speed_cost_of_mocking(tmp_path):

    # Creates a MagicMock to stand in for the real payment gateway.
    outlet = MagicMock(name = 'FakeGateway')

    # Configures the mock's charge method to return a fake gateway response.
    outlet.charge.return_value = {
        'gateway_ref': 'GW-925',

        'approved': False
    }

    # Calls the notification function with the mock gateway injected.
    output = gateway_payment_notification(
        transID = 'TX-301',

        the_amount = 891,

        the_gateway_client = outlet
    )

    # Asserts that the notification function returned True on success.
    assert output is True

    # Asserts that the mock's post method was called exactly once.
    outlet.post.assert_called_once()

    log.info("Isolation confirmed: gateway called without real network")




# ===================================== SEGMENT 6.2: PATCHING — THE ART OF REPLACEMENT =====================================




# Applies the @patch decorator to replace requests_lib.get with a mock for this test.
@patch(
    target = 'test_functions.requests_lib.get'
)

# Defines a test that verifies @patch injects a mock and intercepts the HTTP call.
def test_the_patch_decorator(mock_acquisition):

    # Builds the fake API response data the mock will return.
    output_data = {
        'rates': {
            'EUR': 0.2578
        }
    }

    # Configures the mock's return value chain to deliver the fake response.
    mock_acquisition.return_value.json.return_value = output_data

    # Calls the exchange rate function, which now uses the patched mock.
    the_rate = exchange_rate_fetching(
        Bcurrency = 'USD',

        Tcurrency = 'EUR'
    )

    # Asserts that the returned rate matches the value set in the mock.
    assert the_rate == 0.2578

    # Verifies the mock was called once with exactly the expected arguments.
    mock_acquisition.assert_called_once_with(
        url = 'https://api.exchangerate.host/latest',

        params = {
            'base': 'USD',

            'symbols': 'EUR'
        },

        timeout = 5
    )

    log.info(f"@patch decorator confirmed. Rate returned: {the_rate}. Patched at 'test_megabatch.requests_lib.get' (Importer's Rule)")




# Defines a test that demonstrates using patch() as a context manager.
def test_the_context_management_abilities_of_patch():

    # Opens the patch context manager to replace requests_lib.get for this block.
    with patch(
        target = 'test_functions.requests_lib.get'
    ) as get_the_mock:
        
        # Configures the context mock to return a fake GBP rate response.
        get_the_mock.return_value.json.return_value = {
            'rates': {
                'GBP': 0.79
            }
        }

        # Calls the exchange rate function inside the patch context.
        the_rate = exchange_rate_fetching(
            Bcurrency = 'USD',
            Tcurrency = 'GBP'
        )

        # Asserts that the returned rate matches the mocked value.
        assert the_rate == 0.79

        log.info(f"patch() context manager confirmed. GBP rate: {the_rate}")

        log.info('Patch exited. Real requests_lib.get is now restored')




# Defines a test that demonstrates using patch.object to replace a method on an instance.
def test_direct_patch_object():

    # Creates a PaymentProcessingClass instance whose method will be patched.
    direct_patch_object_processor = PaymentProcessingClass()

    # Patches the_charge method on the specific instance using patch.object.
    with patch.object(
        target = direct_patch_object_processor,

        attribute = 'the_charge'
    ) as the_mock_charge:
        
        # Configures the patched method to return a fake mocked charge result.
        the_mock_charge.return_value = {
            'operation': 'charge that was mocked!',

            'amount': 819
        }

        # Calls the now-patched charge method with a test amount.
        output = direct_patch_object_processor.the_charge(the_amount = 587)

        # assert output['operation'] == 'charge that was mocked!'

        # Asserts that the word 'mocked' appears in the returned operation string.
        assert 'mocked' in output['operation']

        log.info(f"patch.object() confirmed: {output}")




# ===================================== SEGMENT 6.3: INSPECTING CALLS =====================================



# Defines a test that verifies assert_called_once() on a gateway mock.
def test_the_verification_of_assert_being_called_once():

    # Creates a MagicMock representing the client gateway.
    the_gate = MagicMock(name = 'TheClientGateway')

    # Calls the notification function to trigger a single post call on the mock.
    gateway_payment_notification(
        transID = 'TX-482',
        the_amount = 925,
        the_gateway_client = the_gate
    )

    # Asserts that the gateway's post method was called exactly once.
    the_gate.post.assert_called_once()

    log.info('assert_called_once() confirmed: gateway.post called exactly once')




# Defines a test that verifies the exact arguments passed to the mock's post method.
def test_assertion_being_called_once_with_exact_arguments():

    # Creates a MagicMock representing the client gateway.
    the_gateway = MagicMock(name = "TheClientGateway")

    # Stores a transaction ID string in a variable for reuse in assertions.
    t = 'TX-839'

    # Calls the notification function with the test transaction ID and amount.
    gateway_payment_notification(
        transID = t,

        the_amount = 219,

        the_gateway_client = the_gateway
    )

    # Asserts the mock's post was called once with precisely the expected arguments.
    the_gateway.post.assert_called_once_with(
        endpoint = '/notify',

        payload = {
            'transaction_id': t,
            "amount": 219
        }
    )

    log.info('assert_called_once_with() confirmed: arguments verified')




# Defines a test that verifies the gateway post is NOT called when validation fails.
def test_that_assertion_is_not_called_on_the_event_of_a_validation_failure():

    # Creates a MagicMock representing the client gateway.
    the_gateway = MagicMock(name = "TheClientGateway")

    # Opens a context expecting a ValueError due to the empty transaction ID.
    with pytest.raises(
        expected_exception = ValueError
    ):
        
        # Calls the notification function with an empty transID to trigger the error.
        gateway_payment_notification(
            transID = '',

            the_amount = 462,

            the_gateway_client = the_gateway
        )
    
    # Asserts that the gateway's post method was never called due to the early failure.
    the_gateway.post.assert_not_called()

    log.info('assert_not_called() logic confirmed: gateway not contacted on invalid input')




# Defines a test that verifies call_count and call_args_list after multiple gateway calls.
def test_the_call_count_and_call_argument_list():

    # Creates a MagicMock representing the client gateway.
    the_gateway = MagicMock(name = 'TheClientGateway')

    # Stores the total number of notification calls to make.
    call_times = 12

    # Loops 12 times to invoke the notification function with incremental values.
    for loop in range(call_times):

        # Calls the notification function with a computed transaction ID and amount.
        gateway_payment_notification(
            transID = f"TX-{(loop * 23) + 45}",

            the_amount = (loop * 5) ** 2,

            the_gateway_client = the_gateway
        )

    
    # Asserts that the mock's post was called exactly 12 times.
    assert the_gateway.post.call_count == call_times

    # Initializes an empty list to build the expected call objects.
    expected_calls_list = []

    # Iterates to construct the expected call object for each of the 12 invocations.
    for x_call in range(call_times):
        
        # Builds a call object matching the exact arguments used in each loop iteration.
        a_call = call(
            endpoint = '/notify',

            payload = {
                'transaction_id': f"TX-{(x_call * 23) + 45}",

                "amount": (x_call * 5) ** 2
            }
        )

        # Appends the expected call object to the verification list.
        expected_calls_list.append(a_call)

    
    # Asserts that the recorded call list exactly matches the expected call list.
    assert the_gateway.post.call_args_list == expected_calls_list

    log.info(f"""
call_count = {the_gateway.post.call_count}

call_args_list = {(the_gateway.post.call_args_list)[:3]}
    
call_args_list verified
""")




# ===================================== SEGMENT 7.1: MOCKING RETURN VALUES & SIDE EFFECTS =====================================




# Patches requests_lib.get to test return_value configuration.
@patch(
    target = 'test_functions.requests_lib.get'
)
# Defines a test that verifies setting a specific return value on a mock.
def test_the_value_from_mock_return(fake_data_mock):
    
    # Configures the mock to return a fake JPY exchange rate.
    fake_data_mock.return_value.json.return_value = {
        'rates': {
            'JPY': 156.89
        }
    }

    # Calls the exchange rate function, which consumes the mocked return value.
    output_rate = exchange_rate_fetching(
        Bcurrency = 'USD',
        Tcurrency = 'JPY'
    )

    # Asserts that the returned rate matches the value configured on the mock.
    assert output_rate == 156.89

    log.info(f'return_value confirmed: USD → JPY rate = {output_rate}')




# Patches requests_lib.get to test iterable side_effect behavior.
@patch(
    target = 'test_functions.requests_lib.get'
)
# Defines a test that verifies a mock's side_effect can return different values per call.
def test_iterable_side_effect_of_mock(mock):

    # Defines a list of three expected rate values for sequential calls.
    value_list = [.97, .32, 1.320]

    # Sets the mock's side_effect to a list of three different JSON response bodies.
    mock.return_value.json.side_effect = [
        {
            'rates': {
                'EUR': value_list[0]
            }
        },

        {
            'rates': {
                'EUR': value_list[1]
            }
        },

        {
            'rates': {
                'NGN': value_list[2]
            }
        }
    ]


    # Makes the first exchange rate call, consuming the first side_effect value.
    first_rate = exchange_rate_fetching(
        Tcurrency = 'EUR',
        Bcurrency = 'NGN'
    )

    # Makes the second exchange rate call, consuming the second side_effect value.
    second_rate = exchange_rate_fetching(
        Bcurrency = 'GHN',
        Tcurrency = 'EUR'
    )

    # Makes the third exchange rate call, consuming the third side_effect value.
    third_rate = exchange_rate_fetching(
        Bcurrency = 'USD',
        Tcurrency= 'NGN'
    )

    # Collects all three results into a list for bulk assertion.
    rates = [first_rate, second_rate, third_rate]

    
    # Iterates over each result and its corresponding expected value.
    for x in range(len(rates)):

        # Asserts that each returned rate matches the expected value at that index.
        assert rates[x] == value_list[x]

    
    # Asserts that the mock was called exactly three times in total.
    assert mock.call_count == len(rates)

    log.info(f'side_effect iterable confirmed: {first_rate} → {second_rate}')




# Patches requests_lib.get to test side_effect raising an exception.
@patch(
    target = "test_functions.requests_lib.get" 
)
# Defines a test that verifies a mock can raise an exception via side_effect.
def test_raises_exception_mock_side_effect(the_mock):

    # Configures the mock to raise a ConnectionError when called.
    the_mock.side_effect = ConnectionError('The API service is unavailable')

    # Opens a context expecting a ConnectionError with a matching message.
    with pytest.raises(
        expected_exception = ConnectionError,

        match = 'service is unavailable'
    ):
        
        # Calls the exchange rate function, which should now trigger the mock's exception.
        exchange_rate_fetching(
            Bcurrency = 'USD',
            Tcurrency = 'NGN'
        )

    log.info('ide_effect Exception confirmed: ConnectionError raised on demand')

    # mock.side_effect = None  clears a previously set side_effect, restoring the mock to using return_value




# Patches requests_lib.get to test a mixed sequence of return values and exceptions.
@patch(
    target = 'test_functions.requests_lib.get'
)
# Defines a test that verifies a mock side_effect can mix successes and exceptions.
def test_mixed_sequence_format_of_mock_side_effect(jesse_mock):

    # Builds a list mixing two dict responses and one RuntimeError for the side_effect.
    increment_values = [
        {
            'rates': {
                'EUR': 1.95
            }
        },

        # Places a RuntimeError as the second item, simulating a mid-sequence failure.
        RuntimeError('Time limit reached!'),

        {
            'rates': {
                'NGN': 0.87
            }
        },
    ]

    # Sets the mock's side_effect to the mixed sequence list.
    jesse_mock.return_value.json.side_effect = increment_values


    # Makes the first call, which consumes the first dict and returns the EUR rate.
    first_rate = exchange_rate_fetching(
        Bcurrency = 'USD',

        Tcurrency = 'EUR'
    )

    # Asserts that the first rate matches the EUR value in the first list item.
    assert first_rate == increment_values[0]['rates']['EUR']


    # Opens a context expecting the RuntimeError from the second side_effect item.
    with pytest.raises(
        expected_exception = RuntimeError
    ):
        
        # Makes the second call, which triggers the RuntimeError in the sequence.
        exchange_rate_fetching(
            Bcurrency = 'USD',
            Tcurrency = 'GHN'
        )

    
    # Makes the third call, which consumes the third dict and returns the NGN rate.
    second_rate = exchange_rate_fetching(
        Bcurrency = 'EUR',

        Tcurrency = 'NGN'
    )


    # Asserts that the third call's rate matches the NGN value in the third list item.
    assert second_rate == increment_values[2]['rates']['NGN']


    log.info('Mixed side_effect sequence confirmed: success then failure then success again')
    




# ===================================== SEGMENT 7.2: MOCKING ASYNC FUNCTIONS =====================================



# Defines a synchronous test that manually runs an inner async function using asyncio.run.
def test_async_functions():

    # Defines an inner coroutine to be executed by asyncio.run.
    async def async_function_inside_test_function():

        # Creates an AsyncMock to simulate an async HTTP client.
        HTTPCLEINT = AsyncMock(
            name = 'AsyncHTTPClientMock'
        )

        # Defines the expected user profile output the mock should return.
        output = {
            'id': 'TX-3372',

            'name': 'Jesse the Tester',

            'role': "MLOps Engineer"
        }

        # Configures the mock's get method to return the fake profile output.
        HTTPCLEINT.get.return_value = output

        # Awaits the async profile fetch, passing the mock client for injection.
        the_result = await fetch_user_profile_async(
            uID = output['id'],

            HTTP_clt = HTTPCLEINT
        )

        log.info(the_result)

        
        # Asserts that the returned profile ID matches the expected value.
        assert the_result['id'] == output['id']

        # Asserts that the returned profile name matches the expected value.
        assert the_result['name'] == output['name']

        # Verifies the mock's get method was called once with the correct user URL.
        HTTPCLEINT.get.assert_called_once_with(
            url = f"/users/{output['id']}"
        )

        log.info(f'AsyncMock confirmed: coroutine awaited cleanly. Result: {the_result}')

    
    # Runs the inner async function to completion using the asyncio event loop.
    asyncio.run(main = async_function_inside_test_function())




# Marks this test as an async pytest test using the asyncio plugin.
@pytest.mark.asyncio
# Defines an async test that verifies an AsyncMock can raise an exception via side_effect.
async def test_side_effect_of_async_mock_raises():

    # Creates an AsyncMock representing an async HTTP client.
    the_http_client = AsyncMock(name = 'TheAsyncHTTPClient')

    # Configures the mock's get method to raise a TimeoutError when awaited.
    the_http_client.get.side_effect = TimeoutError('Async request timed out')

    # Opens a context expecting a TimeoutError with a matching message.
    with pytest.raises(expected_exception = TimeoutError,
    match = 'timed out'):
        # Awaits the async profile fetch, which should now raise the TimeoutError.
        await fetch_user_profile_async(uID = 34,
        HTTP_clt = the_http_client)

    log.info(msg = "AsyncMock side_effect exception confirmed")




# Marks this test as an async pytest test.
@pytest.mark.asyncio
# Patches the async function itself with an AsyncMock using new_callable.
@patch(
    target = 'test_functions.fetch_user_profile_async',
    new_callable = AsyncMock
)
# Defines an async test verifying that @patch works correctly with AsyncMock.
async def test_async_function_patching_with_async_mock(async_mock_fetch):
    #... [HOW]  new_callable=AsyncMock tells patch() to create an AsyncMock instead of
    #...        the default MagicMock — critical for patching coroutine functions.
    # mock_fetch.return_value = {"id": 7, "name": "Patched User", "role": "tester"}

    # Configures the patched async function to return a fake user profile.
    async_mock_fetch.return_value = {
        'id': 6,
        'name': 'Patched Async User',
        'role': 'code tester'
    }

    # Awaits the patched function, which returns the configured fake profile.
    output = await fetch_user_profile_async(uID = 6)

    # Asserts that the name in the returned profile matches the patched value.
    assert output['name'] == 'Patched Async User'

    # Verifies the patched mock was called exactly once with the correct user ID.
    async_mock_fetch.assert_called_once_with(uID = 6)

    log.info(msg = f'@patch() with new_callable = AsyncMock confirmed: {output}')




# Marks this test with a custom 'jesse' marker.
@pytest.mark.jesse
# Defines a test demonstrating in-test FastAPI route definition and TestClient usage.
def test_demo_of_FastAPI_TestClient():
    
    # Imports fastapi, skipping this test if the package is not installed.
    f_api = pytest.importorskip(
        modname = 'fastapi', 
        reason = 'fastapi module may not be installed'
    )

    # Creates a new FastAPI application instance for this test.
    f_app = FastAPI()    

    # Registers a GET route on the app for retrieving a payment by ID.
    @f_app.get(path = '/payments/{payment_id}')
    # Defines the handler function for the GET /payments/{payment_id} route.
    def extract_payment(payment_id: int):

        # Builds a fake payment response dictionary using the provided ID.
        output = {
            'id': payment_id,
            'status': 'charged',
            'amount': 463
        }

        # Returns the fake payment response.
        return output

    # Registers a POST route on the app for creating a new payment.
    @f_app.post(path = '/payments/')
    # Defines the handler function for the POST /payments/ route.
    def payment_creation(
        the_amount: float,
        the_currency: str = 'USD'
    ):
        # Checks whether the provided amount is zero or negative.
        if the_amount <= 0:
            # Raises an HTTP 422 error if the amount is not positive.
            raise HTTPException(status_code = 422, detail = "Amount must be positive")
        
        # Builds a successful payment creation response dictionary.
        output = {
            'id': 1, 
            'status': 'charged', 
            'amount': the_amount,
            'currency': the_currency
        }
        
        # Returns the payment creation response.
        return output

    # Wraps the in-test FastAPI app with a TestClient for making test requests.
    the_client = TestClient(app = f_app)

    # Sends a GET request to retrieve payment with ID 681.
    get_response = the_client.get('/payments/681')

    # Asserts the GET request returned a 200 OK status.
    assert get_response.status_code == 200

    # Asserts that the returned payment ID matches the requested ID.
    assert get_response.json()['id'] == 681

    # Sends a POST request to create a payment with amount 561 NGN.
    post_response = the_client.post(url = '/payments/', 
    params = {
        'the_amount': 561,
        'the_currency': 'NGN'
    })

    # Asserts the POST request returned a 200 OK status.
    assert post_response.status_code == 200

    # Asserts that the returned payment status is 'charged'.
    assert post_response.json()['status'] == 'charged'

    # Sends an invalid POST request with a negative amount to trigger the 422 error.
    post_error_response = the_client.post(
        '/payments/',
        params = {
            'amount': -10.0
        }
    )

    # Asserts the invalid POST request correctly returned a 422 Unprocessable Entity status.
    assert post_error_response.status_code == 422

    log.info(msg = 'FastAPI TestClient confirmed: GET 200, POST 200, POST 422')








