local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

local Library = {}
Library.__index = Library

-- Расширенная цветовая палитра
local colors = {
    background = Color3.fromRGB(20, 20, 30),
    surface = Color3.fromRGB(30, 30, 45),
    primary = Color3.fromRGB(100, 70, 200),
    secondary = Color3.fromRGB(70, 130, 230),
    accent = Color3.fromRGB(0, 200, 220),
    text = Color3.fromRGB(240, 240, 250),
    textSecondary = Color3.fromRGB(180, 180, 200),
    success = Color3.fromRGB(90, 200, 120),
    warning = Color3.fromRGB(230, 170, 50),
    error = Color3.fromRGB(220, 80, 80),
    dark = Color3.fromRGB(15, 15, 25),
    light = Color3.fromRGB(50, 50, 70)
}

-- Современные шрифты
local FONT_REGULAR = Enum.Font.ArimoBold
local FONT_BOLD = Enum.Font.ArimoBold
local FONT_ICONS = Enum.Font.ArimoBold

-- Улучшенная функция для создания плавных анимаций
local function createTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.4,
        easingStyle or Enum.EasingStyle.Quint,
        easingDirection or Enum.EasingDirection.Out,
        0, -- RepeatCount
        false, -- Reverses
        0 -- DelayTime
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Функция для создания плавного эффекта пружины (spring)
local function springTween(object, properties, frequency, damping)
    frequency = frequency or 4
    damping = damping or 0.8
    
    local startValues = {}
    local targetValues = {}
    
    for property, value in pairs(properties) do
        startValues[property] = object[property]
        targetValues[property] = value
    end
    
    local velocity = {}
    for property, _ in pairs(properties) do
        velocity[property] = 0
    end
    
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        local stillMoving = false
        
        for property, targetValue in pairs(targetValues) do
            local currentValue = object[property]
            local currentVelocity = velocity[property]
            
            if typeof(currentValue) == "number" then
                local displacement = targetValue - currentValue
                local acceleration = (displacement * frequency * frequency) - (2 * frequency * damping * currentVelocity)
                
                velocity[property] = currentVelocity + acceleration * delta
                local newValue = currentValue + velocity[property] * delta
                
                if math.abs(displacement) < 0.001 and math.abs(currentVelocity) < 0.001 then
                    object[property] = targetValue
                else
                    object[property] = newValue
                    stillMoving = true
                end
            elseif typeof(currentValue) == "Color3" then
                local rDisplacement = targetValue.R - currentValue.R
                local gDisplacement = targetValue.G - currentValue.G
                local bDisplacement = targetValue.B - currentValue.B
                
                local rAcceleration = (rDisplacement * frequency * frequency) - (2 * frequency * damping * (velocity[property] or 0))
                local gAcceleration = (gDisplacement * frequency * frequency) - (2 * frequency * damping * (velocity[property] or 0))
                local bAcceleration = (bDisplacement * frequency * frequency) - (2 * frequency * damping * (velocity[property] or 0))
                
                velocity[property] = (velocity[property] or 0) + ((rAcceleration + gAcceleration + bAcceleration) / 3) * delta
                
                local newR = currentValue.R + velocity[property] * delta
                local newG = currentValue.G + velocity[property] * delta
                local newB = currentValue.B + velocity[property] * delta
                
                if math.abs(rDisplacement) < 0.001 and math.abs(gDisplacement) < 0.001 and math.abs(bDisplacement) < 0.001 and math.abs(velocity[property]) < 0.001 then
                    object[property] = targetValue
                else
                    object[property] = Color3.new(newR, newG, newB)
                    stillMoving = true
                end
            end
        end
        
        if not stillMoving then
            connection:Disconnect()
        end
    end)
    
    return connection
end

-- Функции для преобразования цветов
local function HSVToRGB(h, s, v)
    h = h % 1
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    if i == 0 then
        return Color3.new(v, t, p)
    elseif i == 1 then
        return Color3.new(q, v, p)
    elseif i == 2 then
        return Color3.new(p, v, t)
    elseif i == 3 then
        return Color3.new(p, q, v)
    elseif i == 4 then
        return Color3.new(t, p, v)
    else
        return Color3.new(v, p, q)
    end
end

local function RGBToHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v
    v = max
    
    local d = max - min
    if max == 0 then
        s = 0
    else
        s = d / max
    end
    
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then
                h = h + 6
            end
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
    
    return h, s, v
end

-- Основная функция создания окна
function Library:CreateWindow(title, config)
    config = config or {}
    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CustomLib_" .. HttpService:GenerateGUID(false):sub(1, 8)
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = colors.background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    mainFrame.Size = UDim2.new(0, 600, 0, 35)
    mainFrame.ZIndex = 2
    
    -- Функция для адаптации размера окна
    local function updateMainFrameSize()
        local screenSize = screenGui.AbsoluteSize
        local width = math.clamp(screenSize.X * 0.7, 300, 700)
        local height = math.clamp(screenSize.Y * 0.75, 200, 550)
        mainFrame.Size = UDim2.new(0, width, 0, height)
    end
    
    updateMainFrameSize()
    screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateMainFrameSize)
    
    -- Анимация появления
    mainFrame.Size = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundTransparency = 1
    
    local spawnTween = createTween(mainFrame, {
        Size = UDim2.new(0, 600, 0, 430),
        BackgroundTransparency = 0
    }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Создаем скругленные углы
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    -- Обводка с анимацией
    local uiStroke = Instance.new("UIStroke")
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Color = colors.primary
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.7
    uiStroke.Parent = mainFrame
    
    -- Панель заголовка
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = colors.surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    titleBar.ZIndex = 3
    
    -- Текст заголовка
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = colors.text
    titleText.TextSize = 16
    titleText.Font = FONT_BOLD
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    titleText.ZIndex = 4
    
    -- Кнопка сворачивания
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 35, 1, 0)
    minimizeButton.Position = UDim2.new(1, -70, 0, 0)
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "─"
    minimizeButton.TextColor3 = colors.textSecondary
    minimizeButton.TextSize = 18
    minimizeButton.Font = FONT_REGULAR
    minimizeButton.Parent = titleBar
    minimizeButton.ZIndex = 4
    
    -- Кнопка закрытия
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 35, 1, 0)
    closeButton.Position = UDim2.new(1, -35, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = colors.textSecondary
    closeButton.TextSize = 20
    closeButton.Font = FONT_REGULAR
    closeButton.Parent = titleBar
    closeButton.ZIndex = 4
    
    -- Фрейм для кнопок вкладок
    local tabButtonsFrame = Instance.new("ScrollingFrame")
    tabButtonsFrame.Name = "TabButtons"
    tabButtonsFrame.Size = UDim2.new(0, 160, 1, -35)
    tabButtonsFrame.Position = UDim2.new(0, 0, 0, 35)
    tabButtonsFrame.BackgroundColor3 = colors.surface
    tabButtonsFrame.BorderSizePixel = 0
    tabButtonsFrame.ScrollBarThickness = 4
    tabButtonsFrame.ScrollBarImageColor3 = colors.textSecondary
    tabButtonsFrame.ScrollBarImageTransparency = 0.7
    tabButtonsFrame.Parent = mainFrame
    tabButtonsFrame.ZIndex = 2
    
    -- Контентная область
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -160, 1, -35)
    contentFrame.Position = UDim2.new(0, 160, 0, 35)
    contentFrame.BackgroundColor3 = colors.background
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    contentFrame.ZIndex = 2
    
    -- Обработчик закрытия окна
    closeButton.MouseButton1Click:Connect(function()
        createTween(mainFrame, {
            Size = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        createTween(backdrop, {BackgroundTransparency = 1}, 0.5)
        
        wait(0.5)
        screenGui:Destroy()
    end)
    
    -- Layout для кнопок вкладок
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.Name = "TabsListLayout"
    tabsListLayout.Padding = UDim.new(0, 8)
    tabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsListLayout.Parent = tabButtonsFrame
    
    tabsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabButtonsFrame.CanvasSize = UDim2.new(0, 0, 0, tabsListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local tabs = {}
    local currentTab = nil
    local isMinimized = false
    
    -- Обработчик сворачивания/разворачивания
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        
        if isMinimized then
            createTween(mainFrame, {Size = UDim2.new(0, 600, 0, 35)}, 0.4, Enum.EasingStyle.Quart)
            minimizeButton.Text = "+"
            tabButtonsFrame.Visible = false
            contentFrame.Visible = false
        else
            createTween(mainFrame, {Size = UDim2.new(0, 600, 0, 430)}, 0.4, Enum.EasingStyle.Quart)
            minimizeButton.Text = "─"
            tabButtonsFrame.Visible = true
            contentFrame.Visible = true
        end
    end)
    
    -- Адаптация для мобильных устройств
    local function adaptForDevice()
        if UserInputService.TouchEnabled then
            mainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
            mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            titleText.TextSize = 18
            minimizeButton.TextSize = 22
            closeButton.TextSize = 24
            minimizeButton.Size = UDim2.new(0, 50, 1, 0)
            closeButton.Size = UDim2.new(0, 50, 1, 0)
            closeButton.Position = UDim2.new(1, -50, 0, 0)
            minimizeButton.Position = UDim2.new(1, -100, 0, 0)
        else
            updateMainFrameSize()
            titleText.TextSize = 14
            minimizeButton.TextSize = 16
            closeButton.TextSize = 18
            minimizeButton.Size = UDim2.new(0, 30, 1, 0)
            closeButton.Size = UDim2.new(0, 30, 1, 0)
            closeButton.Position = UDim2.new(1, -30, 0, 0)
            minimizeButton.Position = UDim2.new(1, -60, 0, 0)
        end
    end
    
    adaptForDevice()
    UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(adaptForDevice)
    
    -- Перетаскивание окна
    local dragging = false
    local dragInput, dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Создаем объект окна
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        TabButtonsFrame = tabButtonsFrame,
        ContentFrame = contentFrame,
        Tabs = tabs,
        IsMinimized = isMinimized,
        Backdrop = backdrop
    }
    
    setmetatable(window, Library)
    
    -- Функция для применения темы
    function window:SetTheme(themeColors)
        colors = themeColors or colors
        
        -- Применяем новые цвета ко всем элементам
        mainFrame.BackgroundColor3 = colors.background
        titleBar.BackgroundColor3 = colors.surface
        tabButtonsFrame.BackgroundColor3 = colors.surface
        contentFrame.BackgroundColor3 = colors.background
        uiStroke.Color = colors.primary
        
        -- Обновляем все вкладки и элементы
        for _, tab in ipairs(self.Tabs) do
            tab.Button.BackgroundColor3 = colors.surface
            tab.Highlight.BackgroundColor3 = colors.primary
            
            for _, element in ipairs(tab.Elements) do
                if element:IsA("TextButton") and element.Name:find("Button") then
                    element.BackgroundColor3 = colors.surface
                elseif element:IsA("Frame") then
                    local children = element:GetChildren()
                    for _, child in ipairs(children) do
                        if child:IsA("TextButton") and child.Name:find("Toggle") then
                            child.BackgroundColor3 = colors.surface
                        elseif child:IsA("Frame") and child.Name:find("Track") then
                            child.BackgroundColor3 = colors.surface
                        elseif child:IsA("Frame") and child.Name:find("Fill") then
                            child.BackgroundColor3 = colors.primary
                        end
                    end
                end
            end
        end
    end
    
    -- Функция для показа/скрытия окна
    function window:SetVisible(visible)
        if visible then
            self.ScreenGui.Enabled = true
            createTween(self.MainFrame, {
                Size = UDim2.new(0, 600, 0, 430),
                BackgroundTransparency = 0
            }, 0.4)
            createTween(self.Backdrop, {BackgroundTransparency = 0.7}, 0.4)
        else
            createTween(self.MainFrame, {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, 0.4)
            createTween(self.Backdrop, {BackgroundTransparency = 1}, 0.4)
            wait(0.4)
            self.ScreenGui.Enabled = false
        end
    end
    
    return window
end

function Library:AddSection(tab, name, icon, config)
    config = config or {}
    local textColor = config.color or colors.text
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = name .. "Section"
    sectionFrame.Size = UDim2.new(1, -20, 0, 40)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = tab.Content
    sectionFrame.LayoutOrder = #tab.Elements + 1
    sectionFrame.Visible = true
    sectionFrame.ZIndex = 3

    -- Контейнер для иконки и текста
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = sectionFrame
    contentFrame.ZIndex = 4

    -- Иконка секции (эмодзи)
    local iconLabel
    if icon then
        iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Size = UDim2.new(0, 30, 0, 30)
        iconLabel.Position = UDim2.new(0, 0, 0.5, -15)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Text = icon
        iconLabel.TextColor3 = colors.primary
        iconLabel.TextSize = 20
        iconLabel.Font = FONT_REGULAR
        iconLabel.TextXAlignment = Enum.TextXAlignment.Center
        iconLabel.TextYAlignment = Enum.TextYAlignment.Center
        iconLabel.Parent = contentFrame
        iconLabel.ZIndex = 5
    end

    -- Текст секции
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.Size = UDim2.new(1, icon and -35 or 0, 1, 0)
    textLabel.Position = UDim2.new(0, icon and 35 or 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextColor3 = textColor
    textLabel.TextSize = 16
    textLabel.Font = FONT_BOLD
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.Parent = contentFrame
    textLabel.ZIndex = 5

    -- Разделительная линия
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = colors.primary
    divider.BackgroundTransparency = 0.7
    divider.BorderSizePixel = 0
    divider.Parent = sectionFrame
    divider.ZIndex = 4

    -- Анимация появления
    sectionFrame.BackgroundTransparency = 1
    textLabel.TextTransparency = 1
    divider.BackgroundTransparency = 1
    
    if iconLabel then
        iconLabel.TextTransparency = 1
        createTween(iconLabel, {TextTransparency = 0}, 0.5)
    end
    
    createTween(textLabel, {TextTransparency = 0}, 0.5)
    createTween(divider, {BackgroundTransparency = 0.7}, 0.5)

    table.insert(tab.Elements, sectionFrame)
    return sectionFrame
end

function Library:AddTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabButton"
    tabButton.Size = UDim2.new(1, -20, 0, 45)
    tabButton.Position = UDim2.new(0, 10, 0, 10 + (#self.Tabs * 53))
    tabButton.BackgroundColor3 = colors.surface
    tabButton.BorderSizePixel = 0
    tabButton.Text = "  " .. icon .. "  " .. name
    tabButton.TextColor3 = colors.textSecondary
    tabButton.TextSize = 14
    tabButton.Font = FONT_REGULAR
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = self.TabButtonsFrame
    tabButton.LayoutOrder = #self.Tabs + 1
    tabButton.AutoButtonColor = false

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = tabButton

    local tabHighlight = Instance.new("Frame")
    tabHighlight.Name = "Highlight"
    tabHighlight.Size = UDim2.new(0, 4, 1, -10)
    tabHighlight.Position = UDim2.new(0, -4, 0, 5)
    tabHighlight.BackgroundColor3 = colors.primary
    tabHighlight.BorderSizePixel = 0
    tabHighlight.Visible = false
    tabHighlight.Parent = tabButton

    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 2)
    highlightCorner.Parent = tabHighlight

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundColor3 = colors.background
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 3
    tabContent.ScrollBarImageColor3 = colors.textSecondary
    tabContent.Visible = false
    tabContent.Parent = self.ContentFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.Parent = tabContent
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 10)

    local contentListLayout = Instance.new("UIListLayout")
    contentListLayout.Name = "ContentListLayout"
    contentListLayout.Padding = UDim.new(0, 15)
    contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentListLayout.Parent = tabContent

    contentListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentListLayout.AbsoluteContentSize.Y + 15)
    end)

    local tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        Elements = {},
        Highlight = tabHighlight
    }

    table.insert(self.Tabs, tab)

    tabButton.MouseEnter:Connect(function()
        if currentTab ~= tab then
            createTween(tabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.2)
            createTween(tabButton, {TextColor3 = colors.text}, 0.2)
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if currentTab ~= tab then
            createTween(tabButton, {BackgroundColor3 = colors.surface}, 0.2)
            createTween(tabButton, {TextColor3 = colors.textSecondary}, 0.2)
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)

    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    return tab
end

function Library:SwitchTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = false
        createTween(t.Button, {BackgroundColor3 = colors.surface}, 0.2)
        createTween(t.Button, {TextColor3 = colors.textSecondary}, 0.2)
        t.Highlight.Visible = false
    end

    tab.Content.Visible = true
    createTween(tab.Button, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.2)
    createTween(tab.Button, {TextColor3 = colors.text}, 0.2)
    tab.Highlight.Visible = true
    
    currentTab = tab
end

-- Улучшенная функция для добавления кнопки
function Library:AddButton(tab, name, callback, config)
    config = config or {}
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 45)
    button.BackgroundColor3 = colors.surface
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = colors.text
    button.TextSize = 14
    button.Font = FONT_REGULAR
    button.Parent = tab.Content
    button.LayoutOrder = #tab.Elements + 1
    button.AutoButtonColor = false
    button.Visible = true
    button.ZIndex = 3
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = button
    
    local buttonHighlight = Instance.new("Frame")
    buttonHighlight.Name = "Highlight"
    buttonHighlight.Size = UDim2.new(1, 0, 1, 0)
    buttonHighlight.Position = UDim2.new(0, 0, 0, 0)
    buttonHighlight.BackgroundColor3 = colors.primary
    buttonHighlight.BackgroundTransparency = 1
    buttonHighlight.BorderSizePixel = 0
    buttonHighlight.ZIndex = -1
    buttonHighlight.Parent = button
    
    local highlightCorner = Instance.new("UICorner")
    highlightCorner.CornerRadius = UDim.new(0, 8)
    highlightCorner.Parent = buttonHighlight
    
    -- Анимации кнопки
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
        createTween(buttonHighlight, {BackgroundTransparency = 0.9}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = colors.surface}, 0.2)
        createTween(buttonHighlight, {BackgroundTransparency = 1}, 0.2)
    end)
    
    button.MouseButton1Down:Connect(function()
        createTween(button, {Size = UDim2.new(1, -25, 0, 42)}, 0.1)
        createTween(button, {BackgroundColor3 = colors.primary}, 0.1)
    end)
    
    button.MouseButton1Up:Connect(function()
        createTween(button, {Size = UDim2.new(1, -20, 0, 45)}, 0.1)
        createTween(button, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.1)
    end)
    
    button.MouseButton1Click:Connect(function()
        createTween(buttonHighlight, {BackgroundTransparency = 0.7}, 0.1)
        wait(0.1)
        createTween(buttonHighlight, {BackgroundTransparency = 0.9}, 0.3)
        
        -- Эффект "пульсации" при клике
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.8
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 2
        ripple.Parent = button
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        createTween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }, 0.6):Wait()
        
        ripple:Destroy()
        callback()
    end)
    
    table.insert(tab.Elements, button)
    return button
end

-- Улучшенная функция для добавления переключателя
function Library:AddToggle(tab, name, callback, config)
    config = config or {}
    local defaultState = config.default or false
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, -20, 0, 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Content
    toggleFrame.LayoutOrder = #tab.Elements + 1
    toggleFrame.Visible = true
    toggleFrame.ZIndex = 3

    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "Text"
    toggleText.Size = UDim2.new(0.7, 0, 1, 0)
    toggleText.Position = UDim2.new(0, 0, 0, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = name
    toggleText.TextColor3 = colors.text
    toggleText.TextSize = 14
    toggleText.Font = FONT_REGULAR
    toggleText.TextXAlignment = Enum.TextXAlignment.Left
    toggleText.Parent = toggleFrame
    toggleText.ZIndex = 4

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0, 50, 0, 25)
    toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
    toggleButton.BackgroundColor3 = colors.surface
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    toggleButton.AutoButtonColor = false
    toggleButton.ZIndex = 4

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleButton

    local toggleDot = Instance.new("Frame")
    toggleDot.Name = "Dot"
    toggleDot.Size = UDim2.new(0, 21, 0, 21)
    toggleDot.Position = UDim2.new(0, 2, 0, 2)
    toggleDot.BackgroundColor3 = colors.text
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    toggleDot.ZIndex = 5

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 10)
    dotCorner.Parent = toggleDot

    local isToggled = defaultState

    -- Функция для плавного обновления переключателя
    local function updateToggle()
        if isToggled then
            createTween(toggleButton, {BackgroundColor3 = colors.primary}, 0.3, Enum.EasingStyle.Quad)
            createTween(toggleDot, {
                Position = UDim2.new(0, 27, 0, 2),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            createTween(toggleButton, {BackgroundColor3 = colors.surface}, 0.3, Enum.EasingStyle.Quad)
            createTween(toggleDot, {
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = colors.text
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        callback(isToggled)
    end

    -- Анимации при взаимодействии
    toggleButton.MouseEnter:Connect(function()
        createTween(toggleButton, {
            BackgroundColor3 = isToggled and Color3.fromRGB(110, 80, 210) or Color3.fromRGB(50, 50, 65)
        }, 0.2)
    end)

    toggleButton.MouseLeave:Connect(function()
        createTween(toggleButton, {
            BackgroundColor3 = isToggled and colors.primary or colors.surface
        }, 0.2)
    end)

    toggleButton.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        updateToggle()
        
        -- Эффект пульсации
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = isToggled and colors.primary or colors.textSecondary
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 6
        ripple.Parent = toggleButton
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        createTween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }, 0.4):Wait()
        ripple:Destroy()
    end)

    -- Установка начального состояния
    updateToggle()

    table.insert(tab.Elements, toggleFrame)
    return {
        Frame = toggleFrame,
        SetState = function(state)
            isToggled = state
            updateToggle()
        end,
        GetState = function()
            return isToggled
        end
    }
end

-- Улучшенная функция для добавления слайдера
function Library:AddSlider(tab, name, min, max, defaultValue, callback, config)
    config = config or {}
    local precision = config.precision or 0
    local suffix = config.suffix or ""
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Content
    sliderFrame.LayoutOrder = #tab.Elements + 1
    sliderFrame.Visible = true
    sliderFrame.ZIndex = 3

    local sliderText = Instance.new("TextLabel")
    sliderText.Name = "Text"
    sliderText.Size = UDim2.new(1, 0, 0, 20)
    sliderText.Position = UDim2.new(0, 0, 0, 0)
    sliderText.BackgroundTransparency = 1
    sliderText.Text = name .. ": " .. defaultValue .. suffix
    sliderText.TextColor3 = colors.text
    sliderText.TextSize = 14
    sliderText.Font = FONT_REGULAR
    sliderText.TextXAlignment = Enum.TextXAlignment.Left
    sliderText.Parent = sliderFrame
    sliderText.ZIndex = 4

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 35)
    sliderTrack.BackgroundColor3 = colors.surface
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    sliderTrack.ZIndex = 4

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 3)
    trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = colors.primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    sliderFill.ZIndex = 5

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill

    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Size = UDim2.new(0, 18, 0, 18)
    sliderButton.Position = UDim2.new((defaultValue - min) / (max - min), -9, 0.5, -9)
    sliderButton.BackgroundColor3 = colors.text
    sliderButton.BorderSizePixel = 0
    sliderButton.Text = ""
    sliderButton.Parent = sliderTrack
    sliderButton.AutoButtonColor = false
    sliderButton.ZIndex = 6

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 9)
    buttonCorner.Parent = sliderButton

    local isSliding = false
    local currentValue = defaultValue

    -- Функция для плавного обновления слайдера
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = precision > 0 and math.floor(value * 10^precision) / 10^precision or math.floor(value)
        
        sliderText.Text = name .. ": " .. currentValue .. suffix
        
        createTween(sliderFill, {
            Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        }, 0.1, Enum.EasingStyle.Quad)
        
        createTween(sliderButton, {
            Position = UDim2.new((currentValue - min) / (max - min), -9, 0.5, -9)
        }, 0.1, Enum.EasingStyle.Quad)
        
        callback(currentValue)
    end

    -- Анимации при взаимодействии
    sliderButton.MouseEnter:Connect(function()
        if not isSliding then
            createTween(sliderButton, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
            createTween(sliderButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        end
    end)

    sliderButton.MouseLeave:Connect(function()
        if not isSliding then
            createTween(sliderButton, {Size = UDim2.new(0, 18, 0, 18)}, 0.2)
            createTween(sliderButton, {BackgroundColor3 = colors.text}, 0.2)
        end
    end)

    -- Обработка ввода
    local function onInputChanged(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local inputPosition = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
            local trackPos = sliderTrack.AbsolutePosition
            local trackSize = sliderTrack.AbsoluteSize
            local relativeX = (inputPosition.X - trackPos.X) / trackSize.X
            local value = min + (max - min) * math.clamp(relativeX, 0, 1)
            updateSlider(value)
        end
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            createTween(sliderButton, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
            createTween(sliderFill, {BackgroundColor3 = Color3.fromRGB(120, 90, 220)}, 0.1)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isSliding then
                isSliding = false
                createTween(sliderButton, {Size = UDim2.new(0, 18, 0, 18)}, 0.2)
                createTween(sliderFill, {BackgroundColor3 = colors.primary}, 0.2)
            end
        end
    end)

    UserInputService.InputChanged:Connect(onInputChanged)

    table.insert(tab.Elements, sliderFrame)
    
    return {
        Frame = sliderFrame,
        SetValue = function(value)
            updateSlider(value)
        end,
        GetValue = function()
            return currentValue
        end
    }
end

-- Улучшенная функция для добавления текста
function Library:AddLabel(tab, text, icon, config)
    config = config or {}
    local textColor = config.color or colors.textSecondary
    
    local labelFrame = Instance.new("Frame")
    labelFrame.Name = "LabelFrame"
    labelFrame.Size = UDim2.new(1, -20, 0, 30)
    labelFrame.BackgroundTransparency = 1
    labelFrame.Parent = tab.Content
    labelFrame.LayoutOrder = #tab.Elements + 1
    labelFrame.Visible = true
    labelFrame.ZIndex = 3

    local labelText = Instance.new("TextLabel")
    labelText.Name = "LabelText"
    labelText.Size = UDim2.new(1, 0, 1, 0)
    labelText.Position = UDim2.new(0, 0, 0, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = icon and (" " .. icon .. "  " .. text) or text
    labelText.TextColor3 = textColor
    labelText.TextSize = 14
    labelText.Font = FONT_REGULAR
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = labelFrame
    labelText.ZIndex = 4

    -- Анимация появления
    labelText.TextTransparency = 1
    createTween(labelText, {TextTransparency = 0}, 0.5)

    table.insert(tab.Elements, labelFrame)
    return labelFrame
end

-- Улучшенная функция для добавления параграфа
function Library:AddParagraph(tab, text, icon, config)
    config = config or {}
    local textColor = config.color or colors.textSecondary
    
    local paragraphFrame = Instance.new("Frame")
    paragraphFrame.Name = "ParagraphFrame"
    paragraphFrame.BackgroundTransparency = 1
    paragraphFrame.LayoutOrder = #tab.Elements + 1
    paragraphFrame.Visible = true
    paragraphFrame.Size = UDim2.new(1, 0, 0, 0)
    paragraphFrame.Parent = tab.Content
    paragraphFrame.ZIndex = 3

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ParagraphText"
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = textColor
    textLabel.TextSize = 13
    textLabel.Font = FONT_REGULAR
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Text = icon and (icon .. "  " .. text) or text
    textLabel.Size = UDim2.new(1, 0, 0, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Parent = paragraphFrame
    textLabel.ZIndex = 4

    local padding = 20

    local function updateSize()
        if paragraphFrame.AbsoluteSize.X == 0 then return end
        
        -- Получаем максимальную доступную ширину с учетом отступов
        local maxWidth = paragraphFrame.AbsoluteSize.X - padding
        
        -- Рассчитываем размер текста с учетом переносов
        local textSize = TextService:GetTextSize(
            textLabel.Text, 
            textLabel.TextSize, 
            textLabel.Font, 
            Vector2.new(maxWidth, math.huge)
        )
        
        -- Устанавливаем размеры с учетом отступов
        textLabel.Size = UDim2.new(1, -padding, 0, textSize.Y)
        paragraphFrame.Size = UDim2.new(1, 0, 0, textSize.Y + 10) -- Добавляем небольшой отступ снизу
    end

    -- Обновляем размер при изменении размеров фрейма или текста
    paragraphFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    textLabel:GetPropertyChangedSignal("Text"):Connect(updateSize)
    
    -- Также обновляем при изменении размера родительского контейнера
    if tab.Content then
        tab.Content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    end
    
    -- Вызываем обновление размера после небольшой задержки
    task.defer(updateSize)

    -- Анимация появления
    textLabel.TextTransparency = 1
    createTween(textLabel, {TextTransparency = 0}, 0.5)

    table.insert(tab.Elements, paragraphFrame)
    return paragraphFrame
end

-- Улучшенная функция для добавления выпадающего списка
function Library:AddDropdown(tab, name, options, defaultOption, callback, config)
    config = config or {}
    local multiSelect = config.multiSelect or false
    local scrollable = config.scrollable or true
    
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = name .. "DropdownFrame"
    dropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.Parent = tab.Content
    dropdownFrame.LayoutOrder = #tab.Elements + 1
    dropdownFrame.Visible = true
    dropdownFrame.ZIndex = 3

    local dropdownText = Instance.new("TextLabel")
    dropdownText.Name = "Text"
    dropdownText.Size = UDim2.new(0.7, 0, 1, 0)
    dropdownText.Position = UDim2.new(0, 0, 0, 0)
    dropdownText.BackgroundTransparency = 1
    dropdownText.Text = name
    dropdownText.TextColor3 = colors.text
    dropdownText.TextSize = 14
    dropdownText.Font = FONT_REGULAR
    dropdownText.TextXAlignment = Enum.TextXAlignment.Left
    dropdownText.Parent = dropdownFrame
    dropdownText.ZIndex = 4

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Size = UDim2.new(0.3, 0, 1, 0)
    dropdownButton.Position = UDim2.new(0.7, 0, 0, 0)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    dropdownButton.BorderSizePixel = 0
    dropdownButton.Text = defaultOption or "Select..."
    dropdownButton.TextColor3 = colors.text
    dropdownButton.TextSize = 13
    dropdownButton.Font = FONT_REGULAR
    dropdownButton.Parent = dropdownFrame
    dropdownButton.AutoButtonColor = false
    dropdownButton.ZIndex = 4

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = dropdownButton

    local dropdownIcon = Instance.new("TextLabel")
    dropdownIcon.Name = "Icon"
    dropdownIcon.Size = UDim2.new(0, 20, 1, 0)
    dropdownIcon.Position = UDim2.new(1, -20, 0, 0)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Text = "▼"
    dropdownIcon.TextColor3 = colors.textSecondary
    dropdownIcon.TextSize = 12
    dropdownIcon.Font = FONT_REGULAR
    dropdownIcon.Parent = dropdownButton
    dropdownIcon.ZIndex = 5

    local screenGui = self.ScreenGui or game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("CustomLib")
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Name = "DropdownList"
    dropdownList.Size = UDim2.new(0, 0, 0, 0)
    dropdownList.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    dropdownList.BorderSizePixel = 0
    dropdownList.ScrollBarThickness = 6
    dropdownList.ScrollBarImageColor3 = colors.textSecondary
    dropdownList.Visible = false
    dropdownList.ZIndex = 100
    dropdownList.Parent = screenGui
    dropdownList.ClipsDescendants = true

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = dropdownList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = dropdownList
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = dropdownList

    local isOpen = false
    local selectedOptions = multiSelect and {}
    local selectedOption = not multiSelect and defaultOption
    local renderConnection

    -- Функция для обновления позиции выпадающего списка
    local function updateDropdownPosition()
        if not isOpen then return end
        
        local buttonAbsolutePos = dropdownButton.AbsolutePosition
        local buttonAbsoluteSize = dropdownButton.AbsoluteSize
        local screenSize = screenGui.AbsoluteSize
        
        -- Рассчитываем позицию с учетом границ экрана
        local listWidth = buttonAbsoluteSize.X
        local listHeight = math.min(dropdownList.AbsoluteSize.Y, 200)
        
        local positionX = buttonAbsolutePos.X
        local positionY = buttonAbsolutePos.Y + buttonAbsoluteSize.Y + 2
        
        -- Проверяем, не выходит ли список за границы экрана
        if positionX + listWidth > screenSize.X then
            positionX = screenSize.X - listWidth - 5
        end
        
        if positionY + listHeight > screenSize.Y then
            positionY = buttonAbsolutePos.Y - listHeight - 2
        end
        
        dropdownList.Position = UDim2.new(0, positionX, 0, positionY)
        dropdownList.Size = UDim2.new(0, listWidth, 0, listHeight)
    end

    -- Функция для обновления размера списка
    local function updateListSize()
        local contentHeight = listLayout.AbsoluteContentSize.Y + 10
        dropdownList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        updateDropdownPosition()
    end

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateListSize)

    -- Функция для создания опций
    local function createOptions()
        -- Очищаем старые опции
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, option in ipairs(options) do
            local optionButton = Instance.new("TextButton")
            optionButton.Name = option .. "Option"
            optionButton.Size = UDim2.new(1, -10, 0, 30)
            optionButton.BackgroundColor3 = colors.surface
            optionButton.BorderSizePixel = 0
            optionButton.Text = option
            optionButton.TextColor3 = colors.text
            optionButton.TextSize = 13
            optionButton.Font = FONT_REGULAR
            optionButton.ZIndex = 101
            optionButton.AutoButtonColor = false
            optionButton.Parent = dropdownList

            local optionCorner = Instance.new("UICorner")
            optionCorner.CornerRadius = UDim.new(0, 4)
            optionCorner.Parent = optionButton

            -- Анимации опций
            optionButton.MouseEnter:Connect(function()
                createTween(optionButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.2)
            end)

            optionButton.MouseLeave:Connect(function()
                createTween(optionButton, {BackgroundColor3 = colors.surface}, 0.2)
            end)

            optionButton.MouseButton1Click:Connect(function()
                if multiSelect then
                    if table.find(selectedOptions, option) then
                        table.remove(selectedOptions, table.find(selectedOptions, option))
                        createTween(optionButton, {BackgroundColor3 = colors.surface}, 0.2)
                    else
                        table.insert(selectedOptions, option)
                        createTween(optionButton, {BackgroundColor3 = colors.primary}, 0.2)
                    end
                    dropdownButton.Text = #selectedOptions > 0 and table.concat(selectedOptions, ", ") or "Select..."
                else
                    selectedOption = option
                    dropdownButton.Text = option
                    toggleDropdown()
                end
                callback(multiSelect and selectedOptions or selectedOption)
            end)

            -- Подсветка выбранных опций
            if (multiSelect and table.find(selectedOptions, option)) or (not multiSelect and option == selectedOption) then
                optionButton.BackgroundColor3 = colors.primary
            end
        end
        
        updateListSize()
    end

    -- Функция открытия/закрытия выпадающего списка
    local function toggleDropdown()
        isOpen = not isOpen
        
        if isOpen then
            createOptions()
            createTween(dropdownButton, {BackgroundColor3 = colors.primary}, 0.2)
            dropdownList.Visible = true
            dropdownIcon.Text = "▲"
            
            -- Анимация открытия
            dropdownList.Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, 0)
            createTween(dropdownList, {
                Size = UDim2.new(0, dropdownButton.AbsoluteSize.X, 0, math.min(dropdownList.CanvasSize.Y.Offset, 200))
            }, 0.3, Enum.EasingStyle.Quad)
            
            if not renderConnection then
                renderConnection = RunService.RenderStepped:Connect(updateDropdownPosition)
            end
        else
            createTween(dropdownButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
            createTween(dropdownList, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            wait(0.2)
            dropdownList.Visible = false
            dropdownIcon.Text = "▼"
            
            if renderConnection then
                renderConnection:Disconnect()
                renderConnection = nil
            end
        end
    end

    -- Обработчики событий
    dropdownButton.MouseButton1Click:Connect(toggleDropdown)

    -- Закрытие при клике вне области
    local function closeDropdown(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position
            local buttonPos = dropdownButton.AbsolutePosition
            local buttonSize = dropdownButton.AbsoluteSize
            local listPos = dropdownList.AbsolutePosition
            local listSize = dropdownList.AbsoluteSize
            
            local isClickInButton = mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                                  mousePos.Y >= buttonPos.Y and mousePos.Y <= buttonPos.Y + buttonSize.Y
                                  
            local isClickInList = mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X and
                                mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y
            
            if not isClickInButton and not isClickInList then
                toggleDropdown()
            end
        end
    end

    UserInputService.InputBegan:Connect(closeDropdown)

    -- Адаптация для мобильных устройств
    if UserInputService.TouchEnabled then
        dropdownButton.TextSize = 14
        dropdownIcon.TextSize = 14
        dropdownButton.Size = UDim2.new(0.4, 0, 1, 0)
        dropdownButton.Position = UDim2.new(0.6, 0, 0, 0)
        dropdownText.Size = UDim2.new(0.6, 0, 1, 0)
    end

    table.insert(tab.Elements, dropdownFrame)
    
    return {
        Frame = dropdownFrame,
        SetOptions = function(newOptions)
            options = newOptions
            createOptions()
        end,
        GetSelected = function()
            return multiSelect and selectedOptions or selectedOption
        end,
        SetSelected = function(selection)
            if multiSelect then
                selectedOptions = selection
                dropdownButton.Text = #selectedOptions > 0 and table.concat(selectedOptions, ", ") or "Select..."
            else
                selectedOption = selection
                dropdownButton.Text = selection or "Select..."
            end
        end
    }
end

-- Улучшенная функция для добавления цветового пикера
function Library:AddColorPicker(tab, name, defaultColor, callback, config)
    config = config or {}
    defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)
    
    local colorPickerFrame = Instance.new("Frame")
    colorPickerFrame.Name = name .. "ColorPicker"
    colorPickerFrame.Size = UDim2.new(1, -20, 0, 40)
    colorPickerFrame.BackgroundTransparency = 1
    colorPickerFrame.Parent = tab.Content
    colorPickerFrame.LayoutOrder = #tab.Elements + 1
    colorPickerFrame.Visible = true
    colorPickerFrame.ZIndex = 3

    local colorPickerText = Instance.new("TextLabel")
    colorPickerText.Name = "Text"
    colorPickerText.Size = UDim2.new(0.7, 0, 1, 0)
    colorPickerText.Position = UDim2.new(0, 0, 0, 0)
    colorPickerText.BackgroundTransparency = 1
    colorPickerText.Text = name
    colorPickerText.TextColor3 = colors.text
    colorPickerText.TextSize = 14
    colorPickerText.Font = FONT_REGULAR
    colorPickerText.TextXAlignment = Enum.TextXAlignment.Left
    colorPickerText.Parent = colorPickerFrame
    colorPickerText.ZIndex = 4

    local colorButton = Instance.new("TextButton")
    colorButton.Name = "ColorButton"
    colorButton.Size = UDim2.new(0.1, 0, 0.6, 0)
    colorButton.Position = UDim2.new(0.8, 0, 0.2, 0)
    colorButton.BackgroundColor3 = defaultColor
    colorButton.BorderSizePixel = 0
    colorButton.Text = ""
    colorButton.AutoButtonColor = false
    colorButton.Parent = colorPickerFrame
    colorButton.ZIndex = 4

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = colorButton

    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    buttonStroke.Color = colors.textSecondary
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = colorButton

    local screenGui = self.ScreenGui or game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("CustomLib")
    local currentColor = defaultColor
    local colorPickerPopup

    -- Функция создания popup цветового пикера
    local function createColorPickerPopup()
        if colorPickerPopup and colorPickerPopup.Parent then
            colorPickerPopup:Destroy()
        end

        colorPickerPopup = Instance.new("Frame")
        colorPickerPopup.Name = "ColorPickerPopup"
        colorPickerPopup.Size = UDim2.new(0, 300, 0, 250)
        colorPickerPopup.BackgroundColor3 = colors.surface
        colorPickerPopup.BorderSizePixel = 0
        colorPickerPopup.ZIndex = 100
        colorPickerPopup.Parent = screenGui
        colorPickerPopup.ClipsDescendants = true

        local popupCorner = Instance.new("UICorner")
        popupCorner.CornerRadius = UDim.new(0, 8)
        popupCorner.Parent = colorPickerPopup

        local popupStroke = Instance.new("UIStroke")
        popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        popupStroke.Color = colors.primary
        popupStroke.Thickness = 2
        popupStroke.Transparency = 0.7
        popupStroke.Parent = colorPickerPopup

        -- Позиционирование popup
        local buttonPos = colorButton.AbsolutePosition
        local buttonSize = colorButton.AbsoluteSize
        local screenSize = screenGui.AbsoluteSize
        
        local positionX = buttonPos.X - 150 + buttonSize.X / 2
        local positionY = buttonPos.Y + buttonSize.Y + 5
        
        -- Проверка границ экрана
        if positionX + 300 > screenSize.X then
            positionX = screenSize.X - 300 - 5
        end
        
        if positionY + 250 > screenSize.Y then
            positionY = buttonPos.Y - 250 - 5
        end
        
        colorPickerPopup.Position = UDim2.new(0, positionX, 0, positionY)

        -- HSV круг
        local hueCircle = Instance.new("ImageLabel")
        hueCircle.Name = "HueCircle"
        hueCircle.Size = UDim2.new(0, 150, 0, 150)
        hueCircle.Position = UDim2.new(0, 10, 0, 10)
        hueCircle.BackgroundTransparency = 1
        hueCircle.Image = "rbxassetid://2610032323" -- HSV круг
        hueCircle.ZIndex = 101
        hueCircle.Parent = colorPickerPopup

        -- Ползунок яркости
        local brightnessSlider = Instance.new("Frame")
        brightnessSlider.Name = "BrightnessSlider"
        brightnessSlider.Size = UDim2.new(0, 20, 0, 150)
        brightnessSlider.Position = UDim2.new(0, 170, 0, 10)
        brightnessSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        brightnessSlider.BorderSizePixel = 0
        brightnessSlider.ZIndex = 101
        brightnessSlider.Parent = colorPickerPopup

        local brightnessGradient = Instance.new("UIGradient")
        brightnessGradient.Rotation = 90
        brightnessGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
        }
        brightnessGradient.Parent = brightnessSlider

        local brightnessCorner = Instance.new("UICorner")
        brightnessCorner.CornerRadius = UDim.new(0, 4)
        brightnessCorner.Parent = brightnessSlider

        -- Ползунок насыщенности
        local saturationSlider = Instance.new("Frame")
        saturationSlider.Name = "SaturationSlider"
        saturationSlider.Size = UDim2.new(0, 20, 0, 150)
        saturationSlider.Position = UDim2.new(0, 200, 0, 10)
        saturationSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        saturationSlider.BorderSizePixel = 0
        saturationSlider.ZIndex = 101
        saturationSlider.Parent = colorPickerPopup

        local saturationCorner = Instance.new("UICorner")
        saturationCorner.CornerRadius = UDim.new(0, 4)
        saturationCorner.Parent = saturationSlider

        -- Превью выбранного цвета
        local colorPreview = Instance.new("Frame")
        colorPreview.Name = "ColorPreview"
        colorPreview.Size = UDim2.new(0, 80, 0, 30)
        colorPreview.Position = UDim2.new(0, 10, 0, 170)
        colorPreview.BackgroundColor3 = currentColor
        colorPreview.BorderSizePixel = 0
        colorPreview.ZIndex = 101
        colorPreview.Parent = colorPickerPopup

        local previewCorner = Instance.new("UICorner")
        previewCorner.CornerRadius = UDim.new(0, 4)
        previewCorner.Parent = colorPreview

        local previewStroke = Instance.new("UIStroke")
        previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        previewStroke.Color = colors.textSecondary
        previewStroke.Thickness = 1
        previewStroke.Parent = colorPreview

        -- Поля ввода RGB
        local rgbInputFrame = Instance.new("Frame")
        rgbInputFrame.Name = "RGBInputFrame"
        rgbInputFrame.Size = UDim2.new(0, 80, 0, 100)
        rgbInputFrame.Position = UDim2.new(0, 100, 0, 170)
        rgbInputFrame.BackgroundTransparency = 1
        rgbInputFrame.ZIndex = 101
        rgbInputFrame.Parent = colorPickerPopup

        local function createRGBInput(yPos, label, value, max)
            local inputFrame = Instance.new("Frame")
            inputFrame.Size = UDim2.new(1, 0, 0, 25)
            inputFrame.Position = UDim2.new(0, 0, 0, yPos)
            inputFrame.BackgroundTransparency = 1
            inputFrame.ZIndex = 102
            inputFrame.Parent = rgbInputFrame

            local labelText = Instance.new("TextLabel")
            labelText.Size = UDim2.new(0, 20, 1, 0)
            labelText.Position = UDim2.new(0, 0, 0, 0)
            labelText.BackgroundTransparency = 1
            labelText.Text = label
            labelText.TextColor3 = colors.text
            labelText.TextSize = 12
            labelText.Font = FONT_REGULAR
            labelText.ZIndex = 103
            labelText.Parent = inputFrame

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(0, 50, 1, 0)
            textBox.Position = UDim2.new(1, -50, 0, 0)
            textBox.BackgroundColor3 = colors.surface
            textBox.Text = tostring(math.floor(value * max))
            textBox.TextColor3 = colors.text
            textBox.TextSize = 12
            textBox.Font = FONT_REGULAR
            textBox.ZIndex = 103
            textBox.Parent = inputFrame

            local textBoxCorner = Instance.new("UICorner")
            textBoxCorner.CornerRadius = UDim.new(0, 4)
            textBoxCorner.Parent = textBox

            textBox.FocusLost:Connect(function()
                local num = tonumber(textBox.Text)
                if num then
                    num = math.clamp(num, 0, max)
                    textBox.Text = tostring(num)
                    -- Обновление цвета
                end
            end)

            return textBox
        end

        local rInput = createRGBInput(0, "R", currentColor.R, 255)
        local gInput = createRGBInput(30, "G", currentColor.G, 255)
        local bInput = createRGBInput(60, "B", currentColor.B, 255)

        -- Кнопка подтверждения
        local confirmButton = Instance.new("TextButton")
        confirmButton.Name = "ConfirmButton"
        confirmButton.Size = UDim2.new(0, 80, 0, 30)
        confirmButton.Position = UDim2.new(0, 190, 0, 210)
        confirmButton.BackgroundColor3 = colors.primary
        confirmButton.BorderSizePixel = 0
        confirmButton.Text = "OK"
        confirmButton.TextColor3 = colors.text
        confirmButton.TextSize = 14
        confirmButton.Font = FONT_REGULAR
        confirmButton.ZIndex = 101
        confirmButton.Parent = colorPickerPopup

        local confirmCorner = Instance.new("UICorner")
        confirmCorner.CornerRadius = UDim.new(0, 4)
        confirmCorner.Parent = confirmButton

        -- Анимация появления
        colorPickerPopup.Size = UDim2.new(0, 10, 0, 10)
        colorPickerPopup.BackgroundTransparency = 1
        
        createTween(colorPickerPopup, {
            Size = UDim2.new(0, 300, 0, 250),
            BackgroundTransparency = 0
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        -- Функция обновления цвета
        local function updateColor(newColor)
            currentColor = newColor
            colorButton.BackgroundColor3 = newColor
            colorPreview.BackgroundColor3 = newColor
            callback(newColor)
        end

        -- Обработчики взаимодействия
        confirmButton.MouseButton1Click:Connect(function()
            createTween(colorPickerPopup, {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            wait(0.2)
            colorPickerPopup:Destroy()
        end)

        -- Закрытие при клике вне области
        local function closeColorPicker(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = input.Position
                local popupPos = colorPickerPopup.AbsolutePosition
                local popupSize = colorPickerPopup.AbsoluteSize
                
                local isClickInPopup = mousePos.X >= popupPos.X and mousePos.X <= popupPos.X + popupSize.X and
                                     mousePos.Y >= popupPos.Y and mousePos.Y <= popupPos.Y + popupSize.Y
                                     
                local isClickInButton = mousePos.X >= colorButton.AbsolutePosition.X and 
                                      mousePos.X <= colorButton.AbsolutePosition.X + colorButton.AbsoluteSize.X and
                                      mousePos.Y >= colorButton.AbsolutePosition.Y and 
                                      mousePos.Y <= colorButton.AbsolutePosition.Y + colorButton.AbsoluteSize.Y
                
                if not isClickInPopup and not isClickInButton then
                    createTween(colorPickerPopup, {
                        Size = UDim2.new(0, 10, 0, 10),
                        BackgroundTransparency = 1
                    }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    wait(0.2)
                    colorPickerPopup:Destroy()
                end
            end
        end

        UserInputService.InputBegan:Connect(closeColorPicker)
    end

    -- Обработчики событий
    colorButton.MouseButton1Click:Connect(createColorPickerPopup)

    -- Анимации кнопки
    colorButton.MouseEnter:Connect(function()
        createTween(buttonStroke, {Thickness = 2}, 0.2)
        createTween(colorButton, {Size = UDim2.new(0.11, 0, 0.66, 0)}, 0.2)
    end)

    colorButton.MouseLeave:Connect(function()
        createTween(buttonStroke, {Thickness = 1}, 0.2)
        createTween(colorButton, {Size = UDim2.new(0.1, 0, 0.6, 0)}, 0.2)
    end)

    -- Адаптация для мобильных устройств
    if UserInputService.TouchEnabled then
        colorButton.Size = UDim2.new(0.15, 0, 0.7, 0)
        colorButton.Position = UDim2.new(0.75, 0, 0.15, 0)
        colorPickerText.Size = UDim2.new(0.75, 0, 1, 0)
    end

    table.insert(tab.Elements, colorPickerFrame)
    
    return {
        Frame = colorPickerFrame,
        SetColor = function(color)
            currentColor = color
            colorButton.BackgroundColor3 = color
            callback(color)
        end,
        GetColor = function()
            return currentColor
        end
    }
end

-- Улучшенная функция для добавления чекбокса
function Library:AddCheckbox(tab, name, callback, config)
    config = config or {}
    local defaultState = config.default or false
    
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.Name = name
    checkboxFrame.Size = UDim2.new(1, -20, 0, 40)
    checkboxFrame.BackgroundTransparency = 1
    checkboxFrame.Parent = tab.Content
    checkboxFrame.LayoutOrder = #tab.Elements + 1
    checkboxFrame.Visible = true
    checkboxFrame.ZIndex = 3

    local checkboxText = Instance.new("TextLabel")
    checkboxText.Name = "Text"
    checkboxText.Size = UDim2.new(0.7, 0, 1, 0)
    checkboxText.Position = UDim2.new(0, 0, 0, 0)
    checkboxText.BackgroundTransparency = 1
    checkboxText.Text = name
    checkboxText.TextColor3 = colors.text
    checkboxText.TextSize = 14
    checkboxText.Font = FONT_REGULAR
    checkboxText.TextXAlignment = Enum.TextXAlignment.Left
    checkboxText.Parent = checkboxFrame
    checkboxText.ZIndex = 4

    local checkboxButton = Instance.new("TextButton")
    checkboxButton.Name = "Checkbox"
    checkboxButton.Size = UDim2.new(0, 25, 0, 25)
    checkboxButton.Position = UDim2.new(1, -25, 0.5, -12)
    checkboxButton.BackgroundColor3 = colors.surface
    checkboxButton.BorderSizePixel = 0
    checkboxButton.Text = ""
    checkboxButton.Parent = checkboxFrame
    checkboxButton.AutoButtonColor = false
    checkboxButton.ZIndex = 4

    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 6)
    checkboxCorner.Parent = checkboxButton

    local checkIcon = Instance.new("TextLabel")
    checkIcon.Name = "CheckIcon"
    checkIcon.Size = UDim2.new(1, 0, 1, 0)
    checkIcon.Position = UDim2.new(0, 0, 0, 0)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Text = "✓"
    checkIcon.TextColor3 = colors.text
    checkIcon.TextSize = 16
    checkIcon.Font = FONT_REGULAR
    checkIcon.Visible = false
    checkIcon.Parent = checkboxButton
    checkIcon.ZIndex = 5

    local isChecked = defaultState

    local function updateCheckbox()
        if isChecked then
            createTween(checkboxButton, {BackgroundColor3 = colors.primary}, 0.3)
            checkIcon.Visible = true
            checkIcon.TextTransparency = 1
            createTween(checkIcon, {TextTransparency = 0}, 0.3)
        else
            createTween(checkboxButton, {BackgroundColor3 = colors.surface}, 0.3)
            createTween(checkIcon, {TextTransparency = 1}, 0.2)
            wait(0.2)
            checkIcon.Visible = false
        end
        callback(isChecked)
    end

    -- Анимации
    checkboxButton.MouseEnter:Connect(function()
        createTween(checkboxButton, {
            BackgroundColor3 = isChecked and Color3.fromRGB(110, 80, 210) or Color3.fromRGB(50, 50, 65)
        }, 0.2)
    end)

    checkboxButton.MouseLeave:Connect(function()
        createTween(checkboxButton, {
            BackgroundColor3 = isChecked and colors.primary or colors.surface
        }, 0.2)
    end)

    checkboxButton.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        
        -- Эффект пульсации
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.BackgroundColor3 = isChecked and colors.primary or colors.textSecondary
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 6
        ripple.Parent = checkboxButton
        
        local rippleCorner = Instance.new("UICorner")
        rippleCorner.CornerRadius = UDim.new(1, 0)
        rippleCorner.Parent = ripple
        
        createTween(ripple, {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }, 0.4):Wait()
        ripple:Destroy()
        
        updateCheckbox()
    end)

    -- Установка начального состояния
    updateCheckbox()

    table.insert(tab.Elements, checkboxFrame)
    
    return {
        Frame = checkboxFrame,
        SetChecked = function(state)
            isChecked = state
            updateCheckbox()
        end,
        GetChecked = function()
            return isChecked
        end
    }
end

-- Улучшенная функция для добавления поля ввода
function Library:AddInputText(tab, name, placeholder, callback, config)
    config = config or {}
    local defaultText = config.default or ""
    
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = name
    inputFrame.Size = UDim2.new(1, -20, 0, 50)
    inputFrame.BackgroundTransparency = 1
    inputFrame.Parent = tab.Content
    inputFrame.LayoutOrder = #tab.Elements + 1
    inputFrame.Visible = true
    inputFrame.ZIndex = 3

    local inputText = Instance.new("TextLabel")
    inputText.Name = "Text"
    inputText.Size = UDim2.new(1, 0, 0, 20)
    inputText.Position = UDim2.new(0, 0, 0, 0)
    inputText.BackgroundTransparency = 1
    inputText.Text = name
    inputText.TextColor3 = colors.text
    inputText.TextSize = 14
    inputText.Font = FONT_REGULAR
    inputText.TextXAlignment = Enum.TextXAlignment.Left
    inputText.Parent = inputFrame
    inputText.ZIndex = 4

    local textBox = Instance.new("TextBox")
    textBox.Name = "InputBox"
    textBox.Size = UDim2.new(1, 0, 0, 30)
    textBox.Position = UDim2.new(0, 0, 0, 20)
    textBox.BackgroundColor3 = colors.surface
    textBox.BorderSizePixel = 0
    textBox.Text = defaultText
    textBox.PlaceholderText = placeholder
    textBox.TextColor3 = colors.text
    textBox.PlaceholderColor3 = colors.textSecondary
    textBox.TextSize = 14
    textBox.Font = FONT_REGULAR
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    textBox.ZIndex = 4

    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 6)
    textBoxCorner.Parent = textBox

    local textBoxPadding = Instance.new("UIPadding")
    textBoxPadding.PaddingLeft = UDim.new(0, 10)
    textBoxPadding.Parent = textBox

    -- Анимации
    textBox.Focused:Connect(function()
        createTween(textBox, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
        createTween(textBox, {Size = UDim2.new(1, -5, 0, 30)}, 0.1)
    end)

    textBox.FocusLost:Connect(function()
        createTween(textBox, {BackgroundColor3 = colors.surface}, 0.2)
        createTween(textBox, {Size = UDim2.new(1, 0, 0, 30)}, 0.1)
        callback(textBox.Text)
    end)

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        if textBox:IsFocused() then
            createTween(textBox, {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}, 0.1)
        end
    end)

    table.insert(tab.Elements, inputFrame)
    
    return {
        Frame = inputFrame,
        SetText = function(text)
            textBox.Text = text
        end,
        GetText = function()
            return textBox.Text
        end
    }
end

-- Улучшенная функция для выбора игрока
function Library:AddPlayerSelector(tab, name, callback, config)
    config = config or {}
    local showDisplayNames = config.showDisplayNames or false
    
    local playerSelectorFrame = Instance.new("Frame")
    playerSelectorFrame.Name = name .. "PlayerSelector"
    playerSelectorFrame.Size = UDim2.new(1, -20, 0, 40)
    playerSelectorFrame.BackgroundTransparency = 1
    playerSelectorFrame.Parent = tab.Content
    playerSelectorFrame.LayoutOrder = #tab.Elements + 1
    playerSelectorFrame.Visible = true
    playerSelectorFrame.ZIndex = 3

    local playerSelectorText = Instance.new("TextLabel")
    playerSelectorText.Name = "Text"
    playerSelectorText.Size = UDim2.new(0.7, 0, 1, 0)
    playerSelectorText.Position = UDim2.new(0, 0, 0, 0)
    playerSelectorText.BackgroundTransparency = 1
    playerSelectorText.Text = name
    playerSelectorText.TextColor3 = colors.text
    playerSelectorText.TextSize = 14
    playerSelectorText.Font = FONT_REGULAR
    playerSelectorText.TextXAlignment = Enum.TextXAlignment.Left
    playerSelectorText.Parent = playerSelectorFrame
    playerSelectorText.ZIndex = 4

    local playerSelectorButton = Instance.new("TextButton")
    playerSelectorButton.Name = "PlayerSelectorButton"
    playerSelectorButton.Size = UDim2.new(0.3, 0, 1, 0)
    playerSelectorButton.Position = UDim2.new(0.7, 0, 0, 0)
    playerSelectorButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    playerSelectorButton.BorderSizePixel = 0
    playerSelectorButton.Text = "Choose..."
    playerSelectorButton.TextColor3 = colors.text
    playerSelectorButton.TextSize = 13
    playerSelectorButton.Font = FONT_REGULAR
    playerSelectorButton.Parent = playerSelectorFrame
    playerSelectorButton.AutoButtonColor = false
    playerSelectorButton.ZIndex = 4

    local playerSelectorCorner = Instance.new("UICorner")
    playerSelectorCorner.CornerRadius = UDim.new(0, 6)
    playerSelectorCorner.Parent = playerSelectorButton

    local playerSelectorIcon = Instance.new("TextLabel")
    playerSelectorIcon.Name = "Icon"
    playerSelectorIcon.Size = UDim2.new(0, 20, 1, 0)
    playerSelectorIcon.Position = UDim2.new(1, -20, 0, 0)
    playerSelectorIcon.BackgroundTransparency = 1
    playerSelectorIcon.Text = "▼"
    playerSelectorIcon.TextColor3 = colors.textSecondary
    playerSelectorIcon.TextSize = 12
    playerSelectorIcon.Font = FONT_REGULAR
    playerSelectorIcon.Parent = playerSelectorButton
    playerSelectorIcon.ZIndex = 5

    local screenGui = self.ScreenGui or game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("CustomLib")
    local playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(0, 0, 0, 0)
    playerList.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 6
    playerList.ScrollBarImageColor3 = colors.textSecondary
    playerList.ScrollBarImageTransparency = 0.7
    playerList.Visible = false
    playerList.ZIndex = 100
    playerList.Parent = screenGui

    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 6)
    listCorner.Parent = playerList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = playerList
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 5)
    listPadding.PaddingLeft = UDim.new(0, 5)
    listPadding.PaddingRight = UDim.new(0, 5)
    listPadding.Parent = playerList

    local isOpen = false
    local selectedPlayer = nil
    local renderConnection
    local playerAddedConnection
    local playerRemovingConnection
    local playerButtons = {}

    -- Анимации кнопки
    playerSelectorButton.MouseEnter:Connect(function()
        createTween(playerSelectorButton, {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}, 0.2)
    end)

    playerSelectorButton.MouseLeave:Connect(function()
        if not isOpen then
            createTween(playerSelectorButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
        end
    end)

    -- Функции для работы со списком игроков
    local function updatePlayerListPosition()
        if isOpen then
            local buttonAbsolutePos = playerSelectorButton.AbsolutePosition
            local buttonAbsoluteSize = playerSelectorButton.AbsoluteSize
            local listWidth = math.max(buttonAbsoluteSize.X * 1.5, 250)
            
            playerList.Position = UDim2.new(
                0, buttonAbsolutePos.X - (listWidth - buttonAbsoluteSize.X) / 2,
                0, buttonAbsolutePos.Y + buttonAbsoluteSize.Y + 5
            )
            playerList.Size = UDim2.new(0, listWidth, 0, playerList.AbsoluteSize.Y)
        end
    end

    local function updateListSize()
        if not isOpen then return end
        local contentHeight = listLayout.AbsoluteContentSize.Y + 10
        local maxHeight = math.min(contentHeight, 200)
        playerList.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
        playerList.Size = UDim2.new(playerList.Size.X.Scale, playerList.Size.X.Offset, 0, maxHeight)
        updatePlayerListPosition()
    end

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateListSize)

    local function clearPlayerButtons()
        for _, button in pairs(playerButtons) do
            if button and button.Parent then
                button:Destroy()
            end
        end
        playerButtons = {}
    end

    local function createPlayerButtons()
        clearPlayerButtons()
        local players = game.Players:GetPlayers()
        
        for _, player in ipairs(players) do
            if player ~= game.Players.LocalPlayer then
                local playerButton = Instance.new("TextButton")
                playerButton.Name = player.Name .. "PlayerButton"
                playerButton.Size = UDim2.new(1, -10, 0, 40)
                playerButton.BackgroundColor3 = colors.surface
                playerButton.BorderSizePixel = 0
                playerButton.Text = ""
                playerButton.ZIndex = 101
                playerButton.AutoButtonColor = false
                playerButton.Parent = playerList
                playerButtons[player] = playerButton

                local playerButtonCorner = Instance.new("UICorner")
                playerButtonCorner.CornerRadius = UDim.new(0, 4)
                playerButtonCorner.Parent = playerButton

                local playerIcon = Instance.new("ImageLabel")
                playerIcon.Name = "PlayerIcon"
                playerIcon.Size = UDim2.new(0, 30, 0, 30)
                playerIcon.Position = UDim2.new(0, 5, 0.5, -15)
                playerIcon.BackgroundTransparency = 1
                
                -- Загрузка аватара игрока
                spawn(function()
                    local success, result = pcall(function()
                        return game.Players:GetUserThumbnailAsync(
                            player.UserId, 
                            Enum.ThumbnailType.HeadShot, 
                            Enum.ThumbnailSize.Size100x100
                        )
                    end)
                    
                    if success then
                        playerIcon.Image = result
                    else
                        playerIcon.Image = "rbxassetid://0" -- Заглушка
                    end
                end)
                
                playerIcon.ZIndex = 102
                playerIcon.Parent = playerButton

                local playerName = Instance.new("TextLabel")
                playerName.Name = "PlayerName"
                playerName.Size = UDim2.new(1, -40, 1, 0)
                playerName.Position = UDim2.new(0, 40, 0, 0)
                playerName.BackgroundTransparency = 1
                
                local displayName = showDisplayNames and player.DisplayName or player.Name
                if #displayName > 15 then
                    displayName = string.sub(displayName, 1, 15) .. "..."
                end
                
                playerName.Text = displayName
                playerName.TextColor3 = colors.text
                playerName.TextSize = 13
                playerName.Font = FONT_REGULAR
                playerName.TextXAlignment = Enum.TextXAlignment.Left
                playerName.ZIndex = 102
                playerName.Parent = playerButton

                local tooltip = Instance.new("TextLabel")
                tooltip.Name = "Tooltip"
                tooltip.Size = UDim2.new(0, 0, 0, 0)
                tooltip.Position = UDim2.new(0, 0, 1, 5)
                tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                tooltip.BorderSizePixel = 0
                tooltip.Text = player.Name
                tooltip.TextColor3 = colors.text
                tooltip.TextSize = 12
                tooltip.Font = FONT_REGULAR
                tooltip.Visible = false
                tooltip.ZIndex = 105
                tooltip.Parent = playerButton

                local tooltipCorner = Instance.new("UICorner")
                tooltipCorner.CornerRadius = UDim.new(0, 4)
                tooltipCorner.Parent = tooltip

                local tooltipPadding = Instance.new("UIPadding")
                tooltipPadding.PaddingLeft = UDim.new(0, 5)
                tooltipPadding.PaddingRight = UDim.new(0, 5)
                tooltipPadding.Parent = tooltip

                -- Анимации кнопки игрока
                playerButton.MouseEnter:Connect(function()
                    createTween(playerButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.2)
                    local textSize = TextService:GetTextSize(
                        player.Name, tooltip.TextSize, tooltip.Font, Vector2.new(1000, 1000)
                    )
                    tooltip.Size = UDim2.new(0, textSize.X + 10, 0, textSize.Y)
                    tooltip.Visible = true
                end)

                playerButton.MouseLeave:Connect(function()
                    createTween(playerButton, {BackgroundColor3 = colors.surface}, 0.2)
                    tooltip.Visible = false
                end)

                playerButton.MouseButton1Click:Connect(function()
                    selectedPlayer = player
                    local buttonText = showDisplayNames and player.DisplayName or player.Name
                    if #buttonText > 12 then
                        buttonText = string.sub(buttonText, 1, 12) .. "..."
                    end
                    
                    playerSelectorButton.Text = buttonText
                    togglePlayerList()
                    callback(player)
                    
                    -- Эффект пульсации
                    local ripple = Instance.new("Frame")
                    ripple.Name = "Ripple"
                    ripple.Size = UDim2.new(0, 0, 0, 0)
                    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                    ripple.BackgroundColor3 = colors.primary
                    ripple.BackgroundTransparency = 0.7
                    ripple.BorderSizePixel = 0
                    ripple.ZIndex = 106
                    ripple.Parent = playerButton
                    
                    local rippleCorner = Instance.new("UICorner")
                    rippleCorner.CornerRadius = UDim.new(1, 0)
                    rippleCorner.Parent = ripple
                    
                    createTween(ripple, {
                        Size = UDim2.new(2, 0, 2, 0),
                        BackgroundTransparency = 1
                    }, 0.4):Wait()
                    ripple:Destroy()
                end)
            end
        end
        
        updateListSize()
    end

    local function togglePlayerList()
        isOpen = not isOpen
        
        if isOpen then
            createTween(playerSelectorButton, {BackgroundColor3 = colors.primary}, 0.2)
            createTween(playerList, {Size = UDim2.new(0, 0, 0, 0)}, 0.1)
            createPlayerButtons()
            playerList.Visible = true
            playerSelectorIcon.Text = "▲"
            
            if not renderConnection then
                renderConnection = RunService.RenderStepped:Connect(updatePlayerListPosition)
            end
            
            -- Подписка на события добавления/удаления игроков
            if playerAddedConnection then
                playerAddedConnection:Disconnect()
            end
            
            if playerRemovingConnection then
                playerRemovingConnection:Disconnect()
            end
            
            playerAddedConnection = game.Players.PlayerAdded:Connect(function(player)
                wait(0.1)
                createPlayerButtons()
            end)
            
            playerRemovingConnection = game.Players.PlayerRemoving:Connect(function(player)
                if selectedPlayer == player then
                    selectedPlayer = nil
                    playerSelectorButton.Text = "Choose..."
                end
                wait(0.1)
                createPlayerButtons()
            end)
        else
            createTween(playerSelectorButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)}, 0.2)
            createTween(playerList, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            wait(0.2)
            playerList.Visible = false
            playerSelectorIcon.Text = "▼"
            
            if renderConnection then
                renderConnection:Disconnect()
                renderConnection = nil
            end
            
            if playerAddedConnection then
                playerAddedConnection:Disconnect()
                playerAddedConnection = nil
            end
            
            if playerRemovingConnection then
                playerRemovingConnection:Disconnect()
                playerRemovingConnection = nil
            end
            
            clearPlayerButtons()
        end
    end

    playerSelectorButton.MouseButton1Click:Connect(togglePlayerList)

    -- Закрытие списка при клике вне его
    local function closePlayerList(input)
        if isOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local listPos = playerList.AbsolutePosition
            local listSize = playerList.AbsoluteSize
            local isClickInsideList = mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X and
                                     mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y
                                     
            local isClickOnButton = mousePos.X >= playerSelectorButton.AbsolutePosition.X and 
                                   mousePos.X <= playerSelectorButton.AbsolutePosition.X + playerSelectorButton.AbsoluteSize.X and
                                   mousePos.Y >= playerSelectorButton.AbsolutePosition.Y and 
                                   mousePos.Y <= playerSelectorButton.AbsolutePosition.Y + playerSelectorButton.AbsoluteSize.Y
                                   
            if not isClickInsideList and not isClickOnButton then
                togglePlayerList()
            end
        end
    end

    UserInputService.InputBegan:Connect(closePlayerList)

    -- Очистка при уничтожении
    playerSelectorFrame.Destroying:Connect(function()
        if renderConnection then
            renderConnection:Disconnect()
        end
        
        if playerAddedConnection then
            playerAddedConnection:Disconnect()
        end
        
        if playerRemovingConnection then
            playerRemovingConnection:Disconnect()
        end
        
        clearPlayerButtons()
        playerList:Destroy()
    end)

    table.insert(tab.Elements, playerSelectorFrame)
    
    return {
        Frame = playerSelectorFrame,
        GetSelectedPlayer = function()
            return selectedPlayer
        end,
        SetSelectedPlayer = function(player)
            if player and player:IsA("Player") then
                selectedPlayer = player
                local buttonText = showDisplayNames and player.DisplayName or player.Name
                if #buttonText > 12 then
                    buttonText = string.sub(buttonText, 1, 12) .. "..."
                end
                playerSelectorButton.Text = buttonText
                callback(player)
            end
        end
    }
end

-- Улучшенная функция для уведомлений
function Library:Notification(title, message, duration, notifType)
    duration = duration or 5
    notifType = notifType or "info"
    
    local screenGui = self.ScreenGui
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(0, 300, 0, 80)
    notificationFrame.Position = UDim2.new(1, -320, 1, -100)
    notificationFrame.BackgroundColor3 = colors.surface
    notificationFrame.BorderSizePixel = 0
    notificationFrame.ZIndex = 100
    notificationFrame.Parent = screenGui

    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 8)
    notificationCorner.Parent = notificationFrame

    local notificationStroke = Instance.new("UIStroke")
    notificationStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    notificationStroke.Color = colors.primary
    notificationStroke.Thickness = 2
    notificationStroke.Transparency = 0.7
    notificationStroke.Parent = notificationFrame

    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -10, 0, 20)
    titleText.Position = UDim2.new(0, 10, 0, 10)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = colors.text
    titleText.TextSize = 16
    titleText.Font = FONT_BOLD
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 101
    titleText.Parent = notificationFrame

    local messageText = Instance.new("TextLabel")
    messageText.Name = "MessageText"
    messageText.Size = UDim2.new(1, -10, 0, 40)
    messageText.Position = UDim2.new(0, 10, 0, 30)
    messageText.BackgroundTransparency = 1
    messageText.Text = message
    messageText.TextColor3 = colors.textSecondary
    messageText.TextSize = 14
    messageText.Font = FONT_REGULAR
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Top
    messageText.TextWrapped = true
    messageText.ZIndex = 101
    messageText.Parent = notificationFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = colors.textSecondary
    closeButton.TextSize = 18
    closeButton.Font = FONT_REGULAR
    closeButton.ZIndex = 101
    closeButton.Parent = notificationFrame

    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = colors.primary
    progressBar.BorderSizePixel = 0
    progressBar.ZIndex = 101
    progressBar.Parent = notificationFrame

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 1)
    progressCorner.Parent = progressBar

    -- Установка цвета в зависимости от типа уведомления
    local typeColors = {
        info = colors.primary,
        success = colors.success,
        warning = colors.warning,
        error = colors.error
    }
    
    local notifColor = typeColors[notifType] or colors.primary
    notificationStroke.Color = notifColor
    progressBar.BackgroundColor3 = notifColor

    -- Анимация появления
    notificationFrame.Position = UDim2.new(1, -320, 1, 100)
    notificationFrame.BackgroundTransparency = 1
    titleText.TextTransparency = 1
    messageText.TextTransparency = 1
    closeButton.TextTransparency = 1
    progressBar.BackgroundTransparency = 1
    
    createTween(notificationFrame, {
        Position = UDim2.new(1, -320, 1, -100),
        BackgroundTransparency = 0
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    createTween(titleText, {TextTransparency = 0}, 0.5)
    createTween(messageText, {TextTransparency = 0}, 0.5)
    createTween(closeButton, {TextTransparency = 0}, 0.5)
    createTween(progressBar, {BackgroundTransparency = 0}, 0.5)

    -- Обработчик закрытия
    closeButton.MouseButton1Click:Connect(function()
        createTween(notificationFrame, {
            Position = UDim2.new(1, -320, 1, 100),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        createTween(titleText, {TextTransparency = 1}, 0.3)
        createTween(messageText, {TextTransparency = 1}, 0.3)
        createTween(closeButton, {TextTransparency = 1}, 0.3)
        createTween(progressBar, {BackgroundTransparency = 1}, 0.3)
        
        wait(0.3)
        notificationFrame:Destroy()
    end)

    -- Автоматическое закрытие
    spawn(function()
        local startTime = tick()
        
        while tick() - startTime < duration do
            local elapsed = tick() - startTime
            local progress = elapsed / duration
            progressBar.Size = UDim2.new(1 - progress, 0, 0, 3)
            RunService.RenderStepped:Wait()
        end
        
        createTween(notificationFrame, {
            Position = UDim2.new(1, -320, 1, 100),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        createTween(titleText, {TextTransparency = 1}, 0.3)
        createTween(messageText, {TextTransparency = 1}, 0.3)
        createTween(closeButton, {TextTransparency = 1}, 0.3)
        createTween(progressBar, {BackgroundTransparency = 1}, 0.3)
        
        wait(0.3)
        notificationFrame:Destroy()
    end)

    return {
        Frame = notificationFrame,
        Close = function()
            closeButton:Activate()
        end,
        Update = function(newTitle, newMessage, newDuration)
            if newTitle then
                titleText.Text = newTitle
            end
            
            if newMessage then
                messageText.Text = newMessage
            end
            
            if newDuration then
                duration = newDuration
            end
        end
    }
end

-- Улучшенная функция для радужных углов
function Library:EnableRainbowCorners(speed)
    if self.RainbowCorners then return end
    
    self.RainbowCorners = true
    speed = speed or 1
    
    local hue = 0
    local corners = {}
    
    -- Сбор всех углов
    table.insert(corners, self.MainFrame:FindFirstChildOfClass("UICorner"))
    
    for _, tab in ipairs(self.Tabs) do
        if tab.Button:FindFirstChildOfClass("UICorner") then
            table.insert(corners, tab.Button:FindFirstChildOfClass("UICorner"))
        end
        
        for _, element in ipairs(tab.Elements) do
            local corner = element:FindFirstChildOfClass("UICorner")
            if corner then
                table.insert(corners, corner)
            end
        end
    end
    
    local connection
    connection = RunService.RenderStepped:Connect(function(delta)
        if not self.RainbowCorners then
            connection:Disconnect()
            return
        end
        
        hue = (hue + delta * 0.2 * speed) % 1
        local color = HSVToRGB(hue, 1, 1)
        
        -- Анимация углов
        for _, corner in ipairs(corners) do
            if corner then
                corner.CornerRadius = UDim.new(0, 8 + math.sin(tick() * 2 * speed) * 2)
            end
        end
        
        -- Анимация обводки
        local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
        if stroke then
            stroke.Color = color
        end
        
        -- Анимация кнопок вкладок
        for _, tab in ipairs(self.Tabs) do
            if currentTab == tab then
                tab.Highlight.BackgroundColor3 = color
            end
        end
    end)
    
    return connection
end

function Library:DisableRainbowCorners()
    self.RainbowCorners = false
    
    -- Восстановление стандартных значений
    local corners = {}
    local mainCorner = self.MainFrame:FindFirstChildOfClass("UICorner")
    if mainCorner then
        mainCorner.CornerRadius = UDim.new(0, 12)
    end
    
    for _, tab in ipairs(self.Tabs) do
        local tabCorner = tab.Button:FindFirstChildOfClass("UICorner")
        if tabCorner then
            tabCorner.CornerRadius = UDim.new(0, 8)
        end
        
        for _, element in ipairs(tab.Elements) do
            local corner = element:FindFirstChildOfClass("UICorner")
            if corner then
                corner.CornerRadius = UDim.new(0, 8)
            end
        end
    end
    
    local stroke = self.MainFrame:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = colors.primary
    end
    
    for _, tab in ipairs(self.Tabs) do
        if currentTab == tab then
            tab.Highlight.BackgroundColor3 = colors.primary
        end
    end
end

-- Функция для создания всплывающего меню
function Library:CreateContextMenu(options, position)
    local screenGui = self.ScreenGui
    local contextMenu = Instance.new("Frame")
    contextMenu.Name = "ContextMenu"
    contextMenu.Size = UDim2.new(0, 150, 0, 0)
    contextMenu.BackgroundColor3 = colors.surface
    contextMenu.BorderSizePixel = 0
    contextMenu.ZIndex = 100
    contextMenu.Parent = screenGui
    
    local contextCorner = Instance.new("UICorner")
    contextCorner.CornerRadius = UDim.new(0, 6)
    contextCorner.Parent = contextMenu
    
    local contextStroke = Instance.new("UIStroke")
    contextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    contextStroke.Color = colors.primary
    contextStroke.Thickness = 2
    contextStroke.Transparency = 0.7
    contextStroke.Parent = contextMenu
    
    local contextLayout = Instance.new("UIListLayout")
    contextLayout.Parent = contextMenu
    contextLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local contextPadding = Instance.new("UIPadding")
    contextPadding.PaddingTop = UDim.new(0, 5)
    contextPadding.PaddingBottom = UDim.new(0, 5)
    contextPadding.Parent = contextMenu
    
    -- Позиционирование меню
    if position then
        contextMenu.Position = position
    else
        local mousePos = UserInputService:GetMouseLocation()
        contextMenu.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    end
    
    -- Создание пунктов меню
    for i, option in ipairs(options) do
        local menuItem = Instance.new("TextButton")
        menuItem.Name = option.Text or "MenuItem" .. i
        menuItem.Size = UDim2.new(1, -10, 0, 30)
        menuItem.Position = UDim2.new(0, 5, 0, 5 + (i-1) * 35)
        menuItem.BackgroundColor3 = colors.surface
        menuItem.BorderSizePixel = 0
        menuItem.Text = option.Text or "Option " .. i
        menuItem.TextColor3 = colors.text
        menuItem.TextSize = 14
        menuItem.Font = FONT_REGULAR
        menuItem.ZIndex = 101
        menuItem.AutoButtonColor = false
        menuItem.Parent = contextMenu
        
        local menuItemCorner = Instance.new("UICorner")
        menuItemCorner.CornerRadius = UDim.new(0, 4)
        menuItemCorner.Parent = menuItem
        
        -- Анимации пункта меню
        menuItem.MouseEnter:Connect(function()
            createTween(menuItem, {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.2)
        end)
        
        menuItem.MouseLeave:Connect(function()
            createTween(menuItem, {BackgroundColor3 = colors.surface}, 0.2)
        end)
        
        menuItem.MouseButton1Click:Connect(function()
            if option.Callback then
                option.Callback()
            end
            contextMenu:Destroy()
        end)
    end
    
    -- Обновление размера меню
    contextLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contextMenu.Size = UDim2.new(0, 150, 0, contextLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Закрытие меню при клике вне его
    local function closeContextMenu(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local menuPos = contextMenu.AbsolutePosition
            local menuSize = contextMenu.AbsoluteSize
            
            local isClickInsideMenu = mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + menuSize.X and
                                    mousePos.Y >= menuPos.Y and mousePos.Y <= menuPos.Y + menuSize.Y
                                    
            if not isClickInsideMenu then
                contextMenu:Destroy()
                UserInputService.InputBegan:Disconnect(closeContextMenu)
            end
        end
    end
    
    UserInputService.InputBegan:Connect(closeContextMenu)
    
    -- Анимация появления
    contextMenu.Size = UDim2.new(0, 10, 0, 10)
    contextMenu.BackgroundTransparency = 1
    
    createTween(contextMenu, {
        Size = UDim2.new(0, 150, 0, contextLayout.AbsoluteContentSize.Y + 10),
        BackgroundTransparency = 0
    }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    return contextMenu
end

-- Функция для создания тултипа
function Library:CreateTooltip(text, position)
    local screenGui = self.ScreenGui
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 0, 0, 0)
    tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tooltip.BorderSizePixel = 0
    tooltip.ZIndex = 100
    tooltip.Parent = screenGui
    
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, 4)
    tooltipCorner.Parent = tooltip
    
    local tooltipText = Instance.new("TextLabel")
    tooltipText.Name = "TooltipText"
    tooltipText.Size = UDim2.new(1, -10, 1, -10)
    tooltipText.Position = UDim2.new(0, 5, 0, 5)
    tooltipText.BackgroundTransparency = 1
    tooltipText.Text = text
    tooltipText.TextColor3 = colors.text
    tooltipText.TextSize = 12
    tooltipText.Font = FONT_REGULAR
    tooltipText.TextXAlignment = Enum.TextXAlignment.Left
    tooltipText.TextYAlignment = Enum.TextYAlignment.Top
    tooltipText.TextWrapped = true
    tooltipText.ZIndex = 101
    tooltipText.Parent = tooltip
    
    local tooltipPadding = Instance.new("UIPadding")
    tooltipPadding.PaddingLeft = UDim.new(0, 5)
    tooltipPadding.PaddingRight = UDim.new(0, 5)
    tooltipPadding.Parent = tooltipText
    
    -- Позиционирование тултипа
    if position then
        tooltip.Position = position
    else
        local mousePos = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.new(0, mousePos.X + 10, 0, mousePos.Y + 10)
    end
    
    -- Обновление размера тултипа
    local textSize = TextService:GetTextSize(
        tooltipText.Text, tooltipText.TextSize, tooltipText.Font, Vector2.new(200, math.huge)
    )
    
    tooltip.Size = UDim2.new(0, textSize.X + 20, 0, textSize.Y + 10)
    
    -- Анимация появления
    tooltip.BackgroundTransparency = 1
    tooltipText.TextTransparency = 1
    
    createTween(tooltip, {BackgroundTransparency = 0}, 0.2)
    createTween(tooltipText, {TextTransparency = 0}, 0.2)
    
    return {
        Frame = tooltip,
        Update = function(newText)
            tooltipText.Text = newText
            local newTextSize = TextService:GetTextSize(
                newText, tooltipText.TextSize, tooltipText.Font, Vector2.new(200, math.huge)
            )
            tooltip.Size = UDim2.new(0, newTextSize.X + 20, 0, newTextSize.Y + 10)
        end,
        Destroy = function()
            createTween(tooltip, {BackgroundTransparency = 1}, 0.2)
            createTween(tooltipText, {TextTransparency = 1}, 0.2)
            wait(0.2)
            tooltip:Destroy()
        end
    }
end

-- Функция для создания модального окна
function Library:CreateModal(title, content, buttons)
    local screenGui = self.ScreenGui
    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = UDim2.new(0, 400, 0, 200)
    modal.Position = UDim2.new(0.5, -200, 0.5, -100)
    modal.AnchorPoint = Vector2.new(0.5, 0.5)
    modal.BackgroundColor3 = colors.surface
    modal.BorderSizePixel = 0
    modal.ZIndex = 100
    modal.Parent = screenGui
    
    local modalCorner = Instance.new("UICorner")
    modalCorner.CornerRadius = UDim.new(0, 12)
    modalCorner.Parent = modal
    
    local modalStroke = Instance.new("UIStroke")
    modalStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    modalStroke.Color = colors.primary
    modalStroke.Thickness = 2
    modalStroke.Transparency = 0.7
    modalStroke.Parent = modal
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = colors.background
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 101
    titleBar.Parent = modal
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = colors.text
    titleText.TextSize = 16
    titleText.Font = FONT_BOLD
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.ZIndex = 102
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = colors.textSecondary
    closeButton.TextSize = 18
    closeButton.Font = FONT_REGULAR
    closeButton.ZIndex = 102
    closeButton.Parent = titleBar
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -70)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ZIndex = 101
    contentFrame.Parent = modal
    
    -- Добавление контента
    if type(content) == "string" then
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "ContentText"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = content
        textLabel.TextColor3 = colors.text
        textLabel.TextSize = 14
        textLabel.Font = FONT_REGULAR
        textLabel.TextWrapped = true
        textLabel.ZIndex = 102
        textLabel.Parent = contentFrame
    elseif type(content) == "function" then
        content(contentFrame)
    end
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -20, 0, 30)
    buttonContainer.Position = UDim2.new(0, 10, 1, -35)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ZIndex = 101
    buttonContainer.Parent = modal
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Parent = buttonContainer
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 10)
    
    -- Добавление кнопок
    for i, buttonConfig in ipairs(buttons or {}) do
        local button = Instance.new("TextButton")
        button.Name = buttonConfig.Text or "Button" .. i
        button.Size = UDim2.new(0, 80, 1, 0)
        button.BackgroundColor3 = buttonConfig.Color or colors.primary
        button.BorderSizePixel = 0
        button.Text = buttonConfig.Text or "Button " .. i
        button.TextColor3 = colors.text
        button.TextSize = 14
        button.Font = FONT_REGULAR
        button.ZIndex = 102
        button.AutoButtonColor = false
        button.LayoutOrder = i
        button.Parent = buttonContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        -- Анимации кнопки
        button.MouseEnter:Connect(function()
            createTween(button, {BackgroundColor3 = Color3.fromRGB(
                math.min(buttonConfig.Color.R * 255 + 20, 255) / 255,
                math.min(buttonConfig.Color.G * 255 + 20, 255) / 255,
                math.min(buttonConfig.Color.B * 255 + 20, 255) / 255
            )}, 0.2)
        end)
        
        button.MouseLeave:Connect(function()
            createTween(button, {BackgroundColor3 = buttonConfig.Color or colors.primary}, 0.2)
        end)
        
        button.MouseButton1Click:Connect(function()
            if buttonConfig.Callback then
                buttonConfig.Callback()
            end
            modal:Destroy()
        end)
    end
    
    -- Анимация появления
    modal.Size = UDim2.new(0, 10, 0, 10)
    modal.BackgroundTransparency = 1
    modal.Visible = true
    
    createTween(modal, {
        Size = UDim2.new(0, 400, 0, 200),
        BackgroundTransparency = 0
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Обработчик закрытия
    closeButton.MouseButton1Click:Connect(function()
        modal:Destroy()
    end)
    
    return {
        Frame = modal,
        Destroy = function()
            createTween(modal, {
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundTransparency = 1
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            wait(0.3)
            modal:Destroy()
        end
    }
end

return Library
