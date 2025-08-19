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
-- TimerUI.client.lua (langsung bisa diexecute)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Pastikan RemoteEvent ada
local TimerEvent = ReplicatedStorage:FindFirstChild("TimerEvent")
if not TimerEvent then
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "TIMER EVENT TIDAK ADA", Text = "Created by: @lildanzvert", Duration = 5, })
    return
end

-- Buat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimerUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 50)
frame.Position = UDim2.fromScale(0.4, 0.05)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.3
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Text = "Timer: ..."
label.Parent = frame

-- Update ketika server kirim
TimerEvent.OnClientEvent:Connect(function(timeValue)
    label.Text = "Timer: " .. timeValue .. " detik"
end)

-- Notif berhasil load
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "TimerUI",
    Text = "UI Timer berhasil di-load",
    Duration = 5
})
