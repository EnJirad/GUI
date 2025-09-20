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
local ClientDataSnapshot = require(ReplicatedStorage.ClientSource.Systems.ClientDataSnapshot)
local MagnetBoxData = require(ReplicatedStorage.Source.Data.MagnetBoxData)
local Network = require(ReplicatedStorage.Source.Network)

MovementSection:AddToggle({
    Name = "GUI FrostByte",
    Default = true,
    Callback = function(state)
        if state then
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
MovementSection:AddToggle({
    Name = "เปิดกล่องแม่เหล็ก",
    Default = true,
    Callback = function(state)
        if state then
            while state do
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
MovementSection:AddToggle({
    Name = "เก็บของ จากสัตว์เลี้ยง",
    Default = true,
    Callback = function(state)
        if state then
            local petRemote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("WithdrawFromPet")
            while state do
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
