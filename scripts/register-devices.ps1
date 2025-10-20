# Script to register a tenant and 10 devices in DeviceRegistry.Api

$baseUrl = "http://localhost:5101"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Registering Tenant and Devices" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Create a tenant
Write-Host "`n1. Creating tenant 'Innovia Hub'..." -ForegroundColor Yellow
$tenantBody = @{
    name = "Innovia Hub"
    slug = "innovia"
} | ConvertTo-Json

$tenant = Invoke-RestMethod -Uri "$baseUrl/api/tenants" `
    -Method Post `
    -Body $tenantBody `
    -ContentType "application/json"

Write-Host "✅ Tenant created: $($tenant.name) (ID: $($tenant.id))" -ForegroundColor Green

# Step 2: Create 10 devices
Write-Host "`n2. Creating 10 sensor devices..." -ForegroundColor Yellow

$deviceModels = @(
    @{ model = "Acme CO2 Sensor"; serial = "dev-101"; type = "CO2" }
    @{ model = "Acme Temperature Sensor"; serial = "dev-102"; type = "Temperature" }
    @{ model = "Acme Humidity Sensor"; serial = "dev-103"; type = "Humidity" }
    @{ model = "Acme CO2 Sensor"; serial = "dev-104"; type = "CO2" }
    @{ model = "Acme Temperature Sensor"; serial = "dev-105"; type = "Temperature" }
    @{ model = "Acme Multi Sensor"; serial = "dev-106"; type = "Multi" }
    @{ model = "Acme CO2 Sensor"; serial = "dev-107"; type = "CO2" }
    @{ model = "Acme Temperature Sensor"; serial = "dev-108"; type = "Temperature" }
    @{ model = "Acme Humidity Sensor"; serial = "dev-109"; type = "Humidity" }
    @{ model = "Acme Multi Sensor"; serial = "dev-110"; type = "Multi" }
)

$devices = @()

foreach ($deviceInfo in $deviceModels) {
    $deviceBody = @{
        model = $deviceInfo.model
        serial = $deviceInfo.serial
        status = "active"
    } | ConvertTo-Json

    $device = Invoke-RestMethod -Uri "$baseUrl/api/tenants/$($tenant.id)/devices" `
        -Method Post `
        -Body $deviceBody `
        -ContentType "application/json"

    $devices += $device
    Write-Host "  ✅ Created: $($device.serial) - $($device.model) (ID: $($device.id))" -ForegroundColor Green
}

# Step 3: Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Tenant ID: $($tenant.id)" -ForegroundColor White
Write-Host "Tenant Slug: $($tenant.slug)" -ForegroundColor White
Write-Host "Total Devices: $($devices.Count)" -ForegroundColor White

Write-Host "`n✅ All devices registered successfully!" -ForegroundColor Green
Write-Host "`nYou can view them at: $baseUrl/swagger" -ForegroundColor Cyan

# Save device info to JSON file for simulator
$deviceInfo = @{
    tenantId = $tenant.id
    tenantSlug = $tenant.slug
    devices = $devices | ForEach-Object {
        @{
            id = $_.id
            serial = $_.serial
            model = $_.model
        }
    }
} | ConvertTo-Json -Depth 10

$deviceInfo | Out-File -FilePath ".\device-info.json" -Encoding UTF8
Write-Host "`n💾 Device info saved to: .\device-info.json" -ForegroundColor Cyan
