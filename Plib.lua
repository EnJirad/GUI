-- Pixellib.lua: A modern, modular, and efficient GUI library for Roblox
-- Version: 2.0
-- Author: Optimized by Grok for enhanced performance and readability

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Constants
local DEFAULT_COLOR = Color3.fromRGB(0, 132, 255)
local DEFAULT_SIZE = UDim2.fromOffset(550, 315)
local DEFAULT_TAB_WIDTH = 120
local SHADOW_ASSET = "rbxassetid://6015897843"
local CLOSE_ICON = "rbxassetid://9886659671"
local MINIMIZE_ICON = "rbxassetid://9886659276"
local COLLAPSE_ICON = "rbxassetid://16851841101"

-- Utility Functions
local function createInstance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function cacheService(serviceName)
    return game:GetService(serviceName)
end

-- Anti-AFK System
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Toggle Button Creation
local function createToggleButton()
    local screenGui = createInstance("ScreenGui", {
        Name = "ToggleGui",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or cacheService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local toggleButton = createInstance("ImageButton", {
        Parent = screenGui,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderColor3 = Color3.fromRGB(255, 0, 0),
        Position = UDim2.new(0.1, 0, 0.1, 0),
        Size = UDim2.new(0, 50, 0, 50),
        Image = "rbxassetid://98540636959380",
        Visible = false
    })

    createInstance("UICorner", {
        Name = "ButtonCorner",
        CornerRadius = UDim.new(0, 9),
        Parent = toggleButton
    })

    local isDragging = false
    local dragStart, startPos

    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = toggleButton.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    })

    toggleButton.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return toggleButton
end

-- Drag and Resize Functionality
local function enableDragAndResize(topBar, frame)
    local function enableDragging()
        local isDragging = false
        local dragStart, startPos

        topBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isDragging = false
                    end
                end)
            end
        end)

        topBar.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local function enableResizing()
        local minWidth = math.max(400, frame.Size.X.Offset)
        local minHeight = minWidth - 100
        frame.Size = UDim2.new(0, minWidth, 0, minHeight)

        local resizeCorner = createInstance("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.999,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 20, 1, 20),
            Size = UDim2.new(0, 40, 0, 40),
            Name = "ResizeCorner",
            Parent = frame
        })

        local isResizing = false
        local resizeStart

        resizeCorner.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isResizing = true
                resizeStart = input.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        isResizing = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                local newWidth = math.max(minWidth, frame.Size.X.Offset + delta.X)
                local newHeight = math.max(minHeight, frame.Size.Y.Offset + delta.Y)
                TweenService:Create(frame, TweenInfo.new(0.2), {
                    Size = UDim2.new(0, newWidth, 0, newHeight)
                }):Play()
            end
        end)
    end

    enableDragging()
    enableResizing()
end

-- Circle Click Effect
local function createCircleEffect(target, x, y)
    coroutine.wrap(function()
        target.ClipsDescendants = true
        local circle = createInstance("ImageLabel", {
            Image = "rbxassetid://266543268",
            ImageColor3 = Color3.fromRGB(80, 80, 80),
            ImageTransparency = 0.9,
            BackgroundTransparency = 1,
            ZIndex = 10,
            Name = "ClickEffect",
            Parent = target
        })

        local offsetX = x - target.AbsolutePosition.X
        local offsetY = y - target.AbsolutePosition.Y
        circle.Position = UDim2.new(0, offsetX, 0, offsetY)
        local size = math.max(target.AbsoluteSize.X, target.AbsoluteSize.Y) * 1.5

        circle:TweenSizeAndPosition(
            UDim2.new(0, size, 0, size),
            UDim2.new(0.5, -size / 2, 0.5, -size / 2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.5,
            false
        )

        for i = 1, 10 do
            circle.ImageTransparency = circle.ImageTransparency + 0.01
            task.wait(0.05)
        end
        circle:Destroy()
    end)()
end

-- PixelLib Library
local PixelLib = { IsUnloaded = false }

-- Notification System
function PixelLib:CreateNotification(options)
    local notify = options or {}
    notify.Title = notify.Title or "PixelHub"
    notify.Description = notify.Description or "Notification"
    notify.Content = notify.Content or "Content"
    notify.Color = notify.Color or Color3.fromRGB(255, 0, 255)
    notify.Duration = notify.Duration or 0.5
    notify.Delay = notify.Delay or 5

    local NotifyControls = {}

    coroutine.wrap(function()
        local coreGui = cacheService("CoreGui")
        local notifyGui = coreGui:FindFirstChild("NotifyGui") or createInstance("ScreenGui", {
            Name = "NotifyGui",
            Parent = coreGui,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })

        local notifyContainer = notifyGui:FindFirstChild("NotifyContainer") or createInstance("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 1, -30),
            Size = UDim2.new(0, 320, 1, 0),
            Name = "NotifyContainer",
            Parent = notifyGui
        })

        local index = 0
        notifyContainer.ChildRemoved:Connect(function()
            index = 0
            for _, child in ipairs(notifyContainer:GetChildren()) do
                if child:IsA("Frame") then
                    TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                        Position = UDim2.new(0, 0, 1, -((child.Size.Y.Offset + 12) * index))
                    }):Play()
                    index = index + 1
                end
            end
        end)

        local offsetY = 0
        for _, child in ipairs(notifyContainer:GetChildren()) do
            if child:IsA("Frame") then
                offsetY = -child.Position.Y.Offset + child.Size.Y.Offset + 12
            end
        end

        local notifyFrame = createInstance("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 150),
            Name = "NotifyFrame",
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -offsetY),
            Parent = notifyContainer
        })

        local notifyContent = createInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 400, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Name = "NotifyContent",
            Parent = notifyFrame
        })

        createInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = notifyContent })

        local shadowHolder = createInstance("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 0,
            Name = "ShadowHolder",
            Parent = notifyContent
        })

        createInstance("ImageLabel", {
            Image = SHADOW_ASSET,
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 47, 1, 47),
            ZIndex = 0,
            Name = "DropShadow",
            Parent = shadowHolder
        })

        local topBar = createInstance("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Name = "TopBar",
            Parent = notifyContent
        })

        local titleLabel = createInstance("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = notify.Title,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Parent = topBar
        })

        createInstance("UIStroke", {
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 0.3,
            Parent = titleLabel
        })

        createInstance("UICorner", { CornerRadius = UDim.new(0, 5), Parent = topBar })

        local descLabel = createInstance("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = notify.Description,
            TextColor3 = notify.Color,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, titleLabel.TextBounds.X + 15, 0, 0),
            Parent = topBar
        })

        createInstance("UIStroke", {
            Color = notify.Color,
            Thickness = 0.4,
            Parent = descLabel
        })

        local closeButton = createInstance("TextButton", {
            Font = Enum.Font.SourceSans,
            Text = "",
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 14,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -5, 0.5, 0),
            Size = UDim2.new(0, 25, 0, 25),
            Name = "CloseButton",
            Parent = topBar
        })

        createInstance("ImageLabel", {
            Image = CLOSE_ICON,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, -8, 1, -8),
            Parent = closeButton
        })

        local contentLabel = createInstance("TextLabel", {
            Font = Enum.Font.GothamBold,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 13,
            Text = notify.Content,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0, 27),
            Size = UDim2.new(1, -20, 0, 13),
            TextWrapped = true,
            Parent = notifyContent
        })

        contentLabel.Size = UDim2.new(1, -20, 0, 13 + (13 * math.ceil(contentLabel.TextBounds.X / contentLabel.AbsoluteSize.X)))
        notifyFrame.Size = UDim2.new(1, 0, 0, contentLabel.AbsoluteSize.Y < 27 and 65 or contentLabel.AbsoluteSize.Y + 40)

        local isClosing = false
        function NotifyControls:Close()
            if isClosing then return end
            isClosing = true
            TweenService:Create(notifyContent, TweenInfo.new(notify.Duration, Enum.EasingStyle.Back), {
                Position = UDim2.new(0, 400, 0, 0)
            }):Play()
            task.wait(notify.Duration)
            notifyFrame:Destroy()
        end

        closeButton.Activated:Connect(function()
            NotifyControls:Close()
        end)

        TweenService:Create(notifyContent, TweenInfo.new(notify.Duration, Enum.EasingStyle.Back), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(notify.Delay)
        NotifyControls:Close()
    end)()

    return NotifyControls
end

-- Main GUI Creation
function PixelLib:CreateGui(config)
    local guiConfig = config or {}
    guiConfig.NameHub = guiConfig.NameHub or "PixelHub"
    guiConfig.Description = guiConfig.Description or ""
    guiConfig.Color = guiConfig.Color or DEFAULT_COLOR
    guiConfig.TabWidth = guiConfig.TabWidth or DEFAULT_TAB_WIDTH
    guiConfig.SizeUI = guiConfig.SizeUI or DEFAULT_SIZE

    local GuiControls = {}
    local toggleButton = createToggleButton()

    local mainGui = createInstance("ScreenGui", {
        Name = "PixelHubGui",
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or cacheService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local shadowHolder = createInstance("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = guiConfig.SizeUI,
        ZIndex = 0,
        Name = "ShadowHolder",
        Parent = mainGui,
        Position = UDim2.new(0.5, -guiConfig.SizeUI.X.Offset / 2, 0.5, -guiConfig.SizeUI.Y.Offset / 2)
    })

    local dropShadow = createInstance("ImageLabel", {
        Image = SHADOW_ASSET,
        ImageColor3 = Color3.fromRGB(15, 15, 15),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = guiConfig.SizeUI,
        ZIndex = 0,
        Name = "DropShadow",
        Parent = shadowHolder
    })

    local mainFrame = createInstance("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = guiConfig.SizeUI,
        Name = "MainFrame",
        Parent = dropShadow
    })

    createInstance("UICorner", { Parent = mainFrame })

    createInstance("UIStroke", {
        Color = Color3.fromRGB(50, 50, 50),
        Thickness = 1.6,
        Parent = mainFrame
    })

    local topBar = createInstance("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Name = "TopBar",
        Parent = mainFrame
    })

    local titleLabel = createInstance("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = guiConfig.NameHub,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = topBar
    })

    createInstance("UICorner", { Parent = topBar })

    local descLabel = createInstance("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = guiConfig.Description,
        TextColor3 = guiConfig.Color,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -(titleLabel.TextBounds.X + 104), 1, 0),
        Position = UDim2.new(0, titleLabel.TextBounds.X + 15, 0, 0),
        Parent = topBar
    })

    createInstance("UIStroke", {
        Color = guiConfig.Color,
        Thickness = 0.4,
        Parent = descLabel
    })

    local closeButton = createInstance("TextButton", {
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 25, 0, 25),
        Name = "CloseButton",
        Parent = topBar
    })

    createInstance("ImageLabel", {
        Image = CLOSE_ICON,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -8, 1, -8),
        Parent = closeButton
    })

    local minimizeButton = createInstance("TextButton", {
        Font = Enum.Font.SourceSans,
        Text = "",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 14,
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -42, 0.5, 0),
        Size = UDim2.new(0, 25, 0, 25),
        Name = "MinimizeButton",
        Parent = topBar
    })

    createInstance("ImageLabel", {
        Image = MINIMIZE_ICON,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -8, 1, -8),
        Parent = minimizeButton
    })

    local tabContainer = createInstance("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 9, 0, 50),
        Size = UDim2.new(0, guiConfig.TabWidth, 1, -59),
        Name = "TabContainer",
        Parent = mainFrame
    })

    createInstance("UICorner", { CornerRadius = UDim.new(0, 2), Parent = tabContainer })

    createInstance("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 1),
        Name = "TabDivider",
        Parent = mainFrame
    })

    local contentContainer = createInstance("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, guiConfig.TabWidth + 18, 0, 50),
        Size = UDim2.new(1, -(guiConfig.TabWidth + 27), 1, -59),
        Name = "ContentContainer",
        Parent = mainFrame
    })

    createInstance("UICorner", { CornerRadius = UDim.new(0, 2), Parent = contentContainer })

    local tabTitle = createInstance("TextLabel", {
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Name = "TabTitle",
        Parent = contentContainer
    })

    local contentFrame = createInstance("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 1, -33),
        Name = "ContentFrame",
        Parent = contentContainer
    })

    local tabPages = createInstance("Folder", {
        Name = "TabPages",
        Parent = contentFrame
    })

    createInstance("UIPageLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Name = "PageLayout",
        Parent = tabPages,
        TweenTime = 0.5,
        EasingDirection = Enum.EasingDirection.InOut,
        EasingStyle = Enum.EasingStyle.Quad
    })

    local tabList = createInstance("ScrollingFrame", {
        CanvasSize = UDim2.new(0, 0, 1.1, 0),
        ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
        ScrollBarThickness = 0,
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -10),
        Name = "TabList",
        Parent = tabContainer
    })

    local tabLayout = createInstance("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList
    })

    local function updateTabCanvas()
        local totalHeight = 0
        for _, child in ipairs(tabList:GetChildren()) do
            if child:IsA("Frame") then
                totalHeight = totalHeight + child.Size.Y.Offset + tabLayout.Padding.Offset
            end
        end
        tabList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end

    tabList.ChildAdded:Connect(updateTabCanvas)
    tabList.ChildRemoved:Connect(updateTabCanvas)

    function GuiControls:DestroyGui()
        if mainGui then
            mainGui:Destroy()
            PixelLib.IsUnloaded = true
        end
    end

    minimizeButton.Activated:Connect(function()
        createCircleEffect(minimizeButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        shadowHolder.Visible = false
        toggleButton.Visible = true
    end)

    toggleButton.Activated:Connect(function()
        shadowHolder.Visible = true
        toggleButton.Visible = false
    end)

    closeButton.Activated:Connect(function()
        createCircleEffect(closeButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        GuiControls:DestroyGui()
    end)

    enableDragAndResize(topBar, shadowHolder)

    local TabControls = {}
    local tabIndex = 0

    function TabControls:CreateTab(tabConfig)
        local tab = tabConfig or {}
        tab.Name = tab.Name or "Tab"
        tab.Icon = tab.Icon or ""

        local tabContent = createInstance("ScrollingFrame", {
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
            ScrollBarThickness = 4,
            Active = true,
            LayoutOrder = tabIndex,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Name = "TabContent",
            Parent = tabPages
        })

        local contentLayout = createInstance("UIListLayout", {
            Padding = UDim.new(0, 3),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = tabContent
        })

        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y)
        end)

        local tabButtonFrame = createInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = tabIndex == 0 and 0.92 or 0.999,
            BorderSizePixel = 0,
            LayoutOrder = tabIndex,
            Size = UDim2.new(1, 0, 0, 30),
            Name = "TabButtonFrame",
            Parent = tabList
        })

        createInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = tabButtonFrame })

        local tabButton = createInstance("TextButton", {
            Font = Enum.Font.GothamBold,
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Name = "TabButton",
            Parent = tabButtonFrame
        })

        local tabLabel = createInstance("TextLabel", {
            Font = Enum.Font.GothamBold,
            Text = tab.Name,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            Name = "TabLabel",
            Parent = tabButtonFrame
        })

        createInstance("ImageLabel", {
            Image = tab.Icon,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 9, 0, 7),
            Size = UDim2.new(0, 16, 0, 16),
            Name = "TabIcon",
            Parent = tabButtonFrame
        })

        if tabIndex == 0 then
            tabPages.PageLayout:JumpToIndex(0)
            tabTitle.Text = tab.Name
            local tabIndicator = createInstance("Frame", {
                BackgroundColor3 = guiConfig.Color,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 2, 0, 9),
                Size = UDim2.new(0, 1, 0, 12),
                Name = "TabIndicator",
                Parent = tabButtonFrame
            })

            createInstance("UIStroke", {
                Color = guiConfig.Color,
                Thickness = 1.6,
                Parent = tabIndicator
            })

            createInstance("UICorner", { Parent = tabIndicator })
        end

        tabButton.Activated:Connect(function()
            createCircleEffect(tabButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
            local currentIndicator = tabList:FindFirstChildOfClass("Frame"):FindFirstChild("TabIndicator")
            if currentIndicator and tabButtonFrame.LayoutOrder ~= tabPages.PageLayout.CurrentPage.LayoutOrder then
                for _, tabFrame in ipairs(tabList:GetChildren()) do
                    if tabFrame:IsA("Frame") then
                        TweenService:Create(tabFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                            BackgroundTransparency = 0.999
                        }):Play()
                    end
                end
                TweenService:Create(tabButtonFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                    BackgroundTransparency = 0.92
                }):Play()
                TweenService:Create(currentIndicator, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 2, 0, 9 + (33 * tabButtonFrame.LayoutOrder))
                }):Play()
                tabPages.PageLayout:JumpToIndex(tabButtonFrame.LayoutOrder)
                tabTitle.Text = tab.Name
                TweenService:Create(currentIndicator, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 1, 0, 20)
                }):Play()
                task.wait(0.2)
                TweenService:Create(currentIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0, 1, 0, 12)
                }):Play()
            end
        end)

        local SectionControls = {}
        local sectionIndex = 0

        function SectionControls:AddSection(title, collapsible)
            local sectionTitle = title or "Section"
            local isCollapsible = collapsible or false

            local sectionFrame = createInstance("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = sectionIndex,
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 0, 30),
                Name = "SectionFrame",
                Parent = tabContent
            })

            local sectionHeader = createInstance("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.935,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0, 0),
                Size = UDim2.new(1, 1, 0, 30),
                Name = "SectionHeader",
                Parent = sectionFrame
            })

            createInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sectionHeader })

            local headerButton = createInstance("TextButton", {
                Font = Enum.Font.SourceSans,
                Text = "",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 14,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                Name = "HeaderButton",
                Parent = sectionHeader
            })

            local collapseIconFrame = createInstance("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -5, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                Name = "CollapseIconFrame",
                Parent = sectionHeader
            })

            local collapseIcon = createInstance("ImageLabel", {
                Image = COLLAPSE_ICON,
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Rotation = -90,
                Size = UDim2.new(1, 6, 1, 6),
                Name = "CollapseIcon",
                Parent = collapseIconFrame
            })

            local sectionTitleLabel = createInstance("TextLabel", {
                Font = Enum.Font.GothamBold,
                Text = sectionTitle,
                TextColor3 = Color3.fromRGB(230, 230, 230),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0.5, 0),
                Size = UDim2.new(1, -50, 0, 13),
                Name = "SectionTitleLabel",
                Parent = sectionHeader
            })

            local sectionDivider = createInstance("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 33),
                Size = UDim2.new(0, 0, 0, 2),
                Name = "SectionDivider",
                Parent = sectionFrame
            })

            createInstance("UICorner", { CornerRadius = UDim.new(0, 100), Parent = sectionDivider })

            createInstance("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }),
                Parent = sectionDivider
            })

            local sectionContent = createInstance("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 35),
                Size = UDim2.new(1, 0, 0, 0),
                Name = "SectionContent",
                Parent = sectionFrame
            })

            createInstance("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 5),
                Parent = sectionContent
            })

            local contentList = createInstance("UIListLayout", {
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = sectionContent
            })

            local isCollapsed = false
            local defaultHeight = 0

            local function updateSectionSize()
                local contentHeight = 0
                for _, child in ipairs(sectionContent:GetChildren()) do
                    if child:IsA("GuiObject") and child ~= contentList then
                        contentHeight = contentHeight + child.Size.Y.Offset + contentList.Padding.Offset
                    end
                end
                defaultHeight = contentHeight + 35
                sectionFrame.Size = UDim2.new(1, 0, 0, isCollapsed and 30 or defaultHeight)
                sectionContent.Visible = not isCollapsed

                local totalCanvasHeight = 0
                for _, section in ipairs(tabContent:GetChildren()) do
                    if section:IsA("Frame") then
                        totalCanvasHeight = totalCanvasHeight + section.Size.Y.Offset + contentList.Padding.Offset
                    end
                end
                tabContent.CanvasSize = UDim2.new(0, 0, 0, totalCanvasHeight)
            end

            sectionContent.ChildAdded:Connect(updateSectionSize)
            sectionContent.ChildRemoved:Connect(updateSectionSize)

            if isCollapsible then
                headerButton.MouseButton1Click:Connect(function()
                    isCollapsed = not isCollapsed
                    TweenService:Create(collapseIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Rotation = isCollapsed and 0 or -90
                    }):Play()
                    updateSectionSize()
                end)
            else
                collapseIconFrame.Visible = false
            end

            local ElementControls = {}

            function ElementControls:AddButton(config)
                local buttonConfig = config or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Callback = buttonConfig.Callback or function() end

                local buttonFrame = createInstance("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Name = "ButtonFrame",
                    Parent = sectionContent
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = buttonFrame })

                local button = createInstance("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "Button",
                    Parent = buttonFrame
                })

                createInstance("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = buttonConfig.Name,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    Name = "ButtonLabel",
                    Parent = buttonFrame
                })

                button.MouseButton1Click:Connect(function()
                    createCircleEffect(button, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
                    buttonConfig.Callback()
                end)

                updateSectionSize()
                return button
            end

            function ElementControls:AddToggle(config)
                local toggleConfig = config or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Default = toggleConfig.Default or false
                toggleConfig.Callback = toggleConfig.Callback or function() end

                local toggleFrame = createInstance("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Name = "ToggleFrame",
                    Parent = sectionContent
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = toggleFrame })

                local toggleButton = createInstance("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "ToggleButton",
                    Parent = toggleFrame
                })

                createInstance("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = toggleConfig.Name,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Name = "ToggleLabel",
                    Parent = toggleFrame
                })

                local toggleIndicator = createInstance("Frame", {
                    BackgroundColor3 = toggleConfig.Default and guiConfig.Color or Color3.fromRGB(80, 80, 80),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -35, 0.5, -8),
                    Size = UDim2.new(0, 25, 0, 16),
                    Name = "ToggleIndicator",
                    Parent = toggleFrame
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = toggleIndicator })

                local isToggled = toggleConfig.Default

                toggleButton.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = isToggled and guiConfig.Color or Color3.fromRGB(80, 80, 80)
                    }):Play()
                    toggleConfig.Callback(isToggled)
                end)

                updateSectionSize()
                return toggleButton
            end

            function ElementControls:AddSlider(config)
                local sliderConfig = config or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = sliderConfig.Default or 0
                sliderConfig.Callback = sliderConfig.Callback or function() end

                local sliderFrame = createInstance("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 40),
                    Name = "SliderFrame",
                    Parent = sectionContent
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = sliderFrame })

                createInstance("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = sliderConfig.Name,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, 20),
                    Name = "SliderLabel",
                    Parent = sliderFrame
                })

                local sliderBar = createInstance("Frame", {
                    BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 25),
                    Size = UDim2.new(1, -60, 0, 6),
                    Name = "SliderBar",
                    Parent = sliderFrame
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = sliderBar })

                local sliderFill = createInstance("Frame", {
                    BackgroundColor3 = guiConfig.Color,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0),
                    Name = "SliderFill",
                    Parent = sliderBar
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = sliderFill })

                local sliderButton = createInstance("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "SliderButton",
                    Parent = sliderBar
                })

                local valueLabel = createInstance("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = tostring(sliderConfig.Default),
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 12,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -40, 0, 20),
                    Size = UDim2.new(0, 30, 0, 20),
                    Name = "ValueLabel",
                    Parent = sliderFrame
                })

                local function updateSlider(input)
                    local barSize = sliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X - sliderBar.AbsolutePosition.X, 0, barSize)
                    local value = sliderConfig.Min + (mouseX / barSize) * (sliderConfig.Max - sliderConfig.Min)
                    value = math.floor(value + 0.5)
                    sliderFill.Size = UDim2.new(mouseX / barSize, 0, 1, 0)
                    valueLabel.Text = tostring(value)
                    sliderConfig.Callback(value)
                end

                local defaultPercent = (sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                sliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
                valueLabel.Text = tostring(sliderConfig.Default)

                local dragging = false
                sliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                sliderButton.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)

                updateSectionSize()
                return sliderButton
            end

            function ElementControls:AddDropdown(config)
                local dropdownConfig = config or {}
                dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
                dropdownConfig.Options = dropdownConfig.Options or {}
                dropdownConfig.Default = dropdownConfig.Default or ""
                dropdownConfig.Callback = dropdownConfig.Callback or function() end

                local dropdownMainFrame = createInstance("Frame", {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0.95,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Name = "DropdownMainFrame",
                    Parent = sectionContent
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 4), Parent = dropdownMainFrame })

                local dropdownButton = createInstance("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "DropdownButton",
                    Parent = dropdownMainFrame
                })

                createInstance("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = dropdownConfig.Name,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Name = "DropdownLabel",
                    Parent = dropdownMainFrame
                })

                local selectedLabel = createInstance("TextLabel", {
                    Font = Enum.Font.GothamBold,
                    Text = dropdownConfig.Default,
                    TextColor3 = Color3.fromRGB(150, 150, 150),
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Name = "SelectedLabel",
                    Parent = dropdownMainFrame
                })

                createInstance("ImageLabel", {
                    Image = COLLAPSE_ICON,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -25, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = -90,
                    Name = "ArrowIcon",
                    Parent = dropdownMainFrame
                })

                local dropdownOverlay = createInstance("Frame", {
                    AnchorPoint = Vector2.new(1, 1),
                    BackgroundTransparency = 0.999,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Position = UDim2.new(1, 8, 1, 8),
                    Size = UDim2.new(1, 154, 1, 54),
                    Visible = false,
                    Name = "DropdownOverlay_" .. dropdownConfig.Name,
                    Parent = contentContainer
                })

                createInstance("Frame", {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 0,
                    Name = "OverlayShadowHolder",
                    Parent = dropdownOverlay
                })

                createInstance("ImageLabel", {
                    Image = SHADOW_ASSET,
                    ImageColor3 = Color3.fromRGB(0, 0, 0),
                    ImageTransparency = 0.5,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(49, 49, 450, 450),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, 35, 1, 35),
                    ZIndex = 0,
                    Name = "OverlayShadow",
                    Parent = dropdownOverlay:FindFirstChild("OverlayShadowHolder")
                })

                createInstance("UICorner", { Parent = dropdownOverlay })

                local overlayButton = createInstance("TextButton", {
                    Font = Enum.Font.SourceSans,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    TextSize = 14,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "OverlayButton",
                    Parent = dropdownOverlay
                })

                local dropdownFrame = createInstance("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 172, 0.5, 0),
                    Size = UDim2.new(0, 160, 0, 150),
                    Name = "DropdownFrame_" .. dropdownConfig.Name,
                    ClipsDescendants = true,
                    Parent = dropdownOverlay
                })

                createInstance("UICorner", { CornerRadius = UDim.new(0, 3), Parent = dropdownFrame })

                createInstance("UIStroke", {
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 2.5,
                    Transparency = 0.8,
                    Parent = dropdownFrame
                })

                local dropdownContent = createInstance("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(1, -10, 1, -10),
                    Name = "DropdownContent",
                    Parent = dropdownFrame
                })

                local optionList = createInstance("ScrollingFrame", {
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 0,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    Name = "OptionList",
                    Parent = dropdownContent
                })

                local optionLayout = createInstance("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = optionList
                })

                local function updateOptionListSize()
                    local totalHeight = #dropdownConfig.Options * 32 - 2
                    optionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                    dropdownFrame.Size = UDim2.new(0, 160, 0, math.min(totalHeight, 150))
                end

                for _, option in ipairs(dropdownConfig.Options) do
                    local optionButton = createInstance("TextButton", {
                        Font = Enum.Font.SourceSans,
                        Text = "",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        TextSize = 14,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 0.95,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Name = "OptionButton",
                        Parent = optionList
                    })

                    createInstance("TextLabel", {
                        Font = Enum.Font.GothamBold,
                        Text = option,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 1, 0),
                        Name = "OptionLabel",
                        Parent = optionButton
                    })

                    optionButton.MouseButton1Click:Connect(function()
                        selectedLabel.Text = option
                        dropdownConfig.Callback(option)
                        TweenService:Create(dropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.999 }):Play()
                        TweenService:Create(dropdownFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
                        task.wait(0.2)
                        dropdownOverlay.Visible = false
                    end)
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    if not dropdownOverlay.Visible then
                        dropdownOverlay.Visible = true
                        TweenService:Create(dropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.7 }):Play()
                        TweenService:Create(dropdownFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, -8, 0.5, 0) }):Play()
                        updateOptionListSize()
                    end
                end)

                overlayButton.Activated:Connect(function()
                    if dropdownOverlay.Visible then
                        TweenService:Create(dropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.999 }):Play()
                        TweenService:Create(dropdownFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
                        task.wait(0.2)
                        dropdownOverlay.Visible = false
                    end
                end)

                updateSectionSize()
                return dropdownButton
            end

            sectionIndex = sectionIndex + 1
            updateSectionSize()
            return ElementControls
        end

        tabIndex = tabIndex + 1
        return SectionControls
    end

    return TabControls
end

return PixelLib
