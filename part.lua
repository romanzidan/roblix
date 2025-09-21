local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Physics and Simulation Settings
settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
pcall(function()
    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
end)

-- Main System Table
local AttachmentSystem = {
    Parts = {},
    CurrentMode = "Fly_Out_Of_Map", -- Mode is set directly and is always active
    Enabled = true,
    AnimationSpeed = 1,
    ScaleFactor = 1,
    AutoSize = true,
    NoCollision = true
}

-- All available formation modes (Only one remains)
local AttachmentModes = {
    ["Fly_Out_Of_Map"] = {
        Scale = function(partCount)
            return {} -- No scaling needed for this mode
        end,
        Formation = function(part, data, index, total, scale)
            -- Set the target position to a very high point in the sky
            local targetPosition = part.Position + Vector3.new(math.random(-150, 150), 9e6, math.random(-150, 150))
            return {
                Position = CFrame.new(targetPosition),
                Rotation = CFrame.Angles(0, 0, 0) -- No specific rotation needed
            }
        end
    }
}

-- Function to process each part and add physics constraints
function AttachmentSystem:ProcessPart(part)
    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(Character) then
        part.CustomPhysicalProperties = PhysicalProperties.new(0.1, 0, 0, 0, 0)
        part.CanCollide = false

        pcall(function()
            part:SetNetworkOwner(LocalPlayer)
        end)

        local attachment = Instance.new("Attachment")
        attachment.Parent = part

        local alignPos = Instance.new("AlignPosition")
        alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        alignPos.Attachment0 = attachment
        alignPos.MaxForce = 9e18
        alignPos.MaxVelocity = 9e18
        alignPos.Responsiveness = 300
        alignPos.Parent = part

        local alignOri = Instance.new("AlignOrientation")
        alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOri.Attachment0 = attachment
        alignOri.MaxTorque = 9e18
        alignOri.Responsiveness = 300
        alignOri.Parent = part

        self.Parts[part] = {
            Attachment = attachment,
            AlignPosition = alignPos,
            AlignOrientation = alignOri,
            Size = part.Size
        }
    end
end

-- Main loop that runs every frame
RunService.Heartbeat:Connect(function()
    if AttachmentSystem.Enabled and AttachmentSystem.CurrentMode ~= "None" then
        local mode = AttachmentModes[AttachmentSystem.CurrentMode]
        if mode then
            local partCount = 0
            for _ in pairs(AttachmentSystem.Parts) do partCount = partCount + 1 end
            if partCount == 0 then return end

            local scale = mode.Scale(partCount)
            local index = 0

            for part, data in pairs(AttachmentSystem.Parts) do
                if part and part.Parent then
                    local formation = mode.Formation(part, data, index, partCount, scale)

                    data.AlignPosition.Position = formation.Position.Position
                    data.AlignOrientation.CFrame = formation.Position * formation.Rotation

                    if AttachmentSystem.AutoSize then
                        part.Size = data.Size * AttachmentSystem.ScaleFactor
                    end

                    if AttachmentSystem.NoCollision then
                        part.CanCollide = false
                    end

                    index = index + 1
                else
                    AttachmentSystem.Parts[part] = nil
                end
            end
        end
    end
end)

-- Initial scan for parts in the workspace
for _, part in ipairs(workspace:GetDescendants()) do
    AttachmentSystem:ProcessPart(part)
end

-- Listen for new parts being added to the workspace
workspace.DescendantAdded:Connect(function(part)
    AttachmentSystem:ProcessPart(part)
end)

-- Create a credit message
local creditMessage = Instance.new("Message", game.Workspace)
creditMessage.Text = "Fly Out Of Map\nby LILDANZVERT (Modded)\nLoaded Successfully!"
wait(3)
creditMessage:Destroy()
