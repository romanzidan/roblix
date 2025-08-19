-- TimeController.server.lua
-- Kontrol waktu Lighting dari server, dengan whitelist admin + chat command + RemoteEvent
-- TimeSpeedController.server.lua
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

-- Atur multiplier (1 = normal Roblox, 2 = 2x lebih cepat, dst.)
local TIME_SPEED = 10

-- Set waktu awal (opsional)
Lighting.ClockTime = 12

RunService.Stepped:Connect(function(_, step)
    -- step = delta time (detik/frame)
    Lighting.ClockTime = (Lighting.ClockTime + (step * TIME_SPEED)) % 24
end)

game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "SCRIPT BERHASIL DIJALANKAN", Text = "Created by: @lildanzvert", Duration = 5, })
