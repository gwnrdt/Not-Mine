if getgenv().performance_stats then
   return 
end

local CoreGui
local Players
local RunService
local Stats
local UserInputService = game:GetService("UserInputService")

if cloneref then
   Players = cloneref(game:GetService("Players"))
   RunService = cloneref(game:GetService("RunService"))
   Stats = cloneref(game:GetService("Stats"))
else
   Players = game:GetService("Players")
   RunService = game:GetService("RunService")
   Stats = game:GetService("Stats")
end

task.wait(0.1)
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TopBarUI"
if get_hidden_gui or gethui then
    local hiddenUI = get_hidden_gui or gethui
    ScreenGui.Parent = hiddenUI()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 150, 0, 30)
ToggleButton.Position = UDim2.new(1, -160, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.BorderSizePixel = 0
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Hide UI"

local UIContainer = Instance.new("Frame")
UIContainer.Name = "UIContainer"
UIContainer.Parent = ScreenGui
UIContainer.Size = UDim2.new(0, 1105, 0, 40)
UIContainer.Position = UDim2.new(0.5, -550, 0, 0)
UIContainer.BackgroundColor3 = Color3.fromRGB(85, 0, 0)
UIContainer.BackgroundTransparency = 0.2
UIContainer.BorderSizePixel = 0
UIContainer.Visible = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = UIContainer

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(50, 50, 50)
UIStroke.Thickness = 1
UIStroke.Parent = UIContainer

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Parent = UIContainer
TimeLabel.Size = UDim2.new(0, 150, 1, 0)
TimeLabel.Position = UDim2.new(0, 0, 0, 0)
TimeLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.TextScaled = true
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.Text = "Loading..."

local PingLabel = Instance.new("TextLabel")
PingLabel.Name = "PingLabel"
PingLabel.Parent = UIContainer
PingLabel.Size = UDim2.new(0, 150, 1, 0)
PingLabel.Position = UDim2.new(0, 160, 0, 0)
PingLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PingLabel.TextScaled = true
PingLabel.Font = Enum.Font.SourceSansBold
PingLabel.Text = "Detecting Ping..."

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Name = "FPSLabel"
FPSLabel.Parent = UIContainer
FPSLabel.Size = UDim2.new(0, 150, 1, 0)
FPSLabel.Position = UDim2.new(0, 320, 0, 0)
FPSLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextScaled = true
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.Text = "Detecting FPS..."

local ExecutorLabel = Instance.new("TextLabel")
ExecutorLabel.Name = "ExecutorLabel"
ExecutorLabel.Parent = UIContainer
ExecutorLabel.Size = UDim2.new(0, 200, 1, 0)
ExecutorLabel.Position = UDim2.new(0, 480, 0, 0)
ExecutorLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ExecutorLabel.BackgroundTransparency = 1
ExecutorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecutorLabel.TextScaled = true
ExecutorLabel.Font = Enum.Font.SourceSansBold
ExecutorLabel.Text = "Detecting Executor..."

local PCStatusLabel = Instance.new("TextLabel")
PCStatusLabel.Name = "PCStatusLabel"
PCStatusLabel.Parent = UIContainer
PCStatusLabel.Size = UDim2.new(0, 190, 1, 0)
PCStatusLabel.Position = UDim2.new(0, 700, 0, 0)
PCStatusLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
PCStatusLabel.BackgroundTransparency = 1
PCStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PCStatusLabel.TextScaled = true
PCStatusLabel.Font = Enum.Font.SourceSansBold
PCStatusLabel.Text = "Detecting Device..."

getgenv().Player_Counting_Value = true

local PlayerCountLabel = Instance.new("TextLabel")
PlayerCountLabel.Name = "PlayerCountLabel"
PlayerCountLabel.Parent = UIContainer
PlayerCountLabel.Size = UDim2.new(0, 200, 1, 0)
PlayerCountLabel.Position = UDim2.new(0, 900, 0, 0)
PlayerCountLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
PlayerCountLabel.BackgroundTransparency = 1
PlayerCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerCountLabel.TextScaled = true
PlayerCountLabel.Font = Enum.Font.SourceSansBold
PlayerCountLabel.Text = "Players: Detecting..."

task.spawn(function()
   while getgenv().Player_Counting_Value == true do
      local player_count = #Players:GetPlayers()
      local max_players = Players.MaxPlayersInternal
      PlayerCountLabel.Text = "Players: " .. tostring(player_count) .. "/" .. tostring(max_players)
      task.wait(0.3)
   end
end)

local function getExecutor()
    local name, version
    if identifyexecutor then
        name, version = identifyexecutor()
    end
    return { Name = name or "Unknown Executor", Version = version or "Unknown Version" }
end

local function Device_Detector()
    local UserInputService = game:GetService("UserInputService")

    if UserInputService:GetPlatform() == Enum.Platform.Windows then
        return "Windows"
    elseif UserInputService:GetPlatform() == Enum.Platform.OSX then
        return "OSX" or "Apple Desktop"
    elseif UserInputService:GetPlatform() == Enum.Platform.IOS then
        return "iOS"
    elseif UserInputService:GetPlatform() == Enum.Platform.Android then
        return "Android"
    elseif UserInputService:GetPlatform() == Enum.Platform.XBoxOne then
        return "Xbox One (Console)"
    elseif UserInputService:GetPlatform() == Enum.Platform.PS4 then
        return "PS4 (Console)"
    elseif UserInputService:GetPlatform() == Enum.Platform.XBox360 then
        return "Xbox 360 (Console)"
    elseif UserInputService:GetPlatform() == Enum.Platform.WiiU then
        return "Wii-U (Console)"
    elseif UserInputService:GetPlatform() == Enum.Platform.NX then
        return "Cisco Nexus"
    elseif UserInputService:GetPlatform() == Enum.Platform.Ouya then
        return "Ouya (Android-Based)"
    elseif UserInputService:GetPlatform() == Enum.Platform.AndroidTV then
        return "Android TV"
    elseif UserInputService:GetPlatform() == Enum.Platform.Chromecast then
        return "Chromecast"
    elseif UserInputService:GetPlatform() == Enum.Platform.Linux then
        return "Linux (Desktop)"
    elseif UserInputService:GetPlatform() == Enum.Platform.SteamOS then
        return "Steam Client"
    elseif UserInputService:GetPlatform() == Enum.Platform.WebOS then
        return "Web-OS"
    elseif UserInputService:GetPlatform() == Enum.Platform.DOS then
        return "DOS"
    elseif UserInputService:GetPlatform() == Enum.Platform.BeOS then
        return "BeOS"
    elseif UserInputService:GetPlatform() == Enum.Platform.UWP then
        return "UWP (Go Back To Web Bro..)"
    elseif UserInputService:GetPlatform() == Enum.Platform.PS5 then
        return "PS5 (Console)"
    elseif UserInputService:GetPlatform() == Enum.Platform.MetaOS then
        return "MetaOS"
    elseif UserInputService:GetPlatform() == Enum.Platform.None then
        return "Unknown Device"
    end
end

local function detectExecutor()
    local executorDetails = getExecutor()
    return string.format("%s (v%s)", executorDetails.Name, executorDetails.Version)
end

task.spawn(function()
    local executorName = detectExecutor()
    ExecutorLabel.Text = "Executor: " .. executorName
end)

task.spawn(function()
    PCStatusLabel.Text = "Device: " .. Device_Detector()
end)

local isUIVisible = true

ToggleButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    UIContainer.Visible = isUIVisible
    ToggleButton.Text = isUIVisible and "Hide UI" or "Show UI"
end)

getgenv().performance_stats = true

local timeZones = {
    ["-1200"] = "AoE", ["-1100"] = "SST", ["-1000"] = "HST", ["-0930"] = "MART",
    ["-0900"] = "AKST", ["-0800"] = "PST", ["-0700"] = "MST", ["-0600"] = "CST",
    ["-0500"] = "EST", ["-0400"] = "AST", ["-0330"] = "NST", ["-0300"] = "BRT",
    ["-0200"] = "GST", ["-0100"] = "AZOST", ["+0000"] = "UTC", ["+0100"] = "CET",
    ["+0200"] = "EET", ["+0300"] = "MSK", ["+0330"] = "IRST", ["+0400"] = "GST",
    ["+0430"] = "AFT", ["+0500"] = "PKT", ["+0530"] = "IST", ["+0545"] = "NPT",
    ["+0600"] = "BST", ["+0630"] = "MMT", ["+0700"] = "ICT", ["+0800"] = "CST",
    ["+0845"] = "ACWST", ["+0900"] = "JST", ["+0930"] = "ACST", ["+1000"] = "AEST",
    ["+1030"] = "LHST", ["+1100"] = "SBT", ["+1200"] = "NZST", ["+1245"] = "CHAST",
    ["+1300"] = "PHOT", ["+1400"] = "LINT"
}

local function updateTime()
    getgenv().tickingTime = true
    while getgenv().tickingTime == true do
        local currentTime = os.time()
        local offset = os.date("%z", currentTime)
        local regionTimeZone = timeZones[offset] or "Unknown Time Zone"
        local formattedTime = os.date("%I:%M:%S %p", currentTime):gsub("^0", "")
        TimeLabel.Text = string.format("%s (%s)", formattedTime, regionTimeZone)
        task.wait(1.2)
    end
end

task.spawn(updateTime)

local frameCount = 0
local timeElapsed = 0

RunService.Heartbeat:Connect(function(deltaTime)
    frameCount = frameCount + 1
    timeElapsed = timeElapsed + deltaTime
    if timeElapsed >= 1 then
        FPSLabel.Text = frameCount .. " FPS"
        frameCount = 0
        timeElapsed = 0
    end
end)

task.wait()

local function updatePing()
    getgenv().preserve_ping_tick = true
    while getgenv().preserve_ping_tick == true do
        local ping = math.floor(Stats.PerformanceStats.Ping:GetValue())
        PingLabel.Text = ping .. " ms"
        task.wait(0.7)
    end
end

task.spawn(updatePing)
