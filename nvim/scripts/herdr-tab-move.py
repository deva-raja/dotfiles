#!/usr/bin/env python3
"""Move a herdr tab to a specific index (tab.move is in herdr's socket API
but not yet exposed as a CLI subcommand). Usage: herdr-tab-move.py <tab_id> <insert_index>
Requires HERDR_SOCKET_PATH in the environment or standard ~/.config/herdr/herdr.sock."""
import sys, os, json, socket


def main():
    if len(sys.argv) != 3:
        print("usage: herdr-tab-move.py <tab_id> <insert_index>", file=sys.stderr)
        return 1

    tab_id, insert_index = sys.argv[1], int(sys.argv[2])
    sock_path = os.environ.get("HERDR_SOCKET_PATH")
    if not sock_path:
        default_sock = os.path.expanduser("~/.config/herdr/herdr.sock")
        if os.path.exists(default_sock):
            sock_path = default_sock
        else:
            print("HERDR_SOCKET_PATH not set", file=sys.stderr)
            return 1

    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.settimeout(5)
    s.connect(sock_path)
    req = {"id": "herdr-tab-move", "method": "tab.move",
           "params": {"tab_id": tab_id, "insert_index": insert_index}}
    s.sendall((json.dumps(req) + "\n").encode())
    buf = b""
    while not buf.endswith(b"\n"):
        chunk = s.recv(65536)
        if not chunk:
            break
        buf += chunk
    s.close()

    resp = json.loads(buf) if buf else {}
    if "error" in resp:
        print(json.dumps(resp["error"]), file=sys.stderr)
        return 1
    print(json.dumps(resp))
    return 0


if __name__ == "__main__":
    sys.exit(main())
