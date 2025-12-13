from fastapi import FastAPI

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
async def home():
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







