-- Xlib.lua

local Xlib = {}

function Xlib:MakeWindow(config)
    local window = {
        Name = config.Name or "Window",
        Tabs = {},
        MakeTab = function(self, tabConfig)
            local tab = {
                Name = tabConfig.Name or "Tab",
                Icon = tabConfig.Icon or "",
                Toggles = {},
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
    }
    return window
end

return Xlib
