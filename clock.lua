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
local TimerEvent = ReplicatedStorage:WaitForChild("TimerEvent")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TimerUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(0.2, 0.1)
label.Position = UDim2.fromScale(0.4, 0.05)
label.TextScaled = true
label.BackgroundTransparency = 0.5
label.Text = "Timer: 0"
label.Parent = screenGui

-- Update dari server
TimerEvent.OnClientEvent:Connect(function(timeValue)
    label.Text = "Timer: " .. timeValue .. " detik"
end)

game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "SCRIPT BERHASIL DIJALANKAN", Text = "Created by: @lildanzvert", Duration = 5, })
