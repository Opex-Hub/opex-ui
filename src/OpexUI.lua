local OpexUI = {}
OpexUI.__index = OpexUI

local TweenService = game:GetService("TweenService")

local function tween(instance, goal, duration, style, direction)
    duration = duration or 0.18
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tweenObject = TweenService:Create(instance, tweenInfo, goal)
    tweenObject:Play()
    return tweenObject
end

local function makeCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
    return corner
end

local function makeStroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = 0.15
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

local function createButtonTheme(button)
    button.AutoButtonColor = false
    button.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    button.TextColor3 = Color3.fromRGB(226, 233, 248)
    button.Font = Enum.Font.GothamSemibold
end

local function createCreatorButton(parent)
    local button = Instance.new("TextButton")
    button.Name = "CreatorButton"
    button.Size = UDim2.new(0, 180, 0, 32)
    button.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    button.BorderSizePixel = 0
    button.Text = "creator: tu_papi"
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.TextColor3 = Color3.fromRGB(227, 235, 255)
    createButtonTheme(button)
    button.Parent = parent
    makeCorner(button, 12)
    makeStroke(button, Color3.fromRGB(92, 148, 255), 1.8)

    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 10, 1, 10)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundColor3 = Color3.fromRGB(78, 134, 255)
    glow.BorderSizePixel = 0
    glow.BackgroundTransparency = 0.72
    glow.Parent = button
    makeCorner(glow, 12)

    local dropdown = Instance.new("Frame")
    dropdown.Name = "CreatorDropdown"
    dropdown.Visible = false
    dropdown.Size = UDim2.new(0, 220, 0, 94)
    dropdown.Position = UDim2.new(1, 10, 1, 14)
    dropdown.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
    dropdown.BorderSizePixel = 0
    dropdown.Parent = parent
    makeCorner(dropdown, 14)
    makeStroke(dropdown, Color3.fromRGB(83, 139, 255), 1.4)

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment = Enum.VerticalAlignment.Center
    list.Parent = dropdown

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = "Creator Tools"
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(235, 241, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = dropdown

    local toggleHolder = Instance.new("Frame")
    toggleHolder.Size = UDim2.new(1, -20, 0, 26)
    toggleHolder.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    toggleHolder.BorderSizePixel = 0
    toggleHolder.Parent = dropdown
    makeCorner(toggleHolder, 10)
    makeStroke(toggleHolder, Color3.fromRGB(75, 126, 255), 1)

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -42, 1, 0)
    toggleLabel.Position = UDim2.new(0, 10, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "Enabled"
    toggleLabel.Font = Enum.Font.GothamSemibold
    toggleLabel.TextSize = 11
    toggleLabel.TextColor3 = Color3.fromRGB(234, 239, 255)
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleHolder

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 34, 0, 18)
    toggleButton.AnchorPoint = Vector2.new(1, 0.5)
    toggleButton.Position = UDim2.new(1, -10, 0.5, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(68, 122, 255)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = ""
    toggleButton.Parent = toggleHolder
    makeCorner(toggleButton, 9)

    local toggleDot = Instance.new("Frame")
    toggleDot.Size = UDim2.new(0, 12, 0, 12)
    toggleDot.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleDot.Position = UDim2.new(0.78, 0, 0.5, 0)
    toggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleDot.BorderSizePixel = 0
    toggleDot.Parent = toggleButton
    makeCorner(toggleDot, 100)

    local enabled = true

    local function refreshToggle()
        if enabled then
            toggleButton.BackgroundColor3 = Color3.fromRGB(68, 122, 255)
            tween(toggleDot, { Position = UDim2.new(0.78, 0, 0.5, 0) }, 0.18)
            toggleLabel.Text = "Enabled"
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(41, 41, 42)
            tween(toggleDot, { Position = UDim2.new(0.2, 0, 0.5, 0) }, 0.18)
            toggleLabel.Text = "Disabled"
        end
    end

    button.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
    end)

    toggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        refreshToggle()
    end)

    refreshToggle()
    return button, dropdown
end

local function createTabButton(parent, text, index, callback)
    local button = Instance.new("TextButton")
    button.Name = text .. "Tab"
    button.Size = UDim2.new(0, 150, 1, 0)
    button.Position = UDim2.new(0, index * 150, 0, 0)
    button.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    button.BorderSizePixel = 0
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.TextColor3 = Color3.fromRGB(220, 228, 240)
    button.AutoButtonColor = false
    button.Parent = parent
    makeCorner(button, 8)
    makeStroke(button, Color3.fromRGB(74, 119, 255), 1)

    button.MouseEnter:Connect(function()
        tween(button, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) }, 0.12)
    end)

    button.MouseLeave:Connect(function()
        tween(button, { BackgroundColor3 = Color3.fromRGB(18, 18, 18) }, 0.12)
    end)

    button.MouseButton1Click:Connect(function()
        callback(button)
    end)

    return button
end

local function createWindow(options)
    options = options or {}

    local playerGui = options.Parent or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = options.Name or "OpexUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    local root = Instance.new("Frame")
    root.Name = "Window"
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.Size = options.Size or UDim2.fromOffset(760, 430)
    root.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    root.BorderSizePixel = 0
    root.Parent = screenGui
    makeCorner(root, 18)
    makeStroke(root, Color3.fromRGB(86, 140, 255), 2)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 72)
    header.BackgroundColor3 = Color3.fromRGB(13, 13, 14)
    header.BorderSizePixel = 0
    header.Parent = root

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 180, 0, 24)
    title.Position = UDim2.new(0, 18, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = (options.Name or "OPEXUI"):upper()
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(236, 242, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local creatorButton, dropdown = createCreatorButton(header)
    creatorButton.Position = UDim2.new(1, -200, 0, 18)

    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "Tabs"
    tabsContainer.Size = UDim2.new(1, -24, 0, 58)
    tabsContainer.Position = UDim2.new(0, 12, 0, 84)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 19)
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = root
    makeCorner(tabsContainer, 12)
    makeStroke(tabsContainer, Color3.fromRGB(80, 130, 255), 1.2)

    local tabButtons = Instance.new("Frame")
    tabButtons.Name = "Buttons"
    tabButtons.Size = UDim2.new(1, -12, 1, -10)
    tabButtons.Position = UDim2.new(0, 6, 0, 5)
    tabButtons.BackgroundTransparency = 1
    tabButtons.Parent = tabsContainer

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -150)
    content.Position = UDim2.new(0, 10, 0, 150)
    content.BackgroundColor3 = Color3.fromRGB(15, 15, 16)
    content.BorderSizePixel = 0
    content.Parent = root
    makeCorner(content, 14)
    makeStroke(content, Color3.fromRGB(82, 135, 255), 1.2)

    local window = {}
    local tabs = {}

    local function setActiveTab(name)
        for _, tab in ipairs(tabs) do
            local selected = tab.Name == name
            local button = tab.Button
            local panel = tab.Panel

            if selected then
                button.BackgroundColor3 = Color3.fromRGB(72, 122, 255)
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                tween(button, { BackgroundColor3 = Color3.fromRGB(72, 122, 255) }, 0.12)
                panel.Visible = true
                panel.BackgroundTransparency = 0
                tween(panel, { BackgroundTransparency = 0 }, 0.18)
            else
                button.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                button.TextColor3 = Color3.fromRGB(220, 228, 240)
                panel.Visible = false
            end
        end
    end

    function window:AddTab(name)
        local panel = Instance.new("Frame")
        panel.Name = name .. "Panel"
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
        panel.BorderSizePixel = 0
        panel.Visible = false
        panel.Parent = content
        makeCorner(panel, 12)

        local button = createTabButton(tabButtons, name, #tabs, function()
            setActiveTab(name)
        end)

        table.insert(tabs, {
            Name = name,
            Button = button,
            Panel = panel,
        })

        if #tabs == 1 then
            setActiveTab(name)
        end

        return panel
    end

    function window:SetActiveTab(name)
        setActiveTab(name)
    end

    function window:Destroy()
        screenGui:Destroy()
    end

    return window
end

function OpexUI.new(options)
    return createWindow(options)
end

return OpexUI
