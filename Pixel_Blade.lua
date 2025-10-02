local PixelLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/EnJirad/GUI/refs/heads/main/Plib.lua"))()

-- Create main GUI
local Window = PixelLib:CreateGui({
    NameHub = "Pixel Hub",
    Description = "#VIP: Pixel Blade",
    Color = Color3.fromRGB(0, 140, 255),
    TabWidth = 140,
    SizeUI = UDim2.fromOffset(650, 450)
})

local TabControls = Window
local PlayerTab = TabControls:CreateTab({
    Name = "Player",
    Icon = "rbxassetid://7072719338"
})
local MovementSection = PlayerTab:AddSection("Movement", true)

-- =====================
-- ⚡ Replay Games
-- =====================
local replay_g = false
MovementSection:AddToggle({
    Name = "Replay Games",
    Default = replay_g,
    Callback = function(state)
        replay_g = state

        if replay_g then
            task.spawn(function()
                while replay_g do
                    local args = { "replay" }
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("remotes")
                        :WaitForChild("gameEndVote")
                        :FireServer(unpack(args))

                    task.wait(2)
                end
            end)
        end
    end
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ตัวแปร offset สำหรับฟาร์มมอน
local offsetX, offsetY, offsetZ = 0, 25, 30
MovementSection:AddSlider({ Name = "Mob Offset X", Min = -100, Max = 100, Default = offsetX, Callback = function(v) offsetX = v end })
MovementSection:AddSlider({ Name = "Mob Offset Y", Min = -100, Max = 100, Default = offsetY, Callback = function(v) offsetY = v end })
MovementSection:AddSlider({ Name = "Mob Offset Z", Min = -100, Max = 100, Default = offsetZ, Callback = function(v) offsetZ = v end })

-- =========================
-- Auto Farm Toggle
-- =========================
local MobFreezeLoop = false
local mobLoop

-- ลิสต์มอนมิตร
local friendlyMobs = {
    "GoldenPhantom","GiantInfernoGuardian","GiantSkeleton","GiantWizard","GiantZombie",
    "NecromancerGhoul","ShroomArcher","ShroomKnight","ShroomPaladin"
}

-- ลิสต์มอนศัตรู
local enemyMobs = {
    "Archer","Bolt","CannonGoblin","CursedArcher","CursedGiantGoblin","CursedLumberJack",
    "CursedZombie","DarkBolt","DarkMage","DoubleCannonGoblin","Giant","GiantGoblin",
    "Kingslayer","LumberJack","Mage","MegaGiant","MegaMortarGoblin","MortarGoblin",
    "Zombie","Atticus","AtticusOLD","BomberGoblin","DesertArcher","Guardian","Maneater",
    "ManeaterOLD","Mummy","Nekros","Skeleton","SniperSkeleton","TNTSkull","TombstoneGoblin",
    "Wizard","DarkTombstoneGoblin","InfernoWizard","InfernoGuardian","CorruptSkeleton",
    "CorruptDesertArcher","CorruptSniperSkeleton","DarkNekros","DarkBomberGoblin","SunsetMummy",
    "NightWatcher","Ashinaga","MiniCorruptIceGolem","ShadowKnight","Ghoul","CorruptShadowKnight",
    "MiniIceGolemOld","CorruptIceGolem","FrostGoblin","IglooGoblin","CorruptYeti","AkumaOLD",
    "ElderSorcerer","Kori","IceDragon","Akuma","MountainGolem","CorruptGhoul","Yeti",
    "CorruptAshinaga","MiniCorruptIceGolemOld","CorruptNightWatcher","CorruptFrostGoblin",
    "CorruptIglooGoblin","Sorcerer","CorruptSorcerer","IceGolem","MiniIceGolem","ShimBomboYeti",
    "CorruptShimBomboYeti","CorruptAkuma"
}

-- แปลงลิสต์เป็น set เพื่อเช็คเร็ว
local friendlySet = {}
for _, name in pairs(friendlyMobs) do friendlySet[name] = true end
local enemySet = {}
for _, name in pairs(enemyMobs) do enemySet[name] = true end

MovementSection:AddToggle({
    Name = "Auto Farm",
    Default = MobFreezeLoop,
    Callback = function(state)
        MobFreezeLoop = state

        if MobFreezeLoop and not mobLoop then
            mobLoop = RunService.Heartbeat:Connect(function()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("Model") then
                        local mobName = obj.Name

                        -- ข้ามมอนมิตร
                        if friendlySet[mobName] then continue end
                        -- ข้ามมอนที่ไม่ใช่ศัตรู
                        if not enemySet[mobName] then continue end

                        local hadEntrance = obj:GetAttribute("hadEntrance")
                        if hadEntrance == true then
                            local mobHRP = obj:FindFirstChild("HumanoidRootPart")
                            if mobHRP then
                                mobHRP.CFrame = CFrame.new(hrp.Position + Vector3.new(offsetX, offsetY, offsetZ))
                            end
                        end
                    end
                end
            end)
        elseif not MobFreezeLoop and mobLoop then
            mobLoop:Disconnect()
            mobLoop = nil
        end
    end
})

-- =========================
-- Auto Farm
-- =========================
local AutoWarpLoop = false
local warpLoop

MovementSection:AddToggle({
    Name = "Auto Warp",
    Default = AutoWarpLoop,
    Callback = function(state)
        AutoWarpLoop = state

        if AutoWarpLoop and not warpLoop then
            warpLoop = task.spawn(function()
                while AutoWarpLoop do
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then 
                        task.wait(1)
                        continue
                    end

                    -- สร้าง roomList ภายในฟังก์ชัน dynamic
                    local mainRooms = {"Small_odd", "Small_even", "Medium_even", "Medium_odd"}
                    local roomList = {}
                    for _, name in ipairs(mainRooms) do table.insert(roomList, name) end
                    for _, roomObj in ipairs(workspace:GetChildren()) do
                        if roomObj:IsA("Model") and string.find(roomObj.Name, "BossFight") then
                            table.insert(roomList, roomObj.Name)
                        end
                    end

                    local mobsTrue = {}
                    local mobsFalse = {}

                    -- วนเช็คเฉพาะมอนศัตรู
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj:IsA("Model") then
                            local mobName = obj.Name
                            if friendlySet[mobName] then continue end
                            if not enemySet[mobName] then continue end

                            local attr = obj:GetAttribute("hadEntrance")
                            if attr == true then
                                table.insert(mobsTrue, obj)
                            elseif attr == false then
                                table.insert(mobsFalse, obj)
                            end
                        end
                    end

                    -- ถ้ามีมอน hadEntrance true → อยู่รอที่ Tp ของห้องเดิม
                    if #mobsTrue > 0 then
                        task.wait(5)
                        continue
                    end

                    if #mobsFalse > 0 then
                        -- หา nearest room จากมอนตัวแรก
                        local targetMob = mobsFalse[1]
                        local mobPivot = targetMob:GetPivot() or targetMob:FindFirstChild("HumanoidRootPart")
                        if mobPivot then
                            local nearestRoom = nil
                            local nearestDist = math.huge
                            for _, roomName in ipairs(roomList) do
                                local room = workspace:FindFirstChild(roomName)
                                if room and room:FindFirstChild("fightZone") then
                                    local dist = (mobPivot.Position - room.fightZone.Position).Magnitude
                                    if dist < nearestDist then
                                        nearestDist = dist
                                        nearestRoom = room
                                    end
                                end
                            end

                            if nearestRoom then
                                -- ตรวจสอบว่าห้องเป็น BossFight หรือไม่
                                local lastZoneName = string.find(nearestRoom.Name, "BossFight") and "FLOOR" or "Tp"
                                local sequence = {"ExitZone", "fightZone", lastZoneName}

                                for _, zoneName in ipairs(sequence) do
                                    local zone = nearestRoom:FindFirstChild(zoneName)
                                    if zone and zone.Position then
                                        pcall(function()
                                            hrp.CFrame = CFrame.new(zone.Position + Vector3.new(0,5,0))
                                        end)
                                        task.wait(1)
                                    end
                                end
                            end
                        end
                    else
                        -- ไม่มีมอนเลย → วาปไปห้องเลขสูงสุด
                        local maxRoomNum = 0
                        local targetPos = nil
                        for _, roomObj in ipairs(workspace:GetChildren()) do
                            if roomObj:IsA("Model") and tonumber(roomObj.Name) then
                                local num = tonumber(roomObj.Name)
                                if num > maxRoomNum then
                                    maxRoomNum = num
                                    local roomRoot = roomObj:FindFirstChild("Root")
                                    if roomRoot then
                                        targetPos = roomRoot.Position
                                    end
                                end
                            end
                        end
                        if targetPos then
                            pcall(function()
                                hrp.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                            end)
                        end
                    end

                    task.wait(5)
                end
            end)
        elseif not AutoWarpLoop and warpLoop then
            warpLoop:Cancel()
            warpLoop = nil
        end
    end
})

-- =====================
-- ⚡ Auto Skill
-- =====================
local abilities_mele = { "constellation","slash", }
local abilities_magi = {"lightning", "solar", "sandTornado", "lunarSpell", "arcticWind", "gemstone", "bloodSnowstorm",}
local abilities_use = {"boneStrength", "rejuvenate", "berserk", "bloodThirst", "frozenWall", "ablaze", "voidGrip",}
local abilities_other = {"voidGrip", "raiseTheDead", "goldenArmy", "CosmicVision", "Oblivion", "blackHole", "cosmicBeam"}

local abilities_all1 = {
    "raiseTheDead"
}

local abilities_all = {
    "lightning","solar", "arcticWind","bloodSnowstorm",
    "rejuvenate","bloodThirst","frozenWall", "ablaze", "voidGrip",
    "DeathGrasp", "Oblivion", "raiseTheDead","goldenArmy","CosmicVision","blackHole","cosmicBeam",
}
local use_Ability = false
local currentAbilityIndex, abilityLoop = 1, nil

MovementSection:AddToggle({
    Name = "Auto Skill (Interval)",
    Default = use_Ability,
    Callback = function(state)
        use_Ability = state
        if use_Ability and not abilityLoop then
            abilityLoop = RunService.Heartbeat:Connect(function()
                task.wait(0.3) -- ยิงสกิลทุก 0.3 วิ
                if not use_Ability then return end
                local ability = abilities_all[currentAbilityIndex]
                if ability then
                    game.ReplicatedStorage.remotes.useAbility:FireServer(ability)
                end
                currentAbilityIndex = currentAbilityIndex + 1
                if currentAbilityIndex > #abilities_all then
                    currentAbilityIndex = 1
                end
            end)
        elseif not use_Ability and abilityLoop then
            abilityLoop:Disconnect()
            abilityLoop = nil
            currentAbilityIndex = 1
        end
    end
})
