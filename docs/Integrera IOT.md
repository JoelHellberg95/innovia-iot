# Instruktioner för Angular Integration med Innovia IoT

## Kontext

Jag har ett IoT-backend-system (Innovia IoT) som körs lokalt med följande tjänster:

- **DeviceRegistry.Api** på `http://localhost:5101` - Hanterar tenants och enheter
- **Ingest.Gateway** på `http://localhost:5102` - Tar emot sensordata
- **Realtime.Hub** på `http://localhost:5103` - SignalR hub för realtidsdata
- **Portal.Adapter** på `http://localhost:5104` - REST API för portaler

## Vad jag vill göra

Jag vill integrera mitt Angular 19-projekt med detta IoT-system för att:

1. Hämta och visa alla registrerade enheter (10st sensorer)
2. Ta emot och visa realtidsdata via SignalR
3. Visa senaste mätvärden för varje enhet (temperatur, CO2, humidity)

## Backend-detaljer

### Tenant Information

- **Tenant Slug**: `innovia`
- **Tenant ID**: `05263495-411f-4594-b950-163ff5c7ff1e`

### Enheter (10 stycken)

Alla enheter har serienummer från `dev-101` till `dev-110` och skickar data var 10:e sekund.

### API Endpoints som ska användas

#### 1. Hämta tenant

```
GET http://localhost:5101/api/tenants/by-slug/innovia
Response: { "id": "guid", "name": "string", "slug": "string" }
```

#### 2. Hämta alla enheter för en tenant

```
GET http://localhost:5101/api/tenants/{tenantId}/devices
Response: Array<{
  "id": "guid",
  "tenantId": "guid",
  "roomId": "guid | null",
  "model": "string",
  "serial": "string",
  "status": "string"
}>
```

### SignalR Integration

#### Hub URL

```
http://localhost:5103/hub/telemetry
```

#### SignalR Flow

1. Anslut till hubben
2. Invoke metoden `JoinTenant` med parametern `"innovia"`
3. Lyssna på eventet `measurementReceived`

#### Measurement Event Format

```typescript
{
  tenantSlug: string;      // "innovia"
  deviceId: string;        // GUID
  type: string;            // "temperature", "co2", "humidity"
  value: number;           // Mätvärde
  time: string;            // ISO 8601 timestamp
}
```

## Vad som ska skapas

### 1. IoT Service (`src/app/services/iot.service.ts`)

**Ansvar:**

- Hämta tenant via slug
- Hämta alla enheter för tenant
- Hantera SignalR-anslutning
- Uppdatera enheter med realtidsdata
- Exponera Observable för komponenter

**Dependencies:**

```bash
npm install @microsoft/signalr
```

**Funktioner som behövs:**

- `getTenantBySlug(slug: string): Promise<Tenant>`
- `getDevices(tenantId: string): Promise<Device[]>`
- `startRealtimeConnection(): Promise<void>`
- `stopRealtimeConnection(): Promise<void>`
- `devices$: Observable<DeviceWithLatestData[]>`

**Viktig logik:**

- Använd `BehaviorSubject` för att hålla enhetsdata
- När en `measurementReceived` tas emot, uppdatera rätt enhet
- Varje enhet ska ha en `Map<string, MeasurementData>` för senaste värden

### 2. Device List Component (`src/app/components/device-list/`)

**Ansvar:**

- Visa alla 10 enheter i ett grid
- Prenumerera på `devices$` från IotService
- Starta SignalR-anslutning vid `ngOnInit`
- Stoppa SignalR-anslutning vid `ngOnDestroy`
- Visa realtidsdata för varje enhet

**Layout:**

- Responsive grid (3-4 kort per rad på desktop)
- Varje kort visar:
  - Serial number (t.ex. "dev-101")
  - Model name
  - Status badge (active/inactive)
  - Senaste mätvärden:
    - 🌡️ Temperature (°C)
    - 💨 CO2 (ppm)
    - 💧 Humidity (%)
  - Tid sedan senaste uppdatering

**Visual feedback:**

- Kort ska "lysa upp" eller animeras när nya data kommer
- Färgkodning baserat på värden (t.ex. rött för högt CO2)
- Visa "Waiting for data..." om ingen data finns än

### 3. TypeScript Interfaces

```typescript
export interface Tenant {
  id: string;
  name: string;
  slug: string;
}

export interface Device {
  id: string;
  tenantId: string;
  roomId?: string;
  model: string;
  serial: string;
  status: string;
}

export interface RealtimeMeasurement {
  tenantSlug: string;
  deviceId: string;
  type: string;
  value: number;
  time: string;
}

export interface MeasurementData {
  value: number;
  time: string;
}

export interface DeviceWithLatestData extends Device {
  latestMeasurements: Map<string, MeasurementData>;
}
```

### 4. Styling

- Modern, clean design
- Cards med border och shadow
- Smooth animations vid uppdateringar
- Responsive grid layout
- Status indicators med färger

## CORS Configuration (Redan fixat på backend)

Realtime.Hub, DeviceRegistry.Api och Portal.Adapter är konfigurerade att acceptera CORS från:

- `http://localhost:4200` - Angular default port
- `http://127.0.0.1:4200`
- `http://localhost:5500`
- `http://127.0.0.1:5500`

**Inga CORS-problem förväntas!** Om du ändå får CORS-fel, kontrollera att tjänsterna har startats om efter CORS-uppdateringen.

## Testning

### Verifiera att backend körs

```bash
# Testa DeviceRegistry
curl http://localhost:5101/api/tenants/by-slug/innovia

# Testa att enheter finns
curl http://localhost:5101/api/tenants/05263495-411f-4594-b950-163ff5c7ff1e/devices
```

### Starta Angular-appen

```bash
ng serve
```

### Förväntat resultat

1. Appen laddar och visar 10 enheter
2. Efter max 10 sekunder börjar realtidsdata dyka upp
3. Varje enhet uppdateras var 10:e sekund med nya värden
4. UI uppdateras smidigt utan laddning

## Felsökning

**Problem:** CORS-fel i konsolen
**Lösning:** Kontrollera att Angular körs på port som är tillåten, eller uppdatera CORS på backend

**Problem:** SignalR ansluter inte
**Lösning:**

- Kontrollera att Realtime.Hub körs på port 5103
- Kolla nätverkstabben i DevTools för WebSocket-anslutning

**Problem:** Enheter visas inte
**Lösning:**

- Kontrollera att DeviceRegistry.Api körs på port 5101
- Verifiera tenant ID och att enheter finns i databasen

**Problem:** Ingen realtidsdata
**Lösning:**

- Kontrollera att Edge.Simulator körs och skickar MQTT-data
- Kolla att Ingest.Gateway tar emot data (kolla dess terminal-output)

## Angular 19 Specifikt

- Använd standalone components om projektet är konfigurerat för det
- Om projektet använder ny control flow syntax (`@if`, `@for`), använd den
- Annars använd klassisk `*ngIf`, `*ngFor`

## Exempel på användarflöde

1. Användaren öppnar appen
2. Loading spinner visas
3. 10 enheter laddas och visas i grid
4. Kort har "Waiting for data..." status
5. Efter max 10 sek börjar värden dyka upp
6. Varje kort uppdateras kontinuerligt
7. Användaren ser live-data från alla sensorer

---

## Sammanfattning för AI/Copilot

**Uppgift:** Skapa en Angular 19-integration som ansluter till ett lokalt IoT-backend-system.

**Vad behöver skapas:**

1. IoT Service med SignalR och HTTP-anrop
2. Device List Component som visar 10 enheter med realtidsdata
3. Styling för modernt, responsivt grid-layout

**Backend är redan igång på:**

- DeviceRegistry: localhost:5101
- Realtime Hub: localhost:5103
- Tenant: "innovia"
- 10 enheter (dev-101 till dev-110)

**SignalR flow:**

1. Connect → `http://localhost:5103/hub/telemetry`
2. Invoke → `JoinTenant("innovia")`
3. Listen → `measurementReceived` event

**Resultat:** Dashboard som visar alla enheter med live-uppdaterande temperatur, CO2 och humidity-värden.
