# CORS Update Summary

## Changes Made

### 1. Realtime.Hub (Port 5103)

**File:** `src/Realtime.Hub/Program.cs`

**Added CORS origins:**

- `http://localhost:4200` (Angular default)
- `http://127.0.0.1:4200`

**CORS Policy:** Allows credentials (required for SignalR WebSocket)

### 2. DeviceRegistry.Api (Port 5101)

**File:** `src/DeviceRegistry.Api/Program.cs`

**Added CORS origins:**

- `http://localhost:4200`
- `http://127.0.0.1:4200`

**CORS Policy:** Standard REST API CORS

### 3. Portal.Adapter (Port 5104)

**File:** `src/Portal.Adapter/Program.cs`

**Added CORS origins:**

- `http://localhost:4200`
- `http://127.0.0.1:4200`

**CORS Policy:** Standard REST API CORS

## What This Means

✅ Your Angular app running on `http://localhost:4200` can now:

- Fetch data from DeviceRegistry.Api
- Connect to Realtime.Hub via SignalR
- Query Portal.Adapter for historical data

✅ No proxy configuration needed in Angular
✅ No CORS errors expected

## Next Steps

1. **Restart all services** (see `scripts/restart-services.ps1`)
2. **Test the endpoints:**

   ```bash
   # From your Angular project or browser console
   curl http://localhost:5101/api/tenants/by-slug/innovia
   ```

3. **Run your Angular app:**

   ```bash
   ng serve
   ```

4. **Verify SignalR connection** in browser DevTools Network tab (WebSocket connection)

## Production Considerations

⚠️ **Before deploying to production:**

- Update CORS to include your production domain
- Remove localhost/127.0.0.1 from production CORS
- Consider using environment variables for CORS configuration
- Add rate limiting and authentication

Example production CORS:

```csharp
policy.WithOrigins("https://your-production-domain.com")
```
