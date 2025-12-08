local SpecialPlayers = {
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true
}

local player = game.Players.LocalPlayer

if SpecialPlayers[player.Name] then
    ScreenGui:Destroy()
    return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiscordAdUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.Size = UDim2.new(0, 600, 0, 400)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.Draggable = true
Frame.Active = true


local UICorner = Instance.new("UICorner")
UICorner.Parent = Frame
UICorner.CornerRadius = UDim.new(0, 9)

local Label1 = Instance.new("TextLabel")
Label1.Parent = Frame
Label1.BackgroundTransparency = 1
Label1.Position = UDim2.new(0.2, 0, 0.05, 0)
Label1.Size = UDim2.new(0, 400, 0, 50)
Label1.Text = "Join our new server Discord for more uptades!"
Label1.TextColor3 = Color3.new(1, 1, 1)
Label1.TextScaled = true
Label1.Font = Enum.Font.SourceSans

local Label5 = Instance.new("TextLabel")
Label5.Parent = Frame
Label5.BackgroundTransparency = 1
Label5.Position = UDim2.new(0.17, 0, 0.58, 0)
Label5.Size = UDim2.new(0, 400, 0, 50)
Label5.Text = "Wanna stop this ad? just join the server"
Label5.TextColor3 = Color3.new(1, 1, 1)
Label5.TextScaled = true
Label5.Font = Enum.Font.SourceSans

local Label2 = Instance.new("TextLabel")
Label2.Parent = Frame
Label2.BackgroundTransparency = 1
Label2.Position = UDim2.new(0.05, 0, 0.03, 0)
Label2.Size = UDim2.new(0, 50, 0, 50)
Label2.Text = "AD"
Label2.TextColor3 = Color3.new(1, 1, 1)
Label2.TextScaled = true
Label2.Font = Enum.Font.SourceSans

local SecondsLabel = Instance.new("TextLabel")
SecondsLabel.Parent = Frame
SecondsLabel.BackgroundTransparency = 1
SecondsLabel.Position = UDim2.new(0.4, 0, 0.2, 0)
SecondsLabel.Size = UDim2.new(0, 100, 0, 50)
SecondsLabel.Text = "15"
SecondsLabel.TextColor3 = Color3.new(1, 1, 1)
SecondsLabel.TextScaled = true
SecondsLabel.Font = Enum.Font.SourceSans

local Button = Instance.new("TextButton")
Button.Parent = Frame
Button.Position = UDim2.new(0.32, 0, 0.8, 0)
Button.Size = UDim2.new(0, 200, 0, 50)
Button.Text = "Click To Copy Link"
Button.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Button.TextScaled = true
Button.Font = Enum.Font.SourceSans
Button.TextColor3 = Color3.new(1, 1, 1)

local UICorner2 = Instance.new("UICorner")
UICorner2.Parent = Button
UICorner2.CornerRadius = UDim.new(0, 6)

Button.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/hrMtDwFvEG")
    Button.Text = "Link copied"
end)

ScreenGui.Parent = game.CoreGui

spawn(function()
    for i = 15, 0, -1 do
        SecondsLabel.Text = tostring(i)
        wait(1)
    end
    ScreenGui:Destroy()
end)


local player = game.Players.LocalPlayer
if player and (player.Name == "nadermohamedtest" or player.Name == "nadermohamed6") then
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = Frame
    CloseButton.Position = UDim2.new(0.4, 0, 0.40, 0)
    CloseButton.Size = UDim2.new(0, 100, 0, 40)
    CloseButton.Text = "Close"
    CloseButton.BackgroundColor3 = Color3.new(1, 0, 0)
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.TextColor3 = Color3.new(1, 1, 1)

    local UICorner3 = Instance.new("UICorner")
    UICorner3.Parent = CloseButton
    UICorner3.CornerRadius = UDim.new(0, 6)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end
