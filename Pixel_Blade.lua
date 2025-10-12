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

local BossRooms = {
    ["YetiBossFight"] = {"ShimBomboYeti","CorruptShimBomboYeti"},
    ["AkumaBossFight"] = {"Akuma","CorruptAkuma"},
    ["KoriBossFight"] = {"IceDragon"},
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Global tracking for optimization
local trackedMonsters = {}  -- Cache all monsters, updated via events
local friendlyMobs = {
    "GoldenPhantom","GiantInfernoGuardian","GiantSkeleton","GiantWizard","GiantZombie",
    "NecromancerGhoul","ShroomArcher","ShroomKnight","ShroomPaladin","Kori"
}

local Main_Room_Boss = {
    "LumberjackHill","GoblinArena","BossRoom","TheDen",
    "Graveyard","Vault","YetiBossFight","AkumaBossFight","KoriBossFight"
}

local visitedBossRooms = {}
local pullConnection  -- Single global Heartbeat for all pulls
local raidPulling = false
local currentTarget
local currentAbilityIndex = 1

local replay_g = true
local Mon_TP = false
local Raid_Farm = true
local use_Ability = true

-- Health & Stuck trackers with debounce
local healthTracker = {}
local lastPosition = nil
local lastMoveTime = tick()
local stuckThreshold = 120  -- 2 min
local lastHealthCheck = 0
local healthDebounce = 2  -- Check every 2s

-- Abilities
local abilities_all = {
    "lightning","solar", "arcticWind","bloodSnowstorm", "voidGrip_Shockwave",
    "rejuvenate","bloodThirst","frozenWall", "ablaze", "voidGrip",
    "DeathGrasp", "Oblivion", "raiseTheDead","goldenArmy","CosmicVision","blackHole","cosmicBeam",
}

-- =====================
-- Event-Driven Monster Tracking (Optimize: No more GetChildren() loops)
-- =====================
local function updateMonsterCache(model)
    local name = model.Name
    local hadAttr = model:GetAttribute("hadEntrance")
    if table.find(friendlyMobs, name) then return end
    if hadAttr == true or hadAttr == false or (hadAttr == nil and name == "IceDragon") then
        trackedMonsters[model] = true
    end
end

local function removeFromCache(model)
    trackedMonsters[model] = nil
end

-- Connect events once
workspace.ChildAdded:Connect(updateMonsterCache)
workspace.ChildRemoved:Connect(removeFromCache)

-- Initial cache
for _, model in ipairs(workspace:GetChildren()) do
    if model:IsA("Model") then
        updateMonsterCache(model)
    end
end

local function getMonsters()  -- Now O(1) via cache
    local monsters = {}
    for model, _ in pairs(trackedMonsters) do
        if model.Parent then
            table.insert(monsters, model)
        else
            removeFromCache(model)  -- Cleanup
        end
    end
    return monsters
end

local function getTrueMobs()  -- hadEntrance == true or IceDragon
    local mobs = {}
    for model, _ in pairs(trackedMonsters) do
        if model.Parent and (model:GetAttribute("hadEntrance") == true or model.Name == "IceDragon") then
            table.insert(mobs, model)
        end
    end
    return mobs
end

-- =====================
-- Single Global Pull Heartbeat (Optimize: Merge all pulls)
-- =====================
local function getMobRootPart(mob)
    return mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("basehitbox")
end

local function performPull(mobs, playerHRP)
    for _, mob in ipairs(mobs) do
        if not mob or not mob.Parent then continue end
        if table.find(friendlyMobs, mob.Name) then continue end
        if mob:GetAttribute("hadEntrance") ~= true and mob.Name ~= "IceDragon" then continue end

        local monRoot = getMobRootPart(mob)
        if monRoot then
            monRoot.CanCollide = false
            local monSize = monRoot.Size or Vector3.new(2,2,2)
            local distanceOffset = 20 + (monSize.Z / 2)
            local heightOffset = 20 + (monSize.Y / 4)
            local tpPosition = playerHRP.Position + playerHRP.CFrame.LookVector * distanceOffset + Vector3.new(0, heightOffset, 0)
            monRoot.CFrame = CFrame.new(tpPosition, tpPosition + playerHRP.CFrame.LookVector)
        end
    end
end

local function startGlobalPull(activePulls)  -- activePulls = {Mon_TP = true, Raid_Farm = true, ...}
    if pullConnection then pullConnection:Disconnect() end
    pullConnection = RunService.Heartbeat:Connect(function()
        local char = player.Character
        local playerHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not playerHRP then return end

        local trueMobs = getTrueMobs()
        if activePulls.Mon_TP and #trueMobs > 0 then
            performPull(trueMobs, playerHRP)
        end
        if activePulls.Raid_Farm and raidPulling and #trueMobs > 0 then
            performPull(trueMobs, playerHRP)
        end
    end)
end

-- =====================
-- ⚡ Replay Games
-- =====================
MovementSection:AddToggle({
    Name = "Replay Games",
    Default = replay_g,
    Callback = function(state)
        replay_g = state
        if replay_g then
            task.spawn(function()
                while replay_g do
                    local args = { "replay" }
                    game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("gameEndVote"):FireServer(unpack(args))
                    task.wait(2)  -- Unchanged
                end
            end)
        end
    end
})

-- =====================
-- Reset & Stuck Check (Debounced)
-- =====================
local function resetCharacter()
    if player.Character then
        player.Character:BreakJoints()
        print("[AutoTP] Character reset!")
    end
end

local function checkStuck()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local currentPos = hrp.Position
    if lastPosition and (currentPos - lastPosition).Magnitude < 1 then
        if tick() - lastMoveTime > stuckThreshold then
            print("[AutoTP] Character stuck! Resetting...")
            resetCharacter()
            lastMoveTime = tick()
        end
    else
        lastMoveTime = tick()
    end
    lastPosition = currentPos
end

local function checkHealthStuck(trueMobs)
    if tick() - lastHealthCheck < healthDebounce then return end
    lastHealthCheck = tick()

    for _, mob in ipairs(trueMobs) do
        local healthVal = mob:FindFirstChild("Health")
        if healthVal and healthVal:IsA("NumberValue") then
            local prev = healthTracker[mob]
            if prev and prev.value == healthVal.Value then
                if tick() - prev.time >= 5 then
                    print("[AutoTP] Health stuck! Teleporting to", mob.Name)
                    teleportTo(mob)  -- Define below
                    healthTracker[mob] = {value = healthVal.Value, time = tick()}
                end
            else
                healthTracker[mob] = {value = healthVal.Value, time = tick()}
            end
        end
    end
end

-- =====================
-- Teleport Functions (Unchanged but cached)
-- =====================
local function teleportTo(mon)
    local char = player.Character or player.CharacterAdded:Wait()
    local playerHRP = char:FindFirstChild("HumanoidRootPart")
    local monRoot = getMobRootPart(mon)
    if playerHRP and monRoot then
        local direction = (monRoot.Position - playerHRP.Position).Unit
        playerHRP.CFrame = CFrame.new(monRoot.Position - direction * 30 + Vector3.new(0,5,0), monRoot.Position)
    end
end

local function teleportToBossExit(roomName)
    local bossRoom = workspace:FindFirstChild(roomName)
    if bossRoom and bossRoom:FindFirstChild("ExitZone") then
        local exitPart = bossRoom.ExitZone
        local char = player.Character or player.CharacterAdded:Wait()
        local playerHRP = char:FindFirstChild("HumanoidRootPart")
        if playerHRP then
            playerHRP.CFrame = exitPart.CFrame + Vector3.new(0,5,0)
            print("[BossRoom] Teleported to Exit of", roomName)
            visitedBossRooms[roomName] = true
            task.wait(1)
        end
    end
end

local function teleportToLargestRoom()
    local largest = -math.huge
    for _, child in ipairs(workspace:GetChildren()) do
        local num = tonumber(child.Name)
        if num and num > largest then
            largest = num
        end
    end
    if largest ~= -math.huge then
        local room = workspace:FindFirstChild(tostring(largest))
        if room then
            local char = player.Character or player.CharacterAdded:Wait()
            local playerHRP = char:FindFirstChild("HumanoidRootPart")
            if playerHRP then
                playerHRP.CFrame = room:GetModelCFrame() + Vector3.new(0,5,0)
                print("[AutoTP] Teleported to largest room:", largest)
                task.wait(1)
            end
        end
    end
end

-- =====================
-- Auto TP Loop (Throttled to 1s, debounced checks)
-- =====================
local autoTPConnection
local function autoTP()
    autoTPConnection = RunService.Stepped:Connect(function()  -- Use Stepped for less freq than Heartbeat
        if not Mon_TP then
            autoTPConnection:Disconnect()
            autoTPConnection = nil
            return
        end

        checkStuck()  -- Debounced internally

        local trueMobs = getTrueMobs()
        checkHealthStuck(trueMobs)  -- Debounced

        -- Pull via global
        startGlobalPull({Mon_TP = true})

        repeat
            task.wait(1)  -- Throttle to 1s
            trueMobs = getTrueMobs()
            checkStuck()
        until not Mon_TP or #trueMobs == 0

        -- Boss check (unchanged, but less freq)
        for _, room in ipairs(Main_Room_Boss) do
            if not visitedBossRooms[room] then
                local bossRoom = workspace:FindFirstChild(room)
                if bossRoom then
                    if bossRoom:FindFirstChild("Tp") then
                        local char = player.Character or player.CharacterAdded:Wait()
                        local playerHRP = char:FindFirstChild("HumanoidRootPart")
                        if playerHRP then
                            playerHRP.CFrame = bossRoom.Tp.CFrame + Vector3.new(0,5,0)
                            task.wait(0.5)
                        end
                    end

                    local hasTrue = false
                    for _, mob in ipairs(bossRoom:GetChildren()) do
                        if mob:GetAttribute("hadEntrance") == true then
                            hasTrue = true
                            break
                        end
                    end
                    if not hasTrue and bossRoom:FindFirstChild("ExitZone") then
                        teleportToBossExit(room)
                    end
                end
            end
        end

        -- False mobs TP
        local allMobs = getMonsters()
        local falseMobs = {}
        for _, mob in ipairs(allMobs) do
            if mob:GetAttribute("hadEntrance") == false then
                table.insert(falseMobs, mob)
            end
        end
        for _, mob in ipairs(falseMobs) do
            if not Mon_TP then break end
            teleportTo(mob)
            task.wait(0.5)
        end

        -- No mobs -> largest room
        local nonFriendly = {}
        for _, m in ipairs(allMobs) do
            if not table.find(friendlyMobs, m.Name) then
                table.insert(nonFriendly, m)
            end
        end
        if #nonFriendly == 0 then
            teleportToLargestRoom()
            task.wait(1)
        end

        task.wait(1)  -- Throttle main loop
    end)
end

MovementSection:AddToggle({
    Name = "Auto TP Mon and Pull",
    Default = Mon_TP,
    Callback = function(state)
        Mon_TP = state
        if Mon_TP then
            visitedBossRooms = {}
            healthTracker = {}  -- Clear cache
            task.spawn(autoTP)
            startGlobalPull({Mon_TP = true})
        else
            if pullConnection then
                pullConnection:Disconnect()
                pullConnection = nil
            end
            if autoTPConnection then
                autoTPConnection:Disconnect()
                autoTPConnection = nil
            end
            Mon_TP = false
            print("[AutoTP] Stopped")
        end
    end
})

-- =====================
-- Farm Raid (Throttled, use global pull)
-- =====================
local teleportDuration = 0.5
local cooldownDuration = 0.5
local farmRaidTask

-- Raid positions for cycling every 5 seconds (added CrystalTree as 5th target)
local raidPositions = {
    Vector3.new(-788.7662963867188, -194.17047119140625, -152.11851501464844),
    Vector3.new(-692.055419921875, -194.1704864501953, -233.7333526611328),
    Vector3.new(-790.2472534179688, -194.17050170898438, -328.41143798828125),
    Vector3.new(-879.9151611328125, -194.1704864501953, -233.5121307373047),
    "CrystalTree"  -- Special string target for dynamic teleport
}
local currentPosIndex = 1
local lastPosTeleport = 0
local posInterval = 5  -- Every 5 seconds

local function farmRaidLoop()
    startGlobalPull({Raid_Farm = true})

    while Raid_Farm do
        -- Check and teleport to next raid position every 5 seconds
        if tick() - lastPosTeleport >= posInterval then
            local char = player.Character
            local playerHRP = char and char:FindFirstChild("HumanoidRootPart")
            if playerHRP then
                local target = raidPositions[currentPosIndex]
                local targetCFrame
                if typeof(target) == "Vector3" then
                    targetCFrame = CFrame.new(target + Vector3.new(0, 5, 0))
                else  -- "CrystalTree"
                    local raidArena = workspace:FindFirstChild("RaidArena")
                    if raidArena then
                        local crystalTree = raidArena:FindFirstChild("CrystalTree")
                        if crystalTree then
                            targetCFrame = crystalTree:GetModelCFrame() + Vector3.new(0, 5, 0)
                        end
                    end
                end
                if targetCFrame then
                    playerHRP.CFrame = targetCFrame
                    local posName = typeof(target) == "Vector3" and ("position " .. currentPosIndex) or "CrystalTree"
                    print("[FarmRaid] ▶ Teleported to raid " .. posName)
                end
                currentPosIndex = (currentPosIndex % #raidPositions) + 1
                lastPosTeleport = tick()
            end
        end

        local trueMobs = getTrueMobs()
        local validMobs = {}
        local char = player.Character
        local playerHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not playerHRP then task.wait(1) continue end

        for _, mob in ipairs(trueMobs) do
            if mob:GetAttribute("hadEntrance") == true or mob.Name == "IceDragon" then
                table.insert(validMobs, mob)
            end
        end

        if #validMobs > 0 then
            -- Farthest mob
            table.sort(validMobs, function(a, b)
                local aRoot = getMobRootPart(a)
                local bRoot = getMobRootPart(b)
                if not aRoot or not bRoot then return false end
                return (aRoot.Position - playerHRP.Position).Magnitude > (bRoot.Position - playerHRP.Position).Magnitude
            end)

            currentTarget = validMobs[1]
            teleportTo(currentTarget)
            print("[FarmRaid] ▶ Teleported to farthest mob:", currentTarget.Name)

            raidPulling = true
            task.wait(teleportDuration)

            raidPulling = false
            print("[FarmRaid] ⏸ Pause pulling for 3s...")
            task.wait(cooldownDuration)
        else
            raidPulling = false
            task.wait(1)
        end
    end
end

MovementSection:AddToggle({
    Name = "Farm Raid",
    Default = Raid_Farm,
    Callback = function(state)
        Raid_Farm = state
        if Raid_Farm then
            -- Reset position cycle when starting
            currentPosIndex = 1
            lastPosTeleport = 0
            print("[FarmRaid] Started farming in current room...")
            farmRaidTask = task.spawn(farmRaidLoop)
        else
            Raid_Farm = false
            raidPulling = false
            if farmRaidTask then
                task.cancel(farmRaidTask)
                farmRaidTask = nil
            end
            print("[FarmRaid] Stopped")
        end
    end
})

-- =====================
-- ⚡ Auto Skill (Throttled to task.spawn, no Heartbeat)
-- =====================
local skillTask
MovementSection:AddToggle({
    Name = "Auto Skill (Interval)",
    Default = use_Ability,
    Callback = function(state)
        use_Ability = state
        if use_Ability and not skillTask then
            skillTask = task.spawn(function()
                while use_Ability do
                    task.wait(1)  -- Every 1s
                    local ability = abilities_all[currentAbilityIndex]
                    if ability then
                        game.ReplicatedStorage.remotes.useAbility:FireServer(ability)
                    end
                    currentAbilityIndex = currentAbilityIndex + 1
                    if currentAbilityIndex > #abilities_all then
                        currentAbilityIndex = 1
                    end
                end
            end)
        elseif not use_Ability and skillTask then
            task.cancel(skillTask)
            skillTask = nil
            currentAbilityIndex = 1
        end
    end
})

------------------------------------------------------------------------------------
local ShopSection = PlayerTab:AddSection("Shop", true)

local open_Wish55 = false
ShopSection:AddToggle({
    Name = "Open Gacha Even55555",
    Default = open_Wish55,
    Callback = function(state)
        open_Wish55 = state
    end
})

local open_Wish = false
local wishTask
ShopSection:AddToggle({
    Name = "Open Gacha Even",
    Default = open_Wish,
    Callback = function(state)
        open_Wish = state
        if open_Wish and not wishTask then
            wishTask = task.spawn(function()
                while open_Wish do
                    game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("openWish"):InvokeServer()
                    task.wait(0.5)  -- Increased from 0.3 to reduce spam
                end
            end)
        elseif not open_Wish and wishTask then
            task.cancel(wishTask)
            wishTask = nil
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local autoUpgradeToggle = false
local upgradeTask

-- =========================
-- Auto Upgrade (Batched, delayed 0.1s, limit queue)
-- =========================
ShopSection:AddToggle({
    Name = "Auto Upgrade",
    Default = autoUpgradeToggle,
    Callback = function(state)
        autoUpgradeToggle = state
        if autoUpgradeToggle and not upgradeTask then
            upgradeTask = task.spawn(function()
                local gui = player.PlayerGui:WaitForChild("gameUI"):WaitForChild("armory"):WaitForChild("inventory"):WaitForChild("clip")
                local items = {}
                local categories = {"Weapons", "Armor"}
                for _, categoryName in ipairs(categories) do
                    local category = gui:FindFirstChild(categoryName)
                    if category then
                        for _, item in ipairs(category:GetChildren()) do
                            if item.Name ~= "filler" and item.Name ~= "none" then
                                table.insert(items, item.Name)
                            end
                        end
                    end
                end

                local queue = {}
                for _, itemName in ipairs(items) do
                    for tier = 1, 15 do
                        table.insert(queue, {itemName, "itemUpgrade", {upgradeTier = tier}})
                    end
                end

                -- Limit queue if too big (prevent crash)
                if #queue > 500 then
                    queue = {}  -- Or slice: queue = {table.unpack(queue, 1, 500)}
                    print("[AutoUpgrade] Queue too large, skipping")
                    return
                end

                local remote = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("requestPurchase")

                for _, args in ipairs(queue) do
                    if not autoUpgradeToggle then return end
                    remote:FireServer(unpack(args))
                    task.wait(0.1)  -- Increased from 0.01 to reduce spam/CPU
                end
            end)
        else
            if upgradeTask then
                task.cancel(upgradeTask)
                upgradeTask = nil
            end
        end
    end
})

local Chest_Rarity_E = {"GodlyChest", "RavenChest", "SamuraiChest"}
local Chest_Rarity_R = {"CrystalChest", "FossilChest", "RoyalChest"}
local Chest_Rarity_C = {"FrostChest", "SandyChest", "WoodenChest"}

local allChests = {
    ["E"] = Chest_Rarity_E,
    ["R"] = Chest_Rarity_R,
    ["C"] = Chest_Rarity_C
}

local selectedRarity = {E=true, R=true, C=true}  -- Default all
local selectedSingleChest = nil

local dropdownOptions = { "All", "All Chest C", "All Chest R", "All Chest E" }
local chestNameMap = {}

for rarity, list in pairs(allChests) do
    for _, chestName in pairs(list) do
        local displayName = chestName .. " - " .. rarity
        table.insert(dropdownOptions, displayName)
        chestNameMap[displayName] = chestName
    end
end

ShopSection:AddDropdown({
    Name = "Chest Rarity",
    Options = dropdownOptions,
    Default = "All",
    Callback = function(selected)
        selectedRarity = {E=false, R=false, C=false}
        selectedSingleChest = nil

        if selected == "All" then
            selectedRarity = {E=true, R=true, C=true}
        elseif selected == "All Chest E" then
            selectedRarity.E = true
        elseif selected == "All Chest R" then
            selectedRarity.R = true
        elseif selected == "All Chest C" then
            selectedRarity.C = true
        elseif chestNameMap[selected] then
            selectedSingleChest = chestNameMap[selected]
        end

        PixelLib:CreateNotification({
            Title = "Chest Selection",
            Description = "Updated",
            Content = selectedSingleChest and ("Selected chest: " .. selectedSingleChest) or "Selected rarities updated",
            Color = Color3.fromRGB(0, 255, 0)
        })
    end
})

ShopSection:AddToggle({
    Name = "Buy Chest",
    Default = false,
    Callback = function(state)
        if state then
            local chestsToBuy = {}

            if selectedSingleChest then
                table.insert(chestsToBuy, selectedSingleChest .. "2")
            else
                for rarity, isSelected in pairs(selectedRarity) do
                    if isSelected then
                        for _, chestName in pairs(allChests[rarity]) do
                            table.insert(chestsToBuy, chestName .. "2")
                        end
                    end
                end
            end

            for _, chestNameWith2 in pairs(chestsToBuy) do
                local args = {chestNameWith2, "daily"}
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("requestPurchase"):FireServer(unpack(args))
                task.wait(0.05)  -- Small delay to avoid spam
            end

            PixelLib:CreateNotification({
                Title = "Buy Chest",
                Description = "Purchased",
                Content = "Bought " .. #chestsToBuy .. " chests",
                Color = Color3.fromRGB(0, 255, 0)
            })
        end
    end
})
