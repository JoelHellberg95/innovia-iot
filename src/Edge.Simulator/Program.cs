using MQTTnet;
using MQTTnet.Client;
using System.Text.Json;
using System.Text;

var factory = new MqttFactory();
var client = factory.CreateMqttClient();

var options = new MqttClientOptionsBuilder()
    .WithTcpServer("localhost", 1883)
    .Build();

Console.WriteLine("Edge.Simulator starting… connecting to MQTT at localhost:1883");
try
{
    await client.ConnectAsync(options);
    Console.WriteLine("✅ Connected to MQTT broker.");
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Failed to connect to MQTT broker: {ex.Message}");
    throw;
}

// Define all 10 devices
var devices = new[]
{
    new { serial = "dev-101", model = "Acme CO2 Sensor", types = new[] { "co2", "temperature" } },
    new { serial = "dev-102", model = "Acme Temperature Sensor", types = new[] { "temperature" } },
    new { serial = "dev-103", model = "Acme Humidity Sensor", types = new[] { "humidity", "temperature" } },
    new { serial = "dev-104", model = "Acme CO2 Sensor", types = new[] { "co2", "temperature" } },
    new { serial = "dev-105", model = "Acme Temperature Sensor", types = new[] { "temperature" } },
    new { serial = "dev-106", model = "Acme Multi Sensor", types = new[] { "co2", "temperature", "humidity" } },
    new { serial = "dev-107", model = "Acme CO2 Sensor", types = new[] { "co2", "temperature" } },
    new { serial = "dev-108", model = "Acme Temperature Sensor", types = new[] { "temperature" } },
    new { serial = "dev-109", model = "Acme Humidity Sensor", types = new[] { "humidity", "temperature" } },
    new { serial = "dev-110", model = "Acme Multi Sensor", types = new[] { "co2", "temperature", "humidity" } }
};

var rand = new Random();
Console.WriteLine($"📡 Simulating data for {devices.Length} devices...\n");

while (true)
{
    // Send data for all devices
    foreach (var device in devices)
    {
        var metrics = new List<object>();
        
        foreach (var type in device.types)
        {
            if (type == "temperature")
                metrics.Add(new { type = "temperature", value = 20.0 + rand.NextDouble() * 5, unit = "C" });
            else if (type == "co2")
                metrics.Add(new { type = "co2", value = 800 + rand.Next(0, 800), unit = "ppm" });
            else if (type == "humidity")
                metrics.Add(new { type = "humidity", value = 40.0 + rand.NextDouble() * 30, unit = "%" });
        }

        var payload = new
        {
            deviceId = device.serial,
            apiKey = $"{device.serial}-key",
            timestamp = DateTimeOffset.UtcNow,
            metrics = metrics.ToArray()
        };

        var topic = $"tenants/innovia/devices/{device.serial}/measurements";
        var json = JsonSerializer.Serialize(payload);

        var message = new MqttApplicationMessageBuilder()
            .WithTopic(topic)
            .WithPayload(Encoding.UTF8.GetBytes(json))
            .Build();

        await client.PublishAsync(message);
        Console.WriteLine($"[{DateTimeOffset.UtcNow:HH:mm:ss}] {device.serial} → {string.Join(", ", device.types)}");
    }
    
    Console.WriteLine($"✅ Sent data for all {devices.Length} devices. Waiting 10 seconds...\n");
    await Task.Delay(TimeSpan.FromSeconds(10));
}
