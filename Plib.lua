local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- Constants for reusability
local GUI_DEFAULT_SIZE = UDim2.fromOffset(550, 350)
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local NOTIFICATION_DEFAULTS = {
    Title = "PixelHub",
    Description = "Notification",
    Content = "Content",
    Color = Color3.fromRGB(255, 0, 255),
    Duration = 0.5,
    Delay = 5
}

-- Anti-AFK system with proper connection management
local antiAfkConnection
local function enableAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect() end
    antiAfkConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end
enableAntiAfk()

-- Utility function to get safe CoreGui
local function getSafeCoreGui()
    return RunService:IsStudio() and LocalPlayer.PlayerGui or (gethui and gethui() or cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui"))
end

-- Create toggle button with improved dragging
local function CreateToggleButton()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ToggleGui"
    ScreenGui.Parent = getSafeCoreGui()
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Image = "rbxassetid://98540636959380"
    ToggleButton.Visible = false

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = ToggleButton

    local dragState = { isDragging = false, dragStart = nil, startPos = nil }
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragState.isDragging = true
            dragState.dragStart = input.Position
            dragState.startPos = ToggleButton.Position
        end
    end)

    ToggleButton.InputChanged:Connect(function(input)
        if dragState.isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragState.dragStart
            ToggleButton.Position = UDim2.new(
                dragState.startPos.X.Scale, dragState.startPos.X.Offset + delta.X,
                dragState.startPos.Y.Scale, dragState.startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragState.isDragging = false
        end
    end)

    return ToggleButton
end

local ToggleButton = CreateToggleButton()

-- Enhanced drag and resize functionality
local function EnableDragAndResize(topBar, frame)
    local dragState = { isDragging = false, dragStart = nil, startPos = nil }
    local resizeState = { isResizing = false, startPos = nil }
    local minSize = { width = 400, height = 300 }

    -- Dragging
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragState.isDragging = true
            dragState.dragStart = input.Position
            dragState.startPos = frame.Position
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if dragState.isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragState.dragStart
            frame.Position = UDim2.new(
                dragState.startPos.X.Scale, dragState.startPos.X.Offset + delta.X,
                dragState.startPos.Y.Scale, dragState.startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragState.isDragging = false
        end
    end)

    -- Resizing
    local ResizeCorner = Instance.new("Frame")
    ResizeCorner.AnchorPoint = Vector2.new(1, 1)
    ResizeCorner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ResizeCorner.BackgroundTransparency = 0.999
    ResizeCorner.Position = UDim2.new(1, 0, 1, 0)
    ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
    ResizeCorner.Parent = frame

    ResizeCorner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizeState.isResizing = true
            resizeState.startPos = input.Position
            resizeState.startSize = frame.Size
        end
    end)

    ResizeCorner.InputChanged:Connect(function(input)
        if resizeState.isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeState.startPos
            local newWidth = math.max(minSize.width, resizeState.startSize.X.Offset + delta.X)
            local newHeight = math.max(minSize.height, resizeState.startSize.Y.Offset + delta.Y)
            TweenService:Create(frame, TWEEN_INFO, { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizeState.isResizing = false
        end
    end)
end

-- Circle click effect with optimized performance
local function CreateCircleEffect(target, x, y)
    task.spawn(function()
        target.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Parent = target

        local offsetX = x - target.AbsolutePosition.X
        local offsetY = y - target.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, offsetX, 0, offsetY)
        local size = math.max(target.AbsoluteSize.X, target.AbsoluteSize.Y) * 1.5

        TweenService:Create(Circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(0.5, -size / 2, 0.5, -size / 2),
            ImageTransparency = 1
        }):Play()
        task.wait(0.5)
        Circle:Destroy()
    end)
end

-- PixelLib library
local PixelLib = { IsUnloaded = false }

-- Notification system with improved structure
function PixelLib:CreateNotification(options)
    local notify = options or {}
    for key, default in pairs(NOTIFICATION_DEFAULTS) do
        notify[key] = notify[key] or default
    end

    local NotifyControls = {}
    task.spawn(function()
        local NotifyGui = game:GetService("CoreGui"):FindFirstChild("NotifyGui") or Instance.new("ScreenGui")
        NotifyGui.Name = "NotifyGui"
        NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotifyGui.Parent = getSafeCoreGui()

        local NotifyContainer = NotifyGui:FindFirstChild("NotifyContainer") or Instance.new("Frame")
        NotifyContainer.AnchorPoint = Vector2.new(1, 1)
        NotifyContainer.BackgroundTransparency = 1
        NotifyContainer.Position = UDim2.new(1, -30, 1, -30)
        NotifyContainer.Size = UDim2.new(0, 320, 1, 0)
        NotifyContainer.Name = "NotifyContainer"
        NotifyContainer.Parent = NotifyGui

        local index = 0
        NotifyContainer.ChildRemoved:Connect(function()
            index = 0
            for _, child in NotifyContainer:GetChildren() do
                TweenService:Create(child, TWEEN_INFO, { Position = UDim2.new(0, 0, 1, -((child.Size.Y.Offset + 12) * index)) }):Play()
                index = index + 1
            end
        end)

        local offsetY = 0
        for _, child in NotifyContainer:GetChildren() do
            offsetY = -child.Position.Y.Offset + child.Size.Y.Offset + 12
        end

        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -offsetY)
        NotifyFrame.Parent = NotifyContainer

        local NotifyContent = Instance.new("Frame")
        NotifyContent.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        NotifyContent.Position = UDim2.new(0, 400, 0, 0)
        NotifyContent.Size = UDim2.new(1, 0, 1, 0)
        NotifyContent.Parent = NotifyFrame

        local ContentCorner = Instance.new("UICorner", NotifyContent)
        ContentCorner.CornerRadius = UDim.new(0, 8)

        local ShadowHolder = Instance.new("Frame")
        ShadowHolder.BackgroundTransparency = 1
        ShadowHolder.Size = UDim2.new(1, 0, 1, 0)
        ShadowHolder.ZIndex = 0
        ShadowHolder.Parent = NotifyContent

        local DropShadow = Instance.new("ImageLabel")
        DropShadow.Image = "rbxassetid://6015897843"
        DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        DropShadow.ImageTransparency = 0.5
        DropShadow.ScaleType = Enum.ScaleType.Slice
        DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
        DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        DropShadow.BackgroundTransparency = 1
        DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        DropShadow.Size = UDim2.new(1, 47, 1, 47)
        DropShadow.ZIndex = 0
        DropShadow.Parent = ShadowHolder

        local TopBar = Instance.new("Frame")
        TopBar.BackgroundTransparency = 0.999
        TopBar.Size = UDim2.new(1, 0, 0, 36)
        TopBar.Parent = NotifyContent

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = notify.Title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Size = UDim2.new(1, 0, 1, 0)
        TitleLabel.Position = UDim2.new(0, 10, 0, 0)
        TitleLabel.Parent = TopBar

        local TitleStroke = Instance.new("UIStroke")
        TitleStroke.Color = Color3.fromRGB(255, 255, 255)
        TitleStroke.Thickness = 0.3
        TitleStroke.Parent = TitleLabel

        local DescLabel = Instance.new("TextLabel")
        DescLabel.Font = Enum.Font.GothamBold
        DescLabel.Text = notify.Description
        DescLabel.TextColor3 = notify.Color
        DescLabel.TextSize = 14
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.BackgroundTransparency = 1
        DescLabel.Size = UDim2.new(1, 0, 1, 0)
        DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
        DescLabel.Parent = TopBar

        local DescStroke = Instance.new("UIStroke")
        DescStroke.Color = notify.Color
        DescStroke.Thickness = 0.4
        DescStroke.Parent = DescLabel

        local CloseButton = Instance.new("TextButton")
        CloseButton.Font = Enum.Font.SourceSans
        CloseButton.Text = ""
        CloseButton.AnchorPoint = Vector2.new(1, 0.5)
        CloseButton.BackgroundTransparency = 1
        CloseButton.Position = UDim2.new(1, -5, 0.5, 0)
        CloseButton.Size = UDim2.new(0, 25, 0, 25)
        CloseButton.Parent = TopBar

        local CloseIcon = Instance.new("ImageLabel")
        CloseIcon.Image = "rbxassetid://9886659671"
        CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        CloseIcon.BackgroundTransparency = 1
        CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        CloseIcon.Size = UDim2.new(1, -8, 1, -8)
        CloseIcon.Parent = CloseButton

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ContentLabel.TextSize = 13
        ContentLabel.Text = notify.Content
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Position = UDim2.new(0, 10, 0, 27)
        ContentLabel.Size = UDim2.new(1, -20, 0, 13)
        ContentLabel.TextWrapped = true
        ContentLabel.Parent = NotifyContent

        ContentLabel.Size = UDim2.new(1, -20, 0, ContentLabel.TextBounds.Y)
        NotifyFrame.Size = UDim2.new(1, 0, 0, ContentLabel.AbsoluteSize.Y < 27 and 65 or ContentLabel.AbsoluteSize.Y + 40)

        local isClosing = false
        function NotifyControls:Close()
            if isClosing then return end
            isClosing = true
            TweenService:Create(NotifyContent, TweenInfo.new(notify.Duration, Enum.EasingStyle.Back), { Position = UDim2.new(0, 400, 0, 0) }):Play()
            task.wait(notify.Duration)
            NotifyFrame:Destroy()
        end

        CloseButton.Activated:Connect(NotifyControls.Close)
        TweenService:Create(NotifyContent, TweenInfo.new(notify.Duration, Enum.EasingStyle.Back), { Position = UDim2.new(0, 0, 0, 0) }):Play()
        task.wait(notify.Delay)
        NotifyControls:Close()
    end)
    return NotifyControls
end

-- Main GUI creation with improved structure
function PixelLib:CreateGui(config)
    local guiConfig = config or {}
    guiConfig.NameHub = guiConfig.NameHub or "PixelHub"
    guiConfig.Description = guiConfig.Description or ""
    guiConfig.Color = guiConfig.Color or Color3.fromRGB(0, 132, 255)
    guiConfig.TabWidth = guiConfig.TabWidth or 120
    guiConfig.SizeUI = guiConfig.SizeUI or GUI_DEFAULT_SIZE

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "PixelHubGui"
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = getSafeCoreGui()

    local ShadowHolder = Instance.new("Frame")
    ShadowHolder.BackgroundTransparency = 1
    ShadowHolder.Size = guiConfig.SizeUI
    ShadowHolder.Position = UDim2.new(0.5, -guiConfig.SizeUI.X.Offset / 2, 0.5, -guiConfig.SizeUI.Y.Offset / 2)
    ShadowHolder.Parent = MainGui

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = guiConfig.SizeUI
    DropShadow.ZIndex = 0
    DropShadow.Parent = ShadowHolder

    local MainFrame = Instance.new("Frame")
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = guiConfig.SizeUI
    MainFrame.Parent = DropShadow

    local MainCorner = Instance.new("UICorner", MainFrame)
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(50, 50, 50)
    MainStroke.Thickness = 1.6
    MainStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.BackgroundTransparency = 0.999
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = guiConfig.NameHub
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = TopBar

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Font = Enum.Font.GothamBold
    DescLabel.Text = guiConfig.Description
    DescLabel.TextColor3 = guiConfig.Color
    DescLabel.TextSize = 14
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.BackgroundTransparency = 1
    DescLabel.Size = UDim2.new(1, -(TitleLabel.TextBounds.X + 104), 1, 0)
    DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    DescLabel.Parent = TopBar

    local DescStroke = Instance.new("UIStroke")
    DescStroke.Color = guiConfig.Color
    DescStroke.Thickness = 0.4
    DescStroke.Parent = DescLabel

    local CloseButton = Instance.new("TextButton")
    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.Text = ""
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -8, 0.5, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Parent = TopBar

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = CloseButton

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Font = Enum.Font.SourceSans
    MinimizeButton.Text = ""
    MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -42, 0.5, 0)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Parent = TopBar

    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Image = "rbxassetid://9886659276"
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinimizeIcon.Size = UDim2.new(1, -8, 1, -8)
    MinimizeIcon.Parent = MinimizeButton

    local TabContainer = Instance.new("Frame")
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 9, 0, 50)
    TabContainer.Size = UDim2.new(0, guiConfig.TabWidth, 1, -59)
    TabContainer.Parent = MainFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = TabContainer

    local TabDivider = Instance.new("Frame")
    TabDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabDivider.BackgroundTransparency = 0.85
    TabDivider.Position = UDim2.new(0, 0, 0, 38)
    TabDivider.Size = UDim2.new(1, 0, 0, 1)
    TabDivider.Parent = MainFrame

    local ContentContainer = Instance.new("Frame")
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, guiConfig.TabWidth + 18, 0, 50)
    ContentContainer.Size = UDim2.new(1, -(guiConfig.TabWidth + 27), 1, -59)
    ContentContainer.Parent = MainFrame

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 2)
    ContentCorner.Parent = ContentContainer

    local TabTitle = Instance.new("TextLabel")
    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.Text = ""
    TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTitle.TextSize = 24
    TabTitle.TextWrapped = true
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.BackgroundTransparency = 1
    TabTitle.Size = UDim2.new(1, 0, 0, 30)
    TabTitle.Parent = ContentContainer

    local ContentFrame = Instance.new("Frame")
    ContentFrame.AnchorPoint = Vector2.new(0, 1)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    ContentFrame.Position = UDim2.new(0, 0, 1, 0)
    ContentFrame.Size = UDim2.new(1, 0, 1, -33)
    ContentFrame.Parent = ContentContainer

    local TabPages = Instance.new("Folder")
    TabPages.Parent = ContentFrame

    local PageLayout = Instance.new("UIPageLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.TweenTime = 0.5
    PageLayout.EasingDirection = Enum.EasingDirection.InOut
    PageLayout.EasingStyle = Enum.EasingStyle.Quad
    PageLayout.Parent = TabPages

    local TabList = Instance.new("ScrollingFrame")
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    TabList.ScrollBarThickness = 4
    TabList.Active = true
    TabList.BackgroundTransparency = 1
    TabList.Size = UDim2.new(1, 0, 1, -10)
    TabList.Parent = TabContainer

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabList

    local function UpdateTabCanvas()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end
    TabList.ChildAdded:Connect(UpdateTabCanvas)
    TabList.ChildRemoved:Connect(UpdateTabCanvas)

    local GuiControls = {}
    function GuiControls:DestroyGui()
        if MainGui then
            MainGui:Destroy()
            PixelLib.IsUnloaded = true
        end
    end

    MinimizeButton.Activated:Connect(function()
        CreateCircleEffect(MinimizeButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        ShadowHolder.Visible = false
        ToggleButton.Visible = true
    end)

    ToggleButton.Activated:Connect(function()
        CreateCircleEffect(ToggleButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        ShadowHolder.Visible = true
        ToggleButton.Visible = false
    end)

    CloseButton.Activated:Connect(function()
        CreateCircleEffect(CloseButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        GuiControls:DestroyGui()
    end)

    EnableDragAndResize(TopBar, ShadowHolder)

    local TabControls = {}
    local tabIndex = 0

    function TabControls:CreateTab(tabConfig)
        local tab = tabConfig or {}
        tab.Name = tab.Name or "Tab"
        tab.Icon = tab.Icon or ""

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        TabContent.ScrollBarThickness = 4
        TabContent.Active = true
        TabContent.LayoutOrder = tabIndex
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Parent = TabPages

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 3)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        local TabButtonFrame = Instance.new("Frame")
        TabButtonFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButtonFrame.BackgroundTransparency = tabIndex == 0 and 0.92 or 0.999
        TabButtonFrame.LayoutOrder = tabIndex
        TabButtonFrame.Size = UDim2.new(1, 0, 0, 30)
        TabButtonFrame.Parent = TabList

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 4)
        TabButtonCorner.Parent = TabButtonFrame

        local TabButton = Instance.new("TextButton")
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 13
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Parent = TabButtonFrame

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.Text = tab.Name
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 30, 0, 0)
        TabLabel.Size = UDim2.new(1, 0, 1, 0)
        TabLabel.Parent = TabButtonFrame

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Image = tab.Icon
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0, 9, 0, 7)
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Parent = TabButtonFrame

        if tabIndex == 0 then
            PageLayout:JumpToIndex(0)
            TabTitle.Text = tab.Name
            local TabIndicator = Instance.new("Frame")
            TabIndicator.BackgroundColor3 = guiConfig.Color
            TabIndicator.Position = UDim2.new(0, 2, 0, 9)
            TabIndicator.Size = UDim2.new(0, 1, 0, 12)
            TabIndicator.Parent = TabButtonFrame

            local TabIndicatorStroke = Instance.new("UIStroke")
            TabIndicatorStroke.Color = guiConfig.Color
            TabIndicatorStroke.Thickness = 1.6
            TabIndicatorStroke.Parent = TabIndicator
        end

        TabButton.Activated:Connect(function()
            CreateCircleEffect(TabButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
            local currentIndicator = TabList:FindFirstChildOfClass("Frame"):FindFirstChild("TabIndicator")
            if currentIndicator and TabButtonFrame.LayoutOrder ~= PageLayout.CurrentPage.LayoutOrder then
                for _, tabFrame in TabList:GetChildren() do
                    if tabFrame:IsA("Frame") then
                        TweenService:Create(tabFrame, TWEEN_INFO, { BackgroundTransparency = 0.999 }):Play()
                    end
                end
                TweenService:Create(TabButtonFrame, TWEEN_INFO, { BackgroundTransparency = 0.92 }):Play()
                TweenService:Create(currentIndicator, TWEEN_INFO, { Position = UDim2.new(0, 2, 0, 9 + (33 * TabButtonFrame.LayoutOrder)) }):Play()
                PageLayout:JumpToIndex(TabButtonFrame.LayoutOrder)
                TabTitle.Text = tab.Name
                TweenService:Create(currentIndicator, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 1, 0, 20) }):Play()
                task.wait(0.2)
                TweenService:Create(currentIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 1, 0, 12) }):Play()
            end
        end)

        local SectionControls = {}
        local sectionIndex = 0

        function SectionControls:AddSection(title, collapsible)
            local sectionTitle = title or "Section"
            local isCollapsible = collapsible or false

            local SectionFrame = Instance.new("Frame")
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.LayoutOrder = sectionIndex
            SectionFrame.ClipsDescendants = true
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.Parent = TabContent

            local SectionHeader = Instance.new("Frame")
            SectionHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionHeader.BackgroundTransparency = 0.935
            SectionHeader.Position = UDim2.new(0.5, 0, 0, 0)
            SectionHeader.Size = UDim2.new(1, 1, 0, 30)
            SectionHeader.Parent = SectionFrame

            local HeaderCorner = Instance.new("UICorner")
            HeaderCorner.CornerRadius = UDim.new(0, 4)
            HeaderCorner.Parent = SectionHeader

            local HeaderButton = Instance.new("TextButton")
            HeaderButton.Font = Enum.Font.SourceSans
            HeaderButton.Text = ""
            HeaderButton.BackgroundTransparency = 1
            HeaderButton.Size = UDim2.new(1, 0, 1, 0)
            HeaderButton.Parent = SectionHeader

            local CollapseIconFrame = Instance.new("Frame")
            CollapseIconFrame.AnchorPoint = Vector2.new(1, 0.5)
            CollapseIconFrame.BackgroundTransparency = 1
            CollapseIconFrame.Position = UDim2.new(1, -5, 0.5, 0)
            CollapseIconFrame.Size = UDim2.new(0, 20, 0, 20)
            CollapseIconFrame.Parent = SectionHeader
            CollapseIconFrame.Visible = isCollapsible

            local CollapseIcon = Instance.new("ImageLabel")
            CollapseIcon.Image = "rbxassetid://16851841101"
            CollapseIcon.BackgroundTransparency = 1
            CollapseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            CollapseIcon.Size = UDim2.new(1, 6, 1, 6)
            CollapseIcon.Rotation = -90
            CollapseIcon.Parent = CollapseIconFrame

            local SectionTitleLabel = Instance.new("TextLabel")
            SectionTitleLabel.Font = Enum.Font.GothamBold
            SectionTitleLabel.Text = sectionTitle
            SectionTitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitleLabel.TextSize = 13
            SectionTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitleLabel.BackgroundTransparency = 1
            SectionTitleLabel.Position = UDim2.new(0, 10, 0.5, 0)
            SectionTitleLabel.Size = UDim2.new(1, -50, 0, 13)
            SectionTitleLabel.Parent = SectionHeader

            local SectionDivider = Instance.new("Frame")
            SectionDivider.BackgroundColor3 = guiConfig.Color
            SectionDivider.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDivider.Size = UDim2.new(0.8, 0, 0, 2)
            SectionDivider.Parent = SectionFrame

            local DividerCorner = Instance.new("UICorner")
            DividerCorner.CornerRadius = UDim.new(0, 100)
            DividerCorner.Parent = SectionDivider

            local SectionContent = Instance.new("Frame")
            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 0, 0, 35)
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Parent = SectionFrame

            local ContentPadding = Instance.new("UIPadding")
            ContentPadding.PaddingLeft = UDim.new(0, 10)
            ContentPadding.PaddingRight = UDim.new(0, 10)
            ContentPadding.PaddingTop = UDim.new(0, 5)
            ContentPadding.Parent = SectionContent

            local ContentList = Instance.new("UIListLayout")
            ContentList.Padding = UDim.new(0, 5)
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentList.Parent = SectionContent

            local isCollapsed = false
            local function UpdateSectionSize()
                local contentHeight = ContentList.AbsoluteContentSize.Y + ContentPadding.PaddingTop.Offset
                SectionFrame.Size = UDim2.new(1, 0, 0, isCollapsed and 30 or contentHeight + 35)
                SectionContent.Visible = not isCollapsed
                TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            end

            SectionContent.ChildAdded:Connect(UpdateSectionSize)
            SectionContent.ChildRemoved:Connect(UpdateSectionSize)

            if isCollapsible then
                HeaderButton.MouseButton1Click:Connect(function()
                    isCollapsed = not isCollapsed
                    TweenService:Create(CollapseIcon, TWEEN_INFO, { Rotation = isCollapsed and 0 or -90 }):Play()
                    UpdateSectionSize()
                end)
            end

            local ElementControls = {}

            function ElementControls:AddButton(config)
                local buttonConfig = config or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Callback = buttonConfig.Callback or function() end

                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ButtonFrame.BackgroundTransparency = 0.95
                ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
                ButtonFrame.Parent = SectionContent

                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                ButtonCorner.Parent = ButtonFrame

                local Button = Instance.new("TextButton")
                Button.Font = Enum.Font.SourceSans
                Button.Text = ""
                Button.BackgroundTransparency = 1
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Parent = ButtonFrame

                local ButtonLabel = Instance.new("TextLabel")
                ButtonLabel.Font = Enum.Font.GothamBold
                ButtonLabel.Text = buttonConfig.Name
                ButtonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ButtonLabel.TextSize = 13
                ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
                ButtonLabel.BackgroundTransparency = 1
                ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
                ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
                ButtonLabel.Parent = ButtonFrame

                Button.MouseButton1Click:Connect(function()
                    CreateCircleEffect(Button, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
                    buttonConfig.Callback()
                end)

                UpdateSectionSize()
                return Button
            end

            function ElementControls:AddToggle(config)
                local toggleConfig = config or {}
                toggleConfig.Name = toggleConfig.Name or "Toggle"
                toggleConfig.Default = toggleConfig.Default or false
                toggleConfig.Callback = toggleConfig.Callback or function() end

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleFrame.BackgroundTransparency = 0.95
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.Parent = SectionContent

                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 4)
                ToggleCorner.Parent = ToggleFrame

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Font = Enum.Font.SourceSans
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Parent = ToggleFrame

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Font = Enum.Font.GothamBold
                ToggleLabel.Text = toggleConfig.Name
                ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Parent = ToggleFrame

                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.BackgroundColor3 = toggleConfig.Default and guiConfig.Color or Color3.fromRGB(80, 80, 80)
                ToggleIndicator.Position = UDim2.new(1, -35, 0.5, -8)
                ToggleIndicator.Size = UDim2.new(0, 25, 0, 16)
                ToggleIndicator.Parent = ToggleFrame

                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(0, 8)
                IndicatorCorner.Parent = ToggleIndicator

                local isToggled = toggleConfig.Default
                -- เรียก Callback แบบ Asynchronous เมื่อเริ่มต้นถ้า Default = true
                if isToggled then
                    task.spawn(function()
                        toggleConfig.Callback(isToggled)
                    end)
                end

                ToggleButton.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    TweenService:Create(ToggleIndicator, TWEEN_INFO, { BackgroundColor3 = isToggled and guiConfig.Color or Color3.fromRGB(80, 80, 80) }):Play()
                    task.spawn(function()
                        toggleConfig.Callback(isToggled)
                    end)
                end)

                UpdateSectionSize()
                return ToggleButton
            end
            
            function ElementControls:AddSlider(config)
                local sliderConfig = config or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = math.clamp(sliderConfig.Default or 0, sliderConfig.Min, sliderConfig.Max)
                sliderConfig.Callback = sliderConfig.Callback or function() end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderFrame.BackgroundTransparency = 0.95
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.Parent = SectionContent

                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 4)
                SliderCorner.Parent = SliderFrame

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Font = Enum.Font.GothamBold
                SliderLabel.Text = sliderConfig.Name
                SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0, 10, 0, 0)
                SliderLabel.Size = UDim2.new(1, -20, 0, 20)
                SliderLabel.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                SliderBar.Position = UDim2.new(0, 10, 0, 25)
                SliderBar.Size = UDim2.new(1, -60, 0, 6)
                SliderBar.Parent = SliderFrame

                local BarCorner = Instance.new("UICorner")
                BarCorner.CornerRadius = UDim.new(0, 3)
                BarCorner.Parent = SliderBar

                local SliderFill = Instance.new("Frame")
                SliderFill.BackgroundColor3 = guiConfig.Color
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.Parent = SliderBar

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3)
                FillCorner.Parent = SliderFill

                local SliderButton = Instance.new("TextButton")
                SliderButton.Font = Enum.Font.SourceSans
                SliderButton.Text = ""
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.Parent = SliderBar

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.Text = tostring(sliderConfig.Default)
                ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ValueLabel.TextSize = 12
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(1, -40, 0, 20)
                ValueLabel.Size = UDim2.new(0, 30, 0, 20)
                ValueLabel.Parent = SliderFrame

                local function UpdateSlider(input)
                    local barSize = SliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, barSize)
                    local value = math.floor(sliderConfig.Min + (mouseX / barSize) * (sliderConfig.Max - sliderConfig.Min) + 0.5)
                    SliderFill.Size = UDim2.new(mouseX / barSize, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    sliderConfig.Callback(value)
                end

                local defaultPercent = (sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)

                local dragging = false
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                SliderButton.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                UpdateSectionSize()
                return SliderButton
            end

            function ElementControls:AddDropdown(config)
                local dropdownConfig = config or {}
                dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
                dropdownConfig.Options = dropdownConfig.Options or {}
                dropdownConfig.Default = dropdownConfig.Default or (dropdownConfig.Options[1] or "")
                dropdownConfig.Callback = dropdownConfig.Callback or function() end

                local DropdownMainFrame = Instance.new("Frame")
                DropdownMainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownMainFrame.BackgroundTransparency = 0.95
                DropdownMainFrame.Size = UDim2.new(1, 0, 0, 30)
                DropdownMainFrame.Parent = SectionContent

                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 4)
                DropdownCorner.Parent = DropdownMainFrame

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Font = Enum.Font.SourceSans
                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Parent = DropdownMainFrame

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Font = Enum.Font.GothamBold
                DropdownLabel.Text = dropdownConfig.Name
                DropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
                DropdownLabel.Parent = DropdownMainFrame

                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Font = Enum.Font.GothamBold
                SelectedLabel.Text = dropdownConfig.Default
                SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                SelectedLabel.TextSize = 13
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Position = UDim2.new(0, 0, 0, 0)
                SelectedLabel.Size = UDim2.new(1, -40, 1, 0)
                SelectedLabel.Parent = DropdownMainFrame

                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Image = "rbxassetid://16851841101"
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Position = UDim2.new(1, -25, 0.5, -8)
                ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
                ArrowIcon.Rotation = -90
                ArrowIcon.Parent = DropdownMainFrame

                local DropdownOverlay = Instance.new("Frame")
                DropdownOverlay.AnchorPoint = Vector2.new(1, 1)
                DropdownOverlay.BackgroundTransparency = 0.999
                DropdownOverlay.ClipsDescendants = true
                DropdownOverlay.Position = UDim2.new(1, 8, 1, 8)
                DropdownOverlay.Size = UDim2.new(1, 154, 1, 54)
                DropdownOverlay.Visible = false
                DropdownOverlay.Parent = ContentContainer

                local OverlayCorner = Instance.new("UICorner", DropdownOverlay)

                local OverlayButton = Instance.new("TextButton")
                OverlayButton.Font = Enum.Font.SourceSans
                OverlayButton.Text = ""
                OverlayButton.BackgroundTransparency = 1
                OverlayButton.Size = UDim2.new(1, 0, 1, 0)
                OverlayButton.Parent = DropdownOverlay

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.AnchorPoint = Vector2.new(1, 0.5)
                DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                DropdownFrame.Position = UDim2.new(1, 172, 0.5, 0)
                DropdownFrame.Size = UDim2.new(0, 160, 0, 150)
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = DropdownOverlay

                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 3)
                DropdownCorner.Parent = DropdownFrame

                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = Color3.fromRGB(255, 255, 255)
                DropdownStroke.Thickness = 2
                DropdownStroke.Transparency = 0.8
                DropdownStroke.Parent = DropdownFrame

                local DropdownContent = Instance.new("Frame")
                DropdownContent.BackgroundTransparency = 1
                DropdownContent.Position = UDim2.new(0, 0, 0, 0)
                DropdownContent.Size = UDim2.new(1, 0, 1, 0)
                DropdownContent.Parent = DropdownFrame

                local OptionList = Instance.new("ScrollingFrame")
                OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
                OptionList.ScrollBarThickness = 4
                OptionList.BackgroundTransparency = 1
                OptionList.Size = UDim2.new(1, 0, 1, 0)
                OptionList.Parent = DropdownContent

                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.Padding = UDim.new(0, 2)
                OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionLayout.Parent = OptionList

                local function UpdateOptionListSize()
                    local totalHeight = #dropdownConfig.Options * 32
                    OptionList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
                    DropdownFrame.Size = UDim2.new(0, 160, 0, math.min(totalHeight, 150))
                end

                for _, option in ipairs(dropdownConfig.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    OptionButton.BackgroundTransparency = 0.95
                    OptionButton.Size = UDim2.new(1, 0, 0, 30)
                    OptionButton.Parent = OptionList

                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.Font = Enum.Font.GothamBold
                    OptionLabel.Text = option
                    OptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptionLabel.TextSize = 13
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Center
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Size = UDim2.new(1, 0, 1, 0)
                    OptionLabel.Parent = OptionButton

                    OptionButton.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = option
                        dropdownConfig.Callback(option)
                        TweenService:Create(DropdownOverlay, TWEEN_INFO, { BackgroundTransparency = 0.999 }):Play()
                        TweenService:Create(DropdownFrame, TWEEN_INFO, { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
                        task.wait(0.2)
                        DropdownOverlay.Visible = false
                    end)
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    if not DropdownOverlay.Visible then
                        DropdownOverlay.Visible = true
                        TweenService:Create(DropdownOverlay, TWEEN_INFO, { BackgroundTransparency = 0.7 }):Play()
                        TweenService:Create(DropdownFrame, TWEEN_INFO, { Position = UDim2.new(1, -8, 0.5, 0) }):Play()
                        UpdateOptionListSize()
                    end
                end)

                OverlayButton.Activated:Connect(function()
                    if DropdownOverlay.Visible then
                        TweenService:Create(DropdownOverlay, TWEEN_INFO, { BackgroundTransparency = 0.999 }):Play()
                        TweenService:Create(DropdownFrame, TWEEN_INFO, { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
                        task.wait(0.2)
                        DropdownOverlay.Visible = false
                    end
                end)

                UpdateSectionSize()
                return DropdownButton
            end

            sectionIndex = sectionIndex + 1
            UpdateSectionSize()
            return ElementControls
        end

        tabIndex = tabIndex + 1
        return SectionControls
    end

    return TabControls
end

return PixelLib
