--// Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().FPDH = workspace.FallenPartsDestroyHeight
getgenv().OldPos = CFrame.new()

-- Simple message
local function Message(title, text, time)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = time or 3
        })
    end)
end

-- SkidFling (full function kamu, unchanged)
local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter and TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter and TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter and TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end

        if THumanoid and THumanoid.Sit then
            return Message("Error", "Target is sitting", 3)
        end

        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local function FPos(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local function SFBasePart(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart,
                            CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart,
                            CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart,
                            CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart,
                            CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25,
                            CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,
                            CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,
                            CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25),
                            CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25),
                            CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end

        workspace.FallenPartsDestroyHeight = 0 / 0
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1 / 0, 1 / 0, 1 / 0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            for _, x in ipairs(Character:GetChildren()) do
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Occurred", "Random error", 5)
    end
end

--// GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "SkidFlingUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 220) -- mobile-friendly
Frame.Position = UDim2.new(0.35, 0, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Title bar
local TitleBar = Instance.new("TextLabel", Frame)
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, -40, 0, 28)
TitleBar.Position = UDim2.new(0, 8, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Text = "⚡ SkidFling GUI"
TitleBar.TextColor3 = Color3.new(1, 1, 1)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 14
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -34, 0, 0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
local BtnCorner = Instance.new("UICorner", MinBtn)
BtnCorner.CornerRadius = UDim.new(0, 8)

-- Search box
local SearchBox = Instance.new("TextBox", Frame)
SearchBox.Size = UDim2.new(1, -20, 0, 24)
SearchBox.Position = UDim2.new(0, 10, 0, 35)
SearchBox.PlaceholderText = "Search by name or username..."
SearchBox.Text = ""
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.TextColor3 = Color3.new(1, 1, 1)
local SearchCorner = Instance.new("UICorner", SearchBox)
SearchCorner.CornerRadius = UDim.new(0, 6)

-- Player list
local PlayerList = Instance.new("ScrollingFrame", Frame)
PlayerList.Size = UDim2.new(1, -20, 0, 110)
PlayerList.Position = UDim2.new(0, 10, 0, 65)
PlayerList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerList.ScrollBarThickness = 6
local ListCorner = Instance.new("UICorner", PlayerList)
ListCorner.CornerRadius = UDim.new(0, 6)
local UIList = Instance.new("UIListLayout", PlayerList)
UIList.Padding = UDim.new(0, 4)

-- Buttons
local AttackBtn = Instance.new("TextButton", Frame)
AttackBtn.Size = UDim2.new(0.5, -12, 0, 28)
AttackBtn.Position = UDim2.new(0, 10, 1, -34)
AttackBtn.Text = "⚔️ Attack"
AttackBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AttackBtn.TextColor3 = Color3.new(1, 1, 1)
local AC = Instance.new("UICorner", AttackBtn)
AC.CornerRadius = UDim.new(0, 6)

local CancelBtn = Instance.new("TextButton", Frame)
CancelBtn.Size = UDim2.new(0.5, -12, 0, 28)
CancelBtn.Position = UDim2.new(0.5, 2, 1, -34)
CancelBtn.Text = "🚫 Cancel"
CancelBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
CancelBtn.TextColor3 = Color3.new(1, 1, 1)
local CC = Instance.new("UICorner", CancelBtn)
CC.CornerRadius = UDim.new(0, 6)

-- Logic
local CurrentTarget

-- Update list function
local function UpdateList()
    -- clear buttons only
    for _, c in ipairs(PlayerList:GetChildren()) do
        if c:IsA("TextButton") then
            c:Destroy()
        end
    end

    local search = (SearchBox.Text or ""):lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local uname = plr.Name:lower()
            local dname = plr.DisplayName:lower()
            if search == "" or string.find(uname, search) or string.find(dname, search) then
                local Btn = Instance.new("TextButton", PlayerList)
                Btn.Size = UDim2.new(1, -6, 0, 26)
                Btn.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
                Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                Btn.TextColor3 = Color3.new(1, 1, 1)
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 14
                local BC = Instance.new("UICorner", Btn)
                BC.CornerRadius = UDim.new(0, 6)
                Btn.MouseButton1Click:Connect(function()
                    CurrentTarget = plr
                    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                        Camera.CameraSubject = plr.Character:FindFirstChild("Humanoid")
                        Message("Spectating", "Now spectating " .. plr.DisplayName, 2)
                    end
                end)
            end
        end
    end
    -- update canvas size after layout
    task.wait() -- allow layout to compute
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 6)
end

Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateList)
UpdateList()

-- Attack button
AttackBtn.MouseButton1Click:Connect(function()
    if CurrentTarget then
        pcall(function() SkidFling(CurrentTarget) end)
    else
        Message("Error", "No target selected", 2)
    end
end)

-- Cancel spectate
CancelBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
    CurrentTarget = nil
    Message("Stopped", "Cancelled spectate", 2)
end)

-- Minimize (fixed: only toggle GuiObject children, exclude TitleBar & MinBtn)
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(Frame:GetChildren()) do
        if obj:IsA("GuiObject") and obj ~= TitleBar and obj ~= MinBtn then
            obj.Visible = not minimized
        end
    end
    Frame.Size = minimized and UDim2.new(0, 240, 0, 28) or UDim2.new(0, 240, 0, 220)
end)
