import joblib
from sklearn import svm
from sklearn import datasets

import bentoml

if __name__ == "__main__":
    # Load training data
    iris = datasets.load_iris()
    X, y = iris.data, iris.target

    # Model Training
    clf = svm.SVC(gamma='scale')
    clf.fit(X, y)

    with bentoml.models.create("iris_classifier") as bento_model:
        joblib.dump(clf, bento_model.path_of("model.pkl"))
    print(f"Model saved: {bento_model}")
