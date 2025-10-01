local PixelLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/EnJirad/GUI/refs/heads/main/Plib.lua"))()

-- Create main GUI with improved configuration
local Window = PixelLib:CreateGui({
    NameHub = "Pixel Hub",
    Description = "#VIP: Pixel Blade",
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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local myCharacter = player.Character or player.CharacterAdded:Wait()

local MobFreezeLoop = false
local mobLoop

-- เก็บสถานะมอนที่ถูกติดตาม
local activeMobs = {}

-- 🔹 Offset
local offsetX, offsetY, offsetZ = 0, 15, -10
local range = 200 -- ระยะรอบตัวเรา
MovementSection:AddSlider({ Name = "Mob Offset X", Min = -100, Max = 100, Default = offsetX, Callback = function(value) offsetX = value end })
MovementSection:AddSlider({ Name = "Mob Offset Y", Min = -100, Max = 100, Default = offsetY, Callback = function(value) offsetY = value end })
MovementSection:AddSlider({ Name = "Mob Offset Z", Min = -100, Max = 100, Default = offsetZ, Callback = function(value) offsetZ = value end })
MovementSection:AddSlider({ Name = "Mob Range", Min = 10, Max = 1000, Default = range, Callback = function(value) range = value end })

MovementSection:AddToggle({
    Name = "Freeze Mobs (PlatformStand)",
    Default = MobFreezeLoop,
    Callback = function(state)
        MobFreezeLoop = state

        if MobFreezeLoop and not mobLoop then
            mobLoop = RunService.RenderStepped:Connect(function()
                local myHumanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not myHumanoidRootPart then return end

                for _, obj in ipairs(workspace:GetChildren()) do
                    -- ข้ามผู้เล่น
                    if Players:GetPlayerFromCharacter(obj) then continue end
                    -- ข้าม "Shroom"
                    if string.sub(obj.Name,1,6) == "Shroom" then continue end

                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                        local mobHumanoid = obj:FindFirstChild("Humanoid")
                        local mobRoot = obj:FindFirstChild("HumanoidRootPart")

                        -- ตรวจสอบระยะ
                        local distance = (mobRoot.Position - myHumanoidRootPart.Position).Magnitude
                        if distance <= range then
                            -- 🔹 ปรับตำแหน่งก่อน
                            local targetPos = myHumanoidRootPart.Position + Vector3.new(offsetX, offsetY, offsetZ)
                            mobRoot.CFrame = CFrame.new(targetPos, mobRoot.Position + mobRoot.CFrame.LookVector)

                            -- 🔹 ตั้ง PlatformStand ถาวร
                            if not activeMobs[obj] then
                                mobHumanoid.PlatformStand = true
                                activeMobs[obj] = true
                            end
                        end
                    end
                end
            end)
        elseif not MobFreezeLoop and mobLoop then
            -- 🔹 คืนค่าปกติ
            mobLoop:Disconnect()
            mobLoop = nil

            for obj,_ in pairs(activeMobs) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local mobHumanoid = obj:FindFirstChild("Humanoid")
                    if mobHumanoid then
                        mobHumanoid.PlatformStand = false
                    end
                end
            end
            activeMobs = {}
        end
    end
})

local use_Ability = false
local abilities_mele = { "constellation", "ablaze","bloodSnowstorm", "slash", }
local abilities_magi = {"lightning", "solar", "sandTornado", "lunarSpell", "arcticWind", }
local abilities_use = {"blind", "clockwork", "boneStrength", "rejuvenate", "berserk"}
local abilities_cutgrade = {"constellation", "lightning", "solar"}
local abilities_set1 = {"ablaze", "lunarSpell", "sandTornado", "lightning", "solar", "blind", "rejuvenate", "berserk", "boneStrength",}
local abilities_one = {"lightning", "solar", "sandTornado","ablaze", "arcticWind","rejuvenate", "bloodThirst", "boneStrength",}
local abilities = {"voidGrip"}

local abilities_all = {
    "lightning", "solar", "clockwork", "blind", "constellation",
    "ablaze","bloodSnowstorm", "slash", "sandTornado", "lunarSpell",
    "arcticWind", "boneStrength", "rejuvenate", "berserk", "bloodThirst"
}

local use_Ability = false
local currentAbilityIndex = 1
local abilityLoop

MovementSection:AddToggle({
    Name = "Auto Skill (Per Frame)",
    Default = use_Ability,
    Callback = function(state)
        use_Ability = state

        if use_Ability and not abilityLoop then
            abilityLoop = game:GetService("RunService").RenderStepped:Connect(function()
                if not use_Ability then return end

                -- 🔹 ใช้สกิลตัวปัจจุบัน
                local ability = abilities_all[currentAbilityIndex]
                local args = { ability }
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(args))

                -- 🔹 เลื่อนไปสกิลถัดไป
                currentAbilityIndex = currentAbilityIndex + 1
                if currentAbilityIndex > #abilities_all then
                    currentAbilityIndex = 1 -- วนใหม่
                end
            end)
        elseif not use_Ability and abilityLoop then
            -- 🔹 ปิด loop
            abilityLoop:Disconnect()
            abilityLoop = nil
            currentAbilityIndex = 1
        end
    end
})

