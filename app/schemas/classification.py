from pydantic import BaseModel, Field


class ClassificationRequest(BaseModel):
    text: str = Field(min_length=1, max_length=12000)
    request_id: str | None = None


class ClassificationMetrics(BaseModel):
    accuracy: float | None = Field(default=None, ge=0.0, le=1.0)
    precision: float | None = Field(default=None, ge=0.0, le=1.0)
    recall: float | None = Field(default=None, ge=0.0, le=1.0)
    f1_score: float | None = Field(default=None, ge=0.0, le=1.0)
    f1: float | None = Field(default=None, ge=0.0, le=1.0)


class ClassificationResult(BaseModel):
    label: str
    score: float = Field(ge=0.0, le=1.0)
    metrics: ClassificationMetrics | None = None
