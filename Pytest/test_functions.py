import pytest
import time
import logging
from fastapi.testclient import TestClient
import asyncio
import uvicorn
from contextlib import asynccontextmanager
from typing import Optional
from fastapi.responses import JSONResponse
from fastapi import (
    FastAPI,
    Request,
    Response
)

from FastAPI.script_1 import(
    log, sc200,
    jesse_api
)




client_user = TestClient(jesse_api)


# @pytest.mark.run_this_code
def test_injection_to_lifespan_state():

    with TestClient(jesse_api) as client_lifecycle:

        current_state = client_lifecycle.app.state.startup_data

        assert current_state['db'] == "Connected"

        assert current_state['workers'] == 6

        assert "cache" in current_state




# @pytest.mark.run_this_code
def test_context_of_execution():

    # testing sync endpoint
    sync_output = client_user.get("/endpoint-syncing")

    assert sync_output.status_code == sc200

    assert sync_output.json()["does_it_block_event_loop?"] is True


    # testing async endpoint

    async_output = client_user.get("/endpoint-asyncing")

    assert async_output.status_code == (321 - 121)

    assert async_output.json()["message"] == "I am asyncing cooly"





# @pytest.mark.run_this_code
def test_metadata_of_custom_response():

    the_response = client_user.get("/random-response")

    assert the_response.status_code == 400

    assert the_response.headers["X-Random-Header"] == "MyValue"
    
    assert the_response.headers["X-Generated-From"] == "FastAPI-Learning"

    assert the_response.text == "Random Response Body"






# @pytest.mark.run_this_code
def test_body_of_request_and_inspection():

    request_payload = {
        "test": "data",

        "priority": "high"
    }

    output_response = client_user.post(
        "/request-inspection?inspect_able=very_able",

        json = request_payload    
    )

    output_data = output_response.json()

    assert output_data["method"] == "POST"

    assert output_data["path"] == "/request-inspection"

    assert output_data["query_params"]["inspect_able"] == "very_able"

    assert output_data["length_of_body_bytes"] > 30







# @pytest.mark.run_this_code
def test_safe_executor_blocking():

    the_response = client_user.get("/safe-blocking")

    assert the_response.status_code == sc200

    assert "successfully wasted time?" in the_response.json()






# @pytest.mark.run_this_code
def test_lifecycle_of_resource_rest():

    # GET
    sending_get_request = client_user.get("/the_resource/20")

    assert sending_get_request.json()["action"] == "GET"

    
    # POST
    sending_post_request = client_user.post("/the_resource")

    assert sending_post_request.status_code == (sc200 + 1)


    # PUT
    sending_put_request = client_user.put("/the_resource/20")

    put_request_output = sending_put_request.json()

    assert put_request_output["action"] == "PUT"


    # PATCH
    sending_patch_request = client_user.patch("/the_resource/2026")

    patch_request_output = sending_patch_request.json()

    assert patch_request_output["resource_id"] == 2026

    assert patch_request_output["action"] == "PATCH"


    # DELETE

    del_request = client_user.delete("/the_resource/200")
    
    del_request_output = del_request.json()

    assert del_request_output["action"] == "DELETE"

    assert del_request_output["resource_id"] == sc200

    assert del_request.status_code == (sc200 + 4)


    





# @pytest.mark.run_this_code
def test_event_loop_blocking():

    begin = time.perf_counter()

    api_response = client_user.get("/block-event-loop")

    end = time.perf_counter()

    assert api_response.status_code == sc200

    # log.info(f"FastAPI/fastAPI_test == {(end - begin)}")

    assert (end - begin) >= 1.56








# @pytest.mark.run_this_code
def test_checking_of_the_health():

    api_response_to_client = client_user.get("/check-health")

    assert api_response_to_client.status_code == 200

    assert api_response_to_client.json() == {
        'status': 'healthy',

        'service': "jesse-practice"
    }






































































































































































































































































































































































































































































































































