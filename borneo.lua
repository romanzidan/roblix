--RELOAD GUI
if game.CoreGui:FindFirstChild("SysBroker") then
    game:GetService("StarterGui"):SetCore("SendNotification",
        { Title = "CALE HENITUSE", Text = "GUI Already loaded, rejoin to re-execute", Duration = 5, })
    return
end
local version = 2
--VARIABLES
_G.AntiFlingToggled = false
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Light = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or
    request
local mouse = plr:GetMouse()
local ScriptWhitelist = {}
local ForceWhitelist = {}
local TargetedPlayer = nil
local FlySpeed = 50
local SavedCheckpoint = nil
local MinesFolder = nil

--FUNCTIONS
_G.shield = function(id)
    if not table.find(ForceWhitelist, id) then
        table.insert(ForceWhitelist, id)
    end
end

local function RandomChar()
    local length = math.random(1, 5)
    local array = {}
    for i = 1, length do
        array[i] = string.char(math.random(32, 126))
    end
    return table.concat(array)
end

local function ChangeToggleColor(Button)
    led = Button.Ticket_Asset
    if led.ImageColor3 == Color3.fromRGB(255, 0, 0) then
        led.ImageColor3 = Color3.fromRGB(0, 255, 0)
    else
        led.ImageColor3 = Color3.fromRGB(255, 0, 0)
    end
end

local function GetPing()
    return (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) / 1000
end

local function GetPlayer(UserDisplay)
    if UserDisplay ~= "" then
        for i, v in pairs(Players:GetPlayers()) do
            if v.Name:lower():match(UserDisplay) or v.DisplayName:lower():match(UserDisplay) then
                return v
            end
        end
        return nil
    else
        return nil
    end
end

local function GetCharacter(Player)
    if Player.Character then
        return Player.Character
    end
end

local function GetRoot(Player)
    if GetCharacter(Player):FindFirstChild("HumanoidRootPart") then
        return GetCharacter(Player).HumanoidRootPart
    end
end

local function TeleportTO(posX, posY, posZ, player, method)
    pcall(function()
        if method == "safe" then
            task.spawn(function()
                for i = 1, 30 do
                    task.wait()
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                    if player == "pos" then
                        GetRoot(plr).CFrame = CFrame.new(posX, posY, posZ)
                    else
                        GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position) + Vector3.new(0, 2, 0)
                    end
                end
            end)
        else
            GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
            if player == "pos" then
                GetRoot(plr).CFrame = CFrame.new(posX, posY, posZ)
            else
                GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position) + Vector3.new(0, 2, 0)
            end
        end
    end)
end

local function PredictionTP(player, method)
    local root = GetRoot(player)
    local pos = root.Position
    local vel = root.Velocity
    GetRoot(plr).CFrame = CFrame.new((pos.X) + (vel.X) * (GetPing() * 3.5), (pos.Y) + (vel.Y) * (GetPing() * 2),
        (pos.Z) + (vel.Z) * (GetPing() * 3.5))
    if method == "safe" then
        task.wait()
        GetRoot(plr).CFrame = CFrame.new(pos)
        task.wait()
        GetRoot(plr).CFrame = CFrame.new((pos.X) + (vel.X) * (GetPing() * 3.5), (pos.Y) + (vel.Y) * (GetPing() * 2),
            (pos.Z) + (vel.Z) * (GetPing() * 3.5))
    end
end

local function Touch(x, root)
    pcall(function()
        x = x:FindFirstAncestorWhichIsA("Part")
        if x then
            if firetouchinterest then
                task.spawn(function()
                    firetouchinterest(x, root, 1)
                    task.wait()
                    firetouchinterest(x, root, 0)
                end)
            end
        end
    end)
end


local function GetPush()
    local TempPush = nil
    pcall(function()
        if plr.Backpack:FindFirstChild("Push") then
            PushTool = plr.Backpack.Push
            PushTool.Parent = plr.Character
            TempPush = PushTool
        end
        for i, v in pairs(Players:GetPlayers()) do
            if v.Character:FindFirstChild("Push") then
                TempPush = v.Character.Push
            end
        end
    end)
    return TempPush
end

local function Push(Target)
    local Push = GetPush()
    local FixTool = nil
    if Push ~= nil then
        local args = { [1] = Target.Character }
        GetPush().PushTool:FireServer(unpack(args))
    end
    if plr.Character:FindFirstChild("Push") then
        plr.Character.Push.Parent = plr.Backpack
    end
    if plr.Character:FindFirstChild("ModdedPush") then
        FixTool = plr.Character:FindFirstChild("ModdedPush")
        FixTool.Parent = plr.Backpack
        FixTool.Parent = plr.Character
    end
    if plr.Character:FindFirstChild("ClickTarget") then
        FixTool = plr.Character:FindFirstChild("ClickTarget")
        FixTool.Parent = plr.Backpack
        FixTool.Parent = plr.Character
    end
end

local function ToggleRagdoll(bool)
    pcall(function()
        plr.Character["Falling down"].Disabled = bool
        plr.Character["Swimming"].Disabled = bool
        plr.Character["StartRagdoll"].Disabled = bool
        plr.Character["Pushed"].Disabled = bool
        plr.Character["RagdollMe"].Disabled = bool
    end)
end

local function ToggleVoidProtection(bool)
    if bool then
        game.Workspace.FallenPartsDestroyHeight = 0 / 0
    else
        game.Workspace.FallenPartsDestroyHeight = -500
    end
end

local function SendNotify(title, message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = message, Duration = duration, })
end

--LOAD GUI
task.wait(0.1)
local SysBroker = Instance.new("ScreenGui")
local Background = Instance.new("ImageLabel")
local TitleBarLabel = Instance.new("TextLabel")
local SectionList = Instance.new("Frame")
local Character_Section_Button = Instance.new("TextButton")
local Target_Section_Button = Instance.new("TextButton")
local TouchFling_Button = Instance.new("TextButton")
local Character_Section = Instance.new("ScrollingFrame")
local WalkSpeed_Button = Instance.new("TextButton")
local WalkSpeed_Input = Instance.new("TextBox")
local ClearCheckpoint_Button = Instance.new("TextButton")
local JumpPower_Input = Instance.new("TextBox")
local JumpPower_Button = Instance.new("TextButton")
local SaveCheckpoint_Button = Instance.new("TextButton")
local Respawn_Button = Instance.new("TextButton")
local FlySpeed_Button = Instance.new("TextButton")
local FlySpeed_Input = Instance.new("TextBox")
local Fly_Button = Instance.new("TextButton")
local Target_Section = Instance.new("ScrollingFrame")
local TargetImage = Instance.new("ImageLabel")
local ClickTargetTool_Button = Instance.new("ImageButton")
local TargetName_Input = Instance.new("TextBox")
local UserIDTargetLabel = Instance.new("TextLabel")
local ViewTarget_Button = Instance.new("TextButton")
local FlingTarget_Button = Instance.new("TextButton")
local FocusTarget_Button = Instance.new("TextButton")
local BenxTarget_Button = Instance.new("TextButton")
local PushTarget_Button = Instance.new("TextButton")
local WhitelistTarget_Button = Instance.new("TextButton")
local TeleportTarget_Button = Instance.new("TextButton")
local HeadsitTarget_Button = Instance.new("TextButton")
local StandTarget_Button = Instance.new("TextButton")
local BackpackTarget_Button = Instance.new("TextButton")
local DoggyTarget_Button = Instance.new("TextButton")
local DragTarget_Button = Instance.new("TextButton")
--NEWS
local Assets = Instance.new("Folder")
local Ticket_Asset = Instance.new("ImageButton")
local Click_Asset = Instance.new("ImageButton")
local Velocity_Asset = Instance.new("BodyAngularVelocity")
local Fly_Pad = Instance.new("ImageButton")
local UIGradient = Instance.new("UIGradient")
local FlyAButton = Instance.new("TextButton")
local FlyDButton = Instance.new("TextButton")
local FlyWButton = Instance.new("TextButton")
local FlySButton = Instance.new("TextButton")
local OpenClose = Instance.new("ImageButton")
local UICornerOC = Instance.new("UICorner")

local function CreateToggle(Button)
    local NewToggle = Ticket_Asset:Clone()
    NewToggle.Parent = Button
end

local function CreateClicker(Button)
    local NewClicker = Click_Asset:Clone()
    NewClicker.Parent = Button
end

SysBroker.Name = "SysBroker"
SysBroker.Parent = game.CoreGui
SysBroker.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Background.Name = "Background"
Background.Parent = SysBroker
Background.AnchorPoint = Vector2.new(0.5, 0.5)
Background.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Background.BackgroundTransparency = 0.700
Background.BorderColor3 = Color3.fromRGB(0, 255, 255)
Background.Position = UDim2.new(0.5, 0, 0.5, 0)
Background.Size = UDim2.new(0, 500, 0, 350)
Background.ZIndex = 9
Background.ScaleType = Enum.ScaleType.Tile
Background.SliceCenter = Rect.new(0, 256, 0, 256)
Background.TileSize = UDim2.new(0, 30, 0, 30)
Background.Active = true
Background.Draggable = true

TitleBarLabel.Name = "TitleBarLabel"
TitleBarLabel.Parent = Background
TitleBarLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBarLabel.BackgroundTransparency = 0.250
TitleBarLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TitleBarLabel.BorderSizePixel = 0
TitleBarLabel.Size = UDim2.new(1, 0, 0, 30)
TitleBarLabel.Font = Enum.Font.Unknown
TitleBarLabel.Text = "SISTEM RUSAK"
TitleBarLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TitleBarLabel.TextScaled = true
TitleBarLabel.TextSize = 14.000
TitleBarLabel.TextWrapped = true
TitleBarLabel.TextXAlignment = Enum.TextXAlignment.Left

SectionList.Name = "SectionList"
SectionList.Parent = Background
SectionList.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
SectionList.BackgroundTransparency = 0.500
SectionList.BorderColor3 = Color3.fromRGB(0, 0, 0)
SectionList.BorderSizePixel = 0
SectionList.Position = UDim2.new(0, 0, 0, 30)
SectionList.Size = UDim2.new(0, 105, 0, 250)

Character_Section_Button.Name = "Character_Section_Button"
Character_Section_Button.Parent = SectionList
Character_Section_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Character_Section_Button.BackgroundTransparency = 0.500
Character_Section_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
Character_Section_Button.BorderSizePixel = 0
Character_Section_Button.Position = UDim2.new(0, 0, 0, 105)
Character_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Character_Section_Button.Font = Enum.Font.Oswald
Character_Section_Button.Text = "Character"
Character_Section_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Character_Section_Button.TextScaled = true
Character_Section_Button.TextSize = 14.000
Character_Section_Button.TextWrapped = true

Target_Section_Button.Name = "Target_Section_Button"
Target_Section_Button.Parent = SectionList
Target_Section_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Target_Section_Button.BackgroundTransparency = 0.500
Target_Section_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
Target_Section_Button.BorderSizePixel = 0
Target_Section_Button.Position = UDim2.new(0, 0, 0, 145)
Target_Section_Button.Size = UDim2.new(0, 105, 0, 30)
Target_Section_Button.Font = Enum.Font.Oswald
Target_Section_Button.Text = "Target"
Target_Section_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Target_Section_Button.TextScaled = true
Target_Section_Button.TextSize = 14.000
Target_Section_Button.TextWrapped = true

Character_Section.Name = "Character_Section"
Character_Section.Parent = Background
Character_Section.Active = true
Character_Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Character_Section.BackgroundTransparency = 1.000
Character_Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
Character_Section.BorderSizePixel = 0
Character_Section.Position = UDim2.new(0, 105, 0, 30)
Character_Section.Size = UDim2.new(0, 395, 0, 320)
Character_Section.Visible = false
Character_Section.CanvasSize = UDim2.new(0, 0, 1, 0)
Character_Section.ScrollBarThickness = 5

WalkSpeed_Button.Name = "WalkSpeed_Button"
WalkSpeed_Button.Parent = Character_Section
WalkSpeed_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
WalkSpeed_Button.BackgroundTransparency = 0.500
WalkSpeed_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
WalkSpeed_Button.BorderSizePixel = 0
WalkSpeed_Button.Position = UDim2.new(0, 25, 0, 25)
WalkSpeed_Button.Size = UDim2.new(0, 150, 0, 30)
WalkSpeed_Button.Font = Enum.Font.Oswald
WalkSpeed_Button.Text = "Walk Speed"
WalkSpeed_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
WalkSpeed_Button.TextScaled = true
WalkSpeed_Button.TextSize = 14.000
WalkSpeed_Button.TextWrapped = true

WalkSpeed_Input.Name = "WalkSpeed_Input"
WalkSpeed_Input.Parent = Character_Section
WalkSpeed_Input.BackgroundColor3 = Color3.fromRGB(0, 140, 140)
WalkSpeed_Input.BackgroundTransparency = 0.300
WalkSpeed_Input.BorderColor3 = Color3.fromRGB(0, 255, 255)
WalkSpeed_Input.Position = UDim2.new(0, 210, 0, 25)
WalkSpeed_Input.Size = UDim2.new(0, 175, 0, 30)
WalkSpeed_Input.Font = Enum.Font.Gotham
WalkSpeed_Input.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
WalkSpeed_Input.PlaceholderText = "Number [1-99999]"
WalkSpeed_Input.Text = ""
WalkSpeed_Input.TextColor3 = Color3.fromRGB(20, 20, 20)
WalkSpeed_Input.TextSize = 14.000
WalkSpeed_Input.TextWrapped = true

ClearCheckpoint_Button.Name = "ClearCheckpoint_Button"
ClearCheckpoint_Button.Parent = Character_Section
ClearCheckpoint_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
ClearCheckpoint_Button.BackgroundTransparency = 0.500
ClearCheckpoint_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
ClearCheckpoint_Button.BorderSizePixel = 0
ClearCheckpoint_Button.Position = UDim2.new(0, 210, 0, 225)
ClearCheckpoint_Button.Size = UDim2.new(0, 150, 0, 30)
ClearCheckpoint_Button.Font = Enum.Font.Oswald
ClearCheckpoint_Button.Text = "Clear checkpoint"
ClearCheckpoint_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
ClearCheckpoint_Button.TextScaled = true
ClearCheckpoint_Button.TextSize = 14.000
ClearCheckpoint_Button.TextWrapped = true

JumpPower_Input.Name = "JumpPower_Input"
JumpPower_Input.Parent = Character_Section
JumpPower_Input.BackgroundColor3 = Color3.fromRGB(0, 140, 140)
JumpPower_Input.BackgroundTransparency = 0.300
JumpPower_Input.BorderColor3 = Color3.fromRGB(0, 255, 255)
JumpPower_Input.Position = UDim2.new(0, 210, 0, 75)
JumpPower_Input.Size = UDim2.new(0, 175, 0, 30)
JumpPower_Input.Font = Enum.Font.Gotham
JumpPower_Input.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
JumpPower_Input.PlaceholderText = "Number [1-99999]"
JumpPower_Input.Text = ""
JumpPower_Input.TextColor3 = Color3.fromRGB(20, 20, 20)
JumpPower_Input.TextSize = 14.000
JumpPower_Input.TextWrapped = true

JumpPower_Button.Name = "JumpPower_Button"
JumpPower_Button.Parent = Character_Section
JumpPower_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
JumpPower_Button.BackgroundTransparency = 0.500
JumpPower_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
JumpPower_Button.BorderSizePixel = 0
JumpPower_Button.Position = UDim2.new(0, 25, 0, 75)
JumpPower_Button.Size = UDim2.new(0, 150, 0, 30)
JumpPower_Button.Font = Enum.Font.Oswald
JumpPower_Button.Text = "Jump power"
JumpPower_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
JumpPower_Button.TextScaled = true
JumpPower_Button.TextSize = 14.000
JumpPower_Button.TextWrapped = true

SaveCheckpoint_Button.Name = "SaveCheckpoint_Button"
SaveCheckpoint_Button.Parent = Character_Section
SaveCheckpoint_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
SaveCheckpoint_Button.BackgroundTransparency = 0.500
SaveCheckpoint_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
SaveCheckpoint_Button.BorderSizePixel = 0
SaveCheckpoint_Button.Position = UDim2.new(0, 210, 0, 175)
SaveCheckpoint_Button.Size = UDim2.new(0, 150, 0, 30)
SaveCheckpoint_Button.Font = Enum.Font.Oswald
SaveCheckpoint_Button.Text = "Save checkpoint"
SaveCheckpoint_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
SaveCheckpoint_Button.TextScaled = true
SaveCheckpoint_Button.TextSize = 14.000
SaveCheckpoint_Button.TextWrapped = true

Respawn_Button.Name = "Respawn_Button"
Respawn_Button.Parent = Character_Section
Respawn_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Respawn_Button.BackgroundTransparency = 0.500
Respawn_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
Respawn_Button.BorderSizePixel = 0
Respawn_Button.Position = UDim2.new(0, 25, 0, 225)
Respawn_Button.Size = UDim2.new(0, 150, 0, 30)
Respawn_Button.Font = Enum.Font.Oswald
Respawn_Button.Text = "Respawn"
Respawn_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Respawn_Button.TextScaled = true
Respawn_Button.TextSize = 14.000
Respawn_Button.TextWrapped = true

FlySpeed_Button.Name = "FlySpeed_Button"
FlySpeed_Button.Parent = Character_Section
FlySpeed_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
FlySpeed_Button.BackgroundTransparency = 0.500
FlySpeed_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlySpeed_Button.BorderSizePixel = 0
FlySpeed_Button.Position = UDim2.new(0, 25, 0, 125)
FlySpeed_Button.Size = UDim2.new(0, 150, 0, 30)
FlySpeed_Button.Font = Enum.Font.Oswald
FlySpeed_Button.Text = "Fly speed"
FlySpeed_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
FlySpeed_Button.TextScaled = true
FlySpeed_Button.TextSize = 14.000
FlySpeed_Button.TextWrapped = true

FlySpeed_Input.Name = "FlySpeed_Input"
FlySpeed_Input.Parent = Character_Section
FlySpeed_Input.BackgroundColor3 = Color3.fromRGB(0, 140, 140)
FlySpeed_Input.BackgroundTransparency = 0.300
FlySpeed_Input.BorderColor3 = Color3.fromRGB(0, 255, 255)
FlySpeed_Input.Position = UDim2.new(0, 210, 0, 125)
FlySpeed_Input.Size = UDim2.new(0, 175, 0, 30)
FlySpeed_Input.Font = Enum.Font.Gotham
FlySpeed_Input.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
FlySpeed_Input.PlaceholderText = "Number [1-99999]"
FlySpeed_Input.Text = ""
FlySpeed_Input.TextColor3 = Color3.fromRGB(20, 20, 20)
FlySpeed_Input.TextSize = 14.000
FlySpeed_Input.TextWrapped = true

Fly_Button.Name = "Fly_Button"
Fly_Button.Parent = Character_Section
Fly_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Fly_Button.BackgroundTransparency = 0.500
Fly_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
Fly_Button.BorderSizePixel = 0
Fly_Button.Position = UDim2.new(0, 25, 0, 175)
Fly_Button.Size = UDim2.new(0, 150, 0, 30)
Fly_Button.Font = Enum.Font.Oswald
Fly_Button.Text = "Fly"
Fly_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
Fly_Button.TextScaled = true
Fly_Button.TextSize = 14.000
Fly_Button.TextWrapped = true

Target_Section.Name = "Target_Section"
Target_Section.Parent = Background
Target_Section.Active = true
Target_Section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Target_Section.BackgroundTransparency = 1.000
Target_Section.BorderColor3 = Color3.fromRGB(0, 0, 0)
Target_Section.BorderSizePixel = 0
Target_Section.Position = UDim2.new(0, 105, 0, 30)
Target_Section.Size = UDim2.new(0, 395, 0, 320)
Target_Section.Visible = false
Target_Section.CanvasSize = UDim2.new(0, 0, 1.25, 0)
Target_Section.ScrollBarThickness = 5

TargetImage.Name = "TargetImage"
TargetImage.Parent = Target_Section
TargetImage.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TargetImage.BorderColor3 = Color3.fromRGB(0, 255, 255)
TargetImage.Position = UDim2.new(0, 25, 0, 25)
TargetImage.Size = UDim2.new(0, 100, 0, 100)
TargetImage.Image = "rbxassetid://10818605405"

TargetName_Input.Name = "TargetName_Input"
TargetName_Input.Parent = Target_Section
TargetName_Input.BackgroundColor3 = Color3.fromRGB(0, 140, 140)
TargetName_Input.BackgroundTransparency = 0.300
TargetName_Input.BorderColor3 = Color3.fromRGB(0, 255, 255)
TargetName_Input.Position = UDim2.new(0, 150, 0, 30)
TargetName_Input.Size = UDim2.new(0, 175, 0, 30)
TargetName_Input.Font = Enum.Font.Gotham
TargetName_Input.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
TargetName_Input.PlaceholderText = "@target..."
TargetName_Input.Text = ""
TargetName_Input.TextColor3 = Color3.fromRGB(20, 20, 20)
TargetName_Input.TextSize = 14.000
TargetName_Input.TextWrapped = true

ClickTargetTool_Button.Name = "ClickTargetTool_Button"
ClickTargetTool_Button.Parent = TargetName_Input
ClickTargetTool_Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ClickTargetTool_Button.BackgroundTransparency = 1.000
ClickTargetTool_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
ClickTargetTool_Button.BorderSizePixel = 0
ClickTargetTool_Button.Position = UDim2.new(0, 180, 0, 0)
ClickTargetTool_Button.Size = UDim2.new(0, 30, 0, 30)
ClickTargetTool_Button.Image = "rbxassetid://2716591855"

UserIDTargetLabel.Name = "UserIDTargetLabel"
UserIDTargetLabel.Parent = Target_Section
UserIDTargetLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
UserIDTargetLabel.BackgroundTransparency = 1.000
UserIDTargetLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
UserIDTargetLabel.BorderSizePixel = 0
UserIDTargetLabel.Position = UDim2.new(0, 150, 0, 70)
UserIDTargetLabel.Size = UDim2.new(0, 300, 0, 75)
UserIDTargetLabel.Font = Enum.Font.Oswald
UserIDTargetLabel.Text = "UserID: \nDisplay: \nJoined: "
UserIDTargetLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
UserIDTargetLabel.TextSize = 18.000
UserIDTargetLabel.TextWrapped = true
UserIDTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
UserIDTargetLabel.TextYAlignment = Enum.TextYAlignment.Top

ViewTarget_Button.Name = "ViewTarget_Button"
ViewTarget_Button.Parent = Target_Section
ViewTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
ViewTarget_Button.BackgroundTransparency = 0.500
ViewTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
ViewTarget_Button.BorderSizePixel = 0
ViewTarget_Button.Position = UDim2.new(0, 210, 0, 150)
ViewTarget_Button.Size = UDim2.new(0, 150, 0, 30)
ViewTarget_Button.Font = Enum.Font.Oswald
ViewTarget_Button.Text = "View"
ViewTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
ViewTarget_Button.TextScaled = true
ViewTarget_Button.TextSize = 14.000
ViewTarget_Button.TextWrapped = true

FlingTarget_Button.Name = "FlingTarget_Button"
FlingTarget_Button.Parent = Target_Section
FlingTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
FlingTarget_Button.BackgroundTransparency = 0.500
FlingTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlingTarget_Button.BorderSizePixel = 0
FlingTarget_Button.Position = UDim2.new(0, 25, 0, 150)
FlingTarget_Button.Size = UDim2.new(0, 150, 0, 30)
FlingTarget_Button.Font = Enum.Font.Oswald
FlingTarget_Button.Text = "Fling"
FlingTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
FlingTarget_Button.TextScaled = true
FlingTarget_Button.TextSize = 14.000
FlingTarget_Button.TextWrapped = true

FocusTarget_Button.Name = "FocusTarget_Button"
FocusTarget_Button.Parent = Target_Section
FocusTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
FocusTarget_Button.BackgroundTransparency = 0.500
FocusTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
FocusTarget_Button.BorderSizePixel = 0
FocusTarget_Button.Position = UDim2.new(0, 25, 0, 200)
FocusTarget_Button.Size = UDim2.new(0, 150, 0, 30)
FocusTarget_Button.Font = Enum.Font.Oswald
FocusTarget_Button.Text = "Focus"
FocusTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
FocusTarget_Button.TextScaled = true
FocusTarget_Button.TextSize = 14.000
FocusTarget_Button.TextWrapped = true

BenxTarget_Button.Name = "BenxTarget_Button"
BenxTarget_Button.Parent = Target_Section
BenxTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
BenxTarget_Button.BackgroundTransparency = 0.500
BenxTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
BenxTarget_Button.BorderSizePixel = 0
BenxTarget_Button.Position = UDim2.new(0, 210, 0, 200)
BenxTarget_Button.Size = UDim2.new(0, 150, 0, 30)
BenxTarget_Button.Font = Enum.Font.Oswald
BenxTarget_Button.Text = "Bang"
BenxTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
BenxTarget_Button.TextScaled = true
BenxTarget_Button.TextSize = 14.000
BenxTarget_Button.TextWrapped = true

PushTarget_Button.Name = "PushTarget_Button"
PushTarget_Button.Parent = Target_Section
PushTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
PushTarget_Button.BackgroundTransparency = 0.500
PushTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
PushTarget_Button.BorderSizePixel = 0
PushTarget_Button.Position = UDim2.new(0, 25, 0, 400)
PushTarget_Button.Size = UDim2.new(0, 150, 0, 30)
PushTarget_Button.Font = Enum.Font.Oswald
PushTarget_Button.Text = "Push"
PushTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
PushTarget_Button.TextScaled = true
PushTarget_Button.TextSize = 14.000
PushTarget_Button.TextWrapped = true

WhitelistTarget_Button.Name = "WhitelistTarget_Button"
WhitelistTarget_Button.Parent = Target_Section
WhitelistTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
WhitelistTarget_Button.BackgroundTransparency = 0.500
WhitelistTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
WhitelistTarget_Button.BorderSizePixel = 0
WhitelistTarget_Button.Position = UDim2.new(0, 210, 0, 400)
WhitelistTarget_Button.Size = UDim2.new(0, 150, 0, 30)
WhitelistTarget_Button.Font = Enum.Font.Oswald
WhitelistTarget_Button.Text = "Whitelist"
WhitelistTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
WhitelistTarget_Button.TextScaled = true
WhitelistTarget_Button.TextSize = 14.000
WhitelistTarget_Button.TextWrapped = true

TeleportTarget_Button.Name = "TeleportTarget_Button"
TeleportTarget_Button.Parent = Target_Section
TeleportTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
TeleportTarget_Button.BackgroundTransparency = 0.500
TeleportTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
TeleportTarget_Button.BorderSizePixel = 0
TeleportTarget_Button.Position = UDim2.new(0, 210, 0, 350)
TeleportTarget_Button.Size = UDim2.new(0, 150, 0, 30)
TeleportTarget_Button.Font = Enum.Font.Oswald
TeleportTarget_Button.Text = "Teleport"
TeleportTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
TeleportTarget_Button.TextScaled = true
TeleportTarget_Button.TextSize = 14.000
TeleportTarget_Button.TextWrapped = true

HeadsitTarget_Button.Name = "HeadsitTarget_Button"
HeadsitTarget_Button.Parent = Target_Section
HeadsitTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
HeadsitTarget_Button.BackgroundTransparency = 0.500
HeadsitTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
HeadsitTarget_Button.BorderSizePixel = 0
HeadsitTarget_Button.Position = UDim2.new(0, 210, 0, 250)
HeadsitTarget_Button.Size = UDim2.new(0, 150, 0, 30)
HeadsitTarget_Button.Font = Enum.Font.Oswald
HeadsitTarget_Button.Text = "Headsit"
HeadsitTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
HeadsitTarget_Button.TextScaled = true
HeadsitTarget_Button.TextSize = 14.000
HeadsitTarget_Button.TextWrapped = true

StandTarget_Button.Name = "StandTarget_Button"
StandTarget_Button.Parent = Target_Section
StandTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
StandTarget_Button.BackgroundTransparency = 0.500
StandTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
StandTarget_Button.BorderSizePixel = 0
StandTarget_Button.Position = UDim2.new(0, 25, 0, 250)
StandTarget_Button.Size = UDim2.new(0, 150, 0, 30)
StandTarget_Button.Font = Enum.Font.Oswald
StandTarget_Button.Text = "Stand"
StandTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
StandTarget_Button.TextScaled = true
StandTarget_Button.TextSize = 14.000
StandTarget_Button.TextWrapped = true

BackpackTarget_Button.Name = "BackpackTarget_Button"
BackpackTarget_Button.Parent = Target_Section
BackpackTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
BackpackTarget_Button.BackgroundTransparency = 0.500
BackpackTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
BackpackTarget_Button.BorderSizePixel = 0
BackpackTarget_Button.Position = UDim2.new(0, 210, 0, 300)
BackpackTarget_Button.Size = UDim2.new(0, 150, 0, 30)
BackpackTarget_Button.Font = Enum.Font.Oswald
BackpackTarget_Button.Text = "Backpack"
BackpackTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
BackpackTarget_Button.TextScaled = true
BackpackTarget_Button.TextSize = 14.000
BackpackTarget_Button.TextWrapped = true

DoggyTarget_Button.Name = "DoggyTarget_Button"
DoggyTarget_Button.Parent = Target_Section
DoggyTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
DoggyTarget_Button.BackgroundTransparency = 0.500
DoggyTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
DoggyTarget_Button.BorderSizePixel = 0
DoggyTarget_Button.Position = UDim2.new(0, 25, 0, 300)
DoggyTarget_Button.Size = UDim2.new(0, 150, 0, 30)
DoggyTarget_Button.Font = Enum.Font.Oswald
DoggyTarget_Button.Text = "Doggy"
DoggyTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
DoggyTarget_Button.TextScaled = true
DoggyTarget_Button.TextSize = 14.000
DoggyTarget_Button.TextWrapped = true

DragTarget_Button.Name = "DragTarget_Button"
DragTarget_Button.Parent = Target_Section
DragTarget_Button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
DragTarget_Button.BackgroundTransparency = 0.500
DragTarget_Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
DragTarget_Button.BorderSizePixel = 0
DragTarget_Button.Position = UDim2.new(0, 25, 0, 350)
DragTarget_Button.Size = UDim2.new(0, 150, 0, 30)
DragTarget_Button.Font = Enum.Font.Oswald
DragTarget_Button.Text = "Drag"
DragTarget_Button.TextColor3 = Color3.fromRGB(0, 0, 0)
DragTarget_Button.TextScaled = true
DragTarget_Button.TextSize = 14.000
DragTarget_Button.TextWrapped = true

Assets.Name = "Assets"
Assets.Parent = SysBroker

Ticket_Asset.Name = "Ticket_Asset"
Ticket_Asset.Parent = Assets
Ticket_Asset.AnchorPoint = Vector2.new(0, 0.5)
Ticket_Asset.BackgroundTransparency = 1.000
Ticket_Asset.BorderSizePixel = 0
Ticket_Asset.LayoutOrder = 5
Ticket_Asset.Position = UDim2.new(1, 5, 0.5, 0)
Ticket_Asset.Size = UDim2.new(0, 25, 0, 25)
Ticket_Asset.ZIndex = 2
Ticket_Asset.Image = "rbxassetid://3926305904"
Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
Ticket_Asset.ImageRectOffset = Vector2.new(424, 4)
Ticket_Asset.ImageRectSize = Vector2.new(36, 36)

Click_Asset.Name = "Click_Asset"
Click_Asset.Parent = Assets
Click_Asset.AnchorPoint = Vector2.new(0, 0.5)
Click_Asset.BackgroundTransparency = 1.000
Click_Asset.BorderSizePixel = 0
Click_Asset.Position = UDim2.new(1, 5, 0.5, 0)
Click_Asset.Size = UDim2.new(0, 25, 0, 25)
Click_Asset.ZIndex = 2
Click_Asset.Image = "rbxassetid://3926305904"
Click_Asset.ImageColor3 = Color3.fromRGB(100, 100, 100)
Click_Asset.ImageRectOffset = Vector2.new(204, 964)
Click_Asset.ImageRectSize = Vector2.new(36, 36)

Velocity_Asset.AngularVelocity = Vector3.new(0, 0, 0)
Velocity_Asset.MaxTorque = Vector3.new(50000, 50000, 50000)
Velocity_Asset.P = 1250
Velocity_Asset.Name = "BreakVelocity"
Velocity_Asset.Parent = Assets

Fly_Pad.Name = "Fly_Pad"
Fly_Pad.Parent = Assets
Fly_Pad.BackgroundTransparency = 1.000
Fly_Pad.Position = UDim2.new(0.1, 0, 0.6, 0)
Fly_Pad.Size = UDim2.new(0, 100, 0, 100)
Fly_Pad.ZIndex = 2
Fly_Pad.Image = "rbxassetid://6764432293"
Fly_Pad.ImageRectOffset = Vector2.new(713, 315)
Fly_Pad.ImageRectSize = Vector2.new(75, 75)
Fly_Pad.Visible = false

UIGradient.Color = ColorSequence.new { ColorSequenceKeypoint.new(0.00, Color3.fromRGB(30, 30, 30)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 255, 255)) }
UIGradient.Rotation = 45
UIGradient.Parent = Fly_Pad

FlyAButton.Name = "FlyAButton"
FlyAButton.Parent = Fly_Pad
FlyAButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyAButton.BackgroundTransparency = 1.000
FlyAButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyAButton.BorderSizePixel = 0
FlyAButton.Position = UDim2.new(0, 0, 0, 30)
FlyAButton.Size = UDim2.new(0, 30, 0, 40)
FlyAButton.Font = Enum.Font.Oswald
FlyAButton.Text = ""
FlyAButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FlyAButton.TextSize = 25.000
FlyAButton.TextWrapped = true

FlyDButton.Name = "FlyDButton"
FlyDButton.Parent = Fly_Pad
FlyDButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyDButton.BackgroundTransparency = 1.000
FlyDButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyDButton.BorderSizePixel = 0
FlyDButton.Position = UDim2.new(0, 70, 0, 30)
FlyDButton.Size = UDim2.new(0, 30, 0, 40)
FlyDButton.Font = Enum.Font.Oswald
FlyDButton.Text = ""
FlyDButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FlyDButton.TextSize = 25.000
FlyDButton.TextWrapped = true

FlyWButton.Name = "FlyWButton"
FlyWButton.Parent = Fly_Pad
FlyWButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlyWButton.BackgroundTransparency = 1.000
FlyWButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlyWButton.BorderSizePixel = 0
FlyWButton.Position = UDim2.new(0, 30, 0, 0)
FlyWButton.Size = UDim2.new(0, 40, 0, 30)
FlyWButton.Font = Enum.Font.Oswald
FlyWButton.Text = ""
FlyWButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FlyWButton.TextSize = 25.000
FlyWButton.TextWrapped = true

FlySButton.Name = "FlySButton"
FlySButton.Parent = Fly_Pad
FlySButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FlySButton.BackgroundTransparency = 1.000
FlySButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
FlySButton.BorderSizePixel = 0
FlySButton.Position = UDim2.new(0, 30, 0, 70)
FlySButton.Size = UDim2.new(0, 40, 0, 30)
FlySButton.Font = Enum.Font.Oswald
FlySButton.Text = ""
FlySButton.TextColor3 = Color3.fromRGB(0, 0, 0)
FlySButton.TextSize = 25.000
FlySButton.TextWrapped = true

OpenClose.Name = "OpenClose"
OpenClose.Parent = SysBroker
OpenClose.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OpenClose.BorderColor3 = Color3.fromRGB(0, 0, 0)
OpenClose.BorderSizePixel = 0
OpenClose.Position = UDim2.new(0, 0, 0.5, 0)
OpenClose.Size = UDim2.new(0, 30, 0, 30)
OpenClose.Image = "rbxassetid://12298407748"
OpenClose.ImageColor3 = Color3.fromRGB(0, 255, 255)
OpenClose.Active = true
OpenClose.Draggable = true

UICornerOC.CornerRadius = UDim.new(1, 0)
UICornerOC.Parent = OpenClose

CreateToggle(Fly_Button)
CreateClicker(WalkSpeed_Button)
CreateClicker(ClearCheckpoint_Button)
CreateClicker(JumpPower_Button)
CreateClicker(SaveCheckpoint_Button)
CreateClicker(Respawn_Button)
CreateClicker(FlySpeed_Button)

CreateToggle(ViewTarget_Button)
CreateToggle(FlingTarget_Button)
CreateToggle(FocusTarget_Button)
CreateToggle(BenxTarget_Button)
CreateToggle(HeadsitTarget_Button)
CreateToggle(StandTarget_Button)
CreateToggle(BackpackTarget_Button)
CreateToggle(DoggyTarget_Button)
CreateToggle(DragTarget_Button)
CreateClicker(PushTarget_Button)
CreateClicker(WhitelistTarget_Button)
CreateClicker(TeleportTarget_Button)


task.wait(0.5)

local function ChangeSection(SectionClicked)
    SectionClickedName = string.split(SectionClicked.Name, "_")[1]
    for i, v in pairs(SectionList:GetChildren()) do
        if v.Name ~= SectionClicked.Name then
            v.Transparency = 0.5
        else
            v.Transparency = 0
        end
    end
    for i, v in pairs(Background:GetChildren()) do
        if v:IsA("ScrollingFrame") then
            SectionForName = string.split(v.Name, "_")[1]
            if string.find(SectionClickedName, SectionForName) then
                v.Visible = true
            else
                v.Visible = false
            end
        end
    end
end

local function UpdateTarget(player)
    pcall(function()
        if table.find(ForceWhitelist, player.UserId) then
            SendNotify("System Broken", "You cant target this player: @" .. player.Name .. " / " .. player.DisplayName, 5)
            player = nil
        end
    end)
    if (player ~= nil) then
        TargetedPlayer = player.Name
        TargetName_Input.Text = player.Name
        UserIDTargetLabel.Text = ("UserID: " .. player.UserId .. "\nDisplay: " .. player.DisplayName .. "\nJoined: " .. os.date("%d-%m-%Y", os.time() - player.AccountAge * 24 * 3600) .. " [Day/Month/Year]")
        TargetImage.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size420x420)
    else
        TargetName_Input.Text = "@target..."
        UserIDTargetLabel.Text = "UserID: \nDisplay: \nJoined: "
        TargetImage.Image = "rbxassetid://10818605405"
        TargetedPlayer = nil
        if FlingTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            FlingTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
            TouchFling_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        end
        ViewTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        FocusTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        BenxTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        HeadsitTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        StandTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        BackpackTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        DoggyTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        DragTarget_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
    end
end
local aBjaUfk = game.Workspace:FindFirstChild("SBTI")

local function ToggleFling(bool)
    task.spawn(function()
        if bool then
            local RVelocity = nil
            repeat
                pcall(function()
                    RVelocity = GetRoot(plr).Velocity
                    GetRoot(plr).Velocity = Vector3.new(math.random(-1500, 1500), -250000, math.random(-1500, 1500))
                    RunService.RenderStepped:wait()
                    GetRoot(plr).Velocity = RVelocity
                end)
                RunService.Heartbeat:wait()
            until TouchFling_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
        else
            TouchFling_Button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

--CHANGE SECTION BUTTONS
ChangeSection(Target_Section_Button)

Character_Section_Button.MouseButton1Click:Connect(function()
    ChangeSection(Character_Section_Button)
end)

Target_Section_Button.MouseButton1Click:Connect(function()
    ChangeSection(Target_Section_Button)
end)

--CHARACTER SECTION

WalkSpeed_Button.MouseButton1Click:Connect(function()
    pcall(function()
        local Speed = WalkSpeed_Input.Text:gsub("%D", "")
        if Speed == "" then
            Speed = 16
        end
        plr.Character.Humanoid.WalkSpeed = tonumber(Speed)
        SendNotify("System Broken", "Walk speed updated.", 5)
    end)
end)

JumpPower_Button.MouseButton1Click:Connect(function()
    pcall(function()
        local Power = JumpPower_Input.Text:gsub("%D", "")
        if Power == "" then
            Power = 50
        end
        plr.Character.Humanoid.JumpPower = tonumber(Power)
        SendNotify("System Broken", "Jump power updated.", 5)
    end)
end)

FlySpeed_Button.MouseButton1Click:Connect(function()
    pcall(function()
        local Speed = FlySpeed_Input.Text:gsub("%D", "")
        if Speed == "" then
            Speed = 50
        end
        FlySpeed = tonumber(Speed)
        SendNotify("System Broken", "Fly speed updated.", 5)
    end)
end)

Respawn_Button.MouseButton1Click:Connect(function()
    local RsP = GetRoot(plr).Position
    plr.Character.Humanoid.Health = 0
    plr.CharacterAdded:wait(); task.wait(GetPing() + 0.1)
    TeleportTO(RsP.X, RsP.Y, RsP.Z, "pos", "safe")
end)

SaveCheckpoint_Button.MouseButton1Click:Connect(function()
    SavedCheckpoint = GetRoot(plr).Position
    SendNotify("System Broken", "Checkpoint saved.", 5)
end)

ClearCheckpoint_Button.MouseButton1Click:Connect(function()
    SavedCheckpoint = nil
    SendNotify("System Broken", "Checkpoint cleared.", 5)
end)

local flying = true
local deb = true
local ctrl = { f = 0, b = 0, l = 0, r = 0 }
local lastctrl = { f = 0, b = 0, l = 0, r = 0 }
local KeyDownFunction = nil
local KeyUpFunction = nil
Fly_Button.MouseButton1Click:Connect(function()
    ChangeToggleColor(Fly_Button)
    if Fly_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
        flying = true
        if game:GetService("UserInputService").TouchEnabled then
            Fly_Pad.Visible = true
        end
        local UpperTorso = plr.Character.UpperTorso
        local speed = 0
        local function Fly()
            local bg = Instance.new("BodyGyro", UpperTorso)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = UpperTorso.CFrame
            local bv = Instance.new("BodyVelocity", UpperTorso)
            bv.velocity = Vector3.new(0, 0.1, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            PlayAnim(10714347256, 4, 0)
            repeat
                task.wait()
                plr.Character.Humanoid.PlatformStand = true
                if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                    speed = speed + FlySpeed * 0.10
                    if speed > FlySpeed then
                        speed = FlySpeed
                    end
                elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then
                    speed = speed - FlySpeed * 0.10
                    if speed < 0 then
                        speed = 0
                    end
                end
                if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) *
                        speed
                    lastctrl = { f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r }
                elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then
                    bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * .2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) *
                        speed
                else
                    bv.velocity = Vector3.new(0, 0.1, 0)
                end
                bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame *
                    CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / FlySpeed), 0, 0)
            until not flying
            ctrl = { f = 0, b = 0, l = 0, r = 0 }
            lastctrl = { f = 0, b = 0, l = 0, r = 0 }
            speed = 0
            bg:Destroy()
            bv:Destroy()
            plr.Character.Humanoid.PlatformStand = false
        end

        KeyDownFunction = mouse.KeyDown:connect(function(key)
            if key:lower() == "w" then
                ctrl.f = 1
                PlayAnim(10714177846, 4.65, 0)
            elseif key:lower() == "s" then
                ctrl.b = -1
                PlayAnim(10147823318, 4.11, 0)
            elseif key:lower() == "a" then
                ctrl.l = -1
                PlayAnim(10147823318, 3.55, 0)
            elseif key:lower() == "d" then
                ctrl.r = 1
                PlayAnim(10147823318, 4.81, 0)
            end
        end)

        KeyUpFunction = mouse.KeyUp:connect(function(key)
            if key:lower() == "w" then
                ctrl.f = 0
                PlayAnim(10714347256, 4, 0)
            elseif key:lower() == "s" then
                ctrl.b = 0
                PlayAnim(10714347256, 4, 0)
            elseif key:lower() == "a" then
                ctrl.l = 0
                PlayAnim(10714347256, 4, 0)
            elseif key:lower() == "d" then
                ctrl.r = 0
                PlayAnim(10714347256, 4, 0)
            end
        end)
        Fly()
    else
        flying = false
        Fly_Pad.Visible = false
        KeyDownFunction:Disconnect()
        KeyUpFunction:Disconnect()
        StopAnim()
    end
end)

FlyAButton.MouseButton1Down:Connect(function()
    keypress("0x41")
end)
FlyAButton.MouseButton1Up:Connect(function()
    keyrelease("0x41")
end)

FlySButton.MouseButton1Down:Connect(function()
    keypress("0x53")
end)
FlySButton.MouseButton1Up:Connect(function()
    keyrelease("0x53")
end)

FlyDButton.MouseButton1Down:Connect(function()
    keypress("0x44")
end)
FlyDButton.MouseButton1Up:Connect(function()
    keyrelease("0x44")
end)

FlyWButton.MouseButton1Down:Connect(function()
    keypress("0x57")
end)
FlyWButton.MouseButton1Up:Connect(function()
    keyrelease("0x57")
end)

--TARGET
ClickTargetTool_Button.MouseButton1Click:Connect(function()
    local GetTargetTool = Instance.new("Tool")
    GetTargetTool.Name = "ClickTarget"
    GetTargetTool.RequiresHandle = false
    GetTargetTool.TextureId = "rbxassetid://2716591855"
    GetTargetTool.ToolTip = "Select Target"

    local function ActivateTool()
        local root = GetRoot(plr)
        local hit = mouse.Target
        local person = nil
        if hit and hit.Parent then
            if hit.Parent:IsA("Model") then
                person = game.Players:GetPlayerFromCharacter(hit.Parent)
            elseif hit.Parent:IsA("Accessory") then
                person = game.Players:GetPlayerFromCharacter(hit.Parent.Parent)
            end
            if person then
                UpdateTarget(person)
            end
        end
    end

    GetTargetTool.Activated:Connect(function()
        ActivateTool()
    end)
    GetTargetTool.Parent = plr.Backpack
end)

FlingTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(FlingTarget_Button)
        if FlingTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            if TouchFling_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0) then
                ChangeToggleColor(TouchFling_Button)
            end
            local OldPos = GetRoot(plr).Position
            ToggleFling(true)
            repeat
                task.wait()
                pcall(function()
                    PredictionTP(Players[TargetedPlayer], "safe")
                end)
                task.wait()
            until FlingTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            TeleportTO(OldPos.X, OldPos.Y, OldPos.Z, "pos", "safe")
        else
            ToggleFling(false)
        end
    end
end)

ViewTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(ViewTarget_Button)
        if ViewTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            repeat
                pcall(function()
                    game.Workspace.CurrentCamera.CameraSubject = Players[TargetedPlayer].Character.Humanoid
                end)
                task.wait(0.5)
            until ViewTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            game.Workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
        end
    end
end)

FocusTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(FocusTarget_Button)
        if FocusTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            repeat
                pcall(function()
                    local target = Players[TargetedPlayer]
                    TeleportTO(0, 0, 0, target)
                    Push(Players[TargetedPlayer])
                end)
                task.wait(0.2)
            until FocusTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
        end
    end
end)

BenxTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(BenxTarget_Button)
        if BenxTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            PlayAnim(5918726674, 0, 1)
            repeat
                pcall(function()
                    if not GetRoot(plr):FindFirstChild("BreakVelocity") then
                        pcall(function()
                            local TempV = Velocity_Asset:Clone()
                            TempV.Parent = GetRoot(plr)
                        end)
                    end
                    local otherRoot = GetRoot(Players[TargetedPlayer])
                    GetRoot(plr).CFrame = otherRoot.CFrame * CFrame.new(0, 0, 1.1)
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                end)
                task.wait()
            until BenxTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            StopAnim()
            if GetRoot(plr):FindFirstChild("BreakVelocity") then
                GetRoot(plr).BreakVelocity:Destroy()
            end
        end
    end
end)

HeadsitTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(HeadsitTarget_Button)
        if HeadsitTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            repeat
                pcall(function()
                    if not GetRoot(plr):FindFirstChild("BreakVelocity") then
                        pcall(function()
                            local TempV = Velocity_Asset:Clone()
                            TempV.Parent = GetRoot(plr)
                        end)
                    end
                    local targethead = Players[TargetedPlayer].Character.Head
                    plr.Character.Humanoid.Sit = true
                    GetRoot(plr).CFrame = targethead.CFrame * CFrame.new(0, 2, 0)
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                end)
                task.wait()
            until HeadsitTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            if GetRoot(plr):FindFirstChild("BreakVelocity") then
                GetRoot(plr).BreakVelocity:Destroy()
            end
        end
    end
end)

StandTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(StandTarget_Button)
        if StandTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            PlayAnim(13823324057, 4, 0)
            repeat
                pcall(function()
                    if not GetRoot(plr):FindFirstChild("BreakVelocity") then
                        pcall(function()
                            local TempV = Velocity_Asset:Clone()
                            TempV.Parent = GetRoot(plr)
                        end)
                    end
                    local root = GetRoot(Players[TargetedPlayer])
                    GetRoot(plr).CFrame = root.CFrame * CFrame.new(-3, 1, 0)
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                end)
                task.wait()
            until StandTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            StopAnim()
            if GetRoot(plr):FindFirstChild("BreakVelocity") then
                GetRoot(plr).BreakVelocity:Destroy()
            end
        end
    end
end)

BackpackTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(BackpackTarget_Button)
        if BackpackTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            repeat
                pcall(function()
                    if not GetRoot(plr):FindFirstChild("BreakVelocity") then
                        pcall(function()
                            local TempV = Velocity_Asset:Clone()
                            TempV.Parent = GetRoot(plr)
                        end)
                    end
                    local root = GetRoot(Players[TargetedPlayer])
                    plr.Character.Humanoid.Sit = true
                    GetRoot(plr).CFrame = root.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(0, -3, 0)
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                end)
                task.wait()
            until BackpackTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            if GetRoot(plr):FindFirstChild("BreakVelocity") then
                GetRoot(plr).BreakVelocity:Destroy()
            end
        end
    end
end)

DoggyTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(DoggyTarget_Button)
        if DoggyTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            PlayAnim(13694096724, 3.4, 0)
            repeat
                pcall(function()
                    if not GetRoot(plr):FindFirstChild("BreakVelocity") then
                        pcall(function()
                            local TempV = Velocity_Asset:Clone()
                            TempV.Parent = GetRoot(plr)
                        end)
                    end
                    local root = Players[TargetedPlayer].Character.LowerTorso
                    GetRoot(plr).CFrame = root.CFrame * CFrame.new(0, 0.23, 0)
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                end)
                task.wait()
            until DoggyTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            StopAnim()
            if GetRoot(plr):FindFirstChild("BreakVelocity") then
                GetRoot(plr).BreakVelocity:Destroy()
            end
        end
    end
end)

DragTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        ChangeToggleColor(DragTarget_Button)
        if DragTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
            PlayAnim(10714360343, 0.5, 0)
            repeat
                pcall(function()
                    if not GetRoot(plr):FindFirstChild("BreakVelocity") then
                        pcall(function()
                            local TempV = Velocity_Asset:Clone()
                            TempV.Parent = GetRoot(plr)
                        end)
                    end
                    local root = Players[TargetedPlayer].Character.RightHand
                    GetRoot(plr).CFrame = root.CFrame * CFrame.new(0, -2.5, 1) * CFrame.Angles(-2, -3, 0)
                    GetRoot(plr).Velocity = Vector3.new(0, 0, 0)
                end)
                task.wait()
            until DragTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255, 0, 0)
            StopAnim()
            if GetRoot(plr):FindFirstChild("BreakVelocity") then
                GetRoot(plr).BreakVelocity:Destroy()
            end
        end
    end
end)

PushTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        local pushpos = GetRoot(plr).CFrame
        PredictionTP(Players[TargetedPlayer])
        task.wait(GetPing() + 0.05)
        Push(Players[TargetedPlayer])
        GetRoot(plr).CFrame = pushpos
    end
end)

TeleportTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        TeleportTO(0, 0, 0, Players[TargetedPlayer], "safe")
    end
end)

WhitelistTarget_Button.MouseButton1Click:Connect(function()
    if TargetedPlayer ~= nil then
        if table.find(ScriptWhitelist, Players[TargetedPlayer].UserId) then
            for i, v in pairs(ScriptWhitelist) do
                if v == Players[TargetedPlayer].UserId then
                    table.remove(ScriptWhitelist, i)
                end
            end
            SendNotify("System Broken", TargetedPlayer .. " removed from whitelist.", 5)
        else
            table.insert(ScriptWhitelist, Players[TargetedPlayer].UserId)
            SendNotify("System Broken", TargetedPlayer .. " added to whitelist.", 5)
        end
    end
end)

TargetName_Input.FocusLost:Connect(function()
    local LabelText = TargetName_Input.Text
    local LabelTarget = GetPlayer(LabelText)
    UpdateTarget(LabelTarget)
end)

--GUI Functions
Players.PlayerRemoving:Connect(function(player)
    pcall(function()
        if player.Name == TargetedPlayer then
            UpdateTarget(nil)
            SendNotify("System Broken", "Targeted player left/rejoined.", 5)
        end
    end)
end)

plr.CharacterAdded:Connect(function(x)
    task.wait(GetPing() + 0.1)
    x:WaitForChild("Humanoid")
    if SavedCheckpoint ~= nil then
        TeleportTO(SavedCheckpoint.X, SavedCheckpoint.Y, SavedCheckpoint.Z, "pos", "safe")
    end
    if Fly_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0, 255, 0) then
        ChangeToggleColor(Fly_Button)
        flying = false
        Fly_Pad.Visible = false
        KeyDownFunction:Disconnect()
        KeyUpFunction:Disconnect()
        SendNotify("System Broken", "Fly was automatically disabled due to your character respawn", 5)
    end
    x.Humanoid.Died:Connect(function()
        pcall(function()
            x["Pushed"].Disabled = false
            x["RagdollMe"].Disabled = false
        end)
    end)
end)

task.spawn(function()
    while task.wait(10) do
        pcall(function()
            local GuiVersion = loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/H20CalibreYT/SystemBroken/main/version"))()
            if version < GuiVersion then
                SendNotify("System Broken", "You are not using the latest version, please run the script again.", 5)
                task.wait(5)
                SysBroker:Destroy()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
            end
        end)
    end
end)

OpenClose.MouseButton1Click:Connect(function()
    Background.Visible = not Background.Visible
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.B then
        Background.Visible = not Background.Visible
    end
end)

SendNotify("System Broken", "Gui developed by Danz", 10)
setclipboard("https://raw.githubusercontent.com/romanzidan/roblix/refs/heads/main/borneo.lua")
