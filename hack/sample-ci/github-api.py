"""Local GitHub API fixture: no requests or credentials go to github.com."""
import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_PATCH(self):
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        if self.path != "/repos/ci/sample/pulls/1":
            self.send_error(404)
            return
        if self.headers.get("Authorization") != "Bearer ci-token":
            self.send_error(401)
            return
        print(json.dumps({"path": self.path, "body": body}), flush=True)
        response = json.dumps({"number": 1, "title": body["title"]}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()
        self.wfile.write(response)


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
