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

local BossFT = {
    "GiantGoblin","CursedGiantGoblin","LumberJack","CursedLumberJack","Kingslayer",
    "ShimBomboYeti","CorruptShimBomboYeti","Akuma","CorruptAkuma","IceDragon"
}

local AkumaSpecials = {"Akuma", "CorruptAkuma"}
local mainRooms = {"Small_odd","Small_even","Medium_even","Medium_odd","Large_even","Large_odd"}

local akumaPositions = {}
local visitedBossRooms = {}     -- ห้อง BossFight ที่เคยไปแล้ว
local lastFalseMob = nil        -- จำมอน false ล่าสุด

-- =========================================================
-- Helper
-- =========================================================
local function warpTo(pos, offsetY)
    if not tp_mon or not pos then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(pos + Vector3.new(0, offsetY or 0, 0))
        end)
    end
end

-- หา ExitZone ที่ใกล้มอน hadEntrance == false ที่สุด
local function warpToNearestExitZone(mobsFalse)
    local nearestExit, minDist = nil, math.huge
    for _, mob in ipairs(mobsFalse) do
        local mobHRP = mob:FindFirstChild("HumanoidRootPart")
        if mobHRP then
            for _, room in ipairs(workspace:GetChildren()) do
                if room:IsA("Model") and (table.find(mainRooms, room.Name) or room.Name:find("BossFight")) then
                    local exit = room:FindFirstChild("ExitZone")
                    if exit then
                        local dist = (mobHRP.Position - exit.Position).Magnitude
                        if dist < minDist then
                            minDist = dist
                            nearestExit = exit.Position
                        end
                    end
                end
            end
        end
    end
    if nearestExit then
        warpTo(nearestExit, 5)
        task.wait(0.35)
        return nearestExit
    end
    return nil
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

-- =========================================================
-- BossFight Logic
-- =========================================================
local function handleBossFightRoom(room)
    if visitedBossRooms[room.Name] then return end
    visitedBossRooms[room.Name] = true

    local exit = room:FindFirstChild("ExitZone")
    local floor = room:FindFirstChild("FLOOR")

    if exit and floor then
        warpTo(exit.Position, 5)
        task.wait(0.5)
        warpTo(floor.Position, 5)
        task.wait(2)
        warpTo(floor.Position, 5)
    end
end

-- =========================================================
-- Main Loop
-- =========================================================
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
            lastFalseMob = nil
            visitedBossRooms = {}
            return
        end

        if tp_mon and not connection then
            connection = RunService.Heartbeat:Connect(function()
                if not tp_mon or isBusy then return end
                isBusy = true

                local mobsTrue, mobsFalse = {}, {}
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

                -- (1) ถ้ามี hadEntrance == true → ดูดเลย
                if #mobsTrue > 0 then
                    pullMobs(mobsTrue)
                    isBusy = false
                    return
                end

                -- (2) ไม่มี true แต่มี false
                if #mobsFalse > 0 then
                    task.spawn(function()
                        if not tp_mon then isBusy = false return end

                        local exitPos = warpToNearestExitZone(mobsFalse)
                        local target = mobsFalse[1]

                        -- ถ้าเคยไปหามอน false ตัวนี้แล้ว ข้ามไป
                        if lastFalseMob == target then
                            warpToLargestRoom()
                            isBusy = false
                            return
                        end
                        lastFalseMob = target

                        -- เช็คห้อง BossFight
                        for _, room in pairs(workspace:GetChildren()) do
                            if room:IsA("Model") and room.Name:find("BossFight") then
                                handleBossFightRoom(room)
                            end
                        end

                        if target and target:FindFirstChild("HumanoidRootPart") then
                            warpTo(target.HumanoidRootPart.Position, 5)
                            task.wait(0.5)
                        end

                        -- เช็คมอนที่เปลี่ยนเป็น hadEntrance == true หรือยัง
                        local foundTrue = false
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj:IsA("Model") and obj:GetAttribute("hadEntrance") == true then
                                foundTrue = true
                                break
                            end
                        end

                        if not foundTrue and exitPos and target and target:FindFirstChild("HumanoidRootPart") then
                            warpTo(exitPos, 5)
                            task.wait(2)
                            warpTo(target.HumanoidRootPart.Position, 5)
                            task.wait(0.5)
                        end

                        local newTrue = {}
                        for _, obj in pairs(workspace:GetChildren()) do
                            if obj:IsA("Model") and obj:GetAttribute("hadEntrance") == true then
                                table.insert(newTrue, obj)
                            end
                        end

                        if #newTrue > 0 then
                            pullMobs(newTrue)
                        else
                            warpToLargestRoom()
                        end

                        isBusy = false
                    end)
                    return
                end

                -- (3) ไม่มีทั้ง true/false → ห้องเลขใหญ่สุด
                warpToLargestRoom()
                task.wait(1)
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


local open_Wish = false
MovementSection:AddToggle({
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
MovementSection:AddToggle({
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
