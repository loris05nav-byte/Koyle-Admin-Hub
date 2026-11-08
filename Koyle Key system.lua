local Config = {
    -- [1] PlatoBoost Settings
    ServiceId       = 36631, -- Your PlatoBoost Service ID
    PlatoSecret     = "daa22a8e-ab4d-4204-bb2a-46c7834ca80c", -- Your PlatoBoost Secret Key

    -- [2] Anti-Bypass / Global Secret Variable
    Secret          = "0652269804Xd", -- Identique au script principal !
    
    -- [3] Scripts & Links
    MainScriptURL   = "https://raw.githubusercontent.com/loris05nav-byte/Koyle-Admin-Hub/refs/heads/main/Koyle%20Admin%20hub%20v10.lua", -- Ton URL GitHub Raw
    
    -- [4] Social Media Settings
    ShowDiscord     = false,
    DiscordURL      = "https://discord.gg/kT55J724BK",
    
    ShowInstagram   = false,
    InstagramURL    = "https://www.instagram.com/oyb0i/",
    
    ShowYoutube     = false,
    YoutubeURL      = "https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ",

    -- [5] File System
    KeyFileName     = "Mykey.txt",

    -- [6] GUI Management
    OldGuiName      = "Koyle Hub",
    MainGuiName     = "UltimateAdmin_v80", -- Correspond au nom réel de la ScreenGui de ton Hub

    -- [7] Hub Information & UI Text
    HubName         = "Koyle Hub",
    HubDescription  = "Koyle Hub // Universal Script (EASY key system)"
}

-------------------------------------------------------------------------------
--! LIBRARIES (JSON & CRYPTOGRAPHY)
-------------------------------------------------------------------------------
local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;local function lshift(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
local lEncode, lDecode, lDigest = a3, aw, Z;

-------------------------------------------------------------------------------
--! CORE FUNCTIONS (REQUESTS & VERIFICATION)
-------------------------------------------------------------------------------

local useNonce = true 

local function safeRequest(options)
    local req = request or http_request or syn_request or (http and http.request )
    if not req then return nil, "HTTP requests not supported" end
    local success, response = pcall(function() return req(options) end)
    if success and type(response) == "table" then 
        return response 
    else 
        return nil, "Connection Error: " .. tostring(response or "Unknown") 
    end
end

local fSetClipboard = setclipboard or toclipboard or function() end
local fStringChar, fToString, fOsTime, fMathRandom, fMathFloor = string.char, tostring, os.time, math.random, math.floor
local fGetHwid = gethwid or function() return game:GetService("RbxAnalyticsService"):GetClientId() end

local cachedLink, cachedTime = "", 0
local host = "https://api.platoboost.com"

local function checkConnectivity( )
    local response, err = safeRequest({Url = host .. "/public/connectivity", Method = "GET"})
    if not response or (response.StatusCode ~= 200 and response.StatusCode ~= 429) then
        host = "https://api.platoboost.net"
        local fallbackResponse, fallbackErr = safeRequest({Url = host .. "/public/connectivity", Method = "GET"})
        if not fallbackResponse then
            return false 
        end
    end
    return true
end

local function generateNonce()
    local str = ""
    for _ = 1, 16 do str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97) end
    return str
end

local function cacheLink()
    local isConnected = checkConnectivity()
    if not isConnected then
        return false, "Delta/Network Error! Use VPN or change Executor."
    end
    
    if cachedTime + (10*60) < fOsTime() then
        local response, err = safeRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({service = Config.ServiceId, identifier = lDigest(fGetHwid())}),
            Headers = {["Content-Type"] = "application/json"}
        })
        if response and response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            end
        end
        return false, err or "Server Unreachable"
    end
    return true, cachedLink
end

-- Résultat de la vérification : ok, message, kind
--   "valid"   : clé acceptée par le serveur
--   "invalid" : clé refusée par le serveur (la clé sauvegardée est oubliée)
--   "offline" : serveur injoignable / erreur HTTP (une clé validée récemment reste utilisable)
--   "error"   : réponse inattendue ou vérification d'intégrité échouée (rien n'est cru)
local function redeemKey(key)
    local nonce = generateNonce()
    local body = {identifier = lDigest(fGetHwid()), key = key}
    if useNonce then body.nonce = nonce end

    local response, err = safeRequest({
        Url = host .. "/public/redeem/" .. fToString(Config.ServiceId),
        Method = "POST",
        Body = lEncode(body),
        Headers = {["Content-Type"] = "application/json"}
    })

    if not response then
        return false, "Server unreachable: " .. tostring(err), "offline"
    end
    if response.StatusCode == 429 then
        return false, "Too many attempts, wait a moment and retry", "offline"
    end
    if response.StatusCode ~= 200 then
        return false, "Server error (HTTP " .. tostring(response.StatusCode) .. ")", "offline"
    end

    local okDecode, decoded = pcall(lDecode, response.Body)
    if not okDecode or type(decoded) ~= "table" then
        return false, "Invalid server response", "error"
    end
    if not (decoded.success and decoded.data and decoded.data.valid) then
        return false, tostring(decoded.message or "Invalid key"), "invalid"
    end
    if useNonce and decoded.data.hash ~= lDigest("true-" .. nonce .. "-" .. Config.PlatoSecret) then
        return false, "Integrity check failed", "error"
    end
    return true, "Success", "valid"
end

-------------------------------------------------------------------------------
--! SAVED KEY (mémorisée entre les sessions)
-------------------------------------------------------------------------------
-- Fichier JSON : {"key": "...", "verified": <timestamp de la dernière validation réussie>}
local OFFLINE_GRACE = 3 * 24 * 60 * 60 -- lancement hors ligne toléré 3 jours après la dernière validation

local function loadSavedKey()
    local raw = nil
    pcall(function()
        if type(isfile) == "function" and type(readfile) == "function" and isfile(Config.KeyFileName) then
            raw = readfile(Config.KeyFileName)
        end
    end)
    if type(raw) == "string" and raw:match("%S") then
        local okDecode, data = pcall(lDecode, raw)
        if okDecode and type(data) == "table" and type(data.key) == "string" then
            return { key = data.key, verified = tonumber(data.verified) or 0 }
        end
        -- Ancien format : le fichier contenait seulement la clé
        return { key = (raw:gsub("%s+", "")), verified = 0 }
    end
    -- Secours pour la même session si le système de fichiers ne répond pas
    local cache = _G.KoyleKeyCache
    if type(cache) == "table" and type(cache.key) == "string" then
        return cache
    end
    return nil
end

local function saveKey(key, verified)
    local record = { key = key, verified = verified }
    _G.KoyleKeyCache = record
    if type(writefile) == "function" then
        pcall(writefile, Config.KeyFileName, lEncode(record))
    end
end

local function forgetKey()
    _G.KoyleKeyCache = nil
    pcall(function()
        if type(delfile) == "function" and type(isfile) == "function" and isfile(Config.KeyFileName) then
            delfile(Config.KeyFileName)
        elseif type(writefile) == "function" then
            writefile(Config.KeyFileName, "")
        end
    end)
end

-------------------------------------------------------------------------------
--! GUI & MAIN SCRIPT EXECUTION
-------------------------------------------------------------------------------

local function StartMainScript()
    local player = game:GetService("Players").LocalPlayer
    local pGui = player:WaitForChild("PlayerGui")
    
    if pGui:FindFirstChild(Config.OldGuiName) then 
        pGui[Config.OldGuiName]:Destroy() 
        task.wait(0.1)
    end
    
    _G[Config.Secret] = true

    -- Téléchargement du script principal (avec vérification)
    local okGet, source = pcall(function() return game:HttpGet(Config.MainScriptURL) end)
    if not okGet or type(source) ~= "string" or source == "" then
        return false, "Download failed: " .. tostring(source)
    end
    if source:sub(1, 3) == "404" then
        return false, "Main script not found (404). Check MainScriptURL."
    end

    local mainFn, compileErr = loadstring(source)
    if not mainFn then
        return false, "Script error: " .. tostring(compileErr)
    end

    local okRun, runErr = xpcall(mainFn, function(e)
        return tostring(e) .. "\n" .. debug.traceback()
    end)
    if not okRun then
        warn("[Koyle Key System] Main script error:\n" .. tostring(runErr))
        -- Si le hub s'est quand même affiché, l'erreur n'est pas bloquante
        local pGui2 = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
        if pGui2 and pGui2:FindFirstChild(Config.MainGuiName) then
            return true
        end
        local firstLine = tostring(runErr):match("^[^\n]+") or tostring(runErr)
        return false, "Runtime error: " .. firstLine
    end
    return true
end

-------------------------------------------------------------------------------
--! BRICK UI STYLE (même design que le hub)
-------------------------------------------------------------------------------
local BRICK = {
    Blue       = Color3.fromRGB(36, 132, 226),
    BlueLight  = Color3.fromRGB(64, 163, 245),
    BlueDark   = Color3.fromRGB(20, 82, 168),
    BlueDeep   = Color3.fromRGB(16, 62, 138),
    Stud       = Color3.fromRGB(96, 178, 250),
    Orange     = Color3.fromRGB(255, 138, 22),
    OrangeDark = Color3.fromRGB(196, 86, 0),
    Green      = Color3.fromRGB(86, 204, 42),
    GreenDark  = Color3.fromRGB(36, 132, 18),
    Red        = Color3.fromRGB(238, 64, 64),
    RedDark    = Color3.fromRGB(160, 28, 36),
    Text       = Color3.fromRGB(255, 255, 255),
    TextSoft   = Color3.fromRGB(205, 230, 255),
    TextStroke = Color3.fromRGB(12, 52, 118),
    Success    = Color3.fromRGB(150, 255, 110),
    Error      = Color3.fromRGB(255, 120, 120),
    Warning    = Color3.fromRGB(255, 200, 90),
}
local BRICK_FONT = Enum.Font.FredokaOne

local function brickText(label, size, color)
    label.Font = BRICK_FONT
    label.TextColor3 = color or BRICK.Text
    if size then label.TextSize = size end
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    s.Color = BRICK.TextStroke
    s.Thickness = 1.5
    s.Parent = label
end

local function brickify(gui, color, edgeColor, radius, edgeThickness)
    gui.BackgroundColor3 = color
    gui.BackgroundTransparency = 0
    gui.BorderSizePixel = 0
    Instance.new("UICorner", gui).CornerRadius = UDim.new(0, radius or 8)
    local edge = Instance.new("UIStroke")
    edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    edge.Color = edgeColor or BRICK.BlueDark
    edge.Thickness = edgeThickness or 3
    edge.Parent = gui
    local shade = Instance.new("UIGradient")
    shade.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(198, 204, 216))
    shade.Rotation = 90
    shade.Parent = gui
end

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
    grid.CellSize = UDim2.fromOffset(8, 8)
    grid.CellPadding = UDim2.fromOffset(18, 18)
    for _ = 1, math.ceil(width / 26) * math.ceil(height / 26) do
        local stud = Instance.new("Frame")
        stud.BorderSizePixel = 0
        stud.BackgroundColor3 = BRICK.Stud
        stud.BackgroundTransparency = 0.2
        stud.ZIndex = 0
        Instance.new("UICorner", stud).CornerRadius = UDim.new(1, 0)
        stud.Parent = layer
    end
    layer.Parent = frame
end

local function brickButton(parent, text, color, edgeColor)
    local b = Instance.new("TextButton", parent)
    b.Text = text
    b.AutoButtonColor = false
    brickify(b, color, edgeColor, 8, 3)
    brickText(b, 15)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.18) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = color end)
    return b
end

local function CreateGUI()
    local player = game:GetService("Players").LocalPlayer
    local coreGui = game:GetService("CoreGui")
    local targetParent = pcall(function() return coreGui end) and coreGui or player:WaitForChild("PlayerGui")
    
    if targetParent:FindFirstChild("OYB_KeySystem") then targetParent.OYB_KeySystem:Destroy() end

    local ScreenGui = Instance.new("ScreenGui", targetParent)
    ScreenGui.Name = "OYB_KeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local PANEL_W = 340
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, PANEL_W, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
    MainFrame.Active = true;
    MainFrame.Draggable = true
    brickify(MainFrame, BRICK.Blue, BRICK.BlueDark, 12, 4)

    -- Barre de titre orange (style "LOGIN")
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -66, 0, 42)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.Text = string.upper(Config.HubName)
    brickify(Title, BRICK.Orange, BRICK.OrangeDark, 8, 3)
    brickText(Title, 20)

    -- Bouton fermer : icône rouge ✕
    local CloseBtn = Instance.new("TextButton", MainFrame)
    CloseBtn.Size = UDim2.new(0, 42, 0, 42)
    CloseBtn.Position = UDim2.new(1, -52, 0, 10)
    CloseBtn.Text = "X"
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 10
    brickify(CloseBtn, BRICK.Red, BRICK.RedDark, 8, 3)
    brickText(CloseBtn, 20)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local PromoText = Instance.new("TextLabel", MainFrame)
    PromoText.Size = UDim2.new(0.9, 0, 0, 44)
    PromoText.Position = UDim2.new(0.05, 0, 0, 58)
    PromoText.BackgroundTransparency = 1
    PromoText.Text = Config.HubDescription
    PromoText.TextWrapped = true
    brickText(PromoText, 15)

    local currentYOffset = 108

    local function addSocialButton(text, color, edgeColor, iconId, onClick)
        local btn = brickButton(MainFrame, "      " .. text, color, edgeColor)
        btn.Size = UDim2.new(0.85, 0, 0, 36)
        btn.Position = UDim2.new(0.075, 0, 0, currentYOffset)
        btn.TextSize = 14

        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0.1, 0, 0.5, -10)
        icon.BackgroundTransparency = 1
        icon.Image = iconId

        btn.MouseButton1Click:Connect(onClick)
        currentYOffset = currentYOffset + 46
    end

    if Config.ShowDiscord then
        addSocialButton("JOIN DISCORD", Color3.fromRGB(88, 101, 242), Color3.fromRGB(52, 60, 170), "rbxassetid://18505728201", function()
            fSetClipboard(Config.DiscordURL)
            local Status = MainFrame:FindFirstChild("StatusLabel")
            if Status then 
                Status.Text = "Discord Link Copied!"
                Status.TextColor3 = BRICK.TextSoft
            end
            local inviteCode = string.match(Config.DiscordURL, "discord%.gg/([%w-]+)")
            if syn and syn.request and inviteCode then
                syn.request({Url = "http://localhost:1111/discord?invite=" .. inviteCode, Method = "GET"})
            end
        end)
    end

    if Config.ShowInstagram then
        addSocialButton("FOLLOW INSTAGRAM", Color3.fromRGB(225, 48, 108), Color3.fromRGB(150, 20, 70), "rbxassetid://18355586382", function()
            fSetClipboard(Config.InstagramURL)
            local Status = MainFrame:FindFirstChild("StatusLabel")
            if Status then 
                Status.Text = "Instagram Link Copied!"
                Status.TextColor3 = BRICK.TextSoft
            end
        end)
    end
    
    if Config.ShowYoutube then
        addSocialButton("SUBSCRIBE YOUTUBE", Color3.fromRGB(235, 30, 30), Color3.fromRGB(150, 10, 10), "rbxassetid://82532989017804", function()
            fSetClipboard(Config.YoutubeURL)
            local Status = MainFrame:FindFirstChild("StatusLabel")
            if Status then
                Status.Text = "YouTube Link Copied!"
                Status.TextColor3 = BRICK.TextSoft
            end
        end)
    end

    -- Champ de clé : pilule bleu foncé (style "PASSWORD")
    local KeyInput = Instance.new("TextBox", MainFrame)
    KeyInput.Size = UDim2.new(0.85, 0, 0, 42)
    KeyInput.Position = UDim2.new(0.075, 0, 0, currentYOffset + 12)
    KeyInput.PlaceholderText = "ENTER KEY..."
    KeyInput.PlaceholderColor3 = BRICK.TextSoft
    KeyInput.Text = ""
    KeyInput.ClearTextOnFocus = false
    brickify(KeyInput, BRICK.BlueDeep, BRICK.BlueDark, 21, 3)
    brickText(KeyInput, 15)

    -- VERIFY = brique verte (style "OK"), GET KEY = brique orange
    local VerifyBtn = brickButton(MainFrame, "VERIFY", BRICK.Green, BRICK.GreenDark)
    VerifyBtn.Size = UDim2.new(0.4, 0, 0, 42)
    VerifyBtn.Position = UDim2.new(0.075, 0, 0, currentYOffset + 66)

    local GetKeyBtn = brickButton(MainFrame, "GET KEY", BRICK.Orange, BRICK.OrangeDark)
    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 42)
    GetKeyBtn.Position = UDim2.new(0.525, 0, 0, currentYOffset + 66)

    local Status = Instance.new("TextLabel", MainFrame)
    Status.Name = "StatusLabel"
    Status.Size = UDim2.new(0.9, 0, 0, 34)
    Status.Position = UDim2.new(0.05, 0, 0, currentYOffset + 116)
    Status.BackgroundTransparency = 1
    Status.Text = "Waiting for input..."
    Status.TextWrapped = true
    brickText(Status, 13, BRICK.TextSoft)
    
    local panelH = currentYOffset + 160
    MainFrame.Size = UDim2.new(0, PANEL_W, 0, panelH)
    addStuds(MainFrame, PANEL_W, panelH)

    -- Une seule vérification à la fois : évite de lancer le hub deux fois
    local busy = false

    local function setStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or BRICK.TextSoft
    end

    local function launchHub()
        setStatus("Loading script...", BRICK.Success)
        local ok, err = StartMainScript()
        if ok then
            ScreenGui:Destroy()
        else
            busy = false
            setStatus(tostring(err), BRICK.Error)
            if setclipboard or toclipboard then
                pcall(setclipboard or toclipboard, tostring(err))
                setStatus(tostring(err) .. " (copied)", BRICK.Error)
            end
        end
    end

    -- saved : enregistrement précédent (ou nil), sert au mode hors ligne
    local function verify(key, saved)
        if busy then return end
        busy = true
        setStatus("Verifying...", BRICK.TextSoft)

        local ok, msg, kind = redeemKey(key)
        if ok then
            saveKey(key, os.time())
            setStatus("Success! Loading...", BRICK.Success)
            task.wait(0.3)
            launchHub()
            return
        end

        local isSavedKey = saved ~= nil and saved.key == key
        if kind == "offline" and isSavedKey and saved.verified > 0
            and (os.time() - saved.verified) < OFFLINE_GRACE then
            setStatus("Server unreachable, using your saved key (offline)", BRICK.Warning)
            task.wait(0.5)
            launchHub()
            return
        end

        if kind == "invalid" and isSavedKey then
            forgetKey()
        end
        busy = false
        setStatus(msg, BRICK.Error)
    end

    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text:match("^%s*(.-)%s*$")
        if key == "" then
            setStatus("Enter a key!", BRICK.Warning)
            return
        end
        task.spawn(verify, key, loadSavedKey())
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        setStatus("Getting Link...", BRICK.TextSoft)
        local success, link = cacheLink()
        if success then
            fSetClipboard(link)
            setStatus("Link Copied!", BRICK.Success)
        else
            setStatus(tostring(link), BRICK.Error)
        end
    end)

    -- Connexion automatique avec la clé mémorisée
    local saved = loadSavedKey()
    if saved and saved.key ~= "" then
        setStatus("Found saved key, checking...", BRICK.TextSoft)
        task.spawn(verify, saved.key, saved)
    end
end

-- Permet au hub (option "Reset Key") de réafficher la page de clé
_G.KoyleKeySystem_Show = CreateGUI

local player = game:GetService("Players").LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- Le hub est déjà ouvert : on ne le recharge pas (évite deux hubs superposés)
if pGui:FindFirstChild(Config.MainGuiName) then
    warn("[Koyle Key System] Hub already running.")
    return
end

CreateGUI()
