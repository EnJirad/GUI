local Xlib = {}

function Xlib:MakeWindow(WindowConfig)
    -- สร้างหน้าต่างตาม WindowConfig ที่รับเข้ามา
    local Window = {
        Name = WindowConfig.Name or "Window",
        HidePremium = WindowConfig.HidePremium or false,
        SaveConfig = WindowConfig.SaveConfig or false,
        ConfigFolder = WindowConfig.ConfigFolder or "DefaultConfigFolder"
    }

    local function MakeTab(TabConfig)
        -- ฟังก์ชันสำหรับสร้างแท็บ
        local Tab = {
            Name = TabConfig.Name or "Tab",
            Icon = TabConfig.Icon or "",
            PremiumOnly = TabConfig.PremiumOnly or false
        }

        local function AddToggle(ToggleConfig)
            -- ฟังก์ชันสำหรับเพิ่ม Toggle Control
            local Toggle = {
                Name = ToggleConfig.Name or "Toggle",
                Default = ToggleConfig.Default or false,
                Callback = ToggleConfig.Callback or function() end
            }
            -- ใส่โค้ดสำหรับการเพิ่ม Toggle Control ที่นี่ (เช่น GUI และการจัดการ Event)
            print("Added toggle:", Toggle.Name)
        end

        Tab.AddToggle = AddToggle
        return Tab
    end

    Window.MakeTab = MakeTab
    return Window
end

return Xlib
