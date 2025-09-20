local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Anti-AFK system with cleanup
local antiAfkConnection
local function EnableAntiAfk()
    if antiAfkConnection then antiAfkConnection:Disconnect() end
    antiAfkConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end
EnableAntiAfk()

-- Function to create toggle button
local function CreateToggleButton()
    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("ImageButton")
    local Corner = Instance.new("UICorner")
    local Stroke = Instance.new("UIStroke")

    ScreenGui.Name = "ToggleGui"
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or (gethui and gethui() or game:GetService("CoreGui"))
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Image = "rbxassetid://98540636959380"
    ToggleButton.Visible = false

    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = ToggleButton

    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 1
    Stroke.Parent = ToggleButton

    local isDragging = false
    local dragStart, startPos
    local dragConnection

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
        end
    end)

    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    ToggleButton.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return ToggleButton
end

local ToggleButton = CreateToggleButton()

-- Function to enable dragging and resizing
local function EnableDragAndResize(topBar, frame)
    local isDragging, isResizing = false, false
    local dragStart, startPos, resizeStart
    local minWidth, minHeight = 400, 300

    frame.Size = UDim2.new(0, math.max(frame.Size.X.Offset, minWidth), 0, math.max(frame.Size.Y.Offset, minHeight))

    local ResizeCorner = Instance.new("Frame")
    ResizeCorner.AnchorPoint = Vector2.new(1, 1)
    ResizeCorner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ResizeCorner.BackgroundTransparency = 0.999
    ResizeCorner.Position = UDim2.new(1, 0, 1, 0)
    ResizeCorner.Size = UDim2.new(0, 20, 0, 20)
    ResizeCorner.Name = "ResizeCorner"
    ResizeCorner.Parent = frame

    local function UpdateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    local function UpdateResize(input)
        local delta = input.Position - resizeStart
        local newWidth = math.max(minWidth, startPos.X.Offset + delta.X)
        local newHeight = math.max(minHeight, startPos.Y.Offset + delta.Y)
        TweenService:Create(frame, TweenInfo.new(0.1), { Size = UDim2.new(0, newWidth, 0, newHeight) }):Play()
    end

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateDrag(input)
        end
    end)

    ResizeCorner.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStart = input.Position
            startPos = frame.Size
        end
    end)

    ResizeCorner.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateResize(input)
        end
    end)
end

-- Circle click effect
local function CreateCircleEffect(target, x, y)
    task.spawn(function()
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "ClickEffect"
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

-- Notification system
function PixelLib:CreateNotification(options)
    local notify = options or {}
    notify.Title = notify.Title or "PixelHub"
    notify.Description = notify.Description or "Notification"
    notify.Content = notify.Content or "Content"
    notify.Color = notify.Color or Color3.fromRGB(255, 0, 255)
    notify.Duration = notify.Duration or 0.5
    notify.Delay = notify.Delay or 5

    local NotifyControls = {}
    task.spawn(function()
        local NotifyGui = game:GetService("CoreGui"):FindFirstChild("NotifyGui") or Instance.new("ScreenGui")
        NotifyGui.Name = "NotifyGui"
        NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        NotifyGui.Parent = game:GetService("CoreGui")

        local NotifyContainer = NotifyGui:FindFirstChild("NotifyContainer") or Instance.new("Frame")
        NotifyContainer.AnchorPoint = Vector2.new(1, 1)
        NotifyContainer.BackgroundTransparency = 1
        NotifyContainer.Position = UDim2.new(1, -20, 1, -20)
        NotifyContainer.Size = UDim2.new(0, 300, 1, 0)
        NotifyContainer.Name = "NotifyContainer"
        NotifyContainer.Parent = NotifyGui

        local index = 0
        NotifyContainer.ChildRemoved:Connect(function()
            index = 0
            for _, child in NotifyContainer:GetChildren() do
                TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0, 0, 1, -((child.Size.Y.Offset + 10) * index))
                }):Play()
                index = index + 1
            end
        end)

        local offsetY = 0
        for _, child in NotifyContainer:GetChildren() do
            if child:IsA("Frame") then
                offsetY = offsetY + child.Size.Y.Offset + 10
            end
        end

        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Size = UDim2.new(1, 0, 0, 80)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -offsetY)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.Parent = NotifyContainer

        local NotifyContent = Instance.new("Frame")
        NotifyContent.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        NotifyContent.Position = UDim2.new(0, 400, 0, 0)
        NotifyContent.Size = UDim2.new(1, 0, 1, 0)
        NotifyContent.Parent = NotifyFrame

        local ContentCorner = Instance.new("UICorner")
        ContentCorner.CornerRadius = UDim.new(0, 8)
        ContentCorner.Parent = NotifyContent

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
        DropShadow.Size = UDim2.new(1, 47, 1, 47)
        DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        DropShadow.BackgroundTransparency = 1
        DropShadow.ZIndex = 0
        DropShadow.Parent = ShadowHolder

        local TopBar = Instance.new("Frame")
        TopBar.BackgroundTransparency = 1
        TopBar.Size = UDim2.new(1, 0, 0, 30)
        TopBar.Parent = NotifyContent

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = notify.Title
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Size = UDim2.new(0.5, -10, 1, 0)
        TitleLabel.Position = UDim2.new(0, 10, 0, 0)
        TitleLabel.Parent = TopBar

        local DescLabel = Instance.new("TextLabel")
        DescLabel.Font = Enum.Font.GothamBold
        DescLabel.Text = notify.Description
        DescLabel.TextColor3 = notify.Color
        DescLabel.TextSize = 14
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.BackgroundTransparency = 1
        DescLabel.Size = UDim2.new(0.5, -10, 1, 0)
        DescLabel.Position = UDim2.new(0.5, 0, 0, 0)
        DescLabel.Parent = TopBar

        local CloseButton = Instance.new("TextButton")
        CloseButton.Text = ""
        CloseButton.BackgroundTransparency = 1
        CloseButton.Size = UDim2.new(0, 20, 0, 20)
        CloseButton.Position = UDim2.new(1, -25, 0.5, 0)
        CloseButton.AnchorPoint = Vector2.new(1, 0.5)
        CloseButton.Parent = TopBar

        local CloseIcon = Instance.new("ImageLabel")
        CloseIcon.Image = "rbxassetid://9886659671"
        CloseIcon.BackgroundTransparency = 1
        CloseIcon.Size = UDim2.new(1, -4, 1, -4)
        CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        CloseIcon.Parent = CloseButton

        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.Text = notify.Content
        ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ContentLabel.TextSize = 12
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Position = UDim2.new(0, 10, 0, 35)
        ContentLabel.Size = UDim2.new(1, -20, 0, 40)
        ContentLabel.TextWrapped = true
        ContentLabel.Parent = NotifyContent

        NotifyFrame.Size = UDim2.new(1, 0, 0, math.max(ContentLabel.TextBounds.Y + 40, 80))

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
        task.spawn(function()
            task.wait(notify.Delay)
            NotifyControls:Close()
        end)

        return NotifyControls
    end)
end

-- Main GUI creation
function PixelLib:CreateGui(config)
    local guiConfig = config or {}
    guiConfig.NameHub = guiConfig.NameHub or "PixelHub"
    guiConfig.Description = guiConfig.Description or ""
    guiConfig.Color = guiConfig.Color or Color3.fromRGB(0, 132, 255)
    guiConfig.TabWidth = guiConfig.TabWidth or 120
    guiConfig.SizeUI = guiConfig.SizeUI or UDim2.fromOffset(550, 350)

    local GuiControls = {}
    local Connections = {}

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "PixelHubGui"
    MainGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or (gethui and gethui() or game:GetService("CoreGui"))
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.ResetOnSpawn = false

    local ShadowHolder = Instance.new("Frame")
    ShadowHolder.BackgroundTransparency = 1
    ShadowHolder.Size = guiConfig.SizeUI
    ShadowHolder.Position = UDim2.new(0.5, -guiConfig.SizeUI.X.Offset / 2, 0.5, -guiConfig.SizeUI.Y.Offset / 2)
    ShadowHolder.Parent = MainGui

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.ZIndex = 0
    DropShadow.Parent = ShadowHolder

    local MainFrame = Instance.new("Frame")
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.Size = guiConfig.SizeUI
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ShadowHolder

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.BackgroundTransparency = 1
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = guiConfig.NameHub
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(0.5, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = TopBar

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.Text = guiConfig.Description
    DescLabel.TextColor3 = guiConfig.Color
    DescLabel.TextSize = 14
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.BackgroundTransparency = 1
    DescLabel.Size = UDim2.new(0.5, -50, 1, 0)
    DescLabel.Position = UDim2.new(0.5, 0, 0, 0)
    DescLabel.Parent = TopBar

    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = ""
    CloseButton.BackgroundTransparency = 1
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -10, 0.5, 0)
    CloseButton.AnchorPoint = Vector2.new(1, 0.5)
    CloseButton.Parent = TopBar

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Size = UDim2.new(1, -6, 1, -6)
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Parent = CloseButton

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Text = ""
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -40, 0.5, 0)
    MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeButton.Parent = TopBar

    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Image = "rbxassetid://9886659276"
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Size = UDim2.new(1, -6, 1, -6)
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinimizeIcon.Parent = MinimizeButton

    local TabContainer = Instance.new("Frame")
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.Size = UDim2.new(0, guiConfig.TabWidth, 1, -60)
    TabContainer.Parent = MainFrame

    local ContentContainer = Instance.new("Frame")
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, guiConfig.TabWidth + 20, 0, 50)
    ContentContainer.Size = UDim2.new(1, -(guiConfig.TabWidth + 30), 1, -60)
    ContentContainer.Parent = MainFrame

    local TabTitle = Instance.new("TextLabel")
    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.Text = ""
    TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTitle.TextSize = 20
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.BackgroundTransparency = 1
    TabTitle.Size = UDim2.new(1, 0, 0, 30)
    TabTitle.Parent = ContentContainer

    local ContentFrame = Instance.new("Frame")
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 35)
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = ContentContainer

    local TabPages = Instance.new("Folder")
    TabPages.Parent = ContentFrame

    local PageLayout = Instance.new("UIPageLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.TweenTime = 0.3
    PageLayout.EasingStyle = Enum.EasingStyle.Quad
    PageLayout.Parent = TabPages

    local TabList = Instance.new("ScrollingFrame")
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.Parent = TabContainer

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabList

    local function UpdateTabCanvas()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateTabCanvas)

    function GuiControls:DestroyGui()
        if MainGui then
            for _, connection in pairs(Connections) do
                connection:Disconnect()
            end
            MainGui:Destroy()
            PixelLib.IsUnloaded = true
        end
    end

    table.insert(Connections, MinimizeButton.Activated:Connect(function()
        CreateCircleEffect(MinimizeButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        ShadowHolder.Visible = false
        ToggleButton.Visible = true
    end))

    table.insert(Connections, ToggleButton.Activated:Connect(function()
        CreateCircleEffect(ToggleButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        ShadowHolder.Visible = true
        ToggleButton.Visible = false
    end))

    table.insert(Connections, CloseButton.Activated:Connect(function()
        CreateCircleEffect(CloseButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        GuiControls:DestroyGui()
    end))

    EnableDragAndResize(TopBar, ShadowHolder)

    local TabControls = {}
    local tabIndex = 0

    function TabControls:CreateTab(tabConfig)
        local tab = tabConfig or {}
        tab.Name = tab.Name or "Tab"
        tab.Icon = tab.Icon or ""

        local TabContent = Instance.new("ScrollingFrame")
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.LayoutOrder = tabIndex
        TabContent.Parent = TabPages

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        local TabButtonFrame = Instance.new("Frame")
        TabButtonFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButtonFrame.BackgroundTransparency = tabIndex == 0 and 0.9 or 1
        TabButtonFrame.Size = UDim2.new(1, 0, 0, 35)
        TabButtonFrame.LayoutOrder = tabIndex
        TabButtonFrame.Parent = TabList

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 5)
        TabButtonCorner.Parent = TabButtonFrame

        local TabButton = Instance.new("TextButton")
        TabButton.Text = ""
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Parent = TabButtonFrame

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Image = tab.Icon
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0, 10, 0.5, -8)
        TabIcon.Size = UDim2.new(0, 20, 0, 20)
        TabIcon.Parent = TabButtonFrame

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.Text = tab.Name
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabLabel.TextSize = 14
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Parent = TabButtonFrame

        if tabIndex == 0 then
            PageLayout:JumpToIndex(0)
            TabTitle.Text = tab.Name
            local TabIndicator = Instance.new("Frame")
            TabIndicator.BackgroundColor3 = guiConfig.Color
            TabIndicator.Size = UDim2.new(0, 3, 0, 20)
            TabIndicator.Position = UDim2.new(0, 2, 0.5, -10)
            TabIndicator.Parent = TabButtonFrame
        end

        TabButton.Activated:Connect(function()
            CreateCircleEffect(TabButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
            for _, frame in TabList:GetChildren() do
                if frame:IsA("Frame") then
                    TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                end
            end
            TweenService:Create(TabButtonFrame, TweenInfo.new(0.2), { BackgroundTransparency = 0.9 }):Play()
            PageLayout:JumpToIndex(TabButtonFrame.LayoutOrder)
            TabTitle.Text = tab.Name
        end)

        local SectionControls = {}
        local sectionIndex = 0

        function SectionControls:AddSection(title, collapsible)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, 0, 0, 40)
            SectionFrame.LayoutOrder = sectionIndex
            SectionFrame.Parent = TabContent

            local SectionHeader = Instance.new("Frame")
            SectionHeader.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionHeader.BackgroundTransparency = 0.95
            SectionHeader.Size = UDim2.new(1, -10, 0, 30)
            SectionHeader.Position = UDim2.new(0, 5, 0, 0)
            SectionHeader.Parent = SectionFrame

            local HeaderCorner = Instance.new("UICorner")
            HeaderCorner.CornerRadius = UDim.new(0, 4)
            HeaderCorner.Parent = SectionHeader

            local HeaderButton = Instance.new("TextButton")
            HeaderButton.Text = ""
            HeaderButton.BackgroundTransparency = 1
            HeaderButton.Size = UDim2.new(1, 0, 1, 0)
            HeaderButton.Parent = SectionHeader

            local SectionTitleLabel = Instance.new("TextLabel")
            SectionTitleLabel.Font = Enum.Font.GothamBold
            SectionTitleLabel.Text = title or "Section"
            SectionTitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitleLabel.TextSize = 14
            SectionTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitleLabel.BackgroundTransparency = 1
            SectionTitleLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionTitleLabel.Size = UDim2.new(1, -40, 1, 0)
            SectionTitleLabel.Parent = SectionHeader

            local CollapseIcon = Instance.new("ImageLabel")
            CollapseIcon.Image = "rbxassetid://16851841101"
            CollapseIcon.BackgroundTransparency = 1
            CollapseIcon.Position = UDim2.new(1, -25, 0.5, -8)
            CollapseIcon.Size = UDim2.new(0, 16, 0, 16)
            CollapseIcon.Rotation = collapsible and -90 or 0
            CollapseIcon.Visible = collapsible
            CollapseIcon.Parent = SectionHeader

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
                local contentHeight = ContentList.AbsoluteContentSize.Y + 5
                SectionFrame.Size = UDim2.new(1, 0, 0, isCollapsed and 35 or contentHeight + 35)
                SectionContent.Visible = not isCollapsed
                TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            end

            ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSectionSize)

            if collapsible then
                HeaderButton.Activated:Connect(function()
                    isCollapsed = not isCollapsed
                    TweenService:Create(CollapseIcon, TweenInfo.new(0.2), { Rotation = isCollapsed and 0 or -90 }):Play()
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

                Button.Activated:Connect(function()
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
                ToggleIndicator.Size = UDim2.new(0, 25, 0, 16)
                ToggleIndicator.Position = UDim2.new(1, -35, 0.5, -8)
                ToggleIndicator.Parent = ToggleFrame

                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(0, 8)
                IndicatorCorner.Parent = ToggleIndicator

                local isToggled = toggleConfig.Default
                if isToggled then
                    toggleConfig.Callback(true)
                end

                ToggleButton.Activated:Connect(function()
                    isToggled = not isToggled
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                        BackgroundColor3 = isToggled and guiConfig.Color or Color3.fromRGB(80, 80, 80)
                    }):Play()
                    toggleConfig.Callback(isToggled)
                end)

                UpdateSectionSize()
                return ToggleButton
            end

            function ElementControls:AddSlider(config)
                local sliderConfig = config or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = sliderConfig.Default or sliderConfig.Min
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
                SliderLabel.Size = UDim2.new(1, -60, 0, 20)
                SliderLabel.Parent = SliderFrame

                local SliderBar = Instance.new("Frame")
                SliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                SliderBar.Size = UDim2.new(1, -60, 0, 6)
                SliderBar.Position = UDim2.new(0, 10, 0, 25)
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
                SliderButton.Text = ""
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.Parent = SliderBar

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.Text = tostring(sliderConfig.Default)
                ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ValueLabel.TextSize = 12
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(1, -40, 0, 0)
                ValueLabel.Size = UDim2.new(0, 30, 0, 20)
                ValueLabel.Parent = SliderFrame

                local function UpdateSlider(input)
                    local barSize = SliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, barSize)
                    local value = sliderConfig.Min + (mouseX / barSize) * (sliderConfig.Max - sliderConfig.Min)
                    value = math.floor(value + 0.5)
                    SliderFill.Size = UDim2.new(mouseX / barSize, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    sliderConfig.Callback(value)
                end

                local defaultPercent = (sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
                ValueLabel.Text = tostring(sliderConfig.Default)
                sliderConfig.Callback(sliderConfig.Default)

                local dragging = false
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)

                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
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

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                DropdownFrame.BackgroundTransparency = 0.95
                DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
                DropdownFrame.Parent = SectionContent

                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 4)
                DropdownCorner.Parent = DropdownFrame

                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Parent = DropdownFrame

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Font = Enum.Font.GothamBold
                DropdownLabel.Text = dropdownConfig.Name
                DropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
                DropdownLabel.Parent = DropdownFrame

                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Font = Enum.Font.Gotham
                SelectedLabel.Text = dropdownConfig.Default
                SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                SelectedLabel.TextSize = 13
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Position = UDim2.new(0, 0, 0, 0)
                SelectedLabel.Size = UDim2.new(1, -40, 1, 0)
                SelectedLabel.Parent = DropdownFrame

                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Image = "rbxassetid://16851841101"
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Position = UDim2.new(1, -25, 0.5, -8)
                ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
                ArrowIcon.Parent = DropdownFrame

                local DropdownOverlay = Instance.new("Frame")
                DropdownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                DropdownOverlay.BackgroundTransparency = 0.999
                DropdownOverlay.ClipsDescendants = true
                DropdownOverlay.Size = UDim2.new(1, 0, 0, 150)
                DropdownOverlay.Position = UDim2.new(0, 0, 1, 5)
                DropdownOverlay.Visible = false
                DropdownOverlay.Parent = DropdownFrame

                local OverlayCorner = Instance.new("UICorner")
                OverlayCorner.CornerRadius = UDim.new(0, 4)
                OverlayCorner.Parent = DropdownOverlay

                local OverlayButton = Instance.new("TextButton")
                OverlayButton.Text = ""
                OverlayButton.BackgroundTransparency = 1
                OverlayButton.Size = UDim2.new(1, 0, 1, 0)
                OverlayButton.Parent = DropdownOverlay

                local OptionList = Instance.new("ScrollingFrame")
                OptionList.BackgroundTransparency = 1
                OptionList.ScrollBarThickness = 2
                OptionList.Size = UDim2.new(1, -10, 1, -10)
                OptionList.Position = UDim2.new(0, 5, 0, 5)
                OptionList.Parent = DropdownOverlay

                local OptionLayout = Instance.new("UIListLayout")
                OptionLayout.Padding = UDim.new(0, 2)
                OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                OptionLayout.Parent = OptionList

                local function UpdateOptionListSize()
                    OptionList.CanvasSize = UDim2.new(0, 0, 0, OptionLayout.AbsoluteContentSize.Y)
                    DropdownOverlay.Size = UDim2.new(1, 0, 0, math.min(OptionLayout.AbsoluteContentSize.Y + 10, 150))
                end
                OptionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateOptionListSize)

                for _, option in ipairs(dropdownConfig.Options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Text = ""
                    OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    OptionButton.Size = UDim2.new(1, 0, 0, 30)
                    OptionButton.Parent = OptionList

                    local OptionLabel = Instance.new("TextLabel")
                    OptionLabel.Font = Enum.Font.Gotham
                    OptionLabel.Text = option
                    OptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptionLabel.TextSize = 13
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Center
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Size = UDim2.new(1, 0, 1, 0)
                    OptionLabel.Parent = OptionButton

                    OptionButton.Activated:Connect(function()
                        SelectedLabel.Text = option
                        dropdownConfig.Callback(option)
                        TweenService:Create(DropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.999 }):Play()
                        task.wait(0.2)
                        DropdownOverlay.Visible = false
                    end)
                end

                if dropdownConfig.Default then
                    dropdownConfig.Callback(dropdownConfig.Default)
                end

                DropdownButton.Activated:Connect(function()
                    DropdownOverlay.Visible = not DropdownOverlay.Visible
                    TweenService:Create(DropdownOverlay, TweenInfo.new(0.2), {
                        BackgroundTransparency = DropdownOverlay.Visible and 0.7 or 0.999
                    }):Play()
                end)

                OverlayButton.Activated:Connect(function()
                    TweenService:Create(DropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.999 }):Play()
                    task.wait(0.2)
                    DropdownOverlay.Visible = false
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

    return TabControls, GuiControls
end

return PixelLib
