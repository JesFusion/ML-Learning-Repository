import re
import uuid
import time
import pytest
import logging
import asyncio
import uvicorn
from datetime import date
from contextlib import asynccontextmanager
from fastapi.responses import JSONResponse
from fastapi import (
    FastAPI,
    Request,
    Response,
    HTTPException
)
from typing import (
    Literal,
    Optional,
    Union
)
from pydantic import (
    Field,
    constr,
    conint,
    BaseModel,
    ConfigDict,
    ValidationInfo,
    model_validator,
    field_validator
)
from pydantic.networks import EmailStr
# from pydantic_extra_types.phone_numbers import PhoneNumber
from fastapi.testclient import TestClient
from pydantic_extra_types import (
    phone_numbers,
    country
)


PhoneNumber = phone_numbers.PhoneNumber
CountryAlpha2 = country.CountryAlpha2



sc200 = 200

# ===================================== Performing logging operations =====================================

path_to_file = "logs/print.log"


log = logging.getLogger(name = 'FastAPI Learning')

log.setLevel(level = logging.DEBUG)

terminal = logging.StreamHandler()

terminal.setLevel(
    level = logging.INFO
)

terminal.setFormatter(
    fmt = logging.Formatter(
        fmt = "\n%(message)s\n"
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

    log.addHandler(hdlr = handlers[handler])





@asynccontextmanager
async def api_lifespan(
    the_application: FastAPI
):
    
    # firing up logic...

    log.info("Initializing app resources...")

    start_state = {
        "db": "Connected",
        "cache": "Warmed",
        "workers": 6
    }

    the_application.state.startup_data = start_state

    log.info(f"State initialized: {start_state}")

    
    yield

    # shutting down logic...

    log.info("Cleaning up application resources...")

    if hasattr(
        the_application.state, "startup_data"
    ):
        
        del the_application.state.startup_data

    log.info("Cleanup complete!")


jesse_api = FastAPI(
    title = "Jesse Learning FastAPI",

    lifespan = api_lifespan
)






# ===================================== Segment 1: Core Architecture =====================================


@jesse_api.get("/endpoint-syncing")

def sync_the_endpoint():

    the_result = {
        'message': 'I am syncing cooly',

        "does_it_block_event_loop?": True
    }

    output = JSONResponse(
        content = the_result,
        status_code = sc200
    )

    return output





@jesse_api.get("/endpoint-asyncing")
async def async_the_endpoint():

    await asyncio.sleep(0.03)

    result = {
        "message": "I am asyncing cooly", 
        "blocks_event_loop": False
    }

    output = JSONResponse(
        content = result,
        status_code = sc200
    )

    return output






@jesse_api.post("/request-inspection")
async def request_inspection(
    the_request: Request
):
    
    procedure = the_request.method

    link = str(the_request.url)

    request_headers = dict(the_request.headers)

    if the_request.client:

        host_client = the_request.client.host

    else:

        host_client = "Unknown"
    
    link_path = the_request.url.path

    query_parameters = dict(the_request.query_params)

    request_body = await the_request.body()

    output = JSONResponse(
        content = {
            "method": procedure,

            "path": link_path,

            "headers": request_headers,

            "client_host": host_client,

            "query_params": query_parameters,

            "length_of_body_bytes": len(request_body),
        },

        status_code = sc200
    )

    return output








@jesse_api.get('/random-response')
async def random_response():

    url_response = Response(
        content = "Random Response Body",

        status_code = 400,

        headers = {
            "X-Random-Header": "MyValue",
            
            "X-Generated-From": "FastAPI-Learning"
        }
    )

    return url_response




@jesse_api.get("/information-from-event-loop")
async def information_from_event_loop():

    the_event_loop = asyncio.get_event_loop()

    output = JSONResponse(
        content = {
            'is_loop_running?': the_event_loop.is_running(),

            'type_of_loop': type(the_event_loop).__name__,

            "output_message": "This endpoint is running INSIDE the event loop (Uvicorn's context)"
        },

        status_code = sc200
    )

    return output





def blocking_function(secs: int):

    for x in range(secs ** 1):

        pass

    time.sleep(secs)

    output = {
        "successfully wasted time?": True
    }

    return output



# we build APis delicately, slapping things in the main project that we know will take time to the run_in_executor function (which involves passing them to the thread pool), so that it won't blobk the event loop
@jesse_api.get('/safe-blocking')
async def safe_blocking():

    the_event_loop = asyncio.get_event_loop()

    the_result = await the_event_loop.run_in_executor(
        None,
        blocking_function, 1
    )

    output = JSONResponse(
        content = the_result,

        status_code = sc200
    )

    return output

    







@jesse_api.get("/the_resource/{get_resource_id}")
async def obtain_the_resource(
    get_resource_id: int
):
    
    output = JSONResponse(
        content = {
            'action': 'GET',

            'resource_id': get_resource_id
        },

        status_code = sc200
    )

    return output





@jesse_api.post('/the_resource')
async def resource_creation():

    output = JSONResponse(
        content = {
            'action': 'POST',

            'new_ID': (sc200 - 99)
        },

        status_code = 201
    )

    return output





@jesse_api.put("/the_resource/{put_resource_id}")
async def updating_resource(
    put_resource_id: int
):

    output = JSONResponse(
        content = {
            'action': 'PUT',

            'resource_id': put_resource_id
        },

        status_code = sc200
    )

    return output







@jesse_api.patch("/the_resource/{patch_resource_id}")
async def partially_updating_resource(
    patch_resource_id: int
):
    
    output = JSONResponse(
        content = {
            'action': 'PATCH',

            'resource_id': patch_resource_id
        },

        status_code = sc200
    )

    return output









@jesse_api.delete("/the_resource/{delete_resource_id}")

async def deleting_the_resource(
    delete_resource_id: int
):
    output = JSONResponse(
        content = {
            'action': 'DELETE',

            'resource_id': delete_resource_id
        },

        status_code = 204
    )

    return output






@jesse_api.get("/block-event-loop")
def event_loop_blocking():

    time.sleep(2)

    output = JSONResponse(
        content = {
            'message': "This blocked the event loop"
        },

        status_code = sc200
    )

    return output







@jesse_api.get("/check-health")
async def health_checking():

    output = JSONResponse(
        content = {
            'status': 'healthy',

            'service': "jesse-practice"
        },

        status_code = sc200
    )

    return output






















# ===================================== Segment 2: Request Validation with Pydantic Deep-Dive =====================================

def generate_ID() -> str:

    the_unique_id = str(uuid.uuid4())

    return the_unique_id


class UserModel(BaseModel):

    id_of_user: int = Field(
        ge = 1,
        default_factory = generate_ID,
        description = "User ID must be >= 1"
    )

    name_of_user: str = Field(
        min_length = 5,
        max_length = 65,
        description = "Username must be 5-65 characters in length"
    )

    user_email: EmailStr = Field(
        description = "A valid email format is required"
    )

    user_age: Optional[int] = Field(
        default = "Not Set",
        gt = 18,
        le = 80,
        description = "Age must be between 18 and 80"
    )


    score_of_user: Optional[float] = Field(
        default = 0.0,
        multiple_of = 0.5
    )








class ProductModel(BaseModel):

    id_of_product: int = Field(
        ge = 1,
        default_factory = generate_ID,
    )

    product_name: str = Field(
        min_length = 5,
        max_length = 500,
    )

    price_of_product: float = Field(
        gt = 0
    )

    stock_keeping_unit: Optional[str] = Field(
        min_length = 6
    )


    
    @field_validator("stock_keeping_unit")
    @classmethod
    def stock_keeping_unit_validation(
        cls,
        keep_unit_value: str
    ) -> str:
        
        if "-" not in keep_unit_value:

            raise ValueError('"-" must be present in sku')
    
        elif keep_unit_value.count("-") == 2:

            raise ValueError('SKU cannot contain two hyphens')
        
        else:
            
            unit_prefix, unit_value = keep_unit_value.split("-", maxsplit = 1)
             

        if unit_value.isdigit():

            raise ValueError("SKU suffix must contain only digits")


        output = f"{unit_prefix.upper()}({unit_value})"

        return output
    


    @field_validator('price_of_product')
    @classmethod
    def validating_the_price_of_the_product(
        cls,
        price_value: float
    ) -> float:
        
        decimal_part = str(price_value).split(".")[-1]

        decimal_length = len(decimal_part)

        if decimal_length < 2:

            raise ValueError("Price must not have less than 2 decimals")

        elif decimal_length > 2 and not decimal_part.endswith('0'):

            rounded_price_value = round(price_value, 2)

            log.warning(f"Price {price_value} must have at most 2 decimal places"
            f"Automatically rounded to {rounded_price_value}")
            

            return rounded_price_value
        

        return price_value
        
        






class DateRangeModel(BaseModel):

    name_of_event: str

    starting_date: date = Field(
        description = 'Starting date must be in the "YYYY-MM-DD" format'
    )

    ending_date: date = Field(
        description = 'Ending date must be in the "YYYY-MM-DD" format'
    )

    @model_validator(
        mode = "after"
    )
    def date_range_validation(self):

        if self.starting_date >= self.ending_date:

            raise ValueError("Ending date must be greater than Starting date")
        
        return self





class NotificationViaEmail(BaseModel):

    the_type: Literal['email']

    the_recipient: EmailStr = Field(
        description = 'Recipient who will be receiving the email'
    )

    email_subject: str



class NotificationViaSMS(BaseModel):

    the_type: Literal['sms']

    recipient_phone_number: PhoneNumber = Field(
        description = "A valid international phone number"
    )

    input_message: str







class SendPushNotification(BaseModel):

    the_type: Literal['push']

    id_of_target_device: str = Field(
        default_factory = generate_ID
    )

    notification_title: str





alert_notification = Union[
    NotificationViaEmail,
    NotificationViaSMS,
    SendPushNotification
]





class UserAddress(BaseModel):

    user_street: str = Field(
        min_length = 5,
        max_length = 400,
        description = "Street where user lives is required"
    )

    user_city: str = Field(
        min_length = 1,
        max_length = 100,
        description = "City where user lives is required"
    )

    user_country: CountryAlpha2 = Field(
        min_length = 2, max_length = 2,
        description = "ISO 3166-1 alpha-2 country code is required"
    )

    user_zip_code = Optional[str] = Field(
        regex=r"^\d{5}(-\d{4})?$",

        default = '90210',
        
        description="US format with optional +4"
    )









class OrderModel(BaseModel):

    id_of_the_order: int = Field(
        ge = 1,        
        default_factory = generate_ID
    )

    total_price: float = Field(
        gt = 0
    )

    items_purchased: list[str] = Field(
        min_length = 1,
        max_length = 98,
        description = "List of item purchased"
    )









class ProfileOfTheUser(BaseModel):

    id_of_the_user: int = Field(
        ge = 1,
        default_factory = generate_ID
    )

    name_of_the_user: str = Field(
        max_length = 75
    )

    email_of_the_user: EmailStr

    address_of_the_user: list[UserAddress] = Field(
        min_length = 1,
        max_length = 4,
        description = "A maximum of 4 addresses is allowed"
    )

    user_orders: list[OrderModel] = Field(
        default_factory = list
    )








class ProductThatIsStrict(BaseModel):

    model_config  = ConfigDict(
        extra = 'forbid'
    )

    name_of_product: str = Field(
        min_length = 3,
        max_length = 175
    )

    price_of_product: float = Field(
        gt = 0
    )












class ProductThatIsLoose(BaseModel):

    model_config = ConfigDict(extra = 'ignore')

    name_of_product: str = Field(
        min_length = 3,
        max_length = 175
    )

    price_of_product: float = Field(
        gt = 0
    )
    



class InputFromTheUser(BaseModel):

    id_of_the_user: int = Field(alias = "IdOfTheUser")

    user_first_name: str = Field(alias = "FirstNameOfTheUser")

    user_last_name: str = Field(alias = "LastNameOfTheUser")

    model_config = ConfigDict(populate_by_name = True)







class TheTask(BaseModel):

    task_title: str

    task_prority_level: int = Field(
        default = 7,
        ge = 1,
        le = 12
    )

    task_tags: list[str] = Field(
        default_factory = list
    )








class ASimpleUser(BaseModel):
    the_username: constr(
        min_length = 3,
        max_length = 67
    )

    user_age: conint(
        ge = 1,
        le = 70
    )





# ===================================== EndPoints Demonstrating Validation =====================================


@jesse_api.post("/get_users", status_code = 305)





























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































