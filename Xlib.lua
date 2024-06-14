-- Xlib.lua

local Xlib = {}

function Xlib:MakeWindow(params)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = params.Name or "Window"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local windowFrame = Instance.new("Frame")
    windowFrame.Size = UDim2.new(0, 400, 0, 300)
    windowFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    windowFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    windowFrame.BorderSizePixel = 0
    windowFrame.Parent = screenGui

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    titleLabel.BorderSizePixel = 0
    titleLabel.Text = params.Name or "Window"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24
    titleLabel.Parent = windowFrame

    local window = {}
    window.Name = params.Name or "Window"
    window.Tabs = {}
    window.Frame = windowFrame

    function window:MakeTab(params)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 0, 50)
        tabButton.Position = UDim2.new(#window.Tabs * 0.25, 0, 0, 50)
        tabButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        tabButton.BorderSizePixel = 0
        tabButton.Text = params.Name or "Tab"
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.Font = Enum.Font.SourceSans
        tabButton.TextSize = 18
        tabButton.Parent = windowFrame

        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1, 0, 1, -100)
        tabFrame.Position = UDim2.new(0, 0, 0, 100)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = windowFrame

        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(window.Tabs) do
                tab.Frame.Visible = false
            end
            tabFrame.Visible = true
        end)

        local tab = {}
        tab.Name = params.Name or "Tab"
        tab.Elements = {}
        tab.Frame = tabFrame

        function tab:AddToggle(params)
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 200, 0, 50)
            toggleButton.Position = UDim2.new(0, 10, 0, #tab.Elements * 60)
            toggleButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = params.Name or "Toggle"
            toggleButton.TextColor3 = Color3.new(1, 1, 1)
            toggleButton.Font = Enum.Font.SourceSans
            toggleButton.TextSize = 18
            toggleButton.Parent = tabFrame

            local toggle = {}
            toggle.Name = params.Name or "Toggle"
            toggle.Default = params.Default or false
            toggle.Callback = params.Callback or function() end
            toggle.Value = toggle.Default

            -- เพิ่มฟังก์ชัน Callback สำหรับ Toggle
            toggle.SetValue = function(self, value)
                self.Value = value
                toggle.Callback(value)
                if value then
                    toggleButton.BackgroundColor3 = Color3.new(0, 1, 0)
                else
                    toggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
                end
            end

            toggleButton.MouseButton1Click:Connect(function()
                toggle:SetValue(not toggle.Value)
            end)

            table.insert(tab.Elements, toggle)
            toggle:SetValue(toggle.Default)  -- ตั้งค่าเริ่มต้น

            return toggle
        end

        table.insert(window.Tabs, tab)
        return tab
    end

    return window
end

return Xlib
