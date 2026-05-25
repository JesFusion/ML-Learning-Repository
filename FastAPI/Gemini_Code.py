"""
Segment 2: Request Validation with Pydantic Deep-Dive
====================================================

This module demonstrates Pydantic v2 BaseModel, field validators, 
model validators, complex nested models, discriminated unions, and edge cases.
"""

# Import standard typing utilities: 'Literal' for exact values, 'Optional' for nullable fields, 'Union' for multiple allowed types.
from typing import Literal, Optional, Union
# Import Pydantic tools: 'BaseModel' for schema creation, 'Field' for constraints, validators for custom logic, and config/info tools.
from pydantic import BaseModel, Field, field_validator, model_validator, ConfigDict, ValidationInfo
# Import FastAPI components: 'FastAPI' for the main app instance, 'HTTPException' for throwing API errors.
from fastapi import FastAPI, HTTPException
# Import 'JSONResponse' to allow explicit construction of JSON HTTP responses with custom status codes.
from fastapi.responses import JSONResponse
# Import Python's built-in regular expression module for pattern matching.
import re
# Import Uvicorn, an ASGI web server implementation for Python, used to serve the FastAPI app.
import uvicorn

# Initialize the main FastAPI application instance, setting a custom title that will appear in the Swagger UI docs.
app = FastAPI(title="Segment 2: Pydantic Validation")


# [WHAT] Basic Pydantic BaseModel with Field constraints.
# [WHY] Pydantic validates incoming data, rejecting invalid requests at the framework boundary.
# Define a 'User' data model inheriting from Pydantic's BaseModel to enforce strict schema validation.
class User(BaseModel):
    # [COMPONENT MEANING] BaseModel = Pydantic's core class for defining data schemas with automatic validation and serialization.
    
    # [ARGUMENT MEANING] Field() = Pydantic function for adding validation constraints and metadata to model fields.
    # Declare 'user_id' as an integer and apply a constraint ensuring it is greater than or equal to 1.
    user_id: int = Field(ge=1, description="User ID must be >= 1")
    # [ARGUMENT MEANING] ge = Field constraint meaning "greater than or equal to" for numeric validation.
    
    # Declare 'username' as a string bounded between 3 and 50 characters in length.
    username: str = Field(min_length=3, max_length=50, description="Username length must be 3-50 chars")
    # [ARGUMENT MEANING] min_length/max_length = Field constraints requiring minimum/maximum character count.
    
    # Declare 'email' as a string validated against a regular expression pattern checking for standard email structure.
    # [ARGUMENT MEANING] regex = Field constraint that enforces a regular expression pattern on string fields.
    email: str = Field(regex=r"^[\w\.-]+@[\w\.-]+\.\w+$", description="Valid email format required")
    
    # Declare 'age' as an optional integer, defaulting to None, strictly greater than 0 and less than or equal to 150.
    # [ARGUMENT MEANING] gt/le = Field constraints meaning "greater than" (exclusive) and "less than or equal to".
    age: Optional[int] = Field(default=None, gt=0, le=150, description="Age between 0 and 150")
    
    # Declare 'score' as a float, defaulting to 0.0, and mathematically restricted to be a multiple of 0.5.
    
    # [ARGUMENT MEANING] multiple_of = Field constraint requiring the value to be a multiple of a specified number.
    score: float = Field(default=0.0, multiple_of=0.5, description="Score must be multiple of 0.5")


# [WHAT] Custom field validator (runs on individual field).
# [WHY] Sometimes regex or built-in constraints aren't enough; we need custom logic.
# Define a 'Product' model to demonstrate custom programmatic validation beyond basic Field constraints.
class Product(BaseModel):
    # Enforce 'product_id' to be an integer >= 1.
    product_id: int = Field(ge=1)
    # Enforce 'name' to be a non-empty string up to 100 characters.
    name: str = Field(min_length=1, max_length=100)
    # Enforce 'price' to be a float strictly greater than zero.
    price: float = Field(gt=0)
    # Enforce 'sku' to be a string of at least 5 characters before applying custom validation.
    sku: str = Field(min_length=5)
    
    # [COMPONENT MEANING] field_validator = Decorator (Pydantic v2) for creating custom field-level validation logic with access to field value.
    # Bind the upcoming method to act as a validation hook specifically for the 'sku' field.
    @field_validator("sku")
    # Declare this as a class method because Pydantic validators operate on the class level during model instantiation.
    @classmethod
    # Define the validation function accepting the parsed class and the raw input string, returning a validated string.
    def validate_sku(cls, value: str) -> str:
        # [WHAT]: Custom validation for SKU format (must start with 'SKU-' followed by digits).
        # [HOW]: Check the value and raise ValueError if invalid.
        # Check if the raw input string specifically fails to begin with the exact prefix "SKU-".
        if not value.startswith("SKU-"):
            # Raise a standard Python ValueError, which Pydantic catches and converts into a 422 HTTP response error detail.
            raise ValueError("SKU must start with 'SKU-'")
        # Slice the string from index 4 to the end and check if it contains anything other than numeric digits.
        if not value[4:].isdigit():
            # Raise an error if the suffix contains alphabetic characters or special symbols.
            raise ValueError("SKU suffix must contain only digits")
        # Return the successfully validated SKU string, applying a data transformation to uppercase.
        return value.upper()  # Normalize to uppercase
    
    # Bind the upcoming method to validate the 'price' field specifically.
    @field_validator("price")
    # Ensure the method is treated as a class method by the Python interpreter.
    @classmethod
    # Define the price validation function accepting the class and a float value, returning the parsed float.
    def validate_price(cls, value: float) -> float:
        # [WHAT]: Custom validation ensuring price has at most 2 decimal places.
        # Convert the float to a string, split by the decimal point, access the fractional part [-1], and check its length.
        if len(str(value).split(".")[-1]) > 2:
            # Reject values like 99.999 by raising a ValueError explaining the precision constraint.
            raise ValueError("Price must have at most 2 decimal places")
        # If valid, use Python's built-in round function to strictly enforce the 2 decimal place structure before returning.
        return round(value, 2)


# [WHAT] Model-level validator with access to multiple fields.
# [WHY] Sometimes validation requires comparing multiple fields (e.g., start_date < end_date).
# Define a 'DateRange' model to demonstrate validation that depends on the state of multiple properties simultaneously.
class DateRange(BaseModel):
    # Declare a standard string field for the event's name.
    event_name: str
    # Enforce a strict YYYY-MM-DD string format using a regular expression constraint for the start date.
    start_date: str = Field(regex=r"^\d{4}-\d{2}-\d{2}$", description="YYYY-MM-DD format")
    # Enforce a strict YYYY-MM-DD string format using a regular expression constraint for the end date.
    end_date: str = Field(regex=r"^\d{4}-\d{2}-\d{2}$", description="YYYY-MM-DD format")
    
    # [COMPONENT MEANING] model_validator = Decorator (Pydantic v2) for creating model-level validation that can access multiple fields simultaneously.
    # Apply a model validator to run cross-field logic; mode="after" ensures individual field constraints (like regex) pass first.
    @model_validator(mode="after")
    # [ARGUMENT MEANING] mode="after" = Validation mode parameter that runs validation after type coercion and field validation.
    # Define the validation method; 'self' represents the fully populated Pydantic model instance.
    def validate_date_range(self):
        # [WHAT]: Ensure end_date > start_date.
        # [HOW]: Access multiple fields and compare them.
        # Perform a lexicographical string comparison (which works for YYYY-MM-DD) to ensure chronology.
        if self.end_date <= self.start_date:
            # Raise an error if the end date occurs on or before the start date.
            raise ValueError("end_date must be after start_date")
        # Return the unmodified model instance now that we guarantee it passes cross-validation rules.
        return self


# [WHAT] Polymorphic models using discriminated unions.
# [WHY] APIs need to accept different request types based on a discriminator field.
# Define a model specifically for Email notifications.
class EmailNotification(BaseModel):
    # Restrict the 'type' field to exactly the literal string "email".
    type: Literal["email"]
    # Require a valid email format for the recipient field.
    recipient: str = Field(regex=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    # Require a standard string for the email subject.
    subject: str

# Define a model specifically for SMS notifications.
class SMSNotification(BaseModel):
    # Restrict the 'type' field to exactly the literal string "sms".
    type: Literal["sms"]
    # Require a phone number format starting with a '+' and 1-3 country code digits, followed by 6-14 subscriber digits.
    phone_number: str = Field(regex=r"^\+\d{1,3}\d{6,14}$")
    # Require a standard string for the SMS message body.
    message: str

# Define a model specifically for Push notifications.
class PushNotification(BaseModel):
    # Restrict the 'type' field to exactly the literal string "push".
    type: Literal["push"]
    # Require a standard string representing the target device ID.
    device_id: str
    # Require a standard string for the notification title.
    title: str

# [COMPONENT MEANING] discriminator = Parameter for creating polymorphic unions where a specific field determines which model to use.
# [ARGUMENT MEANING] Literal["email"/"sms"/"push"] = Union type that enforces the exact type value.
# Create a Type Alias using Union to tell Pydantic to accept any of these three models, parsing based on the 'type' literal.
Notification = Union[EmailNotification, SMSNotification, PushNotification]


# [WHAT] Complex nested models demonstrating composition.
# [WHY] Real APIs have nested data structures (user with addresses, orders, etc.).
# Define a reusable nested component model representing a physical Address.
class Address(BaseModel):
    # Require street to be a non-empty string.
    street: str = Field(min_length=1)
    # Require city to be a non-empty string.
    city: str = Field(min_length=1)
    # Restrict country code to exactly 2 characters (e.g., 'US', 'NG').
    country: str = Field(min_length=2, max_length=2, description="ISO 3166-1 alpha-2 country code")
    # Use regex to validate US zip codes in either 5-digit format (12345) or 9-digit format (12345-6789).
    zip_code: str = Field(regex=r"^\d{5}(-\d{4})?$", description="US format with optional +4")

# Define a reusable nested component model representing an Order.
class Order(BaseModel):
    # Enforce order_id as an integer >= 1.
    order_id: int = Field(ge=1)
    # Enforce total monetary amount as a float strictly greater than 0.
    total: float = Field(gt=0)
    # Define a list of strings, ensuring the list contains between 1 and 100 items.
    items: list[str] = Field(min_length=1, max_length=100, description="List of item names")

# Define the parent composition model holding nested Address and Order lists.
class UserProfile(BaseModel):
    # Enforce user_id as an integer >= 1.
    user_id: int = Field(ge=1)
    # Standard string for user's full name.
    name: str
    # Standard string for user's email address.
    email: str
    # Define a list composed of the custom 'Address' Pydantic model, enforcing 1 to 5 addresses per user.
    addresses: list[Address] = Field(min_length=1, max_length=5, description="1-5 addresses allowed")
    # Define a list composed of the custom 'Order' model, utilizing a factory function to default to an empty list if omitted.
    orders: list[Order] = Field(default_factory=list)


# [WHAT] Model configuration for strict validation.
# [WHY] Control how extra fields are handled and other validation behavior.
# Define a strict product model that rejects unexpected payloads.
class StrictProduct(BaseModel):
    # [COMPONENT MEANING] model_config = Pydantic v2 configuration dictionary for model-level settings like extra field handling.
    # [ARGUMENT MEANING] ConfigDict(extra="forbid") = Configuration that raises validation errors when extra fields are present in input data.
    # Set the class configuration dictionary to explicitly throw a 422 error if the client sends fields not defined in this class.
    model_config = ConfigDict(extra="forbid")
    
    # Require a name string.
    name: str
    # Require a price float.
    price: float

# Define a loose product model that silently absorbs unexpected payloads.
class LooseProduct(BaseModel):
    # [ARGUMENT MEANING] ConfigDict(extra="ignore") = Configuration that silently strips extra fields not defined in the model.
    # Set the class configuration to silently drop and ignore any incoming data fields not defined below.
    model_config = ConfigDict(extra="ignore")
    
    # Require a name string.
    name: str
    # Require a price float.
    price: float


# [WHAT] Field aliases for mapping external field names to Python-safe names.
# [WHY] APIs sometimes have kebab-case or camelCase parameters that don't map to Python snake_case.
# Define a model to translate external JSON contract casing (camelCase) to internal Python standards (snake_case).
class UserInput(BaseModel):
    # [ARGUMENT MEANING] alias = Parameter to map external field names (like "user-name") to internal Python-safe names (like "user_name").
    # Internally store as 'user_id', but look for 'userId' in the incoming JSON payload.
    user_id: int = Field(alias="userId")
    # Internally store as 'first_name', but look for 'firstName' in the incoming JSON payload.
    first_name: str = Field(alias="firstName")
    # Internally store as 'last_name', but look for 'lastName' in the incoming JSON payload.
    last_name: str = Field(alias="lastName")
    
    # [WHAT]: Allow both the alias and the original field name.
    # Configure the model to accept either 'userId' OR 'user_id' during initialization and parsing.
    model_config = ConfigDict(populate_by_name=True)


# [WHAT] Default and default_factory for optional fields.
# [WHY] Provide sensible defaults or dynamic defaults for optional fields.
# Define a model showcasing how to handle missing data via static and dynamic defaults.
class Task(BaseModel):
    # Require a mandatory title string.
    title: str
    # [ARGUMENT MEANING] default = Parameter specifying the default value if the field is not provided in the request.
    # Specify that if 'priority' is omitted, it becomes 5, while simultaneously bounding valid inputs between 1 and 10.
    priority: int = Field(default=5, ge=1, le=10)
    # [ARGUMENT MEANING] default_factory = Parameter accepting a callable that generates default values dynamically (useful for mutable defaults).
    # Use 'list' as a callable factory to dynamically generate a new empty list instance to prevent mutable default reference bugs.
    tags: list[str] = Field(default_factory=list)


# [WHAT] Constrained types for inline validation.
# [WHY] Sometimes defining a custom class is overkill; constrained types are quick shortcuts.
# [WATCH OUT]: constr() and conint() are somewhat discouraged in Pydantic v2; prefer Field() instead.
# Import legacy constrained type generator functions from Pydantic.
from pydantic import constr, conint

# Define a user model using inline type constraints rather than Field() parameters.
class SimpleUser(BaseModel):
    # [COMPONENT MEANING] constr() = Pydantic function creating a constrained string type with validation rules inline.
    # Define a string property bounded between 3 and 50 characters, ignoring type checker warnings.
    username: constr(min_length=3, max_length=50)  # type: ignore
    # [COMPONENT MEANING] conint() = Pydantic function creating a constrained integer type with validation rules inline.
    # Define an integer property bounded between 0 and 150, ignoring type checker warnings.
    age: conint(ge=0, le=150)  # type: ignore


# ============================================================================
# ENDPOINTS DEMONSTRATING VALIDATION
# ============================================================================

# Register a POST route at "/users", overriding the default 200 status code with a 201 (Created) HTTP response code.
@app.post("/users", status_code=201)
# Define an asynchronous route handler function that expects a payload matching the 'User' Pydantic model.
async def create_user(user: User):
    # [WHAT]: Pydantic automatically validates the incoming request body against the User model.
    # [HOW]: If validation fails, FastAPI returns a 422 Unprocessable Entity response.
    # Construct and return an explicit JSON response payload, serializing the validated user model back to a dictionary.
    return JSONResponse(content={"message": f"User {user.username} created", "user": user.model_dump()}, status_code=201)


# Register a POST route for product creation, automatically enforcing the 201 status code on success.
@app.post("/products", status_code=201)
# Define the async handler requiring the request body to validate against the custom validation logic in the 'Product' model.
async def create_product(product: Product):
    # [WHAT]: Product model with custom field validators.
    # Return success confirmation alongside the dumped product data (which will include the normalized uppercase SKU).
    return JSONResponse(content={"message": f"Product {product.name} created", "product": product.model_dump()}, status_code=201)


# Register a POST route for event creation returning 201 status code.
@app.post("/events", status_code=201)
# Define the async handler requiring payload validation against the 'DateRange' model (which uses the multi-field model_validator).
async def create_event(event: DateRange):
    # [WHAT]: DateRange model with model-level validator.
    # Return success confirmation alongside the serialized event payload.
    return JSONResponse(content={"message": f"Event {event.event_name} created", "event": event.model_dump()}, status_code=201)


# Register a POST route to handle all notification types, returning 201 Created.
@app.post("/notifications", status_code=201)
# Define the handler expecting the 'Notification' polymorphic union; FastAPI will figure out the subtype automatically.
async def send_notification(notification: Notification):
    # [WHAT]: Polymorphic request body using discriminated union.
    # [HOW]: Pydantic automatically selects the correct model based on the 'type' field.
    # Return confirmation and dump the parsed data back out to JSON format.
    return JSONResponse(content={"message": "Notification sent", "data": notification.model_dump()}, status_code=201)


# Register a POST route for complex profile creation returning 201 status code.
@app.post("/user-profiles", status_code=201)
# Define the handler expecting the deeply nested 'UserProfile' model containing internal lists of objects.
async def create_profile(profile: UserProfile):
    # [WHAT]: Complex nested model with lists of nested objects.
    # Return confirmation and recursively dump the entire tree of validated nested models to a dictionary.
    return JSONResponse(content={"message": f"Profile for {profile.name} created", "profile": profile.model_dump()}, status_code=201)


# Register a POST route for strict product configurations.
@app.post("/strict-products", status_code=201)
# Define handler expecting the 'StrictProduct' model, which will hard-fail (422) if unknown fields arrive.
async def create_strict_product(product: StrictProduct):
    # [WHAT]: StrictProduct forbids extra fields; sending unknown fields causes 422 error.
    # Return success and serialize the strictly validated product data.
    return JSONResponse(content={"message": "Strict product created", "product": product.model_dump()}, status_code=201)


# Register a POST route for loose product configurations.
@app.post("/loose-products", status_code=201)
# Define handler expecting the 'LooseProduct' model, which silently absorbs and discards unknown keys.
async def create_loose_product(product: LooseProduct):
    # [WHAT]: LooseProduct ignores extra fields silently.
    # Return success and dump the data (which will inherently omit the dropped extra keys).
    return JSONResponse(content={"message": "Loose product created", "product": product.model_dump()}, status_code=201)


# Register a POST route to demonstrate input aliasing.
@app.post("/user-input", status_code=201)
# Define handler expecting 'UserInput', which parses camelCase incoming JSON into snake_case python variables.
async def create_user_input(user: UserInput):
    # [WHAT]: Aliases allow external camelCase to map to internal snake_case.
    # Return success and explicitly re-export the dumped dictionary using the external camelCase aliases via by_alias=True.
    return JSONResponse(content={"message": "User input received", "user": user.model_dump(by_alias=True)}, status_code=201)


# Register a POST route demonstrating default values and factories.
@app.post("/tasks", status_code=201)
# Define handler expecting 'Task', which auto-fills priority and tags if missing.
async def create_task(task: Task):
    # [WHAT]: Task with default and default_factory fields.
    # Return success and the fully populated task dictionary including newly generated defaults.
    return JSONResponse(content={"message": f"Task '{task.title}' created", "task": task.model_dump()}, status_code=201)


# Register a standard GET route to expose the auto-generated JSON schema.
@app.get("/validation-schema")
# Define handler function taking no arguments.
async def get_schema():
    # [WHAT]: Return the JSON schema of the User model.
    # [HOW]: Pydantic generates OpenAPI/JSON schema automatically.
    # Call the model_json_schema() classmethod on the User model to extract the standard JSON schema dictionary and return it.
    return JSONResponse(content=User.model_json_schema())


# Entry point block that executes only if this file is run directly (not when imported as a module).
if __name__ == "__main__":
    # ========== TESTING SUITE ==========
    # Import the Pytest framework programmatically to run tests directly from this file.
    import pytest
    # Import TestClient from FastAPI (which wraps Starlette's TestClient) to mock HTTP requests in memory.
    from fastapi.testclient import TestClient

    # [WHAT]: Initialize TestClient to bypass the network layer and test ASGI directly.
    # [WHY]: Instantiating the client at the module level allows Pytest to discover and reuse it without the overhead of spinning up an actual Uvicorn server.
    # Initialize the synchronous TestClient with our FastAPI app instance.
    client = TestClient(app)


    # [COMPONENT MEANING] pytest.mark.parametrize = A decorator that executes a single test function multiple times with different sets of arguments.
    # [ARGUMENT MEANING] argnames = Comma-separated string defining the variable names injected into the test function.
    # [ARGUMENT MEANING] argvalues = A list of tuples, each representing a discrete test case iteration.
    # Apply the parametrization decorator mapping three variables to a list of five distinct tuple permutations.
    @pytest.mark.parametrize(
        "payload, expected_status, expected_detail_loc",
        [
            # Happy Path
            # Valid tuple: Correct datatypes, boundaries respected. Expect 201 Created and no error location.
            ({"user_id": 1, "username": "valid_user", "email": "test@domain.com", "age": 25, "score": 10.5}, 201, None),
            # Blocking Traps & Edge Cases
            # Invalid tuple: user_id violates ge=1 boundary. Expect 422 error tracing back to ["body", "user_id"].
            ({"user_id": 0, "username": "valid_user", "email": "test@domain.com"}, 422, ["body", "user_id"]), # Less than 1
            # Invalid tuple: username violates min_length=3 boundary. Expect 422 error tracing back to ["body", "username"].
            ({"user_id": 1, "username": "ab", "email": "test@domain.com"}, 422, ["body", "username"]), # Min length 3
            # Invalid tuple: email violates regex constraint. Expect 422 error tracing back to ["body", "email"].
            ({"user_id": 1, "username": "valid_user", "email": "invalid-email"}, 422, ["body", "email"]), # Regex fail
            # Invalid tuple: age violates le=150 boundary. Expect 422 error tracing back to ["body", "age"].
            ({"user_id": 1, "username": "valid_user", "email": "test@domain.com", "age": 200}, 422, ["body", "age"]), # Age > 150
            # Invalid tuple: score violates multiple_of=0.5 constraint. Expect 422 error tracing back to ["body", "score"].
            ({"user_id": 1, "username": "valid_user", "email": "test@domain.com", "score": 10.3}, 422, ["body", "score"]), # Not multiple of 0.5
        ]
    )
    # Define the test function, receiving the parameterized variables unpacked into arguments.
    def test_create_user_validation_boundaries(payload, expected_status, expected_detail_loc):
        """[WHAT]: Rigorously tests the /users endpoint against Pydantic Field constraints."""
        
        # [HOW]: Post the parameterized payload and capture the response.
        # [WATCH OUT]: Always explicitly pass json=payload to ensure proper Content-Type headers are set automatically by TestClient.
        # Execute an in-memory POST request to /users, automatically serializing the payload dictionary into JSON format.
        response = client.post("/users", json=payload)
        
        # Assert the HTTP status code returned matches our expected expectation tuple variable.
        assert response.status_code == expected_status
        
        # Check if the expected status signifies a successful creation scenario.
        if expected_status == 201:
            # Parse the returned JSON response content into a Python dictionary.
            data = response.json()
            # Assert the message string dynamically constructed by the endpoint matches exactly.
            assert data["message"] == f"User {payload['username']} created"
            # Assert the returned nested user structure perfectly matches the submitted ID.
            assert data["user"]["user_id"] == payload["user_id"]
        # Handle failure cases (status != 201).
        else:
            # [HOW]: Verify exactly which field triggered the 422 Unprocessable Entity.
            # Extract the Pydantic error details list from the standard 422 JSON response body.
            errors = response.json()["detail"]
            # Assert that within the list of validation errors, at least one points directly to the expected field location map.
            assert any(err["loc"] == expected_detail_loc for err in errors)
        # [WHAT ELSE]: We could leverage the `Faker` library to generate randomized boundary data for deeper fuzz testing.


    # Define a test verifying our programmatic @field_validator logic defined in the Product model.
    def test_create_product_custom_field_validators():
        """[WHAT]: Validates the custom @field_validator logic for SKUs and Prices."""
        
        # [WHY]: We use the TestClient context manager syntax here to demonstrate lifecycle awareness, ensuring any hypothetical state/lifespan handlers are initialized.
        # Open a scoped TestClient context manager to properly simulate app startup/shutdown lifecycle events.
        with TestClient(app) as lifecycle_client:
            # Happy Path
            # Create a fully compliant payload dictionary mapping to the Product model requirements.
            valid_payload = {"product_id": 100, "name": "Keyboard", "price": 99.99, "sku": "SKU-12345"}
            # Post the valid payload and capture the HTTP response.
            resp_valid = lifecycle_client.post("/products", json=valid_payload)
            # Assert successful HTTP code 201 Created.
            assert resp_valid.status_code == 201
            # Assert that the SKU string was mutated/normalized to uppercase by the custom validator.
            assert resp_valid.json()["product"]["sku"] == "SKU-12345" # Normalized to uppercase
            
            # Test Custom ValueError Traps
            # Create a shallow copy of valid_payload overriding the SKU to trigger the 'prefix' ValueError.
            invalid_sku_prefix = {**valid_payload, "sku": "BAD-12345"}
            # Post the invalid prefix payload and capture the HTTP response.
            resp_sku_prefix = lifecycle_client.post("/products", json=invalid_sku_prefix)
            # Assert that the custom ValueError was caught and translated to a 422 Unprocessable Entity.
            assert resp_sku_prefix.status_code == 422
            # Assert that our explicitly written string error message was piped directly into the HTTP response body.
            assert "SKU must start with 'SKU-'" in resp_sku_prefix.text

            # Create a shallow copy overriding the SKU to trigger the 'suffix' ValueError.
            invalid_sku_suffix = {**valid_payload, "sku": "SKU-123ABC"}
            # Post the invalid suffix payload and capture the HTTP response.
            resp_sku_suffix = lifecycle_client.post("/products", json=invalid_sku_suffix)
            # Assert HTTP 422 rejection.
            assert resp_sku_suffix.status_code == 422
            # Assert that the specific digit-only error message is present in the response text.
            assert "SKU suffix must contain only digits" in resp_sku_suffix.text

            # Create a shallow copy overriding the price to have 3 decimal places.
            invalid_price = {**valid_payload, "price": 99.999}
            # Post the invalid price payload and capture the HTTP response.
            resp_price = lifecycle_client.post("/products", json=invalid_price)
            # Assert HTTP 422 rejection.
            assert resp_price.status_code == 422
            # Assert the precise decimal place error message is forwarded to the client.
            assert "Price must have at most 2 decimal places" in resp_price.text


    # Define a test to verify cross-field validation rules via @model_validator.
    def test_create_event_model_validator():
        """[WHAT]: Verifies @model_validator multi-field validation."""
        
        # Happy Path
        # Create a dictionary representing a chronologically sound event range.
        valid_payload = {"event_name": "Conference", "start_date": "2026-01-01", "end_date": "2026-01-05"}
        # Assert immediately that POSTing this valid dictionary yields HTTP 201.
        assert client.post("/events", json=valid_payload).status_code == 201
        
        # Logical Trap: End date before start date
        # Create a dictionary deliberately breaking chronology to trigger our custom logic.
        invalid_payload = {"event_name": "Conference", "start_date": "2026-01-05", "end_date": "2026-01-01"}
        # Post the logically flawed payload and capture the HTTP response.
        resp = client.post("/events", json=invalid_payload)
        # Assert HTTP 422 rejection.
        assert resp.status_code == 422
        # Assert our specific cross-field error message appears in the raw response text.
        assert "end_date must be after start_date" in resp.text


    # Define a test to ensure Pydantic effectively routes request payloads based on the union literal.
    def test_polymorphic_notification_routing():
        """[WHAT]: Tests discriminated union model selection based on the 'type' literal."""
        
        # [HOW]: Submit varying payloads that share a generic endpoint, proving Pydantic correctly routes schema validation based on the 'type' key.
        # Define a payload specific to the Email structure containing the "email" literal type flag.
        email_payload = {"type": "email", "recipient": "user@test.com", "subject": "Hello"}
        # Define a payload specific to the SMS structure containing the "sms" literal type flag.
        sms_payload = {"type": "sms", "phone_number": "+1234567890", "message": "Alert"}
        # Define a payload specific to the Push structure containing the "push" literal type flag.
        push_payload = {"type": "push", "device_id": "DEV123", "title": "Popup"}
        
        # Iterate over all three polymorphic dictionaries in a single execution loop.
        for payload in [email_payload, sms_payload, push_payload]:
            # Post the current polymorphic payload to the unified generic endpoint.
            resp = client.post("/notifications", json=payload)
            # Assert successful creation for every polymorphic permutation.
            assert resp.status_code == 201
            # Assert that the serialized type matched the exact literal type submitted, proving the correct sub-model processed it.
            assert resp.json()["data"]["type"] == payload["type"]
            
        # [WATCH OUT]: Omitting the literal discriminator key completely must trigger a strict 422 error.
        # Define a dictionary lacking the 'type' literal flag completely, rendering Pydantic unable to route it.
        bad_payload = {"device_id": "DEV123", "title": "Popup"}
        # Assert that sending this ambiguous payload immediately causes a 422 validation failure.
        assert client.post("/notifications", json=bad_payload).status_code == 422


    # Define a test for checking deeply hierarchical validation involving lists of objects.
    def test_complex_nested_models():
        """[WHAT]: Verifies deeply nested JSON object parsing and list validation."""
        
        # Define a complex nested dictionary mirroring the structure of the composed UserProfile > Address/Order hierarchy.
        payload = {
            "user_id": 1,
            "name": "Jane",
            "email": "jane@test.com",
            # Include a list containing one dictionary mapped to the Address schema constraints.
            "addresses": [
                {"street": "123 Main", "city": "Cityville", "country": "US", "zip_code": "12345"}
            ],
            # Include a list containing one dictionary mapped to the Order schema constraints.
            "orders": [
                {"order_id": 101, "total": 250.0, "items": ["Monitor", "Mouse"]}
            ]
        }
        
        # Post the massive nested dictionary to the profiles endpoint.
        resp = client.post("/user-profiles", json=payload)
        # Assert HTTP 201 Success signifying total tree validation passing.
        assert resp.status_code == 201
        # Extract the serialized parent profile dictionary from the response wrapper.
        data = resp.json()["profile"]
        # Assert that exactly 1 address was successfully mapped and returned in the list.
        assert len(data["addresses"]) == 1
        # Drill down into the orders list and assert the nested total matched the input float exactly.
        assert data["orders"][0]["total"] == 250.0


    # Define a test to guarantee model config behaviors regarding extra payload fields.
    def test_config_dict_extra_fields():
        """[WHAT]: Validates ConfigDict 'forbid' vs 'ignore' behavior."""
        
        # Define a payload containing an illegal 'unexpected_field' not listed in any model schema.
        payload = {"name": "Widget", "price": 10.0, "unexpected_field": "Hacker"}
        
        # Strict Model: Expect failure due to extra field
        # Post the rogue payload to the endpoint bound to StrictProduct (extra="forbid").
        strict_resp = client.post("/strict-products", json=payload)
        # Assert the strict endpoint caught the extra field and rejected it with HTTP 422.
        assert strict_resp.status_code == 422
        # Verify the specific Pydantic error type thrown matches "extra_forbidden".
        assert strict_resp.json()["detail"][0]["type"] == "extra_forbidden"
        
        # Loose Model: Expect success, but the extra field is silently discarded
        # Post the exact same rogue payload to the endpoint bound to LooseProduct (extra="ignore").
        loose_resp = client.post("/loose-products", json=payload)
        # Assert success despite the rogue field, meaning validation passed.
        assert loose_resp.status_code == 201
        # Assert the "unexpected_field" was safely stripped out of the returned parsed data automatically.
        assert "unexpected_field" not in loose_resp.json()["product"]


    # Define a test for checking Pydantic's alias mapping capabilities.
    def test_user_input_aliases():
        """[WHAT]: Tests mapping of camelCase aliases to snake_case backend fields."""
        
        # [HOW]: Send camelCase as expected by the external contract.
        # Construct a dictionary matching the external camelCase format expected by external clients.
        payload = {"userId": 5, "firstName": "John", "lastName": "Doe"}
        # Post the camelCase dictionary to the endpoint.
        resp = client.post("/user-input", json=payload)
        
        # Assert HTTP 201 validation success, proving the aliases caught the external keys.
        assert resp.status_code == 201
        # [WATCH OUT]: Because `by_alias=True` is used in the endpoint's model_dump(), the response will contain the camelCase keys.
        # Extract the serialized user payload from the response wrapper.
        data = resp.json()["user"]
        # Assert that the data returned maintains the camelCase 'userId' key structure instead of snake_case.
        assert data["userId"] == 5
        # Assert that the data returned maintains the camelCase 'firstName' key structure instead of snake_case.
        assert data["firstName"] == "John"


    # Define a test verifying that missing dictionary fields are correctly populated by defaults and factories.
    def test_task_defaults_and_factories():
        """[WHAT]: Asserts that default values and default_factories automatically populate missing payload data."""
        
        # Define a minimal dictionary missing optional fields to trigger default fallback logic.
        payload = {"title": "Learn Pytest"}
        # Post the sparse dictionary to the tasks endpoint.
        resp = client.post("/tasks", json=payload)
        
        # Assert HTTP 201 validation success.
        assert resp.status_code == 201
        # Extract the successfully parsed and fully padded dictionary from the response wrapper.
        data = resp.json()["task"]
        # Assert the missing priority key was auto-populated with the static default integer 5.
        assert data["priority"] == 5 # Populated by default=5
        # Assert the missing tags key was auto-populated with an empty list via the list() default_factory.
        assert data["tags"] == []    # Populated by default_factory=list


    # Define a test verifying automatic JSON Schema documentation creation.
    def test_validation_schema_generation():
        """[WHAT]: Checks that the automatic OpenAPI JSON schema generation endpoint functions correctly."""
        
        # Execute an in-memory GET request to retrieve the exposed JSON schema configuration.
        resp = client.get("/validation-schema")
        # Assert HTTP 200 OK since this is a simple, un-parameterized GET request.
        assert resp.status_code == 200
        # Parse the raw JSON schema payload into a Python dictionary.
        schema = resp.json()
        
        # Assert that the top-level "properties" dict describing the model structure exists in the schema.
        assert "properties" in schema
        # Assert that the user_id property definition is successfully exported to the schema tree.
        assert "user_id" in schema["properties"]
        # Assert that our custom regex rule is explicitly visible in the exposed schema docs for the email field.
        assert schema["properties"]["email"]["pattern"] == "^[\\w\\.-]+@[\\w\\.-]+\\.\\w+$"



    # [HOW]: Allows running this script directly to execute the tests.
    # Import the sys module to interact directly with the python runtime environment and exit codes.
    import sys
    # Print a standard output log message indicating test initialization.
    print("[INFO] Initiating QA Execution Protocol...")
    # Invoke pytest.main pointing to this specific script file and forcibly exit python with its final test return code status.
    sys.exit(pytest.main(["-v", "-s", __file__]))