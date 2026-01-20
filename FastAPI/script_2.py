import os
import time
import random
import json
import joblib
import logging
import requests
import numpy as np
import pandas as pd
from enum import Enum # Enum is a class that enables us to create a restricted list of choices for a dynamic route
from pydantic import BaseModel, Field, model_validator
from fastapi import FastAPI, Depends, HTTPException, Header, Body
from typing import Union, List, Optional, Annotated # for creating optional parameters
from dotenv import load_dotenv
from sqlalchemy import create_engine, text # text is a safer method to write queries for a database than mere strings



app = FastAPI()

@app.get("/")
async def home():

    return {
        "Name": "Nwachukwu Jesse",
        "Career": "MLOps Engineering"
    }

@app.get("/health")
async def check_health():
    return {
        "RAM Status": "Nominal",
        "CPU Load": "Normal"
    }
















































































app = FastAPI()

# ===================================== Path vs. Query Parameters =====================================

'''
Path Parameters points to a specific resource 
For example: "/items/model_v5"
- Here we're trying to access the 5th version of our model

Query Parameters modifies how you view the resource. It comes after "?"

For Example: "/predict?user_ID=99&threshold=0.8"
- Here, we're trying to access the prediction, but only if the user_ID is valid and the confidence is > 80%
'''

@app.get("/")
async def home_page():
    return "Welcome to FastAPI!"


@app.get("/predict/{model}")
async def churn_predictor(

    model: str, # Path Parameter (matched in {}) 
    user_ID: int, # Query Parameter (not in {})
    treshold: float = 0.1, # Query Parameter with Default

): # FastAPI performs type checking befofe passing values. If you passed a string to user_ID, it'll throw an error
    
    output = {
        "Instantiated Model": model,
        "User ID": "ID_" + str(user_ID),
        "Confidence Threshold": treshold,
        "Model Prediction": {
            "Churn Risk": "High",
            "Model Performance": "threshold"
        }
    }

    return output
    # try running "/predict/v1?user_ID=88&threshold=0.3"



























































# ===================================== API =====================================



app = FastAPI()

@app.get("/")
async def main():

    home_output = {
        "Name": "Jesse",
        "is Cool": True
    }

    return home_output


@app.post("/ingest/raw_data")
async def ingest_data(payload_information: dict = Body(...)):

    """
    Simulates an endpoint that accepts raw data (The Moving Truck).
    
    Args:
        payload (dict): This tells FastAPI to expect a JSON body, 
                        and to convert (deserialize) it into a Python dictionary.
                        'Body(...)' means the body is REQUIRED.
    """

    the_ID = payload_information.get("ID")

    the_price = payload_information.get("price")

    output = f"Received! From what I have here, your ID is {the_ID} and you're willing to pay ${the_price} for the house"

    return output





# ===================================== Client =====================================



logging.basicConfig(
    format = "--> %(message)s",
    level = logging.DEBUG
)


the_url = "http://127.0.0.1:8000/ingest/raw_data"

sample_data = {
    "ID": "id_12910",

    "address": "14 Agada Street Co-operative Housing Abakpa Nike Enugu",

    "sqft": 5698,

    "price": 1700000,

    "features": ['garage', 'pool', 'master bedroom', 'solar panels', 'gym']
}

the_payload = json.dumps(sample_data, indent = 3) # json.dumps means "dump to string" (also called Serialization). Normally if you see the output, it'll be one long line of string, but we specified that 3 lines of indentation be added to visual clarity (indent = 3)

logging.info(f'''
Sending Payload: {the_payload}
''')

server_response = requests.post(the_url, json = sample_data) # We use requests.post() over the API. The 'json=' argument handles Serialization for us automatically.


logging.info(f'''
======================================== Server Response ========================================
             
{server_response.json()}
''')

























































# ===================================== API =====================================




app = FastAPI()


class InputDataFormat(BaseModel):

    ID: int

    price: float = Field(..., gt = 0, description = "Price of House in USD") # gt means "greater than", we're trying to specify that he price amout coming in shouldn't be greater than 0

    sqft: int

    features: List[str] # features MUST be a list, and every item in that list MUST be a string

    address: Optional[str] = "Homeless" # Setting 'Optional' means that it's optional to fill this section. If it's not filled, the default value (Homeless) is passed


# loading app...

@app.post("/data_validation")
async def house_validation(HOUSE: InputDataFormat):

    """
    This function ONLY executes if the data passes the Pydantic checks.
    """

    # We now have 'Dot Notation'.

    # We don't need to write payload.get('price'). We can use "payload.price"

    # This enables auto-complete in VS Code and prevents typos

    house_id = f"h_{HOUSE.ID}"

    each_feature_price = HOUSE.price / len(HOUSE.features)

    output = f"House {house_id}: House Address = {HOUSE.address}, House price = ${HOUSE.price}, Price per feature = {each_feature_price}"

    return output





# ===================================== Client =====================================



logging.basicConfig(
    level = logging.DEBUG,
    format = "%(levelname)s :: %(message)s"
)

load_dotenv()

the_url = f"{os.getenv("HOME_URL")}data_validation"

# let's simulate some bad data to see if Pydantic works...
some_stupid_data = {
    "ID": "open",
    "price": -35.23,
    "features": "We're sending features as a string not a list"
}

# Sending trash data to API
api_response = requests.post(the_url, json = some_stupid_data)

# Pydantic should throw an error
logging.error(f"{api_response.status_code}")

logging.error(f'''
======================================== Pydantic Error Message ========================================

{api_response.json()}
''')












































































# ===================================== API =====================================


"""
Nested Models & Complex Structures:

In the enterprise world (and in JSON), data is often deeply nested—like a Russian Doll or a file folder system.

Imagine you aren't just predicting the price of one house. You are Zillow. You need to predict prices for an entire neighborhood at once (Batch Inference). Or, a house object might contain an Address object inside it, which contains a GeoLocation object inside that.

Composition (The "Lego" Approach): Instead of writing one giant validation list, we build small, reusable models (Address, Owner, Features) and plug them into a main model (House).

The Code: We are going to build a Batch Prediction Endpoint. This is standard MLOps practice because running your model once on 50 rows is way faster (Vectorization!) than running it 50 times on 1 row.
"""


belarus = FastAPI()

# ===================================== SUB-MODELS =====================================
class UserAddress(BaseModel):

    street_location: str
    city_of_origin: str
    current_zip_code: str

class ObservableHouseFeatures(BaseModel):

    square_feet: int
    no_of_rooms: int
    pool_present: bool = False # Default should be false

# ===================================== PARENT MODEL =====================================

class ListingOfTheHouse(BaseModel):

    the_address: UserAddress

    present_features: ObservableHouseFeatures

    sales_agent: Optional[str] = None


# ===================================== BATCH MODEL =====================================

class RequestOfTheBatch(BaseModel):

    id_of_batch: str

    the_items: List[ListingOfTheHouse]



# ===================================== ENDPOINTS =====================================

@belarus.get("/")
def is_cools():

    return "Jesse is cool"


@belarus.post("/batch_process")
async def batch_processing(package: RequestOfTheBatch):

    """
    Receives a batch of houses.
    FastAPI will loop through EVERY house in the list and validate it 
    against the HouseListing schema, the Address schema, etc.
    If even ONE field in ONE house is wrong, the whole batch is rejected.
    """

    container_list = []

    for a_house in package.the_items:

        assumed_price = (a_house.present_features.square_feet) * 219

        container_list.append({
            "house_zip": a_house.the_address.current_zip_code,

            "model_prediction": assumed_price
        })

    output = {
        "id_of_batch": package.id_of_batch,

        "number_of_processed_items": len(container_list),

        "the_results": container_list
    }

    return output




    

# ===================================== Client =====================================


load_dotenv()

input_data = {
  "id_of_batch": "batch_001",

  "the_items": [
    {
      "the_address": {
           "street_location": "123 ML St",
           
           "city_of_origin": "Lagos",
           
           "current_zip_code": "100001" 
      },

      "present_features": {
           "square_feet": 1500,
           
           "no_of_rooms": 3,
           
           "pool_present": True 
      }
    },


    {
      "the_address": {
           "street_location": "456 AI Ave",
           
           "city_of_origin": "Abuja",
           
           "current_zip_code": "900001" 
      },

      "present_features": {
          "square_feet": 3000, 
          
          "no_of_rooms": 5
      },

      'sales_agent': "Njoku Kingsley Anthony"
    }
  ]
}


server_response = requests.post(
    json = input_data,

    url = f"{os.getenv("HOME_URL")}batch_process"
)


print(f'''
Server Output: {server_response.json()}

Status Code: {server_response.status_code}
''')

























































# ===================================== API =====================================



load_dotenv()

# model_save_path = os.getenv("MODEL_SAVE_PATH")
model_save_path = '/home/jesfusion/Documents/ml/ML-Learning-Repository/Saved_Datasets_and_Models/Models/'

# loading the model and scaler
diamond_model = joblib.load(f"{model_save_path}KNN/diamond_model.pkl")

diamond_scaler = joblib.load(f"{model_save_path}KNN/diamond_scaler.pkl")

diamond_api = FastAPI()

# defining input data schema...

class CutType(str, Enum):
    FAIR = "fair"
    GOOD = "good"
    IDEAL = "ideal"


class DiamondInputSchema(BaseModel):

    carat: float

    cut: CutType # cut must be either fair, good or ideal


# defining our endpoint and it's function
@diamond_api.post("/predict/price")
async def diamond_price_prediction(diamond: DiamondInputSchema):

    c_string_conversion = {
        "fair": 0,
        "good": 1,
        "ideal": 2
    }

    carat_weight = diamond.carat

    # we'll map cut weight to it's value
    cut_number = c_string_conversion.get(diamond.cut)

    # convert to an array and pass it to our scaler, who can put it in the language our model understands
    input_val_array = np.array([[carat_weight, cut_number]])

    model_feed = diamond_scaler.transform(input_val_array)

    # collecting model answer and passing back to client
    model_answer = float(diamond_model.predict(model_feed)[0])

    return model_answer






# ===================================== Client =====================================

load_dotenv()

# let's simulate a user that wants to make use of our API
carat_weight = input("Enter a Carat Weight: ")

c_rating = input("Enter a Carat Rating: ").lower() # all letters in c_rating will be converted to lowercase, to prevent pydantic from throwing an error

user_input = {
    'carat': carat_weight, # carat_weight is converted to a float, because it's pydantic expects

    'cut': c_rating
}

# sending user input to model through the API...
d_pred_api_response = requests.post(url = f"{os.getenv("HOME_URL")}predict/price", json = user_input).json()

# printing out AI Response
print(f"CrystalClear AI Predicts that diamond is worth ${d_pred_api_response}")














































































# ===================================== API =====================================




API = FastAPI()

class FeaturesOfHouse(BaseModel):

    square_feet: float = Field(gt = 0, description = "Total Area of House")

    number_of_rooms: int = Field(gt = 0, description = "Number of rooms in the House")

    @model_validator(mode = "after") # this runs after incoming data has been allowed to passthrough by the pydantic bodyguard
    def room_check_density(self):

        # in this function, we throw an error if the square feet of the incoming house is unreasonable

        house_area = self.square_feet

        house_rooms = self.number_of_rooms

        if (house_area / house_rooms) < 50:

            error = f"Impossible Data: {house_rooms} rooms cannot fit in {house_area} square feet."

            raise ValueError(error)
        
        return self


@API.post("/predict/house")
async def predict_house_price(the_house: FeaturesOfHouse):

    price = (the_house.square_feet ** 2) / (the_house.number_of_rooms * 58.257)

    output = {
        "status": "valid",

        "density": the_house.square_feet / the_house.number_of_rooms,

        "price": f"${price:.2f}"
    }

    return output





# ===================================== Client =====================================


load_dotenv()

user_input = {
    'square_feet': 7500,

    'number_of_rooms': 4
}

# sending user input to model through the API...
d_pred_api_response = requests.post(url = f"{os.getenv("HOME_URL")}predict/house", json = user_input).json()

# printing out AI Response
print(f"API Response: {d_pred_api_response}")





























































































np.random.seed(20)



fastapp = FastAPI() # Initialize the app


async def check_if_premium(
    x_token: Annotated[str, Header()],
    age: int
):
    
    """
    Acts as a gatekeeper.
    1. Checks the header 'x-token'.
    2. If it's not 'dev_jesse', it raises an error.
    3. If valid, it returns a dictionary with user info.
    """

    # Simulating a database lookup of valid tokens
    # In production, this would be: user = await db.get_user(token)

    fake_database = ['dev_jesse', 'admin_2006_20']

    account_balance = np.random.randint(45000, 315000, size = (1, 6)).tolist()[0]

    # logic to verify if the user is premium
    if x_token not in fake_database:

        raise HTTPException( # raise HTTPException error if user is not a premium User
            status_code = 400,
            detail = "Access Denied! Premium Membership required."
        )
    
    # if user is valid, we return his details

    check_if_p_output = {
        "user_ID": x_token,
        "status": "ACTIVE",
        'tier': "platinum",
        "age": age,
        "Acc. Balance": random.choice(account_balance)
    }

    return check_if_p_output


# let's write an endpoint

@fastapp.get('/model_prediction/exclusive_model')

# We use 'Depends(check_if_premium)' to inject the return value of the function above.
async def run_premium_model(
    user_information: dict = Depends(check_if_premium)
):
    """
    This endpoint logic ONLY runs if .check_if_premium() succeeds.
    We don't need to write 'if user is valid' here. It's guaranteed.
    """
    
    # We can access the data returned by the function

    user_identity = user_information['user_ID']
    
    user_tier = user_information['tier']

    user_balance = user_information['Acc. Balance']

    user_age = user_information['age']

    run_p_model_output = f"Welcome, {user_identity} (Age: {user_age}). You are a {user_tier} user. Your account balance is ${user_balance}"

    return run_p_model_output











































































# Instantiating the fastapi class
fastapp = FastAPI()

# we crate an endpoint named "/health" using the get method
@fastapp.get("/health")
async def check_server_health():
    """
    A simple health check endpoint.
    Used by load balancers (AWS/K8s) to know if the server is alive.
    """

    CH_output = {
        "status": "active",
        "version": "1.0.0"
    }

    return CH_output


# testing a post method with my own logic
@fastapp.post('/jesse')
async def jesse_page():

    JP_output = {
        "Name": "Jesse",
        "Status": "Cool"
    }

    return JP_output























































# create an instance of the FastAPI class
the_api = FastAPI()

# define a route decorator for the home page using the GET method.
# Any HTTP GET request to the home page should run the function below
@the_api.get("/")

async def root_page():

    # return a JSON (standard for API and web communication)
    return {
        "message": "FastAPI is cool!",

        "scale": 7
    }
    








































































the_data = {
    "model_name": ["resnet", "yolo", "transformer", "pytorch"],
    "version": ["v1", "v5", "v2", "v0.1"],
    "accuracy": [0.92, 0.88, 0.95, 0.11]
}

dataset = pd.DataFrame(the_data)

# visualizing the dataset...
# print(dataset.head().to_markdown(tablefmt = "fancy_grid"))


# ===================================== API LOGIC =====================================



the_app = FastAPI()
class Models(str, Enum): # we define a class which is a subclass of the string and Enum classes, where we define the allowed model names

    r = "resnet"

    y = "yolo"

    tf = "transformer"

    torch = "pytorch"



"""
SPECIFIC PATH

A static route for the "latest" model must come BEFORE the generic path.

If this route was below the /{MODEL} route, FastAPI would think "latest" is a variable name.
"""
@the_app.get("/the_models/latest")

async def latest_model():

    return {
        "name": "most powerful model",

        "status": "insanely capable"
    }


"""
DYNAMIC ROUTING WITH TYPE HINTING:

MODEL is a path parameter that we type hint as our 'Models' Enum

The Models class acts as a bouncer for incoming string, ensuring that they must match one of the specified values
"""

@the_app.post("/models/{MODEL}")
async def model_info(MODEL: Models):

    user_choice = dataset.loc[dataset['model_name'] == MODEL]

    user_choice = user_choice.to_dict(orient = 'records')[0]

    return {
        "model_name": user_choice["model_name"],

        "version": user_choice["version"],

        "accuracy": user_choice["accuracy"]
    }

    
























































































































connection = os.environ.get("POSTGRE_CONNECT")

website = FastAPI()

conn = create_engine(connection)




@website.get("/m_acc_logs_10")

async def model_prediction(

    # required parameter. No default value provided.
    model_name: str,

    # also a required parameter
    ID: int = 9,

    # optional parameter. default is 0.445
    model_threshold: float = 0.445,

    # model_tag can either be an inputed string or None by default
    model_tag: Optional[str] = None
    # the code above is the same thing as:
    # model_tag: str | None
):
    model_logs_query = text("""
SELECT model_acc FROM lab_models
WHERE data_name = :model
AND model_acc > :accuracy_score
LIMIT 10
""")

    output = pd.read_sql_query(
        model_logs_query,

        con = conn,

        # "params" is where we input nouyr Parameters; the values our database should use for when running the query
        params = {
            "model": model_name,

            "accuracy_score": model_threshold
        }

    )["model_acc"].tolist() # this extracts only the 'model_acc' column and converts it to a list

    
    acc_report = {}

    for acc_number in range(len(output)):

        acc_report[f"Acc {acc_number + 1}"] = output[acc_number]


    return {
        "model name": model_name,

        "ID": ID,

        "model tag": model_tag,

        "model logs": acc_report,
    }






@website.get("/all_acc_logs")

async def fetch_all_logs(

    model_name: str,

    model_threshold: float,

    skip_logs: int = 10,

    fetch_limit: int = 50,
):
    
    
    all_acc_query = text("""
SELECT model_acc FROM lab_models
WHERE data_name = :model
AND model_acc > :accuracy_score
LIMIT :limit
OFFSET :log_skip
""")

    # by default the database will always return rows of the specified limit
    # we need to make sure that our dataframe never returns more then 10 rows if fetch_limit - skip_logs < 10
    show_size = fetch_limit - skip_logs

    # our dataframe should not return more than 10 rows if the difference between the inputed number of logs to skip and the limit of logs to extract is less than 10
    if show_size < 10:

        dict_limit = show_size
    else:

        dict_limit = 10



    all_output = pd.read_sql_query(
        con = conn,

        sql = all_acc_query,

        params = {
            "model": model_name,
            
            "accuracy_score": model_threshold,

            "log_skip": skip_logs,

            "limit": fetch_limit,
        }
    ).head(dict_limit)["model_acc"].tolist()


    acc_tag = []

    for log_row_number in range(skip_logs, (skip_logs + dict_limit)): # this gives us a range of numbers between the number inputed but the user for the OFFSET, and it's addition to the value of 'dict_limit'

        acc_tag.append(f"Acc {log_row_number + 1}")
        

    acc_report = dict(zip(acc_tag, all_output))

    return {
        "model name": model_name,

        "model logs": acc_report
    }









































































the_data = pd.DataFrame({
    "feature_name": ["sqft", "bedrooms", "age"],
    "min_value": [100, 1, 0],
    "max_value": [10000, 20, 150]
})

file = "/home/jesfusion/Documents/ml/ML-Learning-Repository/Saved_Datasets_and_Models/Datasets/model_feature_stats.parquet"

if False: # we run this only once, and change it from True to False
    the_data.to_parquet(file, index = False)


if True:

    model_feature_data = pd.read_parquet(path = file)



# ===================================== DEFINING THE INPUT SCHEMA (THE REQUEST) =====================================

# this places a strict format on the request to the API...

class HouseFeaturesValidator(BaseModel):

    square_feet: int = Field(
        ..., #  The ellipsis (...) indicates that this field is required; the code will raise a validation error if this value is missing
        
        gt = 0, # Square Feet must be greater than 0
        
        description = "Square Feet Measurement of the Property" # This provides a human-readable explanation of the field, which is useful for automated API documentation
    )

    no_bedrooms: int = Field(
        default = 1, # default value is 1

        gt = 0, # must be greater than 0

        le = 30, # must be less than or equal to 30 bedrooms

        description = "Number of bedrooms in the Property"
    )

    loc_score: float # loc_score must come in as a float. If it's not, kick that fool out!



# ===================================== DEFINING THE OUTPUT SCHEMA (THE RESPONSE) =====================================

# this defines the format of the API's response to the User
# This is to ensure we don't send things we dont want to to the user, like sensitive secrets

class APIOutput(BaseModel):

    predicted_price: float

    currency: str = "USD"

    confidence: float


api = FastAPI()


@api.post(
    path = "/mod_pred/property",

    response_model = APIOutput
)

async def house_prediction(
    house_features: HouseFeaturesValidator
):
    
    house_price = (house_features.square_feet * 233.12) + (house_features.no_bedrooms * 4911.34)

    output = {
        "predicted_price": f"{house_price:.2f}",

        "currency": "GBR",

        "confidence": 0.83,

        'random_output': 'Will be Removed' # This won't appear in the outputted JSON Response
    }

    return output


































































































































d_engine = create_engine(os.environ.get("POSTGRE_CONNECT"))


# Initializing an empty table in the database...

if False:

    pd.DataFrame({
        'id': [],
        'current_status': []
    }).to_sql(
        name = 'work_log',

        con = d_engine,

        if_exists = 'replace',

        index = False
    )





class BoxLine(BaseModel):

    """
    Coordinates for an object detection box.
    
    We need strict integers to draw rectangles on the image.
    """

    min_of_x: int
    min_of_y: int
    max_of_x: int
    max_of_y: int

    img_label: str


class MetadataOfImage(BaseModel):

    image_id: Union[int, str] # works same as:
    # image_id: int | str

    name_of_file: str

    # a list of BoundingBox models...
    model_detections: List[BoxLine] = [] # defaults to an empty list, because a model can turn up with 0 detected objects



class RequestForBatchInference(BaseModel):

    name_of_batch: str

    batch_images: List[MetadataOfImage]


class Output(BaseModel):

    name_of_batch: str

    processed: int | float | str

    process_status: str = 'successful'


# ===================================== ENDPOINT =====================================

the_api = FastAPI()

@the_api.post(
    path = '/analysis/img_batch',

    response_model = Output
)

async def batch_processing(
    input: RequestForBatchInference
):
    count_of_processed = 0

    for image in input.batch_images:

        print(f"\nProcessing {image.name_of_file}...\n(ID: {image.image_id})")

        for bbox in image.model_detections:

            print(f"    Found {bbox.img_label}. Co-ordinates: [{bbox.min_of_x}, {bbox.min_of_y}]")

        count_of_processed += 1

    log = pd.DataFrame({
        'id': [input.name_of_batch],

        'current_status': ["Completed"]
    })

    log.to_sql(
        name = 'work_log',

        if_exists = 'append',

        con = d_engine,

        index = False
    )

    output = {
        
        "name_of_batch": input.name_of_batch,

        "processed": count_of_processed,

        "process_status": 'successful'
    }

    return output












