"""Regression tests for changed-sample selection; no cluster is required."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("discover.sh")


class DiscoveryTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.git("init", "-q")
        self.git("config", "user.email", "test@example.test")
        self.git("config", "user.name", "Test")
        self.samples = [
            "eventing/bookstore-sample-app/start/frontend",
            "eventing/bookstore-sample-app/start/node-server",
            "eventing/bookstore-sample-app/solution/frontend",
            "eventing/bookstore-sample-app/solution/node-server",
            "serving/multi-container",
            "serving/cloudevents/cloudevents-go",
            "serving/cloudevents/cloudevents-go/eventing/logger",
        ]
        for sample in self.samples:
            self.write(f"code-samples/{sample}/ci.sh", "#!/bin/bash\n")
        self.write(".github/workflows/samples-test.yaml", "name: samples-test\n")
        self.write("hack/sample-ci/lib.sh", "# helpers\n")
        self.git("add", ".")
        self.git("commit", "-qm", "base")
        self.base = self.git("rev-parse", "HEAD").strip()

    def git(self, *args):
        return subprocess.check_output(
            ["git", *args], cwd=self.root, text=True, stderr=subprocess.STDOUT
        )

    def write(self, path, text):
        destination = self.root / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(text)

    def matrix(self, changes):
        for path in changes:
            self.write(path, "changed\n")
        self.git("add", ".")
        self.git("commit", "--allow-empty", "-qm", "change")
        return json.loads(subprocess.check_output(
            ["bash", str(SCRIPT), self.base], cwd=self.root, text=True
        ))

    def selected(self, changes):
        return [entry["name"] for entry in self.matrix(changes)]

    def test_bookstore_dockerfile_selects_node_test(self):
        sample = "eventing/bookstore-sample-app/start/node-server"
        self.assertEqual(self.selected([f"code-samples/{sample}/Dockerfile"]), [sample])

    def test_bookstore_names_are_unique(self):
        matrix = self.matrix([
            f"code-samples/{sample}/package.json" for sample in self.samples[:4]
        ])
        self.assertEqual(len(matrix), 4)
        self.assertEqual(len({entry["name"] for entry in matrix}), 4)

    def test_sidecar_selects_parent_integration_test(self):
        self.assertEqual(self.selected([
            "code-samples/serving/multi-container/sidecarcontainer/go.mod"
        ]), ["serving/multi-container"])

    def test_database_fixture_selects_corresponding_node(self):
        self.assertEqual(self.selected([
            "code-samples/eventing/bookstore-sample-app/solution/db-service/sample.sql"
        ]), ["eventing/bookstore-sample-app/solution/node-server"])

    def test_shared_helper_selects_all(self):
        self.assertEqual(set(self.selected(["hack/sample-ci/lib.sh"])), set(self.samples))

    def test_workflow_selects_all(self):
        self.assertEqual(set(self.selected([
            ".github/workflows/samples-test.yaml"
        ])), set(self.samples))

    def test_shared_sink_selects_all(self):
        self.assertEqual(set(self.selected([
            "code-samples/serving/cloudevents/cloudevents-go/eventing/logger/capture.go"
        ])), set(self.samples))

    def test_docs_only_change_is_empty(self):
        self.assertEqual(self.selected(["docs/README.md"]), [])

    def test_sample_without_script_is_empty(self):
        self.assertEqual(self.selected(["code-samples/yaml-only/service.yaml"]), [])


if __name__ == "__main__":
    unittest.main()
