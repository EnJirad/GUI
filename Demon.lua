local PixelLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/MnsEn2001/Xlib/refs/heads/main/Lib/PixLib.lua"))()

-- สร้าง GUI หลัก
local Window = PixelLib:CreateGui({
    NameHub = "Pixel Hub",
    Description = "#VIP: Treasure Quest - V2",
    Color = Color3.fromRGB(0, 140, 255),
    TabWidth = 140,
    SizeUI = UDim2.fromOffset(650, 450)
})

local TabControls = Window
local PlayerTab = TabControls:CreateTab({
    Name = "Player",
    Icon = "rbxassetid://7072719338"
})

local MovementSection = PlayerTab:AddSection("Market", true)
game:GetService("ReplicatedStorage"):WaitForChild("Service"):WaitForChild("EquipageShopService"):WaitForChild("Event"):WaitForChild("eve_EquipageShop"):FireServer()
wait(2)
local HttpService = game:GetService("HttpService")
local configFile = "pixel_config.json"

-- ฟังก์ชันบันทึก config
local function saveConfig(configTable)
    local json = HttpService:JSONEncode(configTable)
    if writefile then
        writefile(configFile, json)
    end
end

-- ฟังก์ชันโหลด config
local function loadConfig()
    if readfile and isfile(configFile) then
        local content = readfile(configFile)
        local success, result = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and type(result) == "table" then
            return result
        end
    end
    return {}
end

-- โหลดค่า config ตอนเริ่ม GUI
local config = loadConfig()
local selectedBreath = config.selectedBreath
local buy_Breaths = config.buy_Breaths or false
local get_items = config.get_items or false
local store_up = config.store_up or false
local buy_gacha_items = config.buy_gacha_items or false
local halloween_ors = config.halloween_ors or false
local check_ors = config.check_ors or false
local guf = config.guf or false

-- ฟังก์ชันดึง Breath จาก GUI และเรียงตาม ID
local function UpdateBreathDropdown()
    local dropdownOptions = {}
    local scrollingFrame = game.Players.LocalPlayer.PlayerGui.UI_Game.UI_EquipageShop.ScrollingFrame_Equipage
    
    local ids = {}
    for _, v in pairs(scrollingFrame:GetChildren()) do
        if tonumber(v.Name) then
            table.insert(ids, tonumber(v.Name))
        end
    end
    table.sort(ids)
    
    for _, id in ipairs(ids) do
        local item = scrollingFrame:FindFirstChild(tostring(id))
        if item then
            table.insert(dropdownOptions, item.Text_Name.Text .. " " .. item.Text_Rank.Text)
        end
    end
    return dropdownOptions
end

-- สร้าง Dropdown Breath
local BreathDropdown = MovementSection:AddDropdown({
    Name = "Select Breath and Demon",
    Options = UpdateBreathDropdown(),
    Default = selectedBreath or UpdateBreathDropdown()[1],
    Callback = function(selected)
        selectedBreath = selected
        -- เซฟค่าอัตโนมัติ
        config.selectedBreath = selectedBreath
        saveConfig(config)
    end
})

-- อัปเดต Dropdown ตอนเปิด
local function SetupRefreshOnOpen()
    local dropdownButton = BreathDropdown.Button
    if dropdownButton then
        dropdownButton.MouseButton1Click:Connect(function()
            local newOptions = UpdateBreathDropdown()
            BreathDropdown:Refresh(newOptions)
            -- ตั้งค่า Default เป็นค่าเดิมหรือค่าตัวแรก
            local default = selectedBreath or newOptions[1]
            if default then
                BreathDropdown:SetValue(default)
                selectedBreath = default
                config.selectedBreath = selectedBreath
                saveConfig(config)
            end
        end)
    end
end
SetupRefreshOnOpen()

-- Toggle ซื้อ Breath อัตโนมัติ
MovementSection:AddToggle({
    Name = "Buy Breaths and Demon",
    Default = buy_Breaths,
    Callback = function(state)
        buy_Breaths = state
        config.buy_Breaths = state
        saveConfig(config)

        if buy_Breaths then
            spawn(function()
                while buy_Breaths do
                    if selectedBreath then
                        local scrollingFrame = game.Players.LocalPlayer.PlayerGui.UI_Game.UI_EquipageShop.ScrollingFrame_Equipage
                        local foundItem = nil
                        for _, v in pairs(scrollingFrame:GetChildren()) do
                            if v:IsA("Frame") and v:FindFirstChild("Text_Name") then
                                local fullName = v.Text_Name.Text .. " " .. v.Text_Rank.Text
                                if fullName == selectedBreath then
                                    foundItem = v
                                    break
                                end
                            end
                        end

                        if foundItem then
                            local priceText = foundItem.Frame_But.But_Gold.TextLabel.Text
                            if priceText ~= "Nothing" then
                                local goldText = game.Players.LocalPlayer.PlayerGui.UI_Game.UI_Money.Frame_Gold.Text_Number.Text
                                local gold = tonumber(goldText:match("[%d%.]+")) or 0
                                if goldText:find("M") then gold = gold * 1000000 end
                                local price = tonumber(priceText:match("[%d%.]+")) or 0
                                if priceText:find("M") then price = price * 1000000 end
                                
                                if gold >= price then
                                    local equipageId = foundItem:GetAttribute("id")
                                    if equipageId then
                                        local args = {{ Name = "Gold", EquipageId = equipageId }}
                                        game:GetService("ReplicatedStorage"):WaitForChild("Service")
                                            :WaitForChild("EquipageShopService")
                                            :WaitForChild("Event")
                                            :WaitForChild("eve_EquipageShop")
                                            :FireServer(unpack(args))
                                    end
                                end
                            end
                        end
                    end
                    wait(1)
                end
            end)
        end
    end
})



local items_demon = {
    ["Arow [comman]"] = "L_G1",
    ["Satin [Rare]"] = "L_G5",
    ["Spider [Epic]"] = "L_G2",
    ["Nightmare [Epic]"] = "L_G3",
    ["Reaper [Legendary]"] = "L_G6",
    ["Black Thunder [Legendary]"] = "L_G10",
    ["Pot [Legendary]"] = "L_G8",
    ["Reaper II [Legendary]"] = "L_G15",
    ["Element [Legendary]"] = "L_G7",
    ["Bewitchment [Legendary]"] = "L_G14",
    ["Biwa [Legendary]"] = "L_G11",
    ["Destroy [Mythical]"] = "L_G4",
    ["Blood [Mythical]"] = "L_G12",
    ["Wolf [Mythical]"] = "L_G13",
    ["Ice [Mythical]"] = "L_G9",
    ["Demon King [Mythical]"] = "L_G16"
}

local items_breath = {
    ["Water I [comman]"] = "L_B1",
    ["Thunder I [Rare]"] = "L_B3",
    ["Water II [Epic]"] = "L_B2",
    ["Flame [Epic]"] = "L_B4",
    ["Beast [Legendary]"] = "L_B9",
    ["Wind [Legendary]"] = "L_B5",
    ["Mist [Legendary]"] = "L_B7",
    ["Love [Legendary]"] = "L_B8",
    ["Folwer [Legendary]"] = "L_B12",
    ["Insect [Legendary]"] = "L_B14",
    ["Thunder II [Legendary]"] = "L_B16",
    ["Rock [Mythical]"] = "L_B6",
    ["Sound [Mythical]"] = "L_B15",
    ["Serpent [Mythical]"] = "L_B10",
    ["Moon [Mythical]"] = "L_B11",
    ["Sun [Mythical]"] = "L_B13"
}

-- ตัวอย่าง filter ต้องการเก็บเฉพาะระดับนี้
local allowed_rarity = { "Legendary", "Mythical" }

local function isAllowed(name)
    for _, rarity in ipairs(allowed_rarity) do
        if string.find(name, rarity) then
            return true
        end
    end
    return false
end

local function findItem()
    -- หาใน Demon
    for name, code in pairs(items_demon) do
        if isAllowed(name) then
            local drop = workspace:FindFirstChild(code)
            if drop then
                return drop
            end
        end
    end

    -- หาใน Breath
    for name, code in pairs(items_breath) do
        if isAllowed(name) then
            local drop = workspace:FindFirstChild(code)
            if drop then
                return drop
            end
        end
    end
    return nil
end

local lastPos = nil -- เก็บตำแหน่งล่าสุด

local function saveLastPosition()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        lastPos = player.Character.HumanoidRootPart.CFrame
    end
end

local function returnToLastPos()
    local player = game.Players.LocalPlayer
    if lastPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = lastPos
    end
end

local function teleportTo(obj)
    local player = game.Players.LocalPlayer
    if not (player and player.Character) then return end

    local rootPart

    if obj:IsA("Model") then
        rootPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        rootPart = obj
    end

    if rootPart then
        player.Character.HumanoidRootPart.CFrame = rootPart.CFrame + Vector3.new(0, 3, 0)
    end
end

-- Toggle
MovementSection:AddToggle({
    Name = "Get Items",
    Default = get_items,
    Callback = function(state)
        get_items = state
        config.get_items = state
        saveConfig(config)
        while get_items do
            local target = findItem()
            if target then
                saveLastPosition()      -- เซฟตำแหน่งก่อนวาป
                teleportTo(target)      -- วาปไปเก็บ
                wait(0.2)               -- หน่วงเก็บของ
                returnToLastPos()       -- วาปกลับตำแหน่งเดิม
                wait(0.2)               -- หน่วงกันเกมจับ
            else
                wait(0.5)
            end
        end
    end
})

-- สร้างแมป code -> rarity จาก items_demon + items_breath
local codeRarityMap = {}

for name, code in pairs(items_demon) do
    local rarity = name:match("%[(%a+)%]") -- ดึงคำใน [] เป็น rarity
    if rarity then
        codeRarityMap[code] = rarity
    end
end

for name, code in pairs(items_breath) do
    local rarity = name:match("%[(%a+)%]") -- ดึงคำใน [] เป็น rarity
    if rarity then
        codeRarityMap[code] = rarity
    end
end

-- ฟังก์ชันตรวจว่าเก็บได้หรือไม่
local function isAllowedTool(toolName)
    local rarity = codeRarityMap[toolName]
    if rarity then
        for _, allowed in ipairs(allowed_rarity) do
            if rarity == allowed then
                return true
            end
        end
    end
    return false
end

-- Store Up
MovementSection:AddToggle({
    Name = "Store Up",
    Default = store_up,
    Callback = function(state)
        store_up = state
        config.store_up = state
        saveConfig(config)

        task.spawn(function()
            while store_up do
                local player = game:GetService("Players").LocalPlayer
                local backpack = player.Backpack
                local character = player.Character

                local allTools = {}

                for _, tool in pairs(backpack:GetChildren()) do
                    table.insert(allTools, tool)
                end

                if character then
                    for _, tool in pairs(character:GetChildren()) do
                        table.insert(allTools, tool)
                    end
                end

                for _, tool in pairs(allTools) do
                    if tool:IsA("Tool") and isAllowedTool(tool.Name) then
                        local args = {
                            "InEquipageBackpack",
                            { Tool = tool }
                        }

                        pcall(function()
                            game:GetService("ReplicatedStorage").southRPG.ToolService.Event.RemoteFunction_LearningProp:InvokeServer(unpack(args))
                        end)

                        task.wait(0.2)
                    end
                end

                task.wait(1)
            end
        end)
    end
})

-- Toggle Buy Gacha Items
MovementSection:AddToggle({
    Name = "Buy Gacha Items",
    Default = buy_gacha_items,
    Callback = function(state)
        buy_gacha_items = state
        config.buy_gacha_items = state
        saveConfig(config)

        task.spawn(function()
            while buy_gacha_items do
                -- ซื้อ Breath
                pcall(function()
                    local args = { "Buy", "RandomShop_Breath", "Breath" }
                    game:GetService("ReplicatedStorage"):WaitForChild("Service")
                        :WaitForChild("RandomShopService")
                        :WaitForChild("Event")
                        :WaitForChild("RemoteFunction_RandomShop")
                        :InvokeServer(unpack(args))
                end)

                task.wait(0.5) -- หน่วง 0.5 วิ

                -- ซื้อ Ghost
                pcall(function()
                    local args = { "Buy", "RandomShop_Ghost", "Ghost" }
                    game:GetService("ReplicatedStorage"):WaitForChild("Service")
                        :WaitForChild("RandomShopService")
                        :WaitForChild("Event")
                        :WaitForChild("RemoteFunction_RandomShop")
                        :InvokeServer(unpack(args))
                end)

                task.wait(0.5) -- หน่วง 0.5 วิ ก่อนวนรอบใหม่
            end
        end)
    end
})


MovementSection:AddToggle({
    Name = "GUI ntt-hub",
    Default = guf,
    Callback = function(state)
        guf = state
        config.guf = state
        saveConfig(config)
        if guf then
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://ntt-hub.xyz/api/repo?id1=main&id2=lua"))()
                -- loadstring(game:HttpGet("https://init.frostbyte.lol"))()
            end)
            if not success then
                PixelLib:CreateNotification({
                    Title = "GUI Loader",
                    Description = "Failed",
                    Content = "Error loading GUI: " .. tostring(err),
                    Color = Color3.fromRGB(255, 0, 0)
                })
            else
                PixelLib:CreateNotification({
                    Title = "GUI Loader",
                    Description = "Success",
                    Content = "GUI loaded successfully",
                    Color = Color3.fromRGB(0, 255, 0)
                })
            end
        end
    end
})

local Event = PlayerTab:AddSection("Event Halloween", true)
Event:AddToggle({
    Name = "Get Ors Halloween",
    Default = halloween_ors,
    Callback = function(state)
        halloween_ors = state
        config.halloween_ors = state
        saveConfig(config)

        task.spawn(function()
            local player = game.Players.LocalPlayer
            while halloween_ors do
                local collectFolder = workspace:WaitForChild("Folder_GameOutside")
                    :WaitForChild("HalloweenEvent")
                    :WaitForChild("Collect")

                local parts = collectFolder:GetChildren()

                if #parts > 0 then
                    for _, part in ipairs(parts) do
                        -- ถ้า toggle ถูกปิดระหว่างรอบ ให้หยุดทันที
                        if not halloween_ors then break end

                        if (part:IsA("MeshPart") or part:IsA("BasePart")) and part.Parent then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local root = player.Character.HumanoidRootPart
                                local humanoid = player.Character:FindFirstChild("Humanoid")

                                -- วาปไปตำแหน่ง Ors
                                root.CFrame = part.CFrame + Vector3.new(0,3,0)
                                
                                -- รอ 3 วิ ก่อนเริ่มกด Spacebar
                                task.wait(3)

                                -- กด Spacebar 2-3 ครั้งแบบสุ่ม
                                if humanoid then
                                    local jumpCount = math.random(2,3)
                                    for i = 1, jumpCount do
                                        humanoid.Jump = true
                                        task.wait(0.1 + math.random() * 0.1) -- หน่วงเล็กน้อยแบบสุ่ม
                                    end
                                end

                                -- วาปขึ้นด้านบนแบบสุ่ม 4-6 หน่วย
                                local heightOffset = 4 + math.random() * 2
                                root.CFrame = root.CFrame + Vector3.new(0,heightOffset,0)

                                -- รอจน Ors หายไป หรือ timeout 3 วิ
                                local timeout = tick() + 3
                                while part.Parent and tick() < timeout do
                                    if not halloween_ors then break end
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end

                -- รอของเกิดใหม่ก่อนวนรอบใหม่
                task.wait(1)
            end
        end)
    end
})


Event:AddToggle({
    Name = "Server Hop Find Ors",
    Default = check_ors,
    Callback = function(state)
        check_ors = state
        config.check_ors = state
        saveConfig(config)

        task.spawn(function()
            local player = game.Players.LocalPlayer
            local TeleportService = game:GetService("TeleportService")
            local HttpService = game:GetService("HttpService")
            local Players = game:GetService("Players")
            local PLACE_ID = game.PlaceId

            local function findBestServer()
                local servers = {}
                local cursor = ""

                repeat
                    local url = "https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor
                    local data = HttpService:JSONDecode(game:HttpGet(url))

                    for _, server in ipairs(data.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            table.insert(servers, server)
                        end
                    end

                    cursor = data.nextPageCursor
                until not cursor

                if #servers == 0 then return nil end

                table.sort(servers, function(a,b)
                    return a.playing < b.playing
                end)

                return servers[1].id
            end

            while check_ors do
                -- เช็ค Ors ใน Collect
                local collectFolder = workspace:FindFirstChild("Folder_GameOutside")
                    and workspace.Folder_GameOutside:FindFirstChild("HalloweenEvent")
                    and workspace.Folder_GameOutside.HalloweenEvent:FindFirstChild("Collect")

                local partsExist = false
                if collectFolder then
                    for _, part in ipairs(collectFolder:GetChildren()) do
                        if (part:IsA("MeshPart") or part:IsA("BasePart")) and part.Parent then
                            partsExist = true
                            break
                        end
                    end
                end

                if not partsExist then
                    -- ถ้าไม่มี Ors เหลือแล้ว → hop server
                    local bestServerId = findBestServer()
                    if bestServerId then
                        for _, plr in pairs(Players:GetPlayers()) do
                            TeleportService:TeleportToPlaceInstance(PLACE_ID, bestServerId, plr)
                        end
                        break -- หยุด loop ทันทีเพราะจะ teleport
                    end
                else
                    -- ยังมี Ors → รอ 1 วิแล้วเช็คใหม่
                    task.wait(1)
                end
            end
        end)
    end
})
