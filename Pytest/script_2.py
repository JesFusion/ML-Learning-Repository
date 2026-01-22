import time
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









