-- Anti-AFK / Anti-Idle (Auto-aktif, interval acak 3-4 menit)
-- LocalScript → StarterPlayerScripts

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- fungsi untuk mengirim input ringan
local function sendInput()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
    end)

    local cam = workspace.CurrentCamera
    if cam then
        pcall(function()
            local cur = cam.CFrame
            cam.CFrame = cur * CFrame.Angles(0, math.rad(0.05), 0)
            task.wait(0.03)
            cam.CFrame = cur
        end)
    end
end

-- tangani Idled event
if player then
    player.Idled:Connect(function()
        sendInput()
    end)
end

-- loop periodik dengan interval acak antara 180-240 detik (3-4 menit)
task.spawn(function()
    local rng = Random.new(tick() % 1 == 0 and os.time() or tick()) -- inisialisasi random
    while true do
        local interval = rng:NextNumber(180, 240)                   -- detik, float
        task.wait(interval)
        sendInput()
    end
end)
