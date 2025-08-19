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
local Players = game:GetService("Players")

-- RemoteEvent untuk broadcast ke client
local TimerEvent = Instance.new("RemoteEvent")
TimerEvent.Name = "TimerEvent"
TimerEvent.Parent = ReplicatedStorage

-- UserId admin (ganti sesuai milikmu)
local ADMIN_USER_ID = 8789851123

-- Data timer per pemain
local playerTimers = {}

-- Saat pemain join, inisialisasi timer
Players.PlayerAdded:Connect(function(player)
    playerTimers[player.UserId] = 0
end)

-- Saat pemain keluar, hapus datanya
Players.PlayerRemoving:Connect(function(player)
    playerTimers[player.UserId] = nil
end)

-- Loop update timer
RunService.Heartbeat:Connect(function(deltaTime)
    for userId, timeValue in pairs(playerTimers) do
        if userId == ADMIN_USER_ID then
            -- Admin: timer stuck di 360 detik (6 menit)
            playerTimers[userId] = 360
        else
            -- Player lain: timer terus bertambah normal
            playerTimers[userId] = playerTimers[userId] + deltaTime
        end
    end

    -- Broadcast ke semua client timer masing-masing
    for _, player in ipairs(Players:GetPlayers()) do
        local currentTime = playerTimers[player.UserId] or 0
        TimerEvent:FireClient(player, math.floor(currentTime))
    end
end)

game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "SCRIPT BERHASIL DIJALANKAN", Text = "Created by: @lildanzvert", Duration = 5, })
