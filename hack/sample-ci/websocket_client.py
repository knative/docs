"""Assert real WebSocket traffic through the forwarded sample service."""
import argparse
import json

import websocket


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--url", required=True)
    parser.add_argument("--host")
    expected = parser.add_mutually_exclusive_group(required=True)
    expected.add_argument("--echo")
    expected.add_argument("--review")
    args = parser.parse_args()
    options = {"timeout": 30}
    if args.host:
        options["host"] = args.host
    connection = websocket.create_connection(args.url, **options)
    try:
        if args.echo is not None:
            connection.send(args.echo)
            received = connection.recv()
            assert received == args.echo, repr(received)
            connection.send_binary(b"binary smoke test")
            received = connection.recv()
            assert received == b"binary smoke test", repr(received)
        else:
            rows = json.loads(connection.recv())
            assert isinstance(rows, list), rows
            assert any(
                row["content"] == args.review and row["sentiment"] == "positive"
                for row in rows
            ), rows
    finally:
        connection.close()
    print("WebSocket assertions passed")


if __name__ == "__main__":
    main()
