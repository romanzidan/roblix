-- // SCRIPT UNTUK MEMPERCEPAT JAM DI ROBLOX

-- -- TimeController.server.lua
-- -- Kontrol waktu Lighting dari server, dengan whitelist admin + chat command + RemoteEvent
-- -- TimeSpeedController.server.lua
-- local Lighting = game:GetService("Lighting")
-- local RunService = game:GetService("RunService")

-- -- Atur multiplier (1 = normal Roblox, 2 = 2x lebih cepat, dst.)
-- local TIME_SPEED = 10

-- -- Set waktu awal (opsional)
-- Lighting.ClockTime = 12

-- RunService.Stepped:Connect(function(_, step)
--     -- step = delta time (detik/frame)
--     Lighting.ClockTime = (Lighting.ClockTime + (step * TIME_SPEED)) % 24
-- end)

-- game:GetService("StarterGui"):SetCore("SendNotification",
--     { Title = "SCRIPT BERHASIL DIJALANKAN", Text = "Created by: @lildanzvert", Duration = 5, })


-- // Script untuk mempercepat timer di Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- RemoteEvent untuk broadcast timer ke client
local TimerEvent = Instance.new("RemoteEvent")
TimerEvent.Name = "TimerEvent"
TimerEvent.Parent = ReplicatedStorage

-- Konfigurasi
local SPEED_MULTIPLIER = 10 -- contoh: 3x lebih cepat

local timerValue = 0

-- Loop
RunService.Heartbeat:Connect(function(deltaTime)
    -- tambah waktu sesuai deltaTime * multiplier
    timerValue = timerValue + deltaTime * SPEED_MULTIPLIER

    -- broadcast ke semua client (dibulatkan 2 angka di belakang koma)
    TimerEvent:FireAllClients(math.floor(timerValue * 100) / 100)
end)

game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "SCRIPT BERHASIL DIJALANKAN", Text = "Created by: @lildanzvert", Duration = 5, })
