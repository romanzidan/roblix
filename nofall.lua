local Lp = game.Players.LocalPlayer
local Cam = workspace.CurrentCamera
local Pos, Char = Cam.CFrame, Lp.Character

local Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
Humanoid.MaxHealth = math.huge
Humanoid.Health = Humanoid.MaxHealth
Humanoid.HealthChanged:Connect(function()
    if Humanoid.Health < 100 then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)

local function Optimize(part)
    part.CanTouch = false
    part.CanQuery = false
end
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        Optimize(obj)
    end
end

local Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
Humanoid.MaxHealth = math.huge
Humanoid.Health = Humanoid.MaxHealth
Humanoid.HealthChanged:Connect(function()
    if Humanoid.Health < 100 then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
local nHuman = Humanoid:Clone()
nHuman.Parent = Char
Lp.Character = nil
nHuman:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
nHuman:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
nHuman:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
nHuman.BreakJointsOnDeath = true
Humanoid:Destroy()
Lp.Character = Char
Cam.CameraSubject = nHuman
Cam.CFrame = Pos
nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
local Script = Char:FindFirstChild("Animate")
if Script then
    Script.Disabled = true
    wait()
    Script.Disabled = false
end
nHuman.MaxHealth = math.huge
nHuman.Health = nHuman.MaxHealth
nHuman.HealthChanged:Connect(function()
    if nHuman.Health < 100 then
        nHuman.Health = nHuman.MaxHealth
    end
end)

for i = 1, 5 do
    local Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
    Humanoid.MaxHealth = math.huge
    Humanoid.Health = Humanoid.MaxHealth
    Humanoid.HealthChanged:Connect(function()
        if Humanoid.Health < 100 then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local nHuman = Humanoid:Clone()
    nHuman.Parent = Char
    Lp.Character = nil
    nHuman:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    nHuman:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    nHuman:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    nHuman.BreakJointsOnDeath = true
    Humanoid:Destroy()
    Lp.Character = Char
    Cam.CameraSubject = nHuman
    Cam.CFrame = Pos
    nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local Script = Char:FindFirstChild("Animate")
    if Script then
        Script.Disabled = true
        wait()
        Script.Disabled = false
    end
    nHuman.MaxHealth = math.huge
    nHuman.Health = nHuman.MaxHealth
    nHuman.HealthChanged:Connect(function()
        if nHuman.Health < 100 then
            nHuman.Health = nHuman.MaxHealth
        end
    end)
end

local Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
Humanoid.MaxHealth = math.huge
Humanoid.Health = Humanoid.MaxHealth
Humanoid.HealthChanged:Connect(function()
    if Humanoid.Health < 100 then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
local nHuman = Humanoid:Clone()
nHuman.Parent = Char
Lp.Character = nil
nHuman:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
nHuman:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
nHuman:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
nHuman.BreakJointsOnDeath = true
Humanoid:Destroy()
Lp.Character = Char
Cam.CameraSubject = nHuman
Cam.CFrame = Pos
nHuman.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
local Script = Char:FindFirstChild("Animate")
if Script then
    Script.Disabled = true
    wait()
    Script.Disabled = false
end
nHuman.MaxHealth = math.huge
nHuman.Health = nHuman.MaxHealth
nHuman.HealthChanged:Connect(function()
    if nHuman.Health < 100 then
        nHuman.Health = nHuman.MaxHealth
    end
end)


workspace.DescendantAdded:Connect(function(nObj)
    if nObj:IsA("BasePart") then
        Optimize(nObj)
    end
end)

local Humanoid = Char:FindFirstChildWhichIsA("Humanoid")
Humanoid.MaxHealth = math.huge
Humanoid.Health = Humanoid.MaxHealth
Humanoid.HealthChanged:Connect(function()
    if Humanoid.Health < 100 then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)
