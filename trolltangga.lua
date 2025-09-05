-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local PlaceId, JobId = game.PlaceId, game.JobId

-- Vars
local flyEnabled, flying = false, false
local walkflinging = false
local bodyVelocity, bodyGyro, flyConnection
local lastLookDirection = Vector3.new(0, 0, -1)

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 200)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Text = "TROLL by LILDANZ"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -35, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ButtonHolder = Instance.new("Frame", Frame)
ButtonHolder.Size = UDim2.new(1, -20, 1, -50)
ButtonHolder.Position = UDim2.new(0, 10, 0, 40)
ButtonHolder.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ButtonHolder)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local UIPadding = Instance.new("UIPadding", ButtonHolder)
UIPadding.PaddingTop = UDim.new(0, 5)

local function createButton(name, text, color)
    local btn = Instance.new("TextButton", ButtonHolder)
    btn.Name = name
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(150, 0, 0)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    return btn
end

-- Urutan tombol: ServerHop di atas
local ServerHopButton = createButton("ServerHopButton", "Server Hop", Color3.fromRGB(0, 100, 200))
local FlyButton = createButton("FlyButton", "Fly [OFF]", Color3.fromRGB(150, 0, 0))
local WalkFlingButton = createButton("WalkFlingButton", "WalkFling [OFF]", Color3.fromRGB(150, 0, 0))

-- Helper Functions
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function waitForControlModule()
    local success, controlModule = pcall(function()
        return require(player:WaitForChild("PlayerScripts")
            :WaitForChild("PlayerModule")
            :WaitForChild("ControlModule"))
    end)
    if success then return controlModule else return nil end
end

-- Fly Functions
local function startFly()
    local char = getCharacter()
    local root = getRootPart()
    if not char or not root or not flyEnabled then return end
    flying = true

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 1e4
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end

    local controlModule = waitForControlModule()
    local camera = workspace.CurrentCamera
    lastLookDirection = camera.CFrame.LookVector

    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled or not flying or not root then return end

        local moveVec = Vector3.zero
        if controlModule then moveVec = controlModule:GetMoveVector() end

        local targetVelocity = Vector3.zero
        if moveVec.Magnitude > 0 then
            local direction = camera.CFrame:VectorToWorldSpace(moveVec)
            targetVelocity = direction.Unit * 80
        end

        if bodyVelocity then
            bodyVelocity.Velocity = bodyVelocity.Velocity:Lerp(targetVelocity, 0.25)
        end

        if bodyGyro then
            local currentLookDirection = camera.CFrame.LookVector
            lastLookDirection = lastLookDirection:Lerp(currentLookDirection, 0.2)
            bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + lastLookDirection)
        end
    end)
end

local function stopFly()
    flying = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    local char = getCharacter()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
end


local function addHitbox(size)
    local root = getRootPart()
    if not root then return end

    -- cek kalau sudah ada hitbox lama
    if root:FindFirstChild("FlingHitbox") then
        root.FlingHitbox:Destroy()
    end

    local hitbox = Instance.new("Part")
    hitbox.Name = "FlingHitbox"
    hitbox.Size = size or Vector3.new(10, 10, 10) -- default hitbox besar
    hitbox.Transparency = 1
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.Massless = true
    hitbox.Parent = root

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = hitbox
    weld.Parent = root
end

-- WalkFling Functions
local walkFlingConnection
local function startWalkFling()
    walkflinging = true
    addHitbox(Vector3.new(20, 20, 20)) -- perbesar hitbox
    walkFlingConnection = RunService.Heartbeat:Connect(function()
        local root = getRootPart()
        if root then
            local vel = root.Velocity
            root.Velocity = vel * 1000000 + Vector3.new(0, 1000000, 0)
            RunService.RenderStepped:Wait()
            --- original
            -- root.Velocity = vel
            -- RunService.Stepped:Wait()
            -- root.Velocity = vel + Vector3.new(0, 0.1, 0)
            --- new
            root.Velocity = vel * 500000
            RunService.Stepped:Wait()
            root.Velocity = vel + Vector3.new(0, 1, 0)
        end
    end)
end

local function stopWalkFling()
    walkflinging = false
    if walkFlingConnection then
        walkFlingConnection:Disconnect()
        walkFlingConnection = nil
    end
    local root = getRootPart()
    if root and root:FindFirstChild("FlingHitbox") then
        root.FlingHitbox:Destroy()
    end
end

-- Toggle Functions
local function toggleFly()
    if not flyEnabled then
        flyEnabled = true
        startFly()
        FlyButton.Text = "Fly [ON]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        flyEnabled = false
        stopFly()
        FlyButton.Text = "Fly [OFF]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

local function toggleWalkFling()
    if not walkflinging then
        startWalkFling()
        WalkFlingButton.Text = "WalkFling [ON]"
        WalkFlingButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        stopWalkFling()
        WalkFlingButton.Text = "WalkFling [OFF]"
        WalkFlingButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end

-- Server Hop
local function serverHop()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" ..
        PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    local body = HttpService:JSONDecode(req)
    if body and body.data then
        for _, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], player)
    end
end

-- Button Events
FlyButton.MouseButton1Click:Connect(toggleFly)
WalkFlingButton.MouseButton1Click:Connect(toggleWalkFling)
ServerHopButton.MouseButton1Click:Connect(serverHop)

-- Minimize (resize frame, bukan hilangin)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ButtonHolder.Visible = false
        Frame.Size = UDim2.new(0, 250, 0, 40)
        MinBtn.Text = "+"
    else
        ButtonHolder.Visible = true
        Frame.Size = UDim2.new(0, 250, 0, 200)
        MinBtn.Text = "-"
    end
end)

-- Keybind (E) untuk Fly + WalkFling sekaligus
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleFly()
        toggleWalkFling()
    end
end)
