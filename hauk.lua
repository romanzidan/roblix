game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "MT.HAUK", Text = "Created by: @lildanzvert", Duration = 5 })

-- Variabel untuk konfigurasi
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- === Character helper ===
local function GetCharacter(Player) return Player.Character or Player.CharacterAdded:Wait() end
local function GetRoot(Player) return GetCharacter(Player):WaitForChild("HumanoidRootPart") end
local function getCharacter() return GetCharacter(plr) end
local function getRootPart()
    local c = getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

-- === Fly system ===
local flyEnabled, flying = false, false
local bodyVelocity, bodyGyro, flyConnection
local flySpeed, rotationSpeed = 100, 0.18
local lastLookDirection = Vector3.new(0, 0, -1)
local autopilotEnabled, autopilotTarget = false, nil
local arrivalRadius, running = 6, false

local function isCharacterAnchored()
    local r = getRootPart()
    return r and r.Anchored
end

-- click function
local function clickAt(x, y)
    -- tekan
    vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.5)
    -- lepas
    vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- Noclip
local noclipConn
local function setNoclip(state)
    if noclipConn then
        noclipConn:Disconnect(); noclipConn = nil
    end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local c = getCharacter()
            if not c then return end
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else
        local c = getCharacter()
        if c then
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end
local function enableNoclip() setNoclip(true) end
local function disableNoclip() setNoclip(false) end

-- Dummy placeholder
local function isMovementAnimation(_) return false end
local function preventSitting()
    local c = getCharacter()
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if not h then return end
    h.Seated:Connect(function(active) if active then h.Jump = true end end)
end
local function handleAnimations() end
local function waitForControlModule()
    local pm = require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    return pm:GetControls()
end

-- Start fly
function startFly()
    local char, root = getCharacter(), getRootPart()
    if not char or not root or not flyEnabled then return end
    flying = true
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 1e4
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation and isMovementAnimation(track.Animation.AnimationId) then track:Stop() end
        end
        task.wait(0.1)
        humanoid.PlatformStand = true
        preventSitting()
        handleAnimations()
    end

    local controlModule = waitForControlModule()
    local camera = workspace.CurrentCamera
    lastLookDirection = camera.CFrame.LookVector

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not flying or not root or not root.Parent then return end

        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and not humanoid.PlatformStand then humanoid.PlatformStand = true end

        local targetVelocity = Vector3.zero
        if autopilotEnabled and autopilotTarget then
            local toTarget = (autopilotTarget - root.Position)
            if toTarget.Magnitude > arrivalRadius then targetVelocity = toTarget.Unit * flySpeed end
        else
            local moveVec = controlModule and controlModule:GetMoveVector() or Vector3.zero
            if moveVec.Magnitude > 0 then
                local direction = camera.CFrame:VectorToWorldSpace(moveVec)
                targetVelocity = direction.Unit * flySpeed
            end
        end

        if bodyVelocity then bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(targetVelocity, 0.25) end

        if flyEnabled and flying and bodyGyro and not isCharacterAnchored() then
            local currentLookDirection
            if autopilotEnabled and targetVelocity.Magnitude > 0 then
                currentLookDirection = targetVelocity.Unit
            else
                currentLookDirection = camera.CFrame.LookVector
            end
            local smoothedLookDirection = lastLookDirection:Lerp(currentLookDirection, rotationSpeed)
            lastLookDirection = smoothedLookDirection
            bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + smoothedLookDirection)
        end

        if targetVelocity.Magnitude == 0 then
            if bodyVelocity then bodyVelocity.Velocity = Vector3.zero end
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    enableNoclip()
end

local function stopFly()
    flying, flyEnabled, autopilotEnabled, autopilotTarget = false, false, false, nil
    if flyConnection then
        flyConnection:Disconnect(); flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy(); bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy(); bodyGyro = nil
    end
    local c, h = getCharacter(), nil
    if c then h = c:FindFirstChildOfClass("Humanoid") end
    if h then h.PlatformStand = false end
    disableNoclip()
end


local function FlyTo(targetPos, speed)
    flySpeed = speed or flySpeed
    flyEnabled, autopilotEnabled, autopilotTarget = true, true, targetPos
    startFly()

    while running and autopilotEnabled do
        local root = getRootPart()
        if not root then break end
        if (root.Position - targetPos).Magnitude <= arrivalRadius then break end
        task.wait()
    end
    stopFly()
    task.wait(1)
end

-- === ROUTE ===
local checkpoints = {
    Vector3.new(93.19, 21.45, 34.15),   -- timer
    Vector3.new(523.19, 40.07, 8.46),   -- camp1
    Vector3.new(897.47, 108.11, 22.12), -- camp2
    Vector3.new(652, 125.24, 399.97),   -- camp3
    -- Vector3.new(-172, 138.17, 548),       -- camp5
    -- Vector3.new(-1057.69, 405.96, 966.7), -- camp8
    -- Vector3.new(-1217.43, 498.24, 1053),  -- camp9
    -- Vector3.new(-1558.67, 510.82, 1112),  -- camp10
    -- Vector3.new(-1734.98, 610.21, 909),   -- camp11
    -- Vector3.new(-1867.25, 664.14, 855.3), -- camp12
    -- Vector3.new(-1901.98, 718.21, 873),   -- camp13
    -- Vector3.new(-2094.39, 771.65, 808),   -- parka summit1
    -- Vector3.new(-2848.56, 1150.39, 599),  -- parka summit2
    -- Vector3.new(-2857, 1517.24, -596)     --summit
}

-- === MAIN ROUTE ===
local currentIndex = 1
local waitingRespawn = false

local function FlyRoute()
    currentIndex = 1
    while running do
        if currentIndex > #checkpoints then
            task.wait(5) -- tunggu 5 detik sebelum reset
            -- autoklik ke basecamp
            -- klik pertama
            clickAt(971, 273)
            -- tunggu 1 detik
            task.wait(1)
            -- klik kedua
            clickAt(463, 349)
            task.wait(5)
            currentIndex = 1
        end

        local pos = checkpoints[currentIndex]
        FlyTo(pos, flySpeed)

        -- kalau sampai camp8 (index 5 di list)
        if currentIndex == 7 then
            local char = GetCharacter(plr)
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local root = GetRoot(plr)

            if humanoid and root then
                waitingRespawn = true
                humanoid.Health = 0 -- bunuh karakter
                break               -- hentikan loop, tunggu respawn
            end
        end

        currentIndex = currentIndex + 1
    end
end

-- === RESPWAN HANDLER ===
plr.CharacterAdded:Connect(function()
    if waitingRespawn then
        task.wait(2)                    -- tunggu character ready
        waitingRespawn = false
        currentIndex = currentIndex + 1 -- lanjut ke checkpoint setelah camp8
        while running and currentIndex <= #checkpoints do
            local pos = checkpoints[currentIndex]
            FlyTo(pos, flySpeed)
            currentIndex = currentIndex + 1
        end
        running = false
    end
end)

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TeleportRouteGui"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = false

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -25, 1, 0)
Title.Text = "LILDANZVERT - MT.HAUK"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font, Title.TextSize, Title.TextXAlignment = Enum.Font.SourceSansBold, 16, Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 5, 0, 0)

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 25, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -25, 0, 0)
MinimizeBtn.Text, MinimizeBtn.TextSize = "-", 18
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.SourceSansBold

local ButtonFrame = Instance.new("Frame", MainFrame)
ButtonFrame.Size = UDim2.new(1, 0, 1, -25)
ButtonFrame.Position = UDim2.new(0, 0, 0, 25)
ButtonFrame.BackgroundTransparency = 1

-- tombol free fly
local FreeFlyBtn = Instance.new("TextButton", ButtonFrame)
FreeFlyBtn.Size = UDim2.new(0, 160, 0, 40)
FreeFlyBtn.Position = UDim2.new(0.5, -80, 0, 10)
FreeFlyBtn.Text = "Start Free Fly"
FreeFlyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
FreeFlyBtn.TextColor3 = Color3.new(1, 1, 1)
FreeFlyBtn.Font, FreeFlyBtn.TextSize = Enum.Font.SourceSansBold, 18

-- tombol summit
local SummitBtn = Instance.new("TextButton", ButtonFrame)
SummitBtn.Size = UDim2.new(0, 160, 0, 40)
SummitBtn.Position = UDim2.new(0.5, -80, 0, 60)
SummitBtn.Text = "Start Summit"
SummitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
SummitBtn.TextColor3 = Color3.new(1, 1, 1)
SummitBtn.Font, SummitBtn.TextSize = Enum.Font.SourceSansBold, 18

-- tombol stop
local StopBtn = Instance.new("TextButton", ButtonFrame)
StopBtn.Size = UDim2.new(0, 160, 0, 40)
StopBtn.Position = UDim2.new(0.5, -80, 0, 110)
StopBtn.Text = "Stop Fly"
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.new(1, 1, 1)
StopBtn.Font, StopBtn.TextSize = Enum.Font.SourceSansBold, 18

-- === SLIDER SPEED ===
local SliderBar = Instance.new("Frame", ButtonFrame)
SliderBar.Size = UDim2.new(0.8, 0, 0, 10)
SliderBar.Position = UDim2.new(0.1, 0, 1, -40)
SliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
SliderBar.BorderSizePixel = 1

local Fill = Instance.new("Frame", SliderBar)
Fill.Size = UDim2.new(0.5, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Fill.BorderSizePixel = 0

local Knob = Instance.new("Frame", SliderBar)
Knob.Size = UDim2.new(0, 15, 1.8, 0)
Knob.Position = UDim2.new(Fill.Size.X.Scale, -7, -0.4, 0)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

local ValueLabel = Instance.new("TextLabel", ButtonFrame)
ValueLabel.Size = UDim2.new(1, 0, 0, 20)
ValueLabel.Position = UDim2.new(0, 0, 1, -25)
ValueLabel.TextColor3 = Color3.new(1, 1, 1)
ValueLabel.BackgroundTransparency = 1
ValueLabel.Text = "Speed: " .. flySpeed

-- custom drag hanya lewat TitleBar
local dragging = false
local dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Slider logic
local UserInputService = game:GetService("UserInputService")
local dragging = false
local minSpeed, maxSpeed = 20, 300

local function updateSlider(inputX)
    local barAbsPos = SliderBar.AbsolutePosition.X
    local barAbsSize = SliderBar.AbsoluteSize.X
    local percent = math.clamp((inputX - barAbsPos) / barAbsSize, 0, 1)
    Fill.Size = UDim2.new(percent, 0, 1, 0)
    Knob.Position = UDim2.new(percent, -7, -0.4, 0)
    flySpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * percent)
    ValueLabel.Text = "Speed: " .. tostring(flySpeed)
end

-- mulai drag (mouse/touch)
Knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

-- stop drag (mouse/touch)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- update saat geser
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input.Position.X)
    end
end)

-- tombol logic
FreeFlyBtn.MouseButton1Click:Connect(function()
    if running then return end
    running, flyEnabled, autopilotEnabled = true, true, false
    startFly()
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "✈️ Free Fly", Text = "Gunakan WASD + kamera", Duration = 5 })
end)


SummitBtn.MouseButton1Click:Connect(function()
    if not running then
        -- Start Summit
        running = true
        SummitBtn.Text = "Stop Summit"
        SummitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- merah

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🗻 Summit Started",
            Text = "Menuju checkpoint...",
            Duration = 5
        })
        task.spawn(FlyRoute)
    else
        -- Stop Summit
        running = false
        stopFly()
        SummitBtn.Text = "Start Summit"
        SummitBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- hijau (atau warna default)

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⛔ Summit Stopped",
            Duration = 5
        })
    end
end)


StopBtn.MouseButton1Click:Connect(function()
    running = false
    stopFly()
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "⛔ Fly Stopped", Duration = 5 })
end)

-- minimize
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ButtonFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 250, 0, 25)
        MinimizeBtn.Text = "+"
    else
        ButtonFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 250, 0, 250)
        MinimizeBtn.Text = "-"
    end
end)
