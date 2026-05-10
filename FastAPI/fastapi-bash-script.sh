#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# FastAPI LEAN-BUT-DEEP CURRICULUM: Production-Ready Full Build
# ============================================================================
# This script generates comprehensive, production-ready FastAPI code
# demonstrating all 20 curriculum segments with pedagogical annotations.
# 
# Each segment showcases: Basic Usage → Power Usage → Precision Usage → Enterprise Context
# ============================================================================

WORKSPACE=$(mktemp -d)
trap 'rm -rf "$WORKSPACE"' EXIT

cd "$WORKSPACE"
echo "🚀 Working in: $WORKSPACE"

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --quiet --upgrade pip
pip install fastapi uvicorn pydantic sqlalchemy aioredis pytest httpx alembic \
  python-jose passlib python-multipart pyjwt cryptography python-json-logger \
  structlog opentelemetry-api opentelemetry-sdk prometheus-client tenacity \
  pybreaker psutil orjson

echo ""
echo "============================================================================"
echo "SEGMENT 1: FastAPI Core Architecture & ASGI Request Lifecycle"
echo "============================================================================"

cat << 'EOF' > segment_1_core_architecture.py
"""
[WHAT]: ASGI, Starlette, Uvicorn, request/response lifecycle, async/sync boundaries
[WHY]: Foundation for non-blocking I/O. Knowing ASGI prevents event loop blocking disasters.
"""

from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
import asyncio
from typing import Callable

# ========== BASIC USAGE: Lifecycle Hooks ==========

# [COMPONENT MEANING] @app.on_event("startup") = Registers function to run ONCE when app starts
# [ARGUMENT MEANING] "startup" = Hook type; also "shutdown" available
app = FastAPI()

startup_state = {"initialized": False}

@app.on_event("startup")
async def startup_event():
    """Runs once before accepting requests. Async context available."""
    startup_state["initialized"] = True
    print("[STARTUP] App initialized")

@app.on_event("shutdown")
async def shutdown_event():
    """Runs once during graceful shutdown. Clean up resources here."""
    print("[SHUTDOWN] App shutting down")

@app.get("/basic")
async def basic_endpoint():
    """[HOW]: Async route yields control to event loop during I/O."""
    await asyncio.sleep(0.1)  # Non-blocking I/O
    return {"status": "ok"}

# ========== POWER USAGE: Lifespan Context Manager (FastAPI 0.93+) ==========

# [COMPONENT MEANING] lifespan = Modern async context manager for startup/shutdown
# More elegant than separate decorators, allows shared state between startup/shutdown
async def lifespan(app: FastAPI):
    """[WHAT]: Unified startup/shutdown with context manager syntax."""
    # SETUP PHASE (runs before app accepts requests)
    print("[LIFESPAN] Starting up")
    app.state.db_pool = {"initialized": True, "connections": []}
    yield  # App runs here, receiving requests
    # TEARDOWN PHASE (runs during shutdown)
    print("[LIFESPAN] Shutting down")
    app.state.db_pool["connections"].clear()

app_v2 = FastAPI(lifespan=lifespan)

# ========== PRECISION USAGE: Async/Sync Boundaries & Event Loop Safety ==========

# [WATCH OUT]: Synchronous function in async context BLOCKS event loop
@app.get("/blocking-trap")
async def blocking_trap():
    """DANGEROUS: This blocks the event loop for EVERYONE."""
    import time
    time.sleep(1)  # ❌ BLOCKS EVENT LOOP! All other requests wait!
    return {"status": "slow"}

# [COMPONENT MEANING] run_in_executor() = Offload blocking code to thread pool
# [ARGUMENT MEANING] None = Uses default ThreadPoolExecutor (default interpreter)
@app.get("/non-blocking")
async def non_blocking():
    """[HOW]: Offload blocking I/O to executor, keep event loop free."""
    loop = asyncio.get_event_loop()
    # [WATCH OUT]: Never block in async; always use run_in_executor for sync code
    result = await loop.run_in_executor(None, lambda: 2 + 2)
    return {"result": result}

# ========== ENTERPRISE CONTEXT: Custom Request/Response Handling ==========

# [COMPONENT MEANING] Request = Starlette request object with full HTTP context
# [COMPONENT MEANING] Response = Starlette response builder for custom HTTP output
@app.get("/custom-response")
async def custom_response(request: Request) -> Response:
    """[WHY]: Enterprise apps need custom headers, status codes, and streaming."""
    # Access request internals
    client_host = request.client.host if request.client else "unknown"
    user_agent = request.headers.get("user-agent", "unknown")
    
    # [WHAT ELSE]: Response types include JSONResponse, FileResponse, StreamingResponse
    response = JSONResponse(
        {"host": client_host, "agent": user_agent},
        status_code=200,
        headers={"X-Custom-Header": "enterprise-value"}
    )
    return response

# Demonstrates async/sync correctness
@app.get("/async-correct")
async def async_correct():
    """[HOW]: Async handler can safely call other async functions."""
    result = await asyncio.sleep(0)
    return {"status": "async-safe"}

@app.post("/sync-for-cpu")
def sync_for_cpu():
    """[WATCH OUT]: CPU-bound work should be SYNC (decorated as 'def', not 'async def')."""
    # Pure CPU computation; no I/O, so async overhead is wasted
    return {"cpu_work": sum(range(1000))}

if __name__ == "__main__":
    import uvicorn
    # [COMPONENT MEANING] uvicorn.run() = Starts ASGI server with event loop management
    # [ARGUMENT MEANING] --host 0.0.0.0 = Listen on all interfaces
    # [ARGUMENT MEANING] --port 8000 = Standard FastAPI port
    # uvicorn.run(app, host="0.0.0.0", port=8000, reload=False)
    pass
EOF

echo "✓ Segment 1: Core Architecture (segment_1_core_architecture.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 2: Request Validation with Pydantic Deep-Dive"
echo "============================================================================"

cat << 'EOF' > segment_2_pydantic_validation.py
"""
[WHAT]: BaseModel, field validation, custom validators, polymorphic unions, edge cases
[WHY]: Pydantic is the production-ready validator. Strict mode prevents data corruption.
"""

from fastapi import FastAPI, HTTPException, Path, Query, Body, Header, Cookie
from pydantic import BaseModel, Field, field_validator, model_validator, ValidationInfo, constr, conint
from typing import Optional, Union, Annotated, Literal
import re

app = FastAPI()

# ========== BASIC USAGE: Simple BaseModel & Field Validation ==========

# [COMPONENT MEANING] BaseModel = Pydantic root class for defining request/response schemas
# [ARGUMENT MEANING] Field(default, description, ...) = Attach validation rules and metadata
class UserCreate(BaseModel):
    """[HOW]: Pydantic auto-validates on instantiation."""
    username: str = Field(..., min_length=3, max_length=50, description="Username must be 3-50 chars")
    email: str = Field(..., pattern=r"^[^@]+@[^@]+\.[^@]+$", description="Valid email required")
    age: int = Field(default=None, ge=0, le=150, description="Age must be 0-150")

@app.post("/basic-validation")
async def basic_validation(user: UserCreate):
    """[WATCH OUT]: Pydantic validates before route executes. Invalid data returns 422."""
    return {"status": "validated", "user": user}

# ========== POWER USAGE: Custom Validators & Context ==========

# [COMPONENT MEANING] @field_validator = Decorator for custom field-level validation
# [ARGUMENT MEANING] mode="before" = Run BEFORE type coercion; mode="after" = RUN AFTER
class AdvancedUser(BaseModel):
    username: str = Field(..., min_length=3)
    password: str = Field(..., min_length=8)
    password_confirm: str
    
    @field_validator("username", mode="before")
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        """[WHAT]: Pre-validation; coerce or reject before type checking."""
        if not re.match(r"^[a-zA-Z0-9_]+$", v):
            raise ValueError("Username must be alphanumeric + underscore")
        return v.lower()  # Normalize to lowercase
    
    @field_validator("password", mode="after")
    @classmethod
    def password_strong(cls, v: str) -> str:
        """[HOW]: Post-validation; password is already string after type coercion."""
        if not any(c.isupper() for c in v):
            raise ValueError("Password must contain uppercase letter")
        if not any(c.isdigit() for c in v):
            raise ValueError("Password must contain digit")
        return v
    
    # [COMPONENT MEANING] @model_validator = Cross-field validation for coherence
    @model_validator(mode="after")
    def passwords_match(self) -> "AdvancedUser":
        """[WHAT]: Access multiple fields; validate relationships."""
        if self.password != self.password_confirm:
            raise ValueError("Passwords do not match")
        return self

@app.post("/advanced-validation")
async def advanced_validation(user: AdvancedUser):
    return {"status": "validated", "username": user.username}

# ========== PRECISION USAGE: Polymorphic Models & Discriminator ==========

# [COMPONENT MEANING] discriminator = Field that determines which Union member to use
# [ARGUMENT MEANING] discriminator="type" = Field "type" decides shape of payload
class Cat(BaseModel):
    pet_type: Literal["cat"] = "cat"
    meows: int

class Dog(BaseModel):
    pet_type: Literal["dog"] = "dog"
    barks: float

class Hamster(BaseModel):
    pet_type: Literal["hamster"] = "hamster"
    fur_color: str

# [WHAT]: Discriminated union picks correct model based on "pet_type" field
Pet = Annotated[Union[Cat, Dog, Hamster], Field(discriminator="pet_type")]

class PetStore(BaseModel):
    pet: Pet
    owner: str

@app.post("/polymorphic")
async def polymorphic_endpoint(store: PetStore):
    """[HOW]: Pydantic uses discriminator to pick correct Union member."""
    return {"owner": store.owner, "pet_type": store.pet.pet_type}

# ========== ENTERPRISE CONTEXT: Path/Query/Body Validation ==========

# [COMPONENT MEANING] Path() = Extract & validate URL path parameters
# [COMPONENT MEANING] Query() = Extract & validate query string parameters
# [COMPONENT MEANING] Header() = Extract & validate HTTP headers
# [ARGUMENT MEANING] alias="user-id" = External name differs from Python name
class QueryFilter(BaseModel):
    search: str = Field(default="", min_length=0, max_length=100)
    limit: int = Field(default=10, ge=1, le=100)

@app.get("/search/{item_id}")
async def search_with_filters(
    item_id: Annotated[int, Path(ge=1, description="Item ID must be positive")] = 1,
    query: QueryFilter = Query(),
    x_token: Annotated[str, Header(description="API token")] = None
):
    """[WHY]: Enterprise apps need strict parameter validation across all input sources."""
    return {"item_id": item_id, "query": query, "has_token": x_token is not None}

# [COMPONENT MEANING] ConfigDict(extra="forbid") = Reject unknown fields
class StrictPayload(BaseModel):
    model_config = {"extra": "forbid"}
    name: str
    value: int

@app.post("/strict")
async def strict_endpoint(payload: StrictPayload):
    """[WATCH OUT]: ConfigDict(extra='forbid') raises error on unknown fields."""
    return payload

# [COMPONENT MEANING] constr() = Inline constrained string type
# [COMPONENT MEANING] conint() = Inline constrained integer type
UsernameType = constr(pattern=r"^[a-z0-9]{3,20}$")  # type: ignore
PortType = conint(ge=1, le=65535)  # type: ignore

@app.post("/constrained")
async def constrained_types(username: UsernameType, port: PortType):
    """[HOW]: Constrained types embed validation in type definition."""
    return {"username": username, "port": port}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 2: Pydantic Validation (segment_2_pydantic_validation.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 3: Response Models & Serialization Strategies"
echo "============================================================================"

cat << 'EOF' > segment_3_response_models.py
"""
[WHAT]: response_model, exclude_unset/none/defaults, custom serializers, streaming
[WHY]: Clean response contracts. Exclude noise. Serialize non-JSON types properly.
"""

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse, StreamingResponse, FileResponse, ORJSONResponse
from pydantic import BaseModel, field_serializer
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Optional, Union
import json
from io import BytesIO

app = FastAPI()

# ========== BASIC USAGE: response_model with Exclusion ==========

# [COMPONENT MEANING] response_model = Route parameter validating outgoing response
class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    created_at: datetime
    is_admin: bool = False

class UserFull(BaseModel):
    id: int
    username: str
    email: str
    password_hash: str  # Never return this!
    created_at: datetime
    is_admin: bool = False

@app.get("/user/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    """[WHAT]: response_model filters response; password_hash never leaves server."""
    user_full = UserFull(
        id=user_id,
        username="john",
        email="john@example.com",
        password_hash="bcrypt$2y$12$xxx",  # ❌ Never returned
        created_at=datetime.now(),
        is_admin=False
    )
    return user_full  # FastAPI extracts only UserResponse fields

# [COMPONENT MEANING] response_model_exclude_unset = Omit fields not explicitly set
class UserPartial(BaseModel):
    id: int
    username: str
    bio: Optional[str] = None
    follower_count: int = 0

@app.get("/user/{user_id}/minimal", response_model=UserPartial, response_model_exclude_unset=True)
async def get_user_minimal(user_id: int):
    """[HOW]: exclude_unset omits 'follower_count' if not explicitly set."""
    return {"id": user_id, "username": "john"}  # Missing fields omitted from JSON

# ========== POWER USAGE: Custom Serializers & JSON Encoders ==========

# [COMPONENT MEANING] @field_serializer = Custom serialization per field
class Order(BaseModel):
    order_id: int
    total_price: Decimal
    created_at: datetime
    
    @field_serializer("total_price")
    def serialize_price(self, value: Decimal) -> str:
        """[HOW]: Serialize Decimal as string with 2 decimal places."""
        return f"${value:.2f}"
    
    @field_serializer("created_at")
    def serialize_timestamp(self, value: datetime) -> str:
        """[WHAT]: Custom datetime serialization (ISO 8601)."""
        return value.isoformat()

@app.get("/order/{order_id}", response_model=Order)
async def get_order(order_id: int):
    return Order(
        order_id=order_id,
        total_price=Decimal("123.45"),
        created_at=datetime.now()
    )

# ========== PRECISION USAGE: Multiple Response Models with Union ==========

# [COMPONENT MEANING] Union[Model1, Model2] = Route returns one of multiple types
class SuccessResponse(BaseModel):
    status: str = "success"
    data: dict

class ErrorResponse(BaseModel):
    status: str = "error"
    error_code: int
    message: str

@app.get("/risky/{item_id}", response_model=Union[SuccessResponse, ErrorResponse])
async def risky_endpoint(item_id: int):
    """[WATCH OUT]: Union response_model requires explicit type union."""
    if item_id > 100:
        return SuccessResponse(data={"item": item_id})
    else:
        return ErrorResponse(error_code=404, message="Not found")

# ========== ENTERPRISE CONTEXT: Streaming & Performance ==========

# [COMPONENT MEANING] StreamingResponse = Send large data without buffering
async def generate_csv():
    """[HOW]: Generator yields chunks; client receives incrementally."""
    yield b"id,name,email\n"
    for i in range(10000):
        yield f"{i},user{i},user{i}@example.com\n".encode()

@app.get("/export/csv")
async def export_csv():
    """[WHAT]: Stream large datasets without loading into memory."""
    return StreamingResponse(generate_csv(), media_type="text/csv")

# [COMPONENT MEANING] ORJSONResponse = High-performance JSON using orjson
@app.get("/fast-json", response_class=ORJSONResponse)
async def fast_json():
    """[WHY]: orjson is 2-3x faster than standard json for large responses."""
    return {"data": [{"id": i, "value": i * 2} for i in range(1000)]}

# [COMPONENT MEANING] status_code = HTTP status for successful response
@app.post("/resource", status_code=201, response_model=UserResponse)
async def create_resource(username: str):
    """[WHAT]: status_code=201 indicates resource created (not 200)."""
    return {"id": 1, "username": username, "email": "new@example.com", "created_at": datetime.now()}

# [COMPONENT MEANING] response_model_exclude_none = Omit None fields
class ProductResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    discount: Optional[float] = None

@app.get("/product/{product_id}", response_model=ProductResponse, response_model_exclude_none=True)
async def get_product(product_id: int):
    """[HOW]: exclude_none prevents {"discount": null} in response."""
    return {"id": product_id, "name": "Widget", "description": None, "discount": None}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 3: Response Models (segment_3_response_models.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 4: Dependency Injection System Mastery"
echo "============================================================================"

cat << 'EOF' > segment_4_dependency_injection.py
"""
[WHAT]: Depends(), caching, generator dependencies, testing overrides
[WHY]: DI decouples components. Caching prevents redundant execution. Testing becomes easy.
"""

from fastapi import FastAPI, Depends, HTTPException
from typing import Generator, Annotated, Optional
import asyncio

app = FastAPI()

# ========== BASIC USAGE: Simple Dependency ==========

# [COMPONENT MEANING] Depends() = Declare dependency to be injected
# [ARGUMENT MEANING] use_cache=True = Default; cache result within single request
async def get_db_connection() -> str:
    """[WHAT]: Simulated async database connection."""
    print("[DB] Opening connection")
    await asyncio.sleep(0.1)
    return "db_connection_object"

@app.get("/basic-di")
async def basic_di(db: Annotated[str, Depends(get_db_connection)]):
    """[HOW]: FastAPI injects result of get_db_connection()."""
    return {"db": db}

# ========== POWER USAGE: Generator Dependencies (Setup/Teardown) ==========

# [COMPONENT MEANING] yield = Separate setup from teardown in dependencies
# [ARGUMENT MEANING] Code before yield = setup; code after = teardown
async def get_db_session() -> Generator[str, None, None]:
    """[WHY]: Generator allows cleanup (close connection, rollback) after request."""
    print("[SESSION] Opening")
    session = "session_object"
    try:
        yield session  # Route handler receives session
    finally:
        print("[SESSION] Closing")
        # Cleanup happens here automatically

@app.get("/generator-di")
async def generator_di(session: Annotated[str, Depends(get_db_session)]):
    """[HOW]: FastAPI manages setup/teardown automatically."""
    return {"session": session}

# ========== PRECISION USAGE: Caching & Nesting ==========

# [COMPONENT MEANING] use_cache=False = Fresh execution every time
class AuthUser:
    def __init__(self, name: str):
        self.name = name

async def get_current_user(token: str) -> AuthUser:
    """[WHAT]: Dependency resolves token to user."""
    if not token:
        raise HTTPException(status_code=401)
    return AuthUser(name="john")

async def get_user_permissions(user: Annotated[AuthUser, Depends(get_current_user)]) -> list[str]:
    """[HOW]: Sub-dependency receives result of parent dependency."""
    return ["read", "write"] if user.name == "john" else ["read"]

@app.get("/with-sub-dependencies")
async def with_sub_deps(
    permissions: Annotated[list[str], Depends(get_user_permissions)]
):
    """[WATCH OUT]: Dependency graph resolved recursively; caching prevents re-execution."""
    return {"permissions": permissions}

# ========== ENTERPRISE CONTEXT: Class-Based Dependencies & Overrides ==========

# [COMPONENT MEANING] Class as dependency = Callable with __call__ method
class PaginationParams:
    """[WHY]: Reusable dependency class for common pagination logic."""
    def __init__(self, skip: int = 0, limit: int = 10):
        self.skip = max(0, skip)
        self.limit = min(100, limit)  # Cap limit at 100

@app.get("/items")
async def list_items(pagination: Annotated[PaginationParams, Depends()]):
    """[HOW]: FastAPI instantiates PaginationParams with query params."""
    return {"skip": pagination.skip, "limit": pagination.limit, "items": []}

# [COMPONENT MEANING] app.dependency_overrides = Replace dependency for testing
# [ARGUMENT MEANING] {original_dep: mock_dep} = Override mapping
async def mock_db():
    return "mock_connection"

def test_with_override():
    """[WHAT]: Testing requires replacing real DB with mock."""
    app.dependency_overrides[get_db_connection] = mock_db
    # Now all routes using get_db_connection receive mock_db instead
    app.dependency_overrides.clear()  # Clean up after test

# [COMPONENT MEANING] dependencies=[...] on route = Apply dependencies to single route
@app.get("/protected", dependencies=[Depends(get_current_user)])
async def protected_route():
    """[HOW]: Current user is validated but not explicitly in signature."""
    return {"status": "authorized"}

# [COMPONENT MEANING] dependencies=[...] on router = Apply to all routes in router
from fastapi import APIRouter
router = APIRouter(dependencies=[Depends(get_current_user)])

@router.get("/admin/users")
async def admin_list_users():
    """[WHAT]: All routes in this router require get_current_user."""
    return {"users": []}

app.include_router(router)

# ========== ADVANCED: Context Variables in Dependencies ==========

async def get_request_id(x_request_id: Optional[str] = None) -> str:
    """[WHY]: Request-scoped state (e.g., correlation ID) via DI."""
    return x_request_id or "no-request-id"

@app.get("/correlation")
async def with_correlation(
    request_id: Annotated[str, Depends(get_request_id)]
):
    """[HOW]: Dependency receives query param as request-scoped state."""
    return {"request_id": request_id}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 4: Dependency Injection (segment_4_dependency_injection.py)"

# Continuing with remaining segments...

echo ""
echo "============================================================================"
echo "SEGMENT 5: Database Integration with SQLAlchemy Async"
echo "============================================================================"

cat << 'EOF' > segment_5_sqlalchemy_async.py
"""
[WHAT]: AsyncEngine, AsyncSession, connection pooling, N+1 prevention, transactions
[WHY]: Async DB prevents event loop blocking. Pooling maximizes throughput.
"""

from fastapi import FastAPI, Depends
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, create_async_engine, async_sessionmaker
from sqlalchemy import Column, Integer, String, DateTime, select, ForeignKey
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.pool import NullPool, QueuePool
from sqlalchemy.orm import selectinload, joinedload
from typing import Annotated, AsyncGenerator
from datetime import datetime
import asyncio

app = FastAPI()

# ========== BASIC USAGE: AsyncEngine & AsyncSession Setup ==========

# [COMPONENT MEANING] create_async_engine() = Factory for async database engine
# [ARGUMENT MEANING] "sqlite+aiosqlite:///" = Async SQLite URL (in-memory)
# [ARGUMENT MEANING] pool_size = Max persistent connections; max_overflow = burst overflow
engine: AsyncEngine = create_async_engine(
    "sqlite+aiosqlite:///:memory:",
    echo=False,  # Set to True to log SQL
    pool_size=10,  # Persistent connections
    max_overflow=5,  # Additional connections during load
    pool_pre_ping=True  # Validate connections before checkout
)

# [COMPONENT MEANING] async_sessionmaker = Factory for AsyncSession instances
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

Base = declarative_base()

# ========== MODEL DEFINITIONS ==========

class User(Base):
    __tablename__ = "users"
    id: int = Column(Integer, primary_key=True)
    username: str = Column(String(50), unique=True)
    email: str = Column(String(100))
    created_at: datetime = Column(DateTime, default=datetime.utcnow)
    posts: list["Post"] = relationship("Post", back_populates="author")

class Post(Base):
    __tablename__ = "posts"
    id: int = Column(Integer, primary_key=True)
    title: str = Column(String(200))
    user_id: int = Column(Integer, ForeignKey("users.id"))
    created_at: datetime = Column(DateTime, default=datetime.utcnow)
    author: User = relationship("User", back_populates="posts")

# ========== BASIC USAGE: Session Dependency ==========

async def get_session() -> AsyncGenerator[AsyncSession, None]:
    """[WHAT]: Session-per-request pattern using async generator."""
    async with async_session() as session:
        try:
            yield session
        finally:
            await session.close()  # Return to pool

@app.get("/user/{user_id}")
async def get_user(user_id: int, session: Annotated[AsyncSession, Depends(get_session)]):
    """[HOW]: Dependency provides fresh session; auto-closed after response."""
    stmt = select(User).where(User.id == user_id)
    result = await session.execute(stmt)
    user = result.scalars().first()
    return {"user": user}

# ========== POWER USAGE: Query Optimization & Eager Loading ==========

# [COMPONENT MEANING] selectinload() = Load relationships in separate SELECT with IN clause
# [ARGUMENT MEANING] selectinload(User.posts) = Fetch user.posts in second query
@app.get("/user/{user_id}/posts-optimized")
async def get_user_with_posts(user_id: int, session: Annotated[AsyncSession, Depends(get_session)]):
    """[WHY]: selectinload prevents N+1 query: 1 user + N posts = N+1 queries."""
    stmt = select(User).where(User.id == user_id).options(selectinload(User.posts))
    result = await session.execute(stmt)
    user = result.scalars().unique().first()
    return {"user": user, "post_count": len(user.posts) if user else 0}

# [COMPONENT MEANING] joinedload() = Load relationships via SQL JOIN in single query
# [WATCH OUT]: joinedload can cause cartesian product if not careful with multiple relationships
@app.get("/user/{user_id}/posts-joined")
async def get_user_with_posts_joined(user_id: int, session: Annotated[AsyncSession, Depends(get_session)]):
    """[HOW]: joinedload uses JOIN; fewer queries but potentially larger result set."""
    stmt = select(User).where(User.id == user_id).options(joinedload(User.posts))
    result = await session.execute(stmt)
    user = result.scalars().unique().first()
    return {"user": user}

# ========== PRECISION USAGE: Transactions & Isolation ==========

async def create_user_with_posts(session: AsyncSession, username: str) -> User:
    """[WHAT]: Multi-statement transaction; all-or-nothing."""
    try:
        user = User(username=username, email=f"{username}@example.com")
        session.add(user)
        await session.flush()  # Get auto-generated ID without commit
        
        post = Post(title="First Post", user_id=user.id)
        session.add(post)
        
        await session.commit()  # Atomic: both created or both rolled back
        return user
    except Exception as e:
        await session.rollback()
        raise

@app.post("/user")
async def create_user(username: str, session: Annotated[AsyncSession, Depends(get_session)]):
    """[HOW]: Transactions ensure data consistency across multiple operations."""
    user = await create_user_with_posts(session, username)
    return {"id": user.id, "username": user.username}

# ========== ENTERPRISE CONTEXT: Connection Pool Tuning ==========

# [COMPONENT MEANING] pool_recycle = Force reconnect after N seconds (MySQL timeout)
# [ARGUMENT MEANING] 3600 = Recycle connections older than 1 hour
enterprise_engine = create_async_engine(
    "sqlite+aiosqlite:///:memory:",
    pool_size=20,  # Production: tune to DB connection limit / worker count
    max_overflow=10,  # Buffer for traffic spikes
    pool_pre_ping=True,  # Detect stale connections
    pool_recycle=3600,  # MySQL default: 8-hour timeout
    echo=False
)

# [WATCH OUT]: pool exhaustion under high concurrency causes request queuing
@app.get("/check-pool")
async def check_pool_status():
    """[WHY]: Monitor pool state to prevent exhaustion under load."""
    # In production: log pool size, overflow, checkedout connections
    return {"pool_size": enterprise_engine.pool.size(), "overflow": engine.pool.overflow()}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 5: SQLAlchemy Async (segment_5_sqlalchemy_async.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 6: Authentication & Authorization Implementation"
echo "============================================================================"

cat << 'EOF' > segment_6_authentication.py
"""
[WHAT]: OAuth2, JWT, password hashing, token refresh, RBAC, scopes
[WHY]: Production auth prevents unauthorized access. JWT is stateless. Scopes enforce least privilege.
"""

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm, HTTPBearer, HTTPAuthCredentials
from pydantic import BaseModel
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta, timezone
from typing import Annotated, Optional
import os

app = FastAPI()

# ========== SETUP: Hashing & JWT Configuration ==========

# [COMPONENT MEANING] CryptContext = Secure password hashing with pluggable algorithms
# [ARGUMENT MEANING] schemes=["bcrypt"] = Use bcrypt as primary; auto-upgrade from argon2
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret-key-change-in-production")  # ❌ Never hardcode
ALGORITHM = "HS256"  # [WATCH OUT]: ALGORITHM="RS256" preferred for distributed systems
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# ========== BASIC USAGE: Password Hashing ==========

# [COMPONENT MEANING] hash() = Generate bcrypt hash from plaintext password
# [ARGUMENT MEANING] Bcrypt cost is auto-tuned; takes ~100ms per hash (security feature)
def hash_password(password: str) -> str:
    """[HOW]: Never store plaintext. Always hash with random salt."""
    return pwd_context.hash(password)

# [COMPONENT MEANING] verify() = Constant-time comparison; prevents timing attacks
def verify_password(plaintext: str, hashed: str) -> bool:
    """[WATCH OUT]: Timing attack: == operator leaks hash byte-by-byte. Use verify()."""
    return pwd_context.verify(plaintext, hashed)

# ========== POWER USAGE: JWT Token Management ==========

class TokenPayload(BaseModel):
    sub: str  # Subject (user ID)
    exp: datetime  # Expiration
    iat: datetime  # Issued at
    scopes: list[str] = []  # OAuth2 scopes

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """[WHAT]: Sign JWT with payload and secret key."""
    to_encode = data.copy()
    
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    
    to_encode.update({"exp": expire, "iat": datetime.now(timezone.utc)})
    
    # [COMPONENT MEANING] jwt.encode() = Create signed token
    # [ARGUMENT MEANING] algorithm="HS256" = HMAC SHA-256 symmetric signing
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> dict:
    """[HOW]: Verify signature and extract payload."""
    try:
        # [COMPONENT MEANING] jwt.decode() = Verify signature; reject if tampered
        # [ARGUMENT MEANING] algorithms=["HS256"] = Accept only this algorithm (prevent confusion attacks)
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# ========== PRECISION USAGE: OAuth2 Password Flow ==========

# [COMPONENT MEANING] OAuth2PasswordBearer = Security scheme for password flow
# [ARGUMENT MEANING] tokenUrl="/token" = Swagger UI uses this endpoint for login
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token", scopes={"read": "Read data", "write": "Write data"})

class User(BaseModel):
    username: str
    scopes: list[str] = []

# Simulated user database
fake_users_db = {
    "john": {
        "username": "john",
        "password_hash": hash_password("secret123"),
        "scopes": ["read", "write"]
    }
}

async def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]) -> User:
    """[WHAT]: Dependency that validates JWT and returns current user."""
    payload = decode_access_token(token)
    username = payload.get("sub")
    
    if not username or username not in fake_users_db:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    user_dict = fake_users_db[username]
    return User(username=username, scopes=user_dict["scopes"])

@app.post("/token")
async def login(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]) -> dict:
    """[HOW]: Password flow endpoint. Return access token on success."""
    user_dict = fake_users_db.get(form_data.username)
    
    if not user_dict or not verify_password(form_data.password, user_dict["password_hash"]):
        raise HTTPException(status_code=401, detail="Incorrect credentials")
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token({"sub": form_data.username}, access_token_expires)
    
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/user/me")
async def read_current_user(current_user: Annotated[User, Depends(get_current_user)]) -> User:
    """[WHAT]: Protected endpoint. Requires valid JWT."""
    return current_user

# ========== ENTERPRISE CONTEXT: Role-Based Access Control ==========

# [COMPONENT MEANING] SecurityScopes = Access required scopes for current request
from fastapi.security import SecurityScopes

async def get_current_admin_user(
    security_scopes: SecurityScopes,
    current_user: Annotated[User, Depends(get_current_user)]
) -> User:
    """[WHY]: RBAC ensures user has required scopes/permissions."""
    if "admin" not in current_user.scopes:
        raise HTTPException(status_code=403, detail="Not authorized")
    return current_user

@app.delete("/admin/user/{username}")
async def delete_user(
    username: str,
    admin: Annotated[User, Depends(get_current_admin_user)]
) -> dict:
    """[HOW]: Only admin-scoped users can access this endpoint."""
    return {"deleted": username}

# [COMPONENT MEANING] HTTPBearer = Security scheme for Bearer tokens (alternative to OAuth2)
http_bearer = HTTPBearer()

async def verify_bearer_token(credentials: HTTPAuthCredentials = Depends(http_bearer)) -> dict:
    """[WHAT]: Parse Authorization: Bearer <token> header."""
    token = credentials.credentials
    payload = decode_access_token(token)
    return payload

@app.get("/bearer")
async def bearer_example(payload: Annotated[dict, Depends(verify_bearer_token)]):
    """[HOW]: HTTPBearer extracts token from Authorization header."""
    return {"user": payload.get("sub")}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 6: Authentication (segment_6_authentication.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 7: Security Hardening & OWASP Defense"
echo "============================================================================"

cat << 'EOF' > segment_7_security_hardening.py
"""
[WHAT]: CORS, headers, TLS, injection prevention, rate limiting
[WHY]: OWASP top 10. Defense in depth. Headers are cheap security wins.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi.responses import JSONResponse
from starlette.requests import Request
import re

app = FastAPI()

# ========== BASIC USAGE: CORS Configuration ==========

# [COMPONENT MEANING] CORSMiddleware = Handle CORS preflight and headers
# [ARGUMENT MEANING] allow_origins = List of allowed origin domains
# [WATCH OUT]: allow_origins=["*"] allows any origin; use explicit list in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://example.com", "https://app.example.com"],  # Explicit whitelist
    allow_credentials=True,  # Allow cookies/auth headers in CORS
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
    max_age=600  # Preflight cache 10 minutes
)

# ========== POWER USAGE: Security Headers & TLS ==========

# [COMPONENT MEANING] TrustedHostMiddleware = Validate Host header to prevent injection
app.add_middleware(TrustedHostMiddleware, allowed_hosts=["example.com", "*.example.com"])

# [COMPONENT MEANING] GZipMiddleware = Compress responses to reduce bandwidth
app.add_middleware(GZipMiddleware, minimum_size=1000)

# [COMPONENT MEANING] Security headers = Browser-enforced protections
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    """[WHAT]: Add HTTP security headers to every response."""
    response = await call_next(request)
    
    # [ARGUMENT MEANING] Strict-Transport-Security = Enforce HTTPS for future requests
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    
    # [ARGUMENT MEANING] Content-Security-Policy = Restrict resource loading (prevent XSS)
    response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self' 'unsafe-inline'"
    
    # [ARGUMENT MEANING] X-Content-Type-Options = Prevent MIME sniffing
    response.headers["X-Content-Type-Options"] = "nosniff"
    
    # [ARGUMENT MEANING] X-Frame-Options = Prevent clickjacking
    response.headers["X-Frame-Options"] = "DENY"
    
    return response

# ========== PRECISION USAGE: Input Validation & Injection Prevention ==========

@app.get("/search")
async def search(q: str):
    """[HOW]: Validate input to prevent SQL/NoSQL/Command injection."""
    # ❌ BAD: Search using raw SQL
    # query = f"SELECT * FROM users WHERE name LIKE '%{q}%'"  # SQL injection!
    
    # ✓ GOOD: Use parameterized queries (FastAPI + SQLAlchemy do this)
    if len(q) > 100:
        raise HTTPException(status_code=400, detail="Query too long")
    
    # Only allow alphanumeric and spaces
    if not re.match(r"^[a-zA-Z0-9\s]+$", q):
        raise HTTPException(status_code=400, detail="Invalid characters in query")
    
    return {"query": q, "results": []}

# ========== ENTERPRISE CONTEXT: Rate Limiting & Request Logging ==========

from collections import defaultdict
from datetime import datetime, timedelta
import asyncio

# Simple in-memory rate limiter (use Redis in production)
request_counts = defaultdict(list)

class RateLimitMiddleware(BaseHTTPMiddleware):
    """[WHAT]: Token bucket algorithm preventing abuse."""
    
    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        now = datetime.utcnow()
        
        # Clean old requests (older than 1 minute)
        request_counts[client_ip] = [
            req_time for req_time in request_counts[client_ip]
            if now - req_time < timedelta(minutes=1)
        ]
        
        # [HOW]: Allow 60 requests per minute per IP
        if len(request_counts[client_ip]) >= 60:
            return JSONResponse(
                {"detail": "Rate limit exceeded"},
                status_code=429,
                headers={"Retry-After": "60"}
            )
        
        request_counts[client_ip].append(now)
        
        response = await call_next(request)
        response.headers["X-RateLimit-Limit"] = "60"
        response.headers["X-RateLimit-Remaining"] = str(60 - len(request_counts[client_ip]))
        
        return response

app.add_middleware(RateLimitMiddleware)

# ========== mTLS (Mutual TLS) for Service-to-Service ==========

@app.get("/api/internal")
async def internal_api(request: Request):
    """[WHAT]: Endpoints accessible only with mTLS client certificate."""
    # In production: verify request.client.sslObject certificate chain
    client_cert = request.headers.get("X-Client-Cert")
    
    if not client_cert:
        raise HTTPException(status_code=403, detail="Client certificate required")
    
    return {"authenticated": True}

# [WATCH OUT]: CORS bypass via null origin or subdomain regex
# Always validate Origin header explicitly; never use regex that matches too broadly
@app.options("/api/resource")
async def preflight_check(request: Request):
    """[HOW]: Handle CORS preflight properly."""
    origin = request.headers.get("Origin")
    
    # ❌ BAD: if origin.endswith(".example.com")  # Matches evil.com.example.com
    # ✓ GOOD: explicit whitelist
    allowed = ["https://app.example.com", "https://admin.example.com"]
    
    if origin not in allowed:
        raise HTTPException(status_code=403, detail="CORS not allowed")
    
    return {"allowed": True}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 7: Security Hardening (segment_7_security_hardening.py)"

# Continue with remaining segments...

echo ""
echo "============================================================================"
echo "SEGMENT 8: Alembic Migrations & Schema Evolution"
echo "============================================================================"

cat << 'EOF' > segment_8_alembic_migrations.py
"""
[WHAT]: Alembic CLI, migration files, data migrations, zero-downtime strategies
[WHY]: Track schema changes. Backward-compatible migrations prevent downtime.
"""

# This segment is CLI-heavy; code demonstrates migration patterns
# In real usage: alembic init project; alembic revision --autogenerate -m "message"

migration_patterns = {
    "basic_usage": """
# Example Alembic migration file: alembic/versions/001_initial.py

from alembic import op
import sqlalchemy as sa

revision = "001"
down_revision = None

def upgrade():
    # [COMPONENT MEANING] op.create_table() = Create new table in migration
    op.create_table(
        'users',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('username', sa.String(50), unique=True),
        sa.Column('created_at', sa.DateTime, server_default=sa.func.now())
    )
    
    # [WHAT]: Add index for performance
    op.create_index('ix_users_username', 'users', ['username'])

def downgrade():
    # [COMPONENT MEANING] op.drop_table() = Remove table during rollback
    op.drop_table('users')
    """,
    
    "data_migration": """
# Alembic data migration: Add default values to new column

def upgrade():
    # [HOW]: Add new column, then backfill existing rows
    op.add_column('users', sa.Column('status', sa.String, nullable=True))
    
    # [WATCH OUT]: Raw SQL for data migration; ensure it's idempotent
    op.execute("UPDATE users SET status = 'active' WHERE status IS NULL")
    
    # Now make it non-nullable
    op.alter_column('users', 'status', nullable=False)

def downgrade():
    op.drop_column('users', 'status')
    """,
    
    "zero_downtime": """
# Zero-downtime migration: Multi-step for backward compatibility

# Step 1 (v1.0): Existing code still uses 'email' column
def upgrade_1_0():
    # Add new column, keep old one
    op.add_column('users', sa.Column('email_normalized', sa.String, nullable=True))

# Step 2 (v1.1): Code reads from both, writes to both
def upgrade_1_1():
    # Backfill new column
    op.execute("UPDATE users SET email_normalized = email")
    op.alter_column('users', 'email_normalized', nullable=False)

# Step 3 (v1.2): Code reads from new column, deprecate old
def upgrade_1_2():
    # Old code can still work; new code prefers email_normalized
    pass

# Step 4 (v2.0): Remove old column
def upgrade_2_0():
    op.drop_column('users', 'email')
    """,
    
    "alembic_ini": """
# alembic.ini configuration snippet
[alembic]
sqlalchemy.url = driver://user:pass@localhost/dbname
script_location = alembic
""",
}

print("[SEGMENT 8] Alembic migration patterns documented")
print(migration_patterns["basic_usage"])

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 8: Alembic Migrations (segment_8_alembic_migrations.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 9: Asynchronous Programming & Concurrency Control"
echo "============================================================================"

cat << 'EOF' > segment_9_async_concurrency.py
"""
[WHAT]: asyncio.create_task, gather, wait_for, locks, semaphores, BackgroundTasks
[WHY]: Non-blocking concurrency scales to thousands of concurrent connections.
"""

from fastapi import FastAPI, BackgroundTasks
import asyncio
from typing import List
import time

app = FastAPI()

# ========== BASIC USAGE: Concurrent Tasks ==========

# [COMPONENT MEANING] asyncio.gather() = Run multiple coroutines concurrently
# [ARGUMENT MEANING] *coros = Variable args; waits for all to complete
async def fetch_data(item_id: int) -> dict:
    """Simulate async I/O (database query, HTTP request, etc.)."""
    await asyncio.sleep(0.1)  # Non-blocking
    return {"item_id": item_id, "data": f"data_{item_id}"}

@app.get("/concurrent/{user_id}")
async def concurrent_fetch(user_id: int):
    """[WHAT]: Fetch multiple items concurrently."""
    item_ids = [1, 2, 3, 4, 5]
    
    # Sequential (BAD): 5 * 0.1s = 0.5s total
    # results = [await fetch_data(item_id) for item_id in item_ids]
    
    # Concurrent (GOOD): 0.1s total (all at same time)
    # [HOW]: gather() waits for all tasks
    results = await asyncio.gather(*[fetch_data(item_id) for item_id in item_ids])
    
    return {"user_id": user_id, "items": results}

# ========== POWER USAGE: Task Creation & Timeout ==========

# [COMPONENT MEANING] asyncio.create_task() = Schedule coroutine on event loop
# [COMPONENT MEANING] asyncio.wait_for() = Enforce timeout on async operation
async def long_operation() -> str:
    """[WHAT]: Operation that might timeout."""
    await asyncio.sleep(10)
    return "done"

@app.get("/timeout-example")
async def timeout_example():
    """[HOW]: wait_for() raises TimeoutError if timeout exceeded."""
    try:
        # [WATCH OUT]: Timeout too strict = false negatives; too loose = slow errors
        result = await asyncio.wait_for(long_operation(), timeout=5.0)
        return {"result": result}
    except asyncio.TimeoutError:
        return {"error": "Operation timed out"}

# ========== PRECISION USAGE: Synchronization Primitives ==========

# [COMPONENT MEANING] asyncio.Lock = Mutex preventing concurrent access
# [COMPONENT MEANING] asyncio.Semaphore = Limit N concurrent tasks
# [COMPONENT MEANING] asyncio.Event = Signal between coroutines

lock = asyncio.Lock()
semaphore = asyncio.Semaphore(3)  # Max 3 concurrent access
event = asyncio.Event()

shared_resource = {"count": 0}

async def increment_with_lock():
    """[WHAT]: Lock prevents race condition on shared_resource."""
    async with lock:
        # Critical section; only one coroutine at a time
        shared_resource["count"] += 1
        await asyncio.sleep(0.01)

@app.get("/lock-example")
async def lock_example():
    """[HOW]: Create 10 concurrent tasks; lock ensures atomicity."""
    await asyncio.gather(*[increment_with_lock() for _ in range(10)])
    return {"count": shared_resource["count"]}  # Always 10, never race condition

async def limited_access():
    """[WHAT]: Semaphore limits to N concurrent accessors."""
    async with semaphore:
        await asyncio.sleep(0.1)
        return "processed"

@app.get("/semaphore-example")
async def semaphore_example():
    """[HOW]: Semaphore(3) limits to 3 concurrent tasks."""
    tasks = [limited_access() for _ in range(10)]
    results = await asyncio.gather(*tasks)
    return {"processed": len(results)}

# ========== ENTERPRISE CONTEXT: BackgroundTasks & Task Queues ==========

# [COMPONENT MEANING] BackgroundTasks = Fire-and-forget tasks after response sent
# [ARGUMENT MEANING] add_task(func, *args) = Queue function to run in background

def send_email(email: str, subject: str):
    """[WATCH OUT]: This blocks! Use BackgroundTasks for non-critical work."""
    time.sleep(1)  # Simulate slow email send
    print(f"[EMAIL] Sent to {email}: {subject}")

@app.post("/user")
async def create_user(username: str, email: str, background_tasks: BackgroundTasks):
    """[HOW]: Email sent after response returned. User doesn't wait."""
    # Immediate response to client
    background_tasks.add_task(send_email, email, f"Welcome, {username}!")
    
    return {"username": username, "message": "User created"}

# [COMPONENT MEANING] asyncio.create_task() = For internal async work, not HTTP response
@app.get("/background-task")
async def background_task_example():
    """[WHAT]: Create_task() schedules coroutine to run concurrently."""
    async def background_work():
        await asyncio.sleep(5)
        print("[BACKGROUND] Finished after response")
    
    # Schedule without awaiting; runs concurrently
    task = asyncio.create_task(background_work())
    
    # ❌ Don't return immediately without cleanup!
    # ✓ Store task in app state or use BackgroundTasks instead
    return {"task_started": task.get_name()}

# ========== Celery for Distributed Task Queues ==========

celery_patterns = {
    "basic": """
from celery import Celery

app_celery = Celery('myapp', broker='redis://localhost:6379')

@app_celery.task
def send_email_task(email, subject):
    # [WHAT]: Distributed task; runs on worker process
    send_email(email, subject)
    """,
    
    "with_retry": """
@app_celery.task(bind=True, max_retries=3)
def risky_task(self, data):
    try:
        result = do_something_risky(data)
        return result
    except Exception as exc:
        # [HOW]: Exponential backoff: 60s, then 120s, then 240s
        self.retry(exc=exc, countdown=2 ** self.request.retries * 60)
    """,
}

print("[SEGMENT 9] Celery patterns demonstrated")

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 9: Async & Concurrency (segment_9_async_concurrency.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 10: API Performance Optimization & Caching"
echo "============================================================================"

cat << 'EOF' > segment_10_caching_performance.py
"""
[WHAT]: HTTP caching headers, Redis, cache strategies, compression, serialization
[WHY]: Caching is the #1 performance optimization. Reduces database load 100x.
"""

from fastapi import FastAPI, Response
from fastapi.responses import ORJSONResponse
import hashlib
import json
from datetime import datetime, timedelta

app = FastAPI()

# ========== BASIC USAGE: HTTP Caching Headers ==========

# [COMPONENT MEANING] Cache-Control = Browser/CDN caching directive
# [ARGUMENT MEANING] max-age=3600 = Cache for 1 hour
# [ARGUMENT MEANING] public = Proxy can cache; private = browser only
@app.get("/public-data", response_class=ORJSONResponse)
async def public_data():
    """[WHAT]: Static data cached aggressively."""
    return Response(
        content=json.dumps({"data": "static"}),
        media_type="application/json",
        headers={
            "Cache-Control": "public, max-age=3600",  # Cache 1 hour
            "ETag": f'"{hashlib.md5(b"static").hexdigest()}"'
        }
    )

# [COMPONENT MEANING] ETag = Hash of response content
# [COMPONENT MEANING] If-None-Match = Client sends ETag; server returns 304 if unchanged
@app.get("/with-etag")
async def with_etag(request: Request):
    """[HOW]: Client caches ETag; on next request, server skips response body if unchanged."""
    from starlette.requests import Request
    
    response_data = {"timestamp": "2024-01-01T00:00:00Z"}
    etag = hashlib.md5(json.dumps(response_data).encode()).hexdigest()
    
    # Client sends If-None-Match header with cached ETag
    if request.headers.get("If-None-Match") == f'"{etag}"':
        return Response(status_code=304)  # Not Modified; use cached response
    
    return Response(
        content=json.dumps(response_data),
        media_type="application/json",
        headers={"ETag": f'"{etag}"'}
    )

# ========== POWER USAGE: Redis Caching ==========

# Simulated Redis client
class MockRedis:
    def __init__(self):
        self.store = {}
    
    async def get(self, key: str):
        return self.store.get(key)
    
    async def set(self, key: str, value: str, ex: int = None):
        self.store[key] = value
    
    async def delete(self, key: str):
        self.store.pop(key, None)

redis = MockRedis()

# [COMPONENT MEANING] aioredis = Async Redis client
# [ARGUMENT MEANING] set(key, value, ex=60) = Cache with 60s TTL
@app.get("/cached-user/{user_id}")
async def cached_user(user_id: int):
    """[WHY]: Redis cache prevents repeated database queries."""
    cache_key = f"user:{user_id}"
    
    # Try cache first
    cached = await redis.get(cache_key)
    if cached:
        return json.loads(cached)
    
    # Cache miss; fetch from DB
    user_data = {"id": user_id, "name": f"User {user_id}"}
    
    # Store in cache for 5 minutes
    # [HOW]: Set TTL to balance freshness vs load
    await redis.set(cache_key, json.dumps(user_data), ex=300)
    
    return user_data

# ========== PRECISION USAGE: Cache Invalidation & Stampede ==========

# [WATCH OUT]: Cache stampede = Multiple requests on expired key cause thundering herd
# Solution: probabilistic early expiration or locking

@app.get("/cache-with-lock/{item_id}")
async def cache_with_lock(item_id: int):
    """[HOW]: Probabilistic expiration prevents stampede."""
    cache_key = f"item:{item_id}"
    lock_key = f"item:{item_id}:lock"
    
    cached = await redis.get(cache_key)
    if cached:
        return json.loads(cached)
    
    # Try to acquire lock (only one worker refreshes)
    # [WHAT]: Lock prevents multiple workers from simultaneously fetching DB
    lock_acquired = False  # In real code: use Redis SET NX
    
    if lock_acquired:
        # This worker refreshes cache
        item_data = {"id": item_id, "data": "fresh"}
        await redis.set(cache_key, json.dumps(item_data), ex=300)
        # Release lock
    else:
        # Other worker is refreshing; wait a bit
        import time
        time.sleep(0.1)
        return await cached_user(item_id)
    
    return item_data

# ========== ENTERPRISE CONTEXT: Compression & ORJson ==========

# [COMPONENT MEANING] ORJSONResponse = 2-3x faster serialization
# [ARGUMENT MEANING] Uses orjson library (Rust-based JSON)
@app.get("/fast-response", response_class=ORJSONResponse)
async def fast_response():
    """[WHY]: orjson is faster for large JSON payloads."""
    return {
        "items": [{"id": i, "data": f"item_{i}"} for i in range(1000)]
    }

# [COMPONENT MEANING] GZipMiddleware = Compress response body
# Responses > 1000 bytes automatically gzipped for clients that accept it
from fastapi.middleware.gzip import GZipMiddleware
app.add_middleware(GZipMiddleware, minimum_size=1000)

# ========== Cache Key Strategies ==========

def build_cache_key(endpoint: str, user_id: int, filters: dict) -> str:
    """[WHAT]: Construct deterministic cache keys."""
    # Sort filters for consistent key
    filters_str = json.dumps(filters, sort_keys=True)
    return f"{endpoint}:user:{user_id}:{hashlib.md5(filters_str.encode()).hexdigest()}"

@app.get("/filtered-items/{user_id}")
async def filtered_items(user_id: int, category: str = "all", limit: int = 10):
    """[HOW]: Cache key incorporates all query parameters."""
    cache_key = build_cache_key("items", user_id, {"category": category, "limit": limit})
    
    # Check cache
    cached = await redis.get(cache_key)
    if cached:
        return json.loads(cached)
    
    # Fetch and cache
    items = [{"id": i, "category": category} for i in range(limit)]
    await redis.set(cache_key, json.dumps(items), ex=600)
    
    return items

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 10: Caching & Performance (segment_10_caching_performance.py)"

# Continue with final segments (11-20)

echo ""
echo "============================================================================"
echo "SEGMENT 11: Structured Logging & Distributed Tracing"
echo "============================================================================"

cat << 'EOF' > segment_11_logging_tracing.py
"""
[WHAT]: JSON logging, correlation IDs, OpenTelemetry, trace context propagation
[WHY]: Production visibility. Trace requests across microservices. Debug distributed systems.
"""

from fastapi import FastAPI, Request
import logging
import json
from pythonjsonlogger import jsonlogger
from datetime import datetime
import uuid

app = FastAPI()

# ========== BASIC USAGE: Structured JSON Logging ==========

# [COMPONENT MEANING] pythonjsonlogger = Log records as JSON objects
# [ARGUMENT MEANING] Enables log aggregation and parsing by tools like ELK

logger = logging.getLogger("fastapi")
logger.setLevel(logging.INFO)

handler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
handler.setFormatter(formatter)
logger.addHandler(handler)

@app.get("/basic-logging")
async def basic_logging():
    """[HOW]: Logs emitted as JSON for ingestion into logging platforms."""
    logger.info("User accessed endpoint", extra={"user_id": 123, "action": "login"})
    return {"status": "ok"}

# ========== POWER USAGE: Correlation ID Middleware ==========

# [COMPONENT MEANING] Correlation ID = Unique ID tracking request through system
# [ARGUMENT MEANING] X-Request-ID header = Standard header for correlation ID
@app.middleware("http")
async def correlation_id_middleware(request: Request, call_next):
    """[WHAT]: Inject correlation ID into every request."""
    correlation_id = request.headers.get("X-Request-ID", str(uuid.uuid4()))
    
    # Store in request state for access in endpoints
    request.state.correlation_id = correlation_id
    
    response = await call_next(request)
    response.headers["X-Request-ID"] = correlation_id
    
    logger.info(
        "Request completed",
        extra={
            "correlation_id": correlation_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code
        }
    )
    
    return response

@app.get("/traced-endpoint")
async def traced_endpoint(request: Request):
    """[HOW]: Endpoint can access correlation ID for local logging."""
    correlation_id = request.state.correlation_id
    
    logger.info(
        "Processing request",
        extra={
            "correlation_id": correlation_id,
            "business_event": "user_action"
        }
    )
    
    return {"correlation_id": correlation_id}

# ========== PRECISION USAGE: OpenTelemetry Integration ==========

# [COMPONENT MEANING] OpenTelemetry = Observability framework for distributed tracing
# [COMPONENT MEANING] Span = Unit of work (single operation) in a trace

tracing_example = """
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.exporter.jaeger.thrift import JaegerExporter

# Configure tracing backend (Jaeger, Datadog, etc.)
jaeger_exporter = JaegerExporter(agent_host_name="localhost", agent_port=6831)
trace.set_tracer_provider(TracerProvider())
trace.get_tracer_provider().add_span_processor(...)

tracer = trace.get_tracer(__name__)

@app.get("/traced")
async def traced_operation():
    # [HOW]: Create named span for this operation
    with tracer.start_as_current_span("get_traced") as span:
        # Add metadata to span
        span.set_attribute("user_id", 123)
        span.set_attribute("operation", "fetch_data")
        
        # Nested span for sub-operation
        with tracer.start_as_current_span("database_query"):
            result = await fetch_from_db()
        
        span.set_status(trace.Status(trace.StatusCode.OK))
        return result
"""

# ========== ENTERPRISE CONTEXT: W3C Trace Context ==========

# [COMPONENT MEANING] W3C Trace Context = Standard for trace ID propagation
# [ARGUMENT MEANING] traceparent header = Format: "00-trace_id-span_id-flags"

@app.middleware("http")
async def trace_context_propagation(request: Request, call_next):
    """[WHAT]: Extract and propagate W3C trace context across services."""
    traceparent = request.headers.get("traceparent", f"00-{uuid.uuid4().hex}-{uuid.uuid4().hex[:16]}-01")
    
    response = await call_next(request)
    
    # Propagate to downstream services
    response.headers["traceparent"] = traceparent
    
    logger.info(
        "Trace context propagated",
        extra={"traceparent": traceparent}
    )
    
    return response

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 11: Logging & Tracing (segment_11_logging_tracing.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 12: Metrics Collection & Health Checks"
echo "============================================================================"

cat << 'EOF' > segment_12_metrics_health.py
"""
[WHAT]: Prometheus metrics, health checks, SLIs/SLOs, APM integration
[WHY]: Visibility into system behavior. Alerting on anomalies. Data-driven decisions.
"""

from fastapi import FastAPI
from prometheus_client import Counter, Gauge, Histogram, generate_latest, REGISTRY
import asyncio
from datetime import datetime

app = FastAPI()

# ========== BASIC USAGE: Prometheus Metrics ==========

# [COMPONENT MEANING] Counter = Monotonically increasing metric (requests, errors)
# [ARGUMENT MEANING] labels=["method", "status"] = Dimensions for analysis
http_requests_total = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "status"]
)

# [COMPONENT MEANING] Gauge = Can increase/decrease (active connections, CPU)
active_connections = Gauge(
    "active_connections",
    "Current active connections"
)

# [COMPONENT MEANING] Histogram = Distribution of values (latency, size)
request_latency_seconds = Histogram(
    "request_latency_seconds",
    "Request latency in seconds",
    buckets=[0.01, 0.05, 0.1, 0.5, 1.0]
)

@app.middleware("http")
async def metrics_middleware(request, call_next):
    """[HOW]: Collect metrics for every request."""
    active_connections.inc()
    
    start_time = datetime.utcnow()
    
    response = await call_next(request)
    
    duration = (datetime.utcnow() - start_time).total_seconds()
    
    # Record metrics
    http_requests_total.labels(method=request.method, status=response.status_code).inc()
    request_latency_seconds.observe(duration)
    active_connections.dec()
    
    return response

# [COMPONENT MEANING] /metrics endpoint = Prometheus scrapes this for metrics
@app.get("/metrics")
async def metrics():
    """[WHAT]: Expose metrics in Prometheus format."""
    return generate_latest(REGISTRY)

# ========== POWER USAGE: Health Check Endpoints ==========

# [COMPONENT MEANING] /health/live = Kubernetes liveness probe
# [ARGUMENT MEANING] Return 200 if process alive; 503 if should restart

@app.get("/health/live", status_code=200)
async def liveness_probe():
    """[HOW]: Indicates if application is running (basic health)."""
    return {"status": "alive"}

# [COMPONENT MEANING] /health/ready = Kubernetes readiness probe
# [ARGUMENT MEANING] Return 200 if ready to accept traffic; 503 if initializing/degraded

db_ready = True  # Simulated DB connection flag

@app.get("/health/ready", status_code=200)
async def readiness_probe():
    """[WHAT]: Indicates if application can handle traffic."""
    if not db_ready:
        return {"status": "not_ready", "reason": "Database unavailable"}, 503
    
    return {"status": "ready"}

# [COMPONENT MEANING] /health/startup = Kubernetes startup probe
# [ARGUMENT MEANING] Return 200 once initialization complete; 503 if still initializing

startup_complete = False

@app.on_event("startup")
async def startup():
    global startup_complete
    await asyncio.sleep(1)  # Simulate initialization
    startup_complete = True

@app.get("/health/startup", status_code=200)
async def startup_probe():
    """[HOW]: Signals when app initialization finished."""
    if not startup_complete:
        return {"status": "initializing"}, 503
    
    return {"status": "started"}

# ========== PRECISION USAGE: Custom Business Metrics ==========

# [COMPONENT MEANING] Custom metrics = Domain-specific KPIs
# [WATCH OUT]: High cardinality labels cause storage explosion

users_created_total = Counter(
    "users_created_total",
    "Total users created",
    ["signup_source"]  # Low cardinality: web, mobile, api
)

payment_amount_total = Gauge(
    "payment_amount_dollars",
    "Total payment revenue",
    ["currency"]  # Cardinality: USD, EUR, GBP (fixed set)
)

@app.post("/user")
async def create_user(source: str):
    """[HOW]: Emit custom business metrics."""
    if source not in ["web", "mobile", "api"]:
        source = "unknown"
    
    users_created_total.labels(signup_source=source).inc()
    
    return {"status": "created"}

# ========== ENTERPRISE CONTEXT: SLI/SLO Definition ==========

slo_definition = """
SLI/SLO Examples:

SLI (Service Level Indicator) = Measurable metric
- API Latency: p99 response time < 500ms
- Error Rate: < 0.1% of requests return 5xx
- Availability: 99.9% of requests successful

SLO (Service Level Objective) = Target for SLI
- "99.9% of requests complete in < 500ms"
- "99.95% uptime per month (22 seconds downtime allowed)"
- "Error budget: 0.1% of requests can fail"

Implementation:
- Monitor p50, p95, p99 latencies
- Track error count by status code
- Alert when approaching error budget limit
"""

# Calculate SLI: successful requests
successful_requests = Counter(
    "requests_successful",
    "Successful requests (2xx/3xx)"
)

# Calculate availability
available_seconds = Gauge(
    "service_available_seconds_total",
    "Total seconds service was available"
)

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 12: Metrics & Health (segment_12_metrics_health.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 13: Middleware Architecture & Request Processing"
echo "============================================================================"

cat << 'EOF' > segment_13_middleware.py
"""
[WHAT]: BaseHTTPMiddleware, middleware order, request/response modification, exception handling
[WHY]: Middleware applies cross-cutting concerns. Proper order prevents bugs.
"""

from fastapi import FastAPI, HTTPException, Request
from starlette.middleware.base import BaseHTTPMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
import time
import logging

app = FastAPI()
logger = logging.getLogger(__name__)

# ========== BASIC USAGE: Decorator-Style Middleware ==========

# [COMPONENT MEANING] @app.middleware("http") = Simpler, functional middleware
# [ARGUMENT MEANING] call_next() = Invoke next middleware or route handler

@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """[HOW]: Middleware wraps request/response processing."""
    start_time = time.time()
    
    response = await call_next(request)
    
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    
    return response

# ========== POWER USAGE: Class-Based Middleware ==========

# [COMPONENT MEANING] BaseHTTPMiddleware = Subclass for complex middleware
# [ARGUMENT MEANING] dispatch() method = Override to implement logic

class LoggingMiddleware(BaseHTTPMiddleware):
    """[WHAT]: Detailed request/response logging for debugging."""
    
    async def dispatch(self, request: Request, call_next):
        """[HOW]: dispatch() receives request before route, response after."""
        # Log incoming request
        logger.info(
            "Incoming request",
            extra={
                "method": request.method,
                "path": request.url.path,
                "client": request.client.host if request.client else "unknown"
            }
        )
        
        response = await call_next(request)
        
        # Log outgoing response
        logger.info(
            "Response sent",
            extra={
                "status": response.status_code,
                "path": request.url.path
            }
        )
        
        return response

app.add_middleware(LoggingMiddleware)

# ========== PRECISION USAGE: Request State & Context ==========

class RequestIDMiddleware(BaseHTTPMiddleware):
    """[WHAT]: Inject unique ID into request for tracking."""
    
    async def dispatch(self, request: Request, call_next):
        """[HOW]: Store arbitrary data in request.state."""
        import uuid
        
        request.state.request_id = str(uuid.uuid4())
        
        response = await call_next(request)
        response.headers["X-Request-ID"] = request.state.request_id
        
        return response

app.add_middleware(RequestIDMiddleware)

@app.get("/with-request-id")
async def with_request_id(request: Request):
    """[WATCH OUT]: Can access request.state set by middleware."""
    return {"request_id": request.state.request_id}

# ========== ENTERPRISE CONTEXT: Custom Exception Handling ==========

class CustomException(Exception):
    """[COMPONENT MEANING] Custom exception for domain logic."""
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail

# [COMPONENT MEANING] @app.exception_handler() = Register handler for exception type
@app.exception_handler(CustomException)
async def custom_exception_handler(request: Request, exc: CustomException):
    """[HOW]: FastAPI catches exception; handler formats response."""
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail, "type": "custom_error"}
    )

@app.get("/custom-error")
async def trigger_custom_error():
    """[WHAT]: Raise custom exception; handler formats as JSON."""
    raise CustomException(status_code=400, detail="Custom validation failed")

# [COMPONENT MEANING] RequestValidationError handler = Customize Pydantic error format
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """[HOW]: Reformat Pydantic errors for cleaner API responses."""
    errors = [
        {
            "field": err["loc"][-1],
            "message": err["msg"],
            "type": err["type"]
        }
        for err in exc.errors()
    ]
    
    return JSONResponse(
        status_code=422,
        content={"detail": "Validation failed", "errors": errors}
    )

# ========== Middleware Execution Order ==========

# [WATCH OUT]: Middleware executes in REVERSE order of addition!
# Add in this order: A -> B -> C
# Request flows: A -> B -> C -> route -> C -> B -> A

class MiddlewareA(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        print("A: before")
        response = await call_next(request)
        print("A: after")
        return response

class MiddlewareB(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        print("B: before")
        response = await call_next(request)
        print("B: after")
        return response

app.add_middleware(MiddlewareA)
app.add_middleware(MiddlewareB)
# Execution: B:before -> A:before -> route -> A:after -> B:after

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 13: Middleware (segment_13_middleware.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 14: Error Handling & Resilience Patterns"
echo "============================================================================"

cat << 'EOF' > segment_14_error_resilience.py
"""
[WHAT]: HTTPException, retry logic, circuit breaker, timeouts, fallback patterns
[WHY]: Production systems fail. Resilience prevents cascading failures.
"""

from fastapi import FastAPI, HTTPException
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
from datetime import datetime, timedelta
import asyncio

app = FastAPI()

# ========== BASIC USAGE: HTTPException ==========

# [COMPONENT MEANING] HTTPException = FastAPI exception for HTTP errors
# [ARGUMENT MEANING] status_code = HTTP status; detail = Error message

@app.get("/user/{user_id}")
async def get_user(user_id: int):
    """[HOW]: Raise HTTPException; FastAPI converts to HTTP response."""
    if user_id < 0:
        raise HTTPException(
            status_code=400,
            detail="User ID must be positive",
            headers={"X-Error": "invalid_id"}
        )
    
    user = {"id": user_id, "name": f"User {user_id}"}
    
    if user_id > 1000000:
        raise HTTPException(
            status_code=404,
            detail=f"User {user_id} not found"
        )
    
    return user

# ========== POWER USAGE: Retry Logic ==========

# [COMPONENT MEANING] @retry() = Decorator adding automatic retry behavior
# [ARGUMENT MEANING] stop=stop_after_attempt(3) = Max 3 attempts
# [ARGUMENT MEANING] wait=wait_exponential() = Exponential backoff: 1s, 2s, 4s, 8s...

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=1, max=10),
    retry=retry_if_exception_type(ConnectionError)
)
async def call_external_api(endpoint: str):
    """[WHAT]: Automatically retry transient failures."""
    # Simulate flaky API
    import random
    if random.random() < 0.7:
        raise ConnectionError("API temporarily unavailable")
    
    return {"status": "success"}

@app.get("/resilient/{endpoint}")
async def resilient_call(endpoint: str):
    """[HOW]: Retry decorator handles transient failures transparently."""
    try:
        result = await call_external_api(endpoint)
        return result
    except ConnectionError:
        raise HTTPException(status_code=503, detail="API unavailable after retries")

# ========== PRECISION USAGE: Circuit Breaker Pattern ==========

# [COMPONENT MEANING] Circuit Breaker = Prevent requests to failing service
# States: Closed (working) -> Open (failing) -> Half-Open (testing recovery)

class CircuitBreaker:
    """[WHY]: Circuit breaker stops hammering failing service, allows recovery."""
    
    def __init__(self, failure_threshold: int = 5, recovery_timeout: int = 60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.last_failure_time = None
        self.state = "closed"  # closed, open, half-open
    
    async def call(self, func, *args, **kwargs):
        """[HOW]: Wrap function call with circuit breaker logic."""
        if self.state == "open":
            # Check if recovery timeout elapsed
            if datetime.utcnow() - self.last_failure_time > timedelta(seconds=self.recovery_timeout):
                self.state = "half-open"
            else:
                raise Exception("Circuit breaker is open")
        
        try:
            result = await func(*args, **kwargs)
            
            # Success; reset
            if self.state == "half-open":
                self.state = "closed"
                self.failure_count = 0
            
            return result
        
        except Exception as e:
            self.failure_count += 1
            self.last_failure_time = datetime.utcnow()
            
            if self.failure_count >= self.failure_threshold:
                self.state = "open"
            
            raise

breaker = CircuitBreaker(failure_threshold=3)

async def flaky_service():
    """[WATCH OUT]: Service fails intermittently."""
    import random
    if random.random() < 0.8:
        raise ConnectionError("Service error")
    return {"data": "ok"}

@app.get("/circuit-breaker")
async def circuit_breaker_example():
    """[WHAT]: Circuit breaker prevents cascade of failures."""
    try:
        result = await breaker.call(flaky_service)
        return result
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {breaker.state}")

# ========== ENTERPRISE CONTEXT: Timeout & Fallback ==========

# [COMPONENT MEANING] asyncio.wait_for() = Enforce timeout on async operation
# [COMPONENT MEANING] [WATCH OUT]: TimeoutError if timeout exceeded

async def slow_database_query():
    """[WHAT]: Potentially slow operation."""
    await asyncio.sleep(10)
    return {"data": "result"}

@app.get("/with-timeout")
async def with_timeout():
    """[HOW]: wait_for() raises TimeoutError if operation exceeds timeout."""
    try:
        result = await asyncio.wait_for(slow_database_query(), timeout=2.0)
        return result
    except asyncio.TimeoutError:
        # Fallback: return cached/degraded response
        return {"data": "cached_result", "stale": True}, 200

# [COMPONENT MEANING] Feature flag = Conditionally enable features
features_enabled = {"new_api": False, "beta_feature": True}

@app.get("/feature-flag/{feature_name}")
async def check_feature(feature_name: str):
    """[WHAT]: Enable/disable features at runtime without deployment."""
    if not features_enabled.get(feature_name, False):
        raise HTTPException(status_code=404, detail="Feature not available")
    
    return {"feature": feature_name, "enabled": True}

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 14: Error Handling (segment_14_error_resilience.py)"

# Segments 15-20

echo ""
echo "============================================================================"
echo "SEGMENT 15: Testing Strategy (Unit, Integration, E2E)"
echo "============================================================================"

cat << 'EOF' > segment_15_testing.py
"""
[WHAT]: pytest, TestClient, fixtures, dependency overrides, async testing, load testing
[WHY]: Automated testing prevents regressions. TestClient enables fast integration tests.
"""

import pytest
from fastapi import FastAPI, Depends
from fastapi.testclient import TestClient
from httpx import AsyncClient

app = FastAPI()

# ========== BASIC USAGE: TestClient ==========

@app.get("/hello")
async def hello(name: str = "World"):
    """Simple endpoint for testing."""
    return {"message": f"Hello, {name}!"}

@app.get("/users/{user_id}")
async def get_user(user_id: int):
    """Simulate user fetch."""
    if user_id < 1:
        return {"error": "Invalid ID"}, 400
    return {"id": user_id, "name": f"User {user_id}"}

# [COMPONENT MEANING] TestClient = Make HTTP requests without running server
# [ARGUMENT MEANING] Can be used in pytest fixtures or directly

def test_hello_endpoint():
    """[HOW]: TestClient mimics HTTP requests for testing."""
    client = TestClient(app)
    response = client.get("/hello")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, World!"}

def test_hello_with_param():
    """[WHAT]: Test with query parameters."""
    client = TestClient(app)
    response = client.get("/hello?name=Alice")
    assert response.json() == {"message": "Hello, Alice!"}

# ========== POWER USAGE: Fixtures & Dependency Overrides ==========

# Simulated dependencies
async def get_db():
    """[WATCH OUT]: In real code, returns database connection."""
    return {"connection": "real_db"}

async def get_current_user():
    """[WHAT]: Dependency that validates authentication."""
    return {"id": 1, "username": "john"}

@app.get("/profile")
async def get_profile(user = Depends(get_current_user)):
    """Protected endpoint requiring authentication."""
    return {"user": user}

# Test fixtures
@pytest.fixture
def client():
    """[HOW]: Pytest fixture provides TestClient for all tests."""
    return TestClient(app)

@pytest.fixture
def mock_user():
    """[WHAT]: Mock user data for testing."""
    return {"id": 999, "username": "testuser"}

def test_profile_without_override(client):
    """[WATCH OUT]: Without override, uses real get_current_user()."""
    response = client.get("/profile")
    # Would fail in real app if user not authenticated

def test_profile_with_override(client, mock_user):
    """[HOW]: Override dependency for testing."""
    # [COMPONENT MEANING] app.dependency_overrides = Replace dependency with mock
    app.dependency_overrides[get_current_user] = lambda: mock_user
    
    response = client.get("/profile")
    assert response.status_code == 200
    assert response.json() == {"user": mock_user}
    
    # Clean up
    app.dependency_overrides.clear()

# ========== PRECISION USAGE: Async Testing ==========

# [COMPONENT MEANING] @pytest.mark.asyncio = Mark test as async
# [ARGUMENT MEANING] Allows using await in test functions

@pytest.mark.asyncio
async def test_async_endpoint():
    """[HOW]: Test async endpoints with async client."""
    # [COMPONENT MEANING] AsyncClient = Async HTTP client for testing
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/hello?name=Bob")
        assert response.status_code == 200

# ========== ENTERPRISE CONTEXT: Database Fixtures ==========

# Simulated database
class MockDatabase:
    def __init__(self):
        self.users = {}
    
    async def create_user(self, name: str):
        user_id = len(self.users) + 1
        self.users[user_id] = {"id": user_id, "name": name}
        return self.users[user_id]
    
    async def get_user(self, user_id: int):
        return self.users.get(user_id)

@pytest.fixture
def mock_db():
    """[WHAT]: Fresh database for each test; isolated state."""
    db = MockDatabase()
    yield db
    # Cleanup after test

@pytest.mark.asyncio
async def test_create_user(mock_db):
    """[HOW]: Use fixture to test database operations."""
    user = await mock_db.create_user("Alice")
    assert user["name"] == "Alice"
    assert await mock_db.get_user(user["id"]) == user

# ========== Load Testing Patterns ==========

load_testing_example = """
# Using Locust for load testing

from locust import HttpUser, task, between

class APIUser(HttpUser):
    wait_time = between(1, 3)  # Wait 1-3 seconds between requests
    
    @task(3)  # Weight: 3 times more frequent than others
    def get_hello(self):
        # [WHAT]: Simulate real user behavior
        self.client.get("/hello?name=User")
    
    @task(1)
    def get_user(self):
        user_id = random.randint(1, 100)
        self.client.get(f"/users/{user_id}")

# Run: locust -f locustfile.py --host=http://localhost:8000
"""

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 15: Testing (segment_15_testing.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 16: Docker Containerization & Kubernetes Deployment"
echo "============================================================================"

cat << 'EOF' > segment_16_docker_k8s.sh
#!/bin/bash

# [COMPONENT MEANING] Dockerfile = Build specification for container image

cat > Dockerfile << 'DOCKER_EOF'
# Multi-stage build for minimal image size

# Stage 1: Builder
FROM python:3.11-slim as builder

WORKDIR /build
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime (much smaller)
FROM python:3.11-slim

# [ARGUMENT MEANING] WORKDIR = Set working directory in container
WORKDIR /app

# Copy venv from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application code
COPY . .

# [COMPONENT MEANING] EXPOSE = Document which port container listens on
EXPOSE 8000

# [COMPONENT MEANING] CMD = Default command when container starts
# [ARGUMENT MEANING] uvicorn main:app = Run FastAPI app with Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
DOCKER_EOF

# ========== Kubernetes Manifests ==========

# [COMPONENT MEANING] Deployment = Kubernetes resource managing pod replicas
cat > deployment.yaml << 'K8S_EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app
  labels:
    app: fastapi
spec:
  # [ARGUMENT MEANING] replicas = Number of pod instances
  replicas: 3
  
  selector:
    matchLabels:
      app: fastapi
  
  template:
    metadata:
      labels:
        app: fastapi
    
    spec:
      containers:
      - name: fastapi
        image: myregistry.azurecr.io/fastapi:latest
        
        # [COMPONENT MEANING] resources.requests = Guaranteed minimum
        # [COMPONENT MEANING] resources.limits = Maximum allowed
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        # [COMPONENT MEANING] livenessProbe = Check if container alive; restart if failed
        livenessProbe:
          httpGet:
            path: /health/live
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 10
          failureThreshold: 3
        
        # [COMPONENT MEANING] readinessProbe = Check if ready for traffic
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        
        # [COMPONENT MEANING] startupProbe = Check if initialization complete
        startupProbe:
          httpGet:
            path: /health/startup
            port: 8000
          failureThreshold: 30
          periodSeconds: 10
---

apiVersion: v1
kind: Service
metadata:
  name: fastapi-service
spec:
  selector:
    app: fastapi
  
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  
  type: LoadBalancer
---

# [COMPONENT MEANING] HorizontalPodAutoscaler = Auto-scale based on metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: fastapi-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: fastapi-app
  
  minReplicas: 2
  maxReplicas: 10
  
  # [ARGUMENT MEANING] targetCPUUtilizationPercentage = Scale when CPU > 70%
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
K8S_EOF

echo "[SEGMENT 16] Dockerfile and Kubernetes manifests generated"
EOF

chmod +x segment_16_docker_k8s.sh
bash segment_16_docker_k8s.sh

echo "✓ Segment 16: Docker & Kubernetes (segment_16_docker_k8s.sh)"

echo ""
echo "============================================================================"
echo "SEGMENT 17: API Versioning & Backward Compatibility"
echo "============================================================================"

cat << 'EOF' > segment_17_api_versioning.py
"""
[WHAT]: URL versioning, semantic versioning, deprecation headers, breaking changes
[WHY]: APIs evolve. Versioning prevents breaking existing clients.
"""

from fastapi import FastAPI, APIRouter, HTTPException, Header
from typing import Optional
from enum import Enum

app = FastAPI()

# ========== BASIC USAGE: URL Path Versioning ==========

# [COMPONENT MEANING] APIRouter(prefix="/v1") = Version prefix for all routes
v1_router = APIRouter(prefix="/v1", tags=["v1"])

@v1_router.get("/users/{user_id}")
async def get_user_v1(user_id: int):
    """[WHAT]: V1 API returns minimal user data."""
    return {"id": user_id, "name": f"User {user_id}"}

# [COMPONENT MEANING] V2 with more fields
v2_router = APIRouter(prefix="/v2", tags=["v2"])

@v2_router.get("/users/{user_id}")
async def get_user_v2(user_id: int):
    """[HOW]: V2 adds new fields (backward compatible additive change)."""
    return {
        "id": user_id,
        "name": f"User {user_id}",
        "email": f"user{user_id}@example.com",  # New field
        "created_at": "2024-01-01T00:00:00Z"     # New field
    }

app.include_router(v1_router)
app.include_router(v2_router)

# ========== POWER USAGE: Deprecation Headers ==========

# [COMPONENT MEANING] Deprecated header = Inform clients endpoint is deprecated
# [COMPONENT MEANING] Sunset header = When endpoint will be removed

from datetime import datetime, timedelta

@v1_router.get("/users", deprecated=True)
async def list_users_v1():
    """[WATCH OUT]: Marked deprecated in Swagger UI."""
    # In production: set headers
    headers = {
        "Deprecation": "true",
        "Sunset": (datetime.utcnow() + timedelta(days=90)).isoformat(),
        "Link": '<http://localhost:8000/v2/users>; rel="successor-version"'
    }
    
    return {"users": [], "headers": headers}

# ========== PRECISION USAGE: Breaking Change Strategies ==========

# Strategy 1: Optional new fields (non-breaking)
class UserV1(BaseModel):
    id: int
    name: str

class UserV2(BaseModel):
    id: int
    name: str
    email: Optional[str] = None  # New field; optional for compatibility

# Strategy 2: Rename field with alias (non-breaking)
from pydantic import BaseModel, Field

class UserV3(BaseModel):
    id: int
    name: str
    email_address: str = Field(alias="email")  # Old name as alias

# Strategy 3: Union types (support both old and new)
from typing import Union

OldUser = dict
NewUser = dict

@app.post("/v2/users")
async def create_user(data: Union[OldUser, NewUser]):
    """[HOW]: Accept both old and new formats."""
    # Detect format and process accordingly
    return {"created": True}

# ========== ENTERPRISE CONTEXT: Versioning Strategy ==========

class APIVersion(str, Enum):
    V1 = "v1"
    V2 = "v2"

@app.get("/versions")
async def list_versions():
    """[WHAT]: Document API versions and deprecation timelines."""
    return {
        "v1": {
            "status": "deprecated",
            "sunset_date": "2024-12-31",
            "reason": "Use v2 for new features"
        },
        "v2": {
            "status": "current",
            "deprecation_date": None
        },
        "v3": {
            "status": "beta",
            "deprecation_date": None
        }
    }

# [WATCH OUT]: Avoid ambiguous routing
# ❌ BAD: /users (matches both /v1/users and /v2/users if not careful)
# ✓ GOOD: /v1/users and /v2/users clearly separated

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 17: API Versioning (segment_17_api_versioning.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 18: Service-to-Service Communication & Resilience"
echo "============================================================================"

cat << 'EOF' > segment_18_service_communication.py
"""
[WHAT]: httpx async client, circuit breaker, service discovery, message queues, gRPC
[WHY]: Microservices require reliable inter-service communication.
"""

from fastapi import FastAPI
import httpx
from typing import Optional
import asyncio

app = FastAPI()

# ========== BASIC USAGE: Async HTTP Client ==========

# [COMPONENT MEANING] httpx.AsyncClient = Async HTTP client with connection pooling
# [ARGUMENT MEANING] timeout = Timeout for all requests

async def call_external_service(url: str) -> dict:
    """[HOW]: Make non-blocking HTTP request to external service."""
    async with httpx.AsyncClient(timeout=5.0) as client:
        # [WATCH OUT]: timeout prevents hanging on slow/dead services
        response = await client.get(url)
        response.raise_for_status()  # Raise on 4xx/5xx
        return response.json()

@app.get("/external-data/{service_id}")
async def get_external_data(service_id: int):
    """[WHAT]: Call external service and return data."""
    try:
        data = await call_external_service(f"https://api.example.com/service/{service_id}")
        return data
    except httpx.TimeoutException:
        return {"error": "Service timeout"}, 504
    except httpx.HTTPError as e:
        return {"error": str(e)}, 502

# ========== POWER USAGE: Connection Pooling & Limits ==========

# [COMPONENT MEANING] limits = Control connection pool behavior
# [ARGUMENT MEANING] max_connections = Max total connections
# [ARGUMENT MEANING] max_keepalive_connections = Reusable connections

client = httpx.AsyncClient(
    timeout=10.0,
    limits=httpx.Limits(max_connections=10, max_keepalive_connections=5),
    http2=True  # Enable HTTP/2 for multiplexing
)

@app.on_event("shutdown")
async def shutdown_event():
    """[HOW]: Close client to return connections to pool."""
    await client.aclose()

# ========== PRECISION USAGE: Retry + Circuit Breaker ==========

from tenacity import retry, stop_after_attempt, wait_exponential

# [COMPONENT MEANING] Circuit breaker wrapper
class ResilientServiceClient:
    """[WHY]: Prevent cascading failures across services."""
    
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.failure_count = 0
        self.is_open = False
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10)
    )
    async def get(self, path: str):
        """[HOW]: Retry transient failures; circuit breaker prevents cascade."""
        if self.is_open:
            raise Exception("Circuit breaker open")
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(f"{self.base_url}{path}", timeout=5.0)
                response.raise_for_status()
                self.failure_count = 0  # Reset on success
                return response.json()
        except Exception as e:
            self.failure_count += 1
            if self.failure_count >= 5:
                self.is_open = True
                asyncio.create_task(self._reset_after_delay())
            raise
    
    async def _reset_after_delay(self):
        """[WATCH OUT]: Allow recovery time before retrying."""
        await asyncio.sleep(60)  # Wait 1 minute
        self.is_open = False
        self.failure_count = 0

user_service = ResilientServiceClient("https://user-service.internal")

@app.get("/user/{user_id}")
async def get_user(user_id: int):
    """[WHAT]: Call user service with automatic retry + circuit breaker."""
    try:
        user = await user_service.get(f"/users/{user_id}")
        return user
    except Exception as e:
        return {"error": "User service unavailable"}, 503

# ========== ENTERPRISE CONTEXT: Message Queues & Event Streaming ==========

# [COMPONENT MEANING] Message queue = Async communication between services
# Examples: RabbitMQ, Kafka

message_queue_example = """
# RabbitMQ with aio-pika

from aio_pika import connect, IncomingMessage

async def publish_event(event: dict):
    # Connect to RabbitMQ
    connection = await connect("amqp://guest:guest@localhost/")
    channel = await connection.channel()
    
    # [COMPONENT MEANING] Exchange = Routing broker for messages
    exchange = await channel.get_exchange("events")
    
    # Publish message
    await exchange.publish(message=aio_pika.Message(
        body=json.dumps(event).encode()
    ), routing_key="user.created")

async def consume_events():
    # [COMPONENT MEANING] Queue = Buffer for messages
    connection = await connect("amqp://guest:guest@localhost/")
    channel = await connection.channel()
    queue = await channel.get_queue("user-events")
    
    # [HOW]: Subscribe to messages
    async with queue.iterator() as queue_iter:
        async for message: IncomingMessage in queue_iter:
            with message.process():
                event = json.loads(message.body)
                # Handle event
"""

# ========== gRPC for High-Performance Communication ==========

grpc_example = """
# Protocol Buffers definition (user.proto)
syntax = "proto3";

service UserService {
  rpc GetUser (GetUserRequest) returns (UserResponse);
  rpc ListUsers (ListUsersRequest) returns (stream UserResponse);
}

message GetUserRequest {
  int32 user_id = 1;
}

message UserResponse {
  int32 id = 1;
  string name = 2;
  string email = 3;
}

# FastAPI + gRPC server
from grpc import aio

async def grpc_server():
    server = aio.Server()
    # Register service handlers
    await server.start()
"""

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 18: Service Communication (segment_18_service_communication.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 19: Production Deployment & Zero-Downtime Strategies"
echo "============================================================================"

cat << 'EOF' > segment_19_deployment.py
"""
[WHAT]: Uvicorn vs Gunicorn, worker tuning, rolling/blue-green/canary deployments
[WHY]: Production deployments require zero downtime. Workers must be properly tuned.
"""

deployment_info = {
    "uvicorn_vs_gunicorn": """
    # Single-worker Uvicorn (development)
    uvicorn main:app --host 0.0.0.0 --port 8000
    
    # Gunicorn with Uvicorn workers (production)
    gunicorn main:app -k uvicorn.workers.UvicornWorker --workers 4 --worker-connections 1000
    
    [WHAT]: Workers = Separate processes handling requests concurrently
    [HOW]: --workers = Number of workers; tune to 2*(CPU cores) + 1 for I/O workloads
    [WATCH OUT]: Too few workers = requests queued; too many = context switching overhead
    """,
    
    "worker_tuning": """
    # For I/O-bound FastAPI (database, HTTP calls):
    workers = 2 * cpu_count + 1
    
    # For CPU-bound (rare):
    workers = cpu_count
    
    # Connection limits per worker
    --worker-connections 1000  # Max concurrent per worker
    --graceful-timeout 30      # Seconds to drain connections on shutdown
    """,
    
    "rolling_deployment": """
    # [WHAT]: Gradually replace old instances with new ones
    # Benefits: Zero downtime, easy rollback if issues
    # Risks: Multiple versions running; DB compatibility required
    
    Process:
    1. Launch new pod with updated code
    2. Wait for readiness probe to pass
    3. Load balancer routes traffic to new pod
    4. Terminate old pod
    5. Repeat until all pods updated
    """,
    
    "blue_green_deployment": """
    # [WHAT]: Two identical environments (Blue, Green); switch traffic between them
    # Benefits: Instant rollback; simple testing
    # Risks: 2x resource cost; data consistency during switch
    
    Process:
    1. Deploy new version to Green environment (no traffic)
    2. Run smoke tests against Green
    3. Switch load balancer: Blue -> Green
    4. Keep Blue as instant rollback plan
    5. After stability, redeploy Blue for next cycle
    """,
    
    "canary_release": """
    # [WHAT]: Route small percentage of traffic to new version
    # Benefits: Real-world testing before full release
    # Risks: Complex routing; version skew issues
    
    Process:
    1. Deploy new version alongside old
    2. Send 5% of traffic to new version
    3. Monitor error rates, latency
    4. If OK, increase to 25%, 50%, 100%
    5. If errors detected, rollback to 0%
    """,
    
    "nginx_config": """
    # Nginx reverse proxy for load balancing & graceful shutdown
    
    upstream backend {
        server app1:8000;
        server app2:8000;
        server app3:8000;
    }
    
    server {
        listen 80;
        
        location / {
            # [WHAT]: Route requests to backend pool
            proxy_pass http://backend;
            proxy_http_version 1.1;
            proxy_set_header Connection "";
            
            # [HOW]: WebSocket support (upgrade connection)
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # [WATCH OUT]: Timeout must match app graceful-timeout
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }
    }
    """,
    
    "graceful_shutdown": """
    # [COMPONENT MEANING] SIGTERM = Signal for graceful shutdown
    # [ARGUMENT MEANING] --graceful-timeout = Max seconds to drain connections
    
    Process:
    1. Kubernetes sends SIGTERM to pod
    2. Uvicorn stops accepting NEW requests
    3. Existing requests continue up to graceful-timeout seconds
    4. Pod exits; load balancer removes from pool
    5. SIGKILL sent if graceful-timeout exceeded (cleanup forced)
    
    Implementation:
    - FastAPI via Uvicorn handles SIGTERM natively
    - Close database connections in shutdown event
    - Use --graceful-timeout matching app lifecycle
    """
}

for title, content in deployment_info.items():
    print(f"\n[{title.upper()}]")
    print(content)

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 19: Production Deployment (segment_19_deployment.py)"

echo ""
echo "============================================================================"
echo "SEGMENT 20: Incident Response & Production Debugging"
echo "============================================================================"

cat << 'EOF' > segment_20_debugging.py
"""
[WHAT]: Log analysis, distributed tracing, profiling, memory debugging, incident response
[WHY]: Production issues demand visibility. Debugging tools extract signal from noise.
"""

debugging_tools = {
    "log_aggregation": """
    # [COMPONENT MEANING] ELK Stack = Elasticsearch, Logstash, Kibana
    # [WHAT]: Centralized log analysis for multi-service systems
    
    Implementation:
    1. FastAPI emits JSON logs to stdout
    2. Logstash parses and sends to Elasticsearch
    3. Kibana visualizes and searches logs
    
    Query example:
    - Find all 500 errors: status:500
    - Filter by service: service:"user-api"
    - Time range: last 5 minutes
    - Correlate by request ID: correlation_id:uuid123
    """,
    
    "distributed_tracing": """
    # [COMPONENT MEANING] Jaeger = Distributed tracing visualization
    # [WHAT]: Track request flow across multiple services
    
    Example trace:
    Request enters -> API Gateway (5ms) 
      -> User Service (50ms) 
        -> Database Query (40ms)
      -> Order Service (30ms)
        -> Payment Service (100ms)
    
    Identifies bottleneck (Payment Service) for optimization
    """,
    
    "profiling": """
    # [COMPONENT MEANING] py-spy = Sampling profiler for production
    # [HOW]: Attach to running process; collect CPU samples
    
    Command:
    py-spy record -o profile.svg -p <pid> -d 30 -r 100
    
    Output: Flame graph showing where CPU time spent
    Identifies hot paths for optimization
    """,
    
    "memory_profiling": """
    # [COMPONENT MEANING] memory_profiler = Track memory allocation
    # [WHAT]: Detect memory leaks, large object creation
    
    Tools:
    - memory_profiler: Line-by-line memory usage
    - tracemalloc: Python std lib; trace allocations
    - objgraph: Find object reference cycles
    """,
    
    "pool_exhaustion": """
    # [WATCH OUT]: Database connection pool exhaustion
    # Symptoms:
    - Requests timeout waiting for connection
    - "QueuePool limit exceeded" errors
    - High latency without CPU increase
    
    Debugging:
    1. Check pool size vs concurrent requests: pool_size + max_overflow
    2. Verify connections are being returned: monitor pool.checkedout()
    3. Check for connection leaks: connections not closing
    4. Review slow queries: might hold connections too long
    
    Fix:
    - Increase pool_size if legitimate traffic spike
    - Optimize queries to reduce holding time
    - Use connection pooling library (PgBouncer for PostgreSQL)
    """,
    
    "slow_queries": """
    # [COMPONENT MEANING] Slow query log = Database logs queries > threshold
    # [HOW]: Enable and analyze to find optimization targets
    
    Example (PostgreSQL):
    SET log_min_duration_statement = 1000;  # Log queries > 1 second
    
    Analysis:
    - Count occurrences: which query runs most?
    - Check execution plan: WHERE clause using index?
    - Look for N+1 queries: could use eager loading
    """,
    
    "race_condition": """
    # [WATCH OUT]: Bugs depending on timing of concurrent operations
    # Hard to reproduce; intermittent failures
    
    Example:
    Thread 1: Read balance = 100
    Thread 2: Read balance = 100
    Thread 1: Withdraw 50, write balance = 50
    Thread 2: Withdraw 30, write balance = 70  # Bug! Should be 20
    
    Debugging:
    - Reproduce under high concurrency: asyncio stress test
    - Use thread analyzers: ThreadSanitizer
    - Review critical sections: are they locked?
    - Add logging to sequence events
    
    Fix:
    - Use database transactions
    - Explicit locking: asyncio.Lock
    - Version-based optimistic locking
    """,
    
    "incident_response": """
    # [COMPONENT MEANING] Incident severity = Classification (P0/P1/P2/P3)
    # P0: Complete outage; immediate escalation
    # P1: Major degradation; page on-call
    # P2: Partial degradation; normal business hours
    # P3: Minor issue; backlog
    
    Incident playbook:
    1. DETECT: Monitoring alert triggered
    2. RESPOND: On-call engineer acknowledges
    3. ASSESS: Understand scope and impact
    4. MITIGATE: Stop bleeding (rollback, failover, etc.)
    5. RESOLVE: Fix root cause
    6. POSTMORTEM: Review what went wrong and prevent recurrence
    
    Runbook example:
    [Incident] Database connection pool exhaustion
    [Symptoms] Requests timing out with "pool limit exceeded"
    [Immediate Action]
    1. Restart affected service pods to clear bad connections
    2. Monitor pool.checkedout() metric
    3. Increase pool_size +50% in production
    [Investigation]
    1. Review slow query log from timeframe
    2. Check for recent deployments
    3. Correlate with traffic spike
    [Prevention]
    1. Add alerting for pool.checkedout() > 80%
    2. Implement connection timeout
    """
}

for title, content in debugging_tools.items():
    print(f"\n{'='*70}")
    print(f"[{title.upper()}]")
    print('='*70)
    print(content)

if __name__ == "__main__":
    pass
EOF

echo "✓ Segment 20: Debugging (segment_20_debugging.py)"

echo ""
echo "============================================================================"
echo "BUILD COMPLETE!"
echo "============================================================================"

echo "
✅ All 20 segments generated:

Segment  1: Core Architecture & ASGI Lifecycle
Segment  2: Pydantic Request Validation
Segment  3: Response Models & Serialization
Segment  4: Dependency Injection
Segment  5: SQLAlchemy Async
Segment  6: Authentication & OAuth2
Segment  7: Security Hardening
Segment  8: Alembic Migrations
Segment  9: Async & Concurrency
Segment 10: Caching & Performance
Segment 11: Logging & Tracing
Segment 12: Metrics & Health Checks
Segment 13: Middleware Architecture
Segment 14: Error Handling & Resilience
Segment 15: Testing Strategy
Segment 16: Docker & Kubernetes
Segment 17: API Versioning
Segment 18: Service-to-Service Communication
Segment 19: Production Deployment
Segment 20: Incident Response & Debugging

📁 Output: All files in $WORKSPACE

✨ Each segment demonstrates:
   - Basic Usage (foundational)
   - Power Usage (advanced features)
   - Precision Usage (edge cases)
   - Enterprise Context (production patterns)
"

echo ""
echo "Files available in workspace:"
ls -lh *.py *.sh 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'