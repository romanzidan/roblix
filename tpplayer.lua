--// Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
StarterGui:SetCore("SendNotification", {
    Title = "TROLL PLAYER Active",
    Text = "Created by @lildanzvert",
    Duration = 5
})
--// Vars
local flyEnabled, flying = false, false
local walkflinging = false
local flyConnection, walkFlingConnection
local bodyVelocity, bodyGyro
local lastLookDirection = Vector3.new()
local CurrentTarget, LastPosition = nil, nil
local TpTrollActive = false

--// Helpers
local function getCharacter()
    return LocalPlayer.Character
end
local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function waitForControlModule()
    local playerModule = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
    return playerModule:GetControls()
end

--// Fly
local function startFly()
    local char = getCharacter()
    local root = getRootPart()
    if not char or not root then return end
    flying, flyEnabled = true, true

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
        local moveVec = controlModule and controlModule:GetMoveVector() or Vector3.zero
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
    flying, flyEnabled = false, false
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

--// WalkFling
local function addHitbox(size)
    local root = getRootPart()
    if not root then return end
    if root:FindFirstChild("FlingHitbox") then root.FlingHitbox:Destroy() end
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
    addHitbox(Vector3.new(50, 50, 50))
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
    if root and root:FindFirstChild("FlingHitbox") then root.FlingHitbox:Destroy() end
end

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlayerListGui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 10 ^ 6
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 300)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Selectable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(80, 80, 80)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -30, 0, 30)
Title.Text = "LILDANZ TROLL"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Parent = MainFrame

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -10, 0, 20)
StatusLbl.Position = UDim2.new(0, 5, 0, 35)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.new(1, 1, 1)
StatusLbl.Font = Enum.Font.SourceSansItalic
StatusLbl.TextSize = 14
StatusLbl.Text = "Not Spectating"
StatusLbl.Parent = MainFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 25)
SearchBox.Position = UDim2.new(0, 5, 0, 60)
SearchBox.PlaceholderText = "Search player..."
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.ClearTextOnFocus = false
SearchBox.Text = ""
SearchBox.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -130)
Scroll.Position = UDim2.new(0, 5, 0, 90)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarThickness = 6
Scroll.BackgroundTransparency = 1
Scroll.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = Scroll

-- tambahin padding dummy di paling bawah
local bottomPad = Instance.new("Frame")
bottomPad.Size = UDim2.new(1, 0, 0, 40) -- tinggi 50px
bottomPad.BackgroundTransparency = 1
bottomPad.LayoutOrder = 999999
bottomPad.Parent = Scroll

local TpOnceBtn = Instance.new("TextButton")
TpOnceBtn.Size = UDim2.new(0.5, -7, 0, 30)
TpOnceBtn.Position = UDim2.new(0, 5, 1, -65)
TpOnceBtn.Text = "TP Sekali"
TpOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TpOnceBtn.TextColor3 = Color3.new(1, 1, 1)
TpOnceBtn.Font = Enum.Font.SourceSansBold
TpOnceBtn.TextSize = 16
TpOnceBtn.Parent = MainFrame

local TpTrollBtn = Instance.new("TextButton")
TpTrollBtn.Size = UDim2.new(0.5, -7, 0, 30)
TpTrollBtn.Position = UDim2.new(0.5, 2, 1, -65)
TpTrollBtn.Text = "TP TROLL"
TpTrollBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
TpTrollBtn.TextColor3 = Color3.new(1, 1, 1)
TpTrollBtn.Font = Enum.Font.SourceSansBold
TpTrollBtn.TextSize = 16
TpTrollBtn.Parent = MainFrame

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(1, -10, 0, 30)
CancelBtn.Position = UDim2.new(0, 5, 1, -30)
CancelBtn.Text = "Cancel Spectate"
CancelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CancelBtn.TextColor3 = Color3.new(1, 1, 1)
CancelBtn.Font = Enum.Font.SourceSansBold
CancelBtn.TextSize = 16
CancelBtn.Parent = MainFrame

-- Tambahkan UICorner ke semua tombol & textbox untuk modern look
local function Roundify(obj, radius)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, radius or 8)
    uic.Parent = obj
end

for _, ui in ipairs({ MinBtn, TpOnceBtn, TpTrollBtn, CancelBtn, SearchBox, Title, MainFrame }) do
    Roundify(ui, 8)
end

--// Logic
local CurrentFilter = ""

local function UpdatePlayerList()
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local nameLower, displayLower = plr.Name:lower(), plr.DisplayName:lower()
            if CurrentFilter == "" or string.find(nameLower, CurrentFilter) or string.find(displayLower, CurrentFilter) then
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -10, 0, 30)
                Btn.Text = plr.Name .. " (" .. plr.DisplayName .. ")"
                Btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                Btn.TextColor3 = Color3.new(1, 1, 1)
                Btn.Font = Enum.Font.SourceSans
                Btn.TextSize = 16
                Btn.Parent = Scroll
                Btn.MouseButton1Click:Connect(function()
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        Camera.CameraSubject = plr.Character.Humanoid
                        CurrentTarget = plr
                        StatusLbl.Text = "Spectating " .. plr.Name
                    end
                end)
            end
        end
    end
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
end

TpOnceBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") and hrp then
        if not LastPosition then LastPosition = hrp.CFrame end
        hrp.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    end
    -- kamera balik ke saya
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
    StatusLbl.Text = "Not Spectating"
end)

TpTrollBtn.MouseButton1Click:Connect(function()
    TpTrollActive = not TpTrollActive
    if TpTrollActive then
        TpTrollBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        TpTrollBtn.Text = "TP TROLL [ON]"
        startFly()
        startWalkFling()
        task.spawn(function()
            while TpTrollActive do
                task.wait(0.1)
                if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = getRootPart()
                    if hrp then
                        if not LastPosition then LastPosition = hrp.CFrame end
                        hrp.CFrame = CurrentTarget.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end)
    else
        TpTrollBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        TpTrollBtn.Text = "TP TROLL"
        stopFly()
        stopWalkFling()
    end
end)

-- === Fungsi Cancel Spectate ===
local function CancelSpectate()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
        if LastPosition and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LastPosition
            LastPosition = nil
        end
        CurrentTarget = nil
        StatusLbl.Text = "Not Spectating"
    end
    -- paksa off TP Troll + stop fly/walkfling
    TpTrollActive = false
    TpTrollBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    TpTrollBtn.Text = "TP TROLL"
    task.wait(0.5)
    stopFly()
    stopWalkFling()
end

-- Cancel via Button
CancelBtn.MouseButton1Click:Connect(CancelSpectate)

-- Cancel via Hotkey G
-- Cancel via Hotkey G atau Volume Down (Mobile)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe then
        if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.VolumeDown then
            StarterGui:SetCore("SendNotification", {
                Title = "Cancel Spectate",
                Text = "Created by @lildanzvert",
                Duration = 5
            })
            CancelSpectate()
        end
    end
end)

-- cek setiap UI baru yang muncul
local function watchGameplayPaused()
    CoreGui.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") and obj.Text == "Gameplay Paused" then
            print("Gameplay Paused UI ditemukan!")

            -- tunggu klik layar apapun untuk cancel spectate
            local connection
            connection = UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe and (input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch) then
                    CancelSpectate()
                    if connection then
                        connection:Disconnect()
                        connection = nil
                    end
                end
            end)
        end
    end)
end

task.spawn(watchGameplayPaused)


-- MINIMIZE FIX
local Minimized = false
MinBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child ~= Title and child ~= MinBtn then
                child.Visible = false
            end
        end
        MainFrame.Size = UDim2.new(0, 200, 0, 30)
        MinBtn.Text = "+"
    else
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
        MainFrame.Size = UDim2.new(0, 200, 0, 300)
        MinBtn.Text = "-"
    end
end)


SearchBox.Focused:Connect(function() SearchBox.Text = "" end)
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    CurrentFilter = SearchBox.Text:lower()
    UpdatePlayerList()
end)
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)
UpdatePlayerList()
