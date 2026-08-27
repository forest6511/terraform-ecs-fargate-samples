import http.server
import platform
import socketserver

PORT = 8080


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        # どのアーキテクチャで動いているかを返す。
        # ARM64 に切り替わったことを画面で確かめるために使う
        body = f"ok machine={platform.machine()}\n"
        self.wfile.write(body.encode("utf-8"))

    def log_message(self, fmt, *args):
        pass


with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
