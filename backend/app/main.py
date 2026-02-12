from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Literal

import firebase_admin
from fastapi import FastAPI, HTTPException
from firebase_admin import credentials, firestore
from pydantic import BaseModel, Field, HttpUrl

app = FastAPI(
    title="AutoPort Ingestion API",
    description="Receives real AGV/crane/camera/sensor/container telemetry and writes to Firestore.",
    version="1.0.0",
)


def _init_firestore() -> firestore.Client:
    if firebase_admin._apps:
        return firestore.client()

    credentials_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    try:
        if credentials_path:
            cred = credentials.Certificate(credentials_path)
            firebase_admin.initialize_app(cred)
        else:
            firebase_admin.initialize_app()
    except Exception as error:  # pragma: no cover
        raise RuntimeError(f"Failed to initialize Firebase Admin SDK: {error}") from error

    return firestore.client()


db = _init_firestore()


class AgvTelemetryPayload(BaseModel):
    agv_id: str = Field(min_length=1)
    online: bool
    mission_status: str
    current_zone: str
    destination_zone: str
    battery_level: float = Field(ge=0, le=100)
    speed_kph: float = Field(ge=0)
    eta_minutes: int = Field(ge=0)
    container_id: str | None = None
    stream_https_url: HttpUrl | None = None
    stream_udp_url: str | None = None
    recorded_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class CraneTelemetryPayload(BaseModel):
    crane_id: str = Field(min_length=1)
    online: bool
    status: str
    utilization_percent: float = Field(ge=0, le=100)
    moves_per_hour: int = Field(ge=0)
    load_cycle_progress: float = Field(ge=0, le=1)
    vessel_name: str | None = None
    stream_https_url: HttpUrl | None = None
    stream_udp_url: str | None = None
    recorded_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class DeliveryPayload(BaseModel):
    container_id: str = Field(min_length=1)
    status: Literal["pending", "verified", "exception", "in_transit", "completed"]
    owner_name: str
    driver_name: str | None = None
    truck_plate: str | None = None
    vessel_name: str | None = None
    origin_port: str | None = None
    destination_yard: str | None = None
    seal_number: str | None = None
    customs_status: str | None = None
    arrived_at: datetime
    loaded_at: datetime | None = None
    verified_at: datetime | None = None
    expected_gate_out_at: datetime | None = None
    actual_gate_out_at: datetime | None = None
    recorded_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class CameraFeedPayload(BaseModel):
    camera_id: str = Field(min_length=1)
    name: str
    zone: str
    status: str
    online: bool
    ai_detection_count: int = Field(ge=0)
    protocol: str | None = None
    stream_https_url: HttpUrl | None = None
    stream_udp_url: str | None = None
    last_seen: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class SensorReadingPayload(BaseModel):
    sensor_id: str = Field(min_length=1)
    name: str
    kind: str
    location: str
    status: str
    online: bool
    value: float
    unit: str
    anomaly: bool = False
    source_protocol: str | None = None
    event_description: str | None = None
    recorded_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class SensorEventPayload(BaseModel):
    title: str
    status: str
    description: str | None = None
    asset_id: str | None = None
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/ingest/agv")
def ingest_agv(payload: AgvTelemetryPayload) -> dict[str, str]:
    document = db.collection("agv_units").document(payload.agv_id)
    document.set(
        {
            "online": payload.online,
            "missionStatus": payload.mission_status,
            "currentZone": payload.current_zone,
            "destinationZone": payload.destination_zone,
            "batteryLevel": payload.battery_level,
            "speedKph": payload.speed_kph,
            "etaMinutes": payload.eta_minutes,
            "containerId": payload.container_id,
            "streamHttpsUrl": str(payload.stream_https_url)
            if payload.stream_https_url
            else None,
            "streamUdpUrl": payload.stream_udp_url,
            "recordedAt": payload.recorded_at,
            "lastUpdated": firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )
    return {"status": "ok", "id": payload.agv_id}


@app.post("/ingest/crane")
def ingest_crane(payload: CraneTelemetryPayload) -> dict[str, str]:
    document = db.collection("cranes").document(payload.crane_id)
    document.set(
        {
            "online": payload.online,
            "status": payload.status,
            "utilizationPercent": payload.utilization_percent,
            "movesPerHour": payload.moves_per_hour,
            "loadCycleProgress": payload.load_cycle_progress,
            "vesselName": payload.vessel_name,
            "streamHttpsUrl": str(payload.stream_https_url)
            if payload.stream_https_url
            else None,
            "streamUdpUrl": payload.stream_udp_url,
            "recordedAt": payload.recorded_at,
            "lastUpdated": firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )
    return {"status": "ok", "id": payload.crane_id}


@app.post("/ingest/delivery")
def ingest_delivery(payload: DeliveryPayload) -> dict[str, str]:
    document = db.collection("deliveries").document(payload.container_id)
    document.set(
        {
            "containerId": payload.container_id,
            "status": payload.status,
            "ownerName": payload.owner_name,
            "driverName": payload.driver_name,
            "truckPlate": payload.truck_plate,
            "vesselName": payload.vessel_name,
            "originPort": payload.origin_port,
            "destinationYard": payload.destination_yard,
            "sealNumber": payload.seal_number,
            "customsStatus": payload.customs_status,
            "arrivedAt": payload.arrived_at,
            "loadedAt": payload.loaded_at,
            "verifiedAt": payload.verified_at,
            "expectedGateOutAt": payload.expected_gate_out_at,
            "actualGateOutAt": payload.actual_gate_out_at,
            "recordedAt": payload.recorded_at,
            "lastUpdated": firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )
    return {"status": "ok", "id": payload.container_id}


@app.post("/ingest/camera")
def ingest_camera(payload: CameraFeedPayload) -> dict[str, str]:
    document = db.collection("camera_feeds").document(payload.camera_id)
    document.set(
        {
            "name": payload.name,
            "zone": payload.zone,
            "status": payload.status,
            "online": payload.online,
            "aiDetectionCount": payload.ai_detection_count,
            "protocol": payload.protocol,
            "streamHttpsUrl": str(payload.stream_https_url)
            if payload.stream_https_url
            else None,
            "streamUdpUrl": payload.stream_udp_url,
            "lastSeen": payload.last_seen,
            "recordedAt": payload.last_seen,
        },
        merge=True,
    )
    return {"status": "ok", "id": payload.camera_id}


@app.post("/ingest/sensor")
def ingest_sensor(payload: SensorReadingPayload) -> dict[str, str]:
    document = db.collection("sensor_readings").document(payload.sensor_id)
    document.set(
        {
            "name": payload.name,
            "kind": payload.kind,
            "location": payload.location,
            "status": payload.status,
            "online": payload.online,
            "value": payload.value,
            "unit": payload.unit,
            "anomaly": payload.anomaly,
            "sourceProtocol": payload.source_protocol,
            "eventDescription": payload.event_description,
            "recordedAt": payload.recorded_at,
            "lastSeen": payload.recorded_at,
        },
        merge=True,
    )

    if payload.anomaly and payload.event_description:
        db.collection("sensor_events").add(
            {
                "title": f"{payload.name} anomaly",
                "status": "open",
                "description": payload.event_description,
                "assetId": payload.sensor_id,
                "createdAt": payload.recorded_at,
            }
        )

    return {"status": "ok", "id": payload.sensor_id}


@app.post("/ingest/sensor-event")
def ingest_sensor_event(payload: SensorEventPayload) -> dict[str, str]:
    reference = db.collection("sensor_events").add(
        {
            "title": payload.title,
            "status": payload.status,
            "description": payload.description,
            "assetId": payload.asset_id,
            "createdAt": payload.created_at,
        }
    )

    if not reference or not reference[1].id:
        raise HTTPException(status_code=500, detail="Failed to persist event")

    return {"status": "ok", "id": reference[1].id}
