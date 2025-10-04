--// Services
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local PathfindingService = game:GetService("PathfindingService")

--// Vars
local LocalPlayer = Players.LocalPlayer

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 230)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 26)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "Teleport Manager"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

-- Tombol Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -28, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = MainFrame

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= Title and child ~= MinBtn and child:IsA("GuiObject") then
                child.Visible = false
            end
        end
        MainFrame.Size = UDim2.new(0, 260, 0, 26)
    else
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child ~= Title and child ~= MinBtn and child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        MainFrame.Size = UDim2.new(0, 260, 0, 230)
    end
end)

-- Notifikasi
local NotifyText = Instance.new("TextLabel")
NotifyText.Size = UDim2.new(1, -20, 0, 20)
NotifyText.Position = UDim2.new(0, 10, 0, 30)
NotifyText.BackgroundTransparency = 1
NotifyText.Text = ""
NotifyText.TextColor3 = Color3.fromRGB(0, 200, 255)
NotifyText.Font = Enum.Font.GothamBold
NotifyText.TextSize = 12
NotifyText.Parent = MainFrame

-- ScrollBox untuk JSON
local JsonScroll = Instance.new("ScrollingFrame")
JsonScroll.Size = UDim2.new(1, -20, 0, 70)
JsonScroll.Position = UDim2.new(0, 10, 0, 55)
JsonScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
JsonScroll.ScrollBarThickness = 6
JsonScroll.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
JsonScroll.Parent = MainFrame
Instance.new("UICorner", JsonScroll).CornerRadius = UDim.new(0, 6)

local JsonBox = Instance.new("TextBox")
JsonBox.Size = UDim2.new(1, -10, 1, -10)
JsonBox.Position = UDim2.new(0, 5, 0, 5)
JsonBox.Text = ""
JsonBox.ClearTextOnFocus = false
JsonBox.MultiLine = true
JsonBox.TextXAlignment = Enum.TextXAlignment.Left
JsonBox.TextYAlignment = Enum.TextYAlignment.Top
JsonBox.TextWrapped = true
JsonBox.TextColor3 = Color3.new(1, 1, 1)
JsonBox.BackgroundTransparency = 1
JsonBox.Font = Enum.Font.Code
JsonBox.TextSize = 12
JsonBox.Parent = JsonScroll

JsonBox:GetPropertyChangedSignal("Text"):Connect(function()
    local textBounds = game:GetService("TextService"):GetTextSize(JsonBox.Text, JsonBox.TextSize, JsonBox.Font,
        Vector2.new(JsonBox.AbsoluteSize.X, math.huge))
    JsonScroll.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 10)
end)

-- Delay Box
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 80, 0, 20)
DelayLabel.Position = UDim2.new(0, 10, 0, 135)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Delay (s):"
DelayLabel.TextColor3 = Color3.new(1, 1, 1)
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.TextSize = 12
DelayLabel.Parent = MainFrame

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0, 50, 0, 20)
DelayBox.Position = UDim2.new(0, 90, 0, 135)
DelayBox.Text = "1.5"
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DelayBox.ClearTextOnFocus = false
DelayBox.Font = Enum.Font.Code
DelayBox.TextSize = 12
DelayBox.Parent = MainFrame
Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 6)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 28)
ToggleBtn.Position = UDim2.new(0, 10, 0, 160)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleBtn.Text = "Start"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

-- Radio Button
local OptionDead = Instance.new("TextButton")
OptionDead.Size = UDim2.new(0.5, -15, 0, 20)
OptionDead.Position = UDim2.new(0, 10, 0, 200)
OptionDead.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
OptionDead.TextColor3 = Color3.new(1, 1, 1)
OptionDead.Text = "[ ] Mati"
OptionDead.Font = Enum.Font.Gotham
OptionDead.TextSize = 11
OptionDead.Parent = MainFrame
Instance.new("UICorner", OptionDead).CornerRadius = UDim.new(0, 6)

local OptionRejoin = Instance.new("TextButton")
OptionRejoin.Size = UDim2.new(0.5, -15, 0, 20)
OptionRejoin.Position = UDim2.new(0.5, 5, 0, 200)
OptionRejoin.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
OptionRejoin.TextColor3 = Color3.new(1, 1, 1)
OptionRejoin.Text = "[ ] Rejoin"
OptionRejoin.Font = Enum.Font.Gotham
OptionRejoin.TextSize = 11
OptionRejoin.Parent = MainFrame
Instance.new("UICorner", OptionRejoin).CornerRadius = UDim.new(0, 6)

local mode = nil
local function setRadio(choice)
    mode = choice
    OptionDead.Text = (choice == "dead") and "[X] Mati" or "[ ] Mati"
    OptionRejoin.Text = (choice == "rejoin") and "[X] Rejoin" or "[ ] Rejoin"
end
OptionDead.MouseButton1Click:Connect(function() setRadio("dead") end)
OptionRejoin.MouseButton1Click:Connect(function() setRadio("rejoin") end)

-- Helpers
local function waitUntilAlive()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    while hum.Health <= 0 do
        task.wait(0.5)
        char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        hum = char:WaitForChild("Humanoid")
    end
    return char
end

-- fallback manual walk
local function manualWalk(hum, targetPos, tolerance)
    local hrp = hum.Parent:WaitForChild("HumanoidRootPart")
    tolerance = tolerance or 2
    while hum.Health > 0 do
        local dist = (hrp.Position - targetPos).Magnitude
        if dist <= tolerance then break end
        local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 4)
        local part = Workspace:FindPartOnRayWithIgnoreList(ray, { hum.Parent, Workspace.Terrain })
        if part then
            hum.Jump = true
        end
        hum:MoveTo(targetPos)
        local reached = hum.MoveToFinished:Wait(2)
        if not reached then break end
        task.wait()
    end
end

-- pathfinding dengan fallback
local function walkWithPath(hum, targetPos, speed)
    local char = hum.Parent
    local hrp = char:WaitForChild("HumanoidRootPart")
    local originalSpeed = hum.WalkSpeed
    if speed then hum.WalkSpeed = speed end

    -- buat path
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentWalkableClimb = 4,
        WaypointSpacing = 2
    })

    path:ComputeAsync(hrp.Position, targetPos)

    if path.Status == Enum.PathStatus.Complete then
        local waypoints = path:GetWaypoints()

        for i, wp in ipairs(waypoints) do
            if wp.Action == Enum.PathWaypointAction.Jump then
                hum.Jump = true
            end

            hum:MoveTo(wp.Position)
            -- tunggu sampai sampai atau timeout 3 detik
            local reached = hum.MoveToFinished:Wait(3)

            if not reached then
                warn("Stuck di waypoint", i)
                break
            end

            if hum.Health <= 0 then
                break
            end
        end
    else
        warn("Path gagal dibuat ke:", targetPos)
    end

    hum.WalkSpeed = originalSpeed
end


-- Main loop
local running = false
local function actionLoop(positions, delayTime)
    local index = 1
    while running do
        local char = waitUntilAlive()
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")
        local pos = positions[index]

        if pos.walk and typeof(pos.walk) == "number" then
            local target = hrp.Position + hrp.CFrame.LookVector * pos.walk
            NotifyText.Text = "Walking " .. pos.walk .. " studs"
            walkWithPath(hum, target)
        elseif pos.walk and typeof(pos.walk) == "table" and pos.walk.x and pos.walk.y and pos.walk.z then
            local target = Vector3.new(pos.walk.x, pos.walk.y, pos.walk.z)
            NotifyText.Text = string.format("Walking to (%.1f, %.1f, %.1f)", target.X, target.Y, target.Z)
            walkWithPath(hum, target)
        elseif pos.jump then
            for i = 1, pos.jump do
                NotifyText.Text = "Jump " .. i .. "/" .. pos.jump
                hum.Jump = true
                task.wait(0.4)
            end
        elseif pos.x and pos.y and pos.z then
            local target = Vector3.new(pos.x, pos.y, pos.z)
            hrp.CFrame = CFrame.new(target)
            NotifyText.Text = string.format("Teleport ke (%.1f, %.1f, %.1f)", target.X, target.Y, target.Z)
        end

        task.wait(delayTime)

        index += 1
        if index > #positions then
            if mode == "dead" then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid.Health = 0
                end
                index = 1
                waitUntilAlive()
            elseif mode == "rejoin" then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
                running = false
                break
            else
                index = 1
            end
        end
    end
    NotifyText.Text = ""
end

-- Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    if running then
        running = false
        ToggleBtn.Text = "Start"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        local success, positions = pcall(function()
            return HttpService:JSONDecode(JsonBox.Text)
        end)
        if success and typeof(positions) == "table" then
            local delayTime = tonumber(DelayBox.Text) or 1.5
            running = true
            ToggleBtn.Text = "Stop"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            task.spawn(function()
                actionLoop(positions, delayTime)
            end)
        else
            NotifyText.Text = "JSON tidak valid!"
        end
    end
end)
