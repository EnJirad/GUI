local Xlib = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnJirad/GUI/main/Xlib'))()
local Window = Xlib:MakeWindow({Name = "Legends Re:Written World 1"})

--local TweenService
local TweenService = game:GetService("TweenService")
local TweenInfoClose = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local Character = game.Players.LocalPlayer.Character
local StarterGui = game:GetService("StarterGui")

--local Players
local Players = game:GetService("Players")
local player = game:GetService("Players").LocalPlayer
local char = Players.LocalPlayer.Character
local HumanoidRootPart = Character.HumanoidRootPart

--local WSH
local Workspace = game:GetService("Workspace")


local Tab1 = Xlib:MakeTab({
    Name = "Player",
    Parent = Window
})

-- Infinite Jump Toggle
local InfJump = false
Xlib:MakeToggle({
    Name = "InfJump",
    Parent = Tab1,
    Default = false,
    Callback = function(value)
        InfJump = value
    end
})

local function onJumpRequest()
    if InfJump then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end

game:GetService("UserInputService").JumpRequest:connect(onJumpRequest)

local AntiAFK = false
Xlib:MakeToggle({
    Name = "Anti AFK",
    Parent = Tab1,
    Default = false,
    Callback = function(value)
        AntiAFK = value
        if AntiAFK then
            wait(3)
            local VirtualUser=game:service'VirtualUser'
            game:service('Players').LocalPlayer.Idled:connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

-- Speed Toggle
local originalSpeed = Character.Humanoid.WalkSpeed
local Speed = 85

Xlib:MakeToggle({
    Name = "Up Speed 85%",
    Parent = Tab1,
    Default = false,
    Callback = function(value)
        Character.Humanoid.WalkSpeed = value and Speed or originalSpeed
    end
})

local Get_Drop = false
Xlib:MakeToggle({
    Name = "Get Item Drop",
    Parent = Tab1,
    Default = false,
    Callback = function(value)
        Get_Drop = value
        if value then
            spawn(function()
                while Get_Drop do
                    for _, model in ipairs(Workspace.Drops:GetChildren()) do
                        if model:IsA("Model") then
                            for _, item in ipairs(model:GetChildren()) do
                                if item:IsA("Part") then
                                    item.CFrame = HumanoidRootPart.CFrame
                                    wait(0.00001)
                                end
                            end
                        end
                    end
                    wait(0.00001)
                end
            end)
        end
    end
})

local DailyLogin = false
Xlib:MakeButton({
    Name = "Login Rewards",
    Parent = Tab1,
    Callback = function()
        if DailyLogin then
            game:GetService("ReplicatedStorage").Remotes.DailyLogin:InvokeServer()
        end
    end
})

-- Teleport Function
local function TPSMB(destination)
    HumanoidRootPart.Anchored = true
    
    local distance = (destination.Position - HumanoidRootPart.Position).Magnitude
    local speed = 500
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = destination})
    tween:Play()
    tween.Completed:Wait()
    HumanoidRootPart.Anchored = false
end

local TpFunctions = {
    Shop = function() TPSMB(CFrame.new(4320.8154296875, -155.29226684570312, 6378.77880859375)) end,
    BlackSmith = function() TPSMB(CFrame.new(211.25051879882812, 18.948881149291992, -368.9964294433594)) end,
    Bank = function() TPSMB(CFrame.new(4190.47802734375, -155.2935333251953, 6377.533203125)) end
}

local M_Market

Xlib:MakeDropdown({
    Name = "Select Market",
    Parent = Tab1,
    Options = {"Shop", "BlackSmith", "Bank"},
    Callback = function(option)
        M_Market = TpFunctions[option]
    end
})

Xlib:MakeButton({
    Name = "Market",
    Parent = Tab1,
    Callback = function()
        if M_Market then
            M_Market()
        end
    end
})


local Tab2 = Xlib:MakeTab({
    Name = "Farm Other",
    Parent = Window
})

local PickAxe = true
local Ore = true

-- Teleport Function for Ore Farming
local function TPOre(destination)
    local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
    HumanoidRootPart.Anchored = true
    
    local distance = (destination.Position - HumanoidRootPart.Position).Magnitude
    local speed = 1000
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(HumanoidRootPart, tweenInfo, {CFrame = destination})
    tween:Play()
    tween.Completed:Wait()
    HumanoidRootPart.Anchored = false
end

-- Ore Farming Functions
local Farm_All_Ore = {
    -- Bronze Ore
    BronzOre = function()
        TPOre(CFrame.new(240.1018829345703, 53.02931594848633, -316.3339538574219))
        wait(0.5)
        spawn(function()
            while Ore do
                TPOre(CFrame.new(240.1018829345703, 53.02931594848633, -316.3339538574219))
                wait(1)
                if not Ore then break end
                TPOre(CFrame.new(286.9085693359375, 37.650390625, -320.1934814453125))
                wait(1)
                if not Ore then break end
                TPOre(CFrame.new(187.58328247070312, 19.634105682373047, -390.7674255371094))
                wait(1)
                if not Ore then break end
                TPOre(CFrame.new(193.07778930664062, 19.430782318115234, -339.6507873535156))
                wait(1)
                if not Ore then break end
            end
        end)
        spawn(function()
            while PickAxe do
                game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
    -- Iron Ore
    IronOre = function()
        TPOre(CFrame.new(181.53350830078125, 19.735998153686523, -362.05657958984375))
        wait(0.5)
        spawn(function()
            while Ore do
                TPOre(CFrame.new(160.1562957763672, 19.645458221435547, -367.737548828125))
                wait(1)
                if not Ore then break end
                TPOre(CFrame.new(255.09307861328125, 48.793399810791016, -301.021484375))
                wait(1)
                if not Ore then break end
                TPOre(CFrame.new(285.98919677734375, 40.22940444946289, -347.4054870605469))
                wait(1)
                if not Ore then break end
            end
        end)
        spawn(function()
            while PickAxe do
                game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
        
    --- Black Ore
    BlackOre = function()
        TPOre(CFrame.new(223.08132934570312, 136.53045654296875, -531.5103149414062))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(200.4218292236328, 109.65225219726562, -492.6632080078125))
                    wait(1)
                    if not Ore then break end
                    TPOre(CFrame.new(211.94068908691406, 96.56543731689453, -467.3862609863281))
                    wait(1)
                    if not Ore then break end
                    TPOre(CFrame.new(241.6495361328125, 87.74860382080078, -476.3205871582031))
                    wait(1)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
    --- Adamant Ore
    AdamantOre = function()
        TPOre(CFrame.new(-330.7143249511719, 214.9051971435547, -325.5738525390625))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(-323.6196594238281, 215.02316284179688, -325.8515625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-359.86956787109375, 210.59722900390625, -328.3359069824219))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-330.3594665527344, 186.15567016601562, -439.197998046875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-353.5116882324219, 139.93310546875, -427.1103210449219))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-367.4247741699219, 139.52586364746094, -356.20098876953125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-392.8315124511719, 137.77349853515625, -348.9147644042969))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-382.199462890625, 141.27218627929688, -332.5194091796875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-381.3611145019531, 93.83789825439453, -382.1306457519531))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-359.61029052734375, 91.9556655883789, -405.3069152832031))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
    --- White Stone
    WhiteStone = function()
        TPOre(CFrame.new(-69.30982208251953, 38.51305389404297, 450.5069274902344))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(-51.26939392089844, 39.663421630859375, 425.5710144042969))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-66.40071868896484, 38.557960510253906, 469.778564453125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-92.4893798828125, 38.788429260253906, 503.6325988769531))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-108.41912841796875, 39.03948211669922, 435.2402038574219))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-172.05116271972656, 40.20874786376953, 484.7751770019531))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-198.0983428955078, 39.03388214111328, 526.1689453125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-280.8353271484375, 39.18865966796875, 556.41357421875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-346.2044982910156, 39.409767150878906, 605.179931640625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-401.2690734863281, 39.195411682128906, 629.8668823242188))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-415.302734375, 39.18645477294922, 668.9577026367188))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
    --- Rune Ore
    RuneOre = function()
        TPOre(CFrame.new(55.129642486572266, 35.783897399902344, 828.6396484375))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(81.77721405029297, 36.264652252197266, 822.6876220703125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4.722234725952148, 36.145389556884766, 818.7888793945312))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-115.99430847167969, 36.562530517578125, 900.9732666015625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-108.41912841796875, 39.03948211669922, 435.2402038574219))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-171.3794403076172, 36.269229888916016, 913.6370239257812))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-252.55679321289062, 36.51658248901367, 939.2569580078125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-308.1146545410156, 36.3888053894043, 938.2496337890625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(-330.0320739746094, 36.216060638427734, 910.8071899414062))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
    --- Gold Ore
    GoldOre = function()
        TPOre(CFrame.new(3364.35009765625, -749.7156372070312, 5966.05908203125))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(3364.78515625, -749.7144165039062, 5970.09716796875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3395.778076171875, -751.8324584960938, 5947.6279296875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3426.228515625, -749.2742919921875, 5961.41552734375))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3476.06591796875, -750.1771240234375, 5945.53515625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3506.312255859375, -750.3860473632812, 5958.54541015625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3509.4072265625, -752.0604858398438, 5980.52099609375))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
    
    --- Crystal Ore
    CrystalOre = function()
        TPOre(CFrame.new(3715.572265625, -762.5343627929688, 5414.412109375))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(3716.40087890625, -758.3865356445312, 5398.45361328125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3691.34619140625, -758.3460083007812, 5415.5419921875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(3741.0693359375, -758.5548706054688, 5410.548828125))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,

    --- Stardust Ore
    CrystalOre = function()
        TPOre(CFrame.new(4434.9765625, -718.8471069335938, 5935.52099609375))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(4423.70166015625, -718.8588256835938, 5930.6494140625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4450.2255859375, -718.7822265625, 5999.75244140625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4490.3818359375, -716.229248046875, 5994.5166015625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4512.103515625, -718.8023071289062, 6067.017578125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4577.4404296875, -718.9923095703125, 6174.88525390625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4551.10986328125, -718.2465209960938, 6199.99462890625))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end,
        
    ---Galaxy Ore
    GalaxyOre = function()
        TPOre(CFrame.new(4434.9765625, -718.8471069335938, 5935.52099609375))
        wait(0.5)
            spawn(function()
                while Ore do
                    TPOre(CFrame.new(4451.029296875, -716.109130859375, 5928.19970703125))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4460.94921875, -716.5733642578125, 6086.16796875))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4563.67138671875, -715.7063598632812, 6104.39306640625))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4605.99853515625, -716.2992553710938, 6176.51708984375))
                    wait(2)
                    if not Ore then break end
                    TPOre(CFrame.new(4716.51708984375, -715.8817749023438, 6140.50927734375))
                    wait(2)
                    if not Ore then break end
                end
            end)
            spawn(function()
                while PickAxe do
                    game:GetService("Players").LocalPlayer.Character.PickAxe.SwordScript.Activate:FireServer()
                wait(0.3)
            end
        end)
    end
}

local F_Ore
Xlib:MakeDropdown({
    Name = "Select Ore",
    Parent = Tab2,
    Options = {"BronzOre", "IronOre", "BlackOre", 
                "AdamantOre", "WhiteStone", "RuneOre", 
                "GoldOre", "CrystalOre", "StardustOre", "GalaxyOre"},
    Callback = function(option)
        F_Ore = Farm_All_Ore[option]
    end
})

Xlib:MakeToggle({
    Name = "Farm Ore",
    Parent = Tab2,
    Default = false,
    Callback = function(value)
        Ore = value
        PickAxe = value
        if value and F_Ore then
            F_Ore()
        end
    end
})

-- Auto Fish Toggle
local AutoFish = false
Xlib:MakeToggle({
    Name = "Auto Fish",
    Parent = Tab2,
    Default = false,
    Callback = function(value)
        AutoFish = value
        spawn(function()
            while AutoFish do
                local ohInstance1 = workspace.FishingSpawns.Fishing
                player.PlayerGui.Fish.Ado.catch:FireServer(ohInstance1)
                wait(5)
            end
        end)
    end
})

-- Dash Toggle
local Dash = false
Xlib:MakeToggle({
    Name = "Farm Speed",
    Parent = Tab2,
    Default = false,
    Callback = function(value)
        Dash = value
        spawn(function()
            while Dash do
                player.PlayerGui.Parkour.Script.Dash:FireServer()
                wait(0.5)
            end
        end)
    end
})

local Tab3 = Xlib:MakeTab({
    Name = "Farm Mobs",
    Parent = Window
})

local function getAllMonsterNames()
    local monsterNames = {}
    for _, monster in pairs(Workspace.Mobs:GetChildren()) do
        local name = monster.Name
        table.insert(monsterNames, name)
    end
    return monsterNames
end

-- Function to get monster names and count
local function getMonsterNameCount()
    local monsterCount = {}
    for _, monster in pairs(Workspace.Mobs:GetChildren()) do
        local name = monster.Name
        local baseName = name:gsub("%d+$", "")
        if not monsterCount[baseName] then
            monsterCount[baseName] = {count = 0, names = {}}
        end
        monsterCount[baseName].count = monsterCount[baseName].count + 1
        table.insert(monsterCount[baseName].names, name)
    end
    return monsterCount
end

local function createSpawnBossUI(monsterNames, tabName)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SpawnBossUI_" .. tabName
    ScreenGui.Parent = game:GetService("CoreGui")

    local Frame = Instance.new("Frame")
    Frame.Name = "SpawnBossFrame_" .. tabName
    Frame.Size = UDim2.new(0, 220, 0, 320)
    Frame.Position = UDim2.new(0.5, -110, 0.5, -160)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = tabName
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Parent = Frame

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Size = UDim2.new(1, 0, 1, -30)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 30)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Parent = Frame
    ScrollFrame.ScrollBarThickness = 6

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = ScrollFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    -- Sort and display monster names
    table.sort(monsterNames)

    for i, name in ipairs(monsterNames) do
        local Frame = Instance.new("Frame")
        Frame.Name = "MonsterFrame"
        Frame.Size = UDim2.new(1, 0, 0, 24)
        Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Frame.BorderSizePixel = 0
        Frame.Parent = Container

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "MonsterName"
        TextLabel.Text = name
        TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TextLabel.TextSize = 16
        TextLabel.Font = Enum.Font.SourceSans
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Parent = Frame

        local Divider = Instance.new("Frame")
        Divider.Name = "Divider"
        Divider.Size = UDim2.new(1, 0, 0, 1)
        Divider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        Divider.BorderSizePixel = 0
        Divider.Position = UDim2.new(0, 0, 1, 0)
        Divider.Parent = Frame

        -- Update container size
        Container.Size = UDim2.new(1, 0, 0, Container.Size.Y.Offset + UIListLayout.Padding.Offset + 24)
    end

    local lastMonster = Container:FindFirstChild("MonsterFrame", true)
    if lastMonster then
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Container.Size.Y.Offset)
        ScrollFrame.CanvasPosition = Vector2.new(0, lastMonster.Position.Y.Offset)
    end
end

local function refreshUI()
    local monsterCount = getMonsterNameCount()
    local bossMonsterNames = {}
    local allMonsterNames = {}
    for baseName, data in pairs(monsterCount) do
        if data.count == 1 then
            table.insert(bossMonsterNames, data.names[1])
        else
            for _, name in ipairs(data.names) do
                table.insert(allMonsterNames, name)
            end
        end
    end
    local bossToggleValue = false
    local monsterToggleValue = false
    local bossToggle = game:GetService("CoreGui"):FindFirstChild("SpawnBossUI_Boss Monsters")
    if bossToggle then
        bossToggleValue = bossToggle.Visible
    end
    local monsterToggle = game:GetService("CoreGui"):FindFirstChild("SpawnBossUI_Monster")
    if monsterToggle then
        monsterToggleValue = monsterToggle.Visible
    end
    if bossToggleValue then
        createSpawnBossUI(bossMonsterNames, "Boss Monsters")
    end
    if monsterToggleValue then
        createSpawnBossUI(allMonsterNames, "Monster")
    end
end

local function checkFolder()
    while true do
        refreshUI()
        wait(0.5)
    end
end

local BossToggle = Xlib:MakeToggle({
    Name = "Show Boss Spawns",
    Parent = Tab3,
    Default = false,
    Callback = function(value)
        if value then
            local bossToggle = game:GetService("CoreGui"):FindFirstChild("SpawnBossUI_Boss Monsters")
            if not bossToggle then
                local monsterCount = getMonsterNameCount()
                local bossMonsterNames = {}

                for baseName, data in pairs(monsterCount) do
                    if data.count == 1 then
                        table.insert(bossMonsterNames, data.names[1])
                    end
                end

                createSpawnBossUI(bossMonsterNames, "Boss Monsters")
            end
        else
            local existingGui = game:GetService("CoreGui"):FindFirstChild("SpawnBossUI_Boss Monsters")
            if existingGui then
                existingGui:Destroy()
            end
        end
    end
})

local MonsterToggle = Xlib:MakeToggle({
    Name = "Show Gigy Spawns",
    Parent = Tab3,
    Default = false,
    Callback = function(value)
        if value then
            local monsterToggle = game:GetService("CoreGui"):FindFirstChild("SpawnBossUI_Monster")
            if not monsterToggle then
                local monsterCount = getMonsterNameCount()
                local allMonsterNames = {}

                for baseName, data in pairs(monsterCount) do
                    if data.count > 1 then
                        -- Sort names with numbers at the end
                        table.sort(data.names, function(a, b)
                            local numA = tonumber(a:match("%d+$")) or 0
                            local numB = tonumber(b:match("%d+$")) or 0
                            if numA == numB then
                                return a < b
                            else
                                return numA < numB
                            end
                        end)

                        for _, name in ipairs(data.names) do
                            table.insert(allMonsterNames, name)
                        end
                    end
                end

                createSpawnBossUI(allMonsterNames, "Monster")
            end
        else
            local existingGui = game:GetService("CoreGui"):FindFirstChild("SpawnBossUI_Monster")
            if existingGui then
                existingGui:Destroy()
            end
        end
    end
})

local Attack = false
local Equip_Weapon = ""
local Secret_Monster

local function moveTo(destination)
    if not destination then return end
    local distance = (destination.Position - HumanoidRootPart.Position).Magnitude
    local speed = 400
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = destination})
    tween:Play()
    tween.Completed:Wait()
end

local AirParts = {}
local airCF = CFrame.new(0, 0, 0)
-- airCF = CFrame.new(-4416.50048828125, -77.86909484863281, -827.60693359375) ใช้งาน
-- createAirPart() สร้าง

local function createAirPart()
    local airPart = Instance.new("Part", Workspace)
    airPart.Size = Vector3.new(5, 0.5, 5)
    airPart.CFrame = airCF
    airPart.Transparency = 0
    airPart.Anchored = true
    airPart.Name = "AirPart"
    table.insert(AirParts, airPart)
    return airPart
end

local function removeAirParts()
    for _, part in ipairs(AirParts) do
        if part then
            part:Destroy()
        end
    end
    AirParts = {}
end

local AirParts_1 = {}
local function createAirPart_1()
    local airPart = Instance.new("Part", Workspace)
    airPart.Size = Vector3.new(5, 0.5, 5)
    airPart.Transparency = 0
    airPart.Anchored = true
    airPart.Name = "AirPart"
    table.insert(AirParts, airPart)
    return airPart
end

local function removeAirParts_1()
    for _, part in ipairs(AirParts) do
        if part then
            part:Destroy()
        end
    end
    AirParts_1 = {}
end


local function Get_Item()
	spawn(function()
	    while Attack do
	        for _, model in ipairs(Workspace.Drops:GetChildren()) do
	            if model:IsA("Model") then
	                for _, item in ipairs(model:GetChildren()) do
	                    if item:IsA("Part") then
	                        item.CFrame = HumanoidRootPart.CFrame
	                        wait(0.00001)
	                    end
	                end
	            end
	        end
	        wait(0.00001)
	    end
	end)
end

local My_Position = player.Character.HumanoidRootPart.Position
local function checkAndMoveTo(destination)
    local moving = true
    spawn(function()
        while Attack and moving do
            local currentPos = HumanoidRootPart.Position
            if (currentPos - destination.Position).Magnitude > 1 then
                moveTo(destination)
            else
                moving = false
            end
            wait(2)
        end
    end)
end

local All_Monster = {
    ["Bandit Level:2"] = function()
        local MobName = "Bandit"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-813.4490356445312, 111.51054382324219, 121.87625885009766)
            createAirPart()
            local destination = CFrame.new(-813.4490356445312, 114.51054382324219, 121.87625885009766)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-685.0829467773438, 12.567567825317383, 275.410888671875))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
	end,

	["Goblin & HobGoblin Level:3-5"] = function()
    	local MobNames = {"Goblin", "HobGoblin"}
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-1235.182861328125, 171.1309814453125, -412.7290954589844)
 			createAirPart()
	        local destination = CFrame.new(-1235.182861328125, 174.1309814453125, -412.7290954589844)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                	for _, name in ipairs(MobNames) do
	                    if v.Name:match("^" .. name) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
	                        spawn(function()
	                            for _, tool in ipairs(Character:GetChildren()) do
	                                if tool:IsA("Tool") then
	                                    for _, script in ipairs(tool:GetChildren()) do
	                                        if script:IsA("Script") and script.Name ~= "Client" then
	                                            for _, Remote in ipairs(script:GetChildren()) do
	                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
	                                                    spawn(function()
	                                                        while Attack do
	                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
	                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
	                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
	                                                                end
	                                                            end        
	                                                            wait(0.1)
	                                                            repeat wait() until v.Humanoid.Health <= 0
	                                                        end
	                                                    end)
	                                                end
	                                            end
	                                        end
	                                    end
	                                end
	                            end
	                        end)
	                    end
	                end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-1131.2349853515625, 4.969914436340332, -317.134521484375))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                	for _, name in ipairs(MobNames) do
	                    if v.Name:match("^" .. name) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
	                        spawn(function()
	                            while Attack and v.Humanoid.Health > 0 do
	                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
	                                wait(0.1)
	                                repeat wait() until v.Humanoid.Health <= 0
	                            end
	                        end)
	                        spawn(function()
	                            for _, tool in ipairs(Character:GetChildren()) do
	                                if tool:IsA("Tool") then
	                                    for _, script in ipairs(tool:GetChildren()) do
	                                        if script:IsA("Script") and script.Name ~= "Client" then
	                                            for _, Remote in ipairs(script:GetChildren()) do
	                                                if Remote:IsA("RemoteEvent") then
	                                                    spawn(function()
	                                                        while Attack do
	                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
	                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
	                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
	                                                                end    
	                                                            end        
	                                                            wait(0.1)
	                                                            repeat wait() until v.Humanoid.Health <= 0
	                                                        end
	                                                    end)
	                                                end
	                                            end
	                                        end
	                                    end
	                                end
	                            end
	                        end)
	                    end
	                end
                end
                wait(0.1)
            end
        end
    end,

    ["Skeleton Level:15"] = function()
        local MobName = "Skeleton"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-2391.349853515625, -148.20631408691406, -1054.1842041015625)
 			createAirPart()
        	local destination = CFrame.new(-2391.349853515625, -145.20631408691406, -1054.1842041015625)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-2548.013427734375, -278.6241149902344, -1076.99072265625))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["DarkStoneKnight Level:25"] = function()
		local MobName = "DarkStoneKnight"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-3401.236572265625, 375.4302673339844, -439.8885192871094)
 			createAirPart()
        	local destination = CFrame.new(-3401.236572265625, 378.4302673339844, -439.8885192871094)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-3307.340576171875, 117.6991195678711, -1105.55908203125))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Witch Level:35"] = function()
        local MobName = "Witch"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-124.02674102783203, 239.83639526367188, -483.43310546875)
 			createAirPart()
        	local destination = CFrame.new(-124.02674102783203, 242.83639526367188, -483.43310546875)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-269.5739440917969, 4.813971996307373, -503.3072204589844))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Boar King Level:40"] = function()
        local MobName = "Boar King"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-3882.43505859375, 629.5661010742188, -858.0487670898438)
 			createAirPart()
            local destination = CFrame.new(-3882.43505859375, 632.5661010742188, -858.0487670898438)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-3893.636962890625, 398.9500427246094, -861.0621948242188))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,

    ["Golem Level:50"] = function()
        local MobName = "Golem"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-1072.201904296875, 423.0378112792969, -215.87530517578125)
 			createAirPart()
            local destination = CFrame.new(-1072.201904296875, 426.0378112792969, -215.87530517578125)
            checkAndMoveTo(destination)
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-843.4234619140625, 288.68218994140625, -189.60377502441406))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                         		-- TweenService:Create(v.HumanoidRootPart, TweenInfoClose, {CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play() มอนสเตอร์วาปมาหาเรา
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,

    ["Plant Beast Level:65"] = function()
        local MobName = "PlantBeast"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-941.6878051757812, 171.4872589111328, -1666.0322265625)
 			createAirPart()
        	local destination = CFrame.new(-941.6878051757812, 174.4872589111328, -1666.0322265625)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-1101.629150390625, 185.9998321533203, -1735.87451171875))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,

    ["Elsa Level:75"] = function()
        local MobName = "Elsa"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(931.5955810546875, -181.04214477539062, -484.5388488769531)
 			createAirPart()
        	local destination = CFrame.new(931.5955810546875, -178.04214477539062, -484.5388488769531)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(957.4970092773438, -225.63124084472656, -518.5598754882812))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Rouge Paladin Level:80"] = function()
        local MobName = "RougePaladin"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-4289.1083984375, -185.9418487548828, -685.239501953125) 
	   		createAirPart()
            local destination = CFrame.new(-4289.1083984375, -182.9418487548828, -685.239501953125)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-4290.62109375, -339.9622802734375, -680.96923828125))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Ruined Knight Level:85"] = function()
        local MobName = "RuinedKnight"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-3362.32080078125, -201.86561584472656, -906.3529663085938) 
	   		createAirPart()
            local destination = CFrame.new(-3362.32080078125, -198.86561584472656, -906.3529663085938)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-3359.1982421875, -339.08013916015625, -904.0843505859375))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Hiyay Level:90"] = function()
        local MobName = "Hiei"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-3119.896484375, 463.95001220703125, -1144.848876953125) 
	   		createAirPart()
            local destination = CFrame.new(-3119.896484375, 466.95001220703125, -1144.848876953125)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-3119.896484375, 463.95001220703125, -1144.848876953125))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Kaze Level:100"] = function()
        local MobName = "Kaze"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-3391.572265625, -185.09054565429688, -1575.2874755859375) 
	   		createAirPart()
            local destination = CFrame.new(-3391.572265625, -182.09054565429688, -1575.2874755859375)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-3393.783447265625, -339.6742248535156, -1576.4881591796875))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Nodryre Level:100"] = function()
        local MobName = "Nodryre"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(231.00592041015625, 120.15098571777344, -203.12843322753906) 
	   		createAirPart()
            local destination = CFrame.new(231.00592041015625, 123.15098571777344, -203.12843322753906)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(231.00592041015625, 120.15098571777344, -203.12843322753906))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
        
    ["Dragon Level:105"] = function()
        local MobName = "Dragon"
        local distance = 10
        local height = 0
        
        if Equip_Weapon == "Bow Farm" then
        	local airPart = createAirPart_1()
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                    spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                            local targetPosition = v.HumanoidRootPart.CFrame.Position + v.HumanoidRootPart.CFrame.LookVector * -distance + Vector3.new(0, height, 0)
                                airPart.CFrame = CFrame.new(targetPosition) * CFrame.new(0, 5, 0)
                                moveTo(airPart.CFrame)
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-3228.85302734375, 491.5760192871094, -581.2042846679688))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["MichKal Level:150"] = function()
        local MobName = "Michkal"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-982.2509155273438, 177.73472595214844, -1793.6485595703125) 
	   		createAirPart()
            local destination = CFrame.new(-982.2509155273438, 180.73472595214844, -1793.6485595703125)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-902.2942504882812, 155.3244171142578, -1599.96484375))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Melioofus Level:200"] = function()
        local MobName = "Melioofus"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-833.2517700195312, 484.2136535644531, 223.50010681152344) 
	   		createAirPart()
            local destination = CFrame.new(-833.2517700195312, 487.2136535644531, 223.50010681152344)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-1004.2633056640625, 339.01983642578125, 175.7955322265625))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Kurito Level:333"] = function()
        local MobName = "Kurito"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-2773.451416015625, -229.88571166992188, -362.5797119140625) 
	   		createAirPart()
            local destination = CFrame.new(-2773.451416015625, -226.88571166992188, -362.5797119140625)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-2773.451416015625, -339.9622497558594, -362.5797119140625))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
    ["Regulus Level:???"] = function()
        local MobName = "Regulus"
        if Equip_Weapon == "Bow Farm" then
            airCF = CFrame.new(-2972.357421875, -229.97445678710938, -340.29730224609375) 
	   		createAirPart()
            local destination = CFrame.new(-2972.357421875, -226.97445678710938, -340.29730224609375)
            checkAndMoveTo(destination)
            wait(0.5)
            
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") or Remote.Name == "Shoot" or Remote.Name ~= "Charge" then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        elseif Equip_Weapon == "Sword Farm" then
            moveTo(CFrame.new(-2963.154541015625, -339.9622802734375, -343.052490234375))
            wait(0.5)
            while Attack do
                Get_Item()
                for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if v.Name == MobName and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                        spawn(function()
                            while Attack and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)}):Play()
                                wait(0.1)
                                repeat wait() until v.Humanoid.Health <= 0
                            end
                        end)
                        spawn(function()
                            for _, tool in ipairs(Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    for _, script in ipairs(tool:GetChildren()) do
                                        if script:IsA("Script") and script.Name ~= "Client" then
                                            for _, Remote in ipairs(script:GetChildren()) do
                                                if Remote:IsA("RemoteEvent") then
                                                    spawn(function()
                                                        while Attack do
                                                            for _, v in ipairs(Workspace.Mobs:GetChildren()) do
                                                                if v.Name:match("^" .. MobName) and v:FindFirstChild("HumanoidRootPart") and (v.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 5000 then
                                                                    game:GetService("Players").LocalPlayer.Character[tool.Name][script.Name][Remote.Name]:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                                                end    
                                                            end        
                                                            wait(0.1)
                                                            repeat wait() until v.Humanoid.Health <= 0
                                                        end
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
                wait(0.1)
            end
        end
    end,
    
}

Xlib:MakeDropdown({
    Name = "Select Weapon",
    Parent = Tab3,
    Options = {"Bow Farm", "Sword Farm"},
    Callback = function(option)
        Equip_Weapon = option
    end
})

Xlib:MakeDropdown({
    Name = "Select Monsters",
    Parent = Tab3,
    Options = {
        "Bandit Level:2", "Goblin & HobGoblin Level:3-5",
        "Skeleton Level:15", "DarkStoneKnight Level:25", 
        "Witch Level:35", "Boar King Level:40", "Golem Level:50",
        "Plant Beast Level:65", "Elsa Level:75", "Rouge Paladin Level:80",
        "Ruined Knight Level:85", "Hiyay Level:90", "Kaze Level:100",
        "Nodryre Level:100", "Dragon Level:105", "MichKal Level:150",
        "Melioofus Level:200", "Kurito Level:333", "Regulus Level:???"
    },
    Callback = function(option)
        Secret_Monster = All_Monster[option]
    end
})

Xlib:MakeToggle({
    Name = "Start Auto Farm",
    Parent = Tab3,
    Default = false,
    Callback = function(value)
        Attack = value
        if value and Secret_Monster then
            Secret_Monster()
        else
            removeAirParts()
            removeAirParts_1()
        end
    end
})


local Tab4 = Xlib:MakeTab({
    Name = "Magic Farm",
    Parent = Window
})

local Tab5 = Xlib:MakeTab({
    Name = "Other",
    Parent = Window
})


local function TpLand(destination)
    HumanoidRootPart.Anchored = true
    
    local distance = (destination.Position - HumanoidRootPart.Position).Magnitude
    local speed =  400
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = destination})
    tween:Play()
    tween.Completed:Wait()
    HumanoidRootPart.Anchored = false
end

local TP_AllLand = {
    ["First City"] = function() TpLand(CFrame.new(-761.6853637695312, 99.91349029541016, 440.947998046875)) end,
    ["Floating Island"] = function() TpLand(CFrame.new(-732.0307006835938, 402.58660888671875, -625.8231201171875)) end,
    ["Castle"] = function() TpLand(CFrame.new(280.6831970214844, 19.368431091308594, -511.48638916015625)) end,
    ["High Mountain"] = function() TpLand(CFrame.new(-2389.85302734375, 85.94990539550781, -550.436767578125)) end,
    ["Village"] = function() TpLand(CFrame.new(-1517.326416015625, 0.9699152708053589, -755.0040283203125)) end,
    ["Forest"] = function() TpLand(CFrame.new(-685.2787475585938, 30.715778350830078, -1542.4014892578125)) end,
}

local TP_Land

Xlib:MakeDropdown({
    Name = "Select Market",
    Parent = Tab5,
    Options = {"First City", "Floating Island", "Castle", "High Mountain", "Village", "Forest",},
    Callback = function(option)
        TP_Land = TP_AllLand[option]
    end
})

Xlib:MakeButton({
    Name = "Click TP",
    Parent = Tab5,
    Callback = function()
        if TP_Land then
            TP_Land()
        end
    end
})

local Refresh = false
Xlib:MakeButton({
    Name = "Refresh Script",
    Parent = Tab5,
    Callback = function()
        if Refresh then
            local Game = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnJirad/GUI/main/Main_New.lua'))()  -- Refresh the script
        end
    end
})

local FullBright
Xlib:MakeToggle({
    Name = "FullBright",
    Parent = Tab5,
    Default = false,
    Callback = function(value)
        FullBright = value
        
        _G.FullBrightEnabled = FullBright
        if not _G.FullBrightExecuted then
        _G.FullBrightEnabled = false
        
        _G.NormalLightingSettings = {
			Brightness = game:GetService("Lighting").Brightness,
			ClockTime = game:GetService("Lighting").ClockTime,
		}
        game:GetService("Lighting"):GetPropertyChangedSignal("Brightness"):Connect(function()
			if game:GetService("Lighting").Brightness ~= 1 and game:GetService("Lighting").Brightness ~= _G.NormalLightingSettings.Brightness then
				_G.NormalLightingSettings.Brightness = game:GetService("Lighting").Brightness
				if not _G.FullBrightEnabled then
					repeat
						wait()
					until _G.FullBrightEnabled
				end
				game:GetService("Lighting").Brightness = 1
			end
		end)
		
		game:GetService("Lighting"):GetPropertyChangedSignal("ClockTime"):Connect(function()
			if game:GetService("Lighting").ClockTime ~= 12 and game:GetService("Lighting").ClockTime ~= _G.NormalLightingSettings.ClockTime then
				_G.NormalLightingSettings.ClockTime = game:GetService("Lighting").ClockTime
				if not _G.FullBrightEnabled then
					repeat
						wait()
					until _G.FullBrightEnabled
				end
				game:GetService("Lighting").ClockTime = 12
			end
		end)
		game:GetService("Lighting").Brightness = 1
		game:GetService("Lighting").ClockTime = 12
		local LatestValue = true
		spawn(function()
			repeat
				wait()
			until _G.FullBrightEnabled
			while wait() do
				if _G.FullBrightEnabled ~= LatestValue then
					if not _G.FullBrightEnabled then
						game:GetService("Lighting").Brightness = _G.NormalLightingSettings.Brightness
						game:GetService("Lighting").ClockTime = _G.NormalLightingSettings.ClockTime
	
					else
						game:GetService("Lighting").Brightness = 1
						game:GetService("Lighting").ClockTime = 12
					end
					LatestValue = not LatestValue
				end
			end
		end)
	end
	_G.FullBrightExecuted = true
end
})

local Rejoin = false
Xlib:MakeButton({
    Name = "Rejoin",
    Parent = Tab5,
    Callback = function()
        if Rejoin then
            local tpservice = game:GetService("TeleportService")
            local plr = game.Players.LocalPlayer
            tpservice:Teleport(game.PlaceId, plr)
        end
    end
}) 
