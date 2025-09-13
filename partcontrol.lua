--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Modern Theme Configuration
local THEME = {
    bg_primary = Color3.fromRGB(15, 15, 20),
    bg_secondary = Color3.fromRGB(25, 25, 35),
    bg_tertiary = Color3.fromRGB(35, 35, 45),
    accent_primary = Color3.fromRGB(255, 165, 0),   -- Orange
    accent_secondary = Color3.fromRGB(255, 140, 0), -- Dark Orange
    accent_gradient = Color3.fromRGB(255, 215, 0),  -- Gold
    text_primary = Color3.fromRGB(255, 255, 255),
    text_secondary = Color3.fromRGB(200, 200, 210),
    text_muted = Color3.fromRGB(140, 140, 150),
    glass_bg = Color3.fromRGB(20, 20, 30),
    success = Color3.fromRGB(0, 255, 127),
    danger = Color3.fromRGB(255, 69, 58),
}

-- Sound Effects
local function playSound(soundId, volume)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.5
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArakenRingSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- SPLASH SCREEN ANIMATION
local SplashFrame = Instance.new("Frame")
SplashFrame.Size = UDim2.new(1, 0, 1, 0)
SplashFrame.Position = UDim2.new(0, 0, 0, 0)
SplashFrame.BackgroundColor3 = THEME.bg_primary
SplashFrame.BorderSizePixel = 0
SplashFrame.ZIndex = 100
SplashFrame.Parent = ScreenGui

-- Background gradient for splash
local SplashGradient = Instance.new("UIGradient")
SplashGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, THEME.bg_primary),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, THEME.bg_secondary)
}
SplashGradient.Rotation = 45
SplashGradient.Parent = SplashFrame

-- Animated particles background
local ParticlesFrame = Instance.new("Frame")
ParticlesFrame.Size = UDim2.new(1, 0, 1, 0)
ParticlesFrame.BackgroundTransparency = 1
ParticlesFrame.Parent = SplashFrame

-- Create floating particles
for i = 1, 15 do
    local Particle = Instance.new("Frame")
    Particle.Size = UDim2.new(0, math.random(4, 12), 0, math.random(4, 12))
    Particle.Position = UDim2.new(math.random(), 0, math.random(), 0)
    Particle.BackgroundColor3 = THEME.accent_primary
    Particle.BackgroundTransparency = math.random(40, 80) / 100
    Particle.BorderSizePixel = 0
    Particle.Parent = ParticlesFrame

    local ParticleCorner = Instance.new("UICorner")
    ParticleCorner.CornerRadius = UDim.new(1, 0)
    ParticleCorner.Parent = Particle

    -- Animate particles
    spawn(function()
        while Particle.Parent do
            local tween = TweenService:Create(Particle, TweenInfo.new(
                math.random(30, 60) / 10,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,
                -1,
                true
            ), {
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundTransparency = math.random(30, 90) / 100
            })
            tween:Play()
            wait(math.random(10, 30) / 10)
        end
    end)
end

-- Main logo container
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 300, 0, 200)
LogoContainer.Position = UDim2.new(0.5, -150, 0.5, -100)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = SplashFrame

-- Araken logo with glow effect
local ArakenLogo = Instance.new("TextLabel")
ArakenLogo.Size = UDim2.new(1, 0, 0, 80)
ArakenLogo.Position = UDim2.new(0, 0, 0, 0)
ArakenLogo.BackgroundTransparency = 1
ArakenLogo.Text = "ARAKEN"
ArakenLogo.TextColor3 = THEME.accent_primary
ArakenLogo.TextScaled = true
ArakenLogo.Font = Enum.Font.GothamBold
ArakenLogo.Parent = LogoContainer

-- Glow effect for logo
local LogoGlow = Instance.new("TextLabel")
LogoGlow.Size = UDim2.new(1, 4, 1, 4)
LogoGlow.Position = UDim2.new(0, -2, 0, -2)
LogoGlow.BackgroundTransparency = 1
LogoGlow.Text = "ARAKEN"
LogoGlow.TextColor3 = THEME.accent_gradient
LogoGlow.TextScaled = true
LogoGlow.Font = Enum.Font.GothamBold
LogoGlow.TextTransparency = 0.7
LogoGlow.ZIndex = -1
LogoGlow.Parent = ArakenLogo

-- Subtitle
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 40)
Subtitle.Position = UDim2.new(0, 0, 0, 90)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Ring Control System"
Subtitle.TextColor3 = THEME.text_secondary
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = LogoContainer

-- Creator text
local CreatorText = Instance.new("TextLabel")
CreatorText.Size = UDim2.new(1, 0, 0, 30)
CreatorText.Position = UDim2.new(0, 0, 0, 140)
CreatorText.BackgroundTransparency = 1
CreatorText.Text = "by ErrorNoName"
CreatorText.TextColor3 = THEME.text_muted
CreatorText.TextScaled = true
CreatorText.Font = Enum.Font.Gotham
CreatorText.Parent = LogoContainer

-- Loading bar container
local LoadingContainer = Instance.new("Frame")
LoadingContainer.Size = UDim2.new(0, 250, 0, 8)
LoadingContainer.Position = UDim2.new(0.5, -125, 0.75, 0)
LoadingContainer.BackgroundColor3 = THEME.bg_tertiary
LoadingContainer.BorderSizePixel = 0
LoadingContainer.Parent = SplashFrame

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 4)
LoadingCorner.Parent = LoadingContainer

-- Loading bar fill
local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = THEME.accent_primary
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = LoadingContainer

local LoadingBarCorner = Instance.new("UICorner")
LoadingBarCorner.CornerRadius = UDim.new(0, 4)
LoadingBarCorner.Parent = LoadingBar

-- Loading bar gradient
local LoadingGradient = Instance.new("UIGradient")
LoadingGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, THEME.accent_primary),
    ColorSequenceKeypoint.new(1, THEME.accent_gradient)
}
LoadingGradient.Parent = LoadingBar

-- Loading text
local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 25)
LoadingText.Position = UDim2.new(0, 0, 1, 15)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Initializing..."
LoadingText.TextColor3 = THEME.text_muted
LoadingText.TextScaled = true
LoadingText.Font = Enum.Font.Gotham
LoadingText.Parent = LoadingContainer

-- MAIN INTERFACE (Modern Glassmorphism Design)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 580)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -290)
MainFrame.BackgroundColor3 = THEME.glass_bg
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Glassmorphism effect
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = THEME.accent_primary
MainStroke.Thickness = 1
MainStroke.Transparency = 0.8
MainStroke.Parent = MainFrame

-- Main gradient background
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
MainGradient.Rotation = 135
MainGradient.Parent = MainFrame

-- Header section
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Size = UDim2.new(1, 0, 0, 80)
HeaderFrame.BackgroundColor3 = THEME.bg_secondary
HeaderFrame.BackgroundTransparency = 0.3
HeaderFrame.BorderSizePixel = 0
HeaderFrame.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = HeaderFrame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, THEME.accent_primary),
    ColorSequenceKeypoint.new(1, THEME.accent_secondary)
}
HeaderGradient.Rotation = 45
HeaderGradient.Parent = HeaderFrame

-- Araken brand in header
local HeaderLogo = Instance.new("TextLabel")
HeaderLogo.Size = UDim2.new(0, 120, 1, -20)
HeaderLogo.Position = UDim2.new(0, 20, 0, 10)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Text = "ARAKEN"
HeaderLogo.TextColor3 = THEME.text_primary
HeaderLogo.TextScaled = true
HeaderLogo.Font = Enum.Font.GothamBold
HeaderLogo.Parent = HeaderFrame

-- Ring System title
local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(0, 180, 0, 25)
HeaderTitle.Position = UDim2.new(0, 20, 0, 45)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "Ring Control System"
HeaderTitle.TextColor3 = THEME.text_secondary
HeaderTitle.TextScaled = true
HeaderTitle.Font = Enum.Font.Gotham
HeaderTitle.Parent = HeaderFrame

-- Close/Minimize button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundColor3 = THEME.danger
CloseButton.BackgroundTransparency = 0.2
CloseButton.Text = "✕"
CloseButton.TextColor3 = THEME.text_primary
CloseButton.TextScaled = true
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = HeaderFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseButton

-- Content Container
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -40, 1, -100)
ContentFrame.Position = UDim2.new(0, 20, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Modern Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 0, 60)
ToggleButton.Position = UDim2.new(0, 0, 0, 0)
ToggleButton.BackgroundColor3 = THEME.bg_secondary
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.Text = "Ring System: OFF"
ToggleButton.TextColor3 = THEME.text_primary
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Parent = ContentFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 15)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = THEME.accent_primary
ToggleStroke.Thickness = 1
ToggleStroke.Transparency = 0.7
ToggleStroke.Parent = ToggleButton

-- Status indicator
local StatusIndicator = Instance.new("Frame")
StatusIndicator.Size = UDim2.new(0, 20, 0, 20)
StatusIndicator.Position = UDim2.new(0, 15, 0.5, -10)
StatusIndicator.BackgroundColor3 = THEME.danger
StatusIndicator.BorderSizePixel = 0
StatusIndicator.Parent = ToggleButton

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = StatusIndicator

-- Status indicator glow effect
local StatusGlow = Instance.new("Frame")
StatusGlow.Size = UDim2.new(1, 8, 1, 8)
StatusGlow.Position = UDim2.new(0, -4, 0, -4)
StatusGlow.BackgroundColor3 = THEME.danger
StatusGlow.BackgroundTransparency = 0.7
StatusGlow.BorderSizePixel = 0
StatusGlow.ZIndex = -1
StatusGlow.Parent = StatusIndicator

local StatusGlowCorner = Instance.new("UICorner")
StatusGlowCorner.CornerRadius = UDim.new(1, 0)
StatusGlowCorner.Parent = StatusGlow

-- Activation bar (animated progress bar)
local ActivationBar = Instance.new("Frame")
ActivationBar.Size = UDim2.new(0, 0, 0, 4)
ActivationBar.Position = UDim2.new(0, 0, 1, -4)
ActivationBar.BackgroundColor3 = THEME.danger
ActivationBar.BorderSizePixel = 0
ActivationBar.Parent = ToggleButton

local ActivationBarCorner = Instance.new("UICorner")
ActivationBarCorner.CornerRadius = UDim.new(0, 2)
ActivationBarCorner.Parent = ActivationBar

-- Activation bar gradient
local ActivationGradient = Instance.new("UIGradient")
ActivationGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, THEME.danger),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
}
ActivationGradient.Parent = ActivationBar

-- Click ripple effect container
local RippleContainer = Instance.new("Frame")
RippleContainer.Size = UDim2.new(1, 0, 1, 0)
RippleContainer.BackgroundTransparency = 1
RippleContainer.ClipsDescendants = true
RippleContainer.Parent = ToggleButton

local RippleCorner = Instance.new("UICorner")
RippleCorner.CornerRadius = UDim.new(0, 15)
RippleCorner.Parent = RippleContainer

-- Radius Control Section
local RadiusFrame = Instance.new("Frame")
RadiusFrame.Size = UDim2.new(1, 0, 0, 120)
RadiusFrame.Position = UDim2.new(0, 0, 0, 80)
RadiusFrame.BackgroundColor3 = THEME.bg_secondary
RadiusFrame.BackgroundTransparency = 0.5
RadiusFrame.BorderSizePixel = 0
RadiusFrame.Parent = ContentFrame

local RadiusFrameCorner = Instance.new("UICorner")
RadiusFrameCorner.CornerRadius = UDim.new(0, 15)
RadiusFrameCorner.Parent = RadiusFrame

local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Size = UDim2.new(1, -20, 0, 30)
RadiusLabel.Position = UDim2.new(0, 10, 0, 10)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Text = "Radius Control"
RadiusLabel.TextColor3 = THEME.text_secondary
RadiusLabel.TextScaled = true
RadiusLabel.Font = Enum.Font.Gotham
RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
RadiusLabel.Parent = RadiusFrame

-- Radius Display
local RadiusDisplay = Instance.new("TextLabel")
RadiusDisplay.Size = UDim2.new(0, 100, 0, 40)
RadiusDisplay.Position = UDim2.new(0.5, -50, 0, 45)
RadiusDisplay.BackgroundColor3 = THEME.accent_primary
RadiusDisplay.BackgroundTransparency = 0.2
RadiusDisplay.BorderSizePixel = 0
RadiusDisplay.Text = "50"
RadiusDisplay.TextColor3 = THEME.text_primary
RadiusDisplay.TextScaled = true
RadiusDisplay.Font = Enum.Font.GothamBold
RadiusDisplay.Parent = RadiusFrame

local RadiusDisplayCorner = Instance.new("UICorner")
RadiusDisplayCorner.CornerRadius = UDim.new(0, 12)
RadiusDisplayCorner.Parent = RadiusDisplay

-- Decrease Radius Button
local DecreaseRadius = Instance.new("TextButton")
DecreaseRadius.Size = UDim2.new(0, 50, 0, 40)
DecreaseRadius.Position = UDim2.new(0, 20, 0, 45)
DecreaseRadius.BackgroundColor3 = THEME.bg_tertiary
DecreaseRadius.Text = "-"
DecreaseRadius.TextColor3 = THEME.text_primary
DecreaseRadius.TextScaled = true
DecreaseRadius.Font = Enum.Font.GothamBold
DecreaseRadius.BorderSizePixel = 0
DecreaseRadius.Parent = RadiusFrame

local DecreaseCorner = Instance.new("UICorner")
DecreaseCorner.CornerRadius = UDim.new(0, 12)
DecreaseCorner.Parent = DecreaseRadius

-- Increase Radius Button
local IncreaseRadius = Instance.new("TextButton")
IncreaseRadius.Size = UDim2.new(0, 50, 0, 40)
IncreaseRadius.Position = UDim2.new(1, -70, 0, 45)
IncreaseRadius.BackgroundColor3 = THEME.bg_tertiary
IncreaseRadius.Text = "+"
IncreaseRadius.TextColor3 = THEME.text_primary
IncreaseRadius.TextScaled = true
IncreaseRadius.Font = Enum.Font.GothamBold
IncreaseRadius.BorderSizePixel = 0
IncreaseRadius.Parent = RadiusFrame

local IncreaseCorner = Instance.new("UICorner")
IncreaseCorner.CornerRadius = UDim.new(0, 12)
IncreaseCorner.Parent = IncreaseRadius

-- Stats Section
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, 0, 0, 70)
StatsFrame.Position = UDim2.new(0, 0, 0, 300)
StatsFrame.BackgroundColor3 = THEME.bg_secondary
StatsFrame.BackgroundTransparency = 0.5
StatsFrame.BorderSizePixel = 0
StatsFrame.Parent = ContentFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 15)
StatsCorner.Parent = StatsFrame

local StatsTitle = Instance.new("TextLabel")
StatsTitle.Size = UDim2.new(1, -20, 0, 25)
StatsTitle.Position = UDim2.new(0, 10, 0, 5)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Text = "System Statistics"
StatsTitle.TextColor3 = THEME.text_secondary
StatsTitle.TextScaled = true
StatsTitle.Font = Enum.Font.Gotham
StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
StatsTitle.Parent = StatsFrame

local PartsCount = Instance.new("TextLabel")
PartsCount.Size = UDim2.new(0.5, -10, 0, 25)
PartsCount.Position = UDim2.new(0, 10, 0, 35)
PartsCount.BackgroundTransparency = 1
PartsCount.Text = "Parts: 0"
PartsCount.TextColor3 = THEME.accent_primary
PartsCount.TextScaled = true
PartsCount.Font = Enum.Font.Gotham
PartsCount.TextXAlignment = Enum.TextXAlignment.Left
PartsCount.Parent = StatsFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0.5, -10, 0, 25)
StatusText.Position = UDim2.new(0.5, 0, 0, 35)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Status: Idle"
StatusText.TextColor3 = THEME.text_muted
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatsFrame

-- Watermark
local Watermark = Instance.new("TextLabel")
Watermark.Size = UDim2.new(1, 0, 0, 30)
Watermark.Position = UDim2.new(0, 0, 1, -35)
Watermark.BackgroundTransparency = 1
Watermark.Text = "ARAKEN • Ring & Orb System • by ErrorNoName"
Watermark.TextColor3 = THEME.text_muted
Watermark.TextScaled = true
Watermark.Font = Enum.Font.Gotham
Watermark.Parent = MainFrame

-- SPLASH SCREEN ANIMATION SEQUENCE
spawn(function()
    -- Play entrance sound
    playSound("6958727243", 0.3) -- Modern UI sound

    -- Animate logo entrance
    ArakenLogo.TextTransparency = 1
    Subtitle.TextTransparency = 1
    CreatorText.TextTransparency = 1
    LoadingContainer.BackgroundTransparency = 1
    LoadingText.TextTransparency = 1

    -- Logo fade in with glow
    TweenService:Create(ArakenLogo, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()

    wait(0.5)

    TweenService:Create(Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()

    wait(0.3)

    TweenService:Create(CreatorText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()

    wait(0.5)

    -- Show loading elements
    TweenService:Create(LoadingContainer, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()

    TweenService:Create(LoadingText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    }):Play()

    -- Loading sequence
    local loadingSteps = {
        { text = "Initializing system...",     progress = 0.2 },
        { text = "Loading Ring Controller...", progress = 0.4 },
        { text = "Scanning workspace...",      progress = 0.6 },
        { text = "Preparing interface...",     progress = 0.8 },
        { text = "Ready to launch!",           progress = 1.0 }
    }

    for i, step in ipairs(loadingSteps) do
        LoadingText.Text = step.text
        TweenService:Create(LoadingBar, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(step.progress, 0, 1, 0)
        }):Play()
        wait(0.8)
    end

    wait(0.5)

    -- Final loading complete sound
    playSound("12221967", 0.4)

    -- Fade out splash screen
    TweenService:Create(SplashFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()

    for _, element in pairs(SplashFrame:GetDescendants()) do
        if element:IsA("GuiObject") then
            TweenService:Create(element, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
        end
        if element:IsA("TextLabel") then
            TweenService:Create(element, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
        end
    end

    wait(0.8)
    SplashFrame:Destroy()

    -- Show main interface with animation
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 580),
        Position = UDim2.new(0.5, -190, 0.5, -290)
    }):Play()

    playSound("6895079853", 0.3) -- Interface open sound
end)

-- MODERN INTERACTION LOGIC
local ringPartsEnabled = false
local radius = 50
local parts = {}

-- Effect System Configuration
local EFFECT_TYPES = {
    RING = "Ring",
    ORB = "Orb"
}

local currentEffectType = EFFECT_TYPES.RING
local orbConfig = {
    layers = 3,                 -- Number of orbital layers
    layerSpacing = 20,          -- Distance between layers
    rotationSpeed = 1.5,        -- Base rotation speed
    orbHeight = 12,             -- Vertical oscillation range
    perfectDistribution = true, -- Ensure perfect distribution
    dynamicRadius = true,       -- Adjust radius based on part count
    layerTilt = 0.4,            -- Orbital plane tilt variation
    heightVariation = 0.6,      -- Height oscillation intensity
    minRadius = 8,              -- Minimum orbital radius
    maxRadius = 50              -- Maximum orbital radius
}

-- Ripple effect function
local function createRippleEffect(button, clickPosition)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X, 0, clickPosition.Y)
    ripple.BackgroundColor3 = THEME.accent_primary
    ripple.BackgroundTransparency = 0.5
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.Parent = RippleContainer

    local rippleCorner = Instance.new("UICorner")
    rippleCorner.CornerRadius = UDim.new(1, 0)
    rippleCorner.Parent = ripple

    -- Animate ripple expansion
    local expandTween = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = UDim2.new(0, 300, 0, 300),
            BackgroundTransparency = 1
        })

    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Activation bar animation
local function animateActivationBar(isActivating)
    if isActivating then
        -- Animate to green/success state
        ActivationBar.BackgroundColor3 = THEME.success
        ActivationGradient.Color = ColorSequence.new {
            ColorSequenceKeypoint.new(0, THEME.success),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 150))
        }

        TweenService:Create(ActivationBar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 4)
        }):Play()

        -- Pulse effect on status indicator
        local pulseLoop
        pulseLoop = TweenService:Create(StatusGlow,
            TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.3
        })
        pulseLoop:Play()

        return pulseLoop
    else
        -- Animate to red/danger state
        ActivationBar.BackgroundColor3 = THEME.danger
        ActivationGradient.Color = ColorSequence.new {
            ColorSequenceKeypoint.new(0, THEME.danger),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
        }

        TweenService:Create(ActivationBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 4)
        }):Play()

        -- Stop any pulse effect
        TweenService:Create(StatusGlow, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.7
        }):Play()
    end
end

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    playSound("6895079853", 0.4)

    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()

    wait(0.4)
    ScreenGui:Destroy()
end)

local currentPulseLoop = nil

-- Modern toggle functionality with enhanced animations
ToggleButton.MouseButton1Click:Connect(function()
    -- Get click position for ripple effect
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local buttonPos = ToggleButton.AbsolutePosition
    local clickPos = Vector2.new(
        mouse.X - buttonPos.X,
        mouse.Y - buttonPos.Y
    )

    -- Create ripple effect
    createRippleEffect(ToggleButton, clickPos)

    -- Toggle state
    ringPartsEnabled = not ringPartsEnabled

    if ringPartsEnabled then
        ToggleButton.Text = "Ring System: ON"
        ToggleButton.BackgroundColor3 = THEME.success
        StatusIndicator.BackgroundColor3 = THEME.success
        StatusGlow.BackgroundColor3 = THEME.success
        StatusText.Text = "Status: Active"
        StatusText.TextColor3 = THEME.success
        playSound("4590662766", 0.5) -- Activation sound

        -- Enhanced glow effect
        TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {
            Transparency = 0.2,
            Thickness = 3,
            Color = THEME.success
        }):Play()

        -- Button scale effect
        TweenService:Create(ToggleButton, TweenInfo.new(0.1), {
            Size = UDim2.new(1, 2, 0, 62)
        }):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 60)
        }):Play()

        -- Animate activation bar
        currentPulseLoop = animateActivationBar(true)
    else
        ToggleButton.Text = "Ring System: OFF"
        ToggleButton.BackgroundColor3 = THEME.bg_secondary
        StatusIndicator.BackgroundColor3 = THEME.danger
        StatusGlow.BackgroundColor3 = THEME.danger
        StatusText.Text = "Status: Idle"
        StatusText.TextColor3 = THEME.text_muted
        playSound("4590662766", 0.3) -- Deactivation sound

        TweenService:Create(ToggleStroke, TweenInfo.new(0.3), {
            Transparency = 0.7,
            Thickness = 1,
            Color = THEME.accent_primary
        }):Play()

        -- Button scale effect
        TweenService:Create(ToggleButton, TweenInfo.new(0.1), {
            Size = UDim2.new(1, -2, 0, 58)
        }):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 60)
        }):Play()

        -- Stop pulse and animate activation bar
        if currentPulseLoop then
            currentPulseLoop:Cancel()
        end
        animateActivationBar(false)
    end
end)

-- Radius controls with modern feedback
DecreaseRadius.MouseButton1Click:Connect(function()
    if radius > 10 then
        radius = radius - 5
        RadiusDisplay.Text = tostring(radius)
        playSound("12221967", 0.3)

        -- Visual feedback
        TweenService:Create(DecreaseRadius, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.accent_primary
        }):Play()
        TweenService:Create(DecreaseRadius, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.bg_tertiary
        }):Play()
    end
end)

IncreaseRadius.MouseButton1Click:Connect(function()
    if radius < 100 then
        radius = radius + 5
        RadiusDisplay.Text = tostring(radius)
        playSound("12221967", 0.3)

        -- Visual feedback
        TweenService:Create(IncreaseRadius, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.accent_primary
        }):Play()
        TweenService:Create(IncreaseRadius, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.bg_tertiary
        }):Play()
    end
end)

-- Effect System Configuration and Functions
-- (Moved here to be defined before use)

-- Update function for effect-specific UI
local function updateEffectSpecificUI()
    if currentEffectType == EFFECT_TYPES.ORB then
        if OrbConfigFrame then
            OrbConfigFrame.Visible = true
            if LayersLabel then LayersLabel.Text = "Layers: " .. orbConfig.layers end
            if SpeedLabel then SpeedLabel.Text = "Speed: " .. string.format("%.1f", orbConfig.rotationSpeed) end

            -- Animate in with new size
            OrbConfigFrame.Size = UDim2.new(1, 0, 0, 0)
            TweenService:Create(OrbConfigFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 0, 120)
            }):Play()

            -- Animate stroke effect
            if OrbConfigStroke then
                TweenService:Create(OrbConfigStroke, TweenInfo.new(0.3), {
                    Transparency = 0.3
                }):Play()
            end
        end
    else
        if OrbConfigFrame then
            -- Animate out
            TweenService:Create(OrbConfigFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(1, 0, 0, 0)
            }):Play()

            -- Fade stroke
            if OrbConfigStroke then
                TweenService:Create(OrbConfigStroke, TweenInfo.new(0.2), {
                    Transparency = 0.9
                }):Play()
            end

            spawn(function()
                wait(0.3)
                if OrbConfigFrame then
                    OrbConfigFrame.Visible = false
                end
            end)
        end
    end
end

-- Effect selection functionality (will be defined after buttons are created)
local updateEffectButtons

-- Effect Selection Container
local EffectContainer = Instance.new("Frame")
EffectContainer.Size = UDim2.new(1, 0, 0, 80)
EffectContainer.Position = UDim2.new(0, 0, 0, 210)
EffectContainer.BackgroundColor3 = THEME.bg_tertiary
EffectContainer.BackgroundTransparency = 0.3
EffectContainer.BorderSizePixel = 0
EffectContainer.Parent = ContentFrame

local EffectCorner = Instance.new("UICorner")
EffectCorner.CornerRadius = UDim.new(0, 12)
EffectCorner.Parent = EffectContainer

local EffectStroke = Instance.new("UIStroke")
EffectStroke.Color = THEME.accent_primary
EffectStroke.Thickness = 1
EffectStroke.Transparency = 0.8
EffectStroke.Parent = EffectContainer

-- Effect selection title
local EffectTitle = Instance.new("TextLabel")
EffectTitle.Size = UDim2.new(1, -20, 0, 25)
EffectTitle.Position = UDim2.new(0, 10, 0, 5)
EffectTitle.BackgroundTransparency = 1
EffectTitle.Text = "Effect Mode"
EffectTitle.TextColor3 = THEME.text_primary
EffectTitle.TextScaled = true
EffectTitle.Font = Enum.Font.GothamBold
EffectTitle.TextXAlignment = Enum.TextXAlignment.Left
EffectTitle.Parent = EffectContainer

-- Ring Effect Button
local RingButton = Instance.new("TextButton")
RingButton.Size = UDim2.new(0, 120, 0, 35)
RingButton.Position = UDim2.new(0, 10, 0, 35)
RingButton.BackgroundColor3 = THEME.accent_primary
RingButton.Text = "🔗 Ring"
RingButton.TextColor3 = THEME.text_primary
RingButton.TextScaled = true
RingButton.Font = Enum.Font.GothamBold
RingButton.BorderSizePixel = 0
RingButton.Parent = EffectContainer

local RingCorner = Instance.new("UICorner")
RingCorner.CornerRadius = UDim.new(0, 8)
RingCorner.Parent = RingButton

local RingGradient = Instance.new("UIGradient")
RingGradient.Color = ColorSequence.new {
    ColorSequenceKeypoint.new(0, THEME.accent_primary),
    ColorSequenceKeypoint.new(1, THEME.accent_secondary)
}
RingGradient.Rotation = 45
RingGradient.Parent = RingButton

-- Orb Effect Button
local OrbButton = Instance.new("TextButton")
OrbButton.Size = UDim2.new(0, 120, 0, 35)
OrbButton.Position = UDim2.new(0, 140, 0, 35)
OrbButton.BackgroundColor3 = THEME.bg_secondary
OrbButton.Text = "⚪ Orb"
OrbButton.TextColor3 = THEME.text_secondary
OrbButton.TextScaled = true
OrbButton.Font = Enum.Font.Gotham
OrbButton.BorderSizePixel = 0
OrbButton.Parent = EffectContainer

local OrbCorner = Instance.new("UICorner")
OrbCorner.CornerRadius = UDim.new(0, 8)
OrbCorner.Parent = OrbButton

-- Current effect indicator
local EffectIndicator = Instance.new("TextLabel")
EffectIndicator.Size = UDim2.new(0, 100, 0, 20)
EffectIndicator.Position = UDim2.new(1, -110, 0, 5)
EffectIndicator.BackgroundTransparency = 1
EffectIndicator.Text = "Current: Ring"
EffectIndicator.TextColor3 = THEME.accent_primary
EffectIndicator.TextScaled = true
EffectIndicator.Font = Enum.Font.GothamBold
EffectIndicator.TextXAlignment = Enum.TextXAlignment.Right
EffectIndicator.Parent = EffectContainer

-- Define the updateEffectButtons function now that all UI elements exist
updateEffectButtons = function()
    if not RingButton or not OrbButton or not EffectIndicator then
        return -- Safety check - don't run if buttons don't exist yet
    end

    if currentEffectType == EFFECT_TYPES.RING then
        -- Ring button active
        RingButton.BackgroundColor3 = THEME.accent_primary
        RingButton.TextColor3 = THEME.text_primary

        -- Orb button inactive
        OrbButton.BackgroundColor3 = THEME.bg_secondary
        OrbButton.TextColor3 = THEME.text_secondary

        EffectIndicator.Text = "Current: Ring"
        EffectIndicator.TextColor3 = THEME.accent_primary
    else
        -- Orb button active
        OrbButton.BackgroundColor3 = THEME.accent_primary
        OrbButton.TextColor3 = THEME.text_primary

        -- Ring button inactive
        RingButton.BackgroundColor3 = THEME.bg_secondary
        RingButton.TextColor3 = THEME.text_secondary

        EffectIndicator.Text = "Current: Orb"
        EffectIndicator.TextColor3 = THEME.accent_primary
    end

    -- Update effect-specific UI
    updateEffectSpecificUI()
end

-- Effect button functionality
RingButton.MouseButton1Click:Connect(function()
    if currentEffectType ~= EFFECT_TYPES.RING then
        currentEffectType = EFFECT_TYPES.RING
        updateEffectButtons()
        playSound("4590662766", 0.3)

        -- Button feedback animation
        TweenService:Create(RingButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 125, 0, 38)
        }):Play()
        TweenService:Create(RingButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 120, 0, 35)
        }):Play()

        -- Notification
        StarterGui:SetCore("SendNotification", {
            Title = "ARAKEN • Ring System",
            Text = "Switched to Ring Mode",
            Duration = 2
        })
    end
end)

OrbButton.MouseButton1Click:Connect(function()
    if currentEffectType ~= EFFECT_TYPES.ORB then
        currentEffectType = EFFECT_TYPES.ORB
        updateEffectButtons()
        playSound("4590662766", 0.3)

        -- Button feedback animation
        TweenService:Create(OrbButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 125, 0, 38)
        }):Play()
        TweenService:Create(OrbButton, TweenInfo.new(0.2), {
            Size = UDim2.new(0, 120, 0, 35)
        }):Play()

        -- Notification
        StarterGui:SetCore("SendNotification", {
            Title = "ARAKEN • Ring System",
            Text = "Switched to Orb Mode - Multi-layer orbital system",
            Duration = 3
        })
    end
end)

-- Initialize effect buttons now that everything is created
updateEffectButtons()

-- Orb Configuration Container (enhanced with controls)
local OrbConfigFrame = Instance.new("Frame")
OrbConfigFrame.Size = UDim2.new(1, 0, 0, 120)
OrbConfigFrame.Position = UDim2.new(0, 0, 0, 380)
OrbConfigFrame.BackgroundColor3 = THEME.bg_tertiary
OrbConfigFrame.BackgroundTransparency = 0.3
OrbConfigFrame.BorderSizePixel = 0
OrbConfigFrame.Visible = false
OrbConfigFrame.Parent = ContentFrame

local OrbConfigCorner = Instance.new("UICorner")
OrbConfigCorner.CornerRadius = UDim.new(0, 12)
OrbConfigCorner.Parent = OrbConfigFrame

local OrbConfigStroke = Instance.new("UIStroke")
OrbConfigStroke.Color = THEME.accent_primary
OrbConfigStroke.Thickness = 1
OrbConfigStroke.Transparency = 0.7
OrbConfigStroke.Parent = OrbConfigFrame

-- Orb controls title
local OrbTitle = Instance.new("TextLabel")
OrbTitle.Size = UDim2.new(1, -20, 0, 25)
OrbTitle.Position = UDim2.new(0, 10, 0, 5)
OrbTitle.BackgroundTransparency = 1
OrbTitle.Text = "⚡ Orb Configuration"
OrbTitle.TextColor3 = THEME.accent_primary
OrbTitle.TextScaled = true
OrbTitle.Font = Enum.Font.GothamBold
OrbTitle.TextXAlignment = Enum.TextXAlignment.Left
OrbTitle.Parent = OrbConfigFrame

-- Layers control
local LayersContainer = Instance.new("Frame")
LayersContainer.Size = UDim2.new(0, 120, 0, 25)
LayersContainer.Position = UDim2.new(0, 10, 0, 35)
LayersContainer.BackgroundTransparency = 1
LayersContainer.Parent = OrbConfigFrame

local LayersLabel = Instance.new("TextLabel")
LayersLabel.Size = UDim2.new(0, 80, 1, 0)
LayersLabel.Position = UDim2.new(0, 0, 0, 0)
LayersLabel.BackgroundTransparency = 1
LayersLabel.Text = "Layers: " .. orbConfig.layers
LayersLabel.TextColor3 = THEME.text_secondary
LayersLabel.TextScaled = true
LayersLabel.Font = Enum.Font.Gotham
LayersLabel.TextXAlignment = Enum.TextXAlignment.Left
LayersLabel.Parent = LayersContainer

local LayersDecrease = Instance.new("TextButton")
LayersDecrease.Size = UDim2.new(0, 20, 1, 0)
LayersDecrease.Position = UDim2.new(0, 80, 0, 0)
LayersDecrease.BackgroundColor3 = THEME.bg_secondary
LayersDecrease.Text = "-"
LayersDecrease.TextColor3 = THEME.text_primary
LayersDecrease.TextScaled = true
LayersDecrease.Font = Enum.Font.GothamBold
LayersDecrease.BorderSizePixel = 0
LayersDecrease.Parent = LayersContainer

local LayersDecreaseCorner = Instance.new("UICorner")
LayersDecreaseCorner.CornerRadius = UDim.new(0, 4)
LayersDecreaseCorner.Parent = LayersDecrease

local LayersIncrease = Instance.new("TextButton")
LayersIncrease.Size = UDim2.new(0, 20, 1, 0)
LayersIncrease.Position = UDim2.new(0, 105, 0, 0)
LayersIncrease.BackgroundColor3 = THEME.bg_secondary
LayersIncrease.Text = "+"
LayersIncrease.TextColor3 = THEME.text_primary
LayersIncrease.TextScaled = true
LayersIncrease.Font = Enum.Font.GothamBold
LayersIncrease.BorderSizePixel = 0
LayersIncrease.Parent = LayersContainer

local LayersIncreaseCorner = Instance.new("UICorner")
LayersIncreaseCorner.CornerRadius = UDim.new(0, 4)
LayersIncreaseCorner.Parent = LayersIncrease

-- Speed control
local SpeedContainer = Instance.new("Frame")
SpeedContainer.Size = UDim2.new(0, 120, 0, 25)
SpeedContainer.Position = UDim2.new(0, 140, 0, 35)
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.Parent = OrbConfigFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0, 80, 1, 0)
SpeedLabel.Position = UDim2.new(0, 0, 0, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: " .. orbConfig.rotationSpeed
SpeedLabel.TextColor3 = THEME.text_secondary
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedContainer

local SpeedDecrease = Instance.new("TextButton")
SpeedDecrease.Size = UDim2.new(0, 20, 1, 0)
SpeedDecrease.Position = UDim2.new(0, 80, 0, 0)
SpeedDecrease.BackgroundColor3 = THEME.bg_secondary
SpeedDecrease.Text = "-"
SpeedDecrease.TextColor3 = THEME.text_primary
SpeedDecrease.TextScaled = true
SpeedDecrease.Font = Enum.Font.GothamBold
SpeedDecrease.BorderSizePixel = 0
SpeedDecrease.Parent = SpeedContainer

local SpeedDecreaseCorner = Instance.new("UICorner")
SpeedDecreaseCorner.CornerRadius = UDim.new(0, 4)
SpeedDecreaseCorner.Parent = SpeedDecrease

local SpeedIncrease = Instance.new("TextButton")
SpeedIncrease.Size = UDim2.new(0, 20, 1, 0)
SpeedIncrease.Position = UDim2.new(0, 105, 0, 0)
SpeedIncrease.BackgroundColor3 = THEME.bg_secondary
SpeedIncrease.Text = "+"
SpeedIncrease.TextColor3 = THEME.text_primary
SpeedIncrease.TextScaled = true
SpeedIncrease.Font = Enum.Font.GothamBold
SpeedIncrease.BorderSizePixel = 0
SpeedIncrease.Parent = SpeedContainer

local SpeedIncreaseCorner = Instance.new("UICorner")
SpeedIncreaseCorner.CornerRadius = UDim.new(0, 4)
SpeedIncreaseCorner.Parent = SpeedIncrease

-- Orb status indicator
local OrbStatusText = Instance.new("TextLabel")
OrbStatusText.Size = UDim2.new(1, -20, 0, 25)
OrbStatusText.Position = UDim2.new(0, 10, 0, 70)
OrbStatusText.BackgroundTransparency = 1
OrbStatusText.Text = "🌟 Perfect orbital distribution active"
OrbStatusText.TextColor3 = THEME.accent_primary
OrbStatusText.TextScaled = true
OrbStatusText.Font = Enum.Font.GothamBold
OrbStatusText.TextXAlignment = Enum.TextXAlignment.Center
OrbStatusText.Parent = OrbConfigFrame

-- Performance indicator
local PerformanceText = Instance.new("TextLabel")
PerformanceText.Size = UDim2.new(1, -20, 0, 20)
PerformanceText.Position = UDim2.new(0, 10, 0, 95)
PerformanceText.BackgroundTransparency = 1
PerformanceText.Text = "Optimized for smooth performance"
PerformanceText.TextColor3 = THEME.text_secondary
PerformanceText.TextScaled = true
PerformanceText.Font = Enum.Font.Gotham
PerformanceText.TextXAlignment = Enum.TextXAlignment.Center
PerformanceText.Parent = OrbConfigFrame

-- Orb control button functionality
LayersDecrease.MouseButton1Click:Connect(function()
    if orbConfig.layers > 1 then
        orbConfig.layers = orbConfig.layers - 1
        LayersLabel.Text = "Layers: " .. orbConfig.layers
        playSound("12221967", 0.3)

        -- Visual feedback
        TweenService:Create(LayersDecrease, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.accent_primary
        }):Play()
        TweenService:Create(LayersDecrease, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.bg_secondary
        }):Play()
    end
end)

LayersIncrease.MouseButton1Click:Connect(function()
    if orbConfig.layers < 6 then
        orbConfig.layers = orbConfig.layers + 1
        LayersLabel.Text = "Layers: " .. orbConfig.layers
        playSound("12221967", 0.3)

        -- Visual feedback
        TweenService:Create(LayersIncrease, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.accent_primary
        }):Play()
        TweenService:Create(LayersIncrease, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.bg_secondary
        }):Play()
    end
end)

SpeedDecrease.MouseButton1Click:Connect(function()
    if orbConfig.rotationSpeed > 0.5 then
        orbConfig.rotationSpeed = math.max(0.5, orbConfig.rotationSpeed - 0.2)
        SpeedLabel.Text = "Speed: " .. string.format("%.1f", orbConfig.rotationSpeed)
        playSound("12221967", 0.3)

        -- Visual feedback
        TweenService:Create(SpeedDecrease, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.accent_primary
        }):Play()
        TweenService:Create(SpeedDecrease, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.bg_secondary
        }):Play()
    end
end)

SpeedIncrease.MouseButton1Click:Connect(function()
    if orbConfig.rotationSpeed < 5.0 then
        orbConfig.rotationSpeed = math.min(5.0, orbConfig.rotationSpeed + 0.2)
        SpeedLabel.Text = "Speed: " .. string.format("%.1f", orbConfig.rotationSpeed)
        playSound("12221967", 0.3)

        -- Visual feedback
        TweenService:Create(SpeedIncrease, TweenInfo.new(0.1), {
            BackgroundColor3 = THEME.accent_primary
        }):Play()
        TweenService:Create(SpeedIncrease, TweenInfo.new(0.2), {
            BackgroundColor3 = THEME.bg_secondary
        }):Play()
    end
end)

-- Make GUI draggable
local dragging = false
local dragStart = nil
local startPos = nil

HeaderFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and startPos then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Update parts counter
spawn(function()
    while ScreenGui.Parent do
        PartsCount.Text = "Parts: " .. #parts
        wait(1)
    end
end)

-- Ring Parts Logic (Backend preserved)
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }
    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

local height = 100
local rotationSpeed = 10
local attractionStrength = 1000

local function RetainPart(Part)
    if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
        if Part.Parent == LocalPlayer.Character or Part:IsDescendantOf(LocalPlayer.Character) then
            return false
        end

        Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        Part.CanCollide = false
        return true
    end
    return false
end

local function addPart(part)
    if RetainPart(part) then
        if not table.find(parts, part) then
            table.insert(parts, part)
        end
    end
end

local function removePart(part)
    local index = table.find(parts, part)
    if index then
        table.remove(parts, index)
    end
end

for _, part in pairs(workspace:GetDescendants()) do
    addPart(part)
end

workspace.DescendantAdded:Connect(addPart)
workspace.DescendantRemoving:Connect(removePart)

-- Ring pattern calculation (enhanced for smoother movement)
local function calculateRingPosition(part, tornadoCenter, partIndex, totalParts)
    local time = tick()
    local pos = part.Position
    local distance = (Vector3.new(pos.X, tornadoCenter.Y, pos.Z) - tornadoCenter).Magnitude

    -- Enhanced angle calculation with time-based rotation
    local baseAngle = math.atan2(pos.Z - tornadoCenter.Z, pos.X - tornadoCenter.X)
    local rotationOffset = math.rad(rotationSpeed) + (time * 0.5)
    local newAngle = baseAngle + rotationOffset

    -- Perfect circle formation
    local targetRadius = math.min(radius, math.max(distance, radius * 0.5))

    -- Smooth height variation for more natural look
    local heightOffset = height * 0.6 * math.sin((time + partIndex * 0.1) * 0.8)

    return Vector3.new(
        tornadoCenter.X + math.cos(newAngle) * targetRadius,
        tornadoCenter.Y + heightOffset,
        tornadoCenter.Z + math.sin(newAngle) * targetRadius
    )
end

-- Orb pattern calculation (perfected multi-layer orbital system)
local function calculateOrbPosition(part, tornadoCenter, partIndex, totalParts)
    local time = tick() * orbConfig.rotationSpeed

    -- Perfect distribution: each layer gets equal parts, remainder distributed to inner layers
    local partsPerLayer = math.floor(totalParts / orbConfig.layers)
    local extraParts = totalParts % orbConfig.layers

    -- Determine which layer this part belongs to and its position within that layer
    local layerIndex = 0
    local partInLayer = 0
    local currentPartCount = partIndex - 1

    for layer = 0, orbConfig.layers - 1 do
        local partsInThisLayer = partsPerLayer + (layer < extraParts and 1 or 0)

        if currentPartCount < partsInThisLayer then
            layerIndex = layer
            partInLayer = currentPartCount
            break
        else
            currentPartCount = currentPartCount - partsInThisLayer
        end
    end

    -- Calculate actual parts in this specific layer
    local actualPartsInLayer = partsPerLayer + (layerIndex < extraParts and 1 or 0)

    -- Perfect angular distribution within the layer
    local angleStep = (2 * math.pi) / actualPartsInLayer
    local baseAngle = partInLayer * angleStep

    -- Each layer rotates at different speeds for visual appeal
    local layerSpeedMultiplier = 1 + (layerIndex * 0.2) -- Inner layers slightly faster
    local rotationOffset = time * layerSpeedMultiplier

    -- Phase offset between layers for aesthetic distribution
    local layerPhaseOffset = layerIndex * (math.pi / orbConfig.layers)

    -- Final angle calculation
    local finalAngle = baseAngle + rotationOffset + layerPhaseOffset

    -- Calculate orbital radius (inner layers closer, outer layers further)
    local baseRadius = radius * 0.7 -- Start closer to player
    local orbitalRadius = baseRadius + (layerIndex * orbConfig.layerSpacing)

    -- Height calculation for 3D orbital effect
    -- Create different orbital planes tilted at different angles
    local orbitalTilt = math.sin(layerIndex * 0.5) * 0.3 -- Each layer tilted differently
    local heightVariation = math.sin(finalAngle + time * 0.3) * orbConfig.orbHeight * (0.5 + layerIndex * 0.3)

    -- Perfect orbital positioning
    local x = tornadoCenter.X + math.cos(finalAngle) * orbitalRadius
    local y = tornadoCenter.Y + heightVariation + (orbitalTilt * orbitalRadius * 0.2)
    local z = tornadoCenter.Z + math.sin(finalAngle) * orbitalRadius * math.cos(orbitalTilt)

    return Vector3.new(x, y, z)
end

RunService.Heartbeat:Connect(function()
    if not ringPartsEnabled then return end

    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local tornadoCenter = humanoidRootPart.Position
        local totalParts = #parts

        for i, part in pairs(parts) do
            if part.Parent and not part.Anchored then
                local targetPos

                -- Calculate target position based on current effect type
                if currentEffectType == EFFECT_TYPES.RING then
                    targetPos = calculateRingPosition(part, tornadoCenter, i, totalParts)
                else -- ORB effect
                    targetPos = calculateOrbPosition(part, tornadoCenter, i, totalParts)
                end

                local directionToTarget = (targetPos - part.Position).unit
                part.Velocity = directionToTarget * attractionStrength
            end
        end
    end
end)

-- Modern Notifications
StarterGui:SetCore("SendNotification", {
    Title = "ARAKEN • Ring System",
    Text = "System initialized successfully!",
    Duration = 4,
    Button1 = "Cool!"
})

wait(1)

StarterGui:SetCore("SendNotification", {
    Title = "Created by ErrorNoName",
    Text = "Advanced Ring Control System loaded",
    Duration = 4
})
