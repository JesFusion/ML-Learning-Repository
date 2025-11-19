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
