local Xlib = {}
Xlib.__index = Xlib

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local userId = player.UserId

-- Create the main window
function Xlib:MakeWindow(props)
    local self = setmetatable({}, Xlib)
    
    -- Create the screen GUI
    self.screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    self.screenGui.Name = "Xlib"
    
    -- Create the main frame
    self.mainFrame = Instance.new("Frame", self.screenGui)
    self.mainFrame.Size = UDim2.new(0, 400, 0, 350)
    self.mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.mainFrame.Draggable = true
    self.mainFrame.Active = true
    local mainFrameUICorner = Instance.new("UICorner", self.mainFrame)
    mainFrameUICorner.CornerRadius = UDim.new(0, 10)
    
    -- Create the title bar
    local titleBar = Instance.new("Frame", self.mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    
    local titleBarBg = Instance.new("Frame", titleBar)
    titleBarBg.Size = UDim2.new(1, 0, 1, 0)
    titleBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    local titleBarUICorner = Instance.new("UICorner", titleBarBg)
    titleBarUICorner.CornerRadius = UDim.new(0, 10)
    
    self.titleLabel = Instance.new("TextLabel", titleBar)
    self.titleLabel.Size = UDim2.new(1, -60, 1, 0)
    self.titleLabel.Position = UDim2.new(0, 10, 0, 5)
    self.titleLabel.Text = props.Name
    self.titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.titleLabel.BackgroundTransparency = 1
    self.titleLabel.Font = Enum.Font.SourceSans
    self.titleLabel.TextSize = 18
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton", titleBar)
    minimizeButton.Size = UDim2.new(0, 20, 0, 20)
    minimizeButton.Position = UDim2.new(1, -55, 0, 5)
    minimizeButton.Text = "-"
    minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Font = Enum.Font.SourceSans
    minimizeButton.TextSize = 16
    minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    -- Close button
    local closeButton = Instance.new("TextButton", titleBar)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.Text = "X"
    closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 16
    closeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Tab frame
    self.tabFrame = Instance.new("ScrollingFrame", self.mainFrame)
    self.tabFrame.Size = UDim2.new(0, 100, 1, -80)
    self.tabFrame.Position = UDim2.new(0, 10, 0, 40)
    self.tabFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    self.tabFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    self.tabFrame.ScrollBarThickness = 8
    
    -- Toggle frame
    self.toggleFrame = Instance.new("ScrollingFrame", self.mainFrame)
    self.toggleFrame.Size = UDim2.new(0, 280, 1, -80)
    self.toggleFrame.Position = UDim2.new(0, 110, 0, 40)
    self.toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    self.toggleFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
    self.toggleFrame.ScrollBarThickness = 8
    
    -- Bottom bar
    local bottomBar = Instance.new("Frame", self.mainFrame)
    bottomBar.Size = UDim2.new(1, 0, 0, 40)
    bottomBar.Position = UDim2.new(0, 0, 1, -40)
    bottomBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    
    local profilePicture = Instance.new("ImageLabel", bottomBar)
    profilePicture.Size = UDim2.new(0, 50, 0, 50)
    profilePicture.Position = UDim2.new(0, 0, 0.5, -25)
    profilePicture.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    profilePicture.Image = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=420&h=420"
    profilePicture.BackgroundTransparency = 1
    
    local playerName = Instance.new("TextLabel", bottomBar)
    playerName.Size = UDim2.new(0, 200, 0, 20)
    playerName.Position = UDim2.new(0, 60, 0, 10)
    playerName.Text = "Name: " .. player.Name
    playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerName.BackgroundTransparency = 1
    playerName.Font = Enum.Font.SourceSans
    playerName.TextSize = 14
    
    local playerId = Instance.new("TextLabel", bottomBar)
    playerId.Size = UDim2.new(0, 200, 0, 20)
    playerId.Position = UDim2.new(0, 60, 0, 20)
    playerId.Text = "ID: " .. userId
    playerId.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerId.BackgroundTransparency = 1
    playerId.Font = Enum.Font.SourceSans
    playerId.TextSize = 14
    
    self.tabs = {}
    
    return self
end

function Xlib:ToggleMinimize()
    if self.minimized then
        self.mainFrame.Visible = true
        if self.minimizedIcon then
            self.minimizedIcon:Destroy()
        end
        self.minimized = false
    else
        self.mainFrame.Visible = false
        self.minimizedIcon = Instance.new("TextButton", self.screenGui)
        self.minimizedIcon.Size = UDim2.new(0, 35, 0, 35)
        self.minimizedIcon.Position = UDim2.new(0, 35, 0, 35)
        self.minimizedIcon.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        self.minimizedIcon.Text = "O"
        self.minimizedIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        self.minimizedIcon.Font = Enum.Font.SourceSans
        self.minimizedIcon.TextSize = 24
        self.minimizedIcon.Draggable = true
        self.minimizedIcon.Active = true
        self.minimizedIcon.MouseButton1Click:Connect(function()
            self:ToggleMinimize()
        end)
        self.minimized = true
    end
end

function Xlib:Close()
    self.screenGui:Destroy()
end

-- Create a tab
function Xlib:MakeTab(props)
    local tab = {}
    tab.toggles = {}
    table.insert(self.tabs, tab)
    
    local tabButton = Instance.new("TextButton", self.tabFrame)
    tabButton.Size = UDim2.new(1, -10, 0, 30)
    tabButton.Position = UDim2.new(0, 5, 0, (#self.tabs-1) * 35 + 5)
    tabButton.Text = props.Name
    tabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 16
    
    tabButton.MouseButton1Click:Connect(function()
        self.toggleFrame.CanvasSize = UDim2.new(0, 0, 0, #tab.toggles * 35 + 5)
    for _, child in ipairs(self.toggleFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for i, toggle in ipairs(tab.toggles) {
        local toggleButton = Instance.new("TextButton", self.toggleFrame)
        toggleButton.Size = UDim2.new(1, -10, 0, 30)
        toggleButton.Position = UDim2.new(0, 5, 0, (i-1) * 35 + 5)
        toggleButton.Text = toggle.Name
        toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.Font = Enum.Font.SourceSans
        toggleButton.TextSize = 16
        toggleButton.MouseButton1Click:Connect(function()
            toggle.Callback(not toggle.Default)
        end)
    end
end)

function tab:AddToggle(props)
    local toggle = {}
    toggle.Name = props.Name
    toggle.Default = props.Default
    toggle.Callback = props.Callback
    table.insert(self.toggles, toggle)
end

return tab
end

return Xlib
