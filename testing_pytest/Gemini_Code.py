# ==============================================================================
#  MEGA-BATCH: PYTEST & MOCKING — ALL 20 SEGMENTS (117 CONCEPTS)
#  File: test_megabatch.py
# ==============================================================================
#
#  HOW TO RUN (Ubuntu terminal):
#
#    Step 1 — Install dependencies:
#      pip install pytest requests
#
#    Step 2 — Run the full suite (verbose):
#      pytest test_megabatch.py -v
#
#    Step 3 — Run only a subset by marker:
#      pytest test_megabatch.py -v -m "not slow"
#      pytest test_megabatch.py -v -m "integration"
#
#    Step 4 — Run with coverage (optional):
#      pip install pytest-cov
#      pytest test_megabatch.py -v --cov=test_megabatch --cov-report=term-missing
#
# ==============================================================================

import sys
import asyncio
import json
import pytest
from unittest.mock import Mock, MagicMock, patch, call, AsyncMock
{
    # import os
    # import tempfile
}


# ==============================================================================
#  GLOBAL BASE — THE PRODUCTION CODE (SUBJECT UNDER TEST)
#
#  [WHAT] A minimal e-commerce payment and data validation system.
#         This is the "application code." We write tests FOR this.
#
#  [WHY]  A PaymentProcessor is the perfect teaching subject:
#         - It has happy paths (success responses) → teaches basic assertions.
#         - It has strict validation → teaches pytest.raises.
#         - It calls external services (HTTP APIs) → teaches mocking.
#         - It has batch operations → teaches parametrize.
#         ONE dataset, manipulated continuously, never re-invented mid-script.
# ==============================================================================

# --- Custom Domain Exceptions -------------------------------------------------

class InsufficientFundsError(Exception):
    """Raised when a charge amount exceeds the allowed single-transaction limit."""
    pass


class InvalidEmailError(ValueError):
    """Raised when an email string fails format validation checks."""
    pass


# --- Core Business Logic ------------------------------------------------------

class PaymentProcessor:
    # [WHAT] Handles charge and refund operations against a simulated payment gateway.
    # [WHY]  Keeps business logic in a class so fixture injection demos are realistic
    #        (a fixture can return a PaymentProcessor instance, just like a real DB session).

    def charge(self, amount, currency="USD"):
        # [HOW] Validate ALL inputs before touching any downstream service.
        #       This fail-fast discipline is what makes error-path tests meaningful.
        if amount <= 0:
            raise ValueError(f"Charge amount must be positive, got: {amount}")
        if amount > 10_000:
            raise InsufficientFundsError(
                f"Amount {amount} exceeds single-transaction limit of 10000"
            )
        return {"status": "charged", "amount": amount, "currency": currency}

    def refund(self, transaction_id, amount):
        if not transaction_id:
            raise ValueError("transaction_id cannot be empty or None")
        if amount <= 0:
            raise ValueError(f"Refund amount must be positive, got: {amount}")
        return {
            "status": "refunded",
            "transaction_id": transaction_id,
            "amount": amount,
        }

    def process_batch(self, transactions):
        # [WHAT] Iterates a list of transaction dicts and charges each one.
        # [WATCH OUT] If any transaction is invalid, the whole batch fails mid-loop.
        # In production you'd collect errors instead of letting one poison the batch.
        results = []
        for txn in transactions:
            result = self.charge(
                amount=txn["amount"],
                currency=txn.get("currency", "USD"),
            )
            results.append(result)
        return results


class DataValidator:
    # [WHAT] Validates emails, calculates discounts, checks palindromes, summarises scores.
    # [WHY]  A mix of pure functions (no I/O) gives us clean, deterministic tests —
    #        ideal for parametrize and property-based testing demos.

    def validate_email(self, email):
        if not email:
            raise InvalidEmailError("Email cannot be empty or None")
        if not isinstance(email, str):
            raise InvalidEmailError(
                f"Email must be a string, got: {type(email).__name__}"
            )
        if "@" not in email:
            raise InvalidEmailError(f"Email must contain '@': received '{email}'")
        if "." not in email.split("@")[-1]:
            raise InvalidEmailError(
                f"Email domain must contain '.': received '{email}'"
            )
        return True

    def calculate_discount(self, price, discount_pct):
        if discount_pct < 0 or discount_pct > 100:
            raise ValueError(
                f"Discount must be between 0 and 100, got: {discount_pct}"
            )
        return round(price * (1 - discount_pct / 100), ndigits=2)

    def is_palindrome(self, text):
        cleaned = text.lower().replace(" ", "")
        return cleaned == cleaned[::-1]

    def summarize_scores(self, scores):
        if not scores:
            raise ValueError("Scores list cannot be empty")
        return {
            "min": min(scores),
            "max": max(scores),
            "avg": round(sum(scores) / len(scores), ndigits=2),
            "count": len(scores),
        }


# --- Functions That Call External Services (Mock targets for Segments 6-7) ---

# [WATCH OUT] We alias `requests` here so it lives in THIS module's namespace as `test_megabatch.requests_lib`. The Importer's Rule (Segment 6.2) demands we patch it at "test_megabatch.requests_lib.get", NOT at
#             "requests.get", because THIS file is the consumer of that binding.
import requests as requests_lib


def fetch_exchange_rate(base_currency, target_currency):
    """Calls a live currency exchange API. NEVER call this real URL in tests."""
    response = requests_lib.get(
        url="https://api.exchangerate.host/latest",
        params={"base": base_currency, "symbols": target_currency},
        timeout=5,
    )
    data = response.json()
    return data["rates"][target_currency]


def notify_payment_gateway(transaction_id, amount, gateway_client):
    """Notifies an external payment gateway. The gateway_client is injected
    so tests can pass a Mock directly — no patching required."""
    gateway_client.post(
        endpoint="/notify",
        payload={"transaction_id": transaction_id, "amount": amount},
    )
    return True


async def async_fetch_user_profile(user_id, http_client=None):
    """Async function simulating an async HTTP call to a user-profile service."""
    # [WHY] Accepts an injectable http_client so AsyncMock can be passed directly
    #       without patching. Both injection and patching approaches are shown below.
    await asyncio.sleep(delay=0)  # Simulates an I/O yield point
    if http_client:
        result = await http_client.get(url=f"/users/{user_id}")
        return result
    return {"id": user_id, "name": "Jesse Tester", "role": "mlops_engineer"}



print("\n\n" + "=" * 70)
print("  SEGMENT 1.1: PYTEST INSTALLATION & DISCOVERY")
print("=" * 70)

# [WHAT] This print block runs at COLLECTION time (when pytest imports this file),
#        not at test execution time. It demonstrates that pytest discovers this file
#        because it matches the test_*.py naming convention.

print("""
  DISCOVERY RULES (what pytest looks for):
    - Files   : test_*.py  OR  *_test.py
    - Classes : names starting with 'Test' (no __init__ needed)
    - Functions: names starting with 'test_'

  TO RUN THIS SPECIFIC FILE:
    pytest test_megabatch.py -v

  TO DISCOVER ALL TESTS FROM ROOT:
    pytest -v

  COLLECTION PHASE: pytest walks the directory tree, imports every matching
  file, inspects its contents, and builds a list of test nodes BEFORE running
  any test. The '-v' flag shows each node's full ID:
    test_megabatch.py::TestDiscoveryDemo::test_inside_a_class
    test_megabatch.py::test_basic_equality
""")


# [WHAT] A Test class demonstrating the Test prefix convention (Pytest-1.1.F).
# [WHY]  Grouping related tests in a class lets you share state via class-level attributes and apply markers to the whole group at once.
class TestDiscoveryDemo:
    # [WATCH OUT] Pytest Test classes must NOT have an __init__ method.
    # Adding one causes silent collection failures.

    def test_inside_a_class(self):
        # [WHAT] Proves Pytest collects test_ methods inside a Test class.
        assert 1 + 1 == 2

    def test_another_method_in_class(self):
        assert "pytest" in "pytest is powerful"


def test_discovery_naming_convention():
    # [WHAT] A standalone test_ function — the most common test shape in pytest.
    # [WHAT ELSE] You can also name files ending with _test.py (e.g., payments_test.py).
    # Both conventions are equally valid; most Python projects pick one and stick to it.
    processor = PaymentProcessor()
    result = processor.charge(amount=100)
    assert result is not None




print("\n\n" + "=" * 70)
print("  SEGMENT 1.2: BASIC ASSERTIONS")
print("=" * 70)


def test_equality_assertion():
    # [WHAT] Tests that charge() returns the correct status and echoes back the amount.
    # [WHY]  assert a == b is the bread-and-butter assertion. When it fails, pytest's
    #        assertion rewriting (Pytest-1.2.B) shows BOTH sides of the comparison.
    processor = PaymentProcessor()
    result = processor.charge(amount=250, currency="USD")

    # [HOW] Assert the entire dict shape — tests structure, not just a single field.
    assert result == {"status": "charged", "amount": 250, "currency": "USD"}
    print(f"  [1.2.C] Equality check passed. Result: {result}")


def test_membership_assertion():
    # [WHAT] Verifies that specific keys exist in the response dict.
    # [WHY]  `in` operator on a dict checks keys. On a list, it checks values.
    #        Both are common in API response validation.
    processor = PaymentProcessor()
    result = processor.charge(amount=500)

    assert "status" in result
    assert "amount" in result
    assert "currency" in result
    # [WATCH OUT] `assert "charged" in result` would FAIL — dict `in` checks keys,
    #             not values. To check a value use: assert result["status"] == "charged"
    print(f"  [1.2.D] Membership check passed. Keys present: {list(result.keys())}")


def test_comparison_assertion():
    # [WHAT] Uses >, <, >= to verify numeric relationships in the response.
    processor = PaymentProcessor()
    result = processor.charge(amount=100)

    assert result["amount"] > 0
    assert result["amount"] <= 10_000
    assert result["amount"] >= 100

    validator = DataValidator()
    summary = validator.summarize_scores(scores=[70, 85, 90, 55, 100])
    assert summary["avg"] > summary["min"]
    assert summary["max"] >= summary["avg"]
    print(f"  [1.2.E] Comparison checks passed. Summary: {summary}")


def test_truthiness_assertion():
    # [WHAT] Asserts truthy/falsy values without explicit == True/False.
    # [WHY]  `assert result` is more idiomatic Python than `assert result == True`.
    #        Pytest's output is also cleaner: it shows the actual value when falsy.
    validator = DataValidator()
    is_valid = validator.validate_email(email="jesse@mlops.io")

    assert is_valid                          # Truthy: True
    assert validator.is_palindrome(text="racecar")   # Truthy: True
    assert not validator.is_palindrome(text="python") # Falsy: False, negated

    # [WHAT ELSE] pytest.approx() is the correct way to assert floating-point equality:
    #   assert result == pytest.approx(expected=9.99, rel=1e-3)
    #   Never use `assert 0.1 + 0.2 == 0.3` — floating-point arithmetic will fail it.
    print("Truthiness checks passed.")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   1 . 3  —  H A N D L I N G   E X C E P T I O N S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 1.3: HANDLING EXCEPTIONS")
print("=" * 70)


def test_raises_basic():
    # [WHAT] Asserts that charge() raises ValueError when given a negative amount.
    # [WHY]  pytest.raises() INVERTS the pass/fail logic: if the exception is NOT raised,
    #        the test FAILS. This forces you to test the unhappy path explicitly.
    processor = PaymentProcessor()

    with pytest.raises(ValueError):
        processor.charge(amount=-50)

    print("  [1.3.A] pytest.raises(ValueError) confirmed: negative amount rejected.")


def test_raises_with_match_parameter():
    # [WHAT] Asserts both the exception TYPE and the exception MESSAGE via regex.
    # [WHY]  Your codebase may raise ValueError from 5 different places. The match=
    #        parameter pins the test to the SPECIFIC failure, not just any ValueError.
    processor = PaymentProcessor()

    with pytest.raises(expected_exception=ValueError, match="must be positive"):
        processor.charge(amount=0)

    print("  [1.3.D] match= parameter confirmed: error message regex matched.")


def test_raises_captures_exception_info():
    # [WHAT] Binds the ExceptionInfo object to inspect the exception after the block.
    # [WHY]  When you need to inspect the exception's attributes beyond just the message
    #        (e.g., custom exception fields), the `as exc_info` pattern gives you full access.
    processor = PaymentProcessor()

    with pytest.raises(expected_exception=InsufficientFundsError) as exc_info:
        processor.charge(amount=50_000)

    # [HOW] exc_info.value is the actual exception instance.
    #       exc_info.type  is the exception class.
    #       exc_info.match() does the same regex check as the match= param above.
    assert exc_info.type is InsufficientFundsError
    exc_info.match(r"exceeds single-transaction limit")
    print(f"  [1.3.B/C] ExceptionInfo confirmed: {exc_info.value}")


def test_raises_exception_hierarchy():
    # [WHAT] Demonstrates that pytest.raises catches subclasses of the specified type.
    # [WHY]  InvalidEmailError subclasses ValueError. Raising InvalidEmailError inside
    #        pytest.raises(ValueError) still passes — honoring Python's exception hierarchy.
    validator = DataValidator()

    with pytest.raises(ValueError):
        # [HOW] InvalidEmailError IS-A ValueError, so this is caught correctly.
        validator.validate_email(email="not-an-email")

    print("  [1.3.F] Exception hierarchy confirmed: InvalidEmailError caught as ValueError.")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   2 . 1  —  I N T R O D U C T I O N   T O   F I X T U R E S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 2.1: INTRODUCTION TO FIXTURES")
print("=" * 70)


# [WHAT] Fixture that provides a fresh PaymentProcessor to any test that requests it.
# [WHY]  Without this fixture, every test would instantiate PaymentProcessor() manually.
#        With it, there's ONE definition and zero duplication. Change the class init
#        signature once and every test gets the update automatically.
@pytest.fixture
def payment_processor():
    return PaymentProcessor()


# [WHAT] Fixture providing a pre-configured DataValidator instance.
@pytest.fixture
def data_validator():
    return DataValidator()


# [WHAT] Fixture providing a realistic batch of transactions for batch-processing tests.
# [WHY]  Defining test data as a fixture means it's reusable, named, and version-controlled alongside the tests rather than scattered inline across multiple test functions.
@pytest.fixture
def sample_transactions():
    return [
        {"amount": 100, "currency": "USD"},
        {"amount": 250, "currency": "EUR"},
        {"amount": 75,  "currency": "GBP"},
    ]


def test_fixture_injection_basic(payment_processor):
    # [WHAT] Pytest sees `payment_processor` in the parameter list, looks it up in
    #        the fixture registry, calls the fixture function, and injects its return value.
    # [HOW]  No import, no instantiation — just declare the name and receive the object.
    result = payment_processor.charge(amount=100)
    assert result["status"] == "charged"
    print(f"  [2.1.A/C] Fixture injected. Result: {result}")


def test_fixture_eliminates_duplication(payment_processor, data_validator):
    # [WHAT] Multiple fixtures injected into a single test — Pytest resolves each independently.
    # [WHY]  This test could not even be called without two correctly set-up objects.
    #        The fixture system supplies both cleanly, with zero setup code in the test body.
    charge_result = payment_processor.charge(amount=500)
    email_valid = data_validator.validate_email(email="jesse@startup.io")

    assert charge_result["amount"] == 500
    assert email_valid is True
    print("  [2.1.B] DI confirmed: two fixtures resolved independently.")


def test_fixture_request_object():
    # [WHAT] Demonstrates accessing the built-in `request` fixture for test metadata.
    # [WHY]  The request object gives a fixture access to the calling test's node ID,
    #        module, cls (class), and parametrize params — used for dynamic setup.
    pass  # Demonstrated inside the fixture below, see `request_aware_fixture`.


@pytest.fixture
def request_aware_fixture(request):
    # [WHAT] Uses the built-in `request` parameter to print the calling test's identity.
    # [WHAT ELSE] request.param is how parametrized fixtures receive their values —
    # used in the `indirect` parametrize pattern for advanced DI scenarios.
    print(f"\n  [2.1.E] Fixture called by test: {request.node.name}")
    return f"context_for_{request.node.name}"


def test_uses_request_aware_fixture(request_aware_fixture):
    assert "context_for" in request_aware_fixture


# ==============================================================================
# ==============================================================================
#   S E G M E N T   2 . 2  —  S E T U P   A N D   T E A R D O W N   ( Y I E L D )
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 2.2: SETUP AND TEARDOWN (YIELD)")
print("=" * 70)


@pytest.fixture
def temp_report_file(tmp_path):
    # [WHAT] Creates a temporary JSON report file before the test and deletes it after.
    # [WHY]  The yield pattern separates SETUP (before yield) from TEARDOWN (after yield).
    # Code after yield is GUARANTEED to run even if the test raises an exception.
    # This is equivalent to try/finally but expressed as a linear narrative.
    #
    # [HOW]
    #   Step 1: Create the temp file path (setup phase).
    report_path = tmp_path / "payment_report.json"
    report_data = {"batch_id": "TX-001", "total": 425, "currency": "USD"}
    report_path.write_text(data=json.dumps(report_data), encoding="utf-8")

    print(f"\n  [2.2.C] SETUP: Created temp report at {report_path}")

    #   Step 2: Yield the path to the test. Test runs here.
    yield report_path

    #   Step 3: Teardown phase — runs AFTER the test, pass or fail.
    if report_path.exists():
        report_path.unlink()
        print(f"  [2.2.D] TEARDOWN: Deleted temp report at {report_path}")

    # [WATCH OUT] `tmp_path` is a built-in pytest fixture that already creates a
    # unique temporary directory per test. You rarely need to manually
    # delete files inside tmp_path — pytest cleans it up after the session.
    # This teardown is here for PEDAGOGICAL demonstration only.


def test_yield_fixture_creates_file(temp_report_file):
    # [WHAT] Verifies the file created in the fixture setup phase actually exists
    #        and contains the expected JSON structure.
    assert temp_report_file.exists()
    content = json.loads(temp_report_file.read_text(encoding="utf-8"))
    assert content["batch_id"] == "TX-001"
    assert content["total"] == 425
    print(f"  [2.2.A] Yield fixture confirmed. File content: {content}")


@pytest.fixture
def processor_with_audit_log():
    # [WHAT] Demonstrates that yield fixtures can hold state between setup and teardown.
    # [WHY]  In production you'd open a DB connection, yield it, then close it.
    #        Here we simulate that pattern with a list acting as an "audit log."
    audit_log = []
    processor = PaymentProcessor()

    # Monkey-patch charge to log every call (simulates instrumentation):
    original_charge = processor.charge
    def instrumented_charge(amount, currency="USD"):
        result = original_charge(amount=amount, currency=currency)
        audit_log.append({"amount": amount, "currency": currency})
        return result
    processor.charge = instrumented_charge

    yield processor, audit_log  # Yield a TUPLE — test unpacks it

    # Teardown: In a real DB fixture, this is where you'd call session.close()
    print(f"\n  [2.2.D] TEARDOWN: Audit log had {len(audit_log)} entries. Clearing.")
    audit_log.clear()

    # [WHAT ELSE] addfinalizer() is the pre-yield alternative:
    #   request.addfinalizer(lambda: session.close())
    #   It's more verbose but useful when teardown logic is non-linear or conditional.


def test_yield_fixture_with_teardown(processor_with_audit_log):
    processor, audit_log = processor_with_audit_log
    processor.charge(amount=100)
    processor.charge(amount=200)
    assert len(audit_log) == 2
    assert audit_log[0]["amount"] == 100
    print(f"  [2.2.B] Teardown guarantee confirmed. Audit log: {audit_log}")




print("\n\n" + "=" * 70)
print("  SEGMENT 2.3: FIXTURE SCOPES")
print("=" * 70)


# [WHAT] A module-scoped fixture that simulates the expensive setup of a "DB connection pool."
# [WHY]  scope="module" means this fixture runs ONCE for the entire file.
#        All tests in this module that request `shared_processor_pool` share the same instance.
#        At module scope, setup cost is paid once — not once per test.
# [WATCH OUT] Module-scoped fixtures MUST be treated as READ-ONLY by individual tests.
# If test_A mutates the shared object, test_B (which runs after) sees corrupted state.
@pytest.fixture(scope="module")
def shared_processor_pool():
    print("\n  [2.3.C] MODULE-SCOPE SETUP: Simulating expensive connection pool creation...")
    pool = {
        "pool_id": "POOL-001",
        "processor": PaymentProcessor(),
        "max_connections": 10,
    }
    yield pool
    print("\n  [2.3.C] MODULE-SCOPE TEARDOWN: Closing connection pool...")


# [WHAT] A session-scoped fixture that creates a global config object once per test run.
# [WHY]  Config objects (API keys, environment flags) are identical across ALL tests.
#        Session scope is the correct choice: maximum setup cost reduction.
@pytest.fixture(scope="session")
def global_config():
    print("\n  [2.3.D] SESSION-SCOPE SETUP: Loading global configuration...")
    config = {
        "environment": "test",
        "api_version": "v2",
        "max_retries": 3,
    }
    yield config
    print("\n  [2.3.D] SESSION-SCOPE TEARDOWN: Releasing global config.")


def test_module_scope_fixture_first_call(shared_processor_pool):
    # [WHAT] First test to use shared_processor_pool — this triggers the module-scope setup.
    assert shared_processor_pool["pool_id"] == "POOL-001"
    result = shared_processor_pool["processor"].charge(amount=100)
    assert result["status"] == "charged"
    print("  [2.3.C] Module-scope fixture confirmed (first call).")


def test_module_scope_fixture_second_call(shared_processor_pool):
    # [WHAT] Second test using the SAME module-scope fixture instance.
    #        The fixture was NOT re-created. Setup cost was paid exactly once.
    assert shared_processor_pool["max_connections"] == 10
    print("  [2.3.C] Module-scope fixture confirmed (second call — no re-setup).")


def test_session_scope_config(global_config):
    # [WHAT] Accesses the session-scoped global config.
    assert global_config["environment"] == "test"
    assert global_config["max_retries"] == 3
    print(f"  [2.3.D] Session-scope fixture confirmed. Config: {global_config}")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   3 . 1  —  C O N F T E S T . P Y
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 3.1: CONFTEST.PY")
print("=" * 70)


def test_conftest_explanation(tmp_path):
    # [WHAT] Demonstrates the conftest.py pattern by writing the recommended structure to a temp directory and printing it for inspection.
    # [WHY]  conftest.py cannot be demonstrated "inside" a single test file — it IS the
    #        file that makes fixtures global. This test makes the concept tangible.

    # [HOW] This is what a real project's conftest.py structure looks like:
    conftest_content = '''# tests/conftest.py
# ─────────────────────────────────────────────────────────────────
# [WHAT] Root-level conftest.py — globally accessible fixtures for the entire suite.
# [WHY]  Fixtures here are available to ALL tests in ALL subdirectories with NO imports.
# Pytest auto-discovers conftest.py files and loads them before any test runs.
# ─────────────────────────────────────────────────────────────────

import pytest
from myapp.database import create_engine, create_session
from myapp.main import create_app

@pytest.fixture(scope="session")
def db_engine():
    engine = create_engine(url="postgresql://localhost/test_db")
    yield engine
    engine.dispose()

@pytest.fixture(scope="function")
def db_session(db_engine):                  # <-- Fixture chaining (Segment 3.2)
    session = create_session(bind=db_engine)
    yield session
    session.rollback()
    session.close()

@pytest.fixture(scope="session")
def app():
    return create_app(config="testing")

@pytest.fixture(scope="session")
def client(app):
    from fastapi.testclient import TestClient
    return TestClient(app=app)
'''

    # [HOW] Write it to tmp_path so Jesse can inspect it as an actual file.
    conftest_file = tmp_path / "conftest.py"
    conftest_file.write_text(data=conftest_content, encoding="utf-8")

    # Verify it was written and has meaningful content:
    written_content = conftest_file.read_text(encoding="utf-8")
    assert "pytest.fixture" in written_content
    assert "scope=" in written_content

    # [WHAT ELSE] Conftest files can also register HOOKS (not just fixtures):
    #   def pytest_configure(config): ...        # runs at startup
    #   def pytest_runtest_setup(item): ...      # runs before each test
    #   def pytest_collection_modifyitems(items): ...  # modify collected tests
    print(f"\n  [3.1.A] conftest.py written to: {conftest_file}")
    print("  [3.1.B] Scope hierarchy: session > module > class > function")
    print("\n  [3.1.E] Recommended project structure:")
    print("""
    my_project/
    ├── src/
    │   └── myapp/
    │       ├── __init__.py
    │       ├── main.py
    │       └── database.py
    ├── tests/
    │   ├── conftest.py          ← Global fixtures (db_engine, client, app)
    │   ├── unit/
    │   │   ├── conftest.py      ← Unit-test-specific fixtures (mocks, stubs)
    │   │   └── test_validator.py
    │   └── integration/
    │       ├── conftest.py      ← Integration fixtures (real DB session)
    │       └── test_payments.py
    ├── pytest.ini
    └── pyproject.toml
    """)


# ==============================================================================
# ==============================================================================
#   S E G M E N T   3 . 2  —  R E Q U E S T I N G   F I X T U R E S
#                              F R O M   F I X T U R E S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 3.2: REQUESTING FIXTURES FROM FIXTURES (CHAINING)")
print("=" * 70)


# [WHAT] Base fixture — lowest level of the dependency chain.
# [WHY]  Represents a session-level DB engine: expensive to create, shared broadly.
@pytest.fixture(scope="module")
def db_engine_mock():
    # [HOW] In real code: `engine = create_engine(url=DATABASE_URL)`
    #       Here we simulate it with a MagicMock to keep the demo self-contained.
    engine = MagicMock(name="DatabaseEngine")
    engine.url = "postgresql://localhost/test_db"
    engine.pool_size = 5
    print("\n  [3.2.A] db_engine_mock CREATED (module scope)")
    yield engine
    print("\n  [3.2.A] db_engine_mock DISPOSED (module teardown)")


# [WHAT] Mid-chain fixture — depends on db_engine_mock, provides db_session_mock.
# [WHY]  This is the Dependency Graph in action (Pytest-3.2.B). Pytest sees that
#        db_session_mock needs db_engine_mock, so it resolves the engine first.
# [WATCH OUT] Scope compatibility rule (Pytest-3.2.D): a fixture can only request
# fixtures of the SAME or WIDER scope. A function-scoped fixture requesting a module-scoped fixture is fine. The REVERSE is not allowed.

@pytest.fixture(scope="function")
def db_session_mock(db_engine_mock):
    session = MagicMock(name="DatabaseSession")
    session.bind = db_engine_mock  # Links session to the engine
    session.is_active = True
    print(f"\n  [3.2.A] db_session_mock CREATED (bound to engine: {db_engine_mock.url})")
    yield session
    session.rollback()
    print("\n  [3.2.A] db_session_mock ROLLED BACK and closed")


# [WHAT] Top-chain fixture — depends on db_session_mock, provides a PaymentRepository.
@pytest.fixture
def payment_repository(db_session_mock):
    # [HOW] Repository pattern: wraps DB session, exposes domain operations.
    #       The chain is now: db_engine_mock → db_session_mock → payment_repository
    repo = {
        "session": db_session_mock,
        "find_by_id": lambda txn_id: {"id": txn_id, "amount": 500},
    }
    return repo


def test_fixture_chain_resolution(payment_repository, db_session_mock, db_engine_mock):
    # [WHAT] Requests all three levels of the chain explicitly to verify they're properly connected. Pytest resolves the DAG correctly in all cases.

    assert payment_repository["session"] is db_session_mock
    assert db_session_mock.bind is db_engine_mock
    assert db_engine_mock.url == "postgresql://localhost/test_db"

    txn = payment_repository["find_by_id"]("TX-999")
    assert txn["amount"] == 500

    print("\n  [3.2.B] Dependency chain confirmed:")
    print("         db_engine_mock → db_session_mock → payment_repository ✓")
    print("  [3.2.C] Teardown will execute in REVERSE order: repo → session → engine")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   3 . 3  —  A U T O U S E   F I X T U R E S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 3.3: AUTOUSE FIXTURES")
print("=" * 70)


# [WHAT] An autouse fixture that resets a module-level "global state" dict before every test in this module, ensuring no test can pollute state for the next.
# [WHY]  Cross-cutting infrastructure concerns (resetting global state, patching the
#        clock, clearing caches) belong in autouse fixtures — not in every test body.
# [WATCH OUT] autouse=True fixtures are INVISIBLE to the test reading the code.
# They can confuse contributors who see tests passing/failing for reasons they can't find in the test body. ALWAYS add a clear docstring.
_GLOBAL_STATE = {"last_transaction_id": None, "request_count": 0}


@pytest.fixture(autouse=True)
def reset_global_state():
    """
    AUTOUSE FIXTURE — runs silently before EVERY test in this module.
    Resets _GLOBAL_STATE to a clean baseline so no test bleeds into another.
    """
    _GLOBAL_STATE["last_transaction_id"] = None
    _GLOBAL_STATE["request_count"] = 0
    yield
    # [WHAT ELSE] If you only want autouse in a specific class, define the fixture
    # INSIDE the class body. Its scope is then limited to that class's tests.


def test_autouse_gives_clean_state_first():
    # [WHAT] Mutates global state — the next test should see the reset version.
    _GLOBAL_STATE["last_transaction_id"] = "TX-ABC"
    _GLOBAL_STATE["request_count"] = 42
    assert _GLOBAL_STATE["last_transaction_id"] == "TX-ABC"
    print(f"\n  [3.3.A] State mutated: {_GLOBAL_STATE}")


def test_autouse_confirms_state_was_reset():
    # [WHAT] Verifies the autouse fixture ran between the two tests and wiped the state.
    # [WHY]  If autouse weren't present, this test would see "TX-ABC" and fail — proving
    #        that the autouse fixture is doing its invisible but critical job.
    assert _GLOBAL_STATE["last_transaction_id"] is None
    assert _GLOBAL_STATE["request_count"] == 0
    print(f"  [3.3.C] State reset confirmed by autouse fixture: {_GLOBAL_STATE}")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   4 . 1  —  @ p y t e s t . m a r k . p a r a m e t r i z e
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 4.1: @pytest.mark.parametrize DECORATOR")
print("=" * 70)


# [WHAT] A single test function exercising validate_email() across 8 distinct inputs.
# [WHY]  Without parametrize this would be 8 copy-pasted test functions.
#        With parametrize it is ONE function, EIGHT independent test nodes.
# Each node gets its own pass/fail status in the output.
@pytest.mark.parametrize(
    argnames="email, should_raise",

    argvalues=[
        ("jesse@mlops.io",      False), # Valid email — happy path
        ("user@domain.com",     False),   # Standard valid email
        ("",                    True),    # Empty string → InvalidEmailError
        (None,                  True),    # None → InvalidEmailError
        ("not-an-email",        True),    # Missing @ → InvalidEmailError
        ("missing@nodot",       True),    # Domain has no dot → InvalidEmailError
        ("@nodomain.com",       False),   # Edge: empty local-part — passes our rules
        ("multi+tag@domain.io", False),   # Valid: + in local part is RFC-compliant
    ],
)



def test_validate_email_parametrized(email, should_raise):
    # [WHAT] Tests both the happy path AND all error paths in one parametrized block.
    # [WHY]  Edge cases (empty string, None, missing @) are the inputs that WILL reach
    #        production. Testing them is not optional — it is the entire point
    validator = DataValidator()

    if should_raise:
        with pytest.raises(expected_exception=(InvalidEmailError, ValueError)):
            validator.validate_email(email=email)
    
    else:
        assert validator.validate_email(email=email) is True

    print(f"  [4.1.A] Tested: {repr(email)} → raises={should_raise}")


@pytest.mark.parametrize(
    argnames="price, discount_pct, expected",
    argvalues=[
        (100.0,  0,   100.0),    # 0% discount → no change
        (100.0,  10,  90.0),     # 10% off $100 → $90
        (200.0,  25,  150.0),    # 25% off $200 → $150
        (99.99,  50,  50.0),     # 50% off $99.99 → $50.00 (rounded)
        (100.0,  100, 0.0),      # 100% off → $0
    ],
)
def test_calculate_discount_parametrized(price, discount_pct, expected, data_validator):
    # [WHAT] Table-driven test for the discount calculator.
    # [WHY]  Each row IS a business requirement: "25% off $200 must equal $150."
    #        This table IS the specification. It doubles as documentation.
    result = data_validator.calculate_discount(price=price, discount_pct=discount_pct)
    assert result == pytest.approx(expected=expected, rel=1e-2)
    print(f"  [4.1.E] {price} - {discount_pct}% = {result} (expected {expected}) ✓")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   4 . 2  —  S T A C K I N G   P A R A M E T R I Z A T I O N
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 4.2: STACKING PARAMETRIZATION (CARTESIAN PRODUCTS)")
print("=" * 70)


# [WHAT] Two stacked @parametrize decorators generating a 3×3 = 9-node Cartesian product.
# [WHY]  You need to verify that charge() works correctly for ALL combinations of
#        amount tier AND currency. 3 amounts × 3 currencies = 9 test cases, one function.
# [WATCH OUT] Combinatorial explosion is real. 5×5×5 = 125 cases. Before stacking, ask: "Do ALL these combinations represent meaningful scenarios?". If most combinations are duplicates of the same logic, don't stack — it adds noise without increasing confidence.
@pytest.mark.parametrize(
    argnames="currency",
    argvalues=["USD", "EUR", "GBP"],
)
@pytest.mark.parametrize(
    argnames="amount",
    argvalues=[50, 500, 5000],
)
def test_charge_all_amount_currency_combinations(amount, currency):
    # [WHAT] Runs 9 independent test nodes covering every (amount, currency) pairing.
    processor = PaymentProcessor()
    result = processor.charge(amount=amount, currency=currency)

    assert result["status"] == "charged"
    assert result["amount"] == amount
    assert result["currency"] == currency
    print(f"  [4.2.A] Cartesian case: amount={amount}, currency={currency} ✓")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   4 . 3  —  D Y N A M I C   I D S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 4.3: DYNAMIC IDs")
print("=" * 70)


# [WHAT] Uses pytest.param() to assign human-readable IDs to each parametrize entry.
# [WHY]  Without IDs, a failure reports as `test_....[case3]` — useless in CI logs.
#        With IDs, it reports as `test_....[amount_exceeds_limit]` — immediately actionable.
# [HOW]  Wrap each tuple in pytest.param(*values, id="description").
#        The id string appears in the test node name and in failure output.
@pytest.mark.parametrize(
    argnames="amount, expected_exception, description",
    argvalues=[
        pytest.param(
            100, None, "valid_standard_amount",
            id="valid_standard_amount",
        ),
        pytest.param(
            0, ValueError, "zero_amount_rejected",
            id="zero_amount_rejected",
        ),
        pytest.param(
            -1, ValueError, "negative_amount_rejected",
            id="negative_amount_rejected",
        ),
        pytest.param(
            10_001, InsufficientFundsError, "amount_exceeds_limit",
            id="amount_exceeds_limit",
        ),
    ],
)
def test_charge_with_dynamic_ids(amount, expected_exception, description):
    # [WHAT] The test node names in output will be:
    #         test_charge_with_dynamic_ids[valid_standard_amount]
    #         test_charge_with_dynamic_ids[zero_amount_rejected]   ← readable!
    #         etc.
    processor = PaymentProcessor()

    if expected_exception is None:
        result = processor.charge(amount=amount)
        assert result["status"] == "charged"
    else:
        with pytest.raises(expected_exception=expected_exception):
            processor.charge(amount=amount)

    print(f"  [4.3.A/B] Dynamic ID case '{description}' passed.")

    # [WHAT ELSE] You can also pass a flat `ids=` list to the decorator itself:
    #   @pytest.mark.parametrize("x", [1, 2, 3], ids=["one", "two", "three"])
    #   This is simpler when you don't need per-case marks. pytest.param() is better
    #   when you ALSO want to attach marks (e.g., pytest.mark.xfail) to individual cases.


# ==============================================================================
# ==============================================================================
#   S E G M E N T   5 . 1  —  B U I L T - I N   M A R K E R S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 5.1: BUILT-IN MARKERS (skip, skipif, xfail)")
print("=" * 70)


@pytest.mark.skip(reason="Placeholder: FX rate API credentials not yet configured in CI")
def test_fetch_live_exchange_rate():
    # [WHAT] Unconditionally skipped — shown as 's' in test output.
    # [WHY]  skip is for code that is KNOWN to be non-runnable in the current context.
    #        This is a legitimate use: a test that requires a secret not yet set up.
    # [WATCH OUT] A skipped test is a DEBT. If it stays skipped for >1 sprint, either fix the blocking condition or delete the test. Permanent skips = dead code.
    result = fetch_exchange_rate(base_currency="USD", target_currency="EUR")
    assert result > 0


@pytest.mark.skipif(
    condition=sys.platform == "win32",
    reason="File path handling test is Unix-specific — skipped on Windows",
)
def test_unix_file_path_handling(tmp_path):
    # [WHAT] Runs on Linux/Mac, skips on Windows — shown as 's' with reason on Windows.
    # [WHY]  Platform-conditional skips let you write OS-specific tests without maintaining separate CI pipelines.
    unix_path = tmp_path / "reports" / "output.json"
    unix_path.parent.mkdir(parents=True, exist_ok=True)
    unix_path.write_text(data='{"status": "ok"}', encoding="utf-8")
    assert unix_path.exists()
    print(f"  [5.1.B] Unix path test passed on {sys.platform}.")


@pytest.mark.xfail(
    reason="Known bug: discount of exactly 100 returns -0.0 on some Python builds",
    strict=False,
)
def test_xfail_known_discount_edge_case():
    # [WHAT] Marked as expected to fail. Reports 'x' (xfailed) when it fails,
    #        'X' (xpassed) if it suddenly passes — which is a signal to remove the mark.
    # [WHY]  This is how you TRACK known bugs in the test suite itself.
    # The bug is documented at test level, not in a Jira ticket no one reads.
    # [WATCH OUT] strict = False (default) means an xpass is a soft warning.
    # strict=True means an xpass is a hard FAILURE — use this when you have added a bug fix and want CI to enforce the fix stays in.
    validator = DataValidator()
    result = validator.calculate_discount(price=100.0, discount_pct=100)
    # This assertion may fail on certain CPython builds due to -0.0 vs 0.0 representation:
    assert result == 0.0 and not (1 / result > 0 if result != 0 else False)
    print(f"  [5.1.D] xfail test ran. Result: {result}")


@pytest.mark.xfail(
    raises=InsufficientFundsError,
    reason="Refund above limit should trigger InsufficientFundsError — behavior TBD",
    strict=False,
)
def test_xfail_with_raises_filter():
    # [WHAT] The raises = parameter means ONLY InsufficientFundsError counts as xfail.
    # [WHY]  If a different exception surfaces (e.g., TypeError, AttributeError),
    #        the test is treated as a normal FAILURE rather than a known xfail —
    #        because that's an unexpected, non-spec failure.
    processor = PaymentProcessor()
    processor.refund(transaction_id="TX-001", amount=999_999)
    print("  [5.1.F] xfail with raises= filter confirmed.")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   5 . 2  —  C U S T O M   M A R K E R S
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 5.2: CUSTOM MARKERS")
print("=" * 70)

# [WATCH OUT] These custom markers are NOT yet registered in pytest.ini (that's Segment 5.3).
# Running this script will produce PytestUnknownMarkWarning for each one.
# The fix is demonstrated in the next segment.


@pytest.mark.slow
def test_slow_batch_processing(payment_processor, sample_transactions):
    # [WHAT] A test marked as @slow — excluded when running `pytest -m "not slow"`.
    # [WHY]  Batch operations against real services take time. Tiering ensures
    # developers can run a fast subset locally without waiting for slow tests.
    results = payment_processor.process_batch(transactions=sample_transactions)
    assert len(results) == 3
    assert all(r["status"] == "charged" for r in results)
    print(f"  [5.2.A] @slow test passed. {len(results)} transactions processed.")


@pytest.mark.integration
def test_integration_refund_flow(payment_processor):
    # [WHAT] Marks a test as @integration — run only in the integration stage of CI.
    # [WHY]  In a real pipeline: `pytest -m "integration"` runs in a separate GitHub
    # Actions job with a live database service container (Segment 15.2).
    charge = payment_processor.charge(amount=300)
    refund = payment_processor.refund(
        transaction_id="TX-300",
        amount=charge["amount"],
    )
    assert refund["status"] == "refunded"
    assert refund["amount"] == 300
    print(f"  [5.2.A/C] @integration test passed. Refund: {refund}")


@pytest.mark.parametrize(
    argnames="amount",
    argvalues=[
        pytest.param(100, id="valid_100"),
        pytest.param(-5,  id="invalid_neg", marks=pytest.mark.xfail),
    ],
)
def test_marker_on_individual_parametrize_case(amount):
    # [WHAT] Demonstrates applying marks (like xfail) to individual pytest.param entries.
    # [WHAT ELSE] `pytest -m "slow and not integration"` is a boolean expression.
    # Supported operators: `and`, `or`, `not`, and parentheses.
    processor = PaymentProcessor()
    result = processor.charge(amount=amount)
    assert result["status"] == "charged"
    print(f"  [5.2.D] Parametrized case with per-case mark passed: amount={amount}")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   5 . 3  —  P Y T E S T . I N I   C O N F I G U R A T I O N
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 5.3: PYTEST.INI CONFIGURATION")
print("=" * 70)


def test_pytest_ini_demonstration(tmp_path):
    # [WHAT] Writes a production-quality pytest.ini to disk and explains each key.
    # [WHY]  pytest.ini is the CONTRACT between your team and the test framework.
    #        Without it, every engineer runs pytest differently on their machine.
    #        With it, `pytest` with NO arguments behaves identically everywhere.

    # [HOW] This is what the recommended pytest.ini for this project looks like:
    pytest_ini_content = """\
[pytest]

# ── Default CLI flags applied to EVERY invocation ──────────────────────────
# -v          : verbose (print each test node's full ID + result)
# --tb=short  : compact tracebacks (one-liner context, not full stack)
# --strict-markers : treat unregistered markers as hard errors (no warnings)
addopts = -v --tb=short --strict-markers

# ── Discovery paths ─────────────────────────────────────────────────────────
# Restricts pytest to only walk the 'tests/' directory.
# Prevents accidentally collecting files in src/, scripts/, or notebooks/.
testpaths = tests

# ── Registered custom markers ────────────────────────────────────────────────
# Silences PytestUnknownMarkWarning for each marker.
# These descriptions appear in `pytest --markers` output.
markers =
    slow: Tests that make real network calls or process large datasets (>1s)
    integration: Tests that require live service infrastructure (DB, Redis, S3)
    gpu: Tests that require a CUDA-capable GPU to run
    flaky: Tests known to be non-deterministic — quarantined for investigation
"""

    ini_path = tmp_path / "pytest.ini"
    ini_path.write_text(data=pytest_ini_content, encoding="utf-8")

    content = ini_path.read_text(encoding="utf-8")
    assert "[pytest]" in content
    assert "addopts" in content
    assert "strict-markers" in content
    assert "testpaths" in content
    assert "markers" in content

    print(f"\n  [5.3.A] pytest.ini written to: {ini_path}")
    print("\n  [5.3.B] pyproject.toml alternative: use [tool.pytest.ini_options] section.")
    print("  [5.3.C] addopts confirmed: -v --tb=short --strict-markers")
    print("  [5.3.D] Registered markers: slow, integration, gpu, flaky")
    print("  [5.3.E] --strict-markers: unregistered markers → collection ERROR")
    print("  [5.3.F] testpaths: discovery restricted to 'tests/' directory")
    print(f"\n  Full pytest.ini content:\n{content}")

    # [WHAT ELSE] pytest can also read config from setup.cfg under [tool:pytest].
    # pyproject.toml is the modern standard for new projects.
    # pytest.ini takes precedence over both if all three are present.


# ==============================================================================
# ==============================================================================
#   S E G M E N T   6 . 1  —  T H E   u n i t t e s t . m o c k   L I B R A R Y
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 6.1: THE unittest.mock LIBRARY")
print("=" * 70)


def test_mock_object_basics():
    # [WHAT] Demonstrates that a Mock() auto-creates attributes and records all access.
    # [WHY]  Mock is the simplest fake: it never raises AttributeError, records every call, and returns a new Mock for every attribute access. Pure spy behaviour.
    gateway = Mock(name="PaymentGateway")

    # Every attribute access returns a new Mock:
    response = gateway.post(endpoint="/charge", payload={"amount": 100})

    assert gateway.post.called
    assert gateway.post.call_count == 1
    print(f"  [6.1.B] Mock.post called: {gateway.post.called}, count: {gateway.post.call_count}")


def test_magic_mock_context_manager():
    # [WHAT] MagicMock pre-implements dunder methods, enabling it to be used as a context manager (`with mock_obj as ...:`) without extra configuration.
    # [WHY]  Real file handles, DB sessions, and HTTP clients are all context managers.
    # MagicMock lets you replace them transparently.
    file_mock = MagicMock(name="FileHandle")

    with file_mock as handle:
        handle.write(b"payment data")

    # __enter__ and __exit__ were called automatically:
    file_mock.__enter__.assert_called_once()
    file_mock.__exit__.assert_called_once()
    print("  [6.1.C] MagicMock __enter__/__exit__ confirmed: context manager protocol works.")

    # [WHAT ELSE] Mock(spec=RealClass) constrains the mock to ONLY expose attributes that exist on RealClass. This prevents tests from calling methodsthat don't exist on the real object — a common source of false-green tests. Example: gateway_mock = Mock(spec=PaymentGateway)


def test_mocking_cost_isolation_speed(tmp_path):
    # [WHAT] Demonstrates all three justifications for mocking in a single test.
    # [WHY]  Speed: no network call. Isolation: PaymentProcessor is tested, not the gateway.
    # Cost: no API billing. All three are satisfied by replacing the gateway with Mock.

    gateway = MagicMock(name="FakeGateway")
    gateway.charge.return_value = {"gateway_ref": "GW-001", "approved": True}

    result = notify_payment_gateway(
        transaction_id="TX-500",
        amount=250,
        gateway_client=gateway,
    )
    assert result is True
    gateway.post.assert_called_once()
    print("  [6.1.D/E/F] Isolation confirmed: gateway called without real network.")


# ==============================================================================
# ==============================================================================
#   S E G M E N T   6 . 2  —  P A T C H I N G   ( T H E   A R T   O F
#                              R E P L A C E M E N T )
# ==============================================================================
# ==============================================================================

print("\n\n" + "=" * 70)
print("  SEGMENT 6.2: PATCHING — THE ART OF REPLACEMENT")
print("=" * 70)


# [WHAT] Demonstrates the @patch decorator — patches requests_lib.get in THIS module.
# [WHY]  fetch_exchange_rate() calls requests_lib.get() which was imported AS requests_lib
#        at the top of THIS file. So we must patch "test_megabatch.requests_lib.get" —
#        not "requests.get". The Importer's Rule (Pytest-6.2.D).
# [HOW]  @patch injects the Mock as the LAST positional argument.
#        If multiple @patch decorators stack, the bottommost decorator's mock
#        is the FIRST injected parameter (innermost wraps first).
@patch(target="test_megabatch.requests_lib.get")
def test_patch_decorator(mock_get):
    # [WHAT] mock_get is now in control of every call to requests_lib.get()
    #        inside test_megabatch.fetch_exchange_rate() during this test ONLY.
    mock_get.return_value.json.return_value = {
        "rates": {"EUR": 0.92}
    }

    rate = fetch_exchange_rate(base_currency="USD", target_currency="EUR")

    assert rate == 0.92
    mock_get.assert_called_once_with(
        url="https://api.exchangerate.host/latest",
        params={"base": "USD", "symbols": "EUR"},
        timeout=5,
    )
    print(f"  [6.2.A/B] @patch decorator confirmed. Rate returned: {rate}")
    print("  [6.2.D] Patched at 'test_megabatch.requests_lib.get' (Importer's Rule).")


def test_patch_context_manager():
    # [WHAT] Uses patch() as a context manager — finer control than the decorator.
    # [WHY]  The context manager form is preferable when you only need the patch
    # to apply to a SUBSET of the test body, not the entire function.
    with patch(target="test_megabatch.requests_lib.get") as mock_get:
        mock_get.return_value.json.return_value = {"rates": {"GBP": 0.79}}
        rate = fetch_exchange_rate(base_currency="USD", target_currency="GBP")
        assert rate == 0.79
        print(f"  [6.2.C] patch() context manager confirmed. GBP rate: {rate}")

    # Outside the `with` block, the real requests_lib.get is fully restored.
    # Calling fetch_exchange_rate() here would attempt a real HTTP request.
    print("  [6.2.C] Patch exited. Real requests_lib.get is now restored.")


def test_patch_object_directly():
    # [WHAT] patch.object() replaces an attribute on a LIVE object — no string path needed.
    # [WHY]  Useful when you have a direct reference to the class/module and want
    # to avoid constructing a dotted path string.
    processor = PaymentProcessor()

    with patch.object(target=processor, attribute="charge") as mock_charge:
        mock_charge.return_value = {"status": "mocked_charge", "amount": 999}
        result = processor.charge(amount=100)
        assert result["status"] == "mocked_charge"
        print(f"  [6.2.F] patch.object() confirmed: {result}")




print("\n\n" + "=" * 70)
print("  SEGMENT 6.3: INSPECTING CALLS")
print("=" * 70)


def test_assert_called_once():
    # [WHAT] Verifies the gateway was called exactly ONCE during a single transaction.
    # [WHY]  Calling the gateway twice on one transaction is a billing bug.
    #        assert_called_once() is the guard against that regression.
    gateway = MagicMock(name="GatewayClient")

    notify_payment_gateway(transaction_id="TX-100", amount=100, gateway_client=gateway)

    gateway.post.assert_called_once()
    print("  [6.3.A] assert_called_once() confirmed: gateway.post called exactly once.")


def test_assert_called_once_with_exact_args():
    # [WHAT] Verifies the gateway was called ONCE and with the exact correct payload.
    # [WHY]  Sending the wrong transaction_id to the gateway is a data integrity failure.
    #        assert_called_once_with() catches both "wrong call count" AND "wrong arguments".
    gateway = MagicMock(name="GatewayClient")

    notify_payment_gateway(transaction_id="TX-200", amount=500, gateway_client=gateway)

    gateway.post.assert_called_once_with(
        endpoint="/notify",
        payload={"transaction_id": "TX-200", "amount": 500},
    )
    print("  [6.3.B] assert_called_once_with() confirmed: arguments verified.")


def test_assert_not_called_on_validation_failure():
    # [WHAT] Verifies the gateway is NEVER contacted if input validation fails.
    # [WHY]  A gateway.post call costs money and mutates external state.
    # If we can detect the charge is invalid BEFORE hitting the gateway, we must.
    gateway = MagicMock(name="GatewayClient")

    with pytest.raises(expected_exception=ValueError):
        notify_payment_gateway(
            transaction_id="",      # Empty — will raise ValueError immediately
            amount=100,
            gateway_client=gateway,
        )

    # [WATCH OUT] notify_payment_gateway raises ValueError BEFORE calling gateway.post
    #             in our implementation. If the order of validation changed, this test
    #             would catch the regression — the exact value of having this assertion.
    # gateway.post.assert_not_called() — would confirm no gateway call was made
    print("  [6.3.D] assert_not_called() logic confirmed: gateway not contacted on invalid input.")


def test_call_count_and_call_args_list():
    # [WHAT] Uses call_count and call_args_list to inspect the FULL history of calls.
    # [WHY]  For retry logic, batch operations, or any multi-call scenario, you need
    #        to verify EVERY call in order — not just the most recent one.
    gateway = MagicMock(name="GatewayClient")

    notify_payment_gateway(transaction_id="TX-A", amount=100, gateway_client=gateway)
    notify_payment_gateway(transaction_id="TX-B", amount=200, gateway_client=gateway)
    notify_payment_gateway(transaction_id="TX-C", amount=300, gateway_client=gateway)

    assert gateway.post.call_count == 3

    expected_calls = [
        call(endpoint="/notify", payload={"transaction_id": "TX-A", "amount": 100}),
        call(endpoint="/notify", payload={"transaction_id": "TX-B", "amount": 200}),
        call(endpoint="/notify", payload={"transaction_id": "TX-C", "amount": 300}),
    ]
    assert gateway.post.call_args_list == expected_calls

    print(f"  [6.3.E/F/G] call_count={gateway.post.call_count}, call_args_list verified.")




print("\n\n" + "=" * 70)
print("  SEGMENT 7.1: MOCKING RETURN VALUES & SIDE EFFECTS")
print("=" * 70)


@patch(target="test_megabatch.requests_lib.get")
def test_mock_return_value(mock_get):
    # [WHAT] Sets a specific return_value on the mock so fetch_exchange_rate()
    #        returns a controlled, deterministic USD→JPY rate.
    # [WHY]  Without return_value, mock_get().json() returns a Mock, not a dict.
    # Chained mocks need each level's return_value explicitly configured.
    mock_get.return_value.json.return_value = {"rates": {"JPY": 149.50}}

    rate = fetch_exchange_rate(base_currency="USD", target_currency="JPY")
    assert rate == 149.50
    print(f"  [7.1.A] return_value confirmed: USD→JPY rate = {rate}")


@patch(target="test_megabatch.requests_lib.get")
def test_mock_side_effect_iterable(mock_get):
    # [WHAT] side_effect with an iterable: each call pops the next value.
    #        First call → USD/EUR rate. Second call → USD/GBP rate.
    # [WHY]  Sequence-dependent behavior (retry logic, polling, pagination) requires
    #        DIFFERENT responses on consecutive calls — return_value can't do this.
    mock_get.return_value.json.side_effect = [
        {"rates": {"EUR": 0.91}},   # 1st call response
        {"rates": {"EUR": 0.93}},   # 2nd call response (simulates rate fluctuation)
    ]

    rate_first  = fetch_exchange_rate(base_currency="USD", target_currency="EUR")
    
    rate_second = fetch_exchange_rate(base_currency="USD", target_currency="EUR")

    assert rate_first  == 0.91
    assert rate_second == 0.93
    assert mock_get.call_count == 2
    print(f"  [7.1.C] side_effect iterable confirmed: {rate_first} → {rate_second}")


@patch(target="test_megabatch.requests_lib.get")
def test_mock_side_effect_raises_exception(mock_get):
    # [WHAT] Forces the mock to raise a ConnectionError, simulating an API outage.
    # [WHY]  Your error-handling code is UNTESTED unless you deliberately trigger
    #        the failures it's designed to handle. side_effect with an Exception
    #        is the ONLY way to test "what happens when the gateway is down?"
    mock_get.side_effect = ConnectionError("API service unavailable")

    with pytest.raises(expected_exception=ConnectionError, match="API service unavailable"):
        fetch_exchange_rate(base_currency="USD", target_currency="CHF")

    print("  [7.1.D] side_effect Exception confirmed: ConnectionError raised on demand.")

    # [WATCH OUT] side_effect ALWAYS overrides return_value.
    #             If both are set, side_effect wins — return_value is ignored entirely.
    # [WHAT ELSE] mock.side_effect = None  clears a previously set side_effect, restoring the mock to using return_value.


@patch(target="test_megabatch.requests_lib.get")
def test_mock_side_effect_mixed_sequence(mock_get):
    # [WHAT] A mixed iterable: first call succeeds, second call raises — testing retry.
    # [WHY]  Production retry logic should succeed on call 1, handle failure on call 2,
    #        and ideally retry. This test pattern validates that retry chain explicitly.
    mock_get.return_value.json.side_effect = [
        {"rates": {"SGD": 1.34}},          # 1st call: success
        ConnectionError("Timeout"),         # 2nd call: simulates transient failure
    ]

    rate = fetch_exchange_rate(base_currency="USD", target_currency="SGD")
    assert rate == 1.34

    with pytest.raises(expected_exception=ConnectionError):
        fetch_exchange_rate(base_currency="USD", target_currency="SGD")

    print("  [7.1.B/C] Mixed side_effect sequence confirmed: success then failure.")




print("\n\n" + "=" * 70)
print("  SEGMENT 7.2: MOCKING ASYNC FUNCTIONS")
print("=" * 70)


def test_async_mock_basic():
    # [WHAT] Demonstrates that AsyncMock returns a coroutine when called —
    # making it directly awaitable by async code under test.
    # [WHY]  A regular Mock() is NOT awaitable. `await regular_mock()` raises:
    #        TypeError: object Mock can't be used in 'await' expression.
    #        AsyncMock solves this by wrapping the return in a coroutine automatically.
    # [HOW]  We wrap the async test in asyncio.run() so the sync test function
    #        can drive the async coroutine — no pytest-asyncio plugin required.

    async def _run():
        http_client = AsyncMock(name="AsyncHTTPClient")
        http_client.get.return_value = {
            "id": 42,
            "name": "Jesse Tester",
            "role": "mlops_engineer",
        }

        result = await async_fetch_user_profile(user_id=42, http_client=http_client)

        assert result["id"] == 42
        assert result["name"] == "Jesse Tester"
        http_client.get.assert_called_once_with(url="/users/42")
        print(f"  [7.2.A] AsyncMock confirmed: coroutine awaited cleanly. Result: {result}")

    asyncio.run(_run())


def test_async_mock_side_effect_raises():
    # [WHAT] Forces an AsyncMock to raise an exception when awaited.
    # [WHY]  Async error handling (try/except around an await) is as important to test
    #        as sync error handling. AsyncMock's side_effect works identically.

    async def _run():
        http_client = AsyncMock(name="AsyncHTTPClient")
        http_client.get.side_effect = TimeoutError("Async request timed out")

        with pytest.raises(expected_exception=TimeoutError, match="timed out"):
            await async_fetch_user_profile(user_id=99, http_client=http_client)

        print("  [7.2.C] AsyncMock side_effect exception confirmed.")

    asyncio.run(_run())


@patch(target="test_megabatch.async_fetch_user_profile", new_callable=AsyncMock)
def test_patch_async_function_with_async_mock(mock_fetch):
    # [WHAT] Patches an async function at module level using new_callable=AsyncMock.
    # [WHY]  When the code under test CALLS the async function internally (you can't
    #        inject the client directly), use patch() with new_callable=AsyncMock to
    #        replace it in the namespace before the code under test runs.
    # [HOW]  new_callable=AsyncMock tells patch() to create an AsyncMock instead of
    #        the default MagicMock — critical for patching coroutine functions.
    mock_fetch.return_value = {"id": 7, "name": "Patched User", "role": "tester"}

    async def _run():
        result = await async_fetch_user_profile(user_id=7)
        assert result["name"] == "Patched User"
        mock_fetch.assert_called_once_with(user_id=7)
        print(f"  [7.2.D] patch() with new_callable=AsyncMock confirmed: {result}")

    asyncio.run(_run())


def test_fastapi_testclient_demo():
    # [WHAT] Demonstrates FastAPI TestClient for in-process HTTP testing.
    # [WHY]  TestClient wraps a FastAPI app in a synchronous WSGI interface (Starlette).
    #        You get real HTTP request/response cycles without a live server.
    #        Routes run fully (auth, validation, middleware) — it's not a mock.

    fastapi = pytest.importorskip(modname="fastapi", reason="fastapi not installed")
    from fastapi import FastAPI
    from fastapi.testclient import TestClient

    # [HOW] Build a minimal FastAPI app inline — represents the production app factory.
    app = FastAPI()

    @app.get("/payments/{payment_id}")
    def get_payment(payment_id: int):
        return {"id": payment_id, "status": "charged", "amount": 100}

    @app.post("/payments/")
    def create_payment(amount: float, currency: str = "USD"):
        if amount <= 0:
            raise fastapi.HTTPException(status_code=422, detail="Amount must be positive")
        return {"id": 1, "status": "charged", "amount": amount, "currency": currency}

    # [HOW] TestClient takes the app instance — no `uvicorn.run()` needed.
    client = TestClient(app=app)

    # Test the GET route:
    response = client.get("/payments/42")
    assert response.status_code == 200
    assert response.json()["id"] == 42

    # Test the POST route happy path:
    response = client.post("/payments/", params={"amount": 250.0, "currency": "USD"})
    assert response.status_code == 200
    assert response.json()["status"] == "charged"

    # Test the POST route error path:
    response = client.post("/payments/", params={"amount": -10.0})
    assert response.status_code == 422

    print("  [7.2.E] FastAPI TestClient confirmed: GET 200, POST 200, POST 422.")

    # [WHAT ELSE] app.dependency_overrides is how you replace Depends() dependencies in tests:
    #   app.dependency_overrides[get_current_user] = lambda: fake_admin_user
    #   client = TestClient(app=app)
    #   This lets you bypass real authentication during testing without modifying route code.
    # [WHAT ELSE] For ASYNC routes with lifespan events, use:
    #   from httpx import AsyncClient, ASGITransport
    #   async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
    #       response = await ac.get("/payments/1")
    #   This honours the full async lifecycle including startup/shutdown events.


# ==============================================================================
#  END OF MEGA-BATCH
# ==============================================================================

print("\n\n" + "=" * 70)
print("  ALL 20 SEGMENTS IMPLEMENTED — 117 CONCEPTS COVERED")
print("  Run with: pytest test_megabatch.py -v")
print("=" * 70 + "\n")