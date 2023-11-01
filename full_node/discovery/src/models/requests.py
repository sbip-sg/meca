from common.models.credential import CredentialModel
from models.did import DIDModel
from pydantic import Field


class AuthenticationRequest(CredentialModel, DIDModel):
    pass


class OffloadRequest(DIDModel):
    task_id: str = Field(..., example="001")
    container_reference: str = Field(..., example="sampleserver:latest")
    content: str = Field(..., example='{\"name\": \"meca dev\"}')
    resource: dict = Field(None, example='{"cpu": 2, "memory": 256}')
    runtime: str = Field(None, example="microVM")


class PollResultRequest(DIDModel):
    correlation_id: str
