# Procedural Programming (a simple list of instructions) gets messy and hard to maintain ("spaghetti code") because data is global and separate from the functions that use it.

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

