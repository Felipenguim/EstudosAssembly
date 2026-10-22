#!/usr/bin/env python3
"""
Servidor HTTP de teste para o projeto "Cliente HTTP em ARM64 assembly".

Escuta em 0.0.0.0:8000 e aceita requisições POST em qualquer path.

Regra de resposta (usada de propósito para você poder testar os DOIS
CAMINHOS de branching no seu programa ARM64):

    - Se o corpo da requisição contiver a palavra "ping"  -> responde 200 OK
    - Qualquer outro corpo                                -> responde 400 Bad Request

Uso:
    python3 server_http_teste.py

Teste manual antes de usar o assembly (recomendado):
    curl -X POST http://127.0.0.1:8000/ -d "ping"     # deve dar 200
    curl -X POST http://127.0.0.1:8000/ -d "qualquer"  # deve dar 400
"""

from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)
        print(f"[server] {self.client_address[0]}:{self.client_address[1]} -> {body!r}")

        if b"ping" in body:
            response_body = b"PONG\n"
            self.send_response(200)
        else:
            response_body = b"ERRO: corpo nao reconhecido\n"
            self.send_response(400)

        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(response_body)))
        self.end_headers()
        self.wfile.write(response_body)

    def log_message(self, format, *args):
        # silencia o log padrão do http.server (já temos nosso print acima)
        pass


if __name__ == "__main__":
    addr = ("0.0.0.0", 8000)
    httpd = HTTPServer(addr, Handler)
    print(f"Servidor rodando em http://{addr[0]}:{addr[1]}  (Ctrl+C para parar)")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nEncerrando servidor.")