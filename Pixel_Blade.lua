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

-- =========================================================
-- Auto TP Mon Complete Fixed
-- =========================================================
local friendlyMobs = {
    "GoldenPhantom","GiantInfernoGuardian","GiantSkeleton","GiantWizard","GiantZombie",
    "NecromancerGhoul","ShroomArcher","ShroomKnight","ShroomPaladin","Kori"
}

local Main_Room_Boss = {
    "LumberjackHill","GoblinArena","BossRoom","TheDen",
    "Graveyard","Vault","YetiBossFight","AkumaBossFight","KoriBossFight"
}

local visitedBossRooms = {}
local Mon_TP = true
local pullConnection

-- เก็บค่า Health ล่าสุด และเวลาเริ่มค้าง
local healthTracker = {}

----------------------------------------------------------
-- FUNCTION: Teleport to Monster (ระยะ 20 หน่วย)
----------------------------------------------------------
-- ฟังก์ชันช่วยหา RootPart ของมอน
local function getMobRootPart(mob)
    return mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("basehitbox")
end

local function teleportTo(mon)
    local char = player.Character or player.CharacterAdded:Wait()
    local playerHRP = char:FindFirstChild("HumanoidRootPart")
    local monRoot = getMobRootPart(mon)
    if playerHRP and monRoot then
        local direction = (monRoot.Position - playerHRP.Position).Unit
        playerHRP.CFrame = CFrame.new(monRoot.Position - direction * 30 + Vector3.new(0,5,0), monRoot.Position)
    end
end

----------------------------------------------------------
-- FUNCTION: Continuous Pull (hadEntrance == true)
----------------------------------------------------------
local function startPull(mobs)
    if pullConnection then pullConnection:Disconnect() end
    pullConnection = RunService.Heartbeat:Connect(function()
        if not Mon_TP then
            pullConnection:Disconnect()
            pullConnection = nil
            return
        end

        local char = player.Character
        local playerHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not playerHRP then return end

        for _, mob in ipairs(mobs) do
            if not mob or not mob.Parent then continue end
            if table.find(friendlyMobs, mob.Name) then continue end

            if mob:GetAttribute("hadEntrance") ~= true and mob.Name ~= "IceDragon" then
                continue
            end

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
    end)
end

----------------------------------------------------------
-- FUNCTION: Find Monsters
----------------------------------------------------------
local function getMonsters()
    local monsters = {}
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") then
            local name = model.Name
            local hadAttr = model:GetAttribute("hadEntrance")
            if table.find(friendlyMobs, name) then continue end
            if hadAttr == true or hadAttr == false then
                table.insert(monsters, model)
            elseif hadAttr == nil and name == "IceDragon" then
                table.insert(monsters, model)
            end
        end
    end
    return monsters
end

----------------------------------------------------------
-- FUNCTION: Teleport to Boss Exit
----------------------------------------------------------
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

----------------------------------------------------------
-- FUNCTION: Teleport to largest numbered room
----------------------------------------------------------
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

----------------------------------------------------------
-- FUNCTION: Auto TP Loop + เช็ค Health ค้าง
----------------------------------------------------------
-- แยก hadEntrance == true และ IceDragon
local function getTrueMobs()
    local mobs = {}
    for _, mob in ipairs(getMonsters()) do
        if mob:GetAttribute("hadEntrance") == true or mob.Name == "IceDragon" then
            table.insert(mobs, mob)
        end
    end
    return mobs
end

-- autoTP loop
local function autoTP()
    while Mon_TP do
        -- ✅ 1. เช็ค Health ค้าง
        local trueMobs = getTrueMobs()
        for _, mob in ipairs(trueMobs) do
            if mob:FindFirstChild("Health") and mob.Health:IsA("NumberValue") then
                local prev = healthTracker[mob]
                if prev and prev.value == mob.Health.Value then
                    if tick() - prev.time >= 5 then
                        print("[AutoTP] Health stuck! Teleporting to", mob.Name)
                        teleportTo(mob)
                        healthTracker[mob] = {value = mob.Health.Value, time = tick()}
                    end
                else
                    healthTracker[mob] = {value = mob.Health.Value, time = tick()}
                end
            end
        end

        -- ✅ 2. ดูด trueMobs (รวม IceDragon)
        if #trueMobs > 0 then
            startPull(trueMobs)
            repeat
                task.wait(0.5)
                trueMobs = getTrueMobs()
            until not Mon_TP or #trueMobs == 0
        end

        -- ✅ 3. เช็คบอส
        for _, room in ipairs(Main_Room_Boss) do
            if not visitedBossRooms[room] then
                local bossRoom = workspace:FindFirstChild(room)
                if bossRoom then
                    -- วาปไป Tp ก่อน
                    if bossRoom:FindFirstChild("Tp") then
                        local char = player.Character or player.CharacterAdded:Wait()
                        local playerHRP = char:FindFirstChild("HumanoidRootPart")
                        if playerHRP then
                            playerHRP.CFrame = bossRoom.Tp.CFrame + Vector3.new(0,5,0)
                            task.wait(0.5)
                        end
                    end
                    -- ถ้าไม่มี trueMobs → วาป ExitZone
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

        -- ✅ 4. หา hadEntrance == false → วาป
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

        -- ✅ 5. ถ้าไม่มีมอนเหลือ → วาปห้องใหญ่สุด
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

        task.wait(0.5)
    end
end

----------------------------------------------------------
-- TOGGLE: Auto TP Mon and Pull
----------------------------------------------------------
MovementSection:AddToggle({
    Name = "Auto TP Mon and Pull",
    Default = Mon_TP,
    Callback = function(state)
        Mon_TP = state
        if Mon_TP then
            visitedBossRooms = {}
            task.spawn(autoTP)
        else
            if pullConnection then
                pullConnection:Disconnect()
                pullConnection = nil
            end
            Mon_TP = false
            print("[AutoTP] Stopped")
        end
    end
})


----------------------------------------------------------
-- FUNCTION: Farm Raid (วาป 10 วิ / หยุดดูด 3 วิ)
----------------------------------------------------------
local Raid_Farm = false
local raidPullConnection
local currentTarget
local pulling = false

local teleportDuration = 1 -- ระยะเวลาดูดหลังวาป
local cooldownDuration = 2  -- เวลาหยุดดูดก่อนวาปใหม่

----------------------------------------------------------
-- FUNCTION: Start/Stop Pull
----------------------------------------------------------
local function startRaidPull()
    if raidPullConnection then raidPullConnection:Disconnect() end

    raidPullConnection = RunService.Heartbeat:Connect(function()
        if not Raid_Farm or not pulling then return end

        local char = player.Character
        local playerHRP = char and char:FindFirstChild("HumanoidRootPart")
        if not playerHRP then return end

        -- ✅ ดูดมอนทั้งหมดที่มีอยู่ทุกเฟรม
        local mobs = getTrueMobs()
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
                local tpPosition = playerHRP.Position
                    + playerHRP.CFrame.LookVector * distanceOffset
                    + Vector3.new(0, heightOffset, 0)
                monRoot.CFrame = CFrame.new(tpPosition, tpPosition + playerHRP.CFrame.LookVector)
            end
        end
    end)
end


----------------------------------------------------------
-- FUNCTION: Farm Raid Main Loop
----------------------------------------------------------
----------------------------------------------------------
-- FUNCTION: Farm Raid Main Loop (วาปไปหามอนไกลที่สุด)
----------------------------------------------------------
local function farmRaidLoop()
    startRaidPull()

    while Raid_Farm do
        -- ✅ เลือกมอนเป้าหมายใหม่
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
            -- ✅ เลือกมอนตัวไกลที่สุด
            table.sort(validMobs, function(a, b)
                local aRoot = getMobRootPart(a)
                local bRoot = getMobRootPart(b)
                if not aRoot or not bRoot then return false end
                return (aRoot.Position - playerHRP.Position).Magnitude > (bRoot.Position - playerHRP.Position).Magnitude
            end)

            currentTarget = validMobs[1]
            teleportTo(currentTarget)
            print("[FarmRaid] ▶ Teleported to farthest mob:", currentTarget.Name)

            -- ✅ เริ่มดูด 3 วิ
            pulling = true
            task.wait(teleportDuration)

            -- ✅ หยุดดูด 3 วิ
            pulling = false
            print("[FarmRaid] ⏸ Pause pulling for 3s...")
            task.wait(cooldownDuration)
        else
            -- ไม่มีมอนให้ฟาร์ม → รอเช็กใหม่
            pulling = false
            task.wait(1)
        end
    end

    -- ✅ ปิดการเชื่อมต่อเมื่อหยุดฟาร์ม
    if raidPullConnection then
        raidPullConnection:Disconnect()
        raidPullConnection = nil
    end
end

----------------------------------------------------------
-- TOGGLE: Farm Raid
----------------------------------------------------------
MovementSection:AddToggle({
    Name = "Farm Raid",
    Default = Raid_Farm,
    Callback = function(state)
        Raid_Farm = state
        if Raid_Farm then
            print("[FarmRaid] Started farming in current room...")
            task.spawn(farmRaidLoop)
        else
            Raid_Farm = false
            if raidPullConnection then
                raidPullConnection:Disconnect()
                raidPullConnection = nil
            end
            pulling = false
            print("[FarmRaid] Stopped")
        end
    end
})


-- =====================
-- ⚡ Auto Skill
-- =====================
local abilities_mele = { "constellation","slash", }
local abilities_magi = {"lightning", "solar", "sandTornado", "lunarSpell", "arcticWind", "gemstone", "bloodSnowstorm", "voidGrip_Shockwave"}
local abilities_use = {"boneStrength", "rejuvenate", "berserk", "bloodThirst", "frozenWall", "ablaze", "voidGrip",}
local abilities_other = {"voidGrip", "raiseTheDead", "goldenArmy", "CosmicVision", "Oblivion", "blackHole", "cosmicBeam"}

local abilities_all1 = {
    "voidGrip_Shockwave"
}

local abilities_all = {
    "lightning","solar", "arcticWind","bloodSnowstorm", "voidGrip_Shockwave",
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
ShopSection:AddToggle({
    Name = "Open Gacha Even",
    Default = open_Wish,
    Callback = function(state)
        open_Wish = state
        if open_Wish then
            while open_Wish do
                game:GetService("ReplicatedStorage"):WaitForChild("remotes"):WaitForChild("openWish"):InvokeServer()
                wait(0.3)
            end
        end
    end
})


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local autoUpgradeToggle = false
local upgradeLoop

-- =========================
-- Toggle
-- =========================
ShopSection:AddToggle({
    Name = "Auto Upgrade",
    Default = autoUpgradeToggle,
    Callback = function(state)
        autoUpgradeToggle = state

        if autoUpgradeToggle then
            upgradeLoop = task.spawn(function()
                -- 🔹 ดึงรายการไอเทมทั้งหมดจาก Weapons + Armor
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

                -- 🔹 สร้าง queue ของทุก item + tier
                local queue = {}
                for _, itemName in ipairs(items) do
                    for tier = 1, 15 do
                        table.insert(queue, {itemName, "itemUpgrade", {upgradeTier = tier}})
                    end
                end

                local remote = ReplicatedStorage:WaitForChild("remotes"):WaitForChild("requestPurchase")

                -- 🔹 ไล่ส่ง FireServer ตาม queue พร้อม delay 0.01 วิ
                for _, args in ipairs(queue) do
                    if not autoUpgradeToggle then return end -- ถ้า toggle ปิด ให้หยุด
                    remote:FireServer(unpack(args))
                    task.wait(0.01)
                end
            end)
        else
            if upgradeLoop then
                task.cancel(upgradeLoop)
                upgradeLoop = nil
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

-- เก็บ Rarity ที่เลือก
local selectedRarity = {} -- {E=true, R=false, C=true}
-- เก็บชื่อกล่องเฉพาะที่เลือก
local selectedSingleChest = nil

-- ✅ สร้าง List ของ Options: Rarity ด้านบน + ชื่อกล่องทั้งหมดด้านล่าง พร้อมต่อท้าย Rarity
local dropdownOptions = { "All", "All Chest C", "All Chest R", "All Chest E" }
local chestNameMap = {} -- ใช้เก็บ mapping ของชื่อที่แสดง → ชื่อจริง (เช่น "SamuraiChest - E" -> "SamuraiChest")

for rarity, list in pairs(allChests) do
    for _, chestName in pairs(list) do
        local displayName = chestName .. " - " .. rarity
        table.insert(dropdownOptions, displayName)
        chestNameMap[displayName] = chestName
    end
end

-- Dropdown รวม
ShopSection:AddDropdown({
    Name = "Chest Rarity",
    Options = dropdownOptions,
    Default = "All",
    Callback = function(selected)
        -- Reset
        selectedRarity = {}
        selectedSingleChest = nil

        if selected == "All" then
            selectedRarity = {E=true, R=true, C=true}

        elseif selected == "All Chest E" then
            selectedRarity = {E=true, R=false, C=false}
        elseif selected == "All Chest R" then
            selectedRarity = {E=false, R=true, C=false}
        elseif selected == "All Chest C" then
            selectedRarity = {E=false, R=false, C=true}

        elseif chestNameMap[selected] then
            -- ✅ เลือกชื่อกล่องเฉพาะ
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

-- Toggle Buy Chest
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
