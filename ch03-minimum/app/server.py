import http.server
import os
import socketserver

PORT = int(os.environ.get("PORT", "8080"))
VERSION = os.environ.get("APP_VERSION", "v1")


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"hello from {VERSION}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(fmt % args, flush=True)


with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"listening on {PORT}", flush=True)
    httpd.serve_forever()
