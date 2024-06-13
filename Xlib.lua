-- Xlib.lua

local Xlib = {}

function Xlib:MakeWindow(config)
    local window = {
        Name = config.Name or "Window",
        Tabs = {},
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 400, 0, 300),
        Minimized = false,
        MakeTab = function(self, tabConfig)
            local tab = {
                Name = tabConfig.Name or "Tab",
                Icon = tabConfig.Icon or "",
                Toggles = {},
                Buttons = {},
                AddToggle = function(self, toggleConfig)
                    local toggle = {
                        Name = toggleConfig.Name or "Toggle",
                        Default = toggleConfig.Default or false,
                        Callback = toggleConfig.Callback or function() end,
                    }
                    table.insert(self.Toggles, toggle)
                    return toggle
                end,
                AddButton = function(self, buttonConfig)
                    local button = {
                        Name = buttonConfig.Name or "Button",
                        Callback = buttonConfig.Callback or function() end,
                    }
                    table.insert(self.Buttons, button)
                    return button
                end,
            }
            table.insert(self.Tabs, tab)
            return tab
        end,
        Render = function(self, parent)
            local frame = Instance.new("Frame")
            frame.Name = self.Name
            frame.Position = self.Position
            frame.Size = self.Size
            frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            frame.BorderSizePixel = 0
            frame.Visible = not self.Minimized
            frame.Parent = parent

            local dragArea = Instance.new("Frame")
            dragArea.Name = "DragArea"
            dragArea.Size = UDim2.new(1, 0, 0, 30)
            dragArea.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            dragArea.BorderSizePixel = 0
            dragArea.Parent = frame

            local titleLabel = Instance.new("TextLabel")
            titleLabel.Name = "TitleLabel"
            titleLabel.Text = self.Name
            titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            titleLabel.TextSize = 18
            titleLabel.Font = Enum.Font.SourceSans
            titleLabel.Size = UDim2.new(1, -10, 1, 0)
            titleLabel.Position = UDim2.new(0, 5, 0, 0)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = dragArea

            local minimizeButton = Instance.new("TextButton")
            minimizeButton.Name = "MinimizeButton"
            minimizeButton.Text = "-"
            minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            minimizeButton.BackgroundTransparency = 1
            minimizeButton.Size = UDim2.new(0, 30, 0, 30)
            minimizeButton.Position = UDim2.new(1, -30, 0, 0)
            minimizeButton.Parent = dragArea
            minimizeButton.MouseButton1Click:Connect(function()
                self.Minimized = not self.Minimized
                frame.Visible = not self.Minimized
            end)

            local closeButton = Instance.new("TextButton")
            closeButton.Name = "CloseButton"
            closeButton.Text = "X"
            closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeButton.BackgroundTransparency = 1
            closeButton.Size = UDim2.new(0, 30, 0, 30)
            closeButton.Position = UDim2.new(1, -60, 0, 0)
            closeButton.Parent = dragArea
            closeButton.MouseButton1Click:Connect(function()
                frame:Destroy()
            end)

            local tabContainer = Instance.new("Frame")
            tabContainer.Name = "TabContainer"
            tabContainer.Size = UDim2.new(1, 0, 1, -30)
            tabContainer.Position = UDim2.new(0, 0, 0, 30)
            tabContainer.BackgroundTransparency = 1
            tabContainer.Parent = frame

            -- Render tabs
            local tabButtons = {}
            for i, tab in ipairs(self.Tabs) do
                local tabButton = Instance.new("TextButton")
                tabButton.Name = "TabButton" .. i
                tabButton.Text = tab.Name
                tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                tabButton.BackgroundTransparency = 1
                tabButton.Size = UDim2.new(0, 100, 1, 0)
                tabButton.Position = UDim2.new(0, (i - 1) * 100, 0, 0)
                tabButton.Parent = tabContainer

                local tabContent = Instance.new("Frame")
                tabContent.Name = "TabContent" .. i
                tabContent.Size = UDim2.new(1, 0, 1, 0)
                tabContent.Position = UDim2.new(0, 0, 0, 0)
                tabContent.BackgroundTransparency = 1
                tabContent.Parent = tabContainer

                if i == 1 then
                    tabButton.TextColor3 = Color3.fromRGB(0, 162, 255)
                    tabContent.Visible = true
                else
                    tabContent.Visible = false
                end

                tabButton.MouseButton1Click:Connect(function()
                    -- Toggle tab content visibility
                    for _, content in ipairs(tabContainer:GetChildren()) do
                        if content.Name == "TabContent" .. i then
                            content.Visible = true
                        else
                            content.Visible = false
                        end
                    end

                    -- Toggle tab button colors
                    for _, button in ipairs(tabButtons) do
                        if button.Name == "TabButton" .. i then
                            button.TextColor3 = Color3.fromRGB(0, 162, 255)
                        else
                            button.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end)

                table.insert(tabButtons, tabButton)
            end

            -- Draggable functionality
            local dragging
            local dragInput
            local dragStart
            local startPos

            local function update(input)
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end

            dragArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position

                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)

            dragArea.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)

            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    update(input)
                end
            end)

            return frame
        end,
    }
    return window
end

return Xlib
