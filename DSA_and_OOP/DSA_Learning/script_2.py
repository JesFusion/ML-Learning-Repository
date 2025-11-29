import random
import time


print("\n============================= Practicing Python's Built-in Data Structures =============================\n")

# let's practice the different data structures python provided us...

# 1. Lists:
# Lists are ordered, changeable and allows duplicate values

a_list = ["Jesse", "Favour", "Caleb"]

print(f'''
============================= Lists =============================

Original List: {a_list}

First Item (Index 0): {a_list[0]}
''')

# let's change the last Item

a_list[-1] = "Goodness"

# add a new item...

a_list.append("Chiedozie")
a_list.append("Jesse")

print(f'Final List: {a_list}')



# 2. Tuples:
# Tuples are ordered, unchangeable and allows duplicates

a_tuple = (10, 30, 40, 45, 67)

print(f'''
Original Tuple: {a_tuple}

First Item (index 0): {a_tuple[0]}
''')

# let's try to change the tuple...

try:
    a_tuple[1] = 39 # this will fail and flag an error, which we'll handle below

except TypeError as an_error:

    print(f"Told ya! The tuple can't be changed --> \"{an_error}\"")


# 3. Dictionaries:

# dictionaries store data in pairs (e.g --> "name": "Jack Ma"), enable fast lookups through "keys" and are changeable



# let's create a dictionary using my student data...

user_info = {
    "Name": "Nwachukwu Jesse",

    "Age": 19,

    "Department": "Mechatronics Engineering",

    "Reg. No": "20221329023"
}


print(f'''
Original Dictionary: {user_info}

Student Department: {user_info['Department']}
''')

# changing a value
user_info["Age"] = 20

# adding a new pair

user_info['Gender'] = "Male"

print(f"Final Dictionary: {user_info}")



# 4. Sets

# sets are unordered, changeable and don't allow duplicates


# let's try creating a set from a list that has duplicates and see what would happen

t_list = ["Enugu", "Anambra", "Ebonyi", "Lokoja", "Lekki", "Enugu", "Lekki"]

a_set = set(t_list) # all duplicates will be removed the moment it's converted to a set

print(f'''
Original List with duplicates: {t_list}

List converted to set (duplicates removed): {a_set}
''')

# let's check if "Enugu" is in the set

status = "Enugu" in a_set


print(f'''
Is "Enugu" in the set? {status}

Is "Zamfara" in the set? {"Zamfara" in a_set}
''')


# we can add new items to sets
a_set.add("Zamfara")

a_set.remove("Enugu") # "remove" raises an error if the item to be removed doesn't exist in the set initially


a_set.discard("Kano") # "discard" does nothing if the item to be removed doesn't exist in the set initially


print(f'''
Final Set after adding and removing items: {a_set}
''')







































































# ==> Big O Analysis


# O(1) --> Constant Time
def ac_first_item(a_list: list) -> str:

    # This function returns the first item from a list

    if not a_list:
        return None
    
    return a_list[0] # this returns the first item of any list


S_list = [True, "a", "f", 4.5]

L_list = list(range(1000000))

# it takes the same amount of time to get the first item from the small and large list

print(f'''
============================= O(1) --> Constant Time =============================
First Item from small list: {ac_first_item(S_list)}

First Item from large list: {ac_first_item(L_list)}
''')


# O(2) --> Linear Time

# here the runtime grows linearly with the number of inputs. As input size increases, the run time increases

def item_find_in_list(a_list: list, find_item):

    """Searches a list for an item by checking one by one.
    This is called a "Linear Search."
    """

    # go through each element of the list one by one. If you find the item, return True. If not, return False

    # Notice we didn't use an else statement for returning False. This is because when the for loop returns True, it immediately exits the function 

    for an_item in a_list:

        if an_item == find_item:

            return True

    return False # return false if you didn't find anything

s_t_s = time.time()

print(f'''
============================= O(n) --> Linear Time =============================

Searching small list (n = {len(S_list)}): {item_find_in_list(S_list, 4.5)}
''')

s_t_e = time.time()

print(f"Searching large list (n = {len(L_list)}): {item_find_in_list(L_list, -1)}")

l_t_e = time.time()


print(f'''
Small list time duration: {s_t_e - s_t_s}

Large list time duration: {l_t_e - s_t_e}
''') # notice that the larger list took a longer time to go through it entirely. It may be a fraction of a second, but when handling large databases, it'll take longer than that











































































# Space Complexity Analysis


# 1. O(1) Space - Constant Space

def sum_calc(the_list: list) -> int:

    total_num = 0

    for a_number in the_list:

        total_num += a_number

    return int(total_num) # it just outputs one variable, which means  constant space


# 2. O(n) Space --> Linear Space
# memory usage grows linearly with input

def l_element_double_list(the_list: list) -> list:

    list_of_double = []

    for number in the_list:

        list_of_double.append(number * 2)

    return list_of_double


# ============================= example of space-time trade off =============================

"""
Note:
- Low space, more time for algorithm to sun
- High space, less time for algorithm to sun
"""

# let's test this out by building a slow and fast algorithm for look for an element in a list

def s_check(the_list: list, the_element): # s_check means slow check

    return the_element in the_list


def f_check(the_list): # f_check means fast check. It'll cost more memory

    set_search = set(the_list)

    return set_search



# now let's run the code...

# ============================= Testing the algorithms =============================


p_list = list(range(34))

# O(1) Space check...

values_sum = sum_calc(p_list)

# O(n) space check...

l_double = l_element_double_list(p_list)

# time before slow search
t_1 = time.time()

# slow search with low memory
s_search = s_check(p_list, 20)

# time after slow search and before fast search
t_2 = time.time()

# fast search with high memory
f_search = f_check(p_list)


# time after fast search
t_3 = time.time()


print(f'''
============================= Testing the algo's =============================
      
Input Data: {p_list}

Sum (O(1)) Space: {values_sum}

Double List (O(n)) Space: {l_double}

Slow search result: {s_search}
Time: {t_2 - t_1}

Fast search result: {f_search}
Time: {t_3 - t_2}

Is 29 in set? {29 in f_search}
''') # f_search is now O(1) (Constant) Time















































































class Item:

    def __init__(self, name, rarity):
        
        self.item_name = name

        self.item_rarity = rarity

        print(f'\nItem "{self.item_name}" created. Rarity: {self.item_rarity}')


class Inventory:

    server_region = "US-East"

    def __init__(self, p_name):
        
        self.player_name = p_name

        self.capacity = 2

        self.items = []

        self.items = list(self.items)

        print(f'\nPlayer "{self.player_name}" created in region "{Inventory.server_region}".')

    
    def add_item(self, item_object):

        new_capacity = self.capacity * 2

        if len(self.items) == self.capacity:

            print(f"Inventory full! Resizing from {self.capacity} to {new_capacity}...\n")

            self.capacity = new_capacity

        
        self.items.append(item_object)

        print(f"{self.player_name} picked up {item_object} (Capacity: {len(self.items)}/{self.capacity})")



jesse = Inventory(p_name = "Jesse")


for item_name in ["Sword", "Shield", "Potion", "Map", "Key"]:

    the_rarity = random.choice(list(range(200)))

    the_item = Item(item_name, the_rarity)

    jesse.add_item(the_item)


enemy = Inventory("Enemy")

print(f'''
Jesse server_region: {jesse.server_region}

Enemy server_region: {enemy.server_region}
''')

Inventory.server_region = "EU-West"

print(f'''
Jesse server_region: {jesse.server_region}

Enemy server_region: {enemy.server_region}
''')

"""
What is the Big O when the inventory is NOT full?
Answer: Constant Time (O(1)), because it takes the same time to add and item to the end of a list of 4 items as it does with a list of 200k items

What is the Big O when the inventory IS full and has to resize?
Answer: Linear Time (O(n)), because we first have to find the size of the list, then double it

As you add more items, how does the memory usage of your self.items list grow relative to the number of items (N)? Is it O(1), O(N), or O(N^2)?
Answer: O(N^2), because the memory size is the same when we double it, until it's full again. Memory usage is the square of input size

If you change self.server_region = "Asia" inside the add_item method, will it change the region for all players? 
Answer: False
Explain why or why not:
You're just creating a new instance attribute called "server_region" for that particular object. It doesn't change the Class attribute for all players
"""









