from __future__ import annotations

import argparse
import json
import logging

import httpx

LOGGER = logging.getLogger("udp-bridge")


def _route_path(message_type: str) -> str:
    routing = {
        "agv": "/ingest/agv",
        "crane": "/ingest/crane",
        "delivery": "/ingest/delivery",
        "camera": "/ingest/camera",
        "sensor": "/ingest/sensor",
        "sensor_event": "/ingest/sensor-event",
    }
    if message_type not in routing:
        raise ValueError(f"Unsupported telemetry type: {message_type}")

    return routing[message_type]


def run_udp_bridge(host: str, port: int, api_base_url: str) -> None:
    import socket

    socket_server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    socket_server.bind((host, port))
    LOGGER.info("UDP bridge listening on %s:%s", host, port)

    with httpx.Client(timeout=8.0) as client:
        while True:
            packet, sender = socket_server.recvfrom(65535)
            try:
                message = json.loads(packet.decode("utf-8"))
                message_type = message["type"]
                payload = message["payload"]
                path = _route_path(message_type)
                response = client.post(f"{api_base_url}{path}", json=payload)
                response.raise_for_status()
                LOGGER.info("Forwarded %s from %s", message_type, sender)
            except Exception as error:  # pragma: no cover
                LOGGER.exception("Failed to process UDP packet from %s: %s", sender, error)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Bridge UDP telemetry packets into the FastAPI ingestion endpoints"
    )
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", default=9910, type=int)
    parser.add_argument("--api-base-url", default="http://127.0.0.1:8000")
    parser.add_argument("--log-level", default="INFO")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper(), logging.INFO))
    run_udp_bridge(host=args.host, port=args.port, api_base_url=args.api_base_url)


if __name__ == "__main__":
    main()
