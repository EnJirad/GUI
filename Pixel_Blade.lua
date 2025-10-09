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
local tp_mon, connection, isBusy = true, nil, false
local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local friendlyMobs = {
    "GoldenPhantom","GiantInfernoGuardian","GiantSkeleton","GiantWizard","GiantZombie",
    "NecromancerGhoul","ShroomArcher","ShroomKnight","ShroomPaladin"
}

local BossFT = {
    "LumberJack","CursedLumberJack","GiantGoblin","CursedGiantGoblin",
    "Kingslayer","Maneater","Nekros","DarkNekros","Atticus",
    "ShimBomboYeti","CorruptShimBomboYeti","Akuma","CorruptAkuma","IceDragon"
}

local mainRooms = {"Small_odd","Small_even","Medium_even","Medium_odd","Large_even","Large_odd"}
local visitedBossRooms, lastPositions, lastCheckTime = {}, {}, {}
local lastRoom, lastBossTarget, lastFalseTarget = nil, nil, nil

--========================================================
-- 🔧 Utils
--========================================================
local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function warpTo(pos, y)
    local hrp = getHRP()
    if tp_mon and hrp and pos then
        pcall(function()
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, y or 0, 0))
        end)
    end
end

local function resetChar()
    if player.Character then player.Character:BreakJoints() end
end

local function getCurrentRoom()
    local hrp = getHRP()
    if not hrp then return nil end
    local minDist, current = math.huge, nil
    for _, room in ipairs(workspace:GetChildren()) do
        if room:IsA("Model") and (table.find(mainRooms, room.Name) or room.Name:find("BossFight")) then
            local root = room:FindFirstChild("Root") or room:FindFirstChild("FLOOR") or room:FindFirstChild("ExitZone")
            if root then
                local d = (hrp.Position - root.Position).Magnitude
                if d < minDist then
                    minDist, current = d, room
                end
            end
        end
    end
    return current
end

local function findExitZone(room)
    if not room or not room:IsA("Model") then return nil end
    return room:FindFirstChild("ExitZone")
end

local function warpToLargestRoom()
    local max, pos = 0, nil
    for _, room in ipairs(workspace:GetChildren()) do
        if room:IsA("Model") then
            local n = tonumber(room.Name)
            if n and n > max and room:FindFirstChild("Root") then
                max, pos = n, room.Root.Position
            end
        end
    end
    if pos then warpTo(pos, 5) end
end

local function pullMobs(mobs)
    local hrp = getHRP()
    if not hrp then return end
    for _, mob in ipairs(mobs) do
        local mhrp = mob:FindFirstChild("HumanoidRootPart")
        if mhrp then
            mhrp.CanCollide = false
            local tpPos = hrp.Position + hrp.CFrame.LookVector * 20 + Vector3.new(0, 20, 0)
            mhrp.CFrame = CFrame.new(tpPos)
        end
    end
end

--========================================================
-- 🔍 หา room จาก Part ที่ยืนอยู่
--========================================================
local function getRoomFromPart(part)
    if not part or not part.Parent then return nil end
    local p = part.Parent
    while p.Parent do
        if table.find(mainRooms, p.Name) or p.Name:find("BossFight") then
            return p
        end
        p = p.Parent
    end
    return nil
end

--========================================================
-- ⚡ Warp ไป ExitZone ก่อน แล้วค่อยไป target
--========================================================
local function warpToExitThenTarget(target)
    local hrp = getHRP()
    if not hrp or not target then return end

    -- หา Part ที่เราอยู่
    local currentPart = workspace:FindPartOnRayWithIgnoreList(Ray.new(hrp.Position, Vector3.new(0, -5, 0)), {player.Character})
    local currentRoom = getRoomFromPart(currentPart)
    local exitZone = currentRoom and currentRoom:FindFirstChild("ExitZone")
    
    if exitZone then
        warpTo(exitZone.Position, 5)
        task.wait(0.5)
    end
    
    -- วาปไป target หลังจากแตะ ExitZone
    local tHRP = target:FindFirstChild("HumanoidRootPart")
    if tHRP then
        warpTo(tHRP.Position, 5)
    end
end

--========================================================
-- 🎯 Core Logic
--========================================================
local function getTargets()
    local bosses, mobsTrue, mobsFalse = {}, {}, {}
    for _, o in ipairs(workspace:GetChildren()) do
        if o:IsA("Model") and not table.find(friendlyMobs, o.Name) then
            local hrp, had = o:FindFirstChild("HumanoidRootPart"), o:GetAttribute("hadEntrance")
            if hrp then
                if table.find(BossFT, o.Name) then
                    table.insert(bosses, o)
                elseif had == true then
                    table.insert(mobsTrue, o)
                elseif had == false then
                    table.insert(mobsFalse, o)
                end
            end
        end
    end
    return bosses, mobsTrue, mobsFalse
end

--========================================================
-- 🧠 Smart Boss Behavior (รองรับทุกห้องบอส + ExitZone + StartDoor/Part Start*)
--========================================================
--========================================================
-- 🧠 Smart Boss Behavior (ExitZone + StartDoor/Start* + Pull)
--========================================================
local function handleBoss(bosses)
    local hrp = getHRP()
    if not hrp then return false end

    for _, boss in ipairs(bosses) do
        local bhrp = boss:FindFirstChild("HumanoidRootPart")
        if bhrp then
            lastBossTarget = boss
            local dist = (hrp.Position - bhrp.Position).Magnitude
            if dist > 50 then
                -- 🔹 หา Room ของบอส
                local bossRoom = getRoomFromPart(bhrp)

                -- 🔹 Warp ไป ExitZone ของห้องบอสก่อน
                local bossExit = bossRoom and bossRoom:FindFirstChild("ExitZone")
                if bossExit then
                    warpTo(bossExit.Position, 5)
                    task.wait(0.5)
                end

                -- 🔹 Warp ไป StartDoor (Model) ถ้ามี
                local warpedStart = false
                if bossRoom then
                    local startDoor = bossRoom:FindFirstChild("StartDoor")
                    if startDoor and startDoor.PrimaryPart then
                        warpTo(startDoor.PrimaryPart.Position, 5)
                        task.wait(0.5)
                        warpedStart = true
                    end
                end

                -- 🔹 ถ้าไม่เจอ StartDoor → warp ไป Part ชื่อ Start*
                if not warpedStart and bossRoom then
                    for _, obj in ipairs(bossRoom:GetDescendants()) do
                        if obj:IsA("BasePart") and obj.Name:sub(1,5) == "Start" then
                            warpTo(obj.Position, 5)
                            task.wait(0.5)
                            break
                        end
                    end
                end

                -- 🔹 Warp มาหาบอส
                warpTo(bhrp.Position, 5)
                task.wait(0.3)
            end

            -- ดึงบอส + มอน true รอบ ๆ
            local _, mobsTrue = getTargets()
            pullMobs({boss})
            if #mobsTrue > 0 then pullMobs(mobsTrue) end
            return true
        end
    end
    return false
end

--========================================================
-- 🧩 False Mob Logic
--========================================================
local function handleFalseMob(target)
    if not target then return end
    warpToExitThenTarget(target)
    lastFalseTarget = target

    local start = tick()
    while tick() - start < 5 do
        if target:GetAttribute("hadEntrance") == true then return end
        task.wait(0.5)
    end
end

--========================================================
-- 🧠 SafeCheck
--========================================================
local function safeCheck()
    local hrp = getHRP()
    if not hrp then return end
    local key = "player"
    local lastPos = lastPositions[key]
    if lastPos and (hrp.Position - lastPos).Magnitude < 2 then
        lastCheckTime[key] = lastCheckTime[key] or tick()
        if tick() - lastCheckTime[key] > 120 then
            warpToLargestRoom()
            task.wait(2)
            resetChar()
        end
    else
        lastCheckTime[key] = tick()
    end
    lastPositions[key] = hrp.Position
end

--========================================================
-- ⚙️ Main Toggle
--========================================================
MovementSection:AddToggle({
    Name = "Auto TP Mon (Smart v3.4)",
    Default = tp_mon,
    Callback = function(state)
        tp_mon = state
        if not state then
            if connection then connection:Disconnect() connection = nil end
            return
        end

        if not connection then
            connection = RunService.Heartbeat:Connect(function()
                if not tp_mon or isBusy then return end
                isBusy = true

                safeCheck()
                local bosses, mobsTrue, mobsFalse = getTargets()
                local currentRoom = getCurrentRoom()
                if currentRoom then lastRoom = currentRoom end
                local exitZone = currentRoom and findExitZone(currentRoom)

                -- ลำดับการทำงาน
                if #bosses > 0 then
                    handleBoss(bosses)
                elseif #mobsTrue > 0 then
                    pullMobs(mobsTrue)
                elseif #mobsTrue == 0 and #mobsFalse > 0 then
                    handleFalseMob(mobsFalse[1])
                else
                    -- ห้องว่าง → warp ExitZone ก่อน
                    if exitZone then
                        warpTo(exitZone.Position, 5)
                        task.wait(0.5)
                    end
                    warpToLargestRoom()
                end

                isBusy = false
            end)
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
    "rebirth"
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
