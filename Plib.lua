local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Anti-AFK system
LocalPlayer.Idled:Connect(function()
    local success, err = pcall(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
    if not success then
        warn("Anti-AFK error: " .. tostring(err))
    end
end)

-- Function to create toggle button
local function CreateToggleButton()
    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("ImageButton")
    local Corner = Instance.new("UICorner")

    ScreenGui.Name = "ToggleGui"
    ScreenGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
    ToggleButton.Position = UDim2.new(0.1021, 0, 0.0743, 0)
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Image = "rbxassetid://98540636959380"
    ToggleButton.Visible = false

    Corner.Name = "ButtonCorner"
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = ToggleButton

    local isDragging = false
    local dragStart = nil
    local startPos = nil

    local function UpdatePosition(input)
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = ToggleButton.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    ToggleButton.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdatePosition(input)
        end
    end)

    return ToggleButton
end

local ToggleButton = CreateToggleButton()

-- Function to enable dragging
local function EnableDragging(topBar, frame)
    local isDragging = false
    local dragStart = nil
    local startPos = nil

    local function UpdateDragPosition(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

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
            UpdateDragPosition(input)
        end
    end)
end

-- Circle click effect
local function CreateCircleEffect(target, x, y)
    task.spawn(function()
        target.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "ClickEffect"
        Circle.Parent = target

        local offsetX = x - Circle.AbsolutePosition.X
        local offsetY = y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, offsetX, 0, offsetY)
        local size = math.max(target.AbsoluteSize.X, target.AbsoluteSize.Y) * 1.5

        local tweenTime = 0.5
        Circle:TweenSizeAndPosition(
            UDim2.new(0, size, 0, size),
            UDim2.new(0.5, -size / 2, 0.5, -size / 2),
            "Out",
            "Quad",
            tweenTime,
            false
        )
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            task.wait(tweenTime / 10)
        end
        Circle:Destroy()
    end)
end

-- PixelLib library
local PixelLib = {}
PixelLib.IsUnloaded = false

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
        local success, err = pcall(function()
            local NotifyGui = game:GetService("CoreGui"):FindFirstChild("NotifyGui") or Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = game:GetService("CoreGui")

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
                    if child:IsA("Frame") then
                        TweenService:Create(
                            child,
                            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                            { Position = UDim2.new(0, 0, 1, -((child.Size.Y.Offset + 12) * index)) }
                        ):Play()
                        index = index + 1
                    end
                end
            end)

            local offsetY = 0
            for _, child in NotifyContainer:GetChildren() do
                if child:IsA("Frame") then
                    offsetY = -child.Position.Y.Offset + child.Size.Y.Offset + 12
                end
            end

            local NotifyFrame = Instance.new("Frame")
            local NotifyContent = Instance.new("Frame")
            local ContentCorner = Instance.new("UICorner")
            local ShadowHolder = Instance.new("Frame")
            local DropShadow = Instance.new("ImageLabel")
            local TopBar = Instance.new("Frame")
            local TitleLabel = Instance.new("TextLabel")
            local TitleStroke = Instance.new("UIStroke")
            local TopCorner = Instance.new("UICorner")
            local DescLabel = Instance.new("TextLabel")
            local DescStroke = Instance.new("UIStroke")
            local CloseButton = Instance.new("TextButton")
            local CloseIcon = Instance.new("ImageLabel")
            local ContentLabel = Instance.new("TextLabel")

            NotifyFrame.BackgroundTransparency = 1
            NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
            NotifyFrame.Name = "NotifyFrame"
            NotifyFrame.AnchorPoint = Vector2.new(0, 1)
            NotifyFrame.Position = UDim2.new(0, 0, 1, -offsetY)
            NotifyFrame.Parent = NotifyContainer

            NotifyContent.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            NotifyContent.Position = UDim2.new(0, 400, 0, 0)
            NotifyContent.Size = UDim2.new(1, 0, 1, 0)
            NotifyContent.Name = "NotifyContent"
            NotifyContent.Parent = NotifyFrame

            ContentCorner.CornerRadius = UDim.new(0, 8)
            ContentCorner.Parent = NotifyContent

            ShadowHolder.BackgroundTransparency = 1
            ShadowHolder.Size = UDim2.new(1, 0, 1, 0)
            ShadowHolder.ZIndex = 0
            ShadowHolder.Name = "ShadowHolder"
            ShadowHolder.Parent = NotifyContent

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
            DropShadow.Name = "DropShadow"
            DropShadow.Parent = ShadowHolder

            TopBar.BackgroundTransparency = 1
            TopBar.Size = UDim2.new(1, 0, 0, 36)
            TopBar.Name = "TopBar"
            TopBar.Parent = NotifyContent

            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.Text = notify.Title
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Size = UDim2.new(1, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 10, 0, 0)
            TitleLabel.Parent = TopBar

            TitleStroke.Color = Color3.fromRGB(255, 255, 255)
            TitleStroke.Thickness = 0.3
            TitleStroke.Parent = TitleLabel

            TopCorner.CornerRadius = UDim.new(0, 5)
            TopCorner.Parent = TopBar

            DescLabel.Font = Enum.Font.GothamBold
            DescLabel.Text = notify.Description
            DescLabel.TextColor3 = notify.Color
            DescLabel.TextSize = 14
            DescLabel.TextXAlignment = Enum.TextXAlignment.Left
            DescLabel.BackgroundTransparency = 1
            DescLabel.Size = UDim2.new(1, 0, 1, 0)
            DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
            DescLabel.Parent = TopBar

            DescStroke.Color = notify.Color
            DescStroke.Thickness = 0.4
            DescStroke.Parent = DescLabel

            CloseButton.Font = Enum.Font.SourceSans
            CloseButton.Text = ""
            CloseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
            CloseButton.BackgroundTransparency = 1
            CloseButton.Position = UDim2.new(1, -5, 0.5, 0)
            CloseButton.Size = UDim2.new(0, 25, 0, 25)
            CloseButton.Name = "CloseButton"
            CloseButton.Parent = TopBar

            CloseIcon.Image = "rbxassetid://9886659671"
            CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            CloseIcon.BackgroundTransparency = 1
            CloseIcon.Position = UDim2.new(0.49, 0, 0.5, 0)
            CloseIcon.Size = UDim2.new(1, -8, 1, -8)
            CloseIcon.Parent = CloseButton

            ContentLabel.Font = Enum.Font.GothamBold
            ContentLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            ContentLabel.TextSize = 13
            ContentLabel.Text = notify.Content
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Position = UDim2.new(0, 10, 0, 27)
            ContentLabel.Size = UDim2.new(1, -20, 0, 13)
            ContentLabel.Parent = NotifyContent
            ContentLabel.TextWrapped = true

            NotifyFrame.Size = UDim2.new(1, 0, 0, ContentLabel.TextBounds.Y + 40)

            local isClosing = false
            function NotifyControls:Close()
                if isClosing then return end
                isClosing = true
                TweenService:Create(
                    NotifyContent,
                    TweenInfo.new(notify.Duration, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                    { Position = UDim2.new(0, 400, 0, 0) }
                ):Play()
                task.wait(notify.Duration / 1.2)
                NotifyFrame:Destroy()
            end

            CloseButton.Activated:Connect(NotifyControls.Close)

            TweenService:Create(
                NotifyContent,
                TweenInfo.new(notify.Duration, Enum.EasingStyle.Back, Enum.EasingDirection.InOut),
                { Position = UDim2.new(0, 0, 0, 0) }
            ):Play()
            task.wait(notify.Delay)
            NotifyControls:Close()
        end)
        if not success then
            warn("Notification creation error: " .. tostring(err))
        end
    end)
    return NotifyControls
end

-- Main GUI creation
function PixelLib:CreateGui(config)
    local guiConfig = config or {}
    guiConfig.NameHub = guiConfig.NameHub or "PixelHub"
    guiConfig.Description = guiConfig.Description or ""
    guiConfig.Color = guiConfig.Color or Color3.fromRGB(0, 132, 255)
    guiConfig.TabWidth = guiConfig.TabWidth or 120
    guiConfig.SizeUI = guiConfig.SizeUI or UDim2.fromOffset(550, 315)

    local GuiControls = {}
    local MainGui = Instance.new("ScreenGui")
    local ShadowHolder = Instance.new("Frame")
    local DropShadow = Instance.new("ImageLabel")
    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local TopBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local TopCorner = Instance.new("UICorner")
    local DescLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local CloseIcon = Instance.new("ImageLabel")
    local MinimizeButton = Instance.new("TextButton")
    local MinimizeIcon = Instance.new("ImageLabel")
    local TabContainer = Instance.new("Frame")
    local TabCorner = Instance.new("UICorner")
    local TabDivider = Instance.new("Frame")
    local ContentContainer = Instance.new("Frame")
    local ContentCorner = Instance.new("UICorner")
    local TabTitle = Instance.new("TextLabel")
    local ContentFrame = Instance.new("Frame")
    local TabPages = Instance.new("Folder")
    local PageLayout = Instance.new("UIPageLayout")

    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Name = "PixelHubGui"
    MainGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")

    ShadowHolder.BackgroundTransparency = 1
    ShadowHolder.Size = guiConfig.SizeUI
    ShadowHolder.ZIndex = 0
    ShadowHolder.Name = "ShadowHolder"
    ShadowHolder.Position = UDim2.new(0.5, -guiConfig.SizeUI.X.Offset / 2, 0.5, -guiConfig.SizeUI.Y.Offset / 2)
    ShadowHolder.Parent = MainGui

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
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = ShadowHolder

    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.Position = UDim2.new(0, 0, 0, 0)
    MainFrame.Size = guiConfig.SizeUI
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ShadowHolder

    MainCorner.Parent = MainFrame

    TopBar.BackgroundTransparency = 1
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame

    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = guiConfig.NameHub
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = TopBar

    TopCorner.Parent = TopBar

    DescLabel.Font = Enum.Font.GothamBold
    DescLabel.Text = guiConfig.Description
    DescLabel.TextColor3 = guiConfig.Color
    DescLabel.TextSize = 14
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.BackgroundTransparency = 1
    DescLabel.Size = UDim2.new(1, -(TitleLabel.TextBounds.X + 104), 1, 0)
    DescLabel.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    DescLabel.Parent = TopBar

    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.Text = ""
    CloseButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -8, 0.5, 0)
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar

    CloseIcon.Image = "rbxassetid://9886659671"
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Position = UDim2.new(0.49, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = CloseButton

    MinimizeButton.Font = Enum.Font.SourceSans
    MinimizeButton.Text = ""
    MinimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Position = UDim2.new(1, -42, 0.5, 0)
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TopBar

    MinimizeIcon.Image = "rbxassetid://9886659276"
    MinimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinimizeIcon.Size = UDim2.new(1, -8, 1, -8)
    MinimizeIcon.Parent = MinimizeButton

    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 9, 0, 50)
    TabContainer.Size = UDim2.new(0, guiConfig.TabWidth, 1, -59)
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame

    TabCorner.CornerRadius = UDim.new(0, 2)
    TabCorner.Parent = TabContainer

    TabDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabDivider.BackgroundTransparency = 0.85
    TabDivider.Position = UDim2.new(0.5, 0, 0, 38)
    TabDivider.Size = UDim2.new(1, 0, 0, 1)
    TabDivider.Name = "TabDivider"
    TabDivider.Parent = MainFrame

    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, guiConfig.TabWidth + 18, 0, 50)
    ContentContainer.Size = UDim2.new(1, -(guiConfig.TabWidth + 27), 1, -59)
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame

    ContentCorner.CornerRadius = UDim.new(0, 2)
    ContentCorner.Parent = ContentContainer

    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTitle.TextSize = 24
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.BackgroundTransparency = 1
    TabTitle.Size = UDim2.new(1, 0, 0, 30)
    TabTitle.Name = "TabTitle"
    TabTitle.Parent = ContentContainer

    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    ContentFrame.Position = UDim2.new(0, 0, 0, 33)
    ContentFrame.Size = UDim2.new(1, 0, 1, -33)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = ContentContainer

    TabPages.Name = "TabPages"
    TabPages.Parent = ContentFrame

    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.TweenTime = 0.5
    PageLayout.EasingDirection = Enum.EasingDirection.InOut
    PageLayout.EasingStyle = Enum.EasingStyle.Quad
    PageLayout.Parent = TabPages

    local TabList = Instance.new("ScrollingFrame")
    local TabLayout = Instance.new("UIListLayout")
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.ScrollBarThickness = 0
    TabList.Active = true
    TabList.BackgroundTransparency = 1
    TabList.Size = UDim2.new(1, 0, 1, -10)
    TabList.Name = "TabList"
    TabList.Parent = TabContainer

    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabList

    local function UpdateTabCanvas()
        local totalHeight = TabLayout.AbsoluteContentSize.Y + 10
        TabList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end

    TabList.ChildAdded:Connect(UpdateTabCanvas)
    TabList.ChildRemoved:Connect(UpdateTabCanvas)

    function GuiControls:DestroyGui()
        pcall(function()
            MainGui:Destroy()
            ToggleButton:Destroy()
            PixelLib.IsUnloaded = true
        end)
    end

    MinimizeButton.Activated:Connect(function()
        CreateCircleEffect(MinimizeButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        ShadowHolder.Visible = false
        ToggleButton.Visible = true
    end)

    ToggleButton.Activated:Connect(function()
        ShadowHolder.Visible = true
        ToggleButton.Visible = false
    end)

    CloseButton.Activated:Connect(function()
        CreateCircleEffect(CloseButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
        GuiControls:DestroyGui()
    end)

    EnableDragging(TopBar, ShadowHolder)

    local DropdownOverlay = Instance.new("Frame")
    DropdownOverlay.BackgroundTransparency = 1
    DropdownOverlay.ClipsDescendants = true
    DropdownOverlay.Position = UDim2.new(1, 8, 1, 8)
    DropdownOverlay.Size = UDim2.new(1, 154, 1, 54)
    DropdownOverlay.Visible = false
    DropdownOverlay.Name = "DropdownOverlay"
    DropdownOverlay.Parent = ContentContainer

    local OverlayShadowHolder = Instance.new("Frame")
    OverlayShadowHolder.BackgroundTransparency = 1
    OverlayShadowHolder.Size = UDim2.new(1, 0, 1, 0)
    OverlayShadowHolder.ZIndex = 0
    OverlayShadowHolder.Name = "OverlayShadowHolder"
    OverlayShadowHolder.Parent = DropdownOverlay

    local OverlayShadow = Instance.new("ImageLabel")
    OverlayShadow.Image = "rbxassetid://6015897843"
    OverlayShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    OverlayShadow.ImageTransparency = 0.5
    OverlayShadow.ScaleType = Enum.ScaleType.Slice
    OverlayShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    OverlayShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    OverlayShadow.BackgroundTransparency = 1
    OverlayShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    OverlayShadow.Size = UDim2.new(1, 35, 1, 35)
    OverlayShadow.ZIndex = 0
    OverlayShadow.Name = "OverlayShadow"
    OverlayShadow.Parent = OverlayShadowHolder

    local OverlayCorner = Instance.new("UICorner")
    OverlayCorner.Parent = DropdownOverlay

    local OverlayButton = Instance.new("TextButton")
    OverlayButton.Font = Enum.Font.SourceSans
    OverlayButton.Text = ""
    OverlayButton.BackgroundTransparency = 1
    OverlayButton.Size = UDim2.new(1, 0, 1, 0)
    OverlayButton.Name = "OverlayButton"
    OverlayButton.Parent = DropdownOverlay

    local TabControls = {}
    local tabIndex = 0

    function TabControls:CreateTab(tabConfig)
        local tab = tabConfig or {}
        tab.Name = tab.Name or "Tab"
        tab.Icon = tab.Icon or ""

        local TabContent = Instance.new("ScrollingFrame")
        local ContentLayout = Instance.new("UIListLayout")
        TabContent.ScrollBarThickness = 0
        TabContent.Active = true
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Name = "TabContent"
        TabContent.Parent = TabPages
        TabContent.LayoutOrder = tabIndex

        ContentLayout.Padding = UDim.new(0, 3)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
        end)

        local TabButtonFrame = Instance.new("Frame")
        local TabButton = Instance.new("TextButton")
        local TabLabel = Instance.new("TextLabel")
        local TabIcon = Instance.new("ImageLabel")

        TabButtonFrame.BackgroundTransparency = tabIndex == 0 and 0.92 or 1
        TabButtonFrame.LayoutOrder = tabIndex
        TabButtonFrame.Size = UDim2.new(1, 0, 0, 30)
        TabButtonFrame.Name = "TabButtonFrame"
        TabButtonFrame.Parent = TabList

        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = ""
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 1, 0)
        TabButton.Name = "TabButton"
        TabButton.Parent = TabButtonFrame

        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.Text = tab.Name
        TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Position = UDim2.new(0, 30, 0, 0)
        TabLabel.Size = UDim2.new(1, 0, 1, 0)
        TabLabel.Name = "TabLabel"
        TabLabel.Parent = TabButtonFrame

        TabIcon.Image = tab.Icon
        TabIcon.BackgroundTransparency = 1
        TabIcon.Position = UDim2.new(0, 9, 0, 7)
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Name = "TabIcon"
        TabIcon.Parent = TabButtonFrame

        if tabIndex == 0 then
            PageLayout:JumpToIndex(0)
            TabTitle.Text = tab.Name
            local TabIndicator = Instance.new("Frame")
            TabIndicator.BackgroundColor3 = guiConfig.Color
            TabIndicator.Position = UDim2.new(0, 2, 0, 9)
            TabIndicator.Size = UDim2.new(0, 1, 0, 12)
            TabIndicator.Name = "TabIndicator"
            TabIndicator.Parent = TabButtonFrame
        end

        TabButton.Activated:Connect(function()
            CreateCircleEffect(TabButton, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
            local currentIndicator = TabList:FindFirstChildOfClass("Frame"):FindFirstChild("TabIndicator")
            if currentIndicator and TabButtonFrame.LayoutOrder ~= PageLayout.CurrentPage.LayoutOrder then
                for _, tabFrame in TabList:GetChildren() do
                    if tabFrame:IsA("Frame") then
                        TweenService:Create(tabFrame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                    end
                end
                TweenService:Create(TabButtonFrame, TweenInfo.new(0.6), { BackgroundTransparency = 0.92 }):Play()
                TweenService:Create(currentIndicator, TweenInfo.new(0.5), { Position = UDim2.new(0, 2, 0, 9 + (33 * TabButtonFrame.LayoutOrder)) }):Play()
                PageLayout:JumpToIndex(TabButtonFrame.LayoutOrder)
                TabTitle.Text = tab.Name
                task.wait(0.05)
                TweenService:Create(currentIndicator, TweenInfo.new(0.35), { Size = UDim2.new(0, 1, 0, 20) }):Play()
                task.wait(0.2)
                TweenService:Create(currentIndicator, TweenInfo.new(0.25), { Size = UDim2.new(0, 1, 0, 12) }):Play()
            end
        end)

        local SectionControls = {}
        local sectionIndex = 0

        function SectionControls:AddSection(title)
            local sectionTitle = title or "Section"

            local SectionFrame = Instance.new("Frame")
            local SectionHeader = Instance.new("Frame")
            local HeaderButton = Instance.new("TextButton")
            local SectionTitleLabel = Instance.new("TextLabel")
            local SectionDivider = Instance.new("Frame")
            local SectionContent = Instance.new("Frame")
            local ContentPadding = Instance.new("UIPadding")
            local ContentList = Instance.new("UIListLayout")

            SectionFrame.BackgroundTransparency = 1
            SectionFrame.LayoutOrder = sectionIndex
            SectionFrame.ClipsDescendants = true
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.Name = "SectionFrame"
            SectionFrame.Parent = TabContent

            SectionHeader.BackgroundTransparency = 0.935
            SectionHeader.Position = UDim2.new(0.5, 0, 0, 0)
            SectionHeader.Size = UDim2.new(1, 1, 0, 30)
            SectionHeader.Name = "SectionHeader"
            SectionHeader.Parent = SectionFrame

            HeaderButton.Font = Enum.Font.SourceSans
            HeaderButton.Text = ""
            HeaderButton.BackgroundTransparency = 1
            HeaderButton.Size = UDim2.new(1, 0, 1, 0)
            HeaderButton.Name = "HeaderButton"
            HeaderButton.Parent = SectionHeader

            SectionTitleLabel.Font = Enum.Font.GothamBold
            SectionTitleLabel.Text = sectionTitle
            SectionTitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
            SectionTitleLabel.TextSize = 13
            SectionTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitleLabel.BackgroundTransparency = 1
            SectionTitleLabel.Position = UDim2.new(0, 10, 0.5, 0)
            SectionTitleLabel.Size = UDim2.new(1, -50, 0, 13)
            SectionTitleLabel.Name = "SectionTitleLabel"
            SectionTitleLabel.Parent = SectionHeader

            SectionDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionDivider.Position = UDim2.new(0.5, 0, 0, 33)
            SectionDivider.Size = UDim2.new(1, 0, 0, 2)
            SectionDivider.Name = "SectionDivider"
            SectionDivider.Parent = SectionFrame

            SectionContent.BackgroundTransparency = 1
            SectionContent.Position = UDim2.new(0, 0, 0, 35)
            SectionContent.Size = UDim2.new(1, 0, 0, 0)
            SectionContent.Name = "SectionContent"
            SectionContent.Parent = SectionFrame

            ContentPadding.PaddingLeft = UDim.new(0, 10)
            ContentPadding.PaddingRight = UDim.new(0, 10)
            ContentPadding.PaddingTop = UDim.new(0, 5)
            ContentPadding.Parent = SectionContent

            ContentList.Padding = UDim.new(0, 5)
            ContentList.SortOrder = Enum.SortOrder.LayoutOrder
            ContentList.Parent = SectionContent

            local function UpdateSectionSize()
                local contentHeight = ContentList.AbsoluteContentSize.Y + ContentPadding.PaddingTop.Offset
                SectionFrame.Size = UDim2.new(1, 0, 0, contentHeight + 35)
                TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y)
            end

            SectionContent.ChildAdded:Connect(UpdateSectionSize)
            SectionContent.ChildRemoved:Connect(UpdateSectionSize)

            local ElementControls = {}

            function ElementControls:AddButton(config)
                local buttonConfig = config or {}
                buttonConfig.Name = buttonConfig.Name or "Button"
                buttonConfig.Callback = buttonConfig.Callback or function() end

                local ButtonFrame = Instance.new("Frame")
                local Button = Instance.new("TextButton")
                local ButtonLabel = Instance.new("TextLabel")

                ButtonFrame.BackgroundTransparency = 0.95
                ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
                ButtonFrame.Name = "ButtonFrame"
                ButtonFrame.Parent = SectionContent

                Button.Font = Enum.Font.SourceSans
                Button.Text = ""
                Button.BackgroundTransparency = 1
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Name = "Button"
                Button.Parent = ButtonFrame

                ButtonLabel.Font = Enum.Font.GothamBold
                ButtonLabel.Text = buttonConfig.Name
                ButtonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ButtonLabel.TextSize = 13
                ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
                ButtonLabel.BackgroundTransparency = 1
                ButtonLabel.Position = UDim2.new(0, 10, 0, 0)
                ButtonLabel.Size = UDim2.new(1, -20, 1, 0)
                ButtonLabel.Name = "ButtonLabel"
                ButtonLabel.Parent = ButtonFrame

                Button.MouseButton1Click:Connect(function()
                    CreateCircleEffect(Button, LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y)
                    local success, err = pcall(buttonConfig.Callback)
                    if not success then
                        warn("Button callback error: " .. tostring(err))
                    end
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
                local ToggleButton = Instance.new("TextButton")
                local ToggleLabel = Instance.new("TextLabel")
                local ToggleIndicator = Instance.new("Frame")

                ToggleFrame.BackgroundTransparency = 0.95
                ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
                ToggleFrame.Name = "ToggleFrame"
                ToggleFrame.Parent = SectionContent

                ToggleButton.Font = Enum.Font.SourceSans
                ToggleButton.Text = ""
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = ToggleFrame

                ToggleLabel.Font = Enum.Font.GothamBold
                ToggleLabel.Text = toggleConfig.Name
                ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Parent = ToggleFrame

                ToggleIndicator.BackgroundColor3 = toggleConfig.Default and guiConfig.Color or Color3.fromRGB(80, 80, 80)
                ToggleIndicator.Position = UDim2.new(1, -35, 0.5, -8)
                ToggleIndicator.Size = UDim2.new(0, 25, 0, 16)
                ToggleIndicator.Name = "ToggleIndicator"
                ToggleIndicator.Parent = ToggleFrame

                local isToggled = toggleConfig.Default

                if isToggled then
                    local success, err = pcall(toggleConfig.Callback, isToggled)
                    if not success then
                        warn("Toggle initial callback error: " .. tostring(err))
                    end
                end

                ToggleButton.MouseButton1Click:Connect(function()
                    isToggled = not isToggled
                    TweenService:Create(
                        ToggleIndicator,
                        TweenInfo.new(0.2),
                        { BackgroundColor3 = isToggled and guiConfig.Color or Color3.fromRGB(80, 80, 80) }
                    ):Play()
                    local success, err = pcall(toggleConfig.Callback, isToggled)
                    if not success then
                        warn("Toggle callback error: " .. tostring(err))
                    end
                end)

                UpdateSectionSize()
                return ToggleButton
            end

            function ElementControls:AddSlider(config)
                local sliderConfig = config or {}
                sliderConfig.Name = sliderConfig.Name or "Slider"
                sliderConfig.Min = sliderConfig.Min or 0
                sliderConfig.Max = sliderConfig.Max or 100
                sliderConfig.Default = sliderConfig.Default or 0
                sliderConfig.Callback = sliderConfig.Callback or function() end

                local SliderFrame = Instance.new("Frame")
                local SliderLabel = Instance.new("TextLabel")
                local SliderBar = Instance.new("Frame")
                local SliderFill = Instance.new("Frame")
                local SliderButton = Instance.new("TextButton")
                local ValueLabel = Instance.new("TextLabel")

                SliderFrame.BackgroundTransparency = 0.95
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = SectionContent

                SliderLabel.Font = Enum.Font.GothamBold
                SliderLabel.Text = sliderConfig.Name
                SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Position = UDim2.new(0, 10, 0, 0)
                SliderLabel.Size = UDim2.new(1, -20, 0, 20)
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Parent = SliderFrame

                SliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                SliderBar.Position = UDim2.new(0, 10, 0, 25)
                SliderBar.Size = UDim2.new(1, -60, 0, 6)
                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderFrame

                SliderFill.BackgroundColor3 = guiConfig.Color
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderBar

                SliderButton.Font = Enum.Font.SourceSans
                SliderButton.Text = ""
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.Name = "SliderButton"
                SliderButton.Parent = SliderBar

                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.Text = tostring(sliderConfig.Default)
                ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                ValueLabel.TextSize = 12
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Position = UDim2.new(1, -40, 0, 20)
                ValueLabel.Size = UDim2.new(0, 30, 0, 20)
                ValueLabel.Name = "ValueLabel"
                ValueLabel.Parent = SliderFrame

                local function UpdateSlider(input)
                    local barSize = SliderBar.AbsoluteSize.X
                    local mouseX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, barSize)
                    local value = sliderConfig.Min + (mouseX / barSize) * (sliderConfig.Max - sliderConfig.Min)
                    value = math.floor(value + 0.5)
                    SliderFill.Size = UDim2.new(mouseX / barSize, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    local success, err = pcall(sliderConfig.Callback, value)
                    if not success then
                        warn("Slider callback error: " .. tostring(err))
                    end
                end

                local defaultPercent = (sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                SliderFill.Size = UDim2.new(defaultPercent, 0, 1, 0)
                ValueLabel.Text = tostring(sliderConfig.Default)
                pcall(sliderConfig.Callback, sliderConfig.Default)

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
                dropdownConfig.Default = dropdownConfig.Default or ""
                dropdownConfig.Callback = dropdownConfig.Callback or function() end

                local DropdownMainFrame = Instance.new("Frame")
                local DropdownButton = Instance.new("TextButton")
                local DropdownLabel = Instance.new("TextLabel")
                local SelectedLabel = Instance.new("TextLabel")
                local ArrowIcon = Instance.new("ImageLabel")

                DropdownMainFrame.BackgroundTransparency = 0.95
                DropdownMainFrame.Size = UDim2.new(1, 0, 0, 30)
                DropdownMainFrame.Name = "DropdownMainFrame"
                DropdownMainFrame.Parent = SectionContent

                DropdownButton.Font = Enum.Font.SourceSans
                DropdownButton.Text = ""
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = DropdownMainFrame

                DropdownLabel.Font = Enum.Font.GothamBold
                DropdownLabel.Text = dropdownConfig.Name
                DropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
                DropdownLabel.Name = "DropdownLabel"
                DropdownLabel.Parent = DropdownMainFrame

                SelectedLabel.Font = Enum.Font.GothamBold
                SelectedLabel.Text = dropdownConfig.Default
                SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                SelectedLabel.TextSize = 13
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Position = UDim2.new(0, 0, 0, 0)
                SelectedLabel.Size = UDim2.new(1, -40, 1, 0)
                SelectedLabel.Name = "SelectedLabel"
                SelectedLabel.Parent = DropdownMainFrame

                ArrowIcon.Image = "rbxassetid://16851841101"
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Position = UDim2.new(1, -25, 0.5, -8)
                ArrowIcon.Size = UDim2.new(0, 16, 0, 16)
                ArrowIcon.Rotation = -90
                ArrowIcon.Name = "ArrowIcon"
                ArrowIcon.Parent = DropdownMainFrame

                local DropdownFrame = Instance.new("Frame")
                local DropdownContent = Instance.new("Frame")
                local OptionList = Instance.new("ScrollingFrame")
                local OptionLayout = Instance.new("UIListLayout")

                DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                DropdownFrame.Position = UDim2.new(1, 172, 0.5, 0)
                DropdownFrame.Size = UDim2.new(0, 160, 0, 150)
                DropdownFrame.Name = "DropdownFrame_" .. dropdownConfig.Name
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = DropdownOverlay

                DropdownContent.BackgroundTransparency = 1
                DropdownContent.Position = UDim2.new(0.5, 0, 0.5, 0)
                DropdownContent.Size = UDim2.new(1, -10, 1, -10)
                DropdownContent.Name = "DropdownContent"
                DropdownContent.Parent = DropdownFrame

                OptionList.CanvasSize = UDim2.new(0, 0, 0, 0)
                OptionList.ScrollBarThickness = 4
                OptionList.BackgroundTransparency = 1
                OptionList.Size = UDim2.new(1, 0, 1, 0)
                OptionList.Name = "OptionList"
                OptionList.Parent = DropdownContent

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
                    local OptionLabel = Instance.new("TextLabel")

                    OptionButton.BackgroundTransparency = 0.95
                    OptionButton.Size = UDim2.new(1, 0, 0, 30)
                    OptionButton.Name = "OptionButton"
                    OptionButton.Parent = OptionList

                    OptionLabel.Font = Enum.Font.GothamBold
                    OptionLabel.Text = option
                    OptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptionLabel.TextSize = 13
                    OptionLabel.TextXAlignment = Enum.TextXAlignment.Center
                    OptionLabel.BackgroundTransparency = 1
                    OptionLabel.Size = UDim2.new(1, 0, 1, 0)
                    OptionLabel.Name = "OptionLabel"
                    OptionLabel.Parent = OptionButton

                    OptionButton.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = option
                        local success, err = pcall(dropdownConfig.Callback, option)
                        if not success then
                            warn("Dropdown callback error: " .. tostring(err))
                        end
                        TweenService:Create(DropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
                        task.wait(0.2)
                        DropdownOverlay.Visible = false
                    end)
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    if not DropdownOverlay.Visible then
                        DropdownOverlay.Visible = true
                        TweenService:Create(DropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.7 }):Play()
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, -8, 0.5, 0) }):Play()
                        UpdateOptionListSize()
                    end
                end)

                OverlayButton.Activated:Connect(function()
                    if DropdownOverlay.Visible then
                        TweenService:Create(DropdownOverlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), { Position = UDim2.new(1, 172, 0.5, 0) }):Play()
                        task.wait(0.2)
                        DropdownOverlay.Visible = false
                    end
                end)

                if dropdownConfig.Default ~= "" then
                    pcall(dropdownConfig.Callback, dropdownConfig.Default)
                end

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
