local PixelLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/EnJirad/GUI/refs/heads/main/Plib.lua"))()

-- Create main GUI
local Window = PixelLib:CreateGui({
    NameHub = "Pixel Hub",
    Description = "#VIP: Dungeon Heroes",
    Color = Color3.fromRGB(0, 140, 255),
    TabWidth = 140,
    SizeUI = UDim2.fromOffset(650, 450)
})

local TabControls = Window

-- Player Features Tab
local PlayerTab = TabControls:CreateTab({
    Name = "Player",
    Icon = "rbxassetid://7072719338"
})

-- Movement Section
local MovementSection = PlayerTab:AddSection("Movement", true)

local auto_G = true
MovementSection:AddToggle({
    Name = "Auto Farm",
    Default = auto_G,
    Callback = function(state)
        auto_G = state
        if auto_G then
            local placeId = game.PlaceId -- ดึง Game ID ปัจจุบัน

            if placeId == 94845773826960 then
                -- สำหรับเกม ID 94845773826960
                local args = {
                    "ForestDungeon",
                    6,
                    1,
                    false,
                    true,
                    {}
                }
                local remote = game:GetService("ReplicatedStorage")
                    :WaitForChild("Systems")
                    :WaitForChild("Parties")
                    :WaitForChild("SetSettings")
                remote:FireServer(unpack(args))
                
            elseif placeId == 81734311524009 then
                -- สำหรับเกม ID 81734311524009
                local remote = game:GetService("ReplicatedStorage")
                    :WaitForChild("Systems")
                    :WaitForChild("Dungeons")
                    :WaitForChild("TriggerStartDungeon")
                remote:FireServer()
            else
                warn("เกมนี้ยังไม่รองรับ Auto Farm")
            end
        end
    end
})

local guf = true
MovementSection:AddToggle({
    Name = "GUI",
    Default = guf,
    Callback = function(state)
        guf = state
        if guf then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/eselfins31/Valor-Hub/main/Dungeon%20Heroes/Unified_protected.lua"))()
            end)
            if not success then
                PixelLib:CreateNotification({
                    Title = "GUI Loader",
                    Description = "Failed",
                    Content = "Error loading GUI: " .. tostring(err),
                    Color = Color3.fromRGB(255, 0, 0)
                })
            else
                PixelLib:CreateNotification({
                    Title = "GUI Loader",
                    Description = "Success",
                    Content = "GUI loaded successfully",
                    Color = Color3.fromRGB(0, 255, 0)
                })
            end
        end
    end
})
