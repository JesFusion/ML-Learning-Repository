import time
import pytest
import numpy as np
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
    assert validate_email(user) == True


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
    assert result == True


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













