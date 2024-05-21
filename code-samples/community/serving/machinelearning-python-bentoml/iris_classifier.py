import bentoml
import joblib


@bentoml.service
class IrisClassifier:
    iris_model = bentoml.models.get("iris_sklearn:latest")

    def __init__(self):
        self.model = joblib.load(self.iris_model.path_of("model.pkl"))

    @bentoml.api
    def predict(self, df):
        return self.artifacts.model.predict(df)
