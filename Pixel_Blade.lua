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

local MobSitLoop = false
local mobLoop

-- เก็บสถานะมอนที่ถูก Sit แล้ว
local activeMobs = {}

-- 🔹 Offset
local offsetX, offsetY, offsetZ = 0, 15, -10
MovementSection:AddSlider({ Name = "Mob Offset X", Min = -100, Max = 100, Default = offsetX, Callback = function(value) offsetX = value end })
MovementSection:AddSlider({ Name = "Mob Offset Y", Min = -100, Max = 100, Default = offsetY, Callback = function(value) offsetY = value end })
MovementSection:AddSlider({ Name = "Mob Offset Z", Min = -100, Max = 100, Default = offsetZ, Callback = function(value) offsetZ = value end })

MovementSection:AddToggle({
    Name = "Force Mobs",
    Default = MobSitLoop,
    Callback = function(state)
        MobSitLoop = state

        if MobSitLoop and not mobLoop then
            -- รันทุกเฟรม
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

                        -- 🔹 ถ้ามอนนี้ยังไม่ถูก Sit → ปรับสถานะและบันทึก
                        if not activeMobs[obj] then
                            mobHumanoid.Sit = true
                            activeMobs[obj] = true
                        end

                        -- 🔹 ปรับ CFrame ของ HumanoidRootPart ให้มาใกล้เรา + Offset
                        local targetPos = myHumanoidRootPart.Position + Vector3.new(offsetX, offsetY, offsetZ)
                        mobRoot.CFrame = CFrame.new(targetPos, mobRoot.Position + mobRoot.CFrame.LookVector)
                    end
                end
            end)
        elseif not MobSitLoop and mobLoop then
            -- 🔹 คืนค่าปกติ
            mobLoop:Disconnect()
            mobLoop = nil

            for obj,_ in pairs(activeMobs) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local mobHumanoid = obj:FindFirstChild("Humanoid")
                    if mobHumanoid then
                        mobHumanoid.Sit = false
                    end
                end
            end
            activeMobs = {}
        end
    end
})



local use_Ability = false
local abilities_all = {"lightning", "solar", "clockwork", "blind", "constellation","ablaze","bloodSnowstorm", "slash", "sandTornado", "lunarSpell", "arcticWind", "boneStrength", "rejuvenate", "berserk", "bloodThirst", }
local abilities_mele = { "constellation", "ablaze","bloodSnowstorm", "slash", }
local abilities_magi = {"lightning", "solar", "sandTornado", "lunarSpell", "arcticWind", }
local abilities_use = {"blind", "clockwork", "boneStrength", "rejuvenate", "berserk"}
local abilities_cutgrade = {"constellation", "lightning", "solar"}
local abilities_set1 = {"ablaze", "lunarSpell", "sandTornado", "lightning", "solar", "blind", "rejuvenate", "berserk", "boneStrength",}
local abilities_one = {"lightning", "solar", "sandTornado","ablaze", "arcticWind","rejuvenate", "bloodThirst", "boneStrength",}
local abilities = {"bloodThirst"}

MovementSection:AddToggle({
    Name = "Auto Skill",
    Default = use_Ability,
    Callback = function(state)
        use_Ability = state
        while use_Ability do
            for _, ability in ipairs(abilities_all) do
                local args = { ability }
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(args))
                wait(0.5) -- เว้นระยะเวลาระหว่างการใช้สกิล (ปรับได้)
            end
        end
    end
})
