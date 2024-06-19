local Xlib = loadstring(game:HttpGet('https://raw.githubusercontent.com/EnJirad/GUI/main/Xlib'))()

local Window = Xlib:MakeWindow({Name = "Legends Re:Written World 2"})

-- Tab for Player functionalities
local Tab1 = Xlib:MakeTab({
    Name = "Player",
    Parent = Window
})

-- Services and Player Variables
local TweenService = game:GetService("TweenService")
local TweenInfoClose = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Character = player.Character
local HumanoidRootPart = Character.HumanoidRootPart
local Workspace = game:GetService("Workspace")

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

-- Hide Water Toggle
local originalWaterTextures = Workspace:FindFirstChild("WaterTextures")
local isWaterHidden = false

Xlib:MakeToggle({
    Name = "Hide Water",
    Parent = Tab1,
    Default = false,
    Callback = function(value)
        isWaterHidden = value
        if originalWaterTextures then
            for _, child in ipairs(originalWaterTextures:GetChildren()) do
                child.Transparency = isWaterHidden and 1 or 0
            end
        end
    end
})

-- Speed Toggle
local originalSpeed = Character.Humanoid.WalkSpeed
local Speed = 85

Xlib:MakeToggle({
    Name = "Up Speed",
    Parent = Tab1,
    Default = false,
    Callback = function(value)
        Character.Humanoid.WalkSpeed = value and Speed or originalSpeed
    end
})

-- Auto Fish Toggle
local AutoFish = false
Xlib:MakeToggle({
    Name = "Auto Fish",
    Parent = Tab1,
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
    Parent = Tab1,
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

-- Buy RuneArrows Button
local RuneArrows = true
local Amount_RuneArrows = 10000
Xlib:MakeButton({
    Name = "Buy RuneArrows 10000",
    Parent = Tab1,
    Callback = function()
        if RuneArrows then
            local ohString1 = "RuneArrows"
            local ohString2 = "Bows"
            local ohNumber3 = Amount_RuneArrows
            game:GetService("ReplicatedStorage").Remotes.BuyItem:FireServer(ohString1, ohString2, ohNumber3)
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

--------------------------------------------------------------------------------------------------------------------------------------

-- Tab for Ore Farming
local Tab2 = Xlib:MakeTab({
    Name = "Farm Ore",
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


local BowAttack = true
local Mon = true
local HumanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
local TweenService = game:GetService("TweenService")

local function moveTo(destination)
    local distance = (destination.Position - HumanoidRootPart.Position).Magnitude
    local speed = 500
    local time = distance / speed
    
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = destination})
    tween:Play()
    tween.Completed:Wait()
end

local All_Monster = {
    Tanzaknite = function()
        local MobName = "Tanzaknite"
        moveTo(CFrame.new(5091.7236328125, 130.20970153808594, 5569.03369140625))
        wait(1)
        spawn(function()
            while BowAttack do
                for _, v in ipairs(workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - HumanoidRootPart.Position.Z <= 500 then
                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                local TweenInfoClose = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                                TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 30)}):Play()
                                wait(0.5)
                            end
                        end)
                        
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                game.Players.LocalPlayer.Character.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    Ronin = function()
        local MobName = "Ronin"
        moveTo(CFrame.new(514.5203857421875, 19.46990966796875, -383.6240234375))
        wait(1)
        spawn(function()
            while BowAttack do
                for _, v in ipairs(workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - HumanoidRootPart.Position.Z <= 500 then
                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                local TweenInfoClose = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                                TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 30)}):Play()
                                wait(0.5)
                            end
                        end)
                        
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                game.Players.LocalPlayer.Character.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    Pharaoh = function()
        local MobName = "Pharaoh"
        moveTo(CFrame.new(-5994.7265625, 1852.7735595703125, 4024.900146484375))
        wait(1)
        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 500 then
                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,30)}):Play()
                                wait(0.5)
                            end
                        end)
                        
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)

                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    MimicChest = function()
        local MobName = "MimicChest"
        moveTo(CFrame.new(694.2025756835938, 145.73423767089844, 532.7348022460938))
        wait(1)
        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5 then
                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,40)}):Play()
                                wait(0.5)
                            end
                        end)
                                
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)

                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    SeaKing = function()
        local MobName = "SeaKing"
        moveTo(CFrame.new(863.7012329101562, 98.45106506347656, 3254.254150390625))
        wait(1)
        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 300 then
                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,50)}):Play()
                                wait(0.5)
                            end
                        end)
                            
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)
    
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    AbyssKnight = function()
        local MobName = "AbyssKnight"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(4483.31982421875, -684.4680786132812, 6372.4453125)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(4483.171875, -681.2482299804688, 6372.15478515625))
        wait(1)
        moveTo(CFrame.new(4483.171875, -681.2482299804688, 6372.15478515625))

        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then
                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(4541.29052734375, -718.9581298828125, 6137.08740234375))
                        wait(4)
                        moveTo(CFrame.new(4483.171875, -681.2482299804688, 6372.15478515625))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    Hiraglacir = function()
        local MobName = "Hiraglacir"
        moveTo(CFrame.new(-42.54088592529297, 29.167022705078125, 8418.783203125))
        wait(1)
        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 300 then
                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,50)}):Play()
                                wait(0.5)
                            end
                        end)
                        
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)

                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    LightningGod = function()
        local MobName = "LightningGod"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(-6189.068359375, 1864.80615234375, 4068.8701171875)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(-6189.068359375, 1867.80615234375, 4068.8701171875))
        wait(1)
        moveTo(CFrame.new(-6189.068359375, 1867.80615234375, 4068.8701171875))

        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then

                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(-6519.38134765625, 1640.769775390625, 4021.671142578125))
                        wait(4)
                        moveTo(CFrame.new(-6189.068359375, 1867.80615234375, 4068.8701171875))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    ChainUser = function()
        local MobName = "Chain User"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(4726.03466796875, 335.33660888671875, 6837.7578125)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(4726.03466796875, 338.33660888671875, 6837.7578125))
        wait(1)
        moveTo(CFrame.new(4726.03466796875, 338.33660888671875, 6837.7578125))

        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then

                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(4869.6298828125, 33.57052230834961, 7219.00439453125))
                        wait(4)
                        moveTo(CFrame.new(4726.03466796875, 338.33660888671875, 6837.7578125))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    Law = function()
        local MobName = "Law"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(1088.350830078125, 332.9471435546875, -788.2487182617188)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(1088.350830078125, 335.9471435546875, -788.2487182617188))
        wait(1)
        moveTo(CFrame.new(1088.350830078125, 335.9471435546875, -788.2487182617188))

        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then

                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.1)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(834.67138671875, 19.46990966796875, -861.7884521484375))
                        wait(4)
                        moveTo(CFrame.new(1088.350830078125, 335.9471435546875, -788.2487182617188))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    RottedKnight = function()
        local MobName = "RottedKnight"
        moveTo(CFrame.new(-4468.2265625, 72.93830871582031, 1339.0042724609375))
        wait(1)
        moveTo(CFrame.new(-4468.2265625, 72.93830871582031, 1339.0042724609375))
        
        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 500 then

                        spawn(function()
                            while Mon and v.Humanoid.Health > 0 do
                                TweenService:Create(player.Character.HumanoidRootPart, TweenInfoClose, {CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,30)}):Play()
                                wait(0.5)
                            end
                        end)
                            
                        spawn(function()
                            while Mon and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.Position, 21)
                                wait(0.3)
                            end
                        end)
                            

                        repeat wait() until v.Humanoid.Health <= 0
                            moveTo(v.HumanoidRootPart.CFrame)
                            wait(4)
                            moveTo(CFrame.new(-4468.2265625, 72.93830871582031, 1339.0042724609375))
                            wait(2)
                        end
                    end
                wait(0.5)
            end
        end)
    end,
    
    MasterSwordsman = function()
        local MobName = "MasterSwordsman"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(-2191.16796875, 365.0719909667969, 4462.98828125)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(-2191.16796875, 368.0719909667969, 4462.98828125))
        wait(1)
        
        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then

                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(-1961.22314453125, 169.16986083984375, 4805.2177734375))
                        wait(4)
                        moveTo(CFrame.new(-2191.16796875, 368.0719909667969, 4462.98828125))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    Nightmare = function()
        local MobName = "Nightmare"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(515.275146484375, 1054.561767578125, 2525.274658203125)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(515.275146484375, 1057.561767578125, 2525.274658203125))
        wait(1)
        moveTo(CFrame.new(515.275146484375, 1057.561767578125, 2525.274658203125))

        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then

                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(256.6656799316406, 893.0773315429688, 2806.488525390625))
                        wait(4)
                        moveTo(CFrame.new(515.275146484375, 1057.561767578125, 2525.274658203125))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end,
    
    PirateHunter = function()
        local MobName = "Pirate Hunter"
        local air = Instance.new("Part", workspace)
        air.Size = Vector3.new(5, 0.5, 5)
        air.CFrame = CFrame.new(-6214.0126953125, 1898.8837890625, 4040.933349609375)
        air.Transparency = 0
        air.Anchored = true
        air.Name = "Airwalk"
        
        moveTo(CFrame.new(-6213.615234375, 1902.1033935546875, 4040.85302734375))
        wait(1)
        moveTo(CFrame.new(-6213.615234375, 1902.1033935546875, 4040.85302734375))

        spawn(function()
            while BowAttack do
                for i, v in ipairs(Workspace.Mobs:GetChildren()) do
                    if string.match(v.Name, MobName) and v:FindFirstChild("HumanoidRootPart") and v.HumanoidRootPart.Position.Z - char.HumanoidRootPart.Position.Z <= 5000 then

                        spawn(function()
                            while BowAttack and v.Humanoid and v.Humanoid.Health > 0 do
                                char.Bow.SwordScript.Shoot:FireServer(v.HumanoidRootPart.CFrame.Position, 21)
                                wait(0.3)
                            end
                        end)
                        
                        repeat wait() until v.Humanoid.Health <= 0
                        moveTo(v.HumanoidRootPart.CFrame)
                        wait(4)
                        moveTo(CFrame.new(-6527.1220703125, 1640.77734375, 4023.134033203125))
                        wait(4)
                        moveTo(CFrame.new(-6213.615234375, 1902.1033935546875, 4040.85302734375))
                        wait(2)
                    end
                end
                wait(0.5)
            end
        end)
    end
}

local M_Monster

Xlib:MakeDropdown({
    Name = "Select Monsters",
    Parent = Tab2,
    Options = {"Tanzaknite", "Ronin", "Pharaoh", 
                "MimicChest", "SeaKing", "AbyssKnight", 
                "Hiraglacir", "LightningGod", "ChainUser", 
                "Law", "RottedKnight", "MasterSwordsman",
                "Nightmare", "PirateHunter"},
    Callback = function(option)
        M_Monster = All_Monster[option]
    end
})

Xlib:MakeToggle({
    Name = "Auto Farm Monsters",
    Parent = Tab2,
    Default = false,
    Callback = function(value)
        BowAttack = value
        Mon = value
        if value and M_Monster then
            M_Monster()
        end
    end
})
