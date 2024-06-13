local Xlib = {}

function Xlib:MakeWindow(config)
    local gui = Instance.new("ScreenGui")
    gui.Parent = game.Players.LocalPlayer.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.6, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui

    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.9, 0, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BorderSizePixel = 0
    closeButton.Parent = mainFrame

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Text = "_"
    minimizeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    minimizeButton.Position = UDim2.new(0.8, 0, 0, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    minimizeButton.TextColor3 = Color3.new(1, 1, 1)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Parent = mainFrame

    local leftTabBar = Instance.new("Frame")
    leftTabBar.Size = UDim2.new(0.2, 0, 1, 0)
    leftTabBar.Position = UDim2.new(0, 0, 0, 0)
    leftTabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    leftTabBar.BorderSizePixel = 0
    leftTabBar.Parent = mainFrame

    local window = {
        gui = gui,
        mainFrame = mainFrame,
        closeButton = closeButton,
        minimizeButton = minimizeButton,
        leftTabBar = leftTabBar
    }

    function window:MakeTab(tabConfig)
        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(0.8, 0, 1, 0)
        tabFrame.Position = UDim2.new(0.2, 0, 0, 0)
        tabFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        tabFrame.BorderSizePixel = 0
        tabFrame.Visible = false
        tabFrame.Parent = self.mainFrame

        local tabButton = Instance.new("TextButton")
        tabButton.Text = tabConfig.Name
        tabButton.Size = UDim2.new(1, 0, 0.1, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.BorderSizePixel = 0
        tabButton.Parent = self.leftTabBar

        local tabContent = {
            tabFrame = tabFrame,
            tabButton = tabButton
        }

        function tabContent:AddToggle(toggleConfig)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(0.2, 0, 0.1, 0)
            toggleFrame.Position = UDim2.new(0.75, 0, 0.1 * #tabFrame:GetChildren(), 0)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabFrame

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Text = toggleConfig.Name
            toggleLabel.Size = UDim2.new(0.8, 0, 1, 0)
            toggleLabel.Position = UDim2.new(0.2, 0, 0, 0)
            toggleLabel.TextColor3 = Color3.new(1, 1, 1)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Parent = toggleFrame

            local toggleButton = Instance.new("TextButton")
            toggleButton.Text = "Off"
            toggleButton.Size = UDim2.new(0.2, 0, 1, 0)
            toggleButton.Position = UDim2.new(0, 0, 0, 0)
            toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            toggleButton.TextColor3 = Color3.new(1, 1, 1)
            toggleButton.BorderSizePixel = 0
            toggleButton.Parent = toggleFrame

            local toggled = toggleConfig.Default

            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                if toggled then
                    toggleButton.Text = "On"
                    toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                else
                    toggleButton.Text = "Off"
                    toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
                toggleConfig.Callback(toggled)
            end)

            return toggleButton
        end

        return tabContent
    end

    return window
end

return Xlib
