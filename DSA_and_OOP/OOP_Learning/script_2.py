# Procedural Programming (a simple list of instructions) gets messy and hard to maintain ("spaghetti code") because data is global and separate from the functions that use it.
import random

the_name, the_balance = "Jesse", 1000

def balance_update(the_amount):
    """
    A procedural function to modify the global user_balance.

    Args:
        the_amount (_type_): 
            Collects a variable
    """

    global the_balance

    print(f'''
Updating balance for {the_name}...
    ''')

    old_balance = the_balance

    the_balance = the_balance + the_amount

    print(f'''
Old Balance: {old_balance}

New Balance: {the_balance}
    ''')


def refund_proc_func(amount_to_ref):

    """
    Another procedural function that also modifies the global state.
    """

    global the_balance # we have to reach out to the global variable (the one outside the function) to modify it

    print(f'''
Processing refund for {the_name}...
    ''')

    o_bal = the_balance

    the_balance = the_balance + amount_to_ref

    print(f'''
Old Balance (2): {o_bal}

New Balance (2): {the_balance}
    ''')



def user_display():

    """
    A function to display the global user's info.
    """

    print(f'''
============================= User Report =============================

Name: {the_name}

Balance: ${the_balance}

Report Done!
    ''')

# let's run the program

user_display()

balance_update(-137)

refund_proc_func(81)


print('============================= End of Program =============================')

user_display()

# what if we wanted two users or more?
# we'd have to create data variables for each and duplicate all functions

# debugging and maintaining code would be extremely difficult!







































































# Core OOP vocabulary...

class user_bank:

    """
    ## user_bank
    This is the blueprint for creating `User` objects.
    - It bundles the data `(attributes)` and behavior `(methods)` together.
    """

    

    def __init__(self, user_name, user_init_balance): # "self" refers to the object/instance being created

        print(f'User "{user_name}" account created successfully!')


        self.name = user_name

        self.user_balance = user_init_balance

    # other functions apart from __init__ are called methods. Think of them as the abilities of a CLASS

    def deposit_money(self, the_amount): # "self" is always the first argument in a method, so that an instance can access it's attributes and other methods

        try:
            the_amount = float(the_amount)

        except Exception as an_error:

            print(f"\nAn error occured in converting amount ${the_amount} to a number\nCheck it out: {an_error}")

            return

        if the_amount > 0: # safety for catching deposit of negative numbers

            self.user_balance = self.user_balance + the_amount

            print(f"\nSafely deposited ${the_amount} into {self.name}'s account")

            self.show_bal()

        else:

            print(f"Yo! The amount you deposited \"{the_amount}\" isn't positive. Try depositing a positive amount")

    def show_bal(self):

        print(f"User {self.name}'s balance is ${self.user_balance}")

    def withdraw_money(self, w_amount):

        try:
            w_amount = float(w_amount)

        except Exception as an_error:

            print(f"\nAn error occured in converting amount ${w_amount} to a number\nCheck it out: {an_error}")

            return

        if w_amount <= self.user_balance and w_amount > 0:

            self.user_balance = self.user_balance - w_amount

            print(f"\nAmount ${w_amount} successfully withdrawn!\nBalance: ${self.user_balance}")

        else:

            print(f"Error! Amount ${w_amount} is either less than your balance ${self.user_balance} or is negative")



    
# now, let's run the OOP code:

# let's create two objects/instances of  the "user_bank" class

# using the class automatically calls the __init__ method

print('\n============================= Running for "user_jesse" =============================\n')

user_jesse = user_bank("Jesse", 15000)


user_jesse.withdraw_money("9975k")

user_jesse.deposit_money(1230)

user_jesse.withdraw_money("15675")


print('\n============================= Running for "user_diana" =============================\n')


user_diana = user_bank("Diana", 23005)

user_diana.deposit_money("7800NGN")

user_diana.withdraw_money(19999)

user_diana.deposit_money(-119)

user_diana.deposit_money(13119)















































































# Procedural Programming


book_shelf = []

book = {
    "title": None,

    "author": None
}

def add_procedural_book(title, author):

    global book, book_shelf

    print(f'\nAdding book "{title}" to the book shelf...')

    book["title"] = title

    book["author"] = author

    book_shelf.append(book)

    return print(f"\nBook added successfully!\nHere's the shelf:\n{book_shelf}")






def find_procedural_book(title):

    global book_shelf

    print(f'\nSearching for book "{title}"...')

    for a_book in book_shelf:

        if a_book["title"] == title:

            return print(f'Book "{title}" has been found!\nHere it is\n{a_book}')


        
    return print(f"Book {title} not found. Please try another book")





add_procedural_book("Kelly", "Lingah")

add_procedural_book("Rango", "Miley")

find_procedural_book("kaild")

find_procedural_book("Rango")
    








# Object-Oriented Programming


class Library:

    def __init__(self):
        self.book_shelf = []

    
    def add_book(self, the_book):

        print(f'\nAdding book "{the_book["title"]}" to the book shelf...')

        self.book_shelf.append(the_book)


        print(f"\nBook added successfully!\nHere's the shelf:\n{self.book_shelf}")

    def find_book(self, book_title):

        print(f'\nSearching for book "{book_title}"...')

        for a_book in self.book_shelf:

            if a_book["title"] == book_title:
               
                return a_book


        return None

    def change_book_status(self, bkT,  procedure):

        if procedure == "in":
            
            for TT_book in self.book_shelf:

                if TT_book["title"] == bkT:
                    
                    TT_book["status"] = "available"

                    return print(f'\nStatus of Book "{bkT}" changed to "available"')

                else:

                    continue


        elif procedure == "out":

            
            for the_book in self.book_shelf:

                if the_book["title"] == bkT:
                    
                    the_book["status"] = "checked out"

                    return print(f'\nStatus of Book "{bkT}" changed to "checked out"')

                else:
                    
                    continue
            



class Book:

    the_library = Library()
    
    def __init__(self, book_title = None, book_author = None, book_status = "available", library = the_library):

        # assigning variables to the object...

        self.title = book_title

        self.author = book_author

        self.status = book_status

        self.the_library = library

        self.book = {
            "title": self.title,

            "author": self.author,

            "status": self.status
        }

        if self.title is not None:
            self.the_library.add_book(the_book = self.book)

      


    def check_out(self, Book_title):
        self.the_library.change_book_status(bkT = Book_title, procedure = "out")
    

    def check_in(self, Book_title):

        self.the_library.change_book_status(bkT = Book_title, procedure = "in")



    def book_search(self, bk_title):

        the_result = self.the_library.find_book(book_title = bk_title)

        if the_result:

            print(f'Book "{bk_title}" has been found!\nHere it is\n{the_result}')

        else:
            print(f"Book \"{bk_title}\" not found. Please try another book")






oriley_book = Book("O-Pyhsics", "Oriley")

disney_book = Book("Aladdin", "Disney")

zv_book = Book("Lioness", "Zonder Van", book_status = "checked out")

v_book = Book("Linak", "Zonn Lenn")

Book().book_search("Lioness")

Book().book_search("Mank")

Book().check_out("Linak")

Book().check_in("Lioness")


kinka = Library()

zv_book = Book("Bulonait", "Mandpqn", book_status = "checked out", library = kinka)

alakan = Book("Pioneer", "Zodln", library = kinka)


"""
Question 1. Look at your find_procedural_book and your Library's "find a book" method. What is the Time Complexity (Big O notation) of this search?

Answer: Linear Time

Question 2. Why does it have this Big O notation? What is the "worst-case" scenario that you are measuring?

Answer: The worst thing that could happen is having the book you're looking for at the end of a list of 10,000,000,000 elements, or not even there. I'll personally mourn your laptop

Question 3. In your own words, why is the OOP solution in Part 2 better and more "maintainable" than the procedural solution in Part 1?

Answer: Well for starters, i don't have to create a new dictionary manually each time i want to create a book, and i don't have to create a new library manually whenever i need a container for my books
"""













































# the "CLASS" keyword

class HumanBody:

    """
    A simple Jesse Class

    Currently it's set to doing absolutely nothing
    """

    pass # pass is like telling python to do nothing and just move along, but don't crash



# INSTANTIATING A CLASS:
# instantiating a class is like building something new using the class blueprint


person_1 = HumanBody()

person_2 = HumanBody()

print(f'''
Instantiated first person: {person_1}

Instantiated second person: {person_2}

Type: {type(person_1)}
''') # notice that the memory address (0x...) for the two objects are different, meaning that they're different things in memory

# let's verify if they are instances of the class...

print(f"Is person_1 a person? {isinstance(person_1, HumanBody)}")




































































class Person:

    """
    ## A class to create a person object

    ### Parameters:
    - `name`: The name of the person being created
    - `age`: The age of the person
    - `gender`: The sex of the person (male or female)
    - `height`: The height of the person
    """

    # the __init__ method is called whenever we instantiate a class

    # self is always the first parameter and refers to the object being created

    def __init__(self, name, age, gender, height):

        print(f"Creating new body for {name}...")

        self.na_me = name # interpreted as "attach the attribute 'na_me' to the object being created, it's value is gotten from the 'name' variable"
        
        self.a_ge = age
        
        self.gen_der = gender
        
        self.hei_ght = height

        self.nationality = "Nigerian" # we can also set constant values in the class

        # If we did NOT use 'self' (e.g., just 'nationality = Nigerian'), the variable
        # would act like a normal local variable: it would vanish as soon 
        # as the __init__ function finished running!

        print(f'''
Body successfully created!
Name: {self.na_me}
Age: {self.a_ge}
Gender: {self.gen_der}
Height: {self.hei_ght}
        ''')


    def grow_tall(self, increase):

        # we use self.hei_ght to access the specific object's height

        self.hei_ght = self.hei_ght + increase

        print(f"{self.na_me} just grew by {increase}m. Total height is {self.hei_ght}m")


# let's instantiate the class by creating objects

print("\n============================= Instantiating Person Objects =============================\n")

person_1 = Person("Jesse", 19, "male", 4.5)

person_2 = Person("Favour", 23, 'female', 3.1)

# each instance/object has it's own data...

print(f'''
============================= Person Objects and their data =============================

person_1 Name: {person_1.na_me}
person_1 Height: {person_1.hei_ght}

person_2 Name: {person_2.na_me}
person_2 Height: {person_2.hei_ght}
''')


# we modify object states using methods

# calling a method only changes the data for that instance

person_2.grow_tall(1.5)

print(f'''
person_1 Height: {person_1.hei_ght}

person_2 Height: {person_2.hei_ght}
''') # person_1's height remains unchanged, while that of person_2 has been modified



















































































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









