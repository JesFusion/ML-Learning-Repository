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
