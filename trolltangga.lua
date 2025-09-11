-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

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
Frame.Size = UDim2.new(0, 180, 0, 200) -- diperkecil
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.BackgroundTransparency = 0.2 -- transparansi
Frame.Active = true
Frame.Draggable = true

local frameCorner = Instance.new("UICorner", Frame)
frameCorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -30, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.Text = "TROLL by LILDANZ"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -28, 0, 5)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local ButtonHolder = Instance.new("Frame", Frame)
ButtonHolder.Size = UDim2.new(1, -20, 1, -40)
ButtonHolder.Position = UDim2.new(0, 10, 0, 35)
ButtonHolder.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ButtonHolder)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local UIPadding = Instance.new("UIPadding", ButtonHolder)
UIPadding.PaddingTop = UDim.new(0, 3)

local function createButton(name, text, color, order)
    local btn = Instance.new("TextButton", ButtonHolder)
    btn.Name = name
    btn.Size = UDim2.new(0, 150, 0, 30) -- lebih kecil
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(220, 53, 69)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.LayoutOrder = order or 0

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    return btn
end

-- Buttons
local ServerHopButton = createButton("ServerHopButton", "Server Hop", Color3.fromRGB(0, 123, 255), 1)
local RejoinButton = createButton("RejoinButton", "Rejoin", Color3.fromRGB(0, 200, 150), 2)
local FlyButton = createButton("FlyButton", "Fly [OFF]", Color3.fromRGB(220, 53, 69), 3)
local WalkFlingButton = createButton("WalkFlingButton", "WalkFling [OFF]", Color3.fromRGB(220, 53, 69), 4)

-- Helper Functions
local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getRootPart()
    local char = getCharacter()
    return char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("Torso")
end

local function waitForControlModule()
    local success, controlModule = pcall(function()
        return require(player:WaitForChild("PlayerScripts")
            :WaitForChild("PlayerModule")
            :WaitForChild("ControlModule"))
    end)
    if success then return controlModule else return nil end
end

-- Fly
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

-- WalkFling
local walkFlingConnection
local function addHitbox(size)
    local root = getRootPart()
    if not root then return end
    if root:FindFirstChild("FlingHitbox") then
        root.FlingHitbox:Destroy()
    end

    local hitbox = Instance.new("Part")
    hitbox.Name = "FlingHitbox"
    hitbox.Size = size or Vector3.new(10, 10, 10)
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

local function startWalkFling()
    walkflinging = true
    addHitbox(Vector3.new(30, 30, 30))
    walkFlingConnection = RunService.Heartbeat:Connect(function()
        local root = getRootPart()
        if root then
            local vel = root.Velocity
            root.Velocity = vel * 1000000 + Vector3.new(0, 1000000, 0)
            RunService.RenderStepped:Wait()
            root.Velocity = vel
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
        FlyButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    else
        flyEnabled = false
        stopFly()
        FlyButton.Text = "Fly [OFF]"
        FlyButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    end
end

local function toggleWalkFling()
    if not walkflinging then
        startWalkFling()
        WalkFlingButton.Text = "WalkFling [ON]"
        WalkFlingButton.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    else
        stopWalkFling()
        WalkFlingButton.Text = "WalkFling [OFF]"
        WalkFlingButton.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    end
end

-- Server Hop (paling ramai + retry + auto rejoin kalau penuh)
local function serverHop()
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" ..
            PlaceId .. "/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true")
    end)

    if not success then
        notify("Server Hop", "Gagal ambil data server, coba lagi...", 2)
        task.wait(1)
        return serverHop()
    end

    local body = HttpService:JSONDecode(result)
    local bestServer, mostPlayers = nil, -1

    if body and body.data then
        for _, v in next, body.data do
            if type(v) == "table"
                and tonumber(v.playing)
                and tonumber(v.maxPlayers)
                and v.playing < v.maxPlayers
                and v.id ~= JobId then
                if v.playing > mostPlayers then
                    mostPlayers = v.playing
                    bestServer = v.id
                end
            end
        end
    end

    if bestServer then
        notify("Server Hop", "Teleport ke server paling ramai...", 2)
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(PlaceId, bestServer, player)
        end)
        if not ok then
            notify("Server Hop", "Teleport gagal: " .. tostring(err), 2)

            -- kalau error server penuh atau teleport gagal, auto rejoin
            task.wait(1)
            TeleportService:Teleport(PlaceId, player)
        end
    else
        notify("Server Hop", "Tidak ada server lain yang tersedia...", 2)
        task.wait(1)
        TeleportService:Teleport(PlaceId, player) -- fallback rejoin
    end
end


-- Rejoin
local function rejoinServer()
    notify("Rejoin", "Teleport ke server ini lagi...", 2)
    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
end

-- Button Events
FlyButton.MouseButton1Click:Connect(toggleFly)
WalkFlingButton.MouseButton1Click:Connect(toggleWalkFling)
ServerHopButton.MouseButton1Click:Connect(serverHop)
RejoinButton.MouseButton1Click:Connect(rejoinServer)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ButtonHolder.Visible = false
        Frame.Size = UDim2.new(0, 180, 0, 35)
        MinBtn.Text = "+"
    else
        ButtonHolder.Visible = true
        Frame.Size = UDim2.new(0, 180, 0, 200)
        MinBtn.Text = "-"
    end
end)

-- Keybind (E)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleFly()
        toggleWalkFling()
    end
end)

-- Auto reconnect saat respawn
player.CharacterAdded:Connect(function(char)
    flying = false
    walkflinging = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
    bodyVelocity, bodyGyro = nil, nil

    if flyEnabled then
        task.wait(0.1)
        startFly()
    end
    if WalkFlingButton.Text == "WalkFling [ON]" then
        task.wait(0.1)
        startWalkFling()
    end
end)
