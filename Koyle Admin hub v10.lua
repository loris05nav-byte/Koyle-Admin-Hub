-- ⚠️ IMPORTANT: Anti-Bypass Protection ⚠️

local ProtectionConfig = {
    -- Clé secrète strictement identique à celle du système de clé ("0652269804Xd")
    SecretKey = "0652269804Xd",

    HubName = "Koyle Admin Hub",

    -- Utilisés par l'option "Reset Key" (doivent correspondre au système de clé)
    KeyFileName = "Mykey.txt",
    KeySystemURL = "https://raw.githubusercontent.com/loris05nav-byte/Koyle-Admin-Hub/refs/heads/main/Koyle%20Key%20system.lua"
}

-- Anti-Bypass Logic: Vérifie si le système de clé a validé la variable globale
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return
end

-------------------------------------------------------------------------------
-- 👇 TON CODE DE PANNEAU ADMIN (REPRIS À 100 % DE TON FICHIER ORIGINAL) 👇
-------------------------------------------------------------------------------

print(ProtectionConfig.HubName .. " Loaded Successfully!")

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
    esp = false, entitiesESP = false, movingESP = false, infjump = false, infzoom = false, xray = false, aimbot = false
}

local connections = {}
local xrayOriginals = {}
local xrayConnection = nil
local xrayAccumulator = 0
local XRAY_RADIUS = 220
local XRAY_MAX_PARTS = 450
local XRAY_UPDATE_INTERVAL = 0.45
local flyBV, flyBG = nil, nil

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- --- THEME AND SIZES (BRICK STYLE) ---
local BRICK = {
    Blue       = Color3.fromRGB(36, 132, 226),
    BlueLight  = Color3.fromRGB(64, 163, 245),
    BlueHover  = Color3.fromRGB(98, 186, 255),
    BlueDark   = Color3.fromRGB(20, 82, 168),
    BlueDeep   = Color3.fromRGB(16, 62, 138),
    Stud       = Color3.fromRGB(96, 178, 250),
    Orange     = Color3.fromRGB(255, 138, 22),
    OrangeDark = Color3.fromRGB(196, 86, 0),
    Green      = Color3.fromRGB(86, 204, 42),
    GreenDark  = Color3.fromRGB(36, 132, 18),
    Red        = Color3.fromRGB(238, 64, 64),
    RedDark    = Color3.fromRGB(160, 28, 36),
    Yellow     = Color3.fromRGB(255, 204, 34),
    YellowDark = Color3.fromRGB(196, 138, 0),
    Purple     = Color3.fromRGB(136, 92, 232),
    PurpleDark = Color3.fromRGB(84, 46, 170),
    Pink       = Color3.fromRGB(244, 72, 132),
    PinkDark   = Color3.fromRGB(170, 30, 80),
    Text       = Color3.fromRGB(255, 255, 255),
    TextSoft   = Color3.fromRGB(205, 230, 255),
    TextStroke = Color3.fromRGB(12, 52, 118),
}

local GUI_THEME = {
    Background = BRICK.Blue,
    Header = BRICK.Orange,
    Accent = BRICK.Yellow,
    ButtonOff = BRICK.BlueLight,
    ButtonOn = BRICK.Green,
    Text = BRICK.Text,
    Transparency = 0
}

local sizes = isMobile and {w = 240, h = 340, head = 44, btn = 36, txt = 12} or {w = 380, h = 550, head = 62, btn = 46, txt = 16}

local BRICK_FONT = Enum.Font.FredokaOne
local BRICK_SHADE = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(198, 204, 216))

-- Texte blanc arrondi avec contour bleu foncé (style "jeu")
local function brickText(label, size, color)
    label.Font = BRICK_FONT
    label.TextColor3 = color or BRICK.Text
    if size then label.TextSize = size end
    local s = label:FindFirstChild("BrickTextStroke") or Instance.new("UIStroke")
    s.Name = "BrickTextStroke"
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    s.Color = BRICK.TextStroke
    s.Thickness = isMobile and 1 or 1.5
    s.Parent = label
    return s
end

-- Bloc "brique" : couleur pleine, bord épais foncé, léger dégradé pour l'effet 3D
local function brickify(gui, color, edgeColor, radius, edgeThickness)
    gui.BackgroundColor3 = color
    gui.BackgroundTransparency = 0
    gui.BorderSizePixel = 0
    local corner = gui:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", gui)
    corner.CornerRadius = UDim.new(0, radius or 8)
    local edge = Instance.new("UIStroke")
    edge.Name = "BrickEdge"
    edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    edge.Color = edgeColor or BRICK.BlueDark
    edge.Thickness = edgeThickness or 3
    edge.Parent = gui
    local shade = Instance.new("UIGradient")
    shade.Name = "BrickShade"
    shade.Color = BRICK_SHADE
    shade.Rotation = 90
    shade.Parent = gui
    return edge
end

-- Picots façon briques de construction, dessinés derrière le contenu d'un panneau
local STUD_SIZE = isMobile and 6 or 8
local STUD_GAP = isMobile and 14 or 18
local function addStuds(frame, width, height)
    local layer = Instance.new("Frame")
    layer.Name = "Studs"
    layer.BackgroundTransparency = 1
    layer.Size = UDim2.fromScale(1, 1)
    layer.ClipsDescendants = true
    layer.ZIndex = 0
    local pad = Instance.new("UIPadding", layer)
    pad.PaddingLeft = UDim.new(0, 9)
    pad.PaddingTop = UDim.new(0, 9)
    local grid = Instance.new("UIGridLayout", layer)
    grid.CellSize = UDim2.fromOffset(STUD_SIZE, STUD_SIZE)
    grid.CellPadding = UDim2.fromOffset(STUD_GAP, STUD_GAP)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    local step = STUD_SIZE + STUD_GAP
    for _ = 1, math.ceil(width / step) * math.ceil(height / step) do
        local stud = Instance.new("Frame")
        stud.BorderSizePixel = 0
        stud.BackgroundColor3 = BRICK.Stud
        stud.BackgroundTransparency = 0.2
        stud.ZIndex = 0
        Instance.new("UICorner", stud).CornerRadius = UDim.new(1, 0)
        stud.Parent = layer
    end
    layer.Parent = frame
    return layer
end

-- Panneau bleu à picots
local function brickPanel(frame, width, height)
    brickify(frame, BRICK.Blue, BRICK.BlueDark, 12, 4)
    addStuds(frame, width, height)
end

-- Police pour les symboles (▶ ♥ ∞ ♪ ✓...) que FredokaOne ne contient pas
local GLYPH_FONT = Enum.Font.GothamBlack
local function glyph(obj)
    obj.Font = GLYPH_FONT
    return obj
end

-- Bouton-icône carré coloré (✕ rouge, ✓ vert, etc.)
local function brickIcon(btn, color, edgeColor, textSize)
    brickify(btn, color, edgeColor, 8, 3)
    brickText(btn, textSize)
    if btn:IsA("GuiButton") then
        btn.AutoButtonColor = false
    end
end

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
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Floating Bubble (Minimized) : brique orange carrée
local bubble = Instance.new("TextButton", screenGui)
bubble.Name = "Bubble"
bubble.Size = UDim2.new(0, 54, 0, 54)
bubble.Position = UDim2.new(0, 20, 0.5, -27)
bubble.Text = "⚡"
bubble.TextSize = 26
bubble.Visible = false
brickIcon(bubble, BRICK.Orange, BRICK.OrangeDark, 26)
bubble:FindFirstChild("BrickEdge").Thickness = 4

-- Main Frame : grand panneau bleu à picots
local main = Instance.new("Frame", screenGui)
main.Name = "MainFrame"
main.Size = UDim2.new(0, sizes.w, 0, sizes.h)
main.Position = UDim2.new(0.5, -sizes.w/2, 0.5, -sizes.h/2)
main.Visible = true
brickPanel(main, sizes.w, sizes.h)

-- Header : barre de titre orange en relief
local headerH = sizes.head - 8
local iconSize = headerH - 14
local header = Instance.new("Frame", main)
header.Name = "Header"
header.Position = UDim2.new(0, 8, 0, 8)
header.Size = UDim2.new(1, -16, 0, headerH)
brickify(header, BRICK.Orange, BRICK.OrangeDark, 8, 3)

local icon = Instance.new("TextLabel", header)
icon.Text = "⚡"
icon.Size = UDim2.new(0, iconSize, 0, iconSize)
icon.Position = UDim2.new(0, 7, 0.5, -iconSize/2)
brickIcon(icon, BRICK.Yellow, BRICK.YellowDark, sizes.txt + 4)

local title = Instance.new("TextLabel", header)
title.Text = "KOYLE ADMIN HUB"
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, iconSize + 16, 0, 0)
title.Size = UDim2.new(1, -(iconSize + 16) - 2 * (iconSize + 8) - 4, 1, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTruncate = Enum.TextTruncate.AtEnd
brickText(title, sizes.txt + 4)

-- Minimize Button "-" : icône bleue
local minBtn = Instance.new("TextButton", header)
minBtn.Name = "MinimizeButton"
minBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
minBtn.Position = UDim2.new(1, -2 * (iconSize + 8), 0.5, -iconSize/2)
minBtn.Text = "-"
brickIcon(minBtn, BRICK.BlueLight, BRICK.BlueDark, sizes.txt + 8)

-- Close Button : icône rouge ✕ (avec confirmation)
local closeBtn = Instance.new("TextButton", header)
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, iconSize, 0, iconSize)
closeBtn.Position = UDim2.new(1, -(iconSize + 8), 0.5, -iconSize/2)
closeBtn.Text = "X"
brickIcon(closeBtn, BRICK.Red, BRICK.RedDark, sizes.txt + 2)
closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100) end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = BRICK.Red end)
minBtn.MouseEnter:Connect(function() minBtn.BackgroundColor3 = BRICK.BlueHover end)
minBtn.MouseLeave:Connect(function() minBtn.BackgroundColor3 = BRICK.BlueLight end)

-- Boîte de dialogue "brique" réutilisable (fermeture, reset key...)
local DIALOG_W = isMobile and 280 or 360
local DIALOG_H = 184
local function createBrickDialog(name, titleText, bodyText, confirmText, confirmColor, confirmEdge)
    local dialog = Instance.new("Frame", screenGui)
    dialog.Name = name
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.Size = UDim2.new(0, DIALOG_W, 0, DIALOG_H)
    dialog.Visible = false
    dialog.ZIndex = 50
    brickPanel(dialog, DIALOG_W, DIALOG_H)

    local dTitle = Instance.new("TextLabel", dialog)
    dTitle.Name = "Title"
    dTitle.Position = UDim2.new(0, 10, 0, 10)
    dTitle.Size = UDim2.new(1, -20, 0, 36)
    dTitle.Text = titleText
    dTitle.ZIndex = 51
    brickify(dTitle, BRICK.Orange, BRICK.OrangeDark, 8, 3)
    brickText(dTitle, isMobile and 16 or 19)

    local dText = Instance.new("TextLabel", dialog)
    dText.Name = "Body"
    dText.BackgroundTransparency = 1
    dText.Position = UDim2.new(0, 16, 0, 52)
    dText.Size = UDim2.new(1, -32, 0, 70)
    dText.Text = bodyText
    dText.TextWrapped = true
    dText.ZIndex = 51
    brickText(dText, isMobile and 12 or 14)

    local cancel = Instance.new("TextButton", dialog)
    cancel.Name = "Cancel"
    cancel.Size = UDim2.new(0.43, 0, 0, 38)
    cancel.Position = UDim2.new(0.05, 0, 1, -50)
    cancel.Text = "CANCEL"
    cancel.ZIndex = 51
    brickIcon(cancel, BRICK.BlueLight, BRICK.BlueDark, isMobile and 13 or 15)

    local confirm = Instance.new("TextButton", dialog)
    confirm.Name = "Confirm"
    confirm.Size = UDim2.new(0.43, 0, 0, 38)
    confirm.Position = UDim2.new(0.52, 0, 1, -50)
    confirm.Text = confirmText
    confirm.ZIndex = 51
    brickIcon(confirm, confirmColor, confirmEdge, isMobile and 13 or 15)

    return dialog, cancel, confirm
end

-- Confirmation Modal
local closeConfirm, cancelCloseBtn, confirmCloseBtn = createBrickDialog(
    "CloseConfirmation",
    "CLOSE PANEL?",
    "The script will stop and its effects will be cancelled. This action is permanent for this session.",
    "CLOSE", BRICK.Red, BRICK.RedDark
)

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
scroll.ScrollBarThickness = 6; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarImageColor3 = BRICK.Orange
local scrollPad = Instance.new("UIPadding", scroll)
scrollPad.PaddingTop = UDim.new(0, 5); scrollPad.PaddingBottom = UDim.new(0, 8)
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

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

-- --- BUTTON CREATOR (BRICK STYLE) ---
local toggleCount = 0
local function addToggle(txt, cb)
    toggleCount += 1
    local btnFrame = Instance.new("Frame", scroll)
    btnFrame.Size = UDim2.new(1, -12, 0, sizes.btn)
    btnFrame.BackgroundTransparency = 1
    btnFrame.LayoutOrder = toggleCount

    local b = Instance.new("TextButton", btnFrame)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.Text = txt
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.AutoButtonColor = false
    local buttonStroke = brickify(b, BRICK.BlueLight, BRICK.BlueDark, 8, 3)
    brickText(b, sizes.txt)
    local pad = Instance.new("UIPadding", b)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, sizes.btn)

    -- Case d'état à droite : bleu foncé = OFF, vert ✓ = ON
    local boxSize = sizes.btn - 16
    local statusIndicator = Instance.new("TextLabel", b)
    statusIndicator.Name = "Status"
    statusIndicator.AnchorPoint = Vector2.new(1, 0.5)
    statusIndicator.Size = UDim2.new(0, boxSize, 0, boxSize)
    statusIndicator.Position = UDim2.new(1, sizes.btn - 8, 0.5, 0)
    statusIndicator.Text = ""
    local statusEdge = brickify(statusIndicator, BRICK.BlueDeep, BRICK.BlueDark, 6, 2)
    brickText(statusIndicator, sizes.txt)
    glyph(statusIndicator)

    local active = false
    local hovered = false

    local function refreshToggleStyle()
        local targetColor = hovered and BRICK.BlueHover or BRICK.BlueLight
        TweenService:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = targetColor
        }):Play()
        buttonStroke.Color = active and BRICK.OrangeDark or BRICK.BlueDark
        buttonStroke.Thickness = active and 4 or 3
        statusIndicator.Text = active and "✓" or ""
        statusEdge.Color = active and BRICK.GreenDark or BRICK.BlueDark
        TweenService:Create(statusIndicator, TweenInfo.new(0.12), {
            BackgroundColor3 = active and BRICK.Green or BRICK.BlueDeep
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
end

addToggle("4. 👁️ Player ESP", function(a)
    states.esp = a
    if not a then 
        removePlayerESP()
    end
    connections["ESP"] = RunService.RenderStepped:Connect(function()
        if states.esp then
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    if not playerESPObjects[head] or not playerESPObjects[head].Parent then
                        local b = Instance.new("BillboardGui", head); b.Name = "ESP_MARK"; b.AlwaysOnTop = true; b.Size = UDim2.new(0,80,0,40)
                        local t = Instance.new("TextLabel", b); t.Text = p.Name; t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.TextColor3 = GUI_THEME.Accent; t.Font = BRICK_FONT; t.TextScaled = true
                        playerESPObjects[head] = b
                    end
                end
            end
        end
    end)
end)

addToggle("5. 🎇 Dash (Click/Touch)", function(a) states.dash = a end)
mouse.Button1Down:Connect(function() if states.dash and getRoot() then getRoot().CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end end)

addToggle("6. 🛡️ God Mode", function(a)
    states.godmode = a
    connections["God"] = RunService.Heartbeat:Connect(function() if states.godmode and getHum() then getHum().Health = 100 end end)
end)

addToggle("7. ⚡ Lightning Speed", function(a) if getHum() then getHum().WalkSpeed = a and 70 or 16 end end)

addToggle("8. 🦘 Infinite Jump", function(a)
    states.infjump = a
    connections["Jump"] = UserInputService.JumpRequest:Connect(function() if states.infjump and getHum() then getHum():ChangeState(3) end end)
end)

-- Optimized X-Ray
local function isCharacterPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    return model ~= nil and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function restoreXRayPart(part)
    local original = xrayOriginals[part]
    if original ~= nil then
        if part and part.Parent then
            part.LocalTransparencyModifier = original
        end
        xrayOriginals[part] = nil
    end
end

local function stopXRay()
    if xrayConnection then
        xrayConnection:Disconnect()
        xrayConnection = nil
    end
    for part, original in pairs(xrayOriginals) do
        if part and part.Parent then
            part.LocalTransparencyModifier = original
        end
        xrayOriginals[part] = nil
    end
    xrayAccumulator = 0
    states.xray = false
end

local function updateXRay()
    local root = getRoot()
    if not root then return end

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = player.Character and {player.Character} or {}
    overlap.MaxParts = XRAY_MAX_PARTS

    local ok, nearbyParts = pcall(function()
        return Workspace:GetPartBoundsInRadius(root.Position, XRAY_RADIUS, overlap)
    end)
    if not ok or not nearbyParts then return end

    local currentlyNearby = {}
    for _, part in ipairs(nearbyParts) do
        if part:IsA("BasePart") and part.Parent and not isCharacterPart(part) then
            currentlyNearby[part] = true
            if xrayOriginals[part] == nil then
                xrayOriginals[part] = part.LocalTransparencyModifier
            end
            part.LocalTransparencyModifier = math.max(xrayOriginals[part], 0.5)
        end
    end

    for part, original in pairs(xrayOriginals) do
        if not currentlyNearby[part] then
            restoreXRayPart(part)
        end
    end
end

addToggle("9. 🩻 X-Ray (Optimized Area)", function(a)
    if not a then
        stopXRay()
        return
    end

    if xrayConnection then
        xrayConnection:Disconnect()
        xrayConnection = nil
    end
    states.xray = true
    xrayAccumulator = XRAY_UPDATE_INTERVAL
    xrayConnection = RunService.Heartbeat:Connect(function(dt)
        if not states.xray then return end
        xrayAccumulator += dt
        if xrayAccumulator >= XRAY_UPDATE_INTERVAL then
            xrayAccumulator = 0
            updateXRay()
        end
    end)
end)

addToggle("10. 💡 Full Bright", function(a)
    Lighting.Ambient = a and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    Lighting.Brightness = a and 2 or 1
end)

addToggle("11.🔍 Infinite Zoom", function(a)
    player.CameraMaxZoomDistance = a and 9999 or 400
    player.CameraMinZoomDistance = a and 0 or 0.5
end)

-- --- SIDE WINDOWS (BRICK STYLE) ---
local SIDE_W, SIDE_H = 210, 270
local function createSideWindow(name, titleText, position)
    local win = Instance.new("Frame", screenGui)
    win.Name = name
    win.Size = UDim2.new(0, SIDE_W, 0, SIDE_H)
    win.Position = position
    win.Visible = false
    brickPanel(win, SIDE_W, SIDE_H)

    local winHeader = Instance.new("TextLabel", win)
    winHeader.Name = "Header"
    winHeader.Position = UDim2.new(0, 7, 0, 7)
    winHeader.Size = UDim2.new(1, -14, 0, 32)
    winHeader.Text = titleText
    brickify(winHeader, BRICK.Orange, BRICK.OrangeDark, 8, 3)
    brickText(winHeader, 16)

    local winScr = Instance.new("ScrollingFrame", win)
    winScr.Size = UDim2.new(1, -14, 1, -54); winScr.Position = UDim2.new(0, 7, 0, 46)
    winScr.BackgroundTransparency = 1; winScr.BorderSizePixel = 0
    winScr.AutomaticCanvasSize = Enum.AutomaticSize.Y
    winScr.CanvasSize = UDim2.new(0, 0, 0, 0)
    winScr.ScrollBarThickness = 4
    winScr.ScrollBarImageColor3 = BRICK.Orange
    local winPad = Instance.new("UIPadding", winScr)
    winPad.PaddingTop = UDim.new(0, 4); winPad.PaddingLeft = UDim.new(0, 4); winPad.PaddingRight = UDim.new(0, 8)
    local winLayout = Instance.new("UIListLayout", winScr)
    winLayout.Padding = UDim.new(0, 7)
    winLayout.SortOrder = Enum.SortOrder.LayoutOrder

    makeDraggable(win, winHeader)
    return win, winHeader, winScr
end

local function createListButton(parent, text, color, edgeColor, order)
    local pb = Instance.new("TextButton", parent)
    pb.Size = UDim2.new(1, 0, 0, 32)
    pb.Text = text
    pb.LayoutOrder = order or 0
    pb.TextTruncate = Enum.TextTruncate.AtEnd
    brickIcon(pb, color or BRICK.BlueLight, edgeColor or BRICK.BlueDark, 14)
    local base = color or BRICK.BlueLight
    pb.MouseEnter:Connect(function() pb.BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.2) end)
    pb.MouseLeave:Connect(function() pb.BackgroundColor3 = base end)
    return pb
end

-- --- PLAYER TELEPORT SYSTEM ---
local tpWin, tpHeader, tpScr = createSideWindow("TeleportWindow", "TELEPORT", UDim2.new(0.5, sizes.w/2 + 20, 0.5, -SIDE_H/2))

addToggle("12. 👥 TP TO PLAYER ▼", function(active)
    tpWin.Visible = active
    if tpWin.Visible then
        for _, v in pairs(tpScr:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local order = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                order += 1
                local pb = createListButton(tpScr, p.DisplayName, nil, nil, order)
                pb.MouseButton1Click:Connect(function() 
                    if getRoot() and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                        getRoot().CFrame = p.Character.HumanoidRootPart.CFrame 
                    end 
                end)
            end
        end
    end
end)

-- --- SPECTATE SYSTEM ---
local specWin, specHeader, specScr = createSideWindow("SpectateWindow", "SPECTATE", UDim2.new(0.5, -sizes.w/2 - SIDE_W - 20, 0.5, -SIDE_H/2))

addToggle("13. 👁️ SPECTATE PLAYER ▼", function(active)
    specWin.Visible = active
    if specWin.Visible then
        for _, v in pairs(specScr:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        
        local stopBtn = createListButton(specScr, "X  STOP SPECTATE", BRICK.Red, BRICK.RedDark, 0)
        stopBtn.MouseButton1Click:Connect(function() 
            if getHum() then camera.CameraSubject = getHum() end
        end)

        local order = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player then
                order += 1
                local pb = createListButton(specScr, p.DisplayName, nil, nil, order)
                pb.MouseButton1Click:Connect(function() 
                    if p.Character and p.Character:FindFirstChild("Humanoid") then 
                        camera.CameraSubject = p.Character.Humanoid
                    end 
                end)
            end
        end
    else
        if getHum() then camera.CameraSubject = getHum() end
    end
end)

-- --- BOOMBOX RELICSxyz v4.1 SYSTEM (BRICK STYLE) ---
local boomboxFrame = Instance.new("Frame", screenGui)
boomboxFrame.Name = "BoomboxFrame"
boomboxFrame.ClipsDescendants = true
boomboxFrame.Visible = false
brickPanel(boomboxFrame, isMobile and 900 or 440, isMobile and 280 or 600)

local function updateBoomboxSize()
    if isMobile then
        boomboxFrame.AnchorPoint = Vector2.new(0.5, 1)
        boomboxFrame.Position = UDim2.new(0.5, 0, 1, -10)
        boomboxFrame.Size = UDim2.new(1, -14, 0, 280)
    else
        boomboxFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        boomboxFrame.Position = UDim2.new(0.5, sizes.w / 2 + 250, 0.5, 0)
        boomboxFrame.Size = UDim2.new(0, 440, 0, 600)
    end
end
updateBoomboxSize()
camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateBoomboxSize)

-- Barre de titre orange
local bbTopBar = Instance.new("Frame", boomboxFrame)
bbTopBar.Name = "TopBar"
bbTopBar.Position = UDim2.new(0, 8, 0, 8)
bbTopBar.Size = UDim2.new(1, -16, 0, 40)
brickify(bbTopBar, BRICK.Orange, BRICK.OrangeDark, 8, 3)

local bbTitle = Instance.new("TextLabel", bbTopBar)
bbTitle.Text = "RELICSxyz"
bbTitle.BackgroundTransparency = 1
bbTitle.Position = UDim2.new(0, 12, 0, 0)
bbTitle.Size = UDim2.new(1, -60, 1, 0)
bbTitle.TextXAlignment = Enum.TextXAlignment.Left
brickText(bbTitle, isMobile and 18 or 22)

local bbMinBtn = Instance.new("TextButton", bbTopBar)
bbMinBtn.Text = "-"
bbMinBtn.Size = UDim2.new(0, 30, 0, 30)
bbMinBtn.Position = UDim2.new(1, -36, 0.5, -15)
brickIcon(bbMinBtn, BRICK.BlueLight, BRICK.BlueDark, 22)

makeDraggable(boomboxFrame, bbTopBar)

local bbTop = 56
local bbNavH = isMobile and 48 or 60
local bbPages = Instance.new("Frame", boomboxFrame)
bbPages.Position = UDim2.new(0, 0, 0, bbTop)
bbPages.Size = UDim2.new(1, 0, 1, -(bbTop + bbNavH + 16))
bbPages.BackgroundTransparency = 1
bbPages.ClipsDescendants = true

local bbPageBrowse = Instance.new("Frame", bbPages); bbPageBrowse.Size = UDim2.new(1,0,1,0); bbPageBrowse.BackgroundTransparency = 1
local bbPagePlay = Instance.new("Frame", bbPages); bbPagePlay.Size = UDim2.new(1,0,1,0); bbPagePlay.Position = UDim2.new(1,0,0,0); bbPagePlay.BackgroundTransparency = 1
local bbPageFavs = Instance.new("ScrollingFrame", bbPages); bbPageFavs.Size = UDim2.new(1,0,1,0); bbPageFavs.Position = UDim2.new(2,0,0,0); bbPageFavs.BackgroundTransparency = 1; bbPageFavs.BorderSizePixel = 0; bbPageFavs.ScrollBarThickness = 4; bbPageFavs.ScrollBarImageColor3 = BRICK.Orange; bbPageFavs.CanvasSize = UDim2.new(0,0,0,0)

-- Browse Page : champ de recherche bleu foncé (style "NAME")
local bbSearchBox = Instance.new("TextBox", bbPageBrowse)
bbSearchBox.PlaceholderText = "Paste a Roblox ID..."
bbSearchBox.PlaceholderColor3 = BRICK.TextSoft
bbSearchBox.Text = ""
bbSearchBox.Size = UDim2.new(1, -24, 0, isMobile and 36 or 42)
bbSearchBox.Position = UDim2.new(0, 12, 0, 2)
bbSearchBox.ClearTextOnFocus = false
brickify(bbSearchBox, BRICK.BlueDeep, BRICK.BlueDark, 21, 3)
brickText(bbSearchBox, 15)

local bbScrollList = Instance.new("ScrollingFrame", bbPageBrowse)
bbScrollList.Position = UDim2.new(0, 0, 0, isMobile and 46 or 54)
bbScrollList.Size = UDim2.new(1, 0, 1, isMobile and -46 or -54)
bbScrollList.BackgroundTransparency = 1
bbScrollList.BorderSizePixel = 0
bbScrollList.ScrollBarThickness = 4
bbScrollList.ScrollBarImageColor3 = BRICK.Orange
bbScrollList.CanvasSize = UDim2.new(0,0,0,0)
local bbListPad = Instance.new("UIPadding", bbScrollList)
bbListPad.PaddingTop = UDim.new(0, 4); bbListPad.PaddingLeft = UDim.new(0, 8); bbListPad.PaddingRight = UDim.new(0, 8)
local bbListLayout = Instance.new("UIListLayout", bbScrollList)
bbListLayout.Padding = UDim.new(0, 8)
bbListLayout.SortOrder = Enum.SortOrder.LayoutOrder
bbListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    bbScrollList.CanvasSize = UDim2.new(0,0,0, bbListLayout.AbsoluteContentSize.Y + 12)
end)

-- Play Page
local BB_ICON_OFF = BRICK.BlueDeep
local BB_ICON_OFF_EDGE = BRICK.BlueDark

local bbBtnHeart = Instance.new("TextButton", bbPagePlay)
bbBtnHeart.Text = "♥"
bbBtnHeart.Size = UDim2.new(0, 36, 0, 36)
bbBtnHeart.Position = UDim2.new(0, 12, 0, 4)
local bbHeartEdge = brickify(bbBtnHeart, BB_ICON_OFF, BB_ICON_OFF_EDGE, 8, 3)
brickText(bbBtnHeart, 20)
glyph(bbBtnHeart)
bbBtnHeart.AutoButtonColor = false

local bbBtnLoop = Instance.new("TextButton", bbPagePlay)
bbBtnLoop.Text = "∞"
bbBtnLoop.Size = UDim2.new(0, 36, 0, 36)
bbBtnLoop.Position = UDim2.new(0, 56, 0, 4)
local bbLoopEdge = brickify(bbBtnLoop, BB_ICON_OFF, BB_ICON_OFF_EDGE, 8, 3)
brickText(bbBtnLoop, 22)
glyph(bbBtnLoop)
bbBtnLoop.AutoButtonColor = false

local function bbSetHeart(isFav)
    bbBtnHeart.BackgroundColor3 = isFav and BRICK.Pink or BB_ICON_OFF
    bbHeartEdge.Color = isFav and BRICK.PinkDark or BB_ICON_OFF_EDGE
end
local function bbSetLoop(isLooped)
    bbBtnLoop.BackgroundColor3 = isLooped and BRICK.Purple or BB_ICON_OFF
    bbLoopEdge.Color = isLooped and BRICK.PurpleDark or BB_ICON_OFF_EDGE
end

-- Pochette : grosse brique jaune
local bbCoverSize = isMobile and 70 or 130
local bbCover = Instance.new("Frame", bbPagePlay)
bbCover.Size = UDim2.new(0, bbCoverSize, 0, bbCoverSize)
bbCover.Position = UDim2.new(0.5, -bbCoverSize/2, 0, isMobile and 6 or 10)
brickify(bbCover, BRICK.Yellow, BRICK.YellowDark, 14, 4)

local bbCoverLabel = Instance.new("TextLabel", bbCover)
bbCoverLabel.Size = UDim2.new(1,0,1,0)
bbCoverLabel.BackgroundTransparency = 1
bbCoverLabel.Text = "♪"
brickText(bbCoverLabel, isMobile and 32 or 56)
glyph(bbCoverLabel)

local bbLblSong = Instance.new("TextLabel", bbPagePlay)
bbLblSong.Text = "No audio"
bbLblSong.BackgroundTransparency = 1
bbLblSong.Position = UDim2.new(0, 14, 0, isMobile and 84 or 150)
bbLblSong.Size = UDim2.new(1, -28, 0, 22)
bbLblSong.TextXAlignment = Enum.TextXAlignment.Left
bbLblSong.TextTruncate = Enum.TextTruncate.AtEnd
brickText(bbLblSong, isMobile and 16 or 20)

local bbLblArtist = Instance.new("TextLabel", bbPagePlay)
bbLblArtist.Text = "Browse to search"
bbLblArtist.BackgroundTransparency = 1
bbLblArtist.Position = UDim2.new(0, 14, 0, isMobile and 104 or 174)
bbLblArtist.Size = UDim2.new(1, -80, 0, 16)
bbLblArtist.TextXAlignment = Enum.TextXAlignment.Left
brickText(bbLblArtist, 13, BRICK.TextSoft)

local bbLblTime = Instance.new("TextLabel", bbPagePlay)
bbLblTime.Text = "-0:00"
bbLblTime.BackgroundTransparency = 1
bbLblTime.Position = UDim2.new(1, -60, 0, isMobile and 104 or 174)
bbLblTime.Size = UDim2.new(0, 46, 0, 16)
bbLblTime.TextXAlignment = Enum.TextXAlignment.Right
brickText(bbLblTime, 13, BRICK.TextSoft)

-- Progress Bar : piste bleu foncé + remplissage vert
local bbBarBack = Instance.new("Frame", bbPagePlay)
bbBarBack.Size = UDim2.new(1, -28, 0, isMobile and 10 or 14)
bbBarBack.Position = UDim2.new(0, 14, 0, isMobile and 124 or 198)
brickify(bbBarBack, BRICK.BlueDeep, BRICK.BlueDark, 7, 3)
bbBarBack.ClipsDescendants = true

local bbBarFill = Instance.new("Frame", bbBarBack)
bbBarFill.Size = UDim2.new(0,0,1,0)
bbBarFill.BackgroundColor3 = BRICK.Green
bbBarFill.BorderSizePixel = 0
Instance.new("UICorner", bbBarFill).CornerRadius = UDim.new(0, 7)
local bbBarShine = Instance.new("UIGradient", bbBarFill)
bbBarShine.Color = ColorSequence.new(Color3.fromRGB(170, 255, 120), BRICK.Green)
bbBarShine.Rotation = 90

-- Bouton Play : brique verte (style "OK")
local bbPlaySize = isMobile and 50 or 68
local bbBtnPlay = Instance.new("TextButton", bbPagePlay)
bbBtnPlay.Text = "▶"
bbBtnPlay.Size = UDim2.new(0, bbPlaySize, 0, bbPlaySize)
bbBtnPlay.Position = UDim2.new(0.5, -bbPlaySize/2, 0, isMobile and 140 or 226)
brickIcon(bbBtnPlay, BRICK.Green, BRICK.GreenDark, isMobile and 22 or 30)
bbBtnPlay:FindFirstChild("BrickEdge").Thickness = 4
glyph(bbBtnPlay)

-- Bottom Navigation
local bbNav = Instance.new("Frame", boomboxFrame)
bbNav.Size = UDim2.new(1, -16, 0, bbNavH)
bbNav.Position = UDim2.new(0, 8, 1, -bbNavH - 8)
brickify(bbNav, BRICK.BlueDark, BRICK.BlueDeep, 10, 3)

local function bbMakeNav(text, iconStr, xPos)
    local b = Instance.new("TextButton", bbNav)
    b.Size = UDim2.new(0.333, -8, 1, -10)
    b.Position = UDim2.new(xPos, 5, 0, 5)
    b.Text = iconStr.."  "..text
    brickIcon(b, BRICK.BlueLight, BRICK.BlueDeep, isMobile and 12 or 14)
    glyph(b)
    return b
end

local bbNavBrowse = bbMakeNav("Browse", "◫", 0)
local bbNavPlay = bbMakeNav("Play", "▶", 0.333)
local bbNavFavs = bbMakeNav("Favs", "♥", 0.666)

local bbCurrentTab = 1
local function bbSwitchPage(index)
    bbCurrentTab = index
    local target = UDim2.new(-(index-1), 0, 0, 0)
    TweenService:Create(bbPageBrowse, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = target}):Play()
    TweenService:Create(bbPagePlay, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = target + UDim2.new(1,0,0,0)}):Play()
    TweenService:Create(bbPageFavs, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {Position = target + UDim2.new(2,0,0,0)}):Play()
    for i, navBtn in ipairs({bbNavBrowse, bbNavPlay, bbNavFavs}) do
        local selected = (i == index)
        navBtn.BackgroundColor3 = selected and BRICK.Orange or BRICK.BlueLight
        navBtn:FindFirstChild("BrickEdge").Color = selected and BRICK.OrangeDark or BRICK.BlueDeep
    end
end

bbNavBrowse.MouseButton1Click:Connect(function() bbSwitchPage(1) end)
bbNavPlay.MouseButton1Click:Connect(function() bbSwitchPage(2) end)
bbNavFavs.MouseButton1Click:Connect(function() bbSwitchPage(3) end)

local bbCurrentSong = nil

local function bbFormatTime(s)
    s = math.floor(s)
    return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

local function bbCreateItem(parent, id, name, creator)
    local item = Instance.new("TextButton")
    item.Size = UDim2.new(1, -4, 0, isMobile and 50 or 60)
    item.AutoButtonColor = false
    item.Text = ""
    brickify(item, BRICK.BlueLight, BRICK.BlueDark, 10, 3)
    item.Parent = parent

    local itemTitle = Instance.new("TextLabel", item)
    itemTitle.Text = name
    itemTitle.BackgroundTransparency = 1
    itemTitle.Position = UDim2.new(0, 12, 0, 6)
    itemTitle.Size = UDim2.new(1, -56, 0, 20)
    itemTitle.TextXAlignment = Enum.TextXAlignment.Left
    itemTitle.TextTruncate = Enum.TextTruncate.AtEnd
    brickText(itemTitle, 16)

    local sub = Instance.new("TextLabel", item)
    sub.Text = "@"..creator
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.new(0, 12, 0, isMobile and 27 or 30)
    sub.Size = UDim2.new(1, -56, 0, 16)
    sub.TextXAlignment = Enum.TextXAlignment.Left
    brickText(sub, 12, BRICK.TextSoft)

    local isFav = favorites[tostring(id)] ~= nil
    local heart = Instance.new("TextLabel", item)
    heart.Text = "♥"
    heart.Size = UDim2.new(0, 28, 0, 28)
    heart.Position = UDim2.new(1, -38, 0.5, -14)
    brickify(heart, isFav and BRICK.Pink or BRICK.BlueDeep, isFav and BRICK.PinkDark or BRICK.BlueDark, 6, 2)
    brickText(heart, 15)
    glyph(heart)

    item.MouseEnter:Connect(function()
        TweenService:Create(item, TweenInfo.new(0.1), {BackgroundColor3 = BRICK.BlueHover}):Play()
    end)
    item.MouseLeave:Connect(function()
        TweenService:Create(item, TweenInfo.new(0.1), {BackgroundColor3 = BRICK.BlueLight}):Play()
    end)

    item.MouseButton1Click:Connect(function()
        bbCurrentSong = {id=id, name=name, creator=creator}
        sound.SoundId = "rbxassetid://"..id
        sound:Play()
        bbBtnPlay.Text = "⏸"
        bbLblSong.Text = name
        bbLblArtist.Text = "@"..creator
        bbCoverLabel.Text = string.sub(name,1,1):upper()
        bbSetHeart(favorites[tostring(id)] ~= nil)
        bbSwitchPage(2)
    end)

    return item
end

bbSearchBox.FocusLost:Connect(function(enter)
    if not enter then return end
    local id = tonumber(bbSearchBox.Text:match("%d+"))
    if not id then return end
    local success, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Asset)
    if success and info and info.AssetTypeId == 3 then
        bbCreateItem(bbScrollList, id, info.Name, info.Creator.Name)
        bbSearchBox.Text = ""
    else
        bbSearchBox.Text = "Invalid ID"
        task.wait(1)
        bbSearchBox.Text = ""
    end
end)

bbBtnPlay.MouseButton1Click:Connect(function()
    if sound.IsPlaying then
        sound:Pause()
        bbBtnPlay.Text = "▶"
    else
        sound:Resume()
        bbBtnPlay.Text = "⏸"
    end
end)

bbBtnHeart.MouseButton1Click:Connect(function()
    if not bbCurrentSong then return end
    local id = tostring(bbCurrentSong.id)
    if favorites[id] then
        favorites[id] = nil
        bbSetHeart(false)
    else
        favorites[id] = {name=bbCurrentSong.name, creator=bbCurrentSong.creator}
        bbSetHeart(true)
    end
    saveFavs()
end)

bbBtnLoop.MouseButton1Click:Connect(function()
    sound.Looped = not sound.Looped
    bbSetLoop(sound.Looped)
end)

RunService.Heartbeat:Connect(function()
    if sound.IsLoaded and sound.TimeLength > 0 then
        local progress = sound.TimePosition / sound.TimeLength
        bbBarFill.Size = UDim2.new(math.clamp(progress,0,1), 0, 1, 0)
        bbLblTime.Text = "-"..bbFormatTime(sound.TimeLength - sound.TimePosition)
    end
end)

local bbIsMinimized = false
bbMinBtn.MouseButton1Click:Connect(function()
    bbIsMinimized = not bbIsMinimized
    local targetHeight = bbIsMinimized and 56 or (isMobile and 280 or 600)
    TweenService:Create(boomboxFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(boomboxFrame.Size.X.Scale, boomboxFrame.Size.X.Offset, 0, targetHeight)}):Play()
    bbPages.Visible = not bbIsMinimized
    bbNav.Visible = not bbIsMinimized
end)

local function bbAddFavLayout()
    local favPad = Instance.new("UIPadding", bbPageFavs)
    favPad.PaddingTop = UDim.new(0, 4); favPad.PaddingLeft = UDim.new(0, 8); favPad.PaddingRight = UDim.new(0, 8)
    local favLayout = Instance.new("UIListLayout", bbPageFavs)
    favLayout.Padding = UDim.new(0, 8)
    favLayout.SortOrder = Enum.SortOrder.LayoutOrder
    favLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        bbPageFavs.CanvasSize = UDim2.new(0,0,0, favLayout.AbsoluteContentSize.Y + 12)
    end)
end
bbAddFavLayout()

bbNavFavs.MouseButton1Click:Connect(function()
    bbPageFavs:ClearAllChildren()
    bbAddFavLayout()
    for id, data in pairs(favorites) do
        bbCreateItem(bbPageFavs, tonumber(id), data.name, data.creator)
    end
end)

bbCreateItem(bbScrollList, 1837657613, "HR - WASSA", "Clippsly")
bbCreateItem(bbScrollList, 9043887097, "FEMININO DO VAPO FUNK", "DistrokidOfficial")
bbCreateItem(bbScrollList, 8422288236, "have", "4jayxx")

bbSwitchPage(1)

-- --- CONTROL PANEL BOOMBOX TOGGLE ---
addToggle("14. 🎵 BOOMBOX RELICSxyz ▼", function(active)
    boomboxFrame.Visible = active
    if active then
        bbSwitchPage(1)
    end
end)


-- --- ENTITY ESP ---
local entityESPObjects = {}
local entityESPScanConnection = nil
local entityESPAddedConnection = nil
local entityESPRemovingConnection = nil

local function isEntityModel(model)
    if not model or not model:IsA("Model") then
        return false
    end

    if Players:GetPlayerFromCharacter(model) then
        return false
    end

    return model:GetAttribute("IsEntity") == true
        or model:FindFirstChild("Entity") ~= nil
        or model:FindFirstChildOfClass("Humanoid") ~= nil
        or model:FindFirstChild("HumanoidRootPart") ~= nil
end

local function removeEntityESP(model)
    local data = entityESPObjects[model]
    if not data then
        return
    end

    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    entityESPObjects[model] = nil
end

local function createEntityESP(model)
    if not states.entitiesESP or entityESPObjects[model] or not isEntityModel(model) then
        return
    end

    local adornee = model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
        or model:FindFirstChild("Head")
        or model:FindFirstChildWhichIsA("BasePart", true)

    if not adornee then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "AdminEntityESP_Highlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 45, 45)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = screenGui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdminEntityESP_Info"
    billboard.Adornee = adornee
    billboard.Size = UDim2.fromOffset(180, 42)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 10000
    billboard.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 70, 70)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = BRICK_FONT
    label.Text = model.Name
    label.Parent = billboard

    entityESPObjects[model] = {
        highlight = highlight,
        billboard = billboard,
        label = label,
    }
end

local function scanEntityInstance(instance)
    if instance:IsA("Model") then
        createEntityESP(instance)
    elseif instance:IsA("BasePart") or instance:IsA("Humanoid")
        or instance.Name == "HumanoidRootPart" or instance.Name == "Entity"
        or instance:GetAttribute("IsEntity") == true then
        local model = instance:FindFirstAncestorOfClass("Model")
        if model then
            task.defer(function()
                if states.entitiesESP and model.Parent then
                    createEntityESP(model)
                end
            end)
        end
    end
end

local function setEntitiesESP(active)
    states.entitiesESP = active

    if entityESPAddedConnection then
        entityESPAddedConnection:Disconnect()
        entityESPAddedConnection = nil
    end
    if entityESPRemovingConnection then
        entityESPRemovingConnection:Disconnect()
        entityESPRemovingConnection = nil
    end
    if entityESPScanConnection then
        entityESPScanConnection:Disconnect()
        entityESPScanConnection = nil
    end

    if not active then
        for model in pairs(entityESPObjects) do
            removeEntityESP(model)
        end
        return
    end

    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("Model") then
            createEntityESP(instance)
        end
    end

    entityESPAddedConnection = Workspace.DescendantAdded:Connect(scanEntityInstance)

    entityESPRemovingConnection = Workspace.DescendantRemoving:Connect(function(instance)
        if instance:IsA("Model") then
            removeEntityESP(instance)
        end
    end)

    entityESPScanConnection = RunService.RenderStepped:Connect(function()
        if not states.entitiesESP then return end

        local root = getRoot()
        for model, data in pairs(entityESPObjects) do
            if not model.Parent then
                removeEntityESP(model)
            elseif root and data.billboard and data.billboard.Adornee
                and data.billboard.Adornee:IsA("BasePart") then
                local distance = (root.Position - data.billboard.Adornee.Position).Magnitude
                data.label.Text = string.format("%s\n%d studs", model.Name, math.floor(distance))
                data.billboard.Enabled = distance <= 10000
            end
        end
    end)
end

addToggle("15. 🔴 Entity ESP", setEntitiesESP)

-- --- MOVING OBJECTS ESP (OPTIMIZED) ---
-- Does not scan the whole map continuously: only queries an area around the player.
local movingESPObjects = {}
local movingESPConnection = nil
local movingESPAddedConnection = nil
local movingESPAccumulator = 0
local MOVING_ESP_RADIUS = 240
local MOVING_ESP_MAX_PARTS = 350
local MOVING_ESP_MAX_MARKERS = 80
local MOVING_ESP_INTERVAL = 0.4
local MOVING_ESP_MIN_DELTA = 1.25
local MOVING_ESP_FORGET_AFTER = 2.0

local function clearMovingESPPart(part)
    local data = movingESPObjects[part]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    movingESPObjects[part] = nil
end

local function stopMovingESP()
    if movingESPConnection then
        movingESPConnection:Disconnect()
        movingESPConnection = nil
    end
    if movingESPAddedConnection then
        movingESPAddedConnection:Disconnect()
        movingESPAddedConnection = nil
    end
    for part in pairs(movingESPObjects) do
        clearMovingESPPart(part)
    end
    movingESPAccumulator = 0
    states.movingESP = false
end

local function markMovingPart(part, distance)
    if movingESPObjects[part] or not part.Parent then return end

    local count = 0
    for _, existingData in pairs(movingESPObjects) do
        if existingData.highlight then count += 1 end
    end
    if count >= MOVING_ESP_MAX_MARKERS then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "AdminMovingESP_Highlight"
    highlight.Adornee = part
    highlight.FillColor = Color3.fromRGB(255, 170, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 245, 190)
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = screenGui

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AdminMovingESP_Info"
    billboard.Adornee = part
    billboard.Size = UDim2.fromOffset(160, 34)
    billboard.StudsOffset = Vector3.new(0, 1.8, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = MOVING_ESP_RADIUS
    billboard.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 190, 65)
    label.TextStrokeTransparency = 0.15
    label.TextScaled = true
    label.Font = BRICK_FONT
    label.Text = "OBJET EN MOUVEMENT"
    label.Parent = billboard

    movingESPObjects[part] = {
        highlight = highlight,
        billboard = billboard,
        label = label,
        lastPosition = part.Position,
        lastMovedAt = os.clock(),
        distance = distance or 0,
    }
end

local function updateMovingESP()
    local root = getRoot()
    if not root then return end

    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = player.Character and {player.Character} or {}
    overlap.MaxParts = MOVING_ESP_MAX_PARTS

    local ok, nearbyParts = pcall(function()
        return Workspace:GetPartBoundsInRadius(root.Position, MOVING_ESP_RADIUS, overlap)
    end)
    if not ok or not nearbyParts then return end

    local now = os.clock()
    local seen = {}

    for _, part in ipairs(nearbyParts) do
        if part:IsA("BasePart") and part.Parent then
            -- Ignore parts belonging to characters; player ESP already covers players.
            local ancestor = part:FindFirstAncestorOfClass("Model")
            local humanoidModel = ancestor and ancestor:FindFirstChildOfClass("Humanoid")
            if not humanoidModel then
                seen[part] = true
                local data = movingESPObjects[part]
                if not data then
                    -- First observation is only a baseline, not proof of movement.
                    movingESPObjects[part] = {
                        lastPosition = part.Position,
                        lastMovedAt = now,
                        candidate = true,
                    }
                else
                    local delta = (part.Position - data.lastPosition).Magnitude
                    if delta >= MOVING_ESP_MIN_DELTA then
                        data.lastMovedAt = now
                        data.lastPosition = part.Position
                        if data.candidate then
                            data.candidate = nil
                            movingESPObjects[part] = nil
                            markMovingPart(part, (root.Position - part.Position).Magnitude)
                            data = movingESPObjects[part]
                        elseif data.highlight then
                            data.distance = (root.Position - part.Position).Magnitude
                        end
                    else
                        data.lastPosition = part.Position
                    end
                    if data and data.highlight then
                        local distance = (root.Position - part.Position).Magnitude
                        data.distance = distance
                        data.label.Text = string.format("EN MOUVEMENT  •  %d studs", math.floor(distance))
                        data.billboard.Enabled = distance <= MOVING_ESP_RADIUS
                    end
                end
            end
        end
    end

    -- Drop candidates/markers that leave the scan area; markers are only retained briefly
    -- after movement stops, so the ESP does not accumulate across a huge map.
    for part, data in pairs(movingESPObjects) do
        if not part.Parent then
            clearMovingESPPart(part)
        elseif not seen[part] then
            if data.candidate or (now - (data.lastMovedAt or now)) > MOVING_ESP_FORGET_AFTER then
                clearMovingESPPart(part)
            end
        end
    end
end

local function setMovingESP(active)
    states.movingESP = active
    if movingESPConnection then
        movingESPConnection:Disconnect()
        movingESPConnection = nil
    end
    if movingESPAddedConnection then
        movingESPAddedConnection:Disconnect()
        movingESPAddedConnection = nil
    end

    if not active then
        for part in pairs(movingESPObjects) do
            clearMovingESPPart(part)
        end
        return
    end

    movingESPAccumulator = MOVING_ESP_INTERVAL
    movingESPConnection = RunService.Heartbeat:Connect(function(dt)
        if not states.movingESP then return end
        movingESPAccumulator += dt
        if movingESPAccumulator >= MOVING_ESP_INTERVAL then
            movingESPAccumulator = 0
            updateMovingESP()
        end
    end)

    movingESPAddedConnection = Workspace.DescendantRemoving:Connect(function(instance)
        if instance:IsA("BasePart") then
            clearMovingESPPart(instance)
        end
    end)
end

addToggle("16. 🟠 ESP Objets en mouvement", setMovingESP)

-- --- ANTI-AFK ---
-- Évite l'expulsion automatique de Roblox après 20 min d'inactivité.
local antiAFKConnection = nil
local function setAntiAFK(active)
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
    if not active then return end

    local VirtualUser = game:GetService("VirtualUser")
    antiAFKConnection = player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

addToggle("17. 💤 Anti-AFK", setAntiAFK)

-- --- FPS BOOST ---
-- Désactive localement ombres, particules et effets visuels lourds ; tout est restauré à la désactivation.
local fpsBoostOriginals = {}
local fpsBoostLighting = nil
local fpsBoostAddedConnection = nil
local FPS_EFFECT_CLASSES = {
    ParticleEmitter = true, Trail = true, Beam = true, Smoke = true,
    Fire = true, Sparkles = true, Explosion = false,
}
local FPS_POST_EFFECT_CLASSES = {
    BloomEffect = true, BlurEffect = true, SunRaysEffect = true,
    DepthOfFieldEffect = true, ColorCorrectionEffect = false,
}

local function fpsBoostInstance(instance)
    local className = instance.ClassName
    if FPS_EFFECT_CLASSES[className] or FPS_POST_EFFECT_CLASSES[className] then
        if fpsBoostOriginals[instance] == nil then
            fpsBoostOriginals[instance] = instance.Enabled
        end
        instance.Enabled = false
    end
end

local function setFPSBoost(active)
    if fpsBoostAddedConnection then
        fpsBoostAddedConnection:Disconnect()
        fpsBoostAddedConnection = nil
    end

    if active then
        fpsBoostLighting = fpsBoostLighting or {
            GlobalShadows = Lighting.GlobalShadows,
            FogEnd = Lighting.FogEnd,
        }
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
        end)
        for _, instance in ipairs(Workspace:GetDescendants()) do
            pcall(fpsBoostInstance, instance)
        end
        for _, instance in ipairs(Lighting:GetChildren()) do
            pcall(fpsBoostInstance, instance)
        end
        fpsBoostAddedConnection = Workspace.DescendantAdded:Connect(function(instance)
            pcall(fpsBoostInstance, instance)
        end)
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    else
        for instance, wasEnabled in pairs(fpsBoostOriginals) do
            if instance.Parent then
                pcall(function() instance.Enabled = wasEnabled end)
            end
        end
        fpsBoostOriginals = {}
        if fpsBoostLighting then
            pcall(function()
                Lighting.GlobalShadows = fpsBoostLighting.GlobalShadows
                Lighting.FogEnd = fpsBoostLighting.FogEnd
            end)
            fpsBoostLighting = nil
            pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        end
    end
end

addToggle("18. 🚀 FPS Boost", setFPSBoost)

-- --- UNTOUCHABLE ---
-- Le personnage ne bloque plus rien (CanCollide = false) et ne déclenche plus les zones
-- au toucher (CanTouch = false : lave, pièges, kill bricks). Valeurs d'origine restaurées à l'arrêt.
local untouchableOriginals = {}
local untouchableConnection = nil

local function applyUntouchable()
    local character = getChar()
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if untouchableOriginals[part] == nil then
                untouchableOriginals[part] = { collide = part.CanCollide, touch = part.CanTouch }
            end
            part.CanCollide = false
            part.CanTouch = false
        end
    end
end

local function setUntouchable(active)
    if untouchableConnection then
        untouchableConnection:Disconnect()
        untouchableConnection = nil
    end

    if active then
        applyUntouchable()
        -- Réappliqué à chaque frame physique : Roblox remet CanCollide sur certaines parties
        untouchableConnection = RunService.Stepped:Connect(applyUntouchable)
    else
        for part, original in pairs(untouchableOriginals) do
            if part.Parent then
                pcall(function()
                    part.CanCollide = original.collide
                    part.CanTouch = original.touch
                end)
            end
        end
        untouchableOriginals = {}
    end
end

addToggle("19. 🫥 Untouchable (No Collide)", setUntouchable)

-- Permanent script shutdown logic (OPTIMIZED - 0 WORKSPACE SCANS)
local scriptClosed = false
local function closeAdminPanelPermanently()
    if scriptClosed then return end
    scriptClosed = true

    -- Instantly stop states & loops
    for key in pairs(states) do states[key] = false end
    stopXRay()
    setEntitiesESP(false)
    stopMovingESP()
    setAntiAFK(false)
    setFPSBoost(false)
    setUntouchable(false)
    removePlayerESP()

    for name, connection in pairs(connections) do
        if connection then pcall(function() connection:Disconnect() end) end
        connections[name] = nil
    end
    if xrayConnection then pcall(function() xrayConnection:Disconnect() end); xrayConnection = nil end

    -- Cleanup fly physics
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end

    -- Restore local player defaults
    local character = player.Character
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            camera.CameraSubject = humanoid
        end
    end
    pcall(function()
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
        player.CameraMaxZoomDistance = 400
        player.CameraMinZoomDistance = 0.5
    end)

    pcall(function() sound:Stop(); sound:Destroy() end)
    activeDrag = nil
    screenGui:Destroy()
end

confirmCloseBtn.MouseButton1Click:Connect(closeAdminPanelPermanently)

-- --- RESET KEY (TEST) ---
-- Supprime définitivement la clé enregistrée, ferme le script, annule ses effets
-- et réaffiche la page de demande de clé.
local resetConfirm, cancelResetBtn, confirmResetBtn = createBrickDialog(
    "ResetKeyConfirmation",
    "RESET KEY?",
    "Your saved key will be permanently deleted. The script will close and the key page will open again.",
    "RESET", BRICK.Orange, BRICK.OrangeDark
)

local function resetKeyPermanently()
    -- 1. Ferme le script et annule tous ses effets
    closeAdminPanelPermanently()

    -- 2. Révoque l'autorisation de la session
    _G[ProtectionConfig.SecretKey] = nil

    -- 3. Supprime définitivement la clé enregistrée
    local keyFile = ProtectionConfig.KeyFileName
    local deleted = false
    if delfile and isfile then
        deleted = pcall(function()
            if isfile(keyFile) then delfile(keyFile) end
        end)
    end
    if not deleted and writefile then
        pcall(writefile, keyFile, "")
    end

    -- 4. Réaffiche la page de demande de clé
    task.defer(function()
        local showKeyPage = _G.KoyleKeySystem_Show
        if type(showKeyPage) == "function" then
            pcall(showKeyPage)
        else
            pcall(function()
                loadstring(game:HttpGet(ProtectionConfig.KeySystemURL))()
            end)
        end
    end)
end

addToggle("20. 🔑 Reset Key (Test)", function()
    resetConfirm.Visible = true
end)
cancelResetBtn.MouseButton1Click:Connect(function()
    resetConfirm.Visible = false
end)
confirmResetBtn.MouseButton1Click:Connect(resetKeyPermanently)

-- --- LAUNCH NOTIFICATION ---
task.spawn(function()
    -- SetCore peut échouer si les CoreScripts ne sont pas encore prêts : on réessaie sans bloquer le script
    for _ = 1, 10 do
        local ok = pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "KOYLE ADMIN HUB",
                Text = "Panel & RELICS Boombox loaded! Press [G] to minimize menu.",
                Duration = 5,
                Icon = "rbxassetid://1087851214"
            })
        end)
        if ok then break end
        task.wait(0.5)
    end
end)
