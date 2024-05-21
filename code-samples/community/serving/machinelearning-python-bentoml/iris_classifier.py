import numpy as np
import bentoml
from pydantic import Field
from bentoml.validators import Shape
from typing_extensions import Annotated
import joblib


@bentoml.service
class IrisClassifier:
    iris_model = bentoml.models.get("iris_sklearn:latest")

    def __init__(self):
        self.model = joblib.load(self.iris_model.path_of("model.pkl"))

    @bentoml.api
    def predict(
        self,
        df: Annotated[np.ndarray, Shape((-1, 4))] = Field(
            default=[[5.2, 2.3, 5.0, 0.7]]
        ),
    ) -> np.ndarray:
        return self.artifacts.model.predict(df)
