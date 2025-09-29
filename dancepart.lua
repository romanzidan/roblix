--[[
    WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Ultimate Dancing Unanchored Parts  FE V2
-- By V0C0N1337

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Dancing = true

-- Network Bypass
settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)

-- Dance Animation System
local DanceSystem = {
    Parts = {},
    CurrentDance = 1,
    DanceTime = 0,
    GroupCenter = Vector3.new(0, 0, 0)
}

-- Enhanced Dance Moves (Emote-style)
local DanceMoves = {
    {
        Duration = 4,
        Steps = function(data, time, center)
            local t = time * 2
            return {
                Position = center + Vector3.new(
                    math.sin(t) * 3,
                    math.abs(math.sin(t * 2)) * 2,
                    math.cos(t) * 3
                ),
                Rotation = Vector3.new(
                    math.sin(t) * 30,
                    t * 180,
                    math.cos(t) * 20
                )
            }
        end
    },
    {
        Duration = 2,
        Steps = function(data, time, center)
            local t = time * 3
            return {
                Position = center + Vector3.new(
                    math.floor(math.sin(t) * 2) * 2,
                    math.abs(math.sin(t * 4)) * 3,
                    math.floor(math.cos(t) * 2) * 2
                ),
                Rotation = Vector3.new(
                    math.floor(time * 90) % 90,
                    math.floor(time * 45) % 180,
                    math.floor(time * 60) % 60
                )
            }
        end
    },
    {
        Duration = 3,
        Steps = function(data, time, center)
            local t = time * 4
            return {
                Position = center + Vector3.new(
                    math.sin(t) * 4 * math.cos(t),
                    math.abs(math.sin(t * 2)) * 4,
                    math.cos(t) * 4 * math.sin(t)
                ),
                Rotation = Vector3.new(
                    t * 360,
                    math.sin(t) * 180,
                    t * 180
                )
            }
        end
    },
    {
        Duration = 2.5,
        Steps = function(data, time, center)
            local wave = math.sin(time * 4) * 3
            local t = time * 2
            return {
                Position = center + Vector3.new(
                    math.sin(t + data.Offset) * 3,
                    wave + math.cos(t * 2) * 2,
                    math.cos(t + data.Offset) * 3
                ),
                Rotation = Vector3.new(
                    wave * 20,
                    t * 90,
                    math.cos(t) * 45
                )
            }
        end
    },
    {
        Duration = 2,
        Steps = function(data, time, center)
            local t = time * 3
            local shuffle = math.sin(t * 2) * math.cos(t)
            return {
                Position = center + Vector3.new(
                    shuffle * 4,
                    math.abs(math.sin(t * 3)) * 2,
                    math.cos(t * 2) * 3
                ),
                Rotation = Vector3.new(
                    0,
                    shuffle * 180,
                    math.sin(t) * 30
                )
            }
        end
    }
}

-- Part Setup with Enhanced Physics
function DanceSystem:SetupPart(part)
    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
        part.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0, 0, 0, 0)

        local attachment = Instance.new("Attachment")
        attachment.Parent = part

        local alignPosition = Instance.new("AlignPosition")
        alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
        alignPosition.Attachment0 = attachment
        alignPosition.MaxForce = math.huge
        alignPosition.MaxVelocity = math.huge
        alignPosition.Responsiveness = 200
        alignPosition.Parent = part

        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        gyro.P = 100000
        gyro.Parent = part

        self.Parts[part] = {
            Attachment = attachment,
            AlignPosition = alignPosition,
            Gyro = gyro,
            StartPos = part.Position,
            Offset = #self.Parts * 0.2,
            BaseY = part.Position.Y
        }

        self.GroupCenter = self.GroupCenter + part.Position
    end
end

-- Formation Control
function DanceSystem:UpdateFormation()
    if next(self.Parts) then
        self.GroupCenter = Vector3.new(0, 0, 0)
        local count = 0
        for part, _ in pairs(self.Parts) do
            if part and part.Parent then
                self.GroupCenter = self.GroupCenter + part.Position
                count = count + 1
            end
        end
        if count > 0 then
            self.GroupCenter = self.GroupCenter / count
        end
    end
end

-- Smooth Dance Animation
function DanceSystem:AnimateParts()
    self:UpdateFormation()
    local currentDance = DanceMoves[self.CurrentDance]
    local nextDance = DanceMoves[self.CurrentDance % #DanceMoves + 1]

    for part, data in pairs(self.Parts) do
        if part and part.Parent then
            local current = currentDance.Steps(data, self.DanceTime, self.GroupCenter)
            local next = nextDance.Steps(data, self.DanceTime, self.GroupCenter)
            local blend = math.clamp((self.DanceTime % currentDance.Duration) / currentDance.Duration, 0, 1)
            local finalPos = current.Position:Lerp(next.Position, blend)
            local finalRot = Vector3.new(
                Lerp(current.Rotation.X, next.Rotation.X, blend),
                Lerp(current.Rotation.Y, next.Rotation.Y, blend),
                Lerp(current.Rotation.Z, next.Rotation.Z, blend)
            )

            data.AlignPosition.Position = finalPos
            data.Gyro.CFrame = CFrame.new(finalPos) * CFrame.Angles(
                math.rad(finalRot.X),
                math.rad(finalRot.Y),
                math.rad(finalRot.Z)
            )

            part.Velocity = (finalPos - part.Position) * 10
        else
            self.Parts[part] = nil
        end
    end
end

-- Lerp Function
function Lerp(a, b, t)
    return a + (b - a) * t
end

-- Main Update Loop
RunService.Heartbeat:Connect(function()
    if Dancing then
        DanceSystem.DanceTime = DanceSystem.DanceTime + 0.03
        if DanceSystem.DanceTime >= DanceMoves[DanceSystem.CurrentDance].Duration then
            DanceSystem.CurrentDance = DanceSystem.CurrentDance % #DanceMoves + 1
            DanceSystem.DanceTime = 0
        end
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        DanceSystem:AnimateParts()
    end
end)

-- Initialize Parts
for _, part in ipairs(workspace:GetDescendants()) do
    DanceSystem:SetupPart(part)
end

workspace.DescendantAdded:Connect(function(part)
    DanceSystem:SetupPart(part)
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0.5, -110, 0.5, -70) -- tengah
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 0.3
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Buttons
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0.25, 0)
toggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "Dancing: ON"
toggleBtn.Parent = frame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

local danceModeBtn = Instance.new("TextButton")
danceModeBtn.Size = UDim2.new(0.9, 0, 0.25, 0)
danceModeBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
danceModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
danceModeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
danceModeBtn.Text = "Next Dance"
danceModeBtn.Parent = frame
Instance.new("UICorner", danceModeBtn).CornerRadius = UDim.new(0, 8)

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0.9, 0, 0.25, 0)
flyBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
flyBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Text = "Fly Out Parts"
flyBtn.Parent = frame
Instance.new("UICorner", flyBtn).CornerRadius = UDim.new(0, 8)

-- Button Handlers
toggleBtn.MouseButton1Click:Connect(function()
    Dancing = not Dancing
    toggleBtn.Text = Dancing and "Dancing: ON" or "Dancing: OFF"
end)

danceModeBtn.MouseButton1Click:Connect(function()
    DanceSystem.CurrentDance = DanceSystem.CurrentDance % #DanceMoves + 1
    DanceSystem.DanceTime = 0
end)

flyBtn.MouseButton1Click:Connect(function()
    for part, _ in pairs(DanceSystem.Parts) do
        if part and part.Parent then
            part.Velocity = Vector3.new(10, 10, 10)
            task.delay(2, function()
                if part and part.Parent then
                    part.Position = part.Position + Vector3.new(math.random(-150, 150), 9e6, math.random(-150, 150))
                end
            end)
        end
    end
end)

print("enjoy LOLL - draggable GUI, centered, with Fly Out Parts")
