-- Xlib.lua

local Xlib = {}

function Xlib:Create()
    local ui = {
        Windows = {}
    }

    function ui:MakeWindow(params)
        local window = {
            Name = params.Name or "Window",
            Tabs = {}
        }

        function window:MakeTab(params)
            local tab = {
                Name = params.Name or "Tab",
                Elements = {}
            }

            function tab:AddToggle(params)
                local toggle = {
                    Name = params.Name or "Toggle",
                    Default = params.Default or false,
                    Callback = params.Callback or function() end,
                    Value = params.Default or false
                }

                function toggle:SetValue(value)
                    toggle.Value = value
                    toggle.Callback(value)
                end

                table.insert(tab.Elements, toggle)
                return toggle
            end

            table.insert(window.Tabs, tab)
            return tab
        end

        table.insert(ui.Windows, window)
        return window
    end

    return ui
end

return Xlib
