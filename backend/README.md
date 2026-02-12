# AutoPort FastAPI Ingestion Service

This service receives real AGV, crane, camera, sensor, and delivery updates from edge systems and writes them to Firestore for the Flutter dashboard.

## 1) Install

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 2) Configure Firebase Admin

Set one of these:

- `GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/service-account.json`
- or run in an environment with Application Default Credentials (ADC)

## 3) Run API

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Health check:

```bash
curl http://127.0.0.1:8000/health
```

## 4) UDP Bridge (optional)

If edge devices publish UDP packets, run:

```bash
python -m app.udp_bridge --host 0.0.0.0 --port 9910 --api-base-url http://127.0.0.1:8000
```

Expected UDP JSON packet format:

```json
{
  "type": "sensor",
  "payload": {
    "sensor_id": "SEN-201",
    "name": "Crane Load Cell 201",
    "kind": "load_cell",
    "location": "QC-03",
    "status": "online",
    "online": true,
    "value": 43.7,
    "unit": "ton",
    "anomaly": false,
    "source_protocol": "udp"
  }
}
```

## 5) Firestore Collections Written

- `agv_units`
- `cranes`
- `deliveries`
- `camera_feeds`
- `sensor_readings`
- `sensor_events`

These are the same collections read by `lib/services/operations_repository.dart`.
