from pydantic import BaseModel, Field, validator


class Resources(BaseModel):
    cpu: int = Field(default=1, example=2, gt=0)
    memory: int = Field(default=128, example=256, gt=0)


class TaskResultModel(BaseModel):
    id: str = Field(default="0", example="001", min_length=1, max_length=255)
    content: str = Field(default="", example="Hello World")
    resource_consumed: Resources = Field(default=Resources())
    transaction_start_datetime: int = Field(default=0, example=1694563200, ge=0)
    transaction_end_datetime: int = Field(default=0, example=1694649600, ge=0)
    duration: int = Field(default=0, example=1, ge=0)

    @validator("transaction_end_datetime")
    def validate_transaction_end_datetime(cls, value, values):
        if (
            "transaction_start_datetime" in values
            and value < values["transaction_start_datetime"]
        ):
            raise ValueError(
                "Transaction end datetime must be greater than or equal to the start datetime"
            )
        return value
