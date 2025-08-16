game:GetService("StarterGui"):SetCore("SendNotification",
    { Title = "MT.HAUK", Text = "Created by: @lildanzvert", Duration = 5, })

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

-- === Character helper ===
local function GetCharacter(Player)
    return Player.Character or Player.CharacterAdded:Wait()
end
local function GetRoot(Player)
    local char = GetCharacter(Player)
    return char:WaitForChild("HumanoidRootPart")
end
local function getCharacter() return GetCharacter(plr) end
local function getRootPart()
    local c = getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end

-- === Fly system ===
local flyEnabled = false
local flying = false
local bodyVelocity, bodyGyro, flyConnection
local flySpeed = 80
local rotationSpeed = 0.18
local lastLookDirection = Vector3.new(0, 0, -1)
local autopilotEnabled = false
local autopilotTarget = nil
local arrivalRadius = 6

local function isCharacterAnchored()
    local r = getRootPart()
    return r and r.Anchored
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
    h.Seated:Connect(function(active)
        if active then h.Jump = true end
    end)
end
local function handleAnimations() end
local function waitForControlModule()
    local pm = require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    return pm:GetControls()
end

-- Start fly
function startFly()
    local char = getCharacter()
    local root = getRootPart()
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
            if track.Animation and track.Animation.AnimationId then
                if isMovementAnimation(track.Animation.AnimationId) then
                    track:Stop()
                end
            end
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
        if humanoid and not humanoid.PlatformStand then
            humanoid.PlatformStand = true
        end

        local targetVelocity = Vector3.zero
        if autopilotEnabled and autopilotTarget then
            local toTarget = (autopilotTarget - root.Position)
            local dist = toTarget.Magnitude
            if dist > arrivalRadius then
                targetVelocity = toTarget.Unit * flySpeed
            end
        else
            local moveVec = Vector3.zero
            if controlModule then moveVec = controlModule:GetMoveVector() end
            if moveVec.Magnitude > 0 then
                local direction = camera.CFrame:VectorToWorldSpace(moveVec)
                targetVelocity = direction.Unit * flySpeed
            end
        end

        if bodyVelocity then
            bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(targetVelocity, 0.25)
        end

        if flyEnabled and flying and bodyGyro and not isCharacterAnchored() then
            local currentLookDirection
            if autopilotEnabled and targetVelocity.Magnitude > 0 then
                currentLookDirection = targetVelocity.Unit
            else
                currentLookDirection = camera.CFrame.LookVector
            end
            local smoothedLookDirection = lastLookDirection:Lerp(currentLookDirection, rotationSpeed)
            lastLookDirection = smoothedLookDirection
            local targetCFrame = CFrame.lookAt(root.Position, root.Position + smoothedLookDirection)
            bodyGyro.CFrame = targetCFrame
        end

        if targetVelocity.Magnitude == 0 then
            if bodyVelocity then
                bodyVelocity.Velocity = Vector3.zero
            end
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    enableNoclip()
end

local function stopFly()
    flying = false
    flyEnabled = false
    autopilotEnabled = false
    autopilotTarget = nil
    if flyConnection then
        flyConnection:Disconnect(); flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy(); bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy(); bodyGyro = nil
    end
    local c = getCharacter()
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand = false end
    disableNoclip()
end

local function FlyTo(targetPos, speed)
    flySpeed = speed or flySpeed
    flyEnabled = true
    autopilotEnabled = true
    autopilotTarget = targetPos
    startFly()

    while running and autopilotEnabled do
        local root = getRootPart()
        if not root then break end
        if (root.Position - targetPos).Magnitude <= arrivalRadius then
            break
        end
        task.wait()
    end

    stopFly()
    task.wait(1)
end

-- === ROUTE ===
local checkpoints = {
    Vector3.new(523.19, 40.07, 8.46),    -- camp1
    Vector3.new(897.47, 108.11, 22.12),  -- camp2
    Vector3.new(652, 125.24, 399.97),    -- camp3
    Vector3.new(-1217.43, 498.24, 1053), -- camp9
    Vector3.new(-2857, 1517.24, -596)    -- summit
}
local running = false

local function FlyRoute()
    while running do
        for _, pos in ipairs(checkpoints) do
            if not running then break end
            FlyTo(pos, 80)
        end
        if running then
            local char = GetCharacter(plr)
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local root = GetRoot(plr)
            if humanoid and root then
                local walkTarget = root.Position + (root.CFrame.LookVector * 10)
                humanoid:MoveTo(walkTarget)
                task.wait(0.5)
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.5)
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                task.wait(0.4)
                humanoid.Health = 0
            end
            plr.CharacterAdded:Wait()
            task.wait(2)
        end
    end
end

-- === GUI ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportRouteGui"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -25, 1, 0)
Title.Text = "MT. HAUK"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 5, 0, 0)

local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 25, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -25, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 18

local ButtonFrame = Instance.new("Frame", MainFrame)
ButtonFrame.Size = UDim2.new(1, 0, 1, -25)
ButtonFrame.Position = UDim2.new(0, 0, 0, 25)
ButtonFrame.BackgroundTransparency = 1

local StartBtn = Instance.new("TextButton", ButtonFrame)
StartBtn.Size = UDim2.new(0, 160, 0, 40)
StartBtn.Position = UDim2.new(0.5, -80, 0, 10)
StartBtn.Text = "Start Summit"
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 18

local StopBtn = Instance.new("TextButton", ButtonFrame)
StopBtn.Size = UDim2.new(0, 160, 0, 40)
StopBtn.Position = UDim2.new(0.5, -80, 0, 60)
StopBtn.Text = "Stop Summit"
StopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Font = Enum.Font.SourceSansBold
StopBtn.TextSize = 18

-- tombol logic
StartBtn.MouseButton1Click:Connect(function()
    if running then return end
    running = true
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "🛫 Fly Started", Text = "Created by: @lildanzvert", Duration = 5, })
    task.spawn(FlyRoute)
end)
StopBtn.MouseButton1Click:Connect(function()
    running = false
    stopFly()
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "⛔ Fly Stopped", Text = "Created by: @lildanzvert", Duration = 5, })
end)

-- minimize logic
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ButtonFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 200, 0, 25)
        MinimizeBtn.Text = "+"
    else
        ButtonFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 200, 0, 120)
        MinimizeBtn.Text = "-"
    end
end)
