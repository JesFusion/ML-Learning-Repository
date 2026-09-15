#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# FastAPI Lean-but-Deep: 10-Segment Production Learning Path
# Generated: Comprehensive, executable code for enterprise mastery
# ============================================================================

WORKSPACE=$(mktemp -d)
cd "$WORKSPACE"
trap 'rm -rf "$WORKSPACE"' EXIT

echo "================================================================================"
echo "FASTAPI MASTERCLASS: Segment Generation Starting"
echo "Workspace: $WORKSPACE"
echo "================================================================================"

# Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -q fastapi uvicorn pydantic sqlalchemy aiosqlite redis aioredis orjson httpx --upgrade

echo ""
echo "================================================================================"
echo "SEGMENT 1: FastAPI Core Architecture & ASGI Request Lifecycle"
echo "================================================================================"

cat << 'SEGMENT_1_EOF' > segment_1_core_architecture.py
"""
Segment 1: FastAPI Core Architecture & ASGI Request Lifecycle
=============================================================

This module demonstrates ASGI fundamentals, Starlette's routing engine,
Uvicorn's event loop management, and proper async/sync execution contexts.
"""

import asyncio
from contextlib import asynccontextmanager
from typing import Optional
from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
import uvicorn

# [COMPONENT MEANING] FastAPI = The modern Python web framework built on ASGI + Starlette that handles async HTTP routing and dependency injection.

# [WHAT] Lifespan events management (startup/shutdown hooks)
# [WHY] We need to establish database connections, cache warming, or cleanup resources at application boot and graceful shutdown.
# [HOW] Using the async context manager approach (lifespan) instead of deprecated @app.on_event().

@asynccontextmanager
async def lifespan(app: FastAPI):
    # [WHAT]: Startup logic runs once before the application accepts requests.
    print("[STARTUP] Initializing application resources...")
    # Simulate database connection pool initialization
    startup_state = {"db": "Connected", "cache": "Warmed", "workers": 4}
    app.state.startup_data = startup_state
    print(f"[STARTUP] State initialized: {startup_state}")
    
    yield  # Application runs here
    
    # [WHAT]: Shutdown logic runs once during graceful shutdown, AFTER server stops accepting new connections.
    print("[SHUTDOWN] Cleaning up application resources...")
    if hasattr(app.state, "startup_data"):
        del app.state.startup_data
    print("[SHUTDOWN] Cleanup complete")

# [COMPONENT MEANING] FastAPI constructor with lifespan = Sets up the application with async context manager for startup/shutdown logic.
app = FastAPI(title="Segment 1: Core Architecture", lifespan=lifespan)


# [WHAT] Basic async endpoint demonstrating event loop cooperation
# [WHY] Non-blocking I/O is the religion. Async endpoints yield control during I/O, allowing Uvicorn to handle other requests.
@app.get("/sync-endpoint")
def sync_endpoint():
    # [WHAT]: Synchronous function - BLOCKS the event loop thread.
    # [WATCH OUT]: Never do blocking I/O (time.sleep, requests.get, DB queries) in async contexts without run_in_executor.
    result = {"message": "I am sync", "blocks_event_loop": True}
    return JSONResponse(content=result, status_code=200)

@app.get("/async-endpoint")
async def async_endpoint():
    # [WHAT]: Async function - YIELDS control to event loop during await.
    # [HOW]: Uses await to suspend execution, allowing other requests to be processed.
    await asyncio.sleep(0.1)  # Simulate I/O operation
    result = {"message": "I am async", "blocks_event_loop": False}
    return JSONResponse(content=result, status_code=200)


# [WHAT] Demonstrating the Request object (Starlette internals exposed).
# [WHY] Request object provides access to headers, query params, body, and connection metadata.
@app.post("/inspect-request")
async def inspect_request(request: Request):
    # [COMPONENT MEANING] Request = Starlette object representing the incoming HTTP request with full metadata.
    
    # [HOW] Extract various request properties
    method = request.method  # HTTP method (GET, POST, etc.)
    url = str(request.url)  # Full URL including query params
    headers = dict(request.headers)  # Headers as dictionary
    client_host = request.client.host if request.client else "Unknown"
    path = request.url.path  # Just the path part
    query_params = dict(request.query_params)  # Query string as dictionary
    
    # [WHAT] Reading the request body (must be awaited as it's an I/O operation).
    body = await request.body()  # Raw bytes
    
    return JSONResponse(content={
        "method": method,
        "path": path,
        "headers": headers,
        "client_host": client_host,
        "query_params": query_params,
        "body_bytes_length": len(body),
    }, status_code=200)


# [WHAT] Custom Response object with explicit status and headers.
# [WHY] Response objects give us fine-grained control over HTTP metadata.
@app.get("/custom-response")
async def custom_response():
    # [COMPONENT MEANING] Response = Starlette object for building custom HTTP responses with status codes and headers.
    
    # [HOW] Create a Response with explicit status code and custom headers
    response = Response(
        content="Custom response body",
        status_code=201,  # Explicit status code
        headers={"X-Custom-Header": "MyValue", "X-Powered-By": "FastAPI-Segment1"}
    )
    return response


# [WHAT] Demonstrating async context and event loop state.
# [WHY] Understanding the event loop is critical for debugging async issues and preventing blocking.
@app.get("/event-loop-info")
async def event_loop_info():
    # [COMPONENT MEANING] asyncio.get_event_loop() = Retrieves the currently running event loop instance.
    
    loop = asyncio.get_event_loop()
    
    return JSONResponse(content={
        "loop_is_running": loop.is_running(),
        "loop_type": type(loop).__name__,
        "message": "This endpoint is running INSIDE the event loop (Uvicorn's context)",
    }, status_code=200)


# [WHAT] Demonstrating the run_in_executor pattern for blocking I/O.
# [WHY] Some libraries (requests, psycopg2) are blocking. We must offload them to thread pool without choking the event loop.
@app.get("/blocking-safe")
async def blocking_safe():
    # [COMPONENT MEANING] loop.run_in_executor() = Method to execute blocking synchronous code in a thread pool without blocking the event loop.
    
    def blocking_operation():
        # [WHAT]: This simulates a blocking I/O operation (like a DB query or HTTP request).
        # [HOW]: This runs in a separate thread, NOT blocking the event loop.
        import time
        time.sleep(0.5)  # Simulate blocking operation
        return {"blocking_result": "Completed in background thread"}
    
    loop = asyncio.get_event_loop()
    # [ARGUMENT MEANING] run_in_executor = Schedules blocking_operation to run in the default ThreadPoolExecutor.
    result = await loop.run_in_executor(None, blocking_operation)
    
    return JSONResponse(content=result, status_code=200)


# [WHAT] Demonstrating multiple HTTP methods on the same endpoint.
# [WHY] RESTful APIs need different handlers for different HTTP verbs with proper semantics.
@app.get("/resource/{resource_id}")
async def get_resource(resource_id: int):
    # [WHAT]: GET retrieves a resource (idempotent, no side effects).
    return JSONResponse(content={"action": "GET", "resource_id": resource_id}, status_code=200)

@app.post("/resource")
async def create_resource():
    # [WHAT]: POST creates a new resource (idempotent in the general sense, but creates new state).
    return JSONResponse(content={"action": "POST", "new_id": 99}, status_code=201)

@app.put("/resource/{resource_id}")
async def update_resource_full(resource_id: int):
    # [WHAT]: PUT replaces the entire resource (idempotent).
    return JSONResponse(content={"action": "PUT", "resource_id": resource_id}, status_code=200)

@app.patch("/resource/{resource_id}")
async def update_resource_partial(resource_id: int):
    # [WHAT]: PATCH partially updates a resource.
    return JSONResponse(content={"action": "PATCH", "resource_id": resource_id}, status_code=200)

@app.delete("/resource/{resource_id}")
async def delete_resource(resource_id: int):
    # [WHAT]: DELETE removes a resource.
    return JSONResponse(content={"action": "DELETE", "resource_id": resource_id, "deleted": True}, status_code=204)


# [WHAT] Edge case: Blocking the event loop (ANTIPATTERN - DO NOT DO THIS).
# [WHY] Demonstrating what happens when you don't use async properly.
@app.get("/blocking-bad")
def blocking_bad():
    # [WATCH OUT]: This is a SYNCHRONOUS endpoint that does blocking I/O.
    # For a single request, it blocks the event loop for this duration.
    # If requests pile up, they queue and the server becomes unresponsive.
    import time
    time.sleep(1)  # BLOCKING - NEVER DO THIS IN PRODUCTION
    return JSONResponse(content={"message": "This blocked the event loop"}, status_code=200)


# [WHAT] Health check endpoint (common in production).
# [WHY] Kubernetes and load balancers use health checks to determine if the app is alive.
@app.get("/health")
async def health():
    # [WHAT]: Lightweight liveness probe.
    # [HOW]: Return early with minimal processing.
    return JSONResponse(content={"status": "healthy", "service": "segment-1"}, status_code=200)


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8001")
    print("[INFO] Visit http://localhost:8001/docs for interactive API documentation")
    print("[INFO] Try these endpoints:")
    print("  - GET /sync-endpoint")
    print("  - GET /async-endpoint")
    print("  - POST /inspect-request (send JSON body)")
    print("  - GET /custom-response")
    print("  - GET /event-loop-info")
    print("  - GET /blocking-safe")
    print("  - GET /resource/42")
    print("  - GET /health")
    print("\n")
    
    # [COMPONENT MEANING] uvicorn.run() = Entry point that starts the ASGI server with Uvicorn.
    uvicorn.run(
        app=app,
        host="127.0.0.1",
        port=8001,
        workers=1,  # Single worker for learning (production uses more)
        log_level="info"
    )
SEGMENT_1_EOF

echo "[✓] Segment 1 generated: segment_1_core_architecture.py"


echo ""
echo "================================================================================"
echo "SEGMENT 2: Request Validation with Pydantic Deep-Dive"
echo "================================================================================"

cat << 'SEGMENT_2_EOF' > segment_2_pydantic_validation.py
"""
Segment 2: Request Validation with Pydantic Deep-Dive
====================================================

This module demonstrates Pydantic v2 BaseModel, field validators, 
model validators, complex nested models, discriminated unions, and edge cases.
"""

from typing import Literal, Optional, Union
from pydantic import BaseModel, Field, field_validator, model_validator, ConfigDict, ValidationInfo
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
import re
import uvicorn

app = FastAPI(title="Segment 2: Pydantic Validation")


# [WHAT] Basic Pydantic BaseModel with Field constraints.
# [WHY] Pydantic validates incoming data, rejecting invalid requests at the framework boundary.
class User(BaseModel):
    # [COMPONENT MEANING] BaseModel = Pydantic's core class for defining data schemas with automatic validation and serialization.
    
    # [ARGUMENT MEANING] Field() = Pydantic function for adding validation constraints and metadata to model fields.
    user_id: int = Field(ge=1, description="User ID must be >= 1")
    # [ARGUMENT MEANING] ge = Field constraint meaning "greater than or equal to" for numeric validation.
    
    username: str = Field(min_length=3, max_length=50, description="Username length must be 3-50 chars")
    # [ARGUMENT MEANING] min_length/max_length = Field constraints requiring minimum/maximum character count.
    
    email: str = Field(regex=r"^[\w\.-]+@[\w\.-]+\.\w+$", description="Valid email format required")
    # [ARGUMENT MEANING] regex = Field constraint that enforces a regular expression pattern on string fields.
    
    age: Optional[int] = Field(default=None, gt=0, le=150, description="Age between 0 and 150")
    # [ARGUMENT MEANING] gt/le = Field constraints meaning "greater than" (exclusive) and "less than or equal to".
    
    score: float = Field(default=0.0, multiple_of=0.5, description="Score must be multiple of 0.5")
    # [ARGUMENT MEANING] multiple_of = Field constraint requiring the value to be a multiple of a specified number.


# [WHAT] Custom field validator (runs on individual field).
# [WHY] Sometimes regex or built-in constraints aren't enough; we need custom logic.
class Product(BaseModel):
    product_id: int = Field(ge=1)
    name: str = Field(min_length=1, max_length=100)
    price: float = Field(gt=0)
    sku: str = Field(min_length=5)
    
    # [COMPONENT MEANING] field_validator = Decorator (Pydantic v2) for creating custom field-level validation logic with access to field value.
    @field_validator("sku")
    @classmethod
    def validate_sku(cls, value: str) -> str:
        # [WHAT]: Custom validation for SKU format (must start with 'SKU-' followed by digits).
        # [HOW]: Check the value and raise ValueError if invalid.
        if not value.startswith("SKU-"):
            raise ValueError("SKU must start with 'SKU-'")
        if not value[4:].isdigit():
            raise ValueError("SKU suffix must contain only digits")
        return value.upper()  # Normalize to uppercase
    
    @field_validator("price")
    @classmethod
    def validate_price(cls, value: float) -> float:
        # [WHAT]: Custom validation ensuring price has at most 2 decimal places.
        if len(str(value).split(".")[-1]) > 2:
            raise ValueError("Price must have at most 2 decimal places")
        return round(value, 2)


# [WHAT] Model-level validator with access to multiple fields.
# [WHY] Sometimes validation requires comparing multiple fields (e.g., start_date < end_date).
class DateRange(BaseModel):
    event_name: str
    start_date: str = Field(regex=r"^\d{4}-\d{2}-\d{2}$", description="YYYY-MM-DD format")
    end_date: str = Field(regex=r"^\d{4}-\d{2}-\d{2}$", description="YYYY-MM-DD format")
    
    # [COMPONENT MEANING] model_validator = Decorator (Pydantic v2) for creating model-level validation that can access multiple fields simultaneously.
    @model_validator(mode="after")
    # [ARGUMENT MEANING] mode="after" = Validation mode parameter that runs validation after type coercion and field validation.
    def validate_date_range(self):
        # [WHAT]: Ensure end_date > start_date.
        # [HOW]: Access multiple fields and compare them.
        if self.end_date <= self.start_date:
            raise ValueError("end_date must be after start_date")
        return self


# [WHAT] Polymorphic models using discriminated unions.
# [WHY] APIs need to accept different request types based on a discriminator field.
class EmailNotification(BaseModel):
    type: Literal["email"]
    recipient: str = Field(regex=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    subject: str

class SMSNotification(BaseModel):
    type: Literal["sms"]
    phone_number: str = Field(regex=r"^\+\d{1,3}\d{6,14}$")
    message: str

class PushNotification(BaseModel):
    type: Literal["push"]
    device_id: str
    title: str

# [COMPONENT MEANING] discriminator = Parameter for creating polymorphic unions where a specific field determines which model to use.
# [ARGUMENT MEANING] Literal["email"/"sms"/"push"] = Union type that enforces the exact type value.
Notification = Union[EmailNotification, SMSNotification, PushNotification]


# [WHAT] Complex nested models demonstrating composition.
# [WHY] Real APIs have nested data structures (user with addresses, orders, etc.).
class Address(BaseModel):
    street: str = Field(min_length=1)
    city: str = Field(min_length=1)
    country: str = Field(min_length=2, max_length=2, description="ISO 3166-1 alpha-2 country code")
    zip_code: str = Field(regex=r"^\d{5}(-\d{4})?$", description="US format with optional +4")

class Order(BaseModel):
    order_id: int = Field(ge=1)
    total: float = Field(gt=0)
    items: list[str] = Field(min_length=1, max_length=100, description="List of item names")

class UserProfile(BaseModel):
    user_id: int = Field(ge=1)
    name: str
    email: str
    addresses: list[Address] = Field(min_length=1, max_length=5, description="1-5 addresses allowed")
    orders: list[Order] = Field(default_factory=list)


# [WHAT] Model configuration for strict validation.
# [WHY] Control how extra fields are handled and other validation behavior.
class StrictProduct(BaseModel):
    # [COMPONENT MEANING] model_config = Pydantic v2 configuration dictionary for model-level settings like extra field handling.
    # [ARGUMENT MEANING] ConfigDict(extra="forbid") = Configuration that raises validation errors when extra fields are present in input data.
    model_config = ConfigDict(extra="forbid")
    
    name: str
    price: float

class LooseProduct(BaseModel):
    # [ARGUMENT MEANING] ConfigDict(extra="ignore") = Configuration that silently strips extra fields not defined in the model.
    model_config = ConfigDict(extra="ignore")
    
    name: str
    price: float


# [WHAT] Field aliases for mapping external field names to Python-safe names.
# [WHY] APIs sometimes have kebab-case or camelCase parameters that don't map to Python snake_case.
class UserInput(BaseModel):
    # [ARGUMENT MEANING] alias = Parameter to map external field names (like "user-name") to internal Python-safe names (like "user_name").
    user_id: int = Field(alias="userId")
    first_name: str = Field(alias="firstName")
    last_name: str = Field(alias="lastName")
    
    # [WHAT]: Allow both the alias and the original field name.
    model_config = ConfigDict(populate_by_name=True)


# [WHAT] Default and default_factory for optional fields.
# [WHY] Provide sensible defaults or dynamic defaults for optional fields.
class Task(BaseModel):
    title: str
    # [ARGUMENT MEANING] default = Parameter specifying the default value if the field is not provided in the request.
    priority: int = Field(default=5, ge=1, le=10)
    # [ARGUMENT MEANING] default_factory = Parameter accepting a callable that generates default values dynamically (useful for mutable defaults).
    tags: list[str] = Field(default_factory=list)


# [WHAT] Constrained types for inline validation.
# [WHY] Sometimes defining a custom class is overkill; constrained types are quick shortcuts.
# [WATCH OUT]: constr() and conint() are somewhat discouraged in Pydantic v2; prefer Field() instead.
from pydantic import constr, conint

class SimpleUser(BaseModel):
    # [COMPONENT MEANING] constr() = Pydantic function creating a constrained string type with validation rules inline.
    username: constr(min_length=3, max_length=50)  # type: ignore
    # [COMPONENT MEANING] conint() = Pydantic function creating a constrained integer type with validation rules inline.
    age: conint(ge=0, le=150)  # type: ignore


# ============================================================================
# ENDPOINTS DEMONSTRATING VALIDATION
# ============================================================================

@app.post("/users", status_code=201)
async def create_user(user: User):
    # [WHAT]: Pydantic automatically validates the incoming request body against the User model.
    # [HOW]: If validation fails, FastAPI returns a 422 Unprocessable Entity response.
    return JSONResponse(content={"message": f"User {user.username} created", "user": user.model_dump()}, status_code=201)


@app.post("/products", status_code=201)
async def create_product(product: Product):
    # [WHAT]: Product model with custom field validators.
    return JSONResponse(content={"message": f"Product {product.name} created", "product": product.model_dump()}, status_code=201)


@app.post("/events", status_code=201)
async def create_event(event: DateRange):
    # [WHAT]: DateRange model with model-level validator.
    return JSONResponse(content={"message": f"Event {event.event_name} created", "event": event.model_dump()}, status_code=201)


@app.post("/notifications", status_code=201)
async def send_notification(notification: Notification):
    # [WHAT]: Polymorphic request body using discriminated union.
    # [HOW]: Pydantic automatically selects the correct model based on the 'type' field.
    return JSONResponse(content={"message": "Notification sent", "data": notification.model_dump()}, status_code=201)


@app.post("/user-profiles", status_code=201)
async def create_profile(profile: UserProfile):
    # [WHAT]: Complex nested model with lists of nested objects.
    return JSONResponse(content={"message": f"Profile for {profile.name} created", "profile": profile.model_dump()}, status_code=201)


@app.post("/strict-products", status_code=201)
async def create_strict_product(product: StrictProduct):
    # [WHAT]: StrictProduct forbids extra fields; sending unknown fields causes 422 error.
    return JSONResponse(content={"message": "Strict product created", "product": product.model_dump()}, status_code=201)


@app.post("/loose-products", status_code=201)
async def create_loose_product(product: LooseProduct):
    # [WHAT]: LooseProduct ignores extra fields silently.
    return JSONResponse(content={"message": "Loose product created", "product": product.model_dump()}, status_code=201)


@app.post("/user-input", status_code=201)
async def create_user_input(user: UserInput):
    # [WHAT]: Aliases allow external camelCase to map to internal snake_case.
    return JSONResponse(content={"message": "User input received", "user": user.model_dump(by_alias=True)}, status_code=201)


@app.post("/tasks", status_code=201)
async def create_task(task: Task):
    # [WHAT]: Task with default and default_factory fields.
    return JSONResponse(content={"message": f"Task '{task.title}' created", "task": task.model_dump()}, status_code=201)


@app.get("/validation-schema")
async def get_schema():
    # [WHAT]: Return the JSON schema of the User model.
    # [HOW]: Pydantic generates OpenAPI/JSON schema automatically.
    return JSONResponse(content=User.model_json_schema())


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8002")
    print("[INFO] Try these endpoints with POST requests:")
    print("  - POST /users (with User model)")
    print("  - POST /products (with Product model)")
    print("  - POST /events (with DateRange model)")
    print("  - POST /notifications (with Notification union)")
    print("  - POST /user-profiles (with UserProfile nested model)")
    print("  - POST /strict-products (forbids extra fields)")
    print("  - POST /loose-products (ignores extra fields)")
    print("  - POST /user-input (with field aliases)")
    print("  - POST /tasks (with defaults)")
    print("  - GET /validation-schema (view JSON schema)")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8002, workers=1, log_level="info")
SEGMENT_2_EOF

echo "[✓] Segment 2 generated: segment_2_pydantic_validation.py"


echo ""
echo "================================================================================"
echo "SEGMENT 3: Response Models & Serialization Strategies"
echo "================================================================================"

cat << 'SEGMENT_3_EOF' > segment_3_response_models.py
"""
Segment 3: Response Models & Serialization Strategies
===================================================

This module demonstrates response_model, serialization strategies, 
custom JSON encoders, streaming, and multiple response types.
"""

from typing import Optional, Union, List
from datetime import datetime
from decimal import Decimal
from pydantic import BaseModel, Field, field_serializer
from fastapi import FastAPI
from fastapi.responses import JSONResponse, ORJSONResponse, StreamingResponse, FileResponse
import json
import uvicorn
import io

app = FastAPI(title="Segment 3: Response Models")


# [WHAT] Basic response model for shape enforcement.
# [WHY] Response models validate and serialize outgoing data, ensuring API contracts.
class UserResponse(BaseModel):
    user_id: int
    username: str
    email: str
    # [ARGUMENT MEANING] response_model = Decorator parameter that validates and serializes response data against a Pydantic model.
    created_at: datetime


class UserWithSensitive(BaseModel):
    user_id: int
    username: str
    email: str
    password_hash: str  # Sensitive field to exclude from some responses
    api_key: str  # Another sensitive field


# [WHAT] Models for demonstration of response filtering.
class PublicUserResponse(BaseModel):
    user_id: int
    username: str
    email: str


# [WHAT] Complex response with nested objects.
# [WHY] Real APIs return nested data structures.
class CommentResponse(BaseModel):
    comment_id: int
    text: str
    created_at: datetime

class PostResponse(BaseModel):
    post_id: int
    title: str
    content: str
    author_id: int
    comments: List[CommentResponse] = Field(default_factory=list)


# [WHAT] Response with special types requiring custom serialization.
# [WHY] JSON doesn't natively support datetime, Decimal, etc.
class PriceData(BaseModel):
    product_id: int
    price: Decimal  # JSON doesn't natively serialize Decimal
    timestamp: datetime  # JSON doesn't natively serialize datetime
    
    # [COMPONENT MEANING] field_serializer = Pydantic v2 decorator for custom serialization logic on specific fields.
    @field_serializer("price")
    def serialize_price(self, value: Decimal) -> str:
        # [WHAT]: Convert Decimal to string to avoid JSON precision issues.
        return str(value)
    
    @field_serializer("timestamp")
    def serialize_timestamp(self, value: datetime) -> str:
        # [WHAT]: Convert datetime to ISO format string.
        return value.isoformat()


# [WHAT] Union response type for different response shapes.
# [WHY] An endpoint might return different response types based on conditions.
class SuccessResponse(BaseModel):
    status: str = "success"
    data: dict

class ErrorResponse(BaseModel):
    status: str = "error"
    error_code: int
    message: str

# [COMPONENT MEANING] Union = Python typing construct for declaring multiple possible response models based on runtime conditions.


# ============================================================================
# ENDPOINTS DEMONSTRATING RESPONSE MODELS
# ============================================================================

@app.post("/users", response_model=UserResponse, status_code=201)
# [ARGUMENT MEANING] response_model = Enforces outgoing data against UserResponse, filtering unknown fields.
async def create_user():
    # [WHAT]: Return data with extra fields; response_model filters them out.
    user_data = {
        "user_id": 1,
        "username": "alice",
        "email": "alice@example.com",
        "created_at": datetime.now(),
        "internal_note": "This field is NOT in UserResponse, so it gets removed",
    }
    return user_data


@app.get("/users/{user_id}", response_model=PublicUserResponse)
async def get_user(user_id: int):
    # [WHAT]: Return only public fields, excluding sensitive data.
    full_user = {
        "user_id": user_id,
        "username": "alice",
        "email": "alice@example.com",
        "password_hash": "super_secret_hash",  # Excluded by response_model
        "api_key": "secret_key_12345",  # Also excluded
    }
    return full_user


@app.get("/users", response_model=List[UserResponse])
async def list_users():
    # [WHAT]: Return a list of UserResponse objects.
    return [
        {"user_id": 1, "username": "alice", "email": "alice@example.com", "created_at": datetime.now()},
        {"user_id": 2, "username": "bob", "email": "bob@example.com", "created_at": datetime.now()},
    ]


@app.get("/posts/{post_id}", response_model=PostResponse)
async def get_post(post_id: int):
    # [WHAT]: Return nested response model.
    return {
        "post_id": post_id,
        "title": "FastAPI is awesome",
        "content": "ASGI is the future...",
        "author_id": 1,
        "comments": [
            {"comment_id": 101, "text": "Great post!", "created_at": datetime.now()},
            {"comment_id": 102, "text": "I learned so much", "created_at": datetime.now()},
        ],
    }


@app.get("/products/{product_id}", response_model=PriceData)
async def get_product(product_id: int):
    # [WHAT]: Return Decimal and datetime, which get serialized via @field_serializer.
    return {
        "product_id": product_id,
        "price": Decimal("19.99"),
        "timestamp": datetime.now(),
    }


# [WHAT] response_model with exclude_unset filtering.
# [WHY] Don't include fields that weren't explicitly set by the endpoint.
@app.post("/profile", response_model=UserResponse, response_model_exclude_unset=True)
# [ARGUMENT MEANING] response_model_exclude_unset = Parameter that excludes fields from the response if they weren't explicitly set.
async def create_profile():
    # [WHAT]: Only fields that are explicitly set appear in response.
    return {
        "user_id": 1,
        "username": "alice",
        "email": "alice@example.com",
        "created_at": datetime.now(),
    }


# [WHAT] response_model with exclude_none filtering.
# [WHY] Don't include null fields in the response.
class OptionalUserResponse(BaseModel):
    user_id: int
    username: str
    email: Optional[str] = None
    phone: Optional[str] = None

@app.get("/user-optional/{user_id}", response_model=OptionalUserResponse, response_model_exclude_none=True)
# [ARGUMENT MEANING] response_model_exclude_none = Parameter that excludes fields from the response if their value is None.
async def get_optional_user(user_id: int):
    # [WHAT]: Only non-None fields appear in response.
    return {
        "user_id": user_id,
        "username": "alice",
        "email": None,  # Excluded from response
        "phone": None,  # Excluded from response
    }


# [WHAT] response_model with exclude_defaults filtering.
# [WHY] Don't include fields with their default values.
class ConfigResponse(BaseModel):
    setting_id: int
    enabled: bool = True  # Has a default
    timeout: int = 30  # Has a default

@app.get("/config/{config_id}", response_model=ConfigResponse, response_model_exclude_defaults=True)
# [ARGUMENT MEANING] response_model_exclude_defaults = Parameter that excludes fields from the response if they contain their default value.
async def get_config(config_id: int):
    return {
        "setting_id": config_id,
        "enabled": True,  # Equals default, will be excluded
        "timeout": 45,  # Different from default, will be included
    }


# [WHAT] response_model with include and exclude sets.
# [WHY] Whitelist or blacklist specific fields.
@app.get("/user-filtered/{user_id}", response_model=UserWithSensitive, response_model_exclude={"password_hash", "api_key"})
# [ARGUMENT MEANING] response_model_exclude = Parameter accepting a set of field names to exclude from the response.
async def get_user_filtered(user_id: int):
    return {
        "user_id": user_id,
        "username": "alice",
        "email": "alice@example.com",
        "password_hash": "should_not_appear",
        "api_key": "should_not_appear",
    }


# [WHAT] Using ORJSONResponse for high-performance serialization.
# [WHY] orjson is significantly faster than standard json for large payloads.
@app.get("/fast-data", response_class=ORJSONResponse)
# [COMPONENT MEANING] ORJSONResponse = High-performance JSON response class using the orjson library for faster serialization.
async def get_fast_data():
    # [WHAT]: Returns via ORJSONResponse instead of default JSON encoder.
    return {
        "data": list(range(1000)),
        "timestamp": datetime.now().isoformat(),
    }


# [WHAT] Union response type based on runtime conditions.
# [WHY] Different error scenarios return different response shapes.
@app.get("/conditional/{resource_id}", response_model=Union[SuccessResponse, ErrorResponse])
async def get_conditional(resource_id: int):
    # [WHAT]: Return different response shapes based on resource_id.
    if resource_id > 0:
        return SuccessResponse(data={"resource_id": resource_id, "message": "Found"})
    else:
        return ErrorResponse(error_code=404, message="Resource not found")


# [WHAT] Streaming response for large datasets.
# [WHY] Don't load entire dataset into memory; stream it to the client.
@app.get("/stream-data", response_class=StreamingResponse)
# [COMPONENT MEANING] StreamingResponse = FastAPI response class for streaming large datasets or real-time data without loading everything into memory.
async def stream_data():
    def generate():
        # [WHAT]: Generator function that yields JSON lines.
        for i in range(1000):
            yield json.dumps({"id": i, "value": i ** 2}) + "\n"
    
    return StreamingResponse(content=generate(), media_type="application/x-ndjson")


# [WHAT] File response for serving downloads.
# [WHY] Efficiently serve file downloads without loading into memory.
@app.get("/download-file", response_class=FileResponse)
# [COMPONENT MEANING] FileResponse = Response class for efficiently serving file downloads with proper headers.
async def download_file():
    # [WHAT]: Return a file response (must exist on disk in real scenario).
    return FileResponse(path="/etc/hostname", filename="data.txt", media_type="text/plain")


# [WHAT] Custom JSON encoder via model_dump().
# [WHY] When response_model doesn't meet your serialization needs.
@app.get("/custom-serialize")
async def custom_serialize():
    # [COMPONENT MEANING] model_dump() = Pydantic v2 method to convert model instance to a dictionary for manual serialization.
    price_data = PriceData(product_id=1, price=Decimal("99.99"), timestamp=datetime.now())
    serialized = price_data.model_dump()  # Convert to dict
    return JSONResponse(content=serialized)


# [WHAT] Direct JSON string via model_dump_json().
# [WHY] When you need the JSON string directly.
@app.get("/json-string")
async def json_string():
    # [COMPONENT MEANING] model_dump_json() = Pydantic v2 method to convert model instance directly to a JSON string.
    user = UserResponse(user_id=1, username="alice", email="alice@example.com", created_at=datetime.now())
    json_str = user.model_dump_json()
    return JSONResponse(content=json.loads(json_str))


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8003")
    print("[INFO] Try these endpoints:")
    print("  - POST /users")
    print("  - GET /users")
    print("  - GET /users/{user_id}")
    print("  - GET /posts/{post_id}")
    print("  - GET /products/{product_id}")
    print("  - GET /user-optional/{user_id}")
    print("  - GET /config/{config_id}")
    print("  - GET /user-filtered/{user_id}")
    print("  - GET /fast-data")
    print("  - GET /conditional/{resource_id}")
    print("  - GET /stream-data")
    print("  - GET /download-file")
    print("  - GET /custom-serialize")
    print("  - GET /json-string")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8003, workers=1, log_level="info")
SEGMENT_3_EOF

echo "[✓] Segment 3 generated: segment_3_response_models.py"


echo ""
echo "================================================================================"
echo "SEGMENT 4: Dependency Injection System Mastery"
echo "================================================================================"

cat << 'SEGMENT_4_EOF' > segment_4_dependency_injection.py
"""
Segment 4: Dependency Injection System Mastery
==============================================

This module demonstrates FastAPI's Depends() system, sub-dependency trees,
generator dependencies (setup/teardown), callable classes, and testing overrides.
"""

from typing import Optional, Generator
from fastapi import FastAPI, Depends, HTTPException, Header
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="Segment 4: Dependency Injection")


# [WHAT] Simple dependency function.
# [WHY] DI decouples business logic from infrastructure concerns (DB, auth, logging).
def get_query_param(skip: int = 0, limit: int = 10) -> dict:
    # [COMPONENT MEANING] Depends() = FastAPI function that declares a dependency to be resolved and injected by the framework.
    # [WHAT]: FastAPI automatically extracts query parameters and passes them to dependencies.
    return {"skip": skip, "limit": limit}


@app.get("/items")
async def list_items(pagination: dict = Depends(get_query_param)):
    # [WHAT]: The pagination dict is resolved by get_query_param dependency.
    # [HOW]: Depends(get_query_param) tells FastAPI to call that function and inject the result.
    return JSONResponse(content={"pagination": pagination, "items": []})


# [WHAT] Dependency with sub-dependencies (dependency tree).
# [WHY] Complex dependencies often compose simpler ones.
def get_database_connection():
    # [WHAT]: Simulates a database connection object.
    return {"connection": "PostgreSQL://localhost", "status": "connected"}

def get_user_repository(db: dict = Depends(get_database_connection)):
    # [WHAT]: Uses db dependency internally.
    # [HOW]: Depends(get_database_connection) injects the DB connection.
    return {"db": db, "user_table": "users"}

@app.get("/users")
async def list_users(user_repo: dict = Depends(get_user_repository)):
    # [WHAT]: User repo depends on DB connection. FastAPI resolves the entire tree.
    # [HOW]: FastAPI calls get_database_connection(), then passes result to get_user_repository().
    return JSONResponse(content={"user_repo": user_repo})


# [WHAT] Dependency caching: FastAPI calls the dependency once per request.
# [WHY] Avoid redundant calls; all downstream endpoints share the same dependency instance.
def get_current_user(authorization: str = Header(None)) -> dict:
    # [WHAT]: Validates the authorization header and returns user info.
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization")
    
    token = authorization.replace("Bearer ", "")
    # Simulate token validation
    return {"user_id": 1, "username": "alice", "token": token}

@app.get("/profile")
async def get_profile(user: dict = Depends(get_current_user)):
    # [WHAT]: get_current_user is called once and cached for this request.
    return JSONResponse(content={"profile": {"user": user, "email": "alice@example.com"}})

@app.get("/settings")
async def get_settings(user: dict = Depends(get_current_user)):
    # [WHAT]: SAME dependency instance is injected here (caching within request).
    # [HOW]: FastAPI's Depends() mechanism caches results per request.
    return JSONResponse(content={"user_id": user["user_id"], "settings": {}})


# [WHAT] Generator dependency for setup/teardown (context managers).
# [WHY] Manage resource lifecycle: open connections on startup, close on cleanup.
def get_db_session() -> Generator[dict, None, None]:
    # [COMPONENT MEANING] Generator dependency = A dependency function that yields (provides) a resource and handles cleanup after the endpoint returns.
    # [WHAT]: Setup phase: open database session.
    print("[SETUP] Opening database session")
    session = {"connection_id": "conn_12345", "active": True}
    
    yield session  # Provide the session to the endpoint
    
    # [WHAT]: Teardown phase: close database session.
    print("[TEARDOWN] Closing database session")
    session["active"] = False

@app.get("/records")
async def get_records(db_session: dict = Depends(get_db_session)):
    # [WHAT]: db_session is provided by the generator.
    # [HOW]: FastAPI calls the generator, yields the session, endpoint runs, then cleanup runs.
    return JSONResponse(content={"records": [], "session_id": db_session["connection_id"]})


# [WHAT] Callable class as a dependency.
# [WHY] Complex dependencies benefit from class structure and state.
class RateLimiter:
    # [COMPONENT MEANING] Callable class as dependency = A class whose __call__ method is treated as a dependency function.
    
    def __init__(self, max_calls: int = 10):
        self.max_calls = max_calls
        self.call_count = 0
    
    def __call__(self, user_id: int) -> dict:
        # [WHAT]: __call__ makes the instance callable, allowing it to be used as a dependency.
        self.call_count += 1
        if self.call_count > self.max_calls:
            raise HTTPException(status_code=429, detail="Rate limit exceeded")
        return {"user_id": user_id, "remaining": self.max_calls - self.call_count}

rate_limiter = RateLimiter(max_calls=5)

@app.get("/api-call")
async def api_call(rate_limit: dict = Depends(rate_limiter)):
    # [WHAT]: rate_limiter instance is used as a dependency.
    return JSONResponse(content={"message": "API call successful", "rate_limit": rate_limit})


# [WHAT] Dependency with multiple request methods.
# [WHY] Some dependencies apply globally (APIRouter or FastAPI constructor).
class AuthContext:
    def __init__(self, user_id: int, is_admin: bool = False):
        self.user_id = user_id
        self.is_admin = is_admin

def get_auth_context(authorization: str = Header(None)) -> AuthContext:
    if not authorization:
        raise HTTPException(status_code=401, detail="Unauthorized")
    # Simulate token parsing
    return AuthContext(user_id=1, is_admin=True)

@app.get("/admin-only")
async def admin_only(auth: AuthContext = Depends(get_auth_context)):
    if not auth.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")
    return JSONResponse(content={"message": "Admin action executed"})


# [WHAT] Overriding dependencies for testing.
# [WHY] In tests, replace real dependencies (DB, external APIs) with mocks.
def get_real_api() -> dict:
    # [WHAT]: Real API call in production.
    return {"data": "from-real-api", "latency_ms": 500}

async def test_mock_api() -> dict:
    # [WHAT]: Mock API for testing.
    return {"data": "from-mock", "latency_ms": 1}

@app.get("/external-data")
async def get_external_data(api: dict = Depends(get_real_api)):
    return JSONResponse(content={"result": api})

# Override for testing
def override_dependencies():
    # [WHAT]: app.dependency_overrides is a dict that maps original dependencies to test replacements.
    # [HOW]: Call this before testing to swap real dependencies with mocks.
    app.dependency_overrides[get_real_api] = test_mock_api


# [WHAT] Multiple dependencies on same endpoint.
# [WHY] Real endpoints often need auth, rate limiting, logging, etc.
async def get_request_id(x_request_id: str = Header(None)) -> str:
    if not x_request_id:
        raise HTTPException(status_code=400, detail="X-Request-ID header required")
    return x_request_id

@app.post("/process")
async def process_data(
    auth: AuthContext = Depends(get_auth_context),
    rate_limit: dict = Depends(rate_limiter),
    request_id: str = Depends(get_request_id),
):
    # [WHAT]: Three dependencies are resolved and injected.
    # [HOW]: FastAPI resolves them in the correct order (respecting sub-dependencies).
    return JSONResponse(content={
        "user_id": auth.user_id,
        "rate_limit": rate_limit,
        "request_id": request_id,
    })


# [WHAT] Dependency with optional values.
# [WHY] Some dependencies might be optional (e.g., optional authentication).
def get_optional_user(authorization: str = Header(None)) -> Optional[dict]:
    if not authorization:
        return None
    return {"user_id": 1, "username": "alice"}

@app.get("/public-with-optional-auth")
async def public_endpoint(user: Optional[dict] = Depends(get_optional_user)):
    # [WHAT]: User can be None if not authenticated.
    if user:
        return JSONResponse(content={"message": f"Hello {user['username']}"})
    else:
        return JSONResponse(content={"message": "Hello anonymous user"})


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8004")
    print("[INFO] Try these endpoints:")
    print("  - GET /items?skip=0&limit=10")
    print("  - GET /users")
    print("  - GET /profile (with Authorization: Bearer token header)")
    print("  - GET /settings (with Authorization: Bearer token header)")
    print("  - GET /records (demonstrates generator setup/teardown)")
    print("  - GET /api-call (multiple times to test rate limiting)")
    print("  - GET /admin-only (with Authorization: Bearer token header)")
    print("  - GET /external-data")
    print("  - POST /process (with headers: Authorization, X-Request-ID)")
    print("  - GET /public-with-optional-auth")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8004, workers=1, log_level="info")
SEGMENT_4_EOF

echo "[✓] Segment 4 generated: segment_4_dependency_injection.py"


echo ""
echo "================================================================================"
echo "SEGMENT 5: Database Integration with SQLAlchemy Async"
echo "================================================================================"

cat << 'SEGMENT_5_EOF' > segment_5_database_integration.py
"""
Segment 5: Database Integration with SQLAlchemy Async
=====================================================

This module demonstrates AsyncEngine, AsyncSession, query optimization,
session-per-request pattern, transaction management, and connection pooling.
"""

from sqlalchemy import Column, Integer, String, Float, DateTime, select, ForeignKey
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.pool import NullPool
from datetime import datetime
from typing import AsyncGenerator
from fastapi import FastAPI, Depends
from fastapi.responses import JSONResponse
import uvicorn

app = FastAPI(title="Segment 5: Database Integration")

# [COMPONENT MEANING] declarative_base() = SQLAlchemy factory creating the base class for all ORM models.
Base = declarative_base()


# [WHAT] Database models (ORM classes).
# [WHY] Decouples database schema from Python code via the SQLAlchemy ORM.
class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    posts = relationship("Post", back_populates="author")

class Post(Base):
    __tablename__ = "posts"
    
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    content = Column(String)
    author_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    author = relationship("User", back_populates="posts")


# [COMPONENT MEANING] create_async_engine() = Factory creating an async SQLAlchemy engine for non-blocking database operations.
# [WHAT] Create async engine with connection pooling.
# [WHY] AsyncEngine is required for async/await patterns; connection pooling reuses connections efficiently.
DATABASE_URL = "sqlite+aiosqlite:///:memory:"  # In-memory SQLite for demo; use PostgreSQL in production

engine = create_async_engine(
    DATABASE_URL,
    # [ARGUMENT MEANING] echo=True = Log all SQL statements for debugging.
    echo=True,
    # [ARGUMENT MEANING] pool_size = Maximum number of persistent connections in the pool.
    pool_size=20,
    # [ARGUMENT MEANING] max_overflow = Maximum overflow connections beyond pool_size.
    max_overflow=10,
    # [ARGUMENT MEANING] pool_pre_ping = Test connections before using them to detect stale connections.
    pool_pre_ping=True,
    # [ARGUMENT MEANING] pool_recycle = Recycle connections after this many seconds (prevents timeout issues).
    pool_recycle=3600,
    # [ARGUMENT MEANING] poolclass = Use NullPool to avoid connection pooling (SQLite limitation).
    poolclass=NullPool,  # SQLite doesn't handle concurrent connections well
)

# [COMPONENT MEANING] async_sessionmaker = Factory creating async session instances with given engine and options.
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    # [ARGUMENT MEANING] expire_on_commit = Expire objects after commit to prevent lazy-loading issues.
    expire_on_commit=False,
)


# [WHAT] Dependency for session-per-request pattern.
# [WHY] Each HTTP request gets its own DB session; automatic cleanup on request end.
async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    # [COMPONENT MEANING] AsyncSession = SQLAlchemy async session providing context for ORM operations.
    async with AsyncSessionLocal() as session:
        try:
            yield session
            # [WHAT]: Commit any pending changes.
            # [WATCH OUT]: In production, use explicit transaction management to avoid unexpected commits.
            await session.commit()
        except Exception as e:
            # [WHAT]: Rollback on any exception.
            await session.rollback()
            raise
        finally:
            # [WHAT]: Close the session.
            await session.close()


# [WHAT] Initialize database tables.
# [WHY] Create schema before running the app (in real apps, use Alembic migrations).
async def init_db():
    async with engine.begin() as conn:
        # [WHAT]: Create all tables defined in Base.metadata.
        await conn.run_sync(Base.metadata.create_all)


# [WHAT] Startup event to initialize database.
@app.on_event("startup")
async def startup():
    print("[STARTUP] Initializing database...")
    await init_db()
    print("[STARTUP] Database ready")


@app.on_event("shutdown")
async def shutdown():
    print("[SHUTDOWN] Closing database engine...")
    await engine.dispose()
    print("[SHUTDOWN] Database closed")


# ============================================================================
# ENDPOINTS DEMONSTRATING DATABASE OPERATIONS
# ============================================================================

@app.post("/users", status_code=201)
async def create_user(username: str, email: str, db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Create a new user and insert into database.
    # [HOW]: Create ORM object, add to session, commit.
    user = User(username=username, email=email)
    db.add(user)
    # [COMPONENT MEANING] session.commit() = Persists changes to the database and begins a new transaction.
    await db.commit()
    # [WHAT]: Refresh the object to get the generated ID.
    await db.refresh(user)
    return JSONResponse(content={"user_id": user.id, "username": user.username}, status_code=201)


@app.get("/users")
async def list_users(db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Query all users from database.
    # [HOW]: Use SQLAlchemy select() for type-safe, async queries.
    # [COMPONENT MEANING] select(User) = Creates a SELECT statement for the User model.
    stmt = select(User)
    # [ARGUMENT MEANING] scalars() = Execute statement and return scalar results (objects, not row tuples).
    result = await db.execute(stmt)
    users = result.scalars().all()
    return JSONResponse(content={"users": [{"id": u.id, "username": u.username, "email": u.email} for u in users]})


@app.get("/users/{user_id}")
async def get_user(user_id: int, db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Query a single user by ID.
    # [HOW]: Use where() to filter results.
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    
    if not user:
        return JSONResponse(content={"error": "User not found"}, status_code=404)
    
    return JSONResponse(content={"id": user.id, "username": user.username, "email": user.email})


@app.post("/users/{user_id}/posts", status_code=201)
async def create_post(user_id: int, title: str, content: str, db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Create a post for a user.
    # [HOW]: First verify user exists, then create post with foreign key relationship.
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    
    if not user:
        return JSONResponse(content={"error": "User not found"}, status_code=404)
    
    post = Post(title=title, content=content, author_id=user_id)
    db.add(post)
    await db.commit()
    await db.refresh(post)
    
    return JSONResponse(content={"post_id": post.id, "title": post.title}, status_code=201)


@app.get("/users/{user_id}/posts")
async def get_user_posts(user_id: int, db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Get all posts for a user.
    # [HOW]: Query posts with where() filter.
    stmt = select(Post).where(Post.author_id == user_id)
    result = await db.execute(stmt)
    posts = result.scalars().all()
    
    return JSONResponse(content={
        "user_id": user_id,
        "posts": [{"id": p.id, "title": p.title, "content": p.content} for p in posts]
    })


@app.get("/posts-with-authors")
async def get_posts_with_authors(db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Get posts WITH their authors (demonstrates relationship loading).
    # [WATCH OUT]: Without explicit join strategy, this causes N+1 query problem.
    # [COMPONENT MEANING] selectinload() = Query optimization that loads related objects in a separate query.
    from sqlalchemy.orm import selectinload
    
    stmt = select(Post).options(selectinload(Post.author))
    result = await db.execute(stmt)
    posts = result.scalars().unique().all()
    
    return JSONResponse(content={
        "posts": [
            {"id": p.id, "title": p.title, "author": p.author.username}
            for p in posts
        ]
    })


@app.put("/users/{user_id}", status_code=200)
async def update_user(user_id: int, username: str, email: str, db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Update an existing user.
    # [HOW]: Query, modify attributes, commit.
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    
    if not user:
        return JSONResponse(content={"error": "User not found"}, status_code=404)
    
    user.username = username
    user.email = email
    await db.commit()
    await db.refresh(user)
    
    return JSONResponse(content={"id": user.id, "username": user.username, "email": user.email})


@app.delete("/users/{user_id}", status_code=200)
async def delete_user(user_id: int, db: AsyncSession = Depends(get_db_session)):
    # [WHAT]: Delete a user.
    # [HOW]: Query, delete from session, commit.
    stmt = select(User).where(User.id == user_id)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()
    
    if not user:
        return JSONResponse(content={"error": "User not found"}, status_code=404)
    
    await db.delete(user)
    await db.commit()
    
    return JSONResponse(content={"message": f"User {user_id} deleted"})


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8005")
    print("[INFO] Try these endpoints:")
    print("  - POST /users?username=alice&email=alice@example.com")
    print("  - GET /users")
    print("  - GET /users/1")
    print("  - POST /users/1/posts?title=Post1&content=Content1")
    print("  - GET /users/1/posts")
    print("  - GET /posts-with-authors")
    print("  - PUT /users/1?username=alice_updated&email=alice_new@example.com")
    print("  - DELETE /users/1")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8005, workers=1, log_level="info")
SEGMENT_5_EOF

echo "[✓] Segment 5 generated: segment_5_database_integration.py"


echo ""
echo "================================================================================"
echo "SEGMENT 6: Authentication & Authorization Implementation"
echo "================================================================================"

cat << 'SEGMENT_6_EOF' > segment_6_authentication.py
"""
Segment 6: Authentication & Authorization Implementation
=======================================================

This module demonstrates OAuth2, JWT, password hashing, token lifecycle,
role-based access control (RBAC), and secure validation patterns.
"""

from datetime import datetime, timedelta
from typing import Optional
from fastapi import FastAPI, Depends, HTTPException, Header
from fastapi.responses import JSONResponse
from fastapi.security import HTTPBearer, HTTPAuthCredentials
from pydantic import BaseModel
import jwt
import uvicorn
from passlib.context import CryptContext

app = FastAPI(title="Segment 6: Authentication & Authorization")

# [COMPONENT MEANING] CryptContext = Passlib utility for hashing and verifying passwords securely.
# [WHAT] Configure password hashing with Argon2 (recommended over bcrypt for newer systems).
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT configuration
SECRET_KEY = "your-secret-key-change-in-production"  # In production, load from environment
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


# [WHAT] Pydantic models for request/response payloads.
class UserCredentials(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int

class UserInfo(BaseModel):
    user_id: int
    username: str
    roles: list[str]


# [WHAT] In-memory user store (in production, use database).
USERS_DB = {
    "alice": {
        "user_id": 1,
        "username": "alice",
        "password_hash": pwd_context.hash("alice_secure_password"),  # Hash: "alice_secure_password"
        "roles": ["user", "admin"],
    },
    "bob": {
        "user_id": 2,
        "username": "bob",
        "password_hash": pwd_context.hash("bob_secure_password"),
        "roles": ["user"],
    },
}

# [WHAT] Token blacklist for revocation (in production, use Redis or database).
TOKEN_BLACKLIST = set()


# ============================================================================
# PASSWORD HASHING
# ============================================================================

def hash_password(password: str) -> str:
    # [COMPONENT MEANING] pwd_context.hash() = Hashes a password using the configured algorithm (bcrypt).
    # [WHAT]: One-way cryptographic hash. Cannot be reversed.
    return pwd_context.hash(password)

def verify_password(plain_password: str, password_hash: str) -> bool:
    # [COMPONENT MEANING] pwd_context.verify() = Securely compares a plain password to its hash.
    # [WHAT]: Constant-time comparison to prevent timing attacks.
    return pwd_context.verify(plain_password, password_hash)


# ============================================================================
# JWT TOKEN GENERATION & VALIDATION
# ============================================================================

def create_access_token(user_id: int, username: str, roles: list[str]) -> str:
    # [WHAT] Create a JWT access token with claims.
    # [WHY] JWT is stateless; the token itself carries user info and signature.
    
    payload = {
        "sub": username,  # Subject (standard JWT claim)
        "user_id": user_id,
        "roles": roles,
        "iat": datetime.utcnow(),  # Issued at
        "exp": datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),  # Expiration
    }
    
    # [COMPONENT MEANING] jwt.encode() = Encodes claims into a JWT token with signature.
    # [ARGUMENT MEANING] algorithm="HS256" = HMAC-SHA256 symmetric signing (HS256 for secrets, RS256 for public keys).
    token = jwt.encode(payload=payload, key=SECRET_KEY, algorithm=ALGORITHM)
    return token

def verify_access_token(token: str) -> dict:
    # [WHAT] Decode and validate a JWT token.
    # [WHY] Verify the signature hasn't been tampered with and the token hasn't expired.
    
    try:
        # [COMPONENT MEANING] jwt.decode() = Validates JWT signature and returns claims dictionary.
        # [ARGUMENT MEANING] algorithms = List of allowed algorithms (prevents algorithm confusion attacks).
        payload = jwt.decode(token=token, key=SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


# ============================================================================
# DEPENDENCY FUNCTIONS FOR AUTH
# ============================================================================

def get_current_user(authorization: str = Header(None)) -> dict:
    # [WHAT] Extract user from Authorization header.
    # [WHY] Standard Bearer token authentication.
    
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
    
    token = authorization.replace("Bearer ", "")
    
    # [WHAT] Check if token is blacklisted (revoked).
    if token in TOKEN_BLACKLIST:
        raise HTTPException(status_code=401, detail="Token has been revoked")
    
    # [WHAT] Verify and decode token.
    payload = verify_access_token(token)
    
    username = payload.get("sub")
    if not username or username not in USERS_DB:
        raise HTTPException(status_code=401, detail="Invalid token claims")
    
    user = USERS_DB[username]
    return {"user_id": user["user_id"], "username": username, "roles": user["roles"]}


def require_admin(user: dict = Depends(get_current_user)) -> dict:
    # [WHAT] Dependency that ensures user has "admin" role.
    # [WHY] Role-based access control (RBAC).
    
    if "admin" not in user["roles"]:
        raise HTTPException(status_code=403, detail="Admin role required")
    
    return user


def require_user(user: dict = Depends(get_current_user)) -> dict:
    # [WHAT] Dependency ensuring basic "user" role.
    
    if "user" not in user["roles"]:
        raise HTTPException(status_code=403, detail="User role required")
    
    return user


# ============================================================================
# AUTHENTICATION ENDPOINTS
# ============================================================================

@app.post("/token", response_model=TokenResponse)
async def login(credentials: UserCredentials):
    # [WHAT] OAuth2 Password flow: exchange username/password for access token.
    # [WHY] Client authenticates and receives a token for subsequent requests.
    
    # [WHAT] Validate credentials against user database.
    user = USERS_DB.get(credentials.username)
    if not user or not verify_password(credentials.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # [WHAT] Generate access token.
    access_token = create_access_token(
        user_id=user["user_id"],
        username=user["username"],
        roles=user["roles"]
    )
    
    return TokenResponse(
        access_token=access_token,
        expires_in=ACCESS_TOKEN_EXPIRE_MINUTES * 60,  # In seconds
    )


@app.post("/register", status_code=201)
async def register(credentials: UserCredentials):
    # [WHAT] User registration endpoint.
    # [WHY] Allow new users to create accounts.
    
    if credentials.username in USERS_DB:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    # [WHAT] Hash password before storing.
    password_hash = hash_password(credentials.password)
    
    # [WHAT] Create new user entry.
    new_user_id = len(USERS_DB) + 1
    USERS_DB[credentials.username] = {
        "user_id": new_user_id,
        "username": credentials.username,
        "password_hash": password_hash,
        "roles": ["user"],  # New users get basic role
    }
    
    return JSONResponse(
        content={"message": f"User {credentials.username} registered", "user_id": new_user_id},
        status_code=201
    )


@app.post("/logout", status_code=200)
async def logout(user: dict = Depends(get_current_user), authorization: str = Header(None)):
    # [WHAT] Token revocation endpoint.
    # [WHY] Allow users to explicitly log out (revoke their token).
    
    token = authorization.replace("Bearer ", "")
    # [WHAT] Add token to blacklist.
    TOKEN_BLACKLIST.add(token)
    
    return JSONResponse(content={"message": "Logged out successfully"})


# ============================================================================
# PROTECTED ENDPOINTS
# ============================================================================

@app.get("/profile")
async def get_profile(user: dict = Depends(get_current_user)):
    # [WHAT] Protected endpoint: requires valid token.
    # [WHY] get_current_user dependency enforces authentication.
    
    return JSONResponse(content={
        "user_id": user["user_id"],
        "username": user["username"],
        "roles": user["roles"],
    })


@app.get("/admin-panel")
async def admin_panel(user: dict = Depends(require_admin)):
    # [WHAT] Admin-only endpoint: requires authentication + admin role.
    # [WHY] Role-based access control via dependency.
    
    return JSONResponse(content={
        "message": f"Welcome admin {user['username']}",
        "admin_data": {"users_count": len(USERS_DB), "features": ["all"]},
    })


@app.get("/user-data")
async def get_user_data(user: dict = Depends(require_user)):
    # [WHAT] User-only endpoint: requires user role.
    
    return JSONResponse(content={
        "message": f"Hello {user['username']}",
        "data": {"preferences": {}, "settings": {}},
    })


@app.post("/change-password")
async def change_password(
    old_password: str,
    new_password: str,
    user: dict = Depends(get_current_user)
):
    # [WHAT] Endpoint to change user password.
    # [WHY] Allow users to update their credentials.
    
    user_data = USERS_DB[user["username"]]
    
    # [WHAT] Verify old password before allowing change.
    if not verify_password(old_password, user_data["password_hash"]):
        raise HTTPException(status_code=401, detail="Current password incorrect")
    
    # [WHAT] Hash new password.
    user_data["password_hash"] = hash_password(new_password)
    
    return JSONResponse(content={"message": "Password changed successfully"})


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8006")
    print("[INFO] Test accounts (password = username + '_secure_password'):")
    print("  - alice (admin)")
    print("  - bob (user)")
    print("[INFO] Try these endpoints:")
    print("  - POST /register (register new user)")
    print("  - POST /token (login to get access token)")
    print("  - GET /profile (requires Authorization: Bearer <token>)")
    print("  - GET /admin-panel (requires admin role)")
    print("  - GET /user-data (requires user role)")
    print("  - POST /change-password (requires authentication)")
    print("  - POST /logout (revoke token)")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8006, workers=1, log_level="info")
SEGMENT_6_EOF

echo "[✓] Segment 6 generated: segment_6_authentication.py"


echo ""
echo "================================================================================"
echo "SEGMENT 7: Security Hardening & OWASP Defense"
echo "================================================================================"

cat << 'SEGMENT_7_EOF' > segment_7_security_hardening.py
"""
Segment 7: Security Hardening & OWASP Defense
==============================================

This module demonstrates CORS, security headers, injection prevention,
TrustedHostMiddleware, GZipMiddleware, and OWASP defense patterns.
"""

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
import uvicorn
import re
import html

app = FastAPI(title="Segment 7: Security Hardening")


# ============================================================================
# CORS (Cross-Origin Resource Sharing) CONFIGURATION
# ============================================================================

# [WHAT] CORS middleware for controlling cross-origin requests.
# [WHY] Prevent unauthorized cross-origin access while allowing legitimate partners.
# [COMPONENT MEANING] CORSMiddleware = Middleware that validates Origin header and adds CORS response headers.

app.add_middleware(
    CORSMiddleware,
    # [ARGUMENT MEANING] allow_origins = List of origins allowed to make cross-origin requests. Use ["*"] sparingly; be specific in production.
    allow_origins=["http://localhost:3000", "https://example.com"],
    # [ARGUMENT MEANING] allow_credentials = Allow credentials (cookies, Authorization) in cross-origin requests.
    allow_credentials=True,
    # [ARGUMENT MEANING] allow_methods = HTTP methods allowed in CORS requests.
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    # [ARGUMENT MEANING] allow_headers = Custom headers allowed in CORS requests.
    allow_headers=["Content-Type", "Authorization"],
    # [ARGUMENT MEANING] expose_headers = Headers exposed to the client in the response.
    expose_headers=["X-Total-Count"],
    # [ARGUMENT MEANING] max_age = Cache preflight response for this many seconds.
    max_age=600,
)

# [WHAT] TrustedHostMiddleware validates Host header to prevent host header injection.
# [WHY] Attackers can manipulate the Host header to bypass security controls or cause caching issues.
# [COMPONENT MEANING] TrustedHostMiddleware = Middleware that validates the Host header against a whitelist.

app.add_middleware(
    TrustedHostMiddleware,
    # [ARGUMENT MEANING] allowed_hosts = List of valid host patterns. Use wildcards carefully.
    allowed_hosts=["localhost", "127.0.0.1", "example.com", "*.example.com"],
)

# [WHAT] GZipMiddleware for response compression.
# [WHY] Reduces bandwidth usage for large responses.
# [COMPONENT MEANING] GZipMiddleware = Middleware that compresses responses with gzip when client supports it.

app.add_middleware(
    GZipMiddleware,
    # [ARGUMENT MEANING] minimum_size = Only compress responses larger than this many bytes.
    minimum_size=1000,
)


# ============================================================================
# SECURITY HEADERS MIDDLEWARE
# ============================================================================

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    # [WHAT] Custom middleware adding OWASP security headers to every response.
    # [WHY] Security headers instruct browsers to enforce protections.
    
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        
        # [ARGUMENT MEANING] Content-Security-Policy = HTTP header restricting resource loading sources to prevent XSS attacks.
        response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self' 'unsafe-inline'"
        
        # [ARGUMENT MEANING] Strict-Transport-Security = HTTP header enforcing HTTPS connections to prevent protocol downgrade attacks.
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        
        # [ARGUMENT MEANING] X-Content-Type-Options = HTTP header preventing MIME type sniffing attacks with "nosniff" value.
        response.headers["X-Content-Type-Options"] = "nosniff"
        
        # [ARGUMENT MEANING] X-Frame-Options = HTTP header preventing clickjacking by controlling iframe embedding with "DENY" or "SAMEORIGIN".
        response.headers["X-Frame-Options"] = "DENY"
        
        # [WHAT] Legacy XSS header (deprecated but sometimes required for legacy compliance).
        response.headers["X-XSS-Protection"] = "1; mode=block"
        
        return response

app.add_middleware(SecurityHeadersMiddleware)


# ============================================================================
# INPUT VALIDATION & SANITIZATION
# ============================================================================

def sanitize_html(user_input: str) -> str:
    # [WHAT] Escape HTML special characters to prevent XSS.
    # [WHY] User input can contain malicious script tags.
    return html.escape(user_input)

def validate_email(email: str) -> bool:
    # [WHAT] Validate email format to prevent injection attacks.
    # [WHY] Malformed input can bypass downstream validation.
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return bool(re.match(pattern, email))

def prevent_sql_injection(query: str) -> str:
    # [WHAT] Basic sanitization (in production, use parameterized queries).
    # [WHY] Prevent SQL injection attacks.
    # [WATCH OUT]: This is a simplified example. Always use ORM parameterized queries in production.
    dangerous_chars = [";", "--", "/*", "*/", "xp_", "sp_"]
    for char in dangerous_chars:
        if char in query.lower():
            raise ValueError(f"Suspicious pattern detected: {char}")
    return query


# ============================================================================
# ENDPOINTS WITH SECURITY MEASURES
# ============================================================================

@app.get("/secure-data")
async def get_secure_data():
    # [WHAT] Endpoint demonstrating security headers in response.
    # [WHY] All responses include OWASP security headers via middleware.
    return JSONResponse(content={"message": "This response has security headers"})


@app.post("/user-comment")
async def create_comment(comment: str):
    # [WHAT] Accept user comment and sanitize it.
    # [WHY] Prevent XSS attacks from stored comments.
    
    # [WHAT] Sanitize HTML.
    sanitized = sanitize_html(comment)
    
    return JSONResponse(content={"comment": sanitized, "safe": True})


@app.post("/contact")
async def create_contact(name: str, email: str):
    # [WHAT] Contact form with email validation.
    # [WHY] Prevent injection attacks via invalid email addresses.
    
    if not validate_email(email):
        return JSONResponse(content={"error": "Invalid email format"}, status_code=400)
    
    return JSONResponse(content={"message": f"Contact from {name} received"}, status_code=201)


@app.post("/search")
async def search(query: str):
    # [WHAT] Search endpoint with SQL injection prevention.
    # [WHY] Prevent attackers from injecting SQL commands.
    
    try:
        safe_query = prevent_sql_injection(query)
        # In production, use parameterized queries with ORM/database driver
        return JSONResponse(content={"query": safe_query, "results": []})
    except ValueError as e:
        return JSONResponse(content={"error": str(e)}, status_code=400)


@app.get("/cors-test")
async def cors_test():
    # [WHAT] Endpoint to test CORS behavior.
    # [WHY] Verify cross-origin requests are properly controlled.
    return JSONResponse(content={"message": "CORS is configured"})


@app.get("/security-headers")
async def check_security_headers():
    # [WHAT] Endpoint describing security headers.
    return JSONResponse(content={
        "security_headers": {
            "Content-Security-Policy": "Restricts script and resource loading",
            "Strict-Transport-Security": "Forces HTTPS",
            "X-Content-Type-Options": "Prevents MIME sniffing",
            "X-Frame-Options": "Prevents clickjacking",
        }
    })


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8007")
    print("[INFO] Security features enabled:")
    print("  - CORS middleware (configured origins only)")
    print("  - TrustedHostMiddleware (Host header validation)")
    print("  - GZipMiddleware (response compression)")
    print("  - Security headers (CSP, HSTS, X-*, etc.)")
    print("  - Input validation & sanitization")
    print("[INFO] Try these endpoints:")
    print("  - GET /secure-data")
    print("  - POST /user-comment (test XSS prevention)")
    print("  - POST /contact (test email validation)")
    print("  - POST /search (test SQL injection prevention)")
    print("  - GET /cors-test")
    print("  - GET /security-headers")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8007, workers=1, log_level="info")
SEGMENT_7_EOF

echo "[✓] Segment 7 generated: segment_7_security_hardening.py"


echo ""
echo "================================================================================"
echo "SEGMENT 8: Alembic Migrations & Schema Evolution"
echo "================================================================================"

cat << 'SEGMENT_8_EOF' > segment_8_alembic_migrations.py
"""
Segment 8: Alembic Migrations & Schema Evolution
================================================

This module demonstrates Alembic setup, migration workflows, data migrations,
zero-downtime strategies, and migration testing patterns.

NOTE: This is a demonstration of Alembic patterns. Full Alembic setup
requires the alembic init command and separate migration files.
"""

from sqlalchemy import Column, Integer, String, DateTime, create_engine, inspect
from sqlalchemy.orm import declarative_base, sessionmaker
from datetime import datetime
from typing import List

Base = declarative_base()


# [WHAT] Initial schema version (before migration).
class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    email = Column(String, unique=True)


# [WHAT] Evolved schema with new field (after migration).
class UserV2(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True)
    email = Column(String, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)  # NEW FIELD


# ============================================================================
# ALEMBIC MIGRATION EXAMPLES (CONCEPTUAL)
# ============================================================================

"""
Example Alembic workflow:

1. INITIALIZE ALEMBIC:
   $ alembic init alembic
   
   This creates:
   - alembic/env.py (runtime environment)
   - alembic/script.py.mako (migration template)
   - alembic.ini (configuration)

2. AUTOGENERATE MIGRATIONS:
   $ alembic revision --autogenerate -m "Add created_at field to users"
   
   This compares the current database schema to SQLAlchemy models and 
   generates a migration file.

3. MIGRATION FILE STRUCTURE:
   
   from alembic import op
   import sqlalchemy as sa
   
   revision = 'abc123'
   down_revision = 'xyz789'
   branch_labels = None
   depends_on = None
   
   def upgrade():
       # [COMPONENT MEANING] op.add_column() = Alembic operation adding a new column to an existing table.
       op.add_column('users', sa.Column('created_at', sa.DateTime(), nullable=True))
   
   def downgrade():
       # [COMPONENT MEANING] op.drop_column() = Alembic operation removing a column from an existing table.
       op.drop_column('users', 'created_at')

4. APPLY MIGRATIONS:
   $ alembic upgrade head
   
   Applies all pending migrations to the database.

5. ROLLBACK MIGRATIONS:
   $ alembic downgrade -1
   
   Reverts the last migration.
"""


# ============================================================================
# MIGRATION PATTERNS
# ============================================================================

class MigrationPatterns:
    """
    Demonstrates various migration patterns and considerations.
    """
    
    # [WHAT] Zero-downtime migration pattern.
    # [WHY] Large tables can lock the database during schema changes.
    # [HOW] Use backward-compatible changes and multi-step migrations.
    
    """
    Pattern: Adding a NOT NULL column to large table
    
    Step 1: Add column as nullable
        ALTER TABLE users ADD COLUMN status VARCHAR DEFAULT 'active' NULL;
    
    Step 2: Backfill existing rows
        UPDATE users SET status = 'active' WHERE status IS NULL;
    
    Step 3: Add NOT NULL constraint
        ALTER TABLE users MODIFY COLUMN status VARCHAR NOT NULL;
    
    This avoids table locks and allows rollback between steps.
    """
    
    # [WHAT] Renaming a column without downtime.
    # [WHY] Direct column rename can break code that uses the old name.
    # [HOW] Create new column, migrate data, drop old column.
    
    """
    Pattern: Renaming column 'email' to 'email_address'
    
    Step 1: Add new column
        ALTER TABLE users ADD COLUMN email_address VARCHAR;
    
    Step 2: Migrate data
        UPDATE users SET email_address = email WHERE email IS NOT NULL;
    
    Step 3: Update application to use new column
        # Deploy new code that reads/writes email_address
    
    Step 4: Drop old column
        ALTER TABLE users DROP COLUMN email;
    
    This allows the old and new columns to coexist during deployment.
    """
    
    # [WHAT] Data migration (transform data, not schema).
    # [WHY] Sometimes you need to transform existing data.
    # [HOW] Use op.execute() for raw SQL within migration.
    
    """
    Pattern: Data migration with op.execute()
    
    def upgrade():
        # Transform email to lowercase
        op.execute('UPDATE users SET email = LOWER(email)')
    
    def downgrade():
        # Impossible to restore original case, so raise error
        raise NotImplementedError()
    """


# ============================================================================
# DATABASE SCHEMA INSPECTION (PROGRAMMATIC)
# ============================================================================

def inspect_schema(database_url: str) -> dict:
    # [WHAT] Programmatically inspect database schema.
    # [WHY] Useful for testing migrations and debugging schema issues.
    
    engine = create_engine(database_url)
    inspector = inspect(engine)
    
    schema_info = {
        "tables": inspector.get_table_names(),
        "columns_by_table": {},
    }
    
    for table_name in inspector.get_table_names():
        columns = inspector.get_columns(table_name)
        schema_info["columns_by_table"][table_name] = [
            {"name": col["name"], "type": str(col["type"])}
            for col in columns
        ]
    
    return schema_info


# ============================================================================
# MIGRATION TESTING PATTERNS
# ============================================================================

def test_migration_forward():
    # [WHAT] Test that upgrade() succeeds.
    # [WHY] Catch migration errors before production.
    
    """
    Test pattern:
    
    1. Create test database
    2. Run migrations to N-1 version
    3. Apply migration N
    4. Verify schema changes
    5. Verify data integrity
    6. Clean up
    """
    pass

def test_migration_backward():
    # [WHAT] Test that downgrade() succeeds.
    # [WHY] Ensure rollback works if migration causes issues.
    
    """
    Test pattern:
    
    1. Create test database
    2. Run all migrations
    3. Run downgrade -1
    4. Verify schema reverted
    5. Verify no data loss
    6. Clean up
    """
    pass


# ============================================================================
# ALEMBIC CLI COMMANDS REFERENCE
# ============================================================================

"""
COMMON ALEMBIC COMMANDS:

[FastAPI-8.A] | alembic init
    Creates initial Alembic directory structure (env.py, migrations/, alembic.ini)

[FastAPI-8.B] | alembic revision --autogenerate -m "message"
    Compares models to database and auto-generates migration file

[FastAPI-8.C] | alembic upgrade head
    Applies all pending migrations to bring database to latest schema

[FastAPI-8.D] | alembic downgrade -1
    Reverts the last migration

[FastAPI-8.E] | alembic current
    Shows the current database revision

[FastAPI-8.F] | alembic history
    Displays migration history with revision IDs

[FastAPI-8.G] | upgrade() function
    Defined in migration files; defines schema changes for forward migration

[FastAPI-8.H] | downgrade() function
    Defined in migration files; defines schema changes for backward migration

[FastAPI-8.I] | op.create_table()
    Alembic operation creating a new database table with columns and constraints

[FastAPI-8.J] | op.drop_table()
    Alembic operation removing a database table and all its data

[FastAPI-8.K] | op.add_column()
    Alembic operation adding a new column to an existing table

[FastAPI-8.L] | op.drop_column()
    Alembic operation removing a column from an existing table

[FastAPI-8.M] | op.alter_column()
    Alembic operation modifying column properties like type, nullable, or default value

[FastAPI-8.N] | op.create_index()
    Alembic operation creating a database index for query performance optimization

[FastAPI-8.O] | op.execute()
    Alembic operation executing raw SQL for complex data migrations not supported by built-in operations

[FastAPI-8.P] | env.py
    Alembic file configuring database connection and migration runtime environment

[FastAPI-8.Q] | alembic.ini
    Alembic configuration file containing database URL and migration settings

[FastAPI-8.R] | revision attribute
    Migration file attribute containing the unique revision ID

[FastAPI-8.S] | down_revision attribute
    Migration file attribute pointing to the previous migration revision

[FastAPI-8.T] | branch_labels attribute
    Migration file attribute for creating named branches in migration history
"""


if __name__ == "__main__":
    print("\n" + "="*80)
    print("SEGMENT 8: Alembic Migrations & Schema Evolution")
    print("="*80)
    print("\nThis segment is conceptual and demonstrates Alembic patterns.")
    print("\nTo use Alembic in a real project:")
    print("  1. Install: pip install alembic sqlalchemy")
    print("  2. Initialize: alembic init alembic")
    print("  3. Configure DATABASE_URL in alembic.ini")
    print("  4. Create migrations: alembic revision --autogenerate -m 'message'")
    print("  5. Apply migrations: alembic upgrade head")
    print("  6. Check status: alembic current")
    print("  7. Rollback: alembic downgrade -1")
    print("\nKey concepts:")
    print("  - Alembic separates schema changes from data migrations")
    print("  - Zero-downtime migrations use backward-compatible multi-step changes")
    print("  - Always test migrations in development before production")
    print("  - Use op.execute() for complex data transformations")
    print("\n")
SEGMENT_8_EOF

echo "[✓] Segment 8 generated: segment_8_alembic_migrations.py"


echo ""
echo "================================================================================"
echo "SEGMENT 9: Asynchronous Programming & Concurrency Control"
echo "================================================================================"

cat << 'SEGMENT_9_EOF' > segment_9_async_concurrency.py
"""
Segment 9: Asynchronous Programming & Concurrency Control
=========================================================

This module demonstrates asyncio fundamentals, concurrent execution patterns,
BackgroundTasks, task retries, and concurrency primitives (Lock, Semaphore, etc.).
"""

import asyncio
from typing import List
from fastapi import FastAPI, BackgroundTasks
from fastapi.responses import JSONResponse
import uvicorn
import time

app = FastAPI(title="Segment 9: Async & Concurrency")


# ============================================================================
# ASYNCIO FUNDAMENTALS
# ============================================================================

async def slow_operation(operation_id: int, duration: int = 2) -> dict:
    # [WHAT] Async function that yields control during sleep.
    # [WHY] Allows other requests to be processed while this waits.
    print(f"[Operation {operation_id}] Starting ({duration}s)")
    # [COMPONENT MEANING] asyncio.sleep() = Non-blocking sleep function that yields control to the event loop.
    await asyncio.sleep(duration)
    print(f"[Operation {operation_id}] Completed")
    return {"operation_id": operation_id, "duration": duration}


async def fetch_user(user_id: int) -> dict:
    # [WHAT] Simulate fetching user from API.
    await asyncio.sleep(0.5)  # Simulate I/O delay
    return {"user_id": user_id, "name": f"User {user_id}"}

async def fetch_posts(user_id: int) -> list:
    # [WHAT] Simulate fetching posts for user.
    await asyncio.sleep(0.3)  # Simulate I/O delay
    return [{"post_id": 1, "title": "Post 1"}, {"post_id": 2, "title": "Post 2"}]

async def fetch_comments(post_id: int) -> list:
    # [WHAT] Simulate fetching comments for post.
    await asyncio.sleep(0.2)
    return [{"comment_id": 1, "text": "Great!"}, {"comment_id": 2, "text": "Thanks!"}]


# ============================================================================
# ENDPOINTS: ASYNCIO PATTERNS
# ============================================================================

@app.get("/single-operation")
async def single_operation():
    # [WHAT] Single async operation.
    result = await slow_operation(operation_id=1, duration=1)
    return JSONResponse(content=result)


@app.get("/concurrent-operations")
async def concurrent_operations():
    # [WHAT] Run multiple operations concurrently.
    # [WHY] Sequential execution takes 3 seconds; concurrent takes ~2 seconds.
    # [COMPONENT MEANING] asyncio.gather() = Function running multiple coroutines concurrently and collecting their results in order.
    
    # [WATCH OUT]: Sequential (slow)
    # result1 = await slow_operation(1)
    # result2 = await slow_operation(2)
    # result3 = await slow_operation(3)
    # Total: 6 seconds
    
    # [HOW]: Concurrent (fast)
    results = await asyncio.gather(
        slow_operation(operation_id=1, duration=2),
        slow_operation(operation_id=2, duration=2),
        slow_operation(operation_id=3, duration=2),
    )
    # Total: ~2 seconds (overlapping)
    
    return JSONResponse(content={"results": results})


@app.get("/user-profile/{user_id}")
async def get_user_profile(user_id: int):
    # [WHAT] Fetch user, posts, and comments concurrently.
    # [HOW] Gather multiple async operations.
    
    user, posts = await asyncio.gather(
        fetch_user(user_id),
        fetch_posts(user_id),
    )
    
    return JSONResponse(content={"user": user, "posts": posts})


@app.get("/timeout-demo")
async def timeout_demo():
    # [WHAT] Demonstrate asyncio.wait_for() timeout.
    # [WHY] Prevent hanging requests; fail fast if operation takes too long.
    # [COMPONENT MEANING] asyncio.wait_for() = Function enforcing a timeout on an async operation, raising TimeoutError if exceeded.
    
    try:
        result = await asyncio.wait_for(
            slow_operation(operation_id=1, duration=5),
            timeout=2.0  # Timeout after 2 seconds
        )
        return JSONResponse(content=result)
    except asyncio.TimeoutError:
        return JSONResponse(
            content={"error": "Operation timed out"},
            status_code=504
        )


@app.get("/create-task-demo")
async def create_task_demo():
    # [WHAT] Schedule a task concurrently using create_task().
    # [WHY] Fire off a task without waiting for it; useful for background work.
    # [COMPONENT MEANING] asyncio.create_task() = Function scheduling a coroutine to run concurrently on the event loop.
    
    # [HOW]: Create task (runs concurrently)
    task = asyncio.create_task(slow_operation(operation_id=1, duration=2))
    
    # Return immediately; task continues in background
    return JSONResponse(content={"message": "Task created", "task_id": "task_1"})


# ============================================================================
# CONCURRENCY PRIMITIVES
# ============================================================================

# [COMPONENT MEANING] asyncio.Lock = Async-safe mutex lock preventing race conditions in shared resource access.
shared_counter = 0
counter_lock = asyncio.Lock()

async def increment_counter_safe():
    # [WHAT] Safely increment counter using Lock.
    # [WHY] Prevent race conditions in concurrent access.
    global shared_counter
    
    async with counter_lock:
        # Critical section: only one coroutine at a time
        temp = shared_counter
        await asyncio.sleep(0.01)  # Simulate some work
        shared_counter = temp + 1

@app.get("/increment-with-lock")
async def increment_with_lock():
    # [WHAT] Demonstrate Lock preventing race conditions.
    
    # Run 10 increments concurrently (safely)
    await asyncio.gather(*[increment_counter_safe() for _ in range(10)])
    
    return JSONResponse(content={"counter": shared_counter})


# [COMPONENT MEANING] asyncio.Semaphore = Async-safe semaphore limiting concurrent access to a resource with a maximum count.
semaphore = asyncio.Semaphore(3)  # Allow max 3 concurrent accesses

async def limited_resource_access(request_id: int):
    # [WHAT] Access a limited resource (e.g., connection pool).
    # [WHY] Prevent overwhelming the resource with too many concurrent accesses.
    
    async with semaphore:
        print(f"[Request {request_id}] Accessing limited resource")
        await asyncio.sleep(1)
        print(f"[Request {request_id}] Releasing resource")
        return f"Request {request_id} completed"

@app.get("/limited-resource")
async def limited_resource():
    # [WHAT] Queue multiple requests for a limited resource.
    
    results = await asyncio.gather(*[
        limited_resource_access(i) for i in range(10)
    ])
    
    return JSONResponse(content={"results": results})


# [COMPONENT MEANING] asyncio.Queue = Async-safe queue for producer-consumer patterns between concurrent tasks.
task_queue: asyncio.Queue = asyncio.Queue()

async def producer(item_id: int):
    # [WHAT] Produce items and add to queue.
    for i in range(5):
        await task_queue.put(f"Item {item_id}-{i}")
        await asyncio.sleep(0.1)

async def consumer(consumer_id: int):
    # [WHAT] Consume items from queue.
    for _ in range(5):
        item = await task_queue.get()
        print(f"[Consumer {consumer_id}] Processing {item}")
        await asyncio.sleep(0.2)
        task_queue.task_done()

@app.get("/queue-demo")
async def queue_demo():
    # [WHAT] Demonstrate producer-consumer pattern with Queue.
    
    # Create 2 producers and 2 consumers
    await asyncio.gather(
        producer(1),
        producer(2),
        consumer(1),
        consumer(2),
    )
    
    return JSONResponse(content={"message": "Queue demo completed"})


# ============================================================================
# BACKGROUND TASKS
# ============================================================================

def send_email(email: str, subject: str):
    # [WHAT] Synchronous task (simulating email sending).
    print(f"[SEND EMAIL] To: {email}, Subject: {subject}")
    time.sleep(2)  # Simulate email sending
    print(f"[SEND EMAIL] Sent to {email}")

async def send_email_async(email: str, subject: str):
    # [WHAT] Async version of email sending.
    print(f"[SEND EMAIL ASYNC] To: {email}, Subject: {subject}")
    await asyncio.sleep(2)  # Simulate email sending
    print(f"[SEND EMAIL ASYNC] Sent to {email}")

@app.post("/register")
async def register(email: str, background_tasks: BackgroundTasks):
    # [WHAT] Register user and send confirmation email in background.
    # [WHY] Don't make client wait for email delivery.
    # [COMPONENT MEANING] BackgroundTasks = FastAPI class for scheduling fire-and-forget tasks after the response is sent.
    
    # [ARGUMENT MEANING] background_tasks.add_task() = Method queuing a function to run in the background after response delivery.
    background_tasks.add_task(send_email, email=email, subject="Welcome!")
    
    return JSONResponse(content={"message": "Registration successful, confirmation email sent"}, status_code=201)


# ============================================================================
# RETRY LOGIC WITH EXPONENTIAL BACKOFF
# ============================================================================

async def unreliable_api_call(attempt: int = 1, max_retries: int = 3) -> dict:
    # [WHAT] Simulate API call that might fail.
    # [WHY] Demonstrate retry logic with backoff.
    
    import random
    if random.random() < 0.7:  # 70% chance of failure
        raise ConnectionError(f"API call failed on attempt {attempt}")
    
    return {"data": "Success"}

async def call_with_retries(max_retries: int = 3, backoff: float = 1.0) -> dict:
    # [WHAT] Call unreliable API with retries and exponential backoff.
    # [WHY] Increase resilience by retrying transient failures.
    
    for attempt in range(1, max_retries + 1):
        try:
            print(f"[RETRY] Attempt {attempt}/{max_retries}")
            return await unreliable_api_call(attempt=attempt)
        except ConnectionError as e:
            if attempt == max_retries:
                raise
            
            # [WHAT]: Exponential backoff: 1s, 2s, 4s, etc.
            wait_time = backoff * (2 ** (attempt - 1))
            print(f"[RETRY] Failed, retrying in {wait_time}s")
            await asyncio.sleep(wait_time)

@app.get("/retry-demo")
async def retry_demo():
    # [WHAT] Demonstrate retry logic.
    
    try:
        result = await call_with_retries(max_retries=3, backoff=0.5)
        return JSONResponse(content=result)
    except ConnectionError:
        return JSONResponse(content={"error": "All retries exhausted"}, status_code=503)


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8009")
    print("[INFO] Try these endpoints:")
    print("  - GET /single-operation")
    print("  - GET /concurrent-operations (demonstrates gathering)")
    print("  - GET /user-profile/1 (concurrent fetch)")
    print("  - GET /timeout-demo (demonstrates timeouts)")
    print("  - GET /create-task-demo")
    print("  - GET /increment-with-lock (demonstrates Lock)")
    print("  - GET /limited-resource (demonstrates Semaphore)")
    print("  - GET /queue-demo (demonstrates Queue)")
    print("  - POST /register?email=test@example.com (background task)")
    print("  - GET /retry-demo (demonstrates retry logic)")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8009, workers=1, log_level="info")
SEGMENT_9_EOF

echo "[✓] Segment 9 generated: segment_9_async_concurrency.py"


echo ""
echo "================================================================================"
echo "SEGMENT 10: API Performance Optimization & Caching"
echo "================================================================================"

cat << 'SEGMENT_10_EOF' > segment_10_caching_performance.py
"""
Segment 10: API Performance Optimization & Caching
=================================================

This module demonstrates HTTP caching headers, Redis integration,
cache strategies, and response compression.
"""

from fastapi import FastAPI, Header
from fastapi.responses import JSONResponse, ORJSONResponse
from fastapi.middleware.gzip import GZipMiddleware
from datetime import datetime, timedelta
import uvicorn
import hashlib
import json

app = FastAPI(title="Segment 10: Caching & Performance")

# Add GZip compression middleware
# [COMPONENT MEANING] GZipMiddleware = Middleware compressing responses with gzip when client supports it.
app.add_middleware(GZipMiddleware, minimum_size=1000)


# ============================================================================
# HTTP CACHING HEADERS
# ============================================================================

def generate_etag(data: dict) -> str:
    # [WHAT] Generate ETag hash from data.
    # [WHY] ETag allows browser/proxy to validate cached content.
    
    json_str = json.dumps(data, sort_keys=True)
    return hashlib.md5(json_str.encode()).hexdigest()

@app.get("/users/{user_id}")
async def get_user_cached(user_id: int, if_none_match: str = Header(None)):
    # [WHAT] Endpoint with ETag-based caching.
    # [WHY] Avoid sending response body if client has fresh cached version.
    
    user_data = {
        "user_id": user_id,
        "username": f"user_{user_id}",
        "email": f"user{user_id}@example.com",
    }
    
    # [COMPONENT MEANING] ETag = HTTP header containing a hash of response content for conditional request validation.
    etag = generate_etag(user_data)
    
    # [ARGUMENT MEANING] If-None-Match = HTTP request header containing ETag value for conditional GET requests.
    if if_none_match == etag:
        # Client has the latest version
        return JSONResponse(content={}, status_code=304)  # Not Modified
    
    response = JSONResponse(content=user_data)
    response.headers["ETag"] = etag
    # [COMPONENT MEANING] Cache-Control = HTTP response header controlling browser and proxy caching behavior.
    response.headers["Cache-Control"] = "public, max-age=300"  # Cache for 5 minutes
    
    return response


@app.get("/public-data")
async def get_public_data():
    # [WHAT] Endpoint with Cache-Control header.
    # [WHY] Tell browser/CDN how long to cache this response.
    
    data = {"data": "This is public and can be cached"}
    
    response = JSONResponse(content=data)
    # [ARGUMENT MEANING] Cache-Control = max-age specifies cache duration in seconds.
    response.headers["Cache-Control"] = "public, max-age=3600"  # Cache for 1 hour
    # [COMPONENT MEANING] Last-Modified = HTTP header containing the timestamp of when the resource was last changed.
    response.headers["Last-Modified"] = datetime.utcnow().strftime("%a, %d %b %Y %H:%M:%S GMT")
    
    return response


@app.get("/user-data/{user_id}")
async def get_user_data_conditional(user_id: int, if_modified_since: str = Header(None)):
    # [WHAT] Endpoint with Last-Modified-based caching.
    # [WHY] Allow client to revalidate with timestamp.
    
    # Simulate resource last modified 1 hour ago
    last_modified = (datetime.utcnow() - timedelta(hours=1))
    
    user_data = {"user_id": user_id, "data": "cached"}
    
    response = JSONResponse(content=user_data)
    # [ARGUMENT MEANING] If-Modified-Since = HTTP request header containing timestamp for conditional GET requests.
    response.headers["Last-Modified"] = last_modified.strftime("%a, %d %b %Y %H:%M:%S GMT")
    response.headers["Cache-Control"] = "public, max-age=600"
    
    return response


# ============================================================================
# IN-MEMORY CACHING (SIMPLE CACHE)
# ============================================================================

# [WHAT] Simple in-memory cache (for single-server; use Redis for distributed).
simple_cache = {}

def cache_get(key: str):
    # [WHAT] Retrieve value from cache if not expired.
    entry = simple_cache.get(key)
    if entry and entry["expires_at"] > datetime.utcnow():
        return entry["value"]
    return None

def cache_set(key: str, value, ttl_seconds: int = 300):
    # [WHAT] Store value in cache with TTL.
    simple_cache[key] = {
        "value": value,
        "expires_at": datetime.utcnow() + timedelta(seconds=ttl_seconds)
    }

@app.get("/expensive-computation")
async def expensive_computation(n: int = 10):
    # [WHAT] Endpoint with simple in-memory caching.
    
    cache_key = f"computation_{n}"
    
    # Check cache first
    cached_result = cache_get(cache_key)
    if cached_result:
        return JSONResponse(content={"result": cached_result, "source": "cache"})
    
    # Compute if not cached
    result = sum(i ** 2 for i in range(n))
    
    # Cache the result
    cache_set(cache_key, result, ttl_seconds=300)
    
    return JSONResponse(content={"result": result, "source": "computed"})


# ============================================================================
# REDIS CACHING SIMULATION
# ============================================================================

# [WHAT] Simulated Redis cache (in production, use aioredis).
redis_cache = {}

# [COMPONENT MEANING] Redis = In-memory data store used for high-performance caching and session management.
# [COMPONENT MEANING] aioredis = Async Redis client library for non-blocking Redis operations in FastAPI.

# [ARGUMENT MEANING] set() = Redis command storing a key-value pair with optional expiration.
# [ARGUMENT MEANING] get() = Redis command retrieving the value associated with a key.
# [ARGUMENT MEANING] setex() = Redis command storing a key-value pair with expiration time in seconds.
# [ARGUMENT MEANING] expire() = Redis command setting expiration time on an existing key.
# [ARGUMENT MEANING] delete() = Redis command removing one or more keys from the cache.
# [ARGUMENT MEANING] pipeline() = Redis method batching multiple commands to reduce network round trips.
# [ARGUMENT MEANING] lock() = Redis distributed lock mechanism preventing cache stampede with mutual exclusion.

async def redis_set(key: str, value: str, ex: int = None):
    # [WHAT] Simulate Redis SET command.
    redis_cache[key] = {"value": value, "expires_at": datetime.utcnow() + timedelta(seconds=ex) if ex else None}

async def redis_get(key: str):
    # [WHAT] Simulate Redis GET command.
    entry = redis_cache.get(key)
    if entry:
        if entry["expires_at"] is None or entry["expires_at"] > datetime.utcnow():
            return entry["value"]
        else:
            del redis_cache[key]
    return None

async def redis_delete(key: str):
    # [WHAT] Simulate Redis DELETE command.
    if key in redis_cache:
        del redis_cache[key]

@app.get("/cached-user/{user_id}")
async def get_cached_user(user_id: int):
    # [WHAT] Endpoint using Redis cache.
    
    cache_key = f"user:{user_id}"
    
    # Try to get from Redis
    cached_user = await redis_get(cache_key)
    if cached_user:
        return JSONResponse(content={"user": json.loads(cached_user), "source": "redis"})
    
    # Fetch from "database"
    user_data = {"user_id": user_id, "name": f"User {user_id}"}
    
    # Store in Redis with 5-minute expiration
    await redis_set(cache_key, json.dumps(user_data), ex=300)
    
    return JSONResponse(content={"user": user_data, "source": "database"})


@app.post("/invalidate-cache/{user_id}")
async def invalidate_user_cache(user_id: int):
    # [WHAT] Invalidate user cache on update.
    # [WHY] When user data changes, remove from cache to prevent stale data.
    
    cache_key = f"user:{user_id}"
    await redis_delete(cache_key)
    
    return JSONResponse(content={"message": f"Cache for user {user_id} invalidated"})


# ============================================================================
# PERFORMANCE OPTIMIZATION
# ============================================================================

@app.get("/fast-json")
async def fast_json():
    # [WHAT] Use ORJSONResponse for faster serialization.
    # [COMPONENT MEANING] ORJSONResponse = High-performance JSON response class using the orjson library for faster serialization.
    
    data = {
        "items": [{"id": i, "value": i ** 2} for i in range(1000)],
        "count": 1000,
    }
    
    # ORJSONResponse is significantly faster than JSONResponse
    return ORJSONResponse(content=data)

@app.get("/slow-json")
async def slow_json():
    # [WHAT] Use standard JSONResponse (slower).
    
    data = {
        "items": [{"id": i, "value": i ** 2} for i in range(1000)],
        "count": 1000,
    }
    
    return JSONResponse(content=data)


@app.get("/cache-key-builder")
async def cache_key_builder(user_id: int, format: str = "json"):
    # [COMPONENT MEANING] cache_key_builder = Function constructing unique cache keys from request parameters.
    # [WHAT]: Build cache key from request params to avoid collisions.
    
    # [HOW]: Combine request parameters to create unique key
    cache_key = f"user:{user_id}:format:{format}"
    
    return JSONResponse(content={"cache_key": cache_key})


@app.get("/bulk-data")
async def bulk_data(limit: int = 100):
    # [WHAT] Large response that benefits from compression.
    # [WHY] GZipMiddleware automatically compresses responses > 1000 bytes.
    
    items = [
        {
            "id": i,
            "name": f"Item {i}",
            "description": f"This is item {i} with some description",
            "price": i * 10.5,
        }
        for i in range(limit)
    ]
    
    return JSONResponse(content={"items": items, "count": len(items)})


@app.get("/health")
async def health():
    return JSONResponse(content={"status": "ok"})


if __name__ == "__main__":
    print("\n[INFO] Starting Uvicorn server on http://localhost:8010")
    print("[INFO] Try these endpoints:")
    print("  - GET /users/1 (with ETag caching)")
    print("  - GET /public-data (with Cache-Control)")
    print("  - GET /user-data/1 (with Last-Modified)")
    print("  - GET /expensive-computation?n=100 (in-memory cache)")
    print("  - GET /cached-user/1 (Redis simulation)")
    print("  - POST /invalidate-cache/1 (invalidate cache)")
    print("  - GET /fast-json (ORJSONResponse)")
    print("  - GET /slow-json (JSONResponse)")
    print("  - GET /bulk-data?limit=500 (tests GZip compression)")
    print("\n")
    
    uvicorn.run(app=app, host="127.0.0.1", port=8010, workers=1, log_level="info")
SEGMENT_10_EOF

echo "[✓] Segment 10 generated: segment_10_caching_performance.py"


echo ""
echo "================================================================================"
echo "ALL SEGMENTS GENERATED SUCCESSFULLY"
echo "================================================================================"

echo ""
echo "Created files:"
ls -lh *.py

echo ""
echo "================================================================================"
echo "NEXT STEPS"
echo "================================================================================"
echo ""
echo "To run each segment individually:"
echo ""
echo "  python segment_1_core_architecture.py"
echo "  python segment_2_pydantic_validation.py"
echo "  python segment_3_response_models.py"
echo "  python segment_4_dependency_injection.py"
echo "  python segment_5_database_integration.py"
echo "  python segment_6_authentication.py"
echo "  python segment_7_security_hardening.py"
echo "  python segment_8_alembic_migrations.py"
echo "  python segment_9_async_concurrency.py"
echo "  python segment_10_caching_performance.py"
echo ""
echo "Each segment runs on a different port (8001-8010)."
echo "Access Swagger docs at: http://localhost:PORT/docs"
echo ""
echo "================================================================================"

echo ""
echo "✓ Code generation complete! Files are in: $WORKSPACE"
echo ""