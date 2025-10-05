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

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local tp_mon = true
local connection = nil
local isBusy = false

local friendlyMobs = { 
    "GoldenPhantom","GiantInfernoGuardian","GiantSkeleton","GiantWizard","GiantZombie",
    "NecromancerGhoul","ShroomArcher","ShroomKnight","ShroomPaladin"
}

local mainRooms = {"Small_odd","Small_even","Medium_even","Medium_odd","Large_even","Large_odd"}

local visitedBossRooms = {}
local mobHealthData = {}
local lastWarpedToExit = 0
local lastFalseMob = nil

-- ==========================
-- Helper
-- ==========================
local function warpTo(pos, offsetY)
    if not tp_mon or not pos then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, offsetY or 0, 0))
        end)
    end
end

local function warpToLargestRoom()
    local maxNum, targetPos = 0, nil
    for _, roomObj in ipairs(workspace:GetChildren()) do
        if roomObj:IsA("Model") then
            local n = tonumber(roomObj.Name)
            if n and n > maxNum then
                maxNum = n
                local root = roomObj:FindFirstChild("Root")
                if root then targetPos = root.Position end
            end
        end
    end
    if targetPos then warpTo(targetPos, 5) end
end

local function pullMobs(mobs)
    if not tp_mon then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local playerHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not playerHRP then return end

    for _, mob in ipairs(mobs) do
        if not tp_mon then break end
        if not mob or not mob.Parent then continue end
        local monHRP = mob:FindFirstChild("HumanoidRootPart")
        if monHRP then
            monHRP.CanCollide = false
            local monSize = monHRP.Size or Vector3.new(2,2,2)
            local distanceOffset = 20 + (monSize.Z / 2)
            local heightOffset = 20 + (monSize.Y / 4)
            local tpPosition = playerHRP.Position + playerHRP.CFrame.LookVector * distanceOffset + Vector3.new(0, heightOffset, 0)
            monHRP.CFrame = CFrame.new(tpPosition, tpPosition + playerHRP.CFrame.LookVector)
        end
    end
end

-- ==========================
-- Main Loop
-- ==========================
MovementSection:AddToggle({
    Name = "Auto TP Mon",
    Default = tp_mon,
    Callback = function(state)
        tp_mon = state

        if not tp_mon then
            if connection then
                connection:Disconnect()
                connection = nil
            end
            isBusy = false
            mobHealthData = {}
            visitedBossRooms = {}
            return
        end

        if tp_mon and not connection then
            connection = RunService.Heartbeat:Connect(function()
                if not tp_mon or isBusy then return end
                isBusy = true

                local mobsTrue, mobsFalse = {}, {}

                -- แยกมอน
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj:IsA("Model") and not table.find(friendlyMobs, obj.Name) then
                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                        local hadEntrance = obj:GetAttribute("hadEntrance")
                        if hrp then
                            if hadEntrance == true then
                                table.insert(mobsTrue, obj)
                            elseif hadEntrance == false then
                                table.insert(mobsFalse, obj)
                            end
                        end
                    end
                end

                -- ถ้ามีมอนที่พร้อมสู้ (true)
                if #mobsTrue > 0 then
                    pullMobs(mobsTrue)
                    isBusy = false
                    return
                end

                -- ไม่มีมอน true
                if #mobsFalse > 0 then
                    local target = mobsFalse[1]
                    if target and target:FindFirstChild("HumanoidRootPart") then
                        -- ป้องกันวาร์ปซ้ำ exit
                        if tick() - lastWarpedToExit > 10 then
                            warpTo(target.HumanoidRootPart.Position, 5)
                            lastWarpedToExit = tick()
                        end
                    end
                    isBusy = false
                    return
                end

                -- ถ้าไม่มีทั้ง true และ false → ห้องใหญ่สุด
                warpToLargestRoom()
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
    "rejuvenate"
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
