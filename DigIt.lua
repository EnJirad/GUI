local PixelLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/EnJirad/GUI/refs/heads/main/Plib.lua"))()

-- สร้าง GUI หลัก
local Window = PixelLib:CreateGui({
    NameHub = "Pixel Hub",
    Description = "#VIP : Dig It",
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

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDataSnapshot = require(ReplicatedStorage:WaitForChild("ClientSource"):WaitForChild("Systems"):WaitForChild("ClientDataSnapshot"))
local MagnetBoxData = require(ReplicatedStorage.Source.Data.MagnetBoxData)
local Network = require(ReplicatedStorage.Source.Network)
local module_5_upvr = require(ReplicatedStorage:WaitForChild("Settings"))
local Shovels_upvr = module_5_upvr.Items.Shovels
local EquipEquipmentRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("EquipEquipment")
local InventoryRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("Inventory")

local guf = true
MovementSection:AddToggle({
    Name = "GUI FrostByte",
    Default = guf,
    Callback = function(state)
        guf = state
        if guf then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://rawscripts.net/raw/SECRETS-Dig-it-V2-AUTO-FARM-GUI-29-FEATURES-27327"))()
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

-- ===== Open Magnet Box =====
local mg = true
MovementSection:AddToggle({
    Name = "เปิดกล่องแม่เหล็ก",
    Default = mg,
    Callback = function(state)
        mg = state
        if mg then
            while mg do
                local success, err = pcall(function()
                    local inventory = ClientDataSnapshot.Get("Inventory")
                    local magnetIndexes = {}

                    for i, v in inventory do
                        if MagnetBoxData[v.Name] and not v.Attributes.Pinned then
                            table.insert(magnetIndexes, i)
                        end
                    end

                    if #magnetIndexes > 0 then
                        for _, id in ipairs(magnetIndexes) do
                            Network:FireServer("OpenMagnetBox", id)
                            wait(0.1)
                        end
                    end
                end)
                if not success then
                    PixelLib:CreateNotification({
                        Title = "Open Magnet Box",
                        Description = "Error",
                        Content = "Error: " .. tostring(err),
                        Color = Color3.fromRGB(255, 0, 0)
                    })
                end
                wait(5)
            end
        end
    end
})

-- ===== Withdraw From Pet =====
local gp = true
MovementSection:AddToggle({
    Name = "เก็บของ จากสัตว์เลี้ยง",
    Default = gp,
    Callback = function(state)
        gp = state
        if gp then
            local petRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("WithdrawFromPet")
            while gp do
                local success, err = pcall(function()
                    petRemote:FireServer()
                    print("WithdrawFromPet fired ✅")
                end)
                if not success then
                    PixelLib:CreateNotification({
                        Title = "Withdraw From Pet",
                        Description = "Error",
                        Content = "Error: " .. tostring(err),
                        Color = Color3.fromRGB(255, 0, 0)
                    })
                end
                wait(60)
            end
        end
    end
})

-- ===== Get All Shovel IDs =====
local function GetAllShovelIDs()
    if not ClientDataSnapshot then
        warn("ClientDataSnapshot is not defined")
        return {}
    end

    local inventory = ClientDataSnapshot.Get("Inventory")
    if not inventory then
        warn("Inventory not found in ClientDataSnapshot")
        return {}
    end

    local shovelData = {}
    for id, item in pairs(inventory) do
        if (item.Type == "Shovel" or (item.Name and Shovels_upvr[item.Name])) then
            table.insert(shovelData, { ID = id, Name = item.Name })
        end
    end

    return shovelData
end

-- ===== Equip Shovel Select =====
local guiShovel = LocalPlayer.PlayerGui:WaitForChild("Main"):WaitForChild("Core"):WaitForChild("Equipment"):WaitForChild("BottomFrame"):WaitForChild("Shovels"):WaitForChild("ShovelFrame")
local ScrollingFrame = guiShovel:WaitForChild("ScrollingFrame")
local shovelOptions = {}
for _, frame in pairs(ScrollingFrame:GetChildren()) do
    if frame.ClassName == "Frame" then
        table.insert(shovelOptions, frame.Name)
    end
end

-- ฟังก์ชันบันทึก config (ชื่อ Shovel) ลงไฟล์ Pixle_config.txt
local function SaveShovelConfig(shovelName)
    if writefile then
        pcall(function()
            writefile("Pixle_config.txt", shovelName)
            PixelLib:CreateNotification({
                Title = "Config Saved",
                Description = "Success",
                Content = "Saved selected shovel: " .. shovelName,
                Color = Color3.fromRGB(0, 255, 0)
            })
        end)
    else
        PixelLib:CreateNotification({
            Title = "Config Error",
            Description = "Failed",
            Content = "writefile not supported in this executor",
            Color = Color3.fromRGB(255, 0, 0)
        })
    end
end

-- โหลด config จากไฟล์ Pixle_config.txt ถ้ามี
local selectedShovel = shovelOptions[1] or ""
if isfile and isfile("Pixle_config.txt") then
    local loadedShovel = readfile("Pixle_config.txt")
    if loadedShovel and table.find(shovelOptions, loadedShovel) then
        selectedShovel = loadedShovel
        PixelLib:CreateNotification({
            Title = "Config Loaded",
            Description = "Success",
            Content = "Loaded selected shovel: " .. selectedShovel,
            Color = Color3.fromRGB(0, 255, 0)
        })
    end
end

MovementSection:AddDropdown({
    Name = "Select Shovel",
    Options = shovelOptions,
    Default = selectedShovel,
    Callback = function(selected)
        selectedShovel = selected
        -- บันทึก config ทันทีเมื่อเปลี่ยนค่า
        SaveShovelConfig(selectedShovel)
    end
})

local equipShovelToggle = true
MovementSection:AddToggle({
    Name = "Equip Shovel Select",
    Default = equipShovelToggle,
    Callback = function(state)
        equipShovelToggle = state
        if equipShovelToggle then
            local success, err = pcall(function()
                if selectedShovel and selectedShovel ~= "" then
                    -- ติดตั้ง Shovel ด้วยชื่อผ่าน EquipEquipment
                    local args = { selectedShovel }
                    EquipEquipmentRemote:FireServer(unpack(args))
                    PixelLib:CreateNotification({
                        Title = "Equip Shovel",
                        Description = "Success",
                        Content = "Equipped Shovel (Name): " .. selectedShovel,
                        Color = Color3.fromRGB(0, 255, 0)
                    })

                    -- รอ 0.1 วินาที
                    wait(0.1)

                    -- ค้นหา ID ของ Shovel
                    local shovelData = GetAllShovelIDs()
                    local shovelID
                    for _, data in ipairs(shovelData) do
                        if data.Name == selectedShovel then
                            shovelID = data.ID
                            break
                        end
                    end

                    if shovelID then
                        -- ติดตั้ง Shovel ด้วย ID
                        local args = { { ID = shovelID, ShouldEquip = true, Command = "EquipItem" } }
                        InventoryRemote:FireServer(unpack(args))
                        PixelLib:CreateNotification({
                            Title = "Equip Shovel",
                            Description = "Success",
                            Content = "Equipped Shovel (ID): " .. shovelID,
                            Color = Color3.fromRGB(0, 255, 0)
                        })
                    else
                        PixelLib:CreateNotification({
                            Title = "Equip Shovel",
                            Description = "Error",
                            Content = "Shovel ID not found for: " .. selectedShovel,
                            Color = Color3.fromRGB(255, 0, 0)
                        })
                    end
                else
                    PixelLib:CreateNotification({
                        Title = "Equip Shovel",
                        Description = "Error",
                        Content = "No shovel selected",
                        Color = Color3.fromRGB(255, 0, 0)
                    })
                end
            end)
            if not success then
                PixelLib:CreateNotification({
                    Title = "Equip Shovel",
                    Description = "Error",
                    Content = "Error equipping shovel: " .. tostring(err),
                    Color = Color3.fromRGB(255, 0, 0)
                })
            end

            -- ทำซ้ำทุก 30 วินาทีด้วย ID
            while equipShovelToggle do
                local success, err = pcall(function()
                    if selectedShovel and selectedShovel ~= "" then
                        local shovelData = GetAllShovelIDs()
                        local shovelID
                        for _, data in ipairs(shovelData) do
                            if data.Name == selectedShovel then
                                shovelID = data.ID
                                break
                            end
                        end

                        if shovelID then
                            local args = { { ID = shovelID, ShouldEquip = true, Command = "EquipItem" } }
                            InventoryRemote:FireServer(unpack(args))
                            PixelLib:CreateNotification({
                                Title = "Equip Shovel",
                                Description = "Success",
                                Content = "Equipped Shovel (ID): " .. shovelID,
                                Color = Color3.fromRGB(0, 255, 0)
                            })
                        else
                            PixelLib:CreateNotification({
                                Title = "Equip Shovel",
                                Description = "Error",
                                Content = "Shovel ID not found for: " .. selectedShovel,
                                Color = Color3.fromRGB(255, 0, 0)
                            })
                        end
                    else
                        PixelLib:CreateNotification({
                            Title = "Equip Shovel",
                            Description = "Error",
                            Content = "No shovel selected",
                            Color = Color3.fromRGB(255, 0, 0)
                        })
                    end
                end)
                if not success then
                    PixelLib:CreateNotification({
                        Title = "Equip Shovel",
                        Description = "Error",
                        Content = "Error equipping shovel: " .. tostring(err),
                        Color = Color3.fromRGB(255, 0, 0)
                    })
                end
                wait(30)
            end
        end
    end
})

-- การแจ้งเตือนเมื่อเริ่มต้น
PixelLib:CreateNotification({
    Title = "PixelHub",
    Description = "System Ready",
    Content = "PixelHub for Dig It has been loaded successfully!",
    Color = Color3.fromRGB(0, 255, 0),
    Duration = 0.5,
    Delay = 6
})

return PixelLib
