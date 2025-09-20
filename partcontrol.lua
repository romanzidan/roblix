-- Unanchored Parts Controller v2
-- Modified by Gemini

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Physics and Simulation Settings
settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)

-- Main System Table
local AttachmentSystem = {
    Parts = {},
    CurrentMode = "None",
    Enabled = true,
    AnimationSpeed = 1,
    ScaleFactor = 1,
    AutoSize = true,
    NoCollision = true
}

-- All available formation modes
local AttachmentModes = {
    -- [NEW MODE] This mode will make all parts fly up and out of the map
    ["Fly_Out_Of_Map"] = {
        Scale = function(partCount)
            return {} -- No scaling needed for this mode
        end,
        Formation = function(part, data, index, total, scale)
            -- Set the target position to a very high point in the sky from the part's current location
            local targetPosition = part.Position + Vector3.new(0, 50000, 0)
            return {
                Position = CFrame.new(targetPosition),
                Rotation = CFrame.Angles(0, 0, 0) -- No specific rotation needed
            }
        end
    },

    ["Angel_Wings"] = {
        Scale = function(partCount)
            return {
                Width = math.min(partCount * 0.4, 8),
                Height = math.min(partCount * 0.5, 6)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local side = index % 2 == 0 and 1 or -1
            local layer = math.floor(index / 2) / (total / 2)
            local curve = math.sin(layer * math.pi)
            return {
                Position = HRP.CFrame * CFrame.new(
                    side * (scale.Width * layer),
                    scale.Height * curve,
                    -layer * 2
                ),
                Rotation = CFrame.Angles(0, side * 0.5, side * (math.pi / 4 * curve))
            }
        end
    },

    ["Demon_Wings"] = {
        Scale = function(partCount)
            return {
                Span = math.min(partCount * 0.6, 10),
                Curve = math.min(partCount * 0.4, 4)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local side = index % 2 == 0 and 1 or -1
            local progress = (index / total)
            local curve = math.sin(progress * math.pi)
            local time = tick() * AttachmentSystem.AnimationSpeed
            return {
                Position = HRP.CFrame * CFrame.new(
                    side * (scale.Span * progress),
                    scale.Curve * curve + math.sin(time + progress * 2),
                    -progress * 4
                ),
                Rotation = CFrame.Angles(
                    side * (curve * 0.7),
                    side * (progress * 1.2),
                    side * (math.pi / 2.5 * curve)
                )
            }
        end
    },

    ["Dragon_Aura"] = {
        Scale = function(partCount)
            return {
                Radius = math.min(partCount * 0.5, 12),
                Height = math.min(partCount * 0.6, 8)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local height = (index / total) * scale.Height
            local angle = (index / total) * math.pi * 8 + time
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(angle) * scale.Radius * (height / scale.Height),
                    height - scale.Height / 2,
                    math.sin(angle) * scale.Radius * (height / scale.Height)
                ),
                Rotation = CFrame.Angles(time, angle, time * 0.5)
            }
        end
    },

    ["Death_Crown"] = {
        Scale = function(partCount)
            return {
                Size = math.min(partCount * 0.3, 5),
                Points = math.min(partCount * 0.4, 6)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local angle = (index / total) * math.pi * 2
            local height = math.abs(math.sin(angle * scale.Points)) * scale.Size
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(angle) * scale.Size,
                    2 + height + math.sin(time + index * 0.1),
                    math.sin(angle) * scale.Size
                ),
                Rotation = CFrame.Angles(height * 0.5, angle, math.rad(60))
            }
        end
    },

    ["Void_Portal"] = {
        Scale = function(partCount)
            return {
                Radius = math.min(partCount * 0.4, 7),
                Depth = math.min(partCount * 0.3, 4)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local angle = (index / total) * math.pi * 2
            local spiral = angle + time
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(spiral) * scale.Radius,
                    math.sin(spiral) * scale.Radius,
                    math.sin(time + index * 0.1) * scale.Depth
                ),
                Rotation = CFrame.Angles(spiral, time, angle)
            }
        end
    },

    ["Death_Cage"] = {
        Scale = function(partCount)
            return {
                Size = math.min(partCount * 0.4, 6)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local layer = math.floor(index / 8)
            local segment = index % 8
            local angle = (segment / 8) * math.pi * 2
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(angle + time) * scale.Size,
                    layer * 2 - 5,
                    math.sin(angle + time) * scale.Size
                ),
                Rotation = CFrame.Angles(time, angle, math.pi / 2)
            }
        end
    },

    ["Shadow_Blades"] = {
        Scale = function(partCount)
            return {
                Radius = math.min(partCount * 0.3, 5),
                Height = math.min(partCount * 0.4, 4)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local angle = (index / total) * math.pi * 2
            local height = math.sin(angle * 3 + time) * scale.Height
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(angle) * scale.Radius,
                    height,
                    math.sin(angle) * scale.Radius
                ),
                Rotation = CFrame.Angles(math.pi / 2, angle + time, time)
            }
        end
    },

    ["Hell_Spiral"] = {
        Scale = function(partCount)
            return {
                Radius = math.min(partCount * 0.5, 8),
                Height = math.min(partCount * 0.6, 10)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local spiral = (index / total) * math.pi * 12
            local height = math.cos(spiral + time) * scale.Height
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(spiral) * scale.Radius * (1 - index / total),
                    height,
                    math.sin(spiral) * scale.Radius * (1 - index / total)
                ),
                Rotation = CFrame.Angles(spiral, time, spiral * 0.5)
            }
        end
    },

    ["Devil_Cross"] = {
        Scale = function(partCount)
            return {
                Size = math.min(partCount * 0.4, 6)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local section = math.floor(index / (total / 4))
            local progress = (index % (total / 4)) / (total / 4)
            local wave = math.sin(time + progress * math.pi) * 0.5
            local positions = {
                Vector3.new(0, scale.Size * progress, 0),
                Vector3.new(scale.Size * progress, 0, 0),
                Vector3.new(0, -scale.Size * progress, 0),
                Vector3.new(-scale.Size * progress, 0, 0)
            }
            return {
                Position = HRP.CFrame * CFrame.new(positions[section + 1]) * CFrame.new(0, wave, 0),
                Rotation = CFrame.Angles(wave, time, math.rad(90 * section))
            }
        end
    },

    ["Death_Ring"] = {
        Scale = function(partCount)
            return {
                Radius = math.min(partCount * 0.4, 7),
                Spin = math.min(partCount * 0.3, 4)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local angle = (index / total) * math.pi * 2
            local spin = time * scale.Spin
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(angle + spin) * scale.Radius,
                    math.sin(time) * 2,
                    math.sin(angle + spin) * scale.Radius
                ),
                Rotation = CFrame.Angles(spin, angle, spin * 0.5)
            }
        end
    },

    ["Pentagram"] = {
        Scale = function(partCount)
            return {
                Size = math.min(partCount * 0.4, 5)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local points = 5
            local angle = (index / total) * math.pi * 2
            local starAngle = angle * points
            local radius = scale.Size * (1 + math.sin(angle * 2 + time) * 0.2)
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(starAngle) * radius,
                    math.sin(time) * 2,
                    math.sin(starAngle) * radius
                ),
                Rotation = CFrame.Angles(time, starAngle, angle)
            }
        end
    },

    ["Blood_Ritual"] = {
        Scale = function(partCount)
            return {
                Radius = math.min(partCount * 0.5, 8)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local angle = (index / total) * math.pi * 2
            local height = math.sin(time + index * 0.5) * 3
            return {
                Position = HRP.CFrame * CFrame.new(
                    math.cos(angle + time) * scale.Radius,
                    height,
                    math.sin(angle + time) * scale.Radius
                ),
                Rotation = CFrame.Angles(
                    math.sin(time) * 0.5,
                    angle + time,
                    math.cos(time) * 0.5
                )
            }
        end
    },

    ["666"] = {
        Scale = function(partCount)
            return {
                Size = math.min(partCount * 0.3, 4)
            }
        end,
        Formation = function(part, data, index, total, scale)
            local time = tick() * AttachmentSystem.AnimationSpeed
            local segment = index % 3
            local number = math.floor(index / 3) % 3
            local angle = (segment / 3) * math.pi * 2
            local offset = number * scale.Size * 2
            return {
                Position = HRP.CFrame * CFrame.new(
                    offset + math.cos(angle + time) * scale.Size,
                    math.sin(time) * 2,
                    math.sin(angle + time) * scale.Size
                ),
                Rotation = CFrame.Angles(time, angle, time * 0.5)
            }
        end
    }
}

-- Function to process each part and add physics constraints
function AttachmentSystem:ProcessPart(part)
    if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(Character) then
        part.CustomPhysicalProperties = PhysicalProperties.new(0.01, 0, 0, 0, 0)
        part.CanCollide = false

        local attachment = Instance.new("Attachment")
        attachment.Parent = part

        local alignPos = Instance.new("AlignPosition")
        alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        alignPos.Attachment0 = attachment
        alignPos.MaxForce = 9e18
        alignPos.MaxVelocity = 9e18
        alignPos.Responsiveness = 200
        alignPos.Parent = part

        local alignOri = Instance.new("AlignOrientation")
        alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOri.Attachment0 = attachment
        alignOri.MaxTorque = 9e18
        alignOri.Responsiveness = 200
        alignOri.Parent = part

        self.Parts[part] = {
            Attachment = attachment,
            AlignPosition = alignPos,
            AlignOrientation = alignOri,
            Size = part.Size
        }
    end
end

-- Function to create the GUI
local function CreateModernGUI()
    local GUI = Instance.new("ScreenGui")
    GUI.Name = "ModernAttachmentController"
    GUI.ResetOnSpawn = false
    GUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainContainer"
    MainFrame.Size = UDim2.new(0.25, 0, 0.6, 0)
    MainFrame.Position = UDim2.new(0.75, -10, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = GUI
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0.02, 0)
    Corner.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0.08, 0)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.9, 0, 0.8, 0)
    Title.Position = UDim2.new(0.05, 0, 0.1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "unanchored parts controller v2"
    Title.TextColor3 = Color3.fromRGB(240, 240, 245)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = TitleBar

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    ScrollFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.Parent = MainFrame

    local ListLayout = Instance.new("UIListLayout", ScrollFrame)
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ButtonTemplate = Instance.new("TextButton")
    ButtonTemplate.Size = UDim2.new(1, 0, 0, 35) -- Fixed height for buttons
    ButtonTemplate.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    ButtonTemplate.TextColor3 = Color3.fromRGB(240, 240, 245)
    ButtonTemplate.Font = Enum.Font.GothamSemibold
    ButtonTemplate.TextSize = 14
    ButtonTemplate.AutoButtonColor = false

    -- Create buttons from the AttachmentModes table
    for modeName, _ in pairs(AttachmentModes) do
        local button = ButtonTemplate:Clone()
        button.Text = modeName:gsub("_", " ")
        button.Parent = ScrollFrame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = button

        button.MouseButton1Click:Connect(function()
            AttachmentSystem.CurrentMode = modeName
            for _, btn in ipairs(ScrollFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                end
            end
            button.BackgroundColor3 = Color3.fromRGB(70, 130, 240)
        end)
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)


    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Size = UDim2.new(0.9, 0, 0.15, 0)
    SettingsFrame.Position = UDim2.new(0.05, 0, 0.82, 0)
    SettingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    SettingsFrame.Parent = MainFrame

    local SettingsCorner = Instance.new("UICorner", SettingsFrame)
    SettingsCorner.CornerRadius = UDim.new(0, 8)


    local function CreateToggle(name, property, position)
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0.45, 0, 0.4, 0)
        toggle.Position = position
        toggle.BackgroundColor3 = AttachmentSystem[property] and Color3.fromRGB(70, 130, 240) or
            Color3.fromRGB(45, 45, 50)
        toggle.Text = name
        toggle.TextColor3 = Color3.fromRGB(240, 240, 245)
        toggle.Font = Enum.Font.GothamSemibold
        toggle.Parent = SettingsFrame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 8)
        toggleCorner.Parent = toggle

        toggle.MouseButton1Click:Connect(function()
            AttachmentSystem[property] = not AttachmentSystem[property]
            toggle.BackgroundColor3 = AttachmentSystem[property]
                and Color3.fromRGB(70, 130, 240)
                or Color3.fromRGB(45, 45, 50)
        end)
    end

    CreateToggle("Auto Size", "AutoSize", UDim2.new(0.03, 0, 0.3, 0))
    CreateToggle("No Collision", "NoCollision", UDim2.new(0.52, 0, 0.3, 0))

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 40)
    ToggleButton.Position = UDim2.new(0, -50, 0.5, -20)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 130, 240)
    ToggleButton.Text = "≡"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 24
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.Parent = GUI

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        ToggleButton.BackgroundColor3 = MainFrame.Visible
            and Color3.fromRGB(70, 130, 240)
            or Color3.fromRGB(45, 45, 50)
    end)
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

-- Create the GUI and display a credit message
CreateModernGUI()

local creditMessage = Instance.new("Message", game.Workspace)
creditMessage.Text = "Hilangin Tangga v2\nby LILDANZVERT (Modded)\nLoaded Successfully!"
wait(3)
creditMessage:Destroy()
