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
local replay_g = true
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
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local player = Players.LocalPlayer

-- =========================
-- Auto Farm Toggle (Adaptive Smooth Tween + Auto Offset + Soft Lock + Collisions)
-- =========================

local friendlyMobs = { "GoldenPhantom","GiantInfernoGuardian","GiantSkeleton","GiantWizard","GiantZombie",
    "NecromancerGhoul","ShroomArcher","ShroomKnight","ShroomPaladin" }

local enemyMobs = { "GiantGoblin","CursedGiantGoblin","LumberJack","CursedLumberJack","Kingslayer",
    "ShimBomboYeti","CorruptShimBomboYeti","Akuma","CorruptAkuma","AkumaOLD","IceDragon",
    "Zombie","CursedZombie","Archer","CursedArcher","Giant","MegaGiant","Mage","DarkMage",
    "CannonGoblin","DoubleCannonGoblin","MortarGoblin","MegaMortarGoblin","Bolt","DarkBolt",
    "Atticus","AtticusOLD","Ghoul","CorruptGhoul","NightWatcher","CorruptNightWatcher","Yeti","CorruptYeti",
    "FrostGoblin","CorruptFrostGoblin","IceGolem","CorruptIceGolem","MiniIceGolem","MiniIceGolemOld",
    "MiniCorruptIceGolem","MiniCorruptIceGolemOld","MountainGolem","IglooGoblin","CorruptIglooGoblin",
    "Ashinaga","CorruptAshinaga","ShadowKnight","CorruptShadowKnight","Sorcerer","CorruptSorcerer",
    "ElderSorcerer","Kori","BomberGoblin","DesertArcher","Guardian","Maneater","ManeaterOLD",
    "Mummy","Nekros","Skeleton","SniperSkeleton","TNTSkull","TombstoneGoblin","Wizard",
    "DarkTombstoneGoblin","InfernoWizard","InfernoGuardian","CorruptSkeleton","CorruptDesertArcher",
    "CorruptSniperSkeleton","DarkNekros","DarkBomberGoblin","SunsetMummy" }

local friendlySet, enemySet = {}, {}
for _, name in pairs(friendlyMobs) do friendlySet[name] = true end
for _, name in pairs(enemyMobs) do enemySet[name] = true end

local MobFreezeLoop = true
local mobLoop

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
                        if friendlySet[mobName] then continue end
                        if not enemySet[mobName] then continue end

                        local hadEntrance = obj:GetAttribute("hadEntrance")
                        if hadEntrance == true then
                            local mobHRP = obj:FindFirstChild("HumanoidRootPart")
                            local humanoid = obj:FindFirstChildWhichIsA("Humanoid")
                            if mobHRP and humanoid then
                                -- ลบ BodyVelocity เดิม
                                if mobHRP:FindFirstChild("BodyVelocity") then
                                    mobHRP.BodyVelocity:Destroy()
                                end

                                -- ตั้ง CollisionGroup ให้ทะลุ Default
                                for _, part in ipairs(obj:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                        PhysicsService:SetPartCollisionGroup(part, "enemies")
                                    end
                                end

                                -- Auto Offset dynamic
                                local mobSize = mobHRP.Size
                                local baseOffset = Vector3.new(0, 25, 20)
                                local targetPos = hrp.Position + Vector3.new(baseOffset.X, baseOffset.Y, baseOffset.Z + mobSize.Z)

                                -- Adaptive Tween
                                local distance = (targetPos - mobHRP.Position).Magnitude
                                local walkSpeed = humanoid.WalkSpeed
                                local tweenTime = math.clamp(distance / walkSpeed, 0.1, 0.5)

                                local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
                                local tween = TweenService:Create(mobHRP, tweenInfo, {CFrame = CFrame.new(targetPos)})

                                tween.Completed:Connect(function()
                                    -- Soft Lock
                                    if not mobHRP:FindFirstChild("BodyVelocity") then
                                        local bv = Instance.new("BodyVelocity")
                                        bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                                        bv.P = 1e5
                                        bv.Velocity = Vector3.new(0,0,0)
                                        bv.Parent = mobHRP
                                    end
                                end)

                                tween:Play()
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


local AutoWarpLoop = true
local warpLoop

local lastRoomName = nil
local stuckCount = 0
local superStuck = 0
local roomBlacklist = {}

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

                    -- สร้าง roomList dynamic
                    local mainRooms = {"Small_odd", "Small_even", "Medium_even", "Medium_odd"}
                    local roomList = {}
                    for _, name in ipairs(mainRooms) do table.insert(roomList, name) end
                    for _, roomObj in ipairs(workspace:GetChildren()) do
                        if roomObj:IsA("Model") and string.find(roomObj.Name, "BossFight") then
                            table.insert(roomList, roomObj.Name)
                        end
                    end

                    -- ตรวจจับมอน
                    local mobsTrue, mobsFalse = {}, {}
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

                    -- ถ้ามีมอน hadEntrance true → รอ
                    if #mobsTrue > 0 then
                        task.wait(5)
                        continue
                    end

                    -- เลือกห้อง
                    local chosenRoom = nil
                    if #mobsFalse > 0 then
                        local nearestRoom, nearestDist = nil, math.huge
                        for _, mob in ipairs(mobsFalse) do
                            local mobPivot = mob:GetPivot() or mob:FindFirstChild("HumanoidRootPart")
                            if mobPivot then
                                for _, roomName in ipairs(roomList) do
                                    local room = workspace:FindFirstChild(roomName)
                                    if room and room:FindFirstChild("fightZone") and not roomBlacklist[room.Name] then
                                        local dist = (mobPivot.Position - room.fightZone.Position).Magnitude
                                        if dist < nearestDist then
                                            nearestDist = dist
                                            nearestRoom = room
                                        end
                                    end
                                end
                            end
                        end
                        chosenRoom = nearestRoom
                    end

                    -- เช็ค stuck
                    if chosenRoom then
                        if lastRoomName == chosenRoom.Name then
                            stuckCount += 1

                            if stuckCount >= 1 then
                                stuckCount = 0
                                superStuck += 1

                                if superStuck >= 2 then
                                    if #mobsFalse > 0 then
                                        local fallbackRoom = mobsFalse[1]
                                        local pivot = fallbackRoom:GetPivot()
                                        if pivot then
                                            hrp.CFrame = CFrame.new(pivot.Position + Vector3.new(0,5,0))
                                        end
                                    end
                                    superStuck = 0
                                    task.wait(5)
                                    continue
                                else
                                    -- stuck ปกติ → วาปไปห้องเลขสูงสุด
                                    local maxRoomNum, targetPos, maxRoomObj = 0, nil, nil
                                    for _, roomObj in ipairs(workspace:GetChildren()) do
                                        if roomObj:IsA("Model") and tonumber(roomObj.Name) then
                                            local num = tonumber(roomObj.Name)
                                            if num > maxRoomNum then
                                                maxRoomNum = num
                                                maxRoomObj = roomObj
                                                local roomRoot = roomObj:FindFirstChild("Root")
                                                if roomRoot then
                                                    targetPos = roomRoot.Position
                                                end
                                            end
                                        end
                                    end
                                    if targetPos then
                                        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                                        if maxRoomObj then
                                            roomBlacklist[maxRoomObj.Name] = true
                                        end
                                    end
                                    task.wait(5)
                                    continue
                                end
                            end
                        else
                            stuckCount = 0
                        end

                        lastRoomName = chosenRoom.Name

                        -- วาป ExitZone
                        local exitZone = chosenRoom:FindFirstChild("ExitZone")
                        if exitZone and exitZone:IsA("BasePart") then
                            pcall(function()
                                hrp.CFrame = CFrame.new(exitZone.Position + Vector3.new(0,5,0))
                            end)
                            task.wait(1)
                        end

                        -- จุดสุดท้าย → fightZone offset (สูง 20, ห่าง 20)
                        local fightZone = chosenRoom:FindFirstChild("fightZone")
                        if fightZone and fightZone:IsA("BasePart") then
                            local targetPos = fightZone.Position + Vector3.new(0,20,20)
                            pcall(function()
                                hrp.CFrame = CFrame.new(targetPos)
                            end)
                        end
                    else
                        -- ไม่มีมอน → วาปไปห้องเลขสูงสุด
                        local maxRoomNum, targetPos = 0, nil
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
                            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))
                        end
                    end

                    task.wait(1)
                end
            end)
        elseif not AutoWarpLoop and warpLoop then
            task.cancel(warpLoop)
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
local use_Ability = true
local currentAbilityIndex, abilityLoop = 1, nil

MovementSection:AddToggle({
    Name = "Auto Skill (Interval)",
    Default = use_Ability,
    Callback = function(state)
        use_Ability = state
        if use_Ability and not abilityLoop then
            abilityLoop = RunService.Heartbeat:Connect(function()
                task.wait(1) -- ยิงสกิลทุก 1 วิ
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
