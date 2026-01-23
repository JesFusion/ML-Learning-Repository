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








