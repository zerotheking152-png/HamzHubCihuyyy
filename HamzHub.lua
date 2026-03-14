local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local CustomTheme = {
    Name = "BiruMerah",
    Accent = Color3.fromRGB(0, 170, 255),
    AcrylicMain = Color3.fromRGB(10, 25, 45),
    AcrylicBorder = Color3.fromRGB(0, 120, 255),
    TitleBarLine = Color3.fromRGB(255, 40, 40),
}

local Window = Fluent:CreateWindow({
    Title = "HamzHub",
    SubTitle = "Anjirr keren bet gwee",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = CustomTheme,
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main" }),
    Player = Window:AddTab({ Title = "Player" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- SERVICES
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ==================== TAB MAIN (fitur lama TETEP 100%) ====================
do
    Tabs.Main:AddSection("Fitur")

    Tabs.Main:AddButton({
        Title = "Infinite Jump",
        Description = "Loncat tanpa batas (versi button)",
        Callback = function()
            game:GetService("UserInputService").JumpRequest:Connect(function()
                local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState("Jumping") end
            end)
        end
    })

    Tabs.Main:AddToggle("AutoFarm", {
        Title = "Auto Farm",
        Default = false,
        Callback = function(v)
            getgenv().AutoFarm = v
            while getgenv().AutoFarm do
                task.wait(0.5)
                -- autofarm code here
            end
        end
    })

    Tabs.Main:AddDropdown("GameSpeed", {
        Title = "Game Speed",
        Values = {"0.5x", "1x", "2x", "5x"},
        Default = 2,
        Callback = function(v)
            local ws = game:GetService("Workspace")
            if v == "0.5x" then ws.Gravity = 50
            elseif v == "1x" then ws.Gravity = 196.2
            elseif v == "2x" then ws.Gravity = 400
            elseif v == "5x" then ws.Gravity = 1000 end
        end
    })
end

-- ==================== TAB PLAYER (FLY SUDAH DI-FIX KHUSUS HP) ====================
do
    Tabs.Player:AddSection("Player Features")

    -- Infinite Jump (ON/OFF)
    local jumpConnection = nil
    Tabs.Player:AddToggle("InfiniteJump", {
        Title = "Infinite Jump",
        Default = false,
        Callback = function(v)
            if v then
                if jumpConnection then jumpConnection:Disconnect() end
                jumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
            else
                if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
            end
        end
    })

    -- Super Speed
    local defaultWalkSpeed = 16
    Tabs.Player:AddToggle("SuperSpeed", {
        Title = "Super Speed (100)",
        Default = false,
        Callback = function(v)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if v then
                    defaultWalkSpeed = hum.WalkSpeed
                    hum.WalkSpeed = 100
                else
                    hum.WalkSpeed = defaultWalkSpeed
                end
            end
        end
    })

    -- High Jump
    local defaultJumpPower = 50
    Tabs.Player:AddToggle("HighJump", {
        Title = "High Jump (200)",
        Default = false,
        Callback = function(v)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if v then
                    defaultJumpPower = hum.JumpPower
                    hum.JumpPower = 200
                else
                    hum.JumpPower = defaultJumpPower
                end
            end
        end
    })

    -- ====================== FLY BARU (FIXED KHUSUS HP + PC) ======================
    local flySpeed = 50
    local isFlying = false
    local flyBV, flyBG, flyConn = nil, nil, nil

    Tabs.Player:AddToggle("Fly", {
        Title = "Fly (Joystick HP / WASD PC)",
        Default = false,
        Callback = function(state)
            isFlying = state
            local char = game.Players.LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end

            if state then
                flyBV = Instance.new("BodyVelocity")
                flyBV.MaxForce = Vector3.new(400000, 400000, 400000)
                flyBV.Velocity = Vector3.new(0,0,0)
                flyBV.Parent = root

                flyBG = Instance.new("BodyGyro")
                flyBG.MaxTorque = Vector3.new(400000, 400000, 400000)
                flyBG.P = 9000
                flyBG.Parent = root

                flyConn = RunService.Heartbeat:Connect(function()
                    if not isFlying or not hum or not root then return end

                    local cam = workspace.CurrentCamera
                    local moveDir = hum.MoveDirection  -- ← INI YANG BIKIN JOYSTICK HP WORK!

                    local dir = Vector3.new(0, 0, 0)
                    dir = dir + cam.CFrame.LookVector * moveDir.Z
                    dir = dir + cam.CFrame.RightVector * moveDir.X

                    -- Vertical hanya di PC (Space naik, Ctrl turun)
                    if UserInputService.KeyboardEnabled then
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            dir = dir + Vector3.new(0, 1, 0)
                        end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                            dir = dir - Vector3.new(0, 1, 0)
                        end
                    end

                    if dir.Magnitude > 0 then
                        flyBV.Velocity = dir.Unit * flySpeed
                    else
                        flyBV.Velocity = Vector3.new(0, 0, 0)
                    end

                    flyBG.CFrame = cam.CFrame
                    hum.PlatformStand = true
                end)
            else
                if flyConn then flyConn:Disconnect() flyConn = nil end
                if flyBV then flyBV:Destroy() flyBV = nil end
                if flyBG then flyBG:Destroy() flyBG = nil end
                if hum then hum.PlatformStand = false end
            end
        end
    })

    Tabs.Player:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Rounding = 0,
        Callback = function(v)
            flySpeed = v
        end
    })

    -- ====================== TEMBUS TEMBOK (Noclip) ======================
    local noclipConn = nil
    Tabs.Player:AddToggle("Noclip", {
        Title = "Tembus Tembok (Noclip)",
        Default = false,
        Callback = function(state)
            if state then
                if noclipConn then noclipConn:Disconnect() end
                noclipConn = RunService.Stepped:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })
end

-- ==================== TOGGLE GUI HMZ (tetep sama) ====================
local sg = Instance.new("ScreenGui")
sg.Name = "FreyaaToggle"
sg.ResetOnSpawn = false
sg.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 90, 0, 50)
frame.Position = UDim2.new(0.05, 0, 0.5, -25)
frame.BackgroundTransparency = 0.4
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = sg

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Thickness = 1.5
uiStroke.Transparency = 0.5
uiStroke.Parent = frame

local h = Instance.new("TextLabel")
h.Size = UDim2.new(0, 30, 1, 0)
h.Position = UDim2.new(0, 0, 0, 0)
h.BackgroundTransparency = 1
h.Text = "H"
h.TextColor3 = Color3.fromRGB(255, 0, 0)
h.Font = Enum.Font.SourceSansBold
h.TextSize = 32
h.TextXAlignment = Enum.TextXAlignment.Center
h.Parent = frame

local m = Instance.new("TextLabel")
m.Size = UDim2.new(0, 30, 1, 0)
m.Position = UDim2.new(0, 30, 0, 0)
m.BackgroundTransparency = 1
m.Text = "M"
m.TextColor3 = Color3.fromRGB(0, 100, 255)
m.Font = Enum.Font.SourceSansBold
m.TextSize = 32
m.TextXAlignment = Enum.TextXAlignment.Center
m.Parent = frame

local z = Instance.new("TextLabel")
z.Size = UDim2.new(0, 30, 1, 0)
z.Position = UDim2.new(0, 60, 0, 0)
z.BackgroundTransparency = 1
z.Text = "Z"
z.TextColor3 = Color3.fromRGB(255, 215, 0)
z.Font = Enum.Font.SourceSansBold
z.TextSize = 32
z.TextXAlignment = Enum.TextXAlignment.Center
z.Parent = frame

frame.MouseEnter:Connect(function() frame.BackgroundTransparency = 0.2 end)
frame.MouseLeave:Connect(function() frame.BackgroundTransparency = 0.4 end)

local visible = true
local function toggleGUI()
    visible = not visible
    Window:Minimize()
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleGUI()
    end
end)

-- Draggable
local dragging, dragInput, dragStart, startPos

local function updateInput(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateInput(input) end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then toggleGUI() end
end).
