# Real-Time Data Schema

The Flutter dashboard reads directly from Firestore collections.

## `agv_units/{agvId}`

- `online`: bool
- `missionStatus`: string
- `currentZone`: string
- `destinationZone`: string
- `batteryLevel`: number
- `speedKph`: number
- `etaMinutes`: number
- `containerId`: string?
- `streamHttpsUrl`: string?
- `streamUdpUrl`: string?
- `recordedAt`: timestamp
- `lastUpdated`: timestamp

## `cranes/{craneId}`

- `online`: bool
- `status`: string
- `utilizationPercent`: number
- `movesPerHour`: number
- `loadCycleProgress`: number (0..1)
- `vesselName`: string?
- `streamHttpsUrl`: string?
- `streamUdpUrl`: string?
- `recordedAt`: timestamp
- `lastUpdated`: timestamp

## `deliveries/{containerId}`

- `containerId`: string
- `status`: string (`pending`|`verified`|`exception`|`in_transit`|`completed`)
- `ownerName`: string
- `driverName`: string?
- `truckPlate`: string?
- `vesselName`: string?
- `originPort`: string?
- `destinationYard`: string?
- `sealNumber`: string?
- `customsStatus`: string?
- `arrivedAt`: timestamp
- `loadedAt`: timestamp?
- `verifiedAt`: timestamp?
- `expectedGateOutAt`: timestamp?
- `actualGateOutAt`: timestamp?
- `recordedAt`: timestamp
- `lastUpdated`: timestamp

## `camera_feeds/{cameraId}`

- `name`: string
- `zone`: string
- `status`: string
- `online`: bool
- `aiDetectionCount`: number
- `protocol`: string?
- `streamHttpsUrl`: string?
- `streamUdpUrl`: string?
- `lastSeen`: timestamp
- `recordedAt`: timestamp

## `sensor_readings/{sensorId}`

- `name`: string
- `kind`: string
- `location`: string
- `status`: string
- `online`: bool
- `value`: number
- `unit`: string
- `anomaly`: bool
- `sourceProtocol`: string?
- `eventDescription`: string?
- `recordedAt`: timestamp
- `lastSeen`: timestamp

## `sensor_events/{eventId}`

- `title`: string
- `status`: string
- `description`: string?
- `assetId`: string?
- `createdAt`: timestamp
