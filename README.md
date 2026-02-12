# AutoPort Operations

AutoPort is a Flutter application for automated port operations monitoring:

- AGV fleet status
- Crane status and throughput
- Delivery verification pipeline
- Camera and sensor operations dashboards
- Firebase Authentication (email/password + password reset)
- Real-time Firestore-backed AGV/crane/camera/sensor/delivery dashboards
- FastAPI ingestion service for edge telemetry

## Prerequisites

- Flutter SDK (stable)
- Dart SDK (installed with Flutter)
- Firebase project configured for this app

## Run Locally

```bash
flutter pub get
flutter run
```

## Real-Time Data Pipeline

This app now reads operational data from Firestore collections:

- `agv_units`
- `cranes`
- `deliveries`
- `camera_feeds`
- `sensor_readings`
- `sensor_events`

Schema reference: `docs/realtime_data_schema.md`

### FastAPI ingest service

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Then publish telemetry into endpoints like:

- `POST /ingest/agv`
- `POST /ingest/crane`
- `POST /ingest/delivery`
- `POST /ingest/camera`
- `POST /ingest/sensor`
- `POST /ingest/sensor-event`

Sample payloads: `backend/examples/`

### UDP ingest bridge (optional)

If sensors/camera gateways send UDP packets:

```bash
cd backend
source .venv/bin/activate
python -m app.udp_bridge --host 0.0.0.0 --port 9910 --api-base-url http://127.0.0.1:8000
```

The bridge converts UDP JSON packets to HTTP ingest calls and persists to Firebase.

## Automated Quality Gate

The project includes a single quality-gate script that enforces formatting, static analysis, and tests:

```bash
./tool/quality_gate.sh
```

Equivalent Make targets:

```bash
make bootstrap
make format
make analyze
make test
make ci
```

## CI/CD Automation

GitHub Actions workflow: `.github/workflows/ci.yml`

On each push to `main`/`master` and on pull requests, it automatically runs:

1. `flutter pub get`
2. `dart format --set-exit-if-changed`
3. `flutter analyze`
4. `flutter test --coverage`

Coverage output is uploaded as a build artifact.

## Dependency Automation

Dependabot config: `.github/dependabot.yml`

Weekly automated update PRs are enabled for:

- `pub` dependencies
- GitHub Actions versions

## Project Structure

- `lib/main.dart`: app bootstrap, Firebase initialization, auth gate
- `lib/auth/`: login and password reset screens + shared validators
- `lib/home/`: operations dashboards
- `lib/services/auth_service.dart`: Firebase auth integration + error mapping
- `test/`: validator/auth unit tests
- `tool/quality_gate.sh`: local automation entrypoint
