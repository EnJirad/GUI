local Xlib = {}

function Xlib:MakeWindow(props)
    local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.Name = props.Name

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Size = UDim2.new(0, 400, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.Draggable = true
    mainFrame.Active = true

    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.Text = props.Name
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextSize = 18

    local window = {
        mainFrame = mainFrame,
        toggles = {},
        tabs = {}
    }

    function window:MakeTab(props)
        local tab = {
            name = props.Name,
            toggles = {}
        }

        function tab:AddToggle(toggleProps)
            local toggleButton = Instance.new("TextButton", mainFrame)
            toggleButton.Size = UDim2.new(0, 100, 0, 30)
            toggleButton.Position = UDim2.new(0, 10, 0, #self.toggles * 35 + 40)
            toggleButton.Text = toggleProps.Name
            toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleButton.Font = Enum.Font.SourceSans
            toggleButton.TextSize = 16
            toggleButton.MouseButton1Click:Connect(function()
                toggleProps.Callback(not toggleProps.Default)
            end)
            table.insert(self.toggles, toggleButton)
        end

        table.insert(window.tabs, tab)
        return tab
    end

    return window
end

return Xlib
