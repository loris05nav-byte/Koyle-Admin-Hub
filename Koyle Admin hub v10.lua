-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: Exactly matches the 'Secret' value in your Key System's Config!
    SecretKey = "0652269804Xd",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Koyle Admin Hub"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

--[[ 
    ULTIMATE Koyle ADMIN PANEL v8.0 (SPECTATE & BOOMBOX INTEGRATED EDITION)
    - Draggable Bubble System: Move button "-" added + Hotkey G + Animation (Retained)
    - TP System: Independent Window (Retained)
    - Spectate System: Independent Window (Retained)
    - Boombox RELICSxyz v4.1 Final Compact System: Responsive Independent Window (New)
    - Core Features: Fly, NoClip, Dash, ESP, GodMode, Aimbot, XRay, Zoom, Bright (Retained)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()
local playerGui = player:WaitForChild("PlayerGui")

-- --- STATES & VARIABLES ---
local states = {
    noclip = false, godmode = false, dash = false, fly = false,
    esp = false, entitiesESP = false, infjump = false, infzoom = false, xray = false, aimbot = false
}

local connections = {}
local xrayOriginals = {}
local xrayConnection = nil
local xrayAccumulator = 0
local XRAY_RADIUS = 220       -- Only handles radius around player
local XRAY_MAX_PARTS = 450    -- Strict limit to avoid overloaded maps
local XRAY_UPDATE_INTERVAL = 0.45
local flyBV, flyBG = nil, nil

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- --- THEME AND SIZES (RESPONSIVE) ---
local GUI_THEME = {
    Background = Color3.fromRGB(15, 15, 22),
    Header = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(0, 200, 255),
    ButtonOff = Color3.fromRGB(35, 35, 45),
    ButtonOn = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Transparency = 0.1
}

local sizes = isMobile and {w = 240, h = 340, head = 40, btn = 35, txt = 11} or {w = 380, h = 550, head = 60, btn = 45, txt = 14}

-- --- BOOMBOX CORE CONFIGURATION ---
local sound = Instance.new("Sound")
sound.Name = "RelicsBoombox"
sound.Volume = 0.7
sound.Parent = Workspace

local favorites = {}
local SAVE_KEY = "relics_v41_favs"

local function saveFavs()
    local data = HttpService:JSONEncode(favorites)
    if writefile then pcall(writefile, SAVE_KEY..".json", data) end
    player:SetAttribute(SAVE_KEY, data)
end

local function loadFavs()
    local data = nil
    if readfile and isfile and isfile(SAVE_KEY..".json") then
        data = readfile(SAVE_KEY..".json")
    else
        data = player:GetAttribute(SAVE_KEY)
    end
    if data then
        local ok, tbl = pcall(HttpService.JSONDecode, HttpService, data)
        if ok and type(tbl) == "table" then favorites = tbl end
    end
end
loadFavs()

-- --- DRAGGING FUNCTIONS ---
local activeDrag = nil
local DRAG_THRESHOLD = 4

local function makeDraggable(frame, handle)
    local dragState = { dragged = false }
    handle.Active = true

    handle.InputBegan:Connect(function(input)
        local inputType = input.UserInputType
        if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then
            return
        end

        dragState.dragged = false
        activeDrag = {
            frame = frame,
            handle = handle,
            input = input,
            inputType = inputType,
            startPointer = input.Position,
            startAbsolute = frame.AbsolutePosition,
            startSize = frame.AbsoluteSize,
            state = dragState,
        }
    end)

    return dragState
end

UserInputService.InputChanged:Connect(function(input)
    local drag = activeDrag
    if not drag or not drag.frame or not drag.frame.Parent then return end

    local isMouseMove = drag.inputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseMovement
    local isTouchMove = drag.inputType == Enum.UserInputType.Touch
        and input.UserInputType == Enum.UserInputType.Touch
        and input == drag.input
    if not isMouseMove and not isTouchMove then return end

    local delta = input.Position - drag.startPointer
    if delta.Magnitude < DRAG_THRESHOLD and not drag.state.dragged then return end
    drag.state.dragged = true

    local viewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
    local frameSize = drag.frame.AbsoluteSize
    local left = math.clamp(drag.startAbsolute.X + delta.X, 0, math.max(0, viewport.X - frameSize.X))
    local top = math.clamp(drag.startAbsolute.Y + delta.Y, 0, math.max(0, viewport.Y - frameSize.Y))

    local anchor = drag.frame.AnchorPoint
    drag.frame.Position = UDim2.fromOffset(
        left + frameSize.X * anchor.X,
        top + frameSize.Y * anchor.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    local drag = activeDrag
    if not drag then return end
    if input == drag.input or (drag.inputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1) then
        activeDrag = nil
    end
end)

-- --- GUI BASE ---
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "UltimateAdmin_v80"
screenGui.ResetOnSpawn = false

-- Floating Bubble (Minimized)
local bubble = Instance.new("TextButton", screenGui)
bubble.Name = "Bubble"
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0, 20, 0.5, -25)
bubble.BackgroundColor3 = GUI_THEME.Background
bubble.Text = "⚡"
bubble.TextColor3 = GUI_THEME.Accent
bubble.Font = Enum.Font.GothamBold
bubble.TextSize = 24
bubble.Visible = false
bubble.AutoButtonColor = false
Instance.new("UICorner", bubble).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", bubble).Color = GUI_THEME.Accent
Instance.new("UIStroke", bubble).Thickness = 2

-- Main Frame
local main = Instance.new("Frame", screenGui)
main.Name = "MainFrame"
main.Size = UDim2.new(0, sizes.w, 0, sizes.h)
main.Position = UDim2.new(0.5, -sizes.w/2, 0.5, -sizes.h/2)
main.BackgroundColor3 = GUI_THEME.Background
main.BackgroundTransparency = GUI_THEME.Transparency
main.BorderSizePixel = 0
main.Visible = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)
local mainGradient = Instance.new("UIGradient", main)
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 24, 34)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 13, 19)),
})
mainGradient.Rotation = 90

-- Glow Border
local stroke = Instance.new("UIStroke", main)
stroke.Color = GUI_THEME.Accent
stroke.Thickness = 2
stroke.Transparency = 0.3

-- Header & Title
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, sizes.head)
header.BackgroundColor3 = GUI_THEME.Header
header.BackgroundTransparency = GUI_THEME.Transparency
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 15)
local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 43, 61)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 22, 32)),
})
headerGradient.Rotation = 0

local headerBottom = Instance.new("Frame", header)
headerBottom.Size = UDim2.new(1, 0, 0, 10)
headerBottom.Position = UDim2.new(0, 0, 1, -10)
headerBottom.BackgroundColor3 = GUI_THEME.Header
headerBottom.BorderSizePixel = 0

local icon = Instance.new("TextLabel", header)
icon.Text = "⚡"
icon.Size = UDim2.new(0, 40, 1, 0); icon.Position = UDim2.new(0, 10, 0, 0)
icon.TextColor3 = GUI_THEME.Accent; icon.BackgroundTransparency = 1
icon.Font = Enum.Font.GothamBold; icon.TextSize = sizes.txt + 6

local title = Instance.new("TextLabel", header)
title.Text = "ULTIMATE ADMIN v8.0"
title.Size = UDim2.new(1, -90, 1, 0); title.Position = UDim2.new(0, 50, 0, 0)
title.TextColor3 = GUI_THEME.Text; title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold; title.TextSize = sizes.txt + 2
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize Button "-"
local minBtn = Instance.new("TextButton", header)
minBtn.Size = UDim2.new(0, 40, 1, 0)
minBtn.Position = UDim2.new(1, -80, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Text = "-"
minBtn.TextColor3 = GUI_THEME.Text
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = sizes.txt + 12

-- Close Button (with confirmation)
local closeBtn = Instance.new("TextButton", header)
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 95, 105)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = sizes.txt + 10
closeBtn.AutoButtonColor = false
closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(255, 145, 150) end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(255, 95, 105) end)

-- Confirmation Modal
local closeConfirm = Instance.new("Frame", screenGui)
closeConfirm.Name = "CloseConfirmation"
closeConfirm.AnchorPoint = Vector2.new(0.5, 0.5)
closeConfirm.Position = UDim2.new(0.5, 0, 0.5, 0)
closeConfirm.Size = UDim2.new(0, isMobile and 280 or 360, 0, 175)
closeConfirm.BackgroundColor3 = Color3.fromRGB(20, 22, 31)
closeConfirm.BorderSizePixel = 0
closeConfirm.Visible = false
closeConfirm.ZIndex = 50
Instance.new("UICorner", closeConfirm).CornerRadius = UDim.new(0, 12)
local confirmStroke = Instance.new("UIStroke", closeConfirm)
confirmStroke.Color = Color3.fromRGB(255, 95, 105)
confirmStroke.Thickness = 1.5

local confirmTitle = Instance.new("TextLabel", closeConfirm)
confirmTitle.BackgroundTransparency = 1
confirmTitle.Position = UDim2.new(0, 14, 0, 12)
confirmTitle.Size = UDim2.new(1, -28, 0, 30)
confirmTitle.Font = Enum.Font.GothamBold
confirmTitle.Text = "Close Panel?"
confirmTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
confirmTitle.TextSize = isMobile and 16 or 18
confirmTitle.ZIndex = 51

local confirmText = Instance.new("TextLabel", closeConfirm)
confirmText.BackgroundTransparency = 1
confirmText.Position = UDim2.new(0, 16, 0, 45)
confirmText.Size = UDim2.new(1, -32, 0, 48)
confirmText.Font = Enum.Font.Gotham
confirmText.Text = "The script will stop and its effects will be cancelled. This action is permanent for this session."
confirmText.TextWrapped = true
confirmText.TextColor3 = Color3.fromRGB(205, 210, 220)
confirmText.TextSize = isMobile and 11 or 13
confirmText.ZIndex = 51

local cancelCloseBtn = Instance.new("TextButton", closeConfirm)
cancelCloseBtn.Name = "CancelClose"
cancelCloseBtn.Size = UDim2.new(0.43, 0, 0, 36)
cancelCloseBtn.Position = UDim2.new(0.05, 0, 1, -48)
cancelCloseBtn.BackgroundColor3 = Color3.fromRGB(55, 59, 72)
cancelCloseBtn.Text = "Cancel"
cancelCloseBtn.TextColor3 = Color3.new(1, 1, 1)
cancelCloseBtn.Font = Enum.Font.GothamSemibold
cancelCloseBtn.TextSize = isMobile and 12 or 14
cancelCloseBtn.ZIndex = 51
Instance.new("UICorner", cancelCloseBtn).CornerRadius = UDim.new(0, 7)

local confirmCloseBtn = Instance.new("TextButton", closeConfirm)
confirmCloseBtn.Name = "ConfirmClose"
confirmCloseBtn.Size = UDim2.new(0.43, 0, 0, 36)
confirmCloseBtn.Position = UDim2.new(0.52, 0, 1, -48)
confirmCloseBtn.BackgroundColor3 = Color3.fromRGB(170, 45, 55)
confirmCloseBtn.Text = "Close"
confirmCloseBtn.TextColor3 = Color3.new(1, 1, 1)
confirmCloseBtn.Font = Enum.Font.GothamBold
confirmCloseBtn.TextSize = isMobile and 12 or 14
confirmCloseBtn.ZIndex = 51
Instance.new("UICorner", confirmCloseBtn).CornerRadius = UDim.new(0, 7)

closeBtn.MouseButton1Click:Connect(function()
    closeConfirm.Visible = true
end)
cancelCloseBtn.MouseButton1Click:Connect(function()
    closeConfirm.Visible = false
end)

-- Scroll Container
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -sizes.head - 16)
scroll.Position = UDim2.new(0, 8, 0, sizes.head + 8)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarImageColor3 = GUI_THEME.Accent
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- --- TOGGLE LOGIC (BUBBLE / MAIN) ---
local isOpen = true
local isAnimating = false

local function toggleUI()
    if isAnimating then return end
    isAnimating = true
    isOpen = not isOpen
    
    if isOpen then
        bubble.Visible = false
        main.Visible = true
        main.Size = UDim2.new(0, sizes.w * 0.8, 0, sizes.h * 0.8)
        local tween = TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, sizes.w, 0, sizes.h)})
        tween:Play()
        tween.Completed:Connect(function() isAnimating = false end)
    else
        local tween = TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, sizes.w * 0.8, 0, sizes.h * 0.8)})
        tween:Play()
        tween.Completed:Connect(function()
            main.Visible = false
            bubble.Visible = true
            bubble.Position = UDim2.new(0, main.AbsolutePosition.X + (sizes.w/2) - 25, 0, main.AbsolutePosition.Y + (sizes.head/2) - 10)
            isAnimating = false
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.G then
        toggleUI()
    end
end)

makeDraggable(main, header)
local bubbleDragState = makeDraggable(bubble, bubble)

bubble.MouseButton1Click:Connect(function()
    if not bubbleDragState.dragged then toggleUI() end
end)
minBtn.MouseButton1Click:Connect(function() toggleUI() end)

-- --- UTILS ---
local function getChar() return player.Character end
local function getHum() return getChar() and getChar():FindFirstChild("Humanoid") end
local function getRoot() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end

-- --- CORE FUNCTIONS ---

-- FLY MODE
local function handleFly()
    if not states.fly or not getRoot() then return end
    local speed = 50; local dir = Vector3.new(0,0,0); local cf = camera.CFrame
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
    if isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dir = cf.LookVector end
    flyBG.cframe = cf; flyBV.velocity = dir * speed
end

-- NOCLIP
local function toggleNoClip(active)
    states.noclip = active
    if active then
        connections["NoClip"] = RunService.Stepped:Connect(function()
            if states.noclip and getChar() then
                for _, v in pairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
            end
        end)
    else
        if connections["NoClip"] then connections["NoClip"]:Disconnect() end
        if getChar() then
            for _, v in pairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end
        end
    end
end

-- AIMBOT / AUTO-LOCK
local function handleAimbot()
    if not states.aimbot then return end
    local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or (isMobile and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1))
    if isAiming then
        local target = nil; local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local d = (getRoot().Position - p.Character.Head.Position).Magnitude
                if d < dist and d < 500 then dist = d; target = p.Character.Head end
            end
        end
        if target then camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position) end
    end
end

-- --- BUTTON CREATOR ---
local function addToggle(txt, cb)
    local btnFrame = Instance.new("Frame", scroll)
    btnFrame.Size = UDim2.new(1, -10, 0, sizes.btn)
    btnFrame.BackgroundTransparency = 1

    local b = Instance.new("TextButton", btnFrame)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = GUI_THEME.ButtonOff
    b.Text = "  " .. txt
    b.TextColor3 = GUI_THEME.Text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = sizes.txt
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local buttonStroke = Instance.new("UIStroke", b)
    buttonStroke.Color = GUI_THEME.Accent
    buttonStroke.Thickness = 1
    buttonStroke.Transparency = 0.88

    local statusIndicator = Instance.new("Frame", b)
    statusIndicator.Size = UDim2.new(0, 4, 0.6, 0)
    statusIndicator.Position = UDim2.new(1, -12, 0.2, 0)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", statusIndicator).CornerRadius = UDim.new(1, 0)

    local active = false
    local hovered = false

    local function refreshToggleStyle()
        local targetColor
        if active then
            targetColor = Color3.fromRGB(25, 60, 80)
        elseif hovered then
            targetColor = Color3.fromRGB(45, 50, 64)
        else
            targetColor = GUI_THEME.ButtonOff
        end
        TweenService:Create(b, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        }):Play()
        TweenService:Create(buttonStroke, TweenInfo.new(0.14), {
            Transparency = (active or hovered) and 0.45 or 0.88
        }):Play()
        TweenService:Create(statusIndicator, TweenInfo.new(0.14), {
            BackgroundColor3 = active and GUI_THEME.Accent or (hovered and Color3.fromRGB(100, 115, 135) or Color3.fromRGB(60, 60, 70))
        }):Play()
    end

    b.MouseEnter:Connect(function()
        hovered = true
        refreshToggleStyle()
    end)
    b.MouseLeave:Connect(function()
        hovered = false
        refreshToggleStyle()
    end)
    b.MouseButton1Click:Connect(function()
        active = not active
        refreshToggleStyle()
        cb(active)
    end)
end

-- --- FEATURES LIST ---

addToggle("1. 👻 NoClip (Wall)", toggleNoClip)

addToggle("2. 🦸 Fly Mode (Fix)", function(a)
    states.fly = a
    if a and getRoot() then
        flyBG = Instance.new("BodyGyro", getRoot()); flyBG.maxTorque = Vector3.new(9e9,9e9,9e9)
        flyBV = Instance.new("BodyVelocity", getRoot()); flyBV.maxForce = Vector3.new(9e9,9e9,9e9)
        connections["Fly"] = RunService.RenderStepped:Connect(handleFly)
    else
        if connections["Fly"] then connections["Fly"]:Disconnect() end
        if flyBG then flyBG:Destroy() end; if flyBV then flyBV:Destroy() end
    end
end)

addToggle("3. 🎯 Admin Auto-Lock", function(a)
    states.aimbot = a
    if a then connections["Aimbot"] = RunService.RenderStepped:Connect(handleAimbot)
    else if connections["Aimbot"] then connections["Aimbot"]:Disconnect() end end
end)

local playerESPObjects = {}
local function removePlayerESP()
    for head, mark in pairs(playerESPObjects) do
        if mark and mark.Parent then
            pcall(function() mark:Destroy() end)
        end
    end
    playerESPObjects = {}
