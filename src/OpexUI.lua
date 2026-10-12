local OpexUI = {}
OpexUI.__index = OpexUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Small helpers
local function tween(instance, goal, duration, style, direction)
    duration = duration or 0.2
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

local function makeStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(80, 140, 255)
    stroke.Thickness = thickness or 1.4
    stroke.Transparency = transparency or 0.05
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

local function makeGlow(parent, color, size, transparency)
    -- glow is a blurred frame sitting behind the parent element
    local glow = Instance.new("Frame")
    glow.Name = "_Glow"
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Size = UDim2.new(1, size or 20, 1, size or 20)
    glow.Position = UDim2.new(0.5, 0.5, 0.5, 0)
    glow.BackgroundColor3 = color or Color3.fromRGB(80, 140, 255)
    glow.BorderSizePixel = 0
    glow.ZIndex = (parent.ZIndex or 1) - 1
    glow.BackgroundTransparency = transparency or 0.8
    glow.Parent = parent
    makeCorner(glow, math.huge)

    -- subtle gradient for nicer neon
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, (color or Color3.fromRGB(80,140,255)) ),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    }
    grad.Rotation = 45
    grad.Parent = glow

    return glow
end

-- Draggable window helper
local function makeDraggable(root, dragHandle)
    dragHandle = dragHandle or root
    local dragging = false
    local dragStart
    local startPos
    local rootStart
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        -- smooth follow
        root.Position = newPos
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            local absPos = root.AbsolutePosition
            startPos = Vector2.new(absPos.X, absPos.Y)
            rootStart = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            RunService:BindToRenderStep("opexui_drag", Enum.RenderPriority.Camera.Value, function()
                if dragging then
                    local mousePos = UserInputService:GetMouseLocation()
                    local delta = mousePos - dragStart
                    local newX = startPos.X + delta.X
                    local newY = startPos.Y + delta.Y
                    root.Position = UDim2.new(0, newX, 0, newY)
                else
                    RunService:UnbindFromRenderStep("opexui_drag")
                end
            end)
        end
    end)
end

-- Component factories
local function createButton(text, parent, onClick)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
    btn.BorderSizePixel = 0
    btn.Text = text or "Button"
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(235, 241, 255)
    btn.AutoButtonColor = false
    btn.Parent = parent
    makeCorner(btn, 8)
    makeStroke(btn, Color3.fromRGB(90, 160, 255), 1)

    btn.MouseEnter:Connect(function()
        tween(btn, { BackgroundColor3 = Color3.fromRGB(30, 30, 34) }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, { BackgroundColor3 = Color3.fromRGB(20, 20, 22) }, 0.12)
    end)

    btn.MouseButton1Click:Connect(function()
        if onClick then pcall(onClick) end
    end)

    return btn
end

local function createLabel(text, parent)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or "Label"
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(220, 228, 240)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function createToggle(text, parent, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    makeCorner(holder, 8)
    makeStroke(holder, Color3.fromRGB(80, 140, 255), 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(230, 236, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Position = UDim2.new(1, -12, 0.5, 0)
    toggle.BackgroundColor3 = default and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(48, 48, 50)
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = holder
    makeCorner(toggle, 10)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = default and UDim2.new(0.78, 0, 0.5, 0) or UDim2.new(0.22, 0, 0.5, 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    makeCorner(dot, 100)

    local state = default or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            tween(dot, { Position = UDim2.new(0.78, 0, 0.5, 0) }, 0.18)
            tween(toggle, { BackgroundColor3 = Color3.fromRGB(80, 150, 255) }, 0.18)
        else
            tween(dot, { Position = UDim2.new(0.22, 0, 0.5, 0) }, 0.18)
            tween(toggle, { BackgroundColor3 = Color3.fromRGB(48, 48, 50) }, 0.18)
        end
        if callback then pcall(callback, state) end
    end)

    return holder, function() return state end
end

local function createSlider(text, parent, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 40)
    holder.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    makeCorner(holder, 8)
    makeStroke(holder, Color3.fromRGB(80, 140, 255), 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 0, 18)
    label.Position = UDim2.new(0, 6, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = (text or "Slider") .. "   " .. tostring(default)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(225, 232, 248)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 8)
    track.Position = UDim2.new(0, 12, 0, 24)
    track.BackgroundColor3 = Color3.fromRGB(36, 36, 38)
    track.BorderSizePixel = 0
    track.Parent = holder
    makeCorner(track, 6)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(((default - (min or 0)) / ((max or 100) - (min or 0))), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    makeCorner(fill, 6)

    local dragging = false
    local function updateFill(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        local value = math.floor(((min or 0) + rel * ((max or 100) - (min or 0))) * 100) / 100
        label.Text = (text or "Slider") .. "   " .. tostring(value)
        if callback then pcall(callback, value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFill(input)
        end
    end)
    track.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFill(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return holder
end

local function createDropdown(labelText, parent, options, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 32)
    holder.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    makeCorner(holder, 8)
    makeStroke(holder, Color3.fromRGB(80,140,255), 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -36, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText or "Select"
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(225,232,248)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local caret = Instance.new("TextButton")
    caret.Size = UDim2.new(0, 26, 0, 26)
    caret.AnchorPoint = Vector2.new(1, 0.5)
    caret.Position = UDim2.new(1, -6, 0.5, 0)
    caret.Text = ">"
    caret.Font = Enum.Font.GothamBold
    caret.TextSize = 14
    caret.AutoButtonColor = false
    caret.BackgroundColor3 = Color3.fromRGB(30,30,32)
    caret.BorderSizePixel = 0
    caret.Parent = holder
    makeCorner(caret, 8)

    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0, 180, 0, #options * 28 + 8)
    dropdown.Position = UDim2.new(0, 0, 1, 6)
    dropdown.BackgroundColor3 = Color3.fromRGB(14,14,16)
    dropdown.BorderSizePixel = 0
    dropdown.Visible = false
    dropdown.Parent = holder
    makeCorner(dropdown, 8)
    makeStroke(dropdown, Color3.fromRGB(80,140,255), 1)

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.Parent = dropdown

    for i, opt in ipairs(options) do
        local item = Instance.new("TextButton")
        item.BackgroundTransparency = 0
        item.BackgroundColor3 = Color3.fromRGB(20,20,22)
        item.BorderSizePixel = 0
        item.Size = UDim2.new(1, -12, 0, 24)
        item.Position = UDim2.new(0, 6, 0, (i-1)*28 + 6)
        item.Text = opt
        item.Font = Enum.Font.Gotham
        item.TextSize = 13
        item.TextColor3 = Color3.fromRGB(230,235,255)
        item.Parent = dropdown
        makeCorner(item, 6)
        makeStroke(item, Color3.fromRGB(76,130,255), 0.8)

        item.MouseButton1Click:Connect(function()
            label.Text = opt
            dropdown.Visible = false
            if callback then pcall(callback, opt) end
        end)
    end

    caret.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
    end)

    return holder
end

-- Window creation
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
    root.Position = options.Position or UDim2.new(0.5, 0, 0.5, 0)
    root.Size = options.Size or UDim2.fromOffset(760, 430)
    root.BackgroundColor3 = Color3.fromRGB(10,10,12)
    root.BorderSizePixel = 0
    root.Parent = screenGui
    makeCorner(root, 16)
    makeStroke(root, Color3.fromRGB(92,160,255), 2)
    makeGlow(root, Color3.fromRGB(80,150,255), 24, 0.9)

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 72)
    header.BackgroundColor3 = Color3.fromRGB(14,14,16)
    header.BorderSizePixel = 0
    header.Parent = root
    makeCorner(header, 12)

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0, 220, 0, 28)
    title.Position = UDim2.new(0, 18, 0, 22)
    title.BackgroundTransparency = 1
    title.Text = (options.Name or "OPEXUI"):upper()
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(240,246,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    -- Creator button + dropdown (reuse previous factory)
    local function createCreator(parent)
        local btn, dd = nil, nil
        btn, dd = (function(p)
            local b, d = nil, nil
            b, d = (function(parentFrame)
                -- reuse createCreatorButton logic but simpler
                local creatorBtn = Instance.new("TextButton")
                creatorBtn.Name = "CreatorButton"
                creatorBtn.Size = UDim2.new(0, 180, 0, 32)
                creatorBtn.BackgroundColor3 = Color3.fromRGB(20,20,22)
                creatorBtn.BorderSizePixel = 0
                creatorBtn.Text = "creator: tu_papi"
                creatorBtn.Font = Enum.Font.GothamBold
                creatorBtn.TextSize = 12
                creatorBtn.TextColor3 = Color3.fromRGB(230,236,255)
                creatorBtn.AutoButtonColor = false
                creatorBtn.Parent = parentFrame
                makeCorner(creatorBtn, 12)
                makeStroke(creatorBtn, Color3.fromRGB(100,170,255), 1.8)
                makeGlow(creatorBtn, Color3.fromRGB(90,170,255), 12, 0.85)

                local dropdown = Instance.new("Frame")
                dropdown.Name = "CreatorDropdown"
                dropdown.Visible = false
                dropdown.Size = UDim2.new(0, 220, 0, 96)
                dropdown.Position = UDim2.new(1, 12, 1, 10)
                dropdown.BackgroundColor3 = Color3.fromRGB(14,14,16)
                dropdown.BorderSizePixel = 0
                dropdown.Parent = parentFrame
                makeCorner(dropdown, 12)
                makeStroke(dropdown, Color3.fromRGB(90,170,255), 1.2)

                local list = Instance.new("UIListLayout")
                list.Padding = UDim.new(0, 8)
                list.Parent = dropdown

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -20, 0, 18)
                label.BackgroundTransparency = 1
                label.Text = "creator: tu_papi"
                label.Font = Enum.Font.GothamSemibold
                label.TextSize = 12
                label.TextColor3 = Color3.fromRGB(245, 248, 255)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = dropdown

                local toggleHolder, getState = createToggle("Library Enabled", dropdown, true, function() end)
                toggleHolder.Parent = dropdown

                creatorBtn.MouseButton1Click:Connect(function()
                    dropdown.Visible = not dropdown.Visible
                end)

                return creatorBtn, dropdown
            end)(parentFrame)
            return b, d
        end)(parent)
        return btn, dd
    end

    local creatorBtn, creatorDD = createCreator(header)
    creatorBtn.Position = UDim2.new(1, -200, 0, 20)

    -- Tabs container
    local tabsWrapper = Instance.new("Frame")
    tabsWrapper.Name = "TabsWrapper"
    tabsWrapper.Size = UDim2.new(1, -28, 0, 64)
    tabsWrapper.Position = UDim2.new(0, 14, 0, 86)
    tabsWrapper.BackgroundTransparency = 1
    tabsWrapper.Parent = root

    local tabsBg = Instance.new("Frame")
    tabsBg.Size = UDim2.new(1, 0, 1, 0)
    tabsBg.BackgroundColor3 = Color3.fromRGB(18,18,20)
    tabsBg.BorderSizePixel = 0
    tabsBg.Parent = tabsWrapper
    makeCorner(tabsBg, 12)
    makeStroke(tabsBg, Color3.fromRGB(86,140,255), 1.2)

    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -12, 1, -12)
    buttonsFrame.Position = UDim2.new(0, 6, 0, 6)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = tabsBg

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -28, 1, -170)
    contentArea.Position = UDim2.new(0, 14, 0, 170)
    contentArea.BackgroundColor3 = Color3.fromRGB(14,14,16)
    contentArea.BorderSizePixel = 0
    contentArea.Parent = root
    makeCorner(contentArea, 14)
    makeStroke(contentArea, Color3.fromRGB(88,150,255), 1.2)
    makeGlow(contentArea, Color3.fromRGB(80,150,255), 26, 0.9)

    -- API table returned to user
    local window = {}
    window._tabs = {}

    -- Create draggable functionality
    makeDraggable(root, header)

    -- Tab logic with premium transitions
    local function createTab(name)
        local panel = Instance.new("Frame")
        panel.Name = name .. "Panel"
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.Position = UDim2.new(1, 0, 0, 0) -- start off-screen to the right
        panel.BackgroundColor3 = Color3.fromRGB(16,16,18)
        panel.BorderSizePixel = 0
        panel.Parent = contentArea
        makeCorner(panel, 12)

        local btn = Instance.new("TextButton")
        btn.Name = name .. "Btn"
        btn.Size = UDim2.new(0, 160, 1, -4)
        btn.Position = UDim2.new(0, (#window._tabs) * 164, 0, 2)
        btn.BackgroundColor3 = Color3.fromRGB(18,18,20)
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(220,228,240)
        btn.AutoButtonColor = false
        btn.Parent = buttonsFrame
        makeCorner(btn, 8)
        makeStroke(btn, Color3.fromRGB(90,150,255), 1)

        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundColor3 = Color3.fromRGB(28,28,30) }, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundColor3 = Color3.fromRGB(18,18,20) }, 0.12)
        end)

        return { Name = name, Button = btn, Panel = panel }
    end

    local activeTab = nil
    local function setActiveTab(name)
        if activeTab == name then return end
        local target = nil
        for _, t in ipairs(window._tabs) do
            if t.Name == name then target = t end
        end
        if not target then return end

        -- animate all tabs out/in
        for _, t in ipairs(window._tabs) do
            if t.Name == name then
                t.Button.TextColor3 = Color3.fromRGB(255,255,255)
                tween(t.Button, { BackgroundColor3 = Color3.fromRGB(66,120,255) }, 0.14)
                t.Panel.Position = UDim2.new(1, 0, 0, 0)
                t.Panel.Visible = true
                tween(t.Panel, { Position = UDim2.new(0,0,0,0) }, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                tween(t.Panel, { BackgroundTransparency = 0 }, 0.26)
            else
                t.Button.TextColor3 = Color3.fromRGB(220,228,240)
                tween(t.Button, { BackgroundColor3 = Color3.fromRGB(18,18,20) }, 0.12)
                if t.Panel.Visible then
                    tween(t.Panel, { Position = UDim2.new(-1, 0, 0, 0) }, 0.24)
                    delay(0.24, function()
                        t.Panel.Visible = false
                        t.Panel.Position = UDim2.new(1,0,0,0)
                    end)
                end
            end
        end
        activeTab = name
    end

    function window:AddTab(name)
        local tab = createTab(name)
        table.insert(window._tabs, tab)

        tab.Button.MouseButton1Click:Connect(function()
            setActiveTab(name)
        end)

        -- return panel as the container where devs can add UI
        return tab.Panel
    end

    -- Components API exposed on the window
    function window:CreateSection(parent, title)
        parent = parent or contentArea
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, -24, 0, 120)
        section.BackgroundColor3 = Color3.fromRGB(18,18,20)
        section.BorderSizePixel = 0
        section.Parent = parent
        makeCorner(section, 12)
        makeStroke(section, Color3.fromRGB(86,140,255), 1)
        makeGlow(section, Color3.fromRGB(75,140,255), 18, 0.92)

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, -24, 0, 28)
        header.Position = UDim2.new(0, 12, 0, 8)
        header.BackgroundTransparency = 1
        header.Text = title or "Section"
        header.Font = Enum.Font.GothamSemibold
        header.TextSize = 14
        header.TextColor3 = Color3.fromRGB(240,246,255)
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = section

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -24, 1, -44)
        content.Position = UDim2.new(0, 12, 0, 40)
        content.BackgroundTransparency = 1
        content.Parent = section

        return section, content
    end

    function window:CreateButton(text, parent, onClick)
        parent = parent or contentArea
        return createButton(text, parent, onClick)
    end

    function window:CreateLabel(text, parent)
        parent = parent or contentArea
        return createLabel(text, parent)
    end

    function window:CreateToggle(text, parent, default, callback)
        parent = parent or contentArea
        return createToggle(text, parent, default, callback)
    end

    function window:CreateSlider(text, parent, min, max, default, callback)
        parent = parent or contentArea
        return createSlider(text, parent, min, max, default, callback)
    end

    function window:CreateDropdown(text, parent, options, callback)
        parent = parent or contentArea
        return createDropdown(text, parent, options or {}, callback)
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
