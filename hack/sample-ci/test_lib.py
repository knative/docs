"""Test shared runner contracts without Docker or Kubernetes."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
LIB = Path(__file__).with_name("lib.sh")
DIAGNOSTICS = Path(__file__).with_name("diagnostics.sh")


class LibraryTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)

    def run_shell(self, script, **env):
        return subprocess.run(
            ["bash", "-c", 'source "$LIB"; ' + script],
            cwd=ROOT,
            env={**os.environ, "LIB": str(LIB), "TEST_DIR": str(self.directory), **env},
            text=True,
            capture_output=True,
        )

    def test_runner_stops_on_command_failure(self):
        result = self.run_shell('sample_test() { false; echo unexpected; }; main')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_runner_stops_on_pipeline_failure(self):
        result = self.run_shell('sample_test() { false | true; echo unexpected; }; main')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("unexpected", result.stdout)

    def test_runner_stops_on_unset_variable(self):
        result = self.run_shell('sample_test() { echo "$UNDEFINED_CI_TEST_VARIABLE"; }; main')
        self.assertNotEqual(result.returncode, 0)

    def test_runner_cleans_up_after_failure(self):
        result = self.run_shell('''sample_test() {
            mkdir "$TEST_DIR/trash"
            CI_TEMP+=("$TEST_DIR/trash")
            false
        }; main''')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.directory / "trash").exists())

    def test_runner_does_not_change_callers_shell_options(self):
        result = self.run_shell('sample_test() { :; }; main; [[ $- != *e* ]]')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_hello_asserts_exact_body(self):
        script = '''ci_docker_service() { :; }
            ci_request() { printf '%s' "$BODY"; }
            sample_test() { ci_hello example:ci 'expected'; }
            main'''
        self.assertEqual(self.run_shell(script, BODY="expected").returncode, 0)
        self.assertNotEqual(self.run_shell(script, BODY="unexpected").returncode, 0)

    def test_manifest_host_lookup(self):
        (self.directory / "service.yaml").write_text("kind: Service\n")
        result = self.run_shell('''kubectl() {
            printf '%s\n' "$*" > "$TEST_DIR/args"
            echo http://example.default.example.test
        }
        ci_host "$TEST_DIR/service.yaml"''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), "example.default.example.test")
        self.assertIn("get -f", (self.directory / "args").read_text())

    def test_event_response_checks_headers_and_body(self):
        script = '''ci_event() {
            printf 'Ce-Specversion: 1.0\r\nCe-Type: %s\r\n' "$TYPE" > "${@: -1}"
            printf '%s' '{"message":"expected"}'
        }
        sample_test() {
            ci_event_response example '{}' '.message == "expected"' ce-type expected.type
        }
        main'''
        self.assertEqual(self.run_shell(script, TYPE="expected.type").returncode, 0)
        self.assertNotEqual(self.run_shell(script, TYPE="wrong.type").returncode, 0)

    def test_function_cli_verifies_checksum_and_is_cached(self):
        result = self.run_shell('''uname() {
            case "$1" in -s) echo Linux ;; -m) echo x86_64 ;; esac
        }
        curl() {
            printf '%s\\n' "$*" >> "$TEST_DIR/downloads"
            printf binary > "${@: -1}"
        }
        sha256sum() {
            echo "33d8dbfbbb9a67ffb6f9296d142132faa2ab20af89b314ca1a2cf986b543b1d2  $1"
        }
        sample_test() {
            ci_function_cli
            [[ -x "$CI_FUNC_BINARY" ]]
            ci_function_cli
        }
        main''')
        self.assertEqual(result.returncode, 0, result.stderr)
        downloads = (self.directory / "downloads").read_text().splitlines()
        self.assertEqual(len(downloads), 1)
        self.assertIn("knative-v1.24.0/func_linux_amd64", downloads[0])

    def test_function_cli_rejects_checksum_mismatch(self):
        result = self.run_shell('''curl() { printf binary > "${@: -1}"; }
        sha256sum() { echo "incorrect  $1"; }
        sample_test() { ci_function_cli; echo unexpected; }
        main''')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("checksum mismatch", result.stderr)
        self.assertNotIn("unexpected", result.stdout)

    def test_every_sample_uses_shared_runner(self):
        scripts = sorted((ROOT / "code-samples").rglob("ci.sh"))
        self.assertTrue(scripts)
        for script in scripts:
            with self.subTest(sample=str(script.relative_to(ROOT))):
                result = subprocess.run(
                    ["bash", "-c", 'source ./ci.sh; declare -F main; declare -F sample_test'],
                    cwd=script.parent, text=True, capture_output=True,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertNotIn("main()", script.read_text())

    def test_diagnostics_do_not_depend_on_application_names(self):
        result = self.run_shell('''kubectl() {
            printf '%s\n' "$*" >> "$TEST_DIR/args"
            if [[ "$*" == 'get pods -A -o json' ]]; then
                printf '%s' '{"items":[{"metadata":{"namespace":"one","name":"arbitrary-pod"}},{"metadata":{"namespace":"two","name":"different-pod"}}]}'
            fi
        }
        export -f kubectl
        bash "$DIAGNOSTICS"''', DIAGNOSTICS=str(DIAGNOSTICS))
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = (self.directory / "args").read_text()
        self.assertIn("-n one logs arbitrary-pod --all-containers", calls)
        self.assertIn("-n two logs different-pod --all-containers", calls)
        self.assertNotIn("app=", calls)


if __name__ == "__main__":
    unittest.main()
