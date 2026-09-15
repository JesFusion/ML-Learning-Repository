import os
import pytest
import sys
import asyncio
import json
from unittest.mock import (
    Mock,
    MagicMock,
    patch,
    call,
    AsyncMock
)
import requests as requests_lib
from code_to_test import (
    log,
    GLOBAL_DICTIONARY,
    session_creation,
    app_initialization,
    creating_the_engine
)




# ===================================== SEGMENT 3.1: CONFTEST.PY =====================================






@pytest.fixture(
    scope = 'session'
)
def database_engine():

    d_engine = creating_the_engine(url = 'postgresql://localhost/test_db')

    yield d_engine

    d_engine.disposing_the_engine()




@pytest.fixture(scope = 'function')
def database_session(database_engine):
    
    the_session = session_creation(bind = database_engine)

    yield the_session

    the_session.rollback()

    the_session.close()



@pytest.fixture(scope = 'session')
def the_app():

    return app_initialization(configuration = 'testing')




@pytest.fixture(scope = 'session')
def the_client(the_app):

    if True:

        from fastapi.testclient import TestClient

    
    return TestClient(app = the_app)










# ===================================== SEGMENT 3.2: REQUESTING FIXTURES FROM FIXTURES (CHAINING) =====================================

@pytest.fixture(scope = 'module')
def database_engine_fixture():
    data_engine = MagicMock(name = 'DatabaseEngineClass')

    data_engine.url = "postgresql://localhost/test_database"

    data_engine.pool_size = 12

    log.debug("database_engine_fixture CREATED (module scope)")

    yield data_engine

    log.debug("database_engine_fixture DISPOSED (module teardown)")






@pytest.fixture(scope = 'function')
def database_session_fixture(database_engine_fixture):

    data_session = MagicMock(name = 'DatabaseSessionClass')

    data_session.bind = database_engine_fixture # this links the session to the engine

    data_session.is_active = True

    log.debug(f"database_session_fixture CREATED (bound to engine: {database_engine_fixture.url})")

    yield data_session

    data_session.rollback()

    log.debug("database_session_fixture ROLLED BACK and closed")







@pytest.fixture
def fixture_for_payment_repository(database_session_fixture):

    repository = {
        'session': database_session_fixture,

        'FindByID': lambda transaction_id: {
            'id': transaction_id,

            'amount': 637
        }
    }

    return repository












# ===================================== SEGMENT 3.3: AUTOUSE FIXTURES =====================================



"""
The final fixture trick is autouse=True, which tells Pytest to inject a fixture into every test in its scope without being explicitly requested. Think of it as a background service that silently starts before every test.
The canonical use cases: resetting a global state variable before every test, patching the system clock to a fixed timestamp across the entire suite, or injecting a logging context. The power is real — you can enforce invariants globally without polluting every test signature. The danger is equally real: autouse fixtures are invisible. A new engineer reading a test has no indication that something is silently running. Used carelessly, it creates tests that mysteriously pass in isolation but fail when run together because of hidden shared state. Autouse is a power tool. Use it for cross-cutting infrastructure concerns, not business logic.
"""



@pytest.fixture(
    scope = 'function',
    autouse = True
)

def fixture_that_resets_global_state():

    GLOBAL_DICTIONARY['LastTransactionID'] = None

    GLOBAL_DICTIONARY['RequestCount'] = 0

    yield

    # If you only want autouse in a specific class, define the fixture INSIDE the class body. Its scope is then limited to that class's tests






























