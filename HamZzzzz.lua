-- =============================================
-- SCRIPT ROBLOX HACK GUI "HAMZ" by Grok (buat lo bro)
-- Warna biru + merah keren + gradient
-- Minimize button + title "Hamz"
-- Fitur: Fly (WASD + Space/Ctrl, sesuai kamera = joystick style)
--        Noclip (tembus tembok)
--        Speed Hack (WalkSpeed bisa diatur)
--        Infinite Jump
-- Fly speed: ketik angka di textbox (contoh 200), max 500
-- Copy paste FULL ke executor lo (Fluxus, Krnl, Synapse, dll)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI utama (keren banget)
local gui = Instance.new("ScreenGui")
gui.Name = "HamzGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 380)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 50, 150)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

-- Gradient biru ke merah (keren abis)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 0, 0)
stroke.Thickness = 3
stroke.Parent = mainFrame

-- Title Bar (ada tulisan Hamz)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 30, 100)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 15)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.65, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Hamz"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 32
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Tombol Minimize
local minButton = Instance.new("TextButton")
minButton.Size = UDim2.new(0, 45, 0, 45)
minButton.Position = UDim2.new(1, -100, 0, 2)
minButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
minButton.Text = "−"
minButton.TextColor3 = Color3.new(1, 1, 1)
minButton.Font = Enum.Font.GothamBold
minButton.TextSize = 35
minButton.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 10)
minCorner.Parent = minButton

-- Tombol Close
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 45, 0, 45)
closeButton.Position = UDim2.new(1, -50, 0, 2)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 35
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -65)
contentFrame.Position = UDim2.new(0, 10, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = contentFrame

-- Draggable (tarik title bar)
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
	end
end)
titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ================== VARIABEL FITUR ==================
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
	hum = newChar:WaitForChild("Humanoid")
end)

local flyEnabled = false
local noclipEnabled = false
local speedEnabled = false
local infJumpEnabled = false
local flySpeed = 200
local targetWalkSpeed = 100

local flyConnection = nil
local noclipConnection = nil
local infJumpConnection = nil
local bv, bg = nil, nil

local pressed = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}

-- ================== INPUT KEYS (Joystick Style) ==================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.W then pressed.W = true
	elseif input.KeyCode == Enum.KeyCode.A then pressed.A = true
	elseif input.KeyCode == Enum.KeyCode.S then pressed.S = true
	elseif input.KeyCode == Enum.KeyCode.D then pressed.D = true
	elseif input.KeyCode == Enum.KeyCode.Space then pressed.Space = true
	elseif input.KeyCode == Enum.KeyCode.LeftControl then pressed.LeftControl = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then pressed.W = false
	elseif input.KeyCode == Enum.KeyCode.A then pressed.A = false
	elseif input.KeyCode == Enum.KeyCode.S then pressed.S = false
	elseif input.KeyCode == Enum.KeyCode.D then pressed.D = false
	elseif input.KeyCode == Enum.KeyCode.Space then pressed.Space = false
	elseif input.KeyCode == Enum.KeyCode.LeftControl then pressed.LeftControl = false
	end
end)

-- ================== FUNGSI FLY ==================
local function startFly()
	if flyConnection then return end
	if not hrp then return end

	bv = Instance.new("BodyVelocity")
	bv.Name = "HamzFlyBV"
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.Parent = hrp

	bg = Instance.new("BodyGyro")
	bg.Name = "HamzFlyBG"
	bg.P = 90000
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flyEnabled or not hrp or not bv then return end

		local camCF = camera.CFrame
		local forward = camCF.LookVector
		local strafe = camCF.RightVector

		local forwardInput = (pressed.W and 1 or 0) - (pressed.S and 1 or 0)
		local strafeInput = (pressed.D and 1 or 0) - (pressed.A and 1 or 0)
		local verticalInput = (pressed.Space and 1 or 0) - (pressed.LeftControl and 1 or 0)

		local moveVector = forward * forwardInput + strafe * strafeInput + Vector3.new(0, verticalInput, 0)

		if moveVector.Magnitude > 0 then
			moveVector = moveVector.Unit
		end

		bv.Velocity = moveVector * flySpeed
		bg.CFrame = camCF
	end)
end

local function stopFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
end

-- ================== FUNGSI NOCLIP ==================
local function toggleNoclip(state)
	noclipEnabled = state
	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
	end
end

-- ================== FUNGSI INFINITE JUMP ==================
local function toggleInfJump(state)
	infJumpEnabled = state
	if infJumpEnabled then
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		if infJumpConnection then
			infJumpConnection:Disconnect()
			infJumpConnection = nil
		end
	end
end

-- ================== FUNGSI SPEED HACK ==================
local function applyWalkSpeed()
	if hum then
		if speedEnabled then
			hum.WalkSpeed = targetWalkSpeed
		else
			hum.WalkSpeed = 16
		end
	end
end

-- ================== BUAT TOGGLE BUTTON ==================
local function createToggle(name, defaultState)
	local toggleFrame = Instance.new("Frame")
	toggleFrame.Size = UDim2.new(1, 0, 0, 55)
	toggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	toggleFrame.Parent = contentFrame

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 10)
	tCorner.Parent = toggleFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 20
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = toggleFrame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0.35, 0, 0.7, 0)
	toggleBtn.Position = UDim2.new(0.62, 0, 0.15, 0)
	toggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	toggleBtn.Text = defaultState and "ON" or "OFF"
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 22
	toggleBtn.Parent = toggleFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = toggleBtn

	return toggleBtn, toggleFrame
end

-- ================== BUAT TEXTBOX ==================
local function createTextBox(labelText, defaultValue, parentFrame)
	local boxFrame = Instance.new("Frame")
	boxFrame.Size = UDim2.new(1, 0, 0, 50)
	boxFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	boxFrame.Parent = parentFrame

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 10)
	bCorner.Parent = boxFrame

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 18
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = boxFrame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.45, 0, 0.8, 0)
	box.Position = UDim2.new(0.52, 0, 0.1, 0)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	box.Text = defaultValue
	box.PlaceholderText = defaultValue
	box.TextColor3 = Color3.new(1, 1, 1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 20
	box.ClearTextOnFocus = false
	box.Parent = boxFrame

	local boxCorner = Instance.new("UICorner")
	boxCorner.CornerRadius = UDim.new(0, 8)
	boxCorner.Parent = box

	return box
end

-- ================== BUAT SEMUA FITUR ==================
-- Fly
local flyToggleBtn, _ = createToggle("Fly (Joystick Style)", false)
local flyBox = createTextBox("Fly Speed (1-500):", "200", contentFrame)
flyBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(flyBox.Text)
		if num then
			flySpeed = math.clamp(num, 1, 500)
			flyBox.Text = tostring(flySpeed)
		end
	end
end)

-- Noclip
local noclipToggleBtn, _ = createToggle("Noclip (Tembus Tembok)", false)

-- Speed Hack
local speedToggleBtn, _ = createToggle("Speed Hack", false)
local speedBox = createTextBox("WalkSpeed Value:", "100", contentFrame)
speedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(speedBox.Text)
		if num then
			targetWalkSpeed = math.clamp(num, 16, 500)
			speedBox.Text = tostring(targetWalkSpeed)
			if speedEnabled and hum then
				hum.WalkSpeed = targetWalkSpeed
			end
		end
	end
end)

-- Infinite Jump
local infJumpToggleBtn, _ = createToggle("Infinite Jump", false)

-- ================== TOGGLE LOGIC ==================
flyToggleBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled then
		flyToggleBtn.Text = "ON"
		flyToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		startFly()
	else
		flyToggleBtn.Text = "OFF"
		flyToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		stopFly()
	end
end)

noclipToggleBtn.MouseButton1Click:Connect(function()
	local newState = not noclipEnabled
	toggleNoclip(newState)
	noclipToggleBtn.Text = newState and "ON" or "OFF"
	noclipToggleBtn.BackgroundColor3 = newState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
end)

speedToggleBtn.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	speedToggleBtn.Text = speedEnabled and "ON" or "OFF"
	speedToggleBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	applyWalkSpeed()
end)

infJumpToggleBtn.MouseButton1Click:Connect(function()
	infJumpEnabled = not infJumpEnabled
	infJumpToggleBtn.Text = infJumpEnabled and "ON" or "OFF"
	infJumpToggleBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
	toggleInfJump(infJumpEnabled)
end)

-- Minimize logic
local contentVisible = true
minButton.MouseButton1Click:Connect(function()
	contentVisible = not contentVisible
	contentFrame.Visible = contentVisible
	minButton.Text = contentVisible and "−" or "＋"
end)

-- Close GUI
closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Auto apply speed kalau character respawn
player.CharacterAdded:Connect(applyWalkSpeed)

print("✅ Hamz GUI loaded bro! Enjoy hacknya, jangan kena ban ya 😂")
