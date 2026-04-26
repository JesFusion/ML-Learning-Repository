import os, sys
import asyncio
import json
import pytest
from unittest.mock import (
    Mock,
    MagicMock,
    patch,
    call,
    AsyncMock
)
import requests as requests_lib
from fastapi import FastAPI
from fastapi.testclient import TestClient
from fastapi import HTTPException
from code_to_test import (
    log,
    GLOBAL_DICTIONARY,
    IS_JESSE_COOL,
    exchange_rate_fetching,
    gateway_payment_notification,
    fetch_user_profile_async,
    ErrorFromInsufficientFunds,
    ErrorFromInvalidEmail,
    ClassThatValidatesData,
    PaymentProcessingClass,
)






# ===================================== SEGMENT 1.1: PYTEST INSTALLATION & DISCOVERY =====================================


class TestPytestDemo:

    def test_InsideAClass(self):

        assert (4 + 5) == (10 - 1)



    def test_method_in_class_again(self):

        assert 'jesse' in 'jesse is cool'






def test_naming_convention():

    the_processor = PaymentProcessingClass()

    the_result = the_processor.the_charge(the_amount = 100)

    # assert the_result is not None

    assert isinstance(the_result, dict)





# ===================================== SEGMENT 1.2: BASIC ASSERTIONS =====================================


def test_assertion_on_inequality():
    
    inequality_processor = PaymentProcessingClass()

    output = inequality_processor.the_charge(
        the_amount = 300,
        the_currency = 'EUR'
    )

    assert output['currency'] != 'USD'

    log.debug(f"Equality check passed. Result: {output}")




# def test_assertion_on_


def test_assertion_on_membership():

    membership_processor = PaymentProcessingClass()

    the_result = membership_processor.the_charge(the_amount = 340)

    for x in ['status', 'amount', 'currency']:

        assert x in the_result

    log.debug(f"Membership check passed. Keys present: {list(the_result.keys())}")






def test_assertion_on_comparison():

    comparison_processor = PaymentProcessingClass()

    comparison_result = comparison_processor.the_charge(the_amount = 998)

    the_amount = comparison_result['amount']

    assert the_amount > 0

    assert the_amount<= 10_000

    assert the_amount >= 100


    the_validator = ClassThatValidatesData()


    comparison_summary = the_validator.scores_summarization(
        the_scores = [22, 56, 92, 912, 73]
    )

    assert comparison_summary['avg'] > comparison_summary['min']

    assert comparison_summary['max'] >= comparison_summary['avg']

    log.debug(f"Comparison checks passed. Summary: {comparison_summary}")






def test_assertion_on_truthiness():

    truthiness_validator = ClassThatValidatesData()

    is_it_valid = truthiness_validator.email_validation(the_Email = 'jesfusionprox@gmail.com')

    assert is_it_valid

    assert truthiness_validator.is_it_palindrome(input_text = 'A man a plan a canal Panama')

    assert not truthiness_validator.is_it_palindrome(input_text = 'jessespark')

    assert 0.1 + 0.2 == pytest.approx(expected = 0.3)   


    a = {
        'number': 34.5
    }

    b = {
        'number': 35
    }

    assert b == pytest.approx(a, rel = 2e-2)

    
    assert 2.003 == pytest.approx(expected = 2, rel = 1e-2)

    assert 45.649241 == pytest.approx(expected = 45, rel = 2e-2)

    log.debug("Truthiness checks passed!")






# ===================================== SEGMENT 1.3: HANDLING EXCEPTIONS =====================================



def test_basic_raises():

    raises_processor = PaymentProcessingClass()

    with pytest.raises(expected_exception = ValueError):

        raises_processor.the_charge(the_amount = -0.13)

    with pytest.raises(expected_exception = ErrorFromInsufficientFunds):

        raises_processor.the_charge(the_amount = 1_000_000)

    
    log.debug("pytest.raises(ValueError) & pytest.raises(ErrorFromInsufficientFunds) confirmed: negative and large amount rejected")






def test_match_parameter_raises():

    match_parameter_processor = PaymentProcessingClass()

    with pytest.raises(
        expected_exception = ValueError,
        match = "amount must be positive"
    ):
        
        match_parameter_processor.the_charge(the_amount = -299.99)

    
    log.debug("match = parameter confirmed: error message regex matched")





def test_captures_exception_info_raises():

    exception_info_processor = PaymentProcessingClass()

    with pytest.raises(
        expected_exception = ErrorFromInsufficientFunds
    ) as exception_info:
        
        a = 1_009_345
        
        exception_info_processor.the_charge(the_amount = a)

        assert exception_info.type is ErrorFromInsufficientFunds

        exception_info.match(rf"Amount {a} exceeds single-transaction limit of")

        log.debug(f"ExceptionInfo confirmed: {exception_info.value}")





def test_exception_hierarchy_raises():

    exception_hierachy_validator = ClassThatValidatesData()


    with pytest.raises(ValueError):

        exception_hierachy_validator.email_validation(the_Email = 'jesseiscool')

    
    log.debug("Exception hierarchy confirmed: ErrorFromInvalidEmail caught as ValueError")










# ===================================== SEGMENT 2.1: INTRODUCTION TO FIXTURES =====================================



@pytest.fixture
def fixture_for_processing_payments():

    return PaymentProcessingClass()



@pytest.fixture
def fixture_that_validates_data():

    return ClassThatValidatesData()




@pytest.fixture
def fixture_that_provides_sample_transactions_data():

    data = [
        {
            "amount": 812, 
            "currency": "USD"
        },

        {
            "amount": 258,
            "currency": "EUR"
        },

        {
            "amount": 369,  
            "currency": "GBP"
        },
    ]

    return data




def test_basic_fixture_injection(fixture_for_processing_payments):

    the_payment_processor = fixture_for_processing_payments
    
    output = the_payment_processor.the_charge(the_amount = 981)

    assert output['status'] == 'charged'

    log.debug(f"Fixture injected. Result: {output}")






def test_duplication_elimination_fixture(fixture_for_processing_payments, fixture_that_validates_data):

    payment_processor = fixture_for_processing_payments

    data_validator = fixture_that_validates_data


    result_from_charge = payment_processor.the_charge(the_amount = 400)

    email_validation = data_validator.email_validation(the_Email = 'workemailaddress73@gmail.com')


    assert result_from_charge['amount'] == 400

    assert email_validation is True

    log.debug("Confirmed! Two fixtures resolved independently")






def test_request_object_fixture():

    pass






@pytest.fixture
def fixture_for_request_awareness(request):

    log.debug(f"Fixture called by test: {request.node.name}")

    output = f"context_for_{request.node.name}"

    return output






def test_using_fixture_for_request_awareness(fixture_for_request_awareness):

    assert 'context_for_' in fixture_for_request_awareness








# ===================================== SEGMENT 2.2: SETUP AND TEARDOWN (YIELD) =====================================



@pytest.fixture
def temporary_report_file_creator_fixture(tmp_path):

    report_file_path = tmp_path / 'the_payment_report.json'

    the_report_data = {
        "batchID": "TX-001",
        "total": 712,
        "currency": "USD"
    }

    report_file_path.write_text(
        data = json.dumps(the_report_data),

        encoding = 'utf-8'
    )

    log.debug(f"SETUP: Created temp report at {report_file_path}")


    yield report_file_path


    if report_file_path.exists():

        report_file_path.unlink()

        log.debug(f"TEARDOWN: Deleted temp report at {report_file_path}")








def test_file_creator_fixture_with_yield(temporary_report_file_creator_fixture):

    temp_file = temporary_report_file_creator_fixture

    assert temp_file.exists()

    file_content = json.loads(temp_file.read_text(encoding = 'utf-8'))

    assert file_content['batchID'] == 'TX-001'

    assert file_content['total'] == 712

    log.debug(f"Yield fixture confirmed. File content: {file_content}")






@pytest.fixture
def processor_fixture_with_audit_log():

    audit_log_list = []

    the_processor = PaymentProcessingClass()

    the_original_charge = the_processor.the_charge

    def charge_instrumented(
        _amount,
        currency_ = 'USD'
    ):
        
        output = the_original_charge(
            the_amount = _amount,
            
            the_currency = currency_
        )

        audit_log_list.append({
            'amount': _amount,
            'currency': currency_
        })

        return output

    the_processor.the_charge = charge_instrumented

    yield the_processor, audit_log_list

    log.debug(f"TEARDOWN: Audit log had {len(audit_log_list)} entries.\nclearing...")

    audit_log_list.clear()






def test_processor_fixture_with_teardown(processor_fixture_with_audit_log):

    PROCESSOR, AuditLog = processor_fixture_with_audit_log

    PROCESSOR.the_charge(_amount = 231)

    PROCESSOR.the_charge(_amount = 912, currency_ = 'NGN')

    assert len(AuditLog) == 2

    assert AuditLog[0]['amount'] == 231

    log.debug(f"Teardown guarantee confirmed. Audit log: {AuditLog}")










# ===================================== SEGMENT 2.3: FIXTURE SCOPES =====================================


@pytest.fixture(
    scope = 'module'
)
def fixture_that_shares_processor_pool():

    log.debug("MODULE-SCOPE SETUP: Simulating expensive connection pool creation...")

    POOL = {
        'pool ID': 'POOL-213',
        'the_processor': PaymentProcessingClass(),
        'maximum connections': 50
    }

    yield POOL

    log.debug("MODULE-SCOPE TEARDOWN: Closing connection pool...")



@pytest.fixture(
    scope = 'session'
)
def global_config_fixture():

    log.debug("SESSION-SCOPE SETUP: Loading global configuration...")

    configuration = {
        'environment': 'test_verification',
        "api version": "v-O1-1.1.3",
        "maximum retries": 12,
    }

    yield configuration

    log.debug("SESSION-SCOPE TEARDOWN: Releasing global config.")






def test_fixture_that_shares_processor_pool(fixture_that_shares_processor_pool):

    assert fixture_that_shares_processor_pool['pool ID'] == 'POOL-213'

    output = fixture_that_shares_processor_pool['the_processor'].the_charge(the_amount = 521)

    assert output['status'] == 'charged'
    
    log.debug("Module-scope fixture confirmed (first call).")





def test_fixture_that_shares_processor_pool_2(fixture_that_shares_processor_pool): # The fixture was NOT re-created. Setup cost was paid exactly once

    assert fixture_that_shares_processor_pool['maximum connections'] == 50

    log.debug("Module-scope fixture confirmed (second call; no re-setup)")




def test_global_config_fixture(global_config_fixture):

    keys = ['environment', 'api version', 'maximum retries']

    values = ['test_verification', 'v-O1-1.1.3', 12]

    for x in range(len(keys)):

        assert global_config_fixture[keys[x]] == values[x]

    







def test_the_explanation_of_conftest():

    temporary_path = os.path.join("/home/jesfusion/Documents/ml/ML-Learning-Repository/Pytest/", "conftest.py")

    with open(temporary_path, "r", encoding = 'utf-8') as the_file:

        conftest_py_file = the_file.read()

    assert 'pytest.fixture' in conftest_py_file

    assert 'scope = ' in conftest_py_file






"""
===================================== PYTEST PROJECT STRUCTURE =====================================


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
"""








def test_the_chain_of_fixtures(
    fixture_for_payment_repository,
    database_session_fixture,
    database_engine_fixture
):
    
    assert fixture_for_payment_repository['session'] is database_session_fixture

    assert database_session_fixture.bind is database_engine_fixture

    assert database_engine_fixture.url == "postgresql://localhost/test_database"

    transaction = fixture_for_payment_repository['FindByID']("TX-1.2-0")

    assert transaction['amount'] == 637

    log.debug("""
Dependency chain confirmed!

database_engine_fixture → database_session_fixture → fixture_for_payment_repository

Teardown will execute in REVERSE order: repository → session → engine
""")
    






def test_global_dictionary_modification():

    GLOBAL_DICTIONARY['LastTransactionID'] = 'Trs-2.3.1'

    GLOBAL_DICTIONARY['RequestCount'] = 432

    assert GLOBAL_DICTIONARY['LastTransactionID'] == 'Trs-2.3.1'

    log.debug(f"State mutated: {GLOBAL_DICTIONARY}")



def test_fixture_that_resets_global_state_resetting_power():

    assert GLOBAL_DICTIONARY['LastTransactionID'] is None

    assert GLOBAL_DICTIONARY['RequestCount'] == 0

    log.debug(f"State reset confirmed by autouse fixture: {GLOBAL_DICTIONARY}")











# ===================================== SEGMENT 4.1: @pytest.mark.parametrize DECORATOR =====================================


@pytest.mark.parametrize(
    argnames = 'the_email, ShouldRaise',

    argvalues = [
        ('jesse@mlops.io', False),

        ("user@domain.com", False),

        ('', True),

        (None, True),

        ('bad-email-format', True),

        ("emailwithout@adot", True),
        
        ("@cooldomain.com", False),
        
        ('jesseis+1@today.com', False),
    ],
)

def test_parametrized_email_validation(the_email, ShouldRaise):

    the_validator = ClassThatValidatesData()

    if ShouldRaise:

        with pytest.raises(
            expected_exception = (ErrorFromInvalidEmail, ValueError)
        ):
            
            the_validator.email_validation(the_Email = the_email)

    else:

        assert the_validator.email_validation(the_Email = the_email) is True

    log.debug(f"Tested: {repr(the_email)} → raises = {ShouldRaise}")








@pytest.mark.parametrize(
    argnames = 'price_of_good, percentage_discount, expected_price',

    argvalues=[
        (100.0, 0, 100.0),
        (100.0, 10, 90.0),
        (200.0, 25, 150.0),
        (99.99, 50, 50.0),
        (100.0, 100, 0.0),
        (50.0, 10, 45.0),
        (80.0, 20, 64.0),
        (150.0, 30, 105.0),
        (300.0, 15, 255.0),
        (10.0, 5, 9.5),
        (1000.0, 1, 990.0),
        (40.0, 40, 24.0),
        (60.0, 60, 24.0),
        (500.0, 75, 125.0),
        (25.0, 10, 22.5),
        (19.99, 0, 19.99),
        (120.0, 50, 60.0),
        (85.0, 10, 76.5),
        (250.0, 20, 200.0),
        (45.0, 100, 0.0),
        (10.0, 50, 5.0),
        (90.0, 10, 81.0),
        (15.0, 20, 12.0),
        (2000.0, 5, 1900.0),
        (1.0, 10, 0.9)
    ],
)




def test_parametrized_discount_calculation(
    price_of_good,
    percentage_discount,
    expected_price,
    fixture_that_validates_data
):
    
    output = fixture_that_validates_data.calculating_the_discount(
        price = price_of_good,
        discount_pct = percentage_discount
    )

    assert output == pytest.approx(
        expected = expected_price,
        rel = 1e-2
    )

    log.debug(f"{price_of_good} - {percentage_discount}% = {output} (expected {expected_price})")














# ===================================== SEGMENT 4.2: STACKING PARAMETRIZATION (CARTESIAN PRODUCTS) =====================================


@pytest.mark.parametrize(
    argnames = 'TheCurrency',

    argvalues = ['USD', 'NGN', 'EUR', "GBP"]
)



@pytest.mark.parametrize(
    argnames = 'money_amount',

    argvalues = [300, 4500, 5320]
)




def test_all_currency_amount_combinations(TheCurrency, money_amount):

    currency_combination_processor = PaymentProcessingClass()

    the_result = currency_combination_processor.the_charge(
        the_amount = money_amount,

        the_currency = TheCurrency
    )

    keys = ['status', 'amount', 'currency']

    values = ['charged', money_amount, TheCurrency]

    for x in range(len(keys)):

        assert the_result[keys[x]] == values[x]

    log.debug(f"Cartesian case: amount = {money_amount}, currency = {TheCurrency}")











# ===================================== SEGMENT 4.3: DYNAMIC IDs =====================================




@pytest.mark.parametrize(
    argnames = 'TheAmount, Error, Description',

    argvalues = [
        # pytest.param(*values, id="description")

        pytest.param(
            231, None, 'Valid Amount value',

            id = 'Valid amount value'
        ),

        pytest.param(
            0, ValueError, 'Zero Amount. Should be rejected',

            id = 'Zero amount. Should be rejected'
        ),

        pytest.param(
            -1, ValueError, 'Negative Amount. Should be rejected',

            id = 'Negative Amount. Should be rejected'
        ),

        pytest.param(
            23456, ErrorFromInsufficientFunds, 'Amount higher than set limit',

            id = "Amount higher than set limit"
        )
    ]
)







def test_charge_functions_with_parametrized_dynamic_IDs(
    TheAmount,
    Error,
    Description
):
    
    dynamic_id_processor = PaymentProcessingClass()

    if Error is None:

        output = dynamic_id_processor.the_charge(
            the_amount = TheAmount
        )

        assert output['status'] == 'charged'

    else:

        with pytest.raises(expected_exception = Error):

            dynamic_id_processor.the_charge(the_amount = TheAmount)

    log.debug(f"Dynamic ID case '{Description}' passed")
















# ===================================== SEGMENT 5.1: BUILT-IN MARKERS (skip, skipif, xfail) =====================================


# skipping a test...
@pytest.mark.skip(
    reason = 'Placeholder: FX rate API credentials not yet configured in CI'
)


def test_live_exchange_rate_fetching():

    output = exchange_rate_fetching(
        Bcurrency = 'USD',
        Tcurrency = 'EUR'
    )

    assert output > 0








# skipping a test if a condition is met...

@pytest.mark.skipif(
    condition = sys.platform == 'win32',
    # condition = sys.platform == 'linux',

    reason = "File path handling test is Unix-specific; skipped on Windows"
)


def test_file_path_handling_on_unix(tmp_path):

    unix_file_path = tmp_path / 'reports' / 'log_output.json'

    unix_file_path.parent.mkdir(
        parents = True,
        exist_ok  = True
    )

    unix_file_path.write_text(
        data = '{"status": "ok"}',

        encoding = 'utf-8'
    )

    assert unix_file_path.exists()

    log.debug(f"Unix path test passed on {sys.platform}")







# this test is expected to fail...


@pytest.mark.xfail(
    # Reports 'x' (xfailed) when it fails, 'X' (xpassed) if it suddenly passes which is a signal to remove the mark.

    reason = 'IS_JESSE_COOL() function is meant to return "True"',

    strict = False
)


def test_xfail_capabilities():

    assert IS_JESSE_COOL() is True

    log.debug("xfail test ran successfully!")





@pytest.mark.xfail(
    raises = ErrorFromInsufficientFunds,

    reason = 'Refund above limit should trigger ErrorFromInsufficientFunds; behavior TBD',

    strict = False
)




def test_xfail_with_raises():

    xfail_with_raises_processor = PaymentProcessingClass()

    xfail_with_raises_processor.refund_money(
        transactionID = 'TX-023',
        the_amount = 89322
    )

    log.debug("xfail with raises = filter confirmed")













# ===================================== SEGMENT 5.2: CUSTOM MARKERS =====================================



@pytest.mark.slow
def test_batch_processing_slow_fixture(
    fixture_for_processing_payments,
    fixture_that_provides_sample_transactions_data
):
    
    the_payment_processor = fixture_for_processing_payments

    output = the_payment_processor.batch_processing(
        the_transactions = fixture_that_provides_sample_transactions_data
    )

    assert len(output) == 3

    assert all(x['status'] == 'charged' for x in output)

    log.debug(f"@slow test passed. {len(output)} transactions processed")








@pytest.mark.integration
def test_integration_custom_marker(fixture_for_processing_payments):

    CHARGE = fixture_for_processing_payments.the_charge(the_amount = 431)

    refund_receipt = fixture_for_processing_payments.refund_money(
        the_amount = CHARGE['amount'],

        transactionID = 'TX-891'
    )

    assert refund_receipt['status'] == 'refunded'

    assert refund_receipt['amount'] == 431

    log.debug(f"@integration test passed. Refund: {refund_receipt}")






@pytest.mark.slow
@pytest.mark.parametrize(
    argnames = 'input_value',

    argvalues = [
        pytest.param(
            320,
            id = 'valid number: 320'
        ),

        pytest.param(
            -32019,
            id = 'invalid number: -32019'
        ),

        pytest.param(
            -23,
            id = 'invalid number: -23',
            marks = pytest.mark.xfail
        )
    ]
)



def test_slow_and_parametrize_markers(input_value):

    slow_and_parametrize_processor = PaymentProcessingClass()

    if input_value < -24:

        with pytest.raises(
            expected_exception = ValueError,

            match = 'Charge amount must be positive'
        ):
            
            output = slow_and_parametrize_processor.the_charge(the_amount = input_value)

    else:

        output = slow_and_parametrize_processor.the_charge(the_amount = input_value)

        assert output['status'] == 'charged'

    log.debug(f"Parametrized case with per-case mark passed: amount = {input_value}")














# ===================================== SEGMENT 5.3: PYTEST.INI/PYPROJECT.TOML CONFIGURATION =====================================


"""
# Main entry point for pytest configuration in pyproject.toml
[tool.pytest.ini_options]


# Default CLI flags:
# -v: verbose output
# -s: allow print statements to show in console (shortcut for --capture=no)
# -m 'code_to_run': ONLY runs tests with this marker by default (be careful!)
# --tb=short: shows only a one-line traceback for failures
# --strict-markers: errors out if you use a marker not registered below

# because you included -m 'code_to_run' in addopts, pytest will only run tests with that marker every time you type the pytest command

# If you try to run a different test or a different marker, it will likely result in "No tests ran."

addopts = "-vsm 'code_to_run' --tb=short --strict-markers" 

# Tells pytest to only look inside this specific file for tests
testpaths = ["test_functions.py"]

# Registered markers to prevent "Unknown mark" warnings
markers = [
    "code_to_run: specific tests I want to run (Segment 6.1 and below)",

    "slow: Tests that make real network calls or process large datasets (>1s)",

    "integration: Tests that require live service infrastructure (DB, Redis, S3)",

    "gpu: Tests that require a CUDA-capable GPU to run",
    "flaky: Tests known to be non-deterministic: quarantined for investigation"
]

"""







def test_jesse():

    log.debug("Jesse is cool")

    assert True

    log.debug("Jesse is so cool")
















# ===================================== SEGMENT 6.1: THE unittest.mock LIBRARY =====================================






def test_unittest_mock():

    outlet = Mock(
        name = 'GatewayForPayment'
    )

    output = outlet.post(
        endpoint = '/charge',

        payload = {
            'amount': 521
        }
    )

    assert outlet.post.called

    assert outlet.post.call_count == 1

    log.info(f"Mock.post called: {outlet.post.called}, count: {outlet.post.call_count}")








def test_MagicMock():

    mock_file = MagicMock(
        name = 'FileHandler'
    )

    with mock_file as mock_handler:

        mock_handler.write(b"payment data")

    
    mock_file.__enter__.assert_called_once()

    mock_file.__exit__.assert_called_once()

    log.info("MagicMock __enter__/__exit__ confirmed: context manager protocol works")










def test_isolation_speed_cost_of_mocking(tmp_path):

    outlet = MagicMock(name = 'FakeGateway')

    outlet.charge.return_value = {
        'gateway_ref': 'GW-925',

        'approved': False
    }

    output = gateway_payment_notification(
        transID = 'TX-301',

        the_amount = 891,

        the_gateway_client = outlet
    )

    assert output is True

    outlet.post.assert_called_once()

    log.info("Isolation confirmed: gateway called without real network")
















# ===================================== SEGMENT 6.2: PATCHING — THE ART OF REPLACEMENT =====================================




@patch(
    target = 'test_functions.requests_lib.get'
)

def test_the_patch_decorator(mock_acquisition):

    output_data = {
        'rates': {
            'EUR': 0.2578
        }
    }

    mock_acquisition.return_value.json.return_value = output_data

    the_rate = exchange_rate_fetching(
        Bcurrency = 'USD',

        Tcurrency = 'EUR'
    )

    assert the_rate == 0.2578

    mock_acquisition.assert_called_once_with(
        url = 'https://api.exchangerate.host/latest',

        params = {
            'base': 'USD',

            'symbols': 'EUR'
        },

        timeout = 5
    )

    log.info(f"@patch decorator confirmed. Rate returned: {the_rate}. Patched at 'test_megabatch.requests_lib.get' (Importer's Rule)")








def test_the_context_management_abilities_of_patch():

    with patch(
        target = 'test_functions.requests_lib.get'
    ) as get_the_mock:
        
        get_the_mock.return_value.json.return_value = {
            'rates': {
                'GBP': 0.79
            }
        }

        the_rate = exchange_rate_fetching(
            Bcurrency = 'USD',
            Tcurrency = 'GBP'
        )

        assert the_rate == 0.79

        log.info(f"patch() context manager confirmed. GBP rate: {the_rate}")

        log.info('Patch exited. Real requests_lib.get is now restored')








def test_direct_patch_object():

    direct_patch_object_processor = PaymentProcessingClass()

    with patch.object(
        target = direct_patch_object_processor,

        attribute = 'the_charge'
    ) as the_mock_charge:
        
        the_mock_charge.return_value = {
            'operation': 'charge that was mocked!',

            'amount': 819
        }

        output = direct_patch_object_processor.the_charge(the_amount = 587)

        # assert output['operation'] == 'charge that was mocked!'

        assert 'mocked' in output['operation']

        log.info(f"patch.object() confirmed: {output}")


















# ===================================== SEGMENT 6.3: INSPECTING CALLS =====================================




def test_the_verification_of_assert_being_called_once():

    the_gate = MagicMock(name = 'TheClientGateway')

    gateway_payment_notification(
        transID = 'TX-482',
        the_amount = 925,
        the_gateway_client = the_gate
    )

    the_gate.post.assert_called_once()

    log.info('assert_called_once() confirmed: gateway.post called exactly once')










def test_assertion_being_called_once_with_exact_arguments():

    the_gateway = MagicMock(name = "TheClientGateway")

    t = 'TX-839'

    gateway_payment_notification(
        transID = t,

        the_amount = 219,

        the_gateway_client = the_gateway
    )

    the_gateway.post.assert_called_once_with(
        endpoint = '/notify',

        payload = {
            'transaction_id': t,
            "amount": 219
        }
    )

    log.info('assert_called_once_with() confirmed: arguments verified')











def test_that_assertion_is_not_called_on_the_event_of_a_validation_failure():

    the_gateway = MagicMock(name = "TheClientGateway")

    with pytest.raises(
        expected_exception = ValueError
    ):
        
        gateway_payment_notification(
            transID = '',

            the_amount = 462,

            the_gateway_client = the_gateway
        )
    
    the_gateway.post.assert_not_called()

    log.info('assert_not_called() logic confirmed: gateway not contacted on invalid input')
















def test_the_call_count_and_call_argument_list():

    the_gateway = MagicMock(name = 'TheClientGateway')

    call_times = 12

    for loop in range(call_times):

        gateway_payment_notification(
            transID = f"TX-{(loop * 23) + 45}",

            the_amount = (loop * 5) ** 2,

            the_gateway_client = the_gateway
        )

    
    assert the_gateway.post.call_count == call_times

    expected_calls_list = []

    for x_call in range(call_times):
        
        a_call = call(
            endpoint = '/notify',

            payload = {
                'transaction_id': f"TX-{(x_call * 23) + 45}",

                "amount": (x_call * 5) ** 2
            }
        )

        expected_calls_list.append(a_call)

    
    assert the_gateway.post.call_args_list == expected_calls_list

    log.info(f"""
call_count = {the_gateway.post.call_count}

call_args_list = {(the_gateway.post.call_args_list)[:3]}
    
call_args_list verified
""")

















# ===================================== SEGMENT 7.1: MOCKING RETURN VALUES & SIDE EFFECTS =====================================





@patch(
    target = 'test_functions.requests_lib.get'
)
def test_the_value_from_mock_return(fake_data_mock):
    
    fake_data_mock.return_value.json.return_value = {
        'rates': {
            'JPY': 156.89
        }
    }

    output_rate = exchange_rate_fetching(
        Bcurrency = 'USD',
        Tcurrency = 'JPY'
    )

    assert output_rate == 156.89

    log.info(f'return_value confirmed: USD → JPY rate = {output_rate}')








@patch(
    target = 'test_functions.requests_lib.get'
)
def test_iterable_side_effect_of_mock(mock):

    value_list = [.97, .32, 1.320]

    mock.return_value.json.side_effect = [
        {
            'rates': {
                'EUR': value_list[0]
            }
        },

        {
            'rates': {
                'EUR': value_list[1]
            }
        },

        {
            'rates': {
                'NGN': value_list[2]
            }
        }
    ]


    first_rate = exchange_rate_fetching(
        Tcurrency = 'EUR',
        Bcurrency = 'NGN'
    )

    second_rate = exchange_rate_fetching(
        Bcurrency = 'GHN',
        Tcurrency = 'EUR'
    )

    third_rate = exchange_rate_fetching(
        Bcurrency = 'USD',
        Tcurrency= 'NGN'
    )

    rates = [first_rate, second_rate, third_rate]

    
    for x in range(len(rates)):

        assert rates[x] == value_list[x]

    
    assert mock.call_count == len(rates)

    log.info(f'side_effect iterable confirmed: {first_rate} → {second_rate}')














@patch(
    target = "test_functions.requests_lib.get" 
)
def test_raises_exception_mock_side_effect(the_mock):

    the_mock.side_effect = ConnectionError('The API service is unavailable')

    with pytest.raises(
        expected_exception = ConnectionError,

        match = 'service is unavailable'
    ):
        
        exchange_rate_fetching(
            Bcurrency = 'USD',
            Tcurrency = 'NGN'
        )

    log.info('ide_effect Exception confirmed: ConnectionError raised on demand')

    # mock.side_effect = None  clears a previously set side_effect, restoring the mock to using return_value












@patch(
    target = 'test_functions.requests_lib.get'
)
def test_mixed_sequence_format_of_mock_side_effect(jesse_mock):

    increment_values = [
        {
            'rates': {
                'EUR': 1.95
            }
        },

        RuntimeError('Time limit reached!'),

        {
            'rates': {
                'NGN': 0.87
            }
        },
    ]

    jesse_mock.return_value.json.side_effect = increment_values


    first_rate = exchange_rate_fetching(
        Bcurrency = 'USD',

        Tcurrency = 'EUR'
    )

    assert first_rate == increment_values[0]['rates']['EUR']


    with pytest.raises(
        expected_exception = RuntimeError
    ):
        
        exchange_rate_fetching(
            Bcurrency = 'USD',
            Tcurrency = 'GHN'
        )

    
    second_rate = exchange_rate_fetching(
        Bcurrency = 'EUR',

        Tcurrency = 'NGN'
    )


    assert second_rate == increment_values[2]['rates']['NGN']


    log.info('Mixed side_effect sequence confirmed: success then failure then success again')
    
















# ===================================== SEGMENT 7.2: MOCKING ASYNC FUNCTIONS =====================================




def test_async_functions():

    async def async_function_inside_test_function():

        HTTPCLEINT = AsyncMock(
            name = 'AsyncHTTPClientMock'
        )

        output = {
            'id': 'TX-3372',

            'name': 'Jesse the Tester',

            'role': "MLOps Engineer"
        }

        HTTPCLEINT.get.return_value = output

        the_result = await fetch_user_profile_async(
            uID = output['id'],

            HTTP_clt = HTTPCLEINT
        )

        log.info(the_result)

        
        assert the_result['id'] == output['id']

        assert the_result['name'] == output['name']

        HTTPCLEINT.get.assert_called_once_with(
            url = f"/users/{output['id']}"
        )

        log.info(f'AsyncMock confirmed: coroutine awaited cleanly. Result: {the_result}')

    
    asyncio.run(main = async_function_inside_test_function())

















@pytest.mark.asyncio
async def test_side_effect_of_async_mock_raises():

    the_http_client = AsyncMock(name = 'TheAsyncHTTPClient')

    the_http_client.get.side_effect = TimeoutError('Async request timed out')

    with pytest.raises(expected_exception = TimeoutError,
    match = 'timed out'):
        await fetch_user_profile_async(uID = 34,
        HTTP_clt = the_http_client)

    log.info(msg = "AsyncMock side_effect exception confirmed")

















@pytest.mark.asyncio
@patch(
    target = 'test_functions.fetch_user_profile_async',
    new_callable = AsyncMock
)
async def test_async_function_patching_with_async_mock(async_mock_fetch):
    #... [HOW]  new_callable=AsyncMock tells patch() to create an AsyncMock instead of
    #...        the default MagicMock — critical for patching coroutine functions.
    # mock_fetch.return_value = {"id": 7, "name": "Patched User", "role": "tester"}

    async_mock_fetch.return_value = {
        'id': 6,
        'name': 'Patched Async User',
        'role': 'code tester'
    }

    output = await fetch_user_profile_async(uID = 6)

    assert output['name'] == 'Patched Async User'

    async_mock_fetch.assert_called_once_with(uID = 6)

    log.info(msg = f'@patch() with new_callable = AsyncMock confirmed: {output}')
















@pytest.mark.jesse
def test_demo_of_FastAPI_TestClient():
    
    f_api = pytest.importorskip(
        modname = 'fastapi', 
        reason = 'fastapi module may not be installed'
    )

    f_app = FastAPI()    

    @f_app.get(path = '/payments/{payment_id}')
    def extract_payment(payment_id: int):

        output = {
            'id': payment_id,
            'status': 'charged',
            'amount': 463
        }

        return output

    @f_app.post(path = '/payments/')
    def payment_creation(
        the_amount: float,
        the_currency: str = 'USD'
    ):
        if the_amount <= 0:
            raise HTTPException(status_code = 422, detail = "Amount must be positive")
        
        output = {
            'id': 1, 
            'status': 'charged', 
            'amount': the_amount,
            'currency': the_currency
        }
        
        return output

    the_client = TestClient(app = f_app)

    get_response = the_client.get('/payments/681')

    assert get_response.status_code == 200

    assert get_response.json()['id'] == 681

    post_response = the_client.post(url = '/payments/', 
    params = {
        'the_amount': 561,
        'the_currency': 'NGN'
    })

    assert post_response.status_code == 200

    assert post_response.json()['status'] == 'charged'

    post_error_response = the_client.post(
        '/payments/',
        params = {
            'amount': -10.0
        }
    )

    assert post_error_response.status_code == 422

    log.info(msg = 'FastAPI TestClient confirmed: GET 200, POST 200, POST 422')



