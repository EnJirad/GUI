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
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local myCharacter = player.Character or player.CharacterAdded:Wait()

local MobSitLoop = false
local mobLoop

-- 🔹 Offset
local offsetX, offsetY, offsetZ = 0, 15, -10
MovementSection:AddSlider({ Name = "Mob Offset X", Min = -100, Max = 100, Default = offsetX, Callback = function(value) offsetX = value end })
MovementSection:AddSlider({ Name = "Mob Offset Y", Min = -100, Max = 100, Default = offsetY, Callback = function(value) offsetY = value end })
MovementSection:AddSlider({ Name = "Mob Offset Z", Min = -100, Max = 100, Default = offsetZ, Callback = function(value) offsetZ = value end })

MovementSection:AddToggle({
    Name = "Force Mobs Sit + Zero Gravity (Tween)",
    Default = MobSitLoop,
    Callback = function(state)
        MobSitLoop = state

        if MobSitLoop and not mobLoop then
            mobLoop = coroutine.create(function()
                while MobSitLoop do
                    for _, obj in ipairs(workspace:GetChildren()) do
                        -- 🔹 ข้ามตัวละครผู้เล่น
                        if Players:GetPlayerFromCharacter(obj) then
                            continue
                        end

                        -- 🔹 ข้าม "Shroom"
                        if string.sub(obj.Name,1,6) == "Shroom" then
                            continue
                        end

                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                            local mobHumanoid = obj:FindFirstChild("Humanoid")
                            local mobRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")

                            if mobRoot and mobHumanoid then
                                -- 🔹 บังคับนั่ง + ปิดแรงโน้มถ่วง
                                mobHumanoid.Sit = true
                                mobHumanoid.PlatformStand = true

                                -- กันไม่ให้ตก/หมุน
                                mobRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                                mobRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)

                                -- 🔹 Tween ตามตำแหน่ง
                                local myHumanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if myHumanoidRootPart then
                                    local targetPos = myHumanoidRootPart.Position + Vector3.new(offsetX, offsetY, offsetZ)

                                    if (mobRoot.Position - targetPos).Magnitude > 3 then -- ถ้าห่างเกิน 3 studs ค่อย Tween
                                        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                                        local tween = TweenService:Create(mobRoot, tweenInfo, { CFrame = CFrame.new(targetPos) })
                                        tween:Play()
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end

                -- 🔹 คืนค่าปกติเมื่อปิด
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                        local mobHumanoid = obj:FindFirstChild("Humanoid")
                        if mobHumanoid then
                            mobHumanoid.Sit = false
                            mobHumanoid.PlatformStand = false
                        end
                    end
                end

                mobLoop = nil
            end)
            coroutine.resume(mobLoop)
        else
            -- 🔹 คืนค่าปกติเมื่อปิด toggle
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local mobHumanoid = obj:FindFirstChild("Humanoid")
                    if mobHumanoid then
                        mobHumanoid.Sit = false
                        mobHumanoid.PlatformStand = false
                    end
                end
            end
            mobLoop = nil
        end
    end
})


local use_Ability = false
local abilities_all = {"lightning", "solar", "clockwork", "blind", "constellation"}
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
            for _, ability in ipairs(abilities_one) do
                local args = { ability }
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(args))
                wait(0.5) -- เว้นระยะเวลาระหว่างการใช้สกิล (ปรับได้)
            end
        end
    end
})
