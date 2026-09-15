import asyncio
import requests as requests_lib
import logging




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





class ErrorFromInsufficientFunds(Exception):

    """
    Raised when a charge amount exceeds the allowed single-transaction limit.
    """

    pass


class ErrorFromInvalidEmail(ValueError):

    """
    Raised when an email string fails format validation checks.
    """

    pass





class PaymentProcessingClass:

    def __init__(self):
        
        self.transaction_limit = 10_000

    def the_charge(
        self,
        the_amount,
        the_currency = 'USD'
    ):
        
        if the_amount <= 0:

            raise ValueError(f"Charge amount must be positive, got: {the_amount}")
        
        elif the_amount > self.transaction_limit:

            raise ErrorFromInsufficientFunds(f"Amount {the_amount} exceeds single-transaction limit of {self.transaction_limit}")
        
        output = {
            "status": "charged",
            
            "amount": the_amount,
            
            "currency": the_currency
        }

        return output
    

    def refund_money(
        self,
        transactionID,
        the_amount
    ):
        
        if not transactionID:

            raise ValueError("transaction_id cannot be empty or None")
        
        if the_amount <= 0:

            raise ValueError(f"Refund amount must be positive, got: {the_amount}")
        
        
        output = {
            "status": "refunded",
            "transaction id": transactionID,
            "amount": the_amount
        }

        return output
    

    def batch_processing(
        self,
        the_transactions
    ):
        
        transaction_results = []


        for transaction in the_transactions:

            the_result = self.the_charge(
                the_amount = transaction['amount'],

                the_currency = transaction.get('currency', 'USD')
            )

            transaction_results.append(the_result)

        
        return transaction_results
    





class ClassThatValidatesData:

    def email_validation(
        self,
        the_Email
    ):
        
        if not the_Email:

            raise ErrorFromInvalidEmail("Email cannot be empty or None")
        

        if not isinstance(the_Email, str):

            raise ErrorFromInvalidEmail(f"Email must be a string, got: {type(the_Email).__name__}")


        if '@' not in the_Email:

            raise ErrorFromInvalidEmail(f"Email must contain '@': received '{the_Email}'")
        

        if '.' not in the_Email.split('@')[-1]:

            raise ErrorFromInvalidEmail(f"Email domain must contain '.': received '{the_Email}'")
        
        return True


    def calculating_the_discount(
        self,
        price,
        discount_pct # discount_pct = discount percentage
    ):
        
        if discount_pct < 0 or discount_pct > 100:

            raise ValueError(f"Discount must be between 0 and 100, got: {discount_pct}")
        
        output = float(f"{(price * (1 - discount_pct / 100)):.2f}")

        return output
    


    def is_it_palindrome(
        self,
        input_text
    ):
        
        cleaned_text = str(input_text).lower().replace(" ", "")


        return cleaned_text == cleaned_text[::-1]
    

    def scores_summarization(
        self,
        the_scores
    ):
        
        if not the_scores:

            raise ValueError("Scores list cannot be empty!")
        
        output = {
            "min": min(the_scores),

            "max": max(the_scores),

            "avg": round(
                sum(the_scores) / len(the_scores),

                ndigits = 2
            ),

            "count": len(the_scores)
        }

        return output







def exchange_rate_fetching(
    Bcurrency, # Bcurrency = Base Currency

    Tcurrency # Tcurrency = Target Currency
):
    
    """
    Calls a live currency exchange API. NEVER call this real URL in tests.    
    """
    
    API_response = requests_lib.get(
        url = 'https://api.exchangerate.host/latest',

        params = {
            "base": Bcurrency,

            "symbols": Tcurrency
        },

        timeout = 5
    )

    output_data = API_response.json()

    output = output_data['rates'][Tcurrency] # Tcurrency = 'EUR'

    return output




def gateway_payment_notification(
    transID,
    the_amount,
    the_gateway_client
):
    
    """
    Notifies an external payment gateway. The gateway_client is injected
    so tests can pass a Mock directly — no patching required.
    """

    if not transID:

        raise ValueError("No value provided! Please provide a value")
    

    the_gateway_client.post(
        endpoint = '/notify',
        payload = {
            'transaction_id': transID,
            "amount": the_amount
        }
    )

    return True
    




async def fetch_user_profile_async(
    uID, # uID = User ID
    HTTP_clt = None # HTTP_clt =  HTTP client
):    
    """
    Async function simulating an async HTTP call to a user-profile service.
    """

    await asyncio.sleep(delay = 0)

    if HTTP_clt:

        the_result = await HTTP_clt.get(
            url = f"/users/{uID}"
        )

        return the_result

    output = {
        'id': uID,
        'name': 'Jesse the Tester',
        'role': "MLOps Engineer"
    }
    
    return output





# ===================================== RANDOM FUNCTIONS TO BE USED IN SEGMENT 3.1 =====================================

class creating_the_engine:

    def __init__(self, url):

        pass

    def disposing_the_engine():

        pass


class session_creation:

    def __init__(self, bind):
        
        pass

    def rollback():

        pass

    def close():

        pass


class app_initialization:

    def __init__(self, configuration):
        
        pass







GLOBAL_DICTIONARY = {
    'LastTransactionID': None,
    'RequestCount': 0
}





def IS_JESSE_COOL():
    return True




























































