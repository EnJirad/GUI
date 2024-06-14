-- Xlib.lua

local Xlib = {}

-- Function to create a window
function Xlib:MakeWindow(config)
    -- Default config values
    config = config or {}
    local defaultConfig = {
        Name = "Window",
        Size = UDim2.new(0, 400, 0, 300),
        Position = UDim2.new(0.5, -200, 0.5, -150),
        BackgroundColor = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 1,
        Parent = game:GetService("CoreGui")
    }
    for key, value in pairs(defaultConfig) do
        config[key] = config[key] or value
    end

    -- Create the main window frame
    local Window = Instance.new("Frame")
    Window.Name = config.Name
    Window.Size = config.Size
    Window.Position = config.Position
    Window.BackgroundColor3 = config.BackgroundColor
    Window.BorderColor3 = config.BorderColor
    Window.BorderSizePixel = config.BorderSizePixel
    Window.Parent = config.Parent

    -- Example method to create a tab
    function Window:MakeTab(tabConfig)
        tabConfig = tabConfig or {}
        local defaultTabConfig = {
            Name = "Tab",
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor = Color3.fromRGB(240, 240, 240),
            Parent = Window
        }
        for key, value in pairs(defaultTabConfig) do
            tabConfig[key] = tabConfig[key] or value
        end

        local Tab = Instance.new("Frame")
        Tab.Name = tabConfig.Name
        Tab.Size = tabConfig.Size
        Tab.Position = tabConfig.Position
        Tab.BackgroundColor3 = tabConfig.BackgroundColor
        Tab.Parent = tabConfig.Parent

        -- Example method to add a toggle control
        function Tab:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local defaultToggleConfig = {
                Name = "Toggle",
                Size = UDim2.new(0, 200, 0, 50),
                Position = UDim2.new(0.5, -100, 0.5, -25),
                BackgroundColor = Color3.fromRGB(200, 200, 200),
                TextColor = Color3.fromRGB(0, 0, 0),
                Parent = Tab
            }
            for key, value in pairs(defaultToggleConfig) do
                toggleConfig[key] = toggleConfig[key] or value
            end

            local Toggle = Instance.new("TextButton")
            Toggle.Name = toggleConfig.Name
            Toggle.Size = toggleConfig.Size
            Toggle.Position = toggleConfig.Position
            Toggle.BackgroundColor3 = toggleConfig.BackgroundColor
            Toggle.TextColor3 = toggleConfig.TextColor
            Toggle.Text = toggleConfig.Text or "Toggle"
            Toggle.Parent = toggleConfig.Parent

            -- Example callback for the toggle control
            function Toggle:SetValue(value)
                toggleConfig.Callback(value)
            end

            return Toggle
        end

        return Tab
    end

    return Window
end

return Xlib
