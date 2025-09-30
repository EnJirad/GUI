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
local player = Players.LocalPlayer
local myCharacter = player.Character or player.CharacterAdded:Wait()
local myHumanoidRootPart = myCharacter:WaitForChild("HumanoidRootPart")

local Mob_tp = false
local mobLoop

-- 🔹 ค่าระยะเริ่มต้นของมอน
local offsetX, offsetY, offsetZ = -5, 13, 3

-- 🔹 Slider สำหรับปรับระยะ X/Y/Z
MovementSection:AddSlider({
    Name = "Mob Offset X",
    Min = -50,
    Max = 50,
    Default = offsetX,
    Callback = function(value)
        offsetX = value
    end
})
MovementSection:AddSlider({
    Name = "Mob Offset Y",
    Min = 0,
    Max = 50,
    Default = offsetY,
    Callback = function(value)
        offsetY = value
    end
})
MovementSection:AddSlider({
    Name = "Mob Offset Z",
    Min = -50,
    Max = 50,
    Default = offsetZ,
    Callback = function(value)
        offsetZ = value
    end
})

MovementSection:AddToggle({
    Name = "Warp Mobs Above Head (Sit + Zero Gravity)",
    Default = Mob_tp,
    Callback = function(state)
        Mob_tp = state

        if Mob_tp and not mobLoop then
            mobLoop = coroutine.create(function()
                while Mob_tp do
                    for _, obj in ipairs(workspace:GetChildren()) do
                        -- 🔹 ข้ามตัวละครผู้เล่นทุกคน
                        if Players:GetPlayerFromCharacter(obj) then
                            continue
                        end

                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                            local mobHumanoid = obj:FindFirstChild("Humanoid")
                            local mobRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                            if mobRoot and mobHumanoid then
                                -- 🔹 ให้มอนนั่งก่อน
                                mobHumanoid.Sit = true

                                -- 🔹 ปิดแรงโน้มถ่วงของมอน
                                mobHumanoid.PlatformStand = true
                                
                                -- 🔹 ตั้ง Velocity = 0 เพื่อไม่ให้ตก
                                mobRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                
                                -- 🔹 ตำแหน่งเหนือหัว + Offset จาก Slider
                                local targetPos = myHumanoidRootPart.Position + Vector3.new(offsetX, offsetY, offsetZ)
                                mobRoot.CFrame = CFrame.new(targetPos)
                            end
                        end
                    end
                    task.wait(0.1)
                end

                -- 🔹 ปิด toggle → ให้มอนลุกขึ้น + เปิด Gravity
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
        elseif not Mob_tp then
            -- 🔹 ปิด toggle ระหว่าง loop → ให้มอนลุกขึ้น + เปิด Gravity
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
local abilities_mele = { "constellation", "ablaze","bloodSnowstorm", "slash", "ablaze",}
local abilities_magi = {"lightning", "solar", "sandTornado", "lunarSpell",}
local abilities_use = {"blind", "clockwork", "boneStrength", "rejuvenate", "berserk"}
local abilities_cutgrade = {"constellation", "lightning", "solar"}
local abilities = {"constellation", "lightning", "solar", "rejuvenate", "berserk", "boneStrength",}


MovementSection:AddToggle({
    Name = "Auto Skill",
    Default = use_Ability,
    Callback = function(state)
        use_Ability = state
        while use_Ability do
            for _, ability in ipairs(abilities) do
                local args = { ability }
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("useAbility"):FireServer(unpack(args))
                wait(0.5) -- เว้นระยะเวลาระหว่างการใช้สกิล (ปรับได้)
            end
        end
    end
})
