--[[
  ╔═══════════════════════════════════════════════════════════╗
  ║                    XYRO ENGINE V5                         ║
  ║                Made with love by kore                     ║
  ╚═══════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════
local Players  = game:GetService("Players")
local RunSvc   = game:GetService("RunService")
local TweenSvc = game:GetService("TweenService")
local UIS      = game:GetService("UserInputService")
local RepStor  = game:GetService("ReplicatedStorage")
local Http     = game:GetService("HttpService")
local CoreGui  = game:GetService("CoreGui")
local lp       = Players.LocalPlayer

local clock = os.clock
local wait = task.wait
local spawn = task.spawn
local insert = table.insert
local remove = table.remove
local find = table.find
local floor = math.floor
local clamp = math.clamp
local random = math.random
local abs = math.abs

-- ════════════════════════════════════════════════════════════
-- THEME
-- ════════════════════════════════════════════════════════════
local T = {
    BG      = Color3.fromRGB(8,8,10),
    CARD    = Color3.fromRGB(22,22,27),
    RAISED  = Color3.fromRGB(32,32,38),
    BORDER  = Color3.fromRGB(50,50,60),
    TEXT    = Color3.fromRGB(242,242,242),
    MUTED   = Color3.fromRGB(138,138,148),
    DIM     = Color3.fromRGB(68,68,80),
    ACCENT  = Color3.fromRGB(138,180,248),
    ON      = Color3.fromRGB(120,220,120),
    OFF     = Color3.fromRGB(50,50,60),
    WARN    = Color3.fromRGB(200,185,120),
    ERR     = Color3.fromRGB(200,80,80),
}

-- ════════════════════════════════════════════════════════════
-- SAVE
-- ════════════════════════════════════════════════════════════
local SAVE = {}
local SAVE_FILE = "xyro_v1.json"
pcall(function()
    if readfile then
        local ok,d = pcall(function() return Http:JSONDecode(readfile(SAVE_FILE)) end)
        if ok and type(d)=="table" then for k,v in pairs(d) do SAVE[k]=v end end
    end
end)
local function DoSave()
    pcall(function() if writefile then writefile(SAVE_FILE,Http:JSONEncode(SAVE)) end end)
end

SAVE.kaRange      = SAVE.kaRange      or 25
SAVE.kaAPS        = SAVE.kaAPS        or 5000
SAVE.hbSize       = SAVE.hbSize       or 12
SAVE.rpSpeed      = SAVE.rpSpeed      or 8
SAVE.strafeRadius = SAVE.strafeRadius or 10
SAVE.strafeSpeed  = SAVE.strafeSpeed  or 4
SAVE.strafeOffset = SAVE.strafeOffset or -2
SAVE.orbRadius    = SAVE.orbRadius    or 10
SAVE.orbSpeed     = SAVE.orbSpeed     or 5
SAVE.orbHeight    = SAVE.orbHeight    or 2
SAVE.tpwSpeed     = SAVE.tpwSpeed     or 6
SAVE.arcDefDelay  = SAVE.arcDefDelay  or 0.1
SAVE.arcGrabDelay = SAVE.arcGrabDelay or 3.5
SAVE.friends      = SAVE.friends      or ""
SAVE.targets      = SAVE.targets      or ""
SAVE.agTarget     = SAVE.agTarget     or ""
SAVE.ggTarget     = SAVE.ggTarget     or ""
SAVE.strafeTarget = SAVE.strafeTarget or ""
SAVE.orbTarget    = SAVE.orbTarget    or ""
SAVE.hsTarget     = SAVE.hsTarget     or ""
SAVE.keybinds     = SAVE.keybinds     or {}
SAVE.configs      = SAVE.configs      or {}
SAVE.toggleKey    = SAVE.toggleKey    or "Insert"
SAVE.safeX        = SAVE.safeX        or 0
SAVE.safeY        = SAVE.safeY        or 100
SAVE.safeZ        = SAVE.safeZ        or 0
SAVE.flySpeed     = SAVE.flySpeed     or 80
SAVE.tpHitTarget  = SAVE.tpHitTarget  or ""
SAVE.tpHitRange   = SAVE.tpHitRange   or 35
SAVE.phrases      = SAVE.phrases      or "XYRO ON TOP!"
SAVE.bioTypeSpeed = SAVE.bioTypeSpeed or 15
SAVE.nameTypewriter = SAVE.nameTypewriter or false
SAVE.kaPredict    = SAVE.kaPredict    or true

-- ════════════════════════════════════════════════════════════
-- CONNECTION MANAGER
-- ════════════════════════════════════════════════════════════
local CONNS = {}
local function TC(c) if c then insert(CONNS,c) end; return c end

-- ════════════════════════════════════════════════════════════
-- FRIENDS / TARGETS
-- ════════════════════════════════════════════════════════════
local FriendsList, TargetsList = {}, {}
local function parseFriends(s)
    FriendsList={}; for w in (s or ""):gmatch("%S+") do insert(FriendsList,w:lower()) end
end
local function parseTargets(s)
    TargetsList={}; for w in (s or ""):gmatch("%S+") do insert(TargetsList,w:lower()) end
end
parseFriends(SAVE.friends); parseTargets(SAVE.targets)

local function isFriend(p)
    local n,dn = p.Name:lower(), p.DisplayName:lower()
    for _,f in ipairs(FriendsList) do if n:find(f,1,true) or dn:find(f,1,true) then return true end end
    return false
end
local function isTarget(p)
    if p==lp then return false end
    if isFriend(p) then return false end
    if #TargetsList==0 then return true end
    local n,dn = p.Name:lower(), p.DisplayName:lower()
    for _,t in ipairs(TargetsList) do if n:find(t,1,true) or dn:find(t,1,true) then return true end end
    return false
end
local function findPlayer(name)
    if not name or name=="" then return nil end
    local nl=name:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and (p.Name:lower()==nl or p.DisplayName:lower()==nl) then return p end
    end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=lp and (p.Name:lower():find(nl,1,true) or p.DisplayName:lower():find(nl,1,true)) then return p end
    end
    return nil
end

local SAFE_CF = CFrame.new(SAVE.safeX, SAVE.safeY, SAVE.safeZ)

-- ════════════════════════════════════════════════════════════
-- REMOTES
-- ════════════════════════════════════════════════════════════
local RF = {}
spawn(function()
    local waited = 0
    repeat wait(0.5); waited += 0.5 until waited >= 3 or game:IsLoaded()
    wait(1)
    pcall(function()
        local cs = RepStor:WaitForChild("Packages",10)
            :WaitForChild("Knit",10)
            :WaitForChild("Services",10)
            :WaitForChild("CombatService",10)
            :WaitForChild("RF",10)
        RF.Hit    = cs:WaitForChild("Hit",10)
        RF.PunchDo= cs:WaitForChild("PunchDo",10)
        RF.Block  = cs:WaitForChild("Block",10)
        RF.Grab   = cs:WaitForChild("Grab",10)
    end)
    pcall(function()
        local rem = RepStor:WaitForChild("Remotes",10)
        RF.UpdateBio      = rem:WaitForChild("UpdateBio",10)
        RF.UpdateBioColor = rem:WaitForChild("UpdateBioColor",10)
        RF.UpdateRPColor  = rem:WaitForChild("UpdateRPColor",10)
        RF.UpdateRPName   = rem:WaitForChild("UpdateRPName",10)
    end)
end)

-- ════════════════════════════════════════════════════════════
-- GUI
-- ════════════════════════════════════════════════════════════
pcall(function() local o=CoreGui:FindFirstChild("XYRO_v45_ultra"); if o then o:Destroy() end end)
local GUI = Instance.new("ScreenGui")
GUI.Name="XYRO_v45_ultra"; GUI.ResetOnSpawn=false
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset=true; GUI.Parent=CoreGui

local Bold = Font.new("rbxasset://fonts/families/Montserrat.json",Enum.FontWeight.Bold)
local Semi = Font.new("rbxasset://fonts/families/Montserrat.json",Enum.FontWeight.SemiBold)
local Reg  = Font.new("rbxasset://fonts/families/Montserrat.json",Enum.FontWeight.Regular)

-- ════════════════════════════════════════════════════════════
-- UI HELPERS
-- ════════════════════════════════════════════════════════════
local function Cnr(p,r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 8); return c end
local function Strk(p,col,thick,tr)
    local s=Instance.new("UIStroke",p); s.Color=col or T.BORDER; s.Thickness=thick or 1; s.Transparency=tr or 0; return s
end
local function LL(p,pad,dir)
    local l=Instance.new("UIListLayout",p); l.Padding=UDim.new(0,pad or 6)
    l.SortOrder=Enum.SortOrder.LayoutOrder
    if dir then l.FillDirection=dir end; return l
end
local function LP(p,l,r,t2,b)
    local u=Instance.new("UIPadding",p)
    u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0)
    u.PaddingTop=UDim.new(0,t2 or 0); u.PaddingBottom=UDim.new(0,b or 0)
end

local tweenCache = {}
local function Tw(obj,props,time,style,dir)
    local key = tostring(obj)
    if tweenCache[key] then tweenCache[key]:Cancel() end
    local tw = TweenSvc:Create(obj,TweenInfo.new(time or 0.15,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out),props)
    tweenCache[key] = tw
    tw:Play()
    tw.Completed:Connect(function() tweenCache[key] = nil end)
    return tw
end

local function MkLabel(parent,p)
    local l=Instance.new("TextLabel",parent); l.BackgroundTransparency=1
    l.FontFace=p.font or Reg; l.TextSize=p.size or 11; l.TextColor3=p.color or T.TEXT
    l.Text=p.text or ""; l.Size=p.sz or UDim2.new(1,0,0,16); l.Position=p.pos or UDim2.new(0,0,0,0)
    l.TextXAlignment=p.xa or Enum.TextXAlignment.Left; l.TextYAlignment=p.ya or Enum.TextYAlignment.Center
    l.TextWrapped=p.wrap or false; l.ZIndex=p.z or 14; return l
end

-- ════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ════════════════════════════════════════════════════════════
local NotifHolder=Instance.new("Frame",GUI)
NotifHolder.Size=UDim2.new(0,290,1,0); NotifHolder.Position=UDim2.new(1,-304,0,12)
NotifHolder.BackgroundTransparency=1; NotifHolder.BorderSizePixel=0; NotifHolder.ZIndex=9000
local _notifs={}; local NH=62; local NG=6

local function _restack()
    local y=0
    for _,f in ipairs(_notifs) do
        if f and f.Parent then Tw(f,{Position=UDim2.new(0,0,0,y)},0.2,Enum.EasingStyle.Back); y=y+NH+NG end
    end
end

local function Notif(title,body,ntype)
    local acc=(ntype=="ok" and Color3.fromRGB(100,255,150)) or (ntype=="warn" and T.WARN) or (ntype=="err" and T.ERR) or T.ACCENT
    local icon=(ntype=="ok" and "✓") or (ntype=="warn" and "⚠") or (ntype=="err" and "✕") or "•"
    local y=#_notifs*(NH+NG)
    
    local f=Instance.new("Frame",NotifHolder); f.Size=UDim2.new(1,0,0,NH); f.Position=UDim2.new(1,20,0,y)
    f.BackgroundColor3=T.CARD; f.BackgroundTransparency=0.04; f.BorderSizePixel=0; f.ZIndex=9001; Cnr(f,10); Strk(f,acc,1.8,0.1)
    
    local acbar=Instance.new("Frame",f); acbar.Size=UDim2.new(0,4,0,40); acbar.Position=UDim2.new(0,0,0.5,-20)
    acbar.BackgroundColor3=acc; acbar.BorderSizePixel=0; Cnr(acbar,2)
    
    MkLabel(f,{text=icon,size=14,color=acc,font=Bold,sz=UDim2.new(0,28,1,0),pos=UDim2.new(0,10,0,0),xa=Enum.TextXAlignment.Center,z=9002})
    MkLabel(f,{text=title,size=11,color=T.TEXT,font=Bold,sz=UDim2.new(1,-42,0,18),pos=UDim2.new(0,40,0,10),z=9002})
    MkLabel(f,{text=body or "",size=9,color=T.MUTED,font=Reg,sz=UDim2.new(1,-42,0,20),pos=UDim2.new(0,40,0,32),wrap=true,z=9002})
    
    local pb=Instance.new("Frame",f); pb.Size=UDim2.new(1,0,0,3); pb.Position=UDim2.new(0,0,1,-3)
    pb.BackgroundColor3=acc; pb.BackgroundTransparency=0.3; pb.BorderSizePixel=0
    TweenSvc:Create(pb,TweenInfo.new(4.5,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,0,3)}):Play()
    
    local rb=Instance.new("TextButton",f); rb.Size=UDim2.new(1,0,1,0); rb.BackgroundTransparency=1; rb.Text=""; rb.ZIndex=9003
    insert(_notifs,f)
    
    Tw(f,{Position=UDim2.new(0,0,0,y)},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    
    local function dismiss()
        local idx=find(_notifs,f); if idx then remove(_notifs,idx) end
        Tw(f,{Position=UDim2.new(1,20,0,f.Position.Y.Offset),BackgroundTransparency=1},0.2)
        task.delay(0.22,function() pcall(function() f:Destroy() end) end); task.delay(0.05,_restack)
    end
    rb.MouseButton1Click:Connect(dismiss); task.delay(4.6,function() if f and f.Parent then dismiss() end end)
end

-- ════════════════════════════════════════════════════════════
-- KEYBINDS
-- ════════════════════════════════════════════════════════════
local KEYBINDS={}
local _kbListening=false; local _kbCb=nil
local function RegKB(action,defaultKey,callback)
    local saved=SAVE.keybinds[action]
    local key=defaultKey
    if saved then local ok,kc=pcall(function() return Enum.KeyCode[saved] end); if ok and kc then key=kc end end
    for _,kb in ipairs(KEYBINDS) do
        if kb.action==action then kb.callback=callback; kb.key=key; return kb end
    end
    local kb={action=action,key=key,callback=callback}
    insert(KEYBINDS,kb); return kb
end
TC(UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if _kbListening and _kbCb and i.UserInputType==Enum.UserInputType.Keyboard then
        _kbCb(i.KeyCode); _kbListening=false; _kbCb=nil; return
    end
    if i.UserInputType==Enum.UserInputType.Keyboard then
        for _,kb in ipairs(KEYBINDS) do if kb.key==i.KeyCode and kb.callback then pcall(kb.callback) end end
    end
end))

-- ════════════════════════════════════════════════════════════
-- COMPONENT FACTORIES
-- ════════════════════════════════════════════════════════════
local function MkCard(parent,h,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,h or 52); f.BackgroundColor3=T.CARD
    f.BackgroundTransparency=0.06; f.BorderSizePixel=0; f.LayoutOrder=order or 0; f.ClipsDescendants=true
    Cnr(f,10); Strk(f,T.BORDER,1,0.45); return f
end

local function MkSep(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,16); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    MkLabel(f,{text=text:upper(),size=8,color=T.DIM,font=Bold,sz=UDim2.new(1,0,1,0),z=14}); return f
end

local function MkToggle(parent,label,order,onEn,onDis)
    local card=MkCard(parent,52,order)
    MkLabel(card,{text=label:upper(),size=9,color=T.TEXT,font=Semi,sz=UDim2.new(1,-68,0,18),pos=UDim2.new(0,16,0.5,-9),z=14})
    
    local track=Instance.new("TextButton",card)
    track.Size=UDim2.new(0,42,0,20); track.Position=UDim2.new(1,-54,0.5,-10)
    track.BackgroundColor3=T.RAISED; track.BackgroundTransparency=0.1; track.Text=""
    track.AutoButtonColor=false; track.BorderSizePixel=0; track.ZIndex=15; Cnr(track,11); Strk(track,T.BORDER,1,0.4)
    
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,14,0,14); thumb.Position=UDim2.new(0,3,0.5,-7)
    thumb.BackgroundColor3=T.OFF; thumb.BorderSizePixel=0; thumb.ZIndex=16; Cnr(thumb,9)
    
    local state=false
    local function Set(s,silent)
        state=s
        local dc=s and T.ON or T.OFF
        local dp=s and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        local tc=s and Color3.fromRGB(35,45,55) or T.RAISED
        
        if silent then
            thumb.Position=dp; thumb.BackgroundColor3=dc; track.BackgroundColor3=tc
        else
            Tw(thumb,{Position=dp,BackgroundColor3=dc},0.25,Enum.EasingStyle.Back)
            Tw(track,{BackgroundColor3=tc},0.18)
        end
    end
    
    track.MouseButton1Click:Connect(function()
        local s=not state; Set(s); if s then onEn() else onDis() end
    end)
    
    track.MouseEnter:Connect(function() Tw(track,{BackgroundTransparency=0.05},0.1) end)
    track.MouseLeave:Connect(function() Tw(track,{BackgroundTransparency=0.1},0.1) end)
    
    return card,function() return state end,Set
end

local function MkSlider(parent,label,minV,maxV,defV,order,onChange)
    local d=clamp(defV or minV,minV,maxV)
    local pct0=(maxV==minV) and 0 or (d-minV)/(maxV-minV)
    
    local card=MkCard(parent,62,order)
    MkLabel(card,{text=label:upper(),size=8,color=T.DIM,font=Bold,sz=UDim2.new(1,-85,0,12),pos=UDim2.new(0,16,0,8),z=14})
    
    local valL=MkLabel(card,{text=tostring(d),size=14,color=T.ACCENT,font=Bold,sz=UDim2.new(0,65,0,16),pos=UDim2.new(1,-78,0,8),xa=Enum.TextXAlignment.Right,z=14})
    
    local track=Instance.new("Frame",card); track.Size=UDim2.new(1,-32,0,6); track.Position=UDim2.new(0,16,0,40)
    track.BackgroundColor3=T.RAISED; track.BackgroundTransparency=0.22; track.BorderSizePixel=0; Cnr(track,3)
    
    local fill=Instance.new("Frame",track); fill.Size=UDim2.new(pct0,0,1,0); fill.BackgroundColor3=T.ACCENT
    fill.BackgroundTransparency=0; fill.BorderSizePixel=0; Cnr(fill,3)
    
    local thumb=Instance.new("Frame",track); thumb.Size=UDim2.new(0,16,0,16); thumb.Position=UDim2.new(pct0,-8,0.5,-8)
    thumb.BackgroundColor3=T.TEXT; thumb.BorderSizePixel=0; Cnr(thumb,8); thumb.ZIndex=15
    
    local glow=Strk(thumb,T.ACCENT,2,0.7)
    
    local dz=Instance.new("TextButton",card); dz.Size=UDim2.new(1,0,0,42); dz.Position=UDim2.new(0,0,0,20)
    dz.BackgroundTransparency=1; dz.Text=""; dz.AutoButtonColor=false; dz.ZIndex=16
    
    local dragging=false; local touchX=nil
    
    dz.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; touchX=i.Position.X
            Tw(thumb,{Size=UDim2.new(0,18,0,18)},0.12)
            Tw(glow,{Transparency=0.3},0.12)
        end
    end)
    
    TC(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
            Tw(thumb,{Size=UDim2.new(0,16,0,16)},0.12)
            Tw(glow,{Transparency=0.7},0.12)
        end
    end))
    
    TC(UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            touchX=i.Position.X
        end
    end))
    
    TC(RunSvc.Heartbeat:Connect(function()
        if not dragging then return end
        local aw=track.AbsoluteSize.X; if aw<=0 then return end
        local mx=touchX or UIS:GetMouseLocation().X
        local p2=clamp((mx-track.AbsolutePosition.X)/aw,0,1)
        
        fill.Size=UDim2.new(p2,0,1,0); thumb.Position=UDim2.new(p2,-8,0.5,-8)
        local val=floor(minV+p2*(maxV-minV)+0.5); valL.Text=tostring(val)
        if onChange then onChange(val) end
    end))
    
    local function setVal(v)
        v=clamp(v,minV,maxV); local p2=(maxV==minV) and 0 or (v-minV)/(maxV-minV)
        fill.Size=UDim2.new(p2,0,1,0); thumb.Position=UDim2.new(p2,-8,0.5,-8); valL.Text=tostring(v)
    end
    
    return card,valL,setVal
end

local function MkTBoxCard(parent,topLabel,ph,order,default)
    local card=MkCard(parent,64,order)
    MkLabel(card,{text=topLabel:upper(),size=8,color=T.DIM,font=Bold,sz=UDim2.new(1,-32,0,12),pos=UDim2.new(0,16,0,8),z=14})
    
    local box=Instance.new("TextBox",card); box.Size=UDim2.new(1,-32,0,30); box.Position=UDim2.new(0,16,0,24)
    box.BackgroundColor3=T.RAISED; box.BackgroundTransparency=0.15; box.FontFace=Reg; box.TextSize=11
    box.TextColor3=T.TEXT; box.PlaceholderColor3=T.DIM; box.PlaceholderText=ph or ""; box.Text=default or ""
    box.ClearTextOnFocus=false; box.BorderSizePixel=0; box.TextXAlignment=Enum.TextXAlignment.Left; box.ZIndex=15; Cnr(box,7)
    
    local s=Strk(box,T.BORDER,1,0.35); LP(box,10,10,0,0)
    
    box.Focused:Connect(function()
        Tw(s,{Transparency=0,Color=T.ACCENT},0.15)
        Tw(box,{BackgroundTransparency=0.05},0.15)
    end)
    box.FocusLost:Connect(function()
        Tw(s,{Transparency=0.35,Color=T.BORDER},0.15)
        Tw(box,{BackgroundTransparency=0.15},0.15)
    end)
    
    return card,box
end

local function MkBtn(parent,p)
    local b=Instance.new("TextButton",parent)
    b.BackgroundColor3=p.bg or T.CARD; b.BackgroundTransparency=p.bgt or 0
    b.FontFace=p.font or Semi; b.TextSize=p.size or 11; b.TextColor3=p.color or T.TEXT
    b.Text=p.text or ""; b.Size=p.sz or UDim2.new(1,0,0,32); b.Position=p.pos or UDim2.new(0,0,0,0)
    b.AnchorPoint=p.anchor or Vector2.new(0,0); b.AutoButtonColor=false; b.BorderSizePixel=0
    b.LayoutOrder=p.order or 0; b.ZIndex=p.z or 14
    if p.corner~=false then Cnr(b,p.corner or 8) end
    
    b.MouseEnter:Connect(function() Tw(b,{BackgroundTransparency=math.max(0,(p.bgt or 0)-0.15)},0.12) end)
    b.MouseLeave:Connect(function() Tw(b,{BackgroundTransparency=p.bgt or 0},0.12) end)
    
    return b
end

local function MkKBRow(parent,action,order)
    local f=Instance.new("Frame",parent); f.Size=UDim2.new(1,0,0,32)
    f.BackgroundColor3=T.RAISED; f.BackgroundTransparency=0.18; f.BorderSizePixel=0; f.LayoutOrder=order; Cnr(f,7)
    
    MkLabel(f,{text=action,size=9,color=T.TEXT,font=Semi,sz=UDim2.new(1,-74,1,0),pos=UDim2.new(0,12,0,0),z=15})
    
    local bindBtn=MkBtn(f,{bg=T.CARD,text="—",size=8,color=T.MUTED,sz=UDim2.new(0,60,0,24),pos=UDim2.new(1,-64,0.5,-12),corner=5,bgt=0.08,z=16})
    
    local function refresh()
        for _,kb in ipairs(KEYBINDS) do
            if kb.action==action then
                bindBtn.Text=kb.key and tostring(kb.key):gsub("Enum.KeyCode.","") or "—"
                return
            end
        end
    end
    refresh()
    
    bindBtn.MouseButton1Click:Connect(function()
        bindBtn.Text="..."; bindBtn.TextColor3=T.ACCENT; _kbListening=true
        _kbCb=function(kc)
            SAVE.keybinds[action]=tostring(kc):gsub("Enum.KeyCode.","")
            for _,kb in ipairs(KEYBINDS) do if kb.action==action then kb.key=kc; break end end
            bindBtn.Text=tostring(kc):gsub("Enum.KeyCode.",""); bindBtn.TextColor3=T.MUTED
            task.delay(0.5,DoSave)
        end
    end)
    
    return f
end

-- ════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ════════════════════════════════════════════════════════════
local WW,WH = 760,580
local Win = Instance.new("Frame",GUI)
Win.Name="XYRO_Main"; Win.Size=UDim2.new(0,WW,0,WH)
Win.Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)
Win.BackgroundColor3=T.BG; Win.BackgroundTransparency=0.02
Win.BorderSizePixel=0; Win.ClipsDescendants=true; Win.ZIndex=10
Cnr(Win,16); Strk(Win,T.BORDER,1.4,0.25)

local WinBg=Instance.new("ImageLabel",Win)
WinBg.Size=UDim2.new(1,0,1,0); WinBg.BackgroundTransparency=1
WinBg.Image="rbxassetid://78240901898379"; WinBg.ImageTransparency=0.9
WinBg.ScaleType=Enum.ScaleType.Crop; WinBg.ZIndex=10; WinBg.BorderSizePixel=0; Cnr(WinBg,16)

local Header=Instance.new("Frame",Win)
Header.Size=UDim2.new(1,0,0,52); Header.BackgroundTransparency=1; Header.BorderSizePixel=0; Header.ZIndex=14

local logo=Instance.new("Frame",Header); logo.Size=UDim2.new(0,32,0,32); logo.Position=UDim2.new(0,16,0.5,-16)
logo.BackgroundColor3=T.RAISED; logo.BackgroundTransparency=0.05; logo.BorderSizePixel=0; Cnr(logo,8); Strk(logo,T.ACCENT,1.5,0.3)
MkLabel(logo,{text="X",size=16,color=T.ACCENT,font=Bold,sz=UDim2.new(1,0,1,0),xa=Enum.TextXAlignment.Center,z=14})

local TitleLbl=MkLabel(Header,{text="XYRO ENGINE",size=16,color=T.TEXT,font=Bold,sz=UDim2.new(0,140,0,22),pos=UDim2.new(0,56,0,12),z=14})
local VersionLbl=MkLabel(Header,{text="V5 - w love by kore 🖤",size=8,color=T.ACCENT,font=Reg,sz=UDim2.new(0,200,0,12),pos=UDim2.new(0,56,0,34),z=14})

local hdrHue=0
TC(RunSvc.RenderStepped:Connect(function(dt) hdrHue=(hdrHue+dt*0.3)%1; TitleLbl.TextColor3=Color3.fromHSV(hdrHue,0.8,1) end))

local CloseBtn=Instance.new("TextButton",Header)
CloseBtn.Size=UDim2.new(0,28,0,28); CloseBtn.Position=UDim2.new(1,-42,0.5,-14)
CloseBtn.BackgroundColor3=T.RAISED; CloseBtn.BackgroundTransparency=0.15; CloseBtn.Text="×"
CloseBtn.FontFace=Bold; CloseBtn.TextSize=16; CloseBtn.TextColor3=T.MUTED
CloseBtn.AutoButtonColor=false; CloseBtn.BorderSizePixel=0; CloseBtn.ZIndex=15; Cnr(CloseBtn,8)
CloseBtn.MouseEnter:Connect(function() Tw(CloseBtn,{BackgroundColor3=T.ERR,TextColor3=T.TEXT},0.14) end)
CloseBtn.MouseLeave:Connect(function() Tw(CloseBtn,{BackgroundColor3=T.RAISED,TextColor3=T.MUTED},0.14) end)
CloseBtn.MouseButton1Click:Connect(function() Win.Visible=false end)

local HDiv=Instance.new("Frame",Win)
HDiv.Size=UDim2.new(1,0,0,1); HDiv.Position=UDim2.new(0,0,0,52)
HDiv.BackgroundColor3=T.BORDER; HDiv.BackgroundTransparency=0.5; HDiv.BorderSizePixel=0; HDiv.ZIndex=14

do
    local dragging,dragStart,startPos=false,nil,nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=Win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            Win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

-- ════════════════════════════════════════════════════════════
-- SIDEBAR + CONTENT
-- ════════════════════════════════════════════════════════════
local SIDE_W=140; local BODY_Y=53

local Sidebar=Instance.new("ScrollingFrame",Win)
Sidebar.Size=UDim2.new(0,SIDE_W,0,WH-BODY_Y); Sidebar.Position=UDim2.new(0,0,0,BODY_Y)
Sidebar.BackgroundTransparency=1; Sidebar.BorderSizePixel=0; Sidebar.ScrollBarThickness=3
Sidebar.ScrollBarImageColor3=T.DIM; Sidebar.AutomaticCanvasSize=Enum.AutomaticSize.Y
Sidebar.CanvasSize=UDim2.new(0,0,0,0); Sidebar.ZIndex=14; Sidebar.ClipsDescendants=true
LP(Sidebar,8,8,10,10); LL(Sidebar,3)

local SDiv=Instance.new("Frame",Win)
SDiv.Size=UDim2.new(0,1,0,WH-BODY_Y); SDiv.Position=UDim2.new(0,SIDE_W,0,BODY_Y)
SDiv.BackgroundColor3=T.BORDER; SDiv.BackgroundTransparency=0.5; SDiv.BorderSizePixel=0; SDiv.ZIndex=14

local Content=Instance.new("Frame",Win)
Content.Size=UDim2.new(0,WW-SIDE_W-1,0,WH-BODY_Y); Content.Position=UDim2.new(0,SIDE_W+1,0,BODY_Y)
Content.BackgroundTransparency=1; Content.BorderSizePixel=0; Content.ClipsDescendants=true; Content.ZIndex=12

-- ════════════════════════════════════════════════════════════
-- TABS
-- ════════════════════════════════════════════════════════════
local TABS={
    {n="Home",    i="🏠"},
    {n="Combat",  i="⚔️"},
    {n="RP Color",i="🌈"},
    {n="Movement",i="🚀"},
    {n="Targets", i="🎯"},
    {n="Ghost",   i="👻"},
    {n="Glitch",  i="⚡"},
    {n="Headless",i="😵"},
    {n="Spin",    i="🌀"},
    {n="Settings",i="⚙️"},
    {n="Configs", i="💾"},
    {n="Advanced Cbt",i="👊"},
    {n="Cbt Utils",i="🛡️"},
    {n="Advantage",i="💎"},
}

local tabBtns={}; local tabPanels={}; local activeTab=nil; local transiting=false

for i,t in ipairs(TABS) do
    local btn=Instance.new("TextButton",Sidebar)
    btn.Size=UDim2.new(1,0,0,38); btn.BackgroundColor3=T.CARD; btn.BackgroundTransparency=1
    btn.Text=""; btn.AutoButtonColor=false; btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.ZIndex=15; Cnr(btn,7)
    
    local bar=Instance.new("Frame",btn); bar.Size=UDim2.new(0,3,0,20); bar.Position=UDim2.new(0,0,0.5,-10)
    bar.BackgroundColor3=T.ACCENT; bar.BackgroundTransparency=1; bar.BorderSizePixel=0; Cnr(bar,2)
    
    local ic=Instance.new("TextLabel",btn); ic.Size=UDim2.new(0,24,1,0); ic.Position=UDim2.new(0,8,0,0)
    ic.BackgroundTransparency=1; ic.Text=t.i; ic.TextSize=14; ic.TextColor3=T.DIM; ic.FontFace=Bold
    ic.TextXAlignment=Enum.TextXAlignment.Center; ic.ZIndex=15
    
    local nl=Instance.new("TextLabel",btn); nl.Size=UDim2.new(1,-36,1,0); nl.Position=UDim2.new(0,36,0,0)
    nl.BackgroundTransparency=1; nl.Text=t.n:upper(); nl.TextSize=8; nl.TextColor3=T.MUTED; nl.FontFace=Bold
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=15
    
    local panel=Instance.new("ScrollingFrame",Content)
    panel.Size=UDim2.new(1,0,1,0); panel.Position=UDim2.new(1,0,0,0); panel.BackgroundTransparency=1
    panel.BorderSizePixel=0; panel.ScrollBarThickness=4; panel.ScrollBarImageColor3=T.ACCENT
    panel.AutomaticCanvasSize=Enum.AutomaticSize.Y; panel.CanvasSize=UDim2.new(0,0,0,0)
    panel.ClipsDescendants=true; panel.Visible=false; panel.ZIndex=12
    LP(panel,14,14,12,24); LL(panel,8)
    
    btn.MouseEnter:Connect(function() if activeTab~=i then Tw(btn,{BackgroundTransparency=0.7},0.12) end end)
    btn.MouseLeave:Connect(function() if activeTab~=i then Tw(btn,{BackgroundTransparency=1},0.12) end end)
    
    tabBtns[i]={btn=btn,bar=bar,ic=ic,nl=nl}; tabPanels[i]=panel
end

local function GoTab(idx)
    if activeTab==idx or transiting then return end
    transiting=true; local prev=activeTab; activeTab=idx
    
    for i,tb in ipairs(tabBtns) do
        local a=(i==idx)
        Tw(tb.btn,{BackgroundTransparency=a and 0.05 or 1,BackgroundColor3=a and T.CARD or T.BG},0.16)
        Tw(tb.nl,{TextColor3=a and T.TEXT or T.MUTED},0.16)
        Tw(tb.ic,{TextColor3=a and T.ACCENT or T.DIM},0.16)
        Tw(tb.bar,{BackgroundTransparency=a and 0 or 1},0.2)
    end
    
    local dir=(prev and idx>prev) and 1 or -1
    local np=tabPanels[idx]; local op=prev and tabPanels[prev]
    
    np.Position=UDim2.new(dir,0,0,0); np.Visible=true
    
    local ti=TweenInfo.new(0.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
    if op then TweenSvc:Create(op,ti,{Position=UDim2.new(-dir,0,0,0)}):Play() end
    local t2=TweenSvc:Create(np,ti,{Position=UDim2.new(0,0,0,0)}); t2:Play()
    
    t2.Completed:Connect(function()
        if op then op.Visible=false; op.Position=UDim2.new(1,0,0,0) end
        transiting=false
    end)
end

for i in ipairs(tabBtns) do
    local idx=i
    tabBtns[i].btn.MouseButton1Click:Connect(function() GoTab(idx) end)
end

-- ════════════════════════════════════════════════════════════
-- TOGGLE BUTTON
-- ════════════════════════════════════════════════════════════
local TBtn=Instance.new("TextButton",GUI)
TBtn.Name="XYRO_Toggle"; TBtn.Size=UDim2.fromOffset(52,52)
TBtn.BackgroundColor3=T.BG; TBtn.BackgroundTransparency=0.02
TBtn.Text="X"; TBtn.FontFace=Bold; TBtn.TextSize=18; TBtn.TextColor3=T.ACCENT
TBtn.AutoButtonColor=false; TBtn.BorderSizePixel=0; TBtn.ZIndex=200
Cnr(TBtn,12); Strk(TBtn,T.ACCENT,1.8,0.2)

task.defer(function() local gs=GUI.AbsoluteSize; TBtn.Position=UDim2.fromOffset(gs.X-64,12) end)

local toggleHue=0
TC(RunSvc.RenderStepped:Connect(function(dt)
    toggleHue=(toggleHue+dt*0.4)%1
    TBtn.TextColor3=Color3.fromHSV(toggleHue,0.9,1)
end))

local _toggleKey=Enum.KeyCode.Insert
do
    local saved=SAVE.toggleKey
    if saved then local ok,kc=pcall(function() return Enum.KeyCode[saved] end); if ok and kc then _toggleKey=kc end end
end

local function toggleUI()
    Win.Visible=not Win.Visible
    if Win.Visible and not activeTab then GoTab(1) end
end

do
    local dragging,dragStart,startPos=false,nil,nil
    TBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=TBtn.Position
        end
    end)
    TBtn.InputEnded:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            dragging=false
            if (i.Position-dragStart).Magnitude<8 then toggleUI() end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            TBtn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

TC(UIS.InputBegan:Connect(function(i,gp)
    if not gp and i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==_toggleKey then toggleUI() end
end))

-- ════════════════════════════════════════════════════════════
-- SHARED UTILITIES
-- ════════════════════════════════════════════════════════════
local function cleanRag(char)
    if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    pcall(function()
        for _,st in ipairs({Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.Physics,Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.PlatformStanding}) do
            hum:SetStateEnabled(st,false)
        end
        hum.PlatformStand=false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
    for _,o in ipairs(char:GetDescendants()) do
        if o:IsA("Motor6D") then o.Enabled=true
        elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
            pcall(function() o:Destroy() end)
        end
    end
end

local function findArena()
    local s=workspace:FindFirstChild("Stuff")
    if s then local fa=s:FindFirstChild("Fight Arena"); if fa then return fa:FindFirstChild("CombatArena") end end
    return workspace:FindFirstChild("CombatArena",true)
end

-- ═══════════════════════════════════════
-- TAB 1: HOME
-- ═══════════════════════════════════════
do
    local P=tabPanels[1]
    local wc=MkCard(P,76,1)
    MkLabel(wc,{text="Welcome back",size=9,color=T.MUTED,font=Reg,sz=UDim2.new(1,-32,0,14),pos=UDim2.new(0,16,0,10),z=14})
    local wnL=MkLabel(wc,{text=lp.DisplayName,size=22,color=T.TEXT,font=Bold,sz=UDim2.new(1,-32,0,30),pos=UDim2.new(0,16,0,26),z=14})
    local wnH=0; TC(RunSvc.Heartbeat:Connect(function(dt) wnH=(wnH+dt*0.5)%1; wnL.TextColor3=Color3.fromHSV(wnH,1,1) end))
    MkLabel(wc,{text="@"..lp.Name.." · ID: "..lp.UserId,size=8,color=T.DIM,font=Reg,sz=UDim2.new(1,-32,0,12),pos=UDim2.new(0,16,0,58),z=14})
    
    local sc=MkCard(P,42,2)
    MkLabel(sc,{text=#Players:GetPlayers().." / "..Players.MaxPlayers.." players  ·  Place ID: "..game.PlaceId,size=10,color=T.MUTED,font=Reg,sz=UDim2.new(1,-32,0,18),pos=UDim2.new(0,16,0,12),z=14})
    
    local ulCard=MkCard(P,48,3)
    MkLabel(ulCard,{text="UNLOAD ENGINE",size=8,color=T.DIM,font=Bold,sz=UDim2.new(1,-32,0,12),pos=UDim2.new(0,16,0,8),z=14})
    local ulBtn=MkBtn(ulCard,{bg=T.ERR,text="UNLOAD XYRO",size=10,color=T.TEXT,sz=UDim2.new(1,-32,0,26),pos=UDim2.new(0,16,0,20),corner=7,bgt=0.1,z=15})
    local ulC=false
    ulBtn.MouseButton1Click:Connect(function()
        if not ulC then
            ulC=true; ulBtn.Text="CLICK AGAIN TO CONFIRM"
            task.delay(3,function() ulC=false; ulBtn.Text="UNLOAD XYRO" end)
        else
            for _,c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
            DoSave(); Notif("Unload","Goodbye!","warn")
            task.delay(0.5,function() pcall(function() GUI:Destroy() end) end)
        end
    end)
end

-- ═══════════════════════════════════════
-- TAB 2: COMBAT
-- ═══════════════════════════════════════
do
    local P=tabPanels[2]

    local kaOn=false
    local kaAPS=SAVE.kaAPS
    local kaCD=1/kaAPS
    local kaRange=SAVE.kaRange
    local kaSimul=false
    local kaPredict=SAVE.kaPredict or true
    local kaHeadOn=false
    local kaAFling=false
    local safeSpotOn=false

    local kaLast=0
    local kaTStr=SAVE.kaTargets or ""
    local kaFStr=SAVE.kaFriends or ""
    local kaHStr=SAVE.headSit or ""

    local kaTgts={}
    local kaFrns={}
    local kaHds={}
    local kaManualTgt={}
    local kaManualFrn={}

    local originalCFrame=nil
    local safeLockConn=nil

    local function ParseN(s)
        local t={}
        if s=="" then return t end
        for nm in s:gsub(",", " "):gmatch("%S+") do
            local n=nm:lower():match("^%s*(.-)%s*$")
            if n and n~="" then t[#t+1]=n end
        end
        return t
    end

    local function RefAll()
        kaTgts=ParseN(kaTStr); kaFrns=ParseN(kaFStr); kaHds=ParseN(kaHStr)
        SAVE.kaTargets=kaTStr; SAVE.kaFriends=kaFStr; SAVE.headSit=kaHStr; task.delay(.5,DoSave)
    end
    RefAll()

    local function matchesAny(arr, name, displayName)
        local nl, dn = name:lower(), displayName:lower()
        for _, k in ipairs(arr) do
            if nl==k or dn==k then return true end
            if nl:find(k, 1, true) or dn:find(k, 1, true) then return true end
        end
        return false
    end

    local function IsFriend(p)
        if kaManualFrn[p] then return true end
        if #kaFrns==0 then return false end
        return matchesAny(kaFrns, p.Name, p.DisplayName)
    end

    local function IsTarget(p)
        if p==lp then return false end
        if IsFriend(p) then return false end
        if kaManualTgt[p] then return true end
        if #kaTgts==0 then return true end
        return matchesAny(kaTgts, p.Name, p.DisplayName)
    end

    local function IsHeadSitTarget(p)
        if p==lp then return false end
        if #kaHds==0 then return false end
        return matchesAny(kaHds, p.Name, p.DisplayName)
    end

    local function goToSafeSpot()
        local myC=lp.Character; local myH=myC and myC:FindFirstChild("HumanoidRootPart")
        if not myH then return end

        originalCFrame=myH.CFrame
        SAVE.safeX=SAFE_CF.Position.X
        SAVE.safeY=SAFE_CF.Position.Y
        SAVE.safeZ=SAFE_CF.Position.Z
        
        myH.CFrame=SAFE_CF
        myH.AssemblyLinearVelocity=Vector3.zero
        myH.AssemblyAngularVelocity=Vector3.zero
        myH.CanCollide=false
        pcall(function() local h=myC:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand=true end end)
        
        if safeLockConn then safeLockConn:Disconnect() end
        safeLockConn=TC(RunSvc.Heartbeat:Connect(function()
            if not safeSpotOn then return end
            local c=lp.Character; local h=c and c:FindFirstChild("HumanoidRootPart")
            if h then h.CFrame=SAFE_CF; h.AssemblyLinearVelocity=Vector3.zero end
        end))
    end

    local function disableSafeSpot()
        if safeLockConn then safeLockConn:Disconnect(); safeLockConn=nil end
        
        local myC=lp.Character; local myH=myC and myC:FindFirstChild("HumanoidRootPart")
        if myH then
            pcall(function()
                local hum=myC:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand=false
                    hum.Sit=false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
            
            myH.CanCollide=true
            myH.AssemblyLinearVelocity=Vector3.zero
            
            if originalCFrame then
                myH.CFrame=originalCFrame
                originalCFrame=nil
            end
        end
    end

    local afConn
    local function StartAF()
        if afConn then afConn:Disconnect() end
        afConn=TC(RunSvc.Heartbeat:Connect(function()
            local c=lp.Character; if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if hrp.AssemblyLinearVelocity.Magnitude>150 then hrp.AssemblyLinearVelocity=hrp.AssemblyLinearVelocity*0.75 end
            if hrp.AssemblyAngularVelocity.Magnitude>20 then hrp.AssemblyAngularVelocity=Vector3.zero end
        end))
    end
    local function StopAF() if afConn then afConn:Disconnect(); afConn=nil end end

    local function HitRemoteInvoke(hum, px, py, pz)
        spawn(function()
            pcall(function()
                if RF.Hit then RF.Hit:InvokeServer(unpack({hum, vector.create(px, py, pz)})) end
            end)
        end)
    end

    local kaConn
    local lastTargets = {}
    local targetCache = {}
    local cacheTime = 0
    
    local function StartKA()
        if kaConn then kaConn:Disconnect() end
        
        kaConn = TC(RunSvc.Heartbeat:Connect(function()
            if not kaOn then return end
            
            local mc = lp.Character
            local myHRP = mc and mc:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end
            
            local now = clock()
            if now - kaLast < kaCD then return end
            
            local px, py, pz = myHRP.Position.X, myHRP.Position.Y, myHRP.Position.Z

            if kaHeadOn then
                for _, p in ipairs(Players:GetPlayers()) do
                    if IsHeadSitTarget(p) and p.Character then
                        local head = p.Character:FindFirstChild("Head")
                        if head and (head.Position - myHRP.Position).Magnitude <= kaRange then
                            myHRP.CFrame = CFrame.new(head.Position + Vector3.new(0, 3.5, 0))
                        end
                    end
                end
            end
            
            local targets = {}
            local hitAny = false
            
            if now - cacheTime > 0.1 then
                targetCache = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if not IsTarget(p) then continue end
                    local c = p.Character
                    if not c then continue end
                    
                    local hu = c:FindFirstChild("Humanoid")
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    
                    if hu and hrp and hu.Health > 0 then
                        targetCache[p] = {hu, hrp}
                    end
                end
                cacheTime = now
            end
            
            if kaSimul then
                for p, data in pairs(targetCache) do
                    local hu, hrp = data[1], data[2]
                    if (hrp.Position - myHRP.Position).Magnitude <= kaRange then
                        insert(targets, data)
                        hitAny = true
                    end
                end
            else
                local cls, mind = nil, math.huge
                for p, data in pairs(targetCache) do
                    local hu, hrp = data[1], data[2]
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d <= kaRange and d < mind then
                        mind = d
                        cls = data
                    end
                end
                if cls then
                    insert(targets, cls)
                    hitAny = true
                end
            end
            
            if hitAny then
                spawn(function()
                    for _, tData in ipairs(targets) do
                        local hu, hrp = tData[1], tData[2]
                        
                        if kaPredict and hrp then
                            local vel = hrp.AssemblyLinearVelocity
                            local predictPos = hrp.Position + vel * (kaCD * 0.5)
                            HitRemoteInvoke(hu, predictPos.X, predictPos.Y, predictPos.Z)
                        else
                            HitRemoteInvoke(hu, px, py, pz)
                        end
                    end
                end)
                kaLast = now
            end
        end))
    end
    
    local function StopKA()
        if kaConn then
            kaConn:Disconnect()
            kaConn = nil
        end
        targetCache = {}
    end

    MkSep(P,"Kill Aura",1)

    local _,_,kSet = MkToggle(P, "KILL AURA", 2,
        function()
            kaOn = true
            StartKA()
            Notif("Kill Aura","Active","ok")
        end,
        function()
            kaOn = false
            StopKA()
            Notif("Kill Aura","Off","")
        end
    )

    RegKB("Kill Aura",Enum.KeyCode.K,function()
        kaOn = not kaOn
        kSet(kaOn)
        if kaOn then StartKA(); Notif("Kill Aura","Active","ok") else StopKA(); Notif("Kill Aura","Off","") end
    end)

    MkToggle(P,"SIMULTANEOUS HITS",4,function() kaSimul=true; Notif("Kill Aura","Simultaneous: ON","ok") end,function() kaSimul=false; Notif("Kill Aura","Simultaneous: OFF","") end)
    
    MkToggle(P,"VELOCITY PREDICTION",5,
        function()
            kaPredict=true
            SAVE.kaPredict=true
            DoSave()
            Notif("Kill Aura","Prediction: ON","ok")
        end,
        function()
            kaPredict=false
            SAVE.kaPredict=false
            DoSave()
            Notif("Kill Aura","Prediction: OFF","")
        end
    )
    
    MkToggle(P,"ANTI-FLING",6,function() kaAFling=true; StartAF(); Notif("Anti-Fling","Active","ok") end,function() kaAFling=false; StopAF(); Notif("Anti-Fling","Off","") end)
    
    local _,_,ssSet=MkToggle(P,"SAFE SPOT",7,
        function() safeSpotOn=true; goToSafeSpot(); Notif("Safe Spot","Locked","ok") end,
        function() safeSpotOn=false; disableSafeSpot(); Notif("Safe Spot","Unlocked","") end
    )
    RegKB("Safe Spot",Enum.KeyCode.V,function()
        safeSpotOn=not safeSpotOn; ssSet(safeSpotOn)
        if safeSpotOn then goToSafeSpot(); Notif("Safe Spot","Locked","ok") else disableSafeSpot(); Notif("Safe Spot","Unlocked","") end
    end)

    MkSlider(P,"ATTACKS PER SECOND",100,15000,SAVE.kaAPS,8,function(v) kaAPS=v; kaCD=1/v; SAVE.kaAPS=v; task.delay(.5,DoSave) end)
    MkSlider(P,"RANGE",5,500,SAVE.kaRange,9,function(v) kaRange=v; SAVE.kaRange=v; task.delay(.5,DoSave) end)
    
    local hbOn=false; local hbConn
    MkSlider(P,"HITBOX EXPANDER",0,25,0,10,function(v)
        for _, p in Players:GetPlayers() do
            if p==lp then continue end
            local c=p.Character; if not c then continue end
            local hrp=c:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() local s=v<1 and 2 or v; hrp.Size=Vector3.new(s,s,s) end) end
        end
    end)
    
    MkToggle(P,"HITBOX COLLISION OFF",11,function()
        local function setNC(p) if p==lp then return end; local c=p.Character; if not c then return end; local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then pcall(function() hrp.CanCollide=false end) end end
        for _, p in Players:GetPlayers() do setNC(p) end
        hbConn=TC(Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(0.5); setNC(p) end) end))
        Notif("Hitbox","Collision Off","ok")
    end,function()
        if hbConn then hbConn:Disconnect(); hbConn=nil end
        for _, p in Players:GetPlayers() do if p==lp then continue end; local c=p.Character; if not c then continue end; local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then pcall(function() hrp.CanCollide=true end) end end
        Notif("Hitbox","Collision On","")
    end)

    local _,tgBox=MkTBoxCard(P,"TARGETS (saved)","player1 player2 ...",12)
    tgBox.Text=kaTStr
    tgBox.FocusLost:Connect(function() kaTStr=tgBox.Text; RefAll() end)

    local _,frBox=MkTBoxCard(P,"FRIENDS / AVOID (saved)","friend1 friend2 ...",13)
    frBox.Text=kaFStr
    frBox.FocusLost:Connect(function() kaFStr=frBox.Text; RefAll() end)

    MkToggle(P,"HEAD SIT",14,function() kaHeadOn=true; Notif("Kill Aura","Head Sit: ON","ok") end,function() kaHeadOn=false; Notif("Kill Aura","Head Sit: OFF","") end)
    local _,hsBox=MkTBoxCard(P,"HEAD SIT TARGETS (saved)","player1 player2 ...",15)
    hsBox.Text=kaHStr
    hsBox.FocusLost:Connect(function() kaHStr=hsBox.Text; RefAll() end)

    MkSep(P,"TP Hit",30)
    do
        local _,thBox=MkTBoxCard(P,"TP HIT TARGET (blank=nearest)","player name ...",31,SAVE.tpHitTarget)
        tpHitTargetBox=thBox
        thBox.FocusLost:Connect(function() SAVE.tpHitTarget=thBox.Text; task.delay(.5,DoSave) end)
    end
    local function startTPHit()
        if tpHitConn then tpHitConn:Disconnect() end
        local last=0; local interval=1/math.max(kaAPS,1)
        tpHitConn=TC(RunSvc.RenderStepped:Connect(function()
            if not tpHitOn then return end
            local now=tick(); if now-last < interval then return end; last=now
            local mc=lp.Character; if not mc then return end
            local mHRP=mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            local tgtName=tpHitTargetBox and tpHitTargetBox.Text or ""
            local tgt
            if tgtName~="" then tgt=findPlayer(tgtName)
            else
                local best,bestD=nil,math.huge
                for _,p in Players:GetPlayers() do
                    if not IsTarget(p) then continue end
                    local c=p.Character; if not c then continue end
                    local hrp=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health>0 then
                        local d=(hrp.Position-mHRP.Position).Magnitude
                        if d<tpHitRange and d<bestD then bestD=d; best=p end
                    end
                end
                tgt=best
            end
            if not tgt or not tgt.Character then return end
            local tHRP=tgt.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
            local tHum=tgt.Character:FindFirstChildOfClass("Humanoid"); if not tHum or tHum.Health<=0 then return end
            local origCF=mHRP.CFrame
            mHRP.CFrame=CFrame.new(tHRP.Position); mHRP.AssemblyLinearVelocity=Vector3.zero
            RunSvc.Heartbeat:Wait()
            pcall(function() if RF.PunchDo then RF.PunchDo:InvokeServer() end end)
            pcall(function() if RF.Hit then RF.Hit:InvokeServer(tHum,vector.create(tHRP.Position.X,tHRP.Position.Y,tHRP.Position.Z)) end end)
            task.wait(0.04)
            mHRP.CFrame=origCF
        end))
    end
    MkToggle(P,"TP HIT ",32,
        function() tpHitOn=true; startTPHit(); Notif("TP Hit","Active","ok") end,
        function() tpHitOn=false; if tpHitConn then tpHitConn:Disconnect();tpHitConn=nil end; Notif("TP Hit","Off","") end)
    RegKB("TP Hit",Enum.KeyCode.Y,function()
        tpHitOn=not tpHitOn
        if tpHitOn then startTPHit(); Notif("TP Hit","Active","ok") else if tpHitConn then tpHitConn:Disconnect();tpHitConn=nil end; Notif("TP Hit","Off","") end
    end)
    MkSlider(P,"TP HIT RANGE",5,100,SAVE.tpHitRange,33,function(v) tpHitRange=v; SAVE.tpHitRange=v; task.delay(.5,DoSave) end)

    MkSep(P,"Hitbox",34)
    local _hbF=0
    TC(RunSvc.RenderStepped:Connect(function()
        if not hbOn then return end
        _hbF=_hbF+1; if _hbF%3~=0 then return end
        for _,p in Players:GetPlayers() do
            if p==lp or not p.Character then continue end
            pcall(function()
                local hrp=p.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                if IsTarget(p) then
                    hrp.Size=Vector3.new(hbSize,hbSize,hbSize); hrp.CanCollide=false
                    if hbVis then hrp.Transparency=0.65; hrp.Material=Enum.Material.Neon; hrp.BrickColor=BrickColor.new("White")
                    else hrp.Transparency=1; hrp.Material=Enum.Material.Plastic end
                else hrp.Size=Vector3.new(2,2,1); hrp.Transparency=1; hrp.CanCollide=false end
            end)
        end
    end))
    MkToggle(P,"HITBOX EXPANDER",35,function() hbOn=true; Notif("Hitbox","Active","ok") end,function() hbOn=false; Notif("Hitbox","Off","") end)
    MkToggle(P,"HITBOX VISIBLE",36,function() hbVis=true end,function() hbVis=false end)
    MkSlider(P,"HITBOX SIZE",1,50,SAVE.hbSize,37,function(v) hbSize=v; SAVE.hbSize=v; task.delay(.5,DoSave) end)

    MkSep(P,"Grab",38)
    local function fireGrab() pcall(function() if RF.Grab then RF.Grab:InvokeServer() end end) end
    RegKB("Manual Grab",Enum.KeyCode.G,function() fireGrab() end)

    MkToggle(P,"SPAM GRAB",39,
        function()
            sgOn=true
            task.spawn(function()
                while sgOn do fireGrab(); task.wait() end
            end)
            Notif("Spam Grab","Active","ok")
        end,
        function() sgOn=false; Notif("Spam Grab","Off","") end)

    do
        local _,agBox2=MkTBoxCard(P,"AUTO GRAB TARGET (required)","player name ...",40,SAVE.agTarget)
        agTargetBox=agBox2
        agBox2.FocusLost:Connect(function() SAVE.agTarget=agBox2.Text; task.delay(.5,DoSave) end)
    end
    local function startAG()
        if agConn then agConn:Disconnect() end
        local t=0
        agConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            if not agOn then return end
            t=t+dt; if t<0.1 then return end; t=0
            local mc=lp.Character; if not mc then return end
            local mHRP=mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            local tgtName=agTargetBox and agTargetBox.Text or ""
            if tgtName=="" then return end
            local tgt=findPlayer(tgtName); if not tgt or not tgt.Character then return end
            local tHRP=tgt.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
            local tHum=tgt.Character:FindFirstChildOfClass("Humanoid"); if not tHum or tHum.Health<=0 then return end
            local origCF=mHRP.CFrame
            mHRP.CFrame=tHRP.CFrame
            mHRP.AssemblyLinearVelocity=Vector3.zero
            RunSvc.Heartbeat:Wait()
            RunSvc.Heartbeat:Wait()
            pcall(function() if RF.Grab then RF.Grab:InvokeServer() end end)
            task.wait(0.06)
            mHRP.CFrame=origCF
        end))
    end
    MkToggle(P,"AUTO GRAB",41,
        function() agOn=true; startAG(); Notif("Auto Grab","Active","ok") end,
        function() agOn=false; if agConn then agConn:Disconnect();agConn=nil end; Notif("Auto Grab","Off","") end)

    local function startGrabLoop()
        if grabLoopConn then grabLoopConn:Disconnect() end
        local t=0
        grabLoopConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            if not grabLoopOn then return end
            t=t+dt; if t<0.08 then return end; t=0
            local mc=lp.Character; local mHRP=mc and mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            for _,p in Players:GetPlayers() do
                if not IsTarget(p) then continue end
                local c=p.Character; if not c then continue end
                local hrp=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health>0 and (hrp.Position-mHRP.Position).Magnitude<=kaRange then
                    local orig=mHRP.CFrame
                    mHRP.CFrame=hrp.CFrame; mHRP.AssemblyLinearVelocity=Vector3.zero
                    RunSvc.Heartbeat:Wait(); RunSvc.Heartbeat:Wait()
                    pcall(function() if RF.Grab then RF.Grab:InvokeServer() end end)
                    task.wait(0.04); mHRP.CFrame=orig
                end
            end
        end))
    end
    MkToggle(P,"GRAB LOOP (all in range)",42,
        function() grabLoopOn=true; startGrabLoop(); Notif("Grab Loop","Active","ok") end,
        function() grabLoopOn=false; if grabLoopConn then grabLoopConn:Disconnect();grabLoopConn=nil end; Notif("Grab Loop","Off","") end)

    do
        local _,ggBox2=MkTBoxCard(P,"GRAB GLITCH TARGET","player name ...",43,SAVE.ggTarget)
        ggTargetBox=ggBox2
        ggBox2.FocusLost:Connect(function() SAVE.ggTarget=ggBox2.Text; task.delay(.5,DoSave) end)
        local ggBtnCard=MkCard(P,38,44)
        MkLabel(ggBtnCard,{text="GRAB GLITCH",size=9,color=T.TEXT,font=Semi,sz=UDim2.new(1,-88,0,18),pos=UDim2.new(0,14,0.5,-9),z=14})
        local ggBtn=MkBtn(ggBtnCard,{bg=T.RAISED,text="FIRE",size=8,color=T.TEXT,sz=UDim2.new(0,72,0,24),pos=UDim2.new(1,-86,0.5,-12),corner=6,bgt=0.1,z=15})
        local function doGG()
            local tgtName=ggTargetBox and ggTargetBox.Text or ""
            local tgt
            if tgtName~="" then tgt=findPlayer(tgtName)
            else
                if #TargetsList==0 then return end
                for _,s in ipairs(TargetsList) do
                    for _,p in Players:GetPlayers() do
                        if p~=lp and (p.Name:lower():find(s,1,true) or p.DisplayName:lower():find(s,1,true)) then
                            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then tgt=p; break end
                        end
                    end; if tgt then break end
                end
            end
            if not tgt then Notif("Grab Glitch","Target not found","err"); return end
            local mc=lp.Character; if not mc then return end
            local mHRP=mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            local tHRP=tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
            local origCF=mHRP.CFrame
            task.spawn(function()
                mHRP.CFrame=tHRP.CFrame; mHRP.AssemblyLinearVelocity=Vector3.zero
                RunSvc.Heartbeat:Wait(); RunSvc.Heartbeat:Wait()
                pcall(function() if RF.Grab then RF.Grab:InvokeServer() end end)
                task.wait(0.06); mHRP.CFrame=origCF
            end)
            Notif("Grab Glitch","→ "..tgt.DisplayName,"ok")
        end
        ggBtn.MouseButton1Click:Connect(doGG)
        RegKB("Grab Glitch",Enum.KeyCode.H,doGG)
    end

    MkSep(P,"Extra Combat",45)
    local function startRapid()
        if rapidConn then rapidConn:Disconnect() end
        local t=0
        rapidConn=TC(RunSvc.RenderStepped:Connect(function(dt)
            if not rapidOn then return end
            t=t+dt; if t<0.016 then return end; t=0
            local mc=lp.Character; local mHRP=mc and mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            for _,p in Players:GetPlayers() do
                if not IsTarget(p) then continue end
                local c=p.Character; if not c then continue end
                local hum=c:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    pcall(function() if RF.Hit then RF.Hit:InvokeServer(hum,vector.create(mHRP.Position.X,mHRP.Position.Y,mHRP.Position.Z)) end end)
                end
            end
        end))
    end
    MkToggle(P,"RAPID HIT SPAM",46,
        function() rapidOn=true; startRapid(); Notif("Rapid Hit","Active","ok") end,
        function() rapidOn=false; if rapidConn then rapidConn:Disconnect();rapidConn=nil end; Notif("Rapid Hit","Off","") end)

    local function startPunch()
        if punchConn then punchConn:Disconnect() end
        local t=0
        punchConn=TC(RunSvc.RenderStepped:Connect(function(dt)
            if not punchOn then return end
            t=t+dt; if t<0.02 then return end; t=0
            pcall(function() if RF.PunchDo then RF.PunchDo:InvokeServer() end end)
        end))
    end
    MkToggle(P,"PUNCH SPAM",47,
        function() punchOn=true; startPunch(); Notif("Punch Spam","Active","ok") end,
        function() punchOn=false; if punchConn then punchConn:Disconnect();punchConn=nil end; Notif("Punch Spam","Off","") end)

    local function startSpamBlock()
        if spamBlockConn then spamBlockConn:Disconnect() end
        spamBlockConn=TC(RunSvc.RenderStepped:Connect(function()
            if not spamBlockOn then return end
            pcall(function() if RF.Block then RF.Block:InvokeServer(true) end end)
        end))
    end
    MkToggle(P,"SPAM BLOCK (ultra fast)",48,
        function() spamBlockOn=true; startSpamBlock(); Notif("Spam Block","Active","ok") end,
        function() spamBlockOn=false; if spamBlockConn then spamBlockConn:Disconnect();spamBlockConn=nil end; Notif("Spam Block","Off","") end)

    local function startAutoParry()
        if autoParryConn then autoParryConn:Disconnect() end
        autoParryConn=TC(RunSvc.Heartbeat:Connect(function()
            if not autoParryOn then return end
            local mc=lp.Character; if not mc then return end
            local mHRP=mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            for _,p in Players:GetPlayers() do
                if p==lp or not p.Character then continue end
                local c=p.Character
                local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                local d=(hrp.Position-mHRP.Position).Magnitude
                if d<12 then
                    pcall(function() if RF.Block then RF.Block:InvokeServer(true) end end)
                end
            end
        end))
    end
    MkToggle(P,"AUTO PARRY",49,
        function() autoParryOn=true; startAutoParry(); Notif("Auto Parry","Active","ok") end,
        function() autoParryOn=false; if autoParryConn then autoParryConn:Disconnect();autoParryConn=nil end; Notif("Auto Parry","Off","") end)

    MkSep(P,"Defensive",50)

    local function startSB()
        if sbConn then sbConn:Disconnect() end
        local t=0
        sbConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            t=t+dt; if t<0.03 then return end; t=0
            pcall(function() if RF.Block then RF.Block:InvokeServer(true) end end)
        end))
    end
    MkToggle(P,"SILENT BLOCK",51,function() startSB(); Notif("Silent Block","Active","ok") end,function() if sbConn then sbConn:Disconnect();sbConn=nil end; Notif("Silent Block","Off","") end)

    local arOn=false; local arConn; local arCharConn
    local function startAR()
        arConn=TC(RunSvc.Heartbeat:Connect(function()
            local c=lp.Character; if c then cleanRag(c) end
        end))
        arCharConn=TC(lp.CharacterAdded:Connect(function(c) task.wait(.3); cleanRag(c) end))
        if lp.Character then cleanRag(lp.Character) end
    end
    MkToggle(P,"ANTI RAGDOLL",52,
        function() arOn=true; startAR(); Notif("Anti Ragdoll","Active","ok") end,
        function() arOn=false; if arConn then arConn:Disconnect();arConn=nil end; if arCharConn then arCharConn:Disconnect();arCharConn=nil end; Notif("Anti Ragdoll","Off","") end)

    local function _arc_removePlat()
        if _arc_platConn then _arc_platConn:Disconnect();_arc_platConn=nil end
        if _arc_platform then pcall(function() _arc_platform:Destroy() end);_arc_platform=nil end
    end
    local function _arc_spawnPlat(pos)
        _arc_removePlat()
        local part=Instance.new("Part"); part.Size=Vector3.new(12,1,12)
        part.CFrame=CFrame.new(pos.X,pos.Y-3.5,pos.Z); part.Anchored=true; part.CanCollide=true
        part.Material=Enum.Material.SmoothPlastic; part.Transparency=0.4; part.Locked=true; part.Parent=workspace
        _arc_platform=part; local topY=part.Position.Y+0.5
        _arc_platConn=TC(RunSvc.Heartbeat:Connect(function()
            if not _arc_platform or not _arc_platform.Parent then _arc_removePlat(); return end
            local c=lp.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y<topY then hrp.CFrame=CFrame.new(pos.X,topY+3.5,pos.Z); hrp.AssemblyLinearVelocity=Vector3.zero end
        end))
    end
    local function _arc_countDis(char)
        local tot,dis=0,0
        for _,o in ipairs(char:GetDescendants()) do if o:IsA("Motor6D") then tot=tot+1; if not o.Enabled then dis=dis+1 end end end
        return tot,dis
    end
    local function _arc_forceEnd(char)
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        for _,st in ipairs({Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.Physics,Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.PlatformStanding}) do pcall(function() hum:SetStateEnabled(st,false) end) end
        hum.PlatformStand=false; pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        for _,o in ipairs(char:GetDescendants()) do
            if o:IsA("Motor6D") then o.Enabled=true
            elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then o:Destroy() end
        end
    end
    local function _arc_doReturn(hrp,saved)
        local sp=_arc_safeCF.Position; _arc_spawnPlat(sp); hrp.CFrame=CFrame.new(sp); hrp.AssemblyLinearVelocity=Vector3.zero
        _arc_retTask=task.delay(arcGrabDelay,function()
            _arc_removePlat()
            if hrp and hrp.Parent and saved then hrp.CFrame=saved end
            task.delay(.05,function() if hrp and hrp.Parent then hrp.AssemblyLinearVelocity=Vector3.new(0,-1,0) end end)
            _arc_origCF=nil;_arc_retTask=nil;_arc_cleaned=false;_arc_inReturn=false;_arc_wasGrabbed=false
        end)
    end
    local function _arc_startChar(char)
        local hrp=char:WaitForChild("HumanoidRootPart",10); if not hrp then return end
        local hum=char:WaitForChild("Humanoid",10); if not hum then return end
        if _arc_conn then _arc_conn:Disconnect() end; if _arc_platStandConn then _arc_platStandConn:Disconnect() end
        _arc_origCF=nil;_arc_cleaned=false;_arc_inReturn=false;_arc_wasGrabbed=false
        if _arc_retTask then task.cancel(_arc_retTask);_arc_retTask=nil end
        task.wait(2.5); if not arcOn then return end
        _arc_platStandConn=TC(hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if not arcOn or _arc_inReturn then return end
            if hum.PlatformStand then _arc_wasGrabbed=true; if not _arc_origCF then _arc_origCF=hrp.CFrame end end
        end))
        _arc_conn=TC(RunSvc.Heartbeat:Connect(function()
            if not arcOn or not char.Parent then return end; if _arc_inReturn then return end
            local tot,dis=_arc_countDis(char); local isRag=tot>=12 and (dis/tot)>=0.9
            if isRag then
                if not _arc_origCF then _arc_origCF=hrp.CFrame end
                if _arc_wasGrabbed then
                    if not _arc_cleaned then _arc_forceEnd(char);_arc_cleaned=true end
                    if not _arc_retTask then _arc_inReturn=true;_arc_doReturn(hrp,_arc_origCF) end
                else hrp.CFrame=_arc_safeCF; if not _arc_cleaned then _arc_forceEnd(char);_arc_cleaned=true end end
            else
                if not _arc_wasGrabbed and _arc_origCF and not _arc_retTask then
                    _arc_inReturn=true; local saved=_arc_origCF
                    _arc_retTask=task.delay(arcDefDelay,function()
                        if hrp and hrp.Parent and saved then hrp.CFrame=saved end
                        task.delay(.05,function() if hrp and hrp.Parent then hrp.AssemblyLinearVelocity=Vector3.new(0,-1,0) end end)
                        _arc_origCF=nil;_arc_retTask=nil;_arc_cleaned=false;_arc_inReturn=false;_arc_wasGrabbed=false
                    end)
                end
                if not _arc_wasGrabbed then _arc_cleaned=false end
            end
        end))
    end
    local function startARC() _arc_charConn=TC(lp.CharacterAdded:Connect(function(c) task.spawn(_arc_startChar,c) end)); if lp.Character then task.spawn(_arc_startChar,lp.Character) end end
    local function stopARC()
        arcOn=false
        if _arc_conn then _arc_conn:Disconnect();_arc_conn=nil end; if _arc_platStandConn then _arc_platStandConn:Disconnect();_arc_platStandConn=nil end
        if _arc_charConn then _arc_charConn:Disconnect();_arc_charConn=nil end
        if _arc_retTask then task.cancel(_arc_retTask);_arc_retTask=nil end; _arc_removePlat()
    end
    MkToggle(P,"ANTI RAG COMBO (ARC)",53,
        function() arcOn=true; startARC(); Notif("ARC","Active","ok") end,
        function() stopARC(); Notif("ARC","Off","") end)
    MkSlider(P,"ARC DEFAULT DELAY",1,10,math.max(1,math.floor(SAVE.arcDefDelay*10+.5)),54,function(v) arcDefDelay=v/10; SAVE.arcDefDelay=arcDefDelay; task.delay(.5,DoSave) end)
    MkSlider(P,"ARC GRAB DELAY",1,10,math.max(1,math.floor(SAVE.arcGrabDelay+.5)),55,function(v) arcGrabDelay=v; SAVE.arcGrabDelay=v; task.delay(.5,DoSave) end)

    local function startInvincible()
        if invConn then invConn:Disconnect() end
        local t=0
        invConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            if not invOn then return end
            t=t+dt; if t<0.02 then return end; t=0
            pcall(function() if RF.Block then RF.Block:InvokeServer(true) end end)
            local c=lp.Character; if not c then return end
            local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return end
            if hum.PlatformStand then
                hum.PlatformStand=false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                local hrp=c:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
            end
            for _,st in ipairs({Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.Physics,Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.PlatformStanding}) do
                pcall(function() hum:SetStateEnabled(st,false) end)
            end
            for _,o in ipairs(c:GetDescendants()) do
                if o:IsA("Motor6D") then o.Enabled=true
                elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
                    pcall(function() o:Destroy() end)
                end
            end
        end))
    end
    MkToggle(P,"INVINCIBLE",56,
        function() invOn=true; startInvincible(); Notif("Invincible","Active","ok") end,
        function() invOn=false; if invConn then invConn:Disconnect();invConn=nil end; Notif("Invincible","Off","") end)
    RegKB("Invincible",Enum.KeyCode.I,function()
        invOn=not invOn
        if invOn then startInvincible(); Notif("Invincible","Active","ok") else if invConn then invConn:Disconnect();invConn=nil end; Notif("Invincible","Off","") end
    end)

    local function startDodge()
        if dodgeConn then dodgeConn:Disconnect() end
        local lastDodge=0
        dodgeConn=TC(RunSvc.Heartbeat:Connect(function()
            if not dodgeOn then return end
            local c=lp.Character; if not c then return end
            local hum=c:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            if hum.PlatformStand and tick()-lastDodge>0.5 then
                lastDodge=tick()
                hrp.CFrame=SAFE_CF; hrp.AssemblyLinearVelocity=Vector3.zero
                hum.PlatformStand=false
                pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                for _,o in ipairs(c:GetDescendants()) do
                    if o:IsA("Motor6D") then o.Enabled=true
                    elseif (o:IsA("BaseConstraint") or o:IsA("Attachment")) and o.Name:lower():find("ragdoll") then
                        pcall(function() o:Destroy() end)
                    end
                end
                Notif("Dodge","Grab dodged","ok")
            end
        end))
    end
    MkToggle(P,"DODGE GRABS",57,
        function() dodgeOn=true; startDodge(); Notif("Dodge","Active","ok") end,
        function() dodgeOn=false; if dodgeConn then dodgeConn:Disconnect();dodgeConn=nil end; Notif("Dodge","Off","") end)

    local function hookDeathHum(char)
        local hum=char:FindFirstChildOfClass("Humanoid"); if not hum then return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        hum.Died:Connect(function() if hrp and hrp.Parent then dtCF=hrp.CFrame end end)
    end
    local function startDT()
        dtCharConn=TC(lp.CharacterAdded:Connect(function(char)
            task.wait(0.8); local hrp2=char:FindFirstChild("HumanoidRootPart")
            if hrp2 and dtCF then hrp2.CFrame=dtCF; Notif("Death TP","Returned","ok") end; hookDeathHum(char)
        end))
        if lp.Character then hookDeathHum(lp.Character) end
    end
    MkToggle(P,"DEATH TP",58,
        function() dtOn=true; startDT(); Notif("Death TP","Active","ok") end,
        function() dtOn=false; if dtCharConn then dtCharConn:Disconnect();dtCharConn=nil end; Notif("Death TP","Off","") end)

    MkSep(P,"TP Aura",59)
    local tpAuraDelay=0
    local function startTPAura()
        if tpAuraConn then tpAuraConn:Disconnect();tpAuraConn=nil end
        local alive=true
        task.spawn(function()
            while alive and tpAuraOn do
                local mc=lp.Character; local mHRP=mc and mc:FindFirstChild("HumanoidRootPart")
                if mHRP then
                    local arena=findArena()
                    local best,bestD=nil,math.huge
                    for _,p in Players:GetPlayers() do
                        if not IsTarget(p) then continue end; local c=p.Character; if not c then continue end
                        local hrp=c:FindFirstChild("HumanoidRootPart"); local hum=c:FindFirstChildOfClass("Humanoid")
                        if hrp and hum and hum.Health>0 then
                            local d=(hrp.Position-mHRP.Position).Magnitude; if d<bestD then bestD=d; best=hrp end
                        end
                    end
                    if best and arena then
                        local halfSize=arena.Size/2
                        local randLocal=Vector3.new(
                            (math.random()-0.5)*2*(halfSize.X-2),
                            halfSize.Y+2,
                            (math.random()-0.5)*2*(halfSize.Z-2)
                        )
                        local worldPos=arena.CFrame:PointToWorldSpace(randLocal)
                        mHRP.CFrame=CFrame.new(worldPos)
                        mHRP.AssemblyLinearVelocity=Vector3.zero
                        task.wait()
                        mHRP.CFrame=CFrame.new(best.Position+Vector3.new(0,2,0))
                        mHRP.AssemblyLinearVelocity=Vector3.zero
                    elseif best then
                        mHRP.CFrame=CFrame.new(best.Position+Vector3.new(0,2,0))
                        mHRP.AssemblyLinearVelocity=Vector3.zero
                    end
                end
                if tpAuraDelay>0 then task.wait(tpAuraDelay/20) else task.wait() end
                if not alive then break end
            end
        end)
        tpAuraConn=TC({Disconnect=function() alive=false end} :: any)
    end
    MkToggle(P,"TP AURA",60,
        function() tpAuraOn=true; startTPAura(); Notif("TP Aura","Active","ok") end,
        function() tpAuraOn=false; if tpAuraConn then tpAuraConn:Disconnect();tpAuraConn=nil end; Notif("TP Aura","Off","") end)
    MkSlider(P,"TP AURA DELAY (0=instant)",0,100,0,61,function(v) tpAuraDelay=v end)

    MkSep(P,"Auto Farm",62)
    local function inArena(char)
        local arena=findArena(); if not arena then return true end
        local hrp=char:FindFirstChild("HumanoidRootPart'); if not hrp then return false end
        local rel=arena.CFrame:PointToObjectSpace(hrp.Position); local sz=arena.Size/2
        return math.abs(rel.X)<=sz.X+8 and math.abs(rel.Y)<=sz.Y+8 and math.abs(rel.Z)<=sz.Z+8
    end
    local function startAFK()
        if afkConn then afkConn:Disconnect() end
        local t=0
        afkConn=TC(RunSvc.Heartbeat:Connect(function(dt)
            if not afkOn then return end
            t=t+dt; if t<0.04 then return end; t=0
            local mc=lp.Character; if not mc then return end
            local mHRP=mc:FindFirstChild("HumanoidRootPart"); if not mHRP then return end
            local mHum=mc:FindFirstChildOfClass("Humanoid"); if not mHum or mHum.Health<=0 then return end
            local best,bestD=nil,math.huge
            for _,p in Players:GetPlayers() do
                if not IsTarget(p) then continue end
                local c=p.Character; if not c then continue end
                local hum=c:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health<=0 then continue end
                if not inArena(c) then continue end
                local hrp2=c:FindFirstChild("HumanoidRootPart"); if not hrp2 then continue end
                local d=(hrp2.Position-mHRP.Position).Magnitude; if d<bestD then bestD=d; best=p end
            end
            if not best or not best.Character then
                local arena=findArena()
                if arena and not inArena(mc) then mHRP.CFrame=arena.CFrame*CFrame.new(0,3,0); mHRP.AssemblyLinearVelocity=Vector3.zero end
                return
            end
            local tHead=best.Character:FindFirstChild("Head"); if not tHead then return end
            local tHum2=best.Character:FindFirstChildOfClass("Humanoid"); if not tHum2 then return end
            mHRP.CFrame=CFrame.new(tHead.Position+Vector3.new(0,2.5,0)); mHRP.AssemblyLinearVelocity=Vector3.zero
            if tHum2.Health>0 then
                pcall(function() if RF.PunchDo then RF.PunchDo:InvokeServer() end end)
                pcall(function() if RF.Hit then RF.Hit:InvokeServer(tHum2,vector.create(mHRP.Position.X,mHRP.Position.Y,mHRP.Position.Z)) end end)
            end
        end))
    end
    MkToggle(P,"AUTO FARM",63,
        function() afkOn=true; startAFK(); Notif("Auto Farm","Active","ok") end,
        function() afkOn=false; if afkConn then afkConn:Disconnect();afkConn=nil end; Notif("Auto Farm","Off","") end)
    RegKB("Auto Farm",Enum.KeyCode.B,function()
        afkOn=not afkOn
        if afkOn then startAFK(); Notif("Auto Farm","Active","ok") else if afkConn then afkConn:Disconnect();afkConn=nil end; Notif("Auto Farm","Off","") end
    end)

    MkSep(P,"Fake Lag",64)
    local flConn; local fl2Conn; local fl3Conn
    MkToggle(P,"FAKE LAG - JITTER",65,
        function()
            flConn=TC(RunSvc.Heartbeat:Connect(function()
                local c=lp.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                hrp.CFrame=hrp.CFrame*CFrame.new((math.random()-.5)*1.2,(math.random()-.5)*.5,(math.random()-.5)*1.2)
            end))
            Notif("Fake Lag","Jitter active","ok")
        end,
        function() if flConn then flConn:Disconnect();flConn=nil end; Notif("Fake Lag","Off","") end)
    MkToggle(P,"FAKE LAG - FREEZE (2s loop)",66,
        function()
            local on=true
            fl2Conn=TC({Disconnect=function() on=false end} :: any)
            task.spawn(function()
                while on do
                    local c=lp.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
                    if hrp then local cf=hrp.CFrame; task.wait(2); if hrp and hrp.Parent then hrp.CFrame=cf end end
                    task.wait(0.1)
                end
            end)
            Notif("Fake Lag","Freeze loop active","ok")
        end,
        function() Notif("Fake Lag","Off","") end)
    MkToggle(P,"FAKE LAG - BLINK",67,
        function()
            fl3Conn=TC(RunSvc.Heartbeat:Connect(function()
                if math.random(1,8)~=1 then return end
                local c=lp.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                local orig=hrp.CFrame
                hrp.CFrame=CFrame.new(orig.Position+Vector3.new(math.random(-8,8),0,math.random(-8,8)))
                task.wait(); if hrp and hrp.Parent then hrp.CFrame=orig end
            end))
            Notif("Fake Lag","Blink active","ok")
        end,
        function() if fl3Conn then fl3Conn:Disconnect();fl3Conn=nil end; Notif("Fake Lag","Off","") end)
end

-- ═══════════════════════════════════════
-- TAB 3: RP COLOR
-- ═══════════════════════════════════════
do
    local P=tabPanels[3]
    local rpOn=false; local rpConn; local rpSpd=SAVE.rpSpeed; local rpMode="rainbow"
    local bioPhrasesOn=false; local _phraseTask=nil; local _currentPhrase=""
    local _userPhrases={}; local nameTypewriter=SAVE.nameTypewriter; local bioTypeSpeed=SAVE.bioTypeSpeed; local rpNameIdx=1
    
    local function parseUserPhrases(s)
        _userPhrases={}
        for line in (s or ""):gmatch("[^\n]+") do
            local t=line:match("^%s*(.-)%s*$")
            if t~="" then insert(_userPhrases,t) end
        end
        if #_userPhrases==0 then insert(_userPhrases,"XYRO!") end
    end
    parseUserPhrases(SAVE.phrases)
    
    local function startPhrases()
        if _phraseTask then task.cancel(_phraseTask) end
        _phraseTask=spawn(function()
            while bioPhrasesOn do
                local s=_userPhrases[random(1,#_userPhrases)]
                local t=""
                local delay=1/(bioTypeSpeed or 10)
                for u=1,#s do
                    if not bioPhrasesOn then break end
                    t=string.sub(s,1,u); _currentPhrase=t; wait(delay)
                end
                wait(0.05); _currentPhrase=""
            end
        end)
    end
    
    local function stopPhrases()
        bioPhrasesOn=false
        if _phraseTask then task.cancel(_phraseTask);_phraseTask=nil end
        _currentPhrase=""
    end
    
    local function startRP()
        if rpConn then rpConn:Disconnect() end
        local accB=0; local accR=0; local bioT=0; local rpT=0; local nameT=0
        local PHASE=0.22
        
        rpConn=TC(RunSvc.RenderStepped:Connect(function(dt)
            if not rpOn then return end
            local spd=rpSpd*0.05
            accB=accB+dt*spd; accR=accR+dt*spd; bioT=bioT+dt; rpT=rpT+dt; nameT=nameT+dt
            
            if bioT>=0.06 and bioPhrasesOn and _currentPhrase~="" then
                bioT=0
                pcall(function() if RF.UpdateBio then RF.UpdateBio:FireServer(_currentPhrase) end end)
            elseif bioT>=0.06 then bioT=0 end
            
            if nameTypewriter and nameT>=0.1 then
                nameT=0
                local fullName=lp.DisplayName
                pcall(function()
                    if RF.UpdateRPName then RF.UpdateRPName:FireServer(string.sub(fullName,1,rpNameIdx)) end
                end)
                rpNameIdx=rpNameIdx>=#fullName and 1 or rpNameIdx+1
            end
            
            if rpT>=0.05 then
                rpT=0
                local cB,cR
                
                if rpMode=="rainbow" then
                    cB=Color3.fromHSV((accB+PHASE)%1,0.65,0.98)
                    cR=Color3.fromHSV(accR%1,0.65,0.98)
                elseif rpMode=="bw" then
                    local v=(math.sin(accB*6)+1)/2
                    cB=Color3.new(v,v,v); cR=cB
                elseif rpMode=="strobe" then
                    local s=random(0,1)==1
                    cB=s and Color3.new(1,1,1) or Color3.new(0,0,0); cR=cB
                elseif rpMode=="pastel" then
                    cB=Color3.fromHSV((accB+PHASE)%1,0.35,0.99)
                    cR=Color3.fromHSV(accR%1,0.35,0.99)
                elseif rpMode=="neon" then
                    cB=Color3.fromHSV((accB+PHASE)%1,1,1)
                    cR=Color3.fromHSV(accR%1,1,1)
                elseif rpMode=="fire" then
                    local h=(accB*0.1)%0.15
                    cB=Color3.fromHSV(h,0.9,1); cR=Color3.fromHSV((accR*0.1)%0.15,0.9,1)
                elseif rpMode=="ice" then
                    local h=0.55+(accB*0.05)%0.1
                    cB=Color3.fromHSV(h,0.7,0.95); cR=Color3.fromHSV(0.55+(accR*0.05)%0.1,0.7,0.95)
                elseif rpMode=="toxic" then
                    local h=0.3+(accB*0.08)%0.15
                    cB=Color3.fromHSV(h,0.85,0.95); cR=Color3.fromHSV(0.3+(accR*0.08)%0.15,0.85,0.95)
                elseif rpMode=="galaxy" then
                    local h=(accB*0.2)%1
                    cB=Color3.fromHSV(h,0.8,0.9); cR=Color3.fromHSV((accR*0.2)%1,0.8,0.9)
                elseif rpMode=="sunset" then
                    local h=(accB*0.12)%0.25
                    cB=Color3.fromHSV(h,0.8,1); cR=Color3.fromHSV((accR*0.12)%0.25,0.8,1)
                elseif rpMode=="ocean" then
                    local h=0.5+(accB*0.06)%0.2
                    cB=Color3.fromHSV(h,0.7,0.95); cR=Color3.fromHSV(0.5+(accR*0.06)%0.2,0.7,0.95)
                elseif rpMode=="matrix" then
                    local g=random()>0.7 and 1 or 0.2
                    cB=Color3.fromRGB(0,g*255,0); cR=cB
                elseif rpMode=="vaporwave" then
                    local h=(accB*0.15)%1
                    cB=Color3.fromHSV(h,0.6,1); cR=Color3.fromHSV((accR*0.15)%1,0.6,1)
                elseif rpMode=="crimson" then
                    local v=(math.sin(accB*4)+1)/2
                    cB=Color3.fromRGB(255,v*100,v*100); cR=cB
                elseif rpMode=="gold" then
                    local v=(math.sin(accB*3)+1)/2
                    cB=Color3.fromRGB(255,200+v*55,0); cR=cB
                end
                
                if cB then pcall(function() if RF.UpdateBioColor then RF.UpdateBioColor:FireServer(cB) end end) end
                if cR then pcall(function() if RF.UpdateRPColor then RF.UpdateRPColor:FireServer(cR) end end) end
            end
        end))
    end
    
    local _,_,rpSet=MkToggle(P,"RP COLOR",1,
        function() rpOn=true; startRP(); Notif("RP Color","Active","ok") end,
        function() rpOn=false; if rpConn then rpConn:Disconnect();rpConn=nil end; Notif("RP Color","Off","") end)
    RegKB("RP Color",Enum.KeyCode.R,function()
        rpOn=not rpOn; rpSet(rpOn)
        if rpOn then startRP(); Notif("RP Color","Active","ok") else if rpConn then rpConn:Disconnect();rpConn=nil end; Notif("RP Color","Off","") end
    end)
    
    MkSlider(P,"COLOR SPEED",1,100,SAVE.rpSpeed,2,function(v)
        rpSpd=v; SAVE.rpSpeed=v; task.delay(.5,DoSave); if rpOn then startRP() end
    end)
    
    local modeCard=MkCard(P,158,3)
    MkLabel(modeCard,{text="COLOR MODE",size=7,color=T.DIM,font=Bold,sz=UDim2.new(1,-28,0,10),pos=UDim2.new(0,14,0,7),z=14})
    
    local modes={"Rainbow","B+W","Neon","Pastel","Strobe","Fire","Ice","Toxic","Galaxy","Sunset","Ocean","Matrix","Vaporwave","Crimson","Gold"}
    local modeKeys={"rainbow","bw","neon","pastel","strobe","fire","ice","toxic","galaxy","sunset","ocean","matrix","vaporwave","crimson","gold"}
    
    local mRows={}
    for r=1,5 do
        local row=Instance.new("Frame",modeCard)
        row.Size=UDim2.new(1,-28,0,24); row.Position=UDim2.new(0,14,0,20+(r-1)*26)
        row.BackgroundTransparency=1; row.BorderSizePixel=0
        LL(row,4,Enum.FillDirection.Horizontal)
        insert(mRows,row)
    end
    
    local mBtns={}
    for i,lbl in ipairs(modes) do
        local key=modeKeys[i]
        local row=mRows[math.ceil(i/3)]
        local active=(key==rpMode)
        local b=MkBtn(row,{text=lbl,size=7,bg=active and T.ACCENT or T.RAISED,color=active and T.BG or T.TEXT,sz=UDim2.new(0.33,-3,1,0),corner=5,bgt=0,order=i,z=15})
        b.MouseButton1Click:Connect(function()
            rpMode=key
            for _,bt in ipairs(mBtns) do Tw(bt.b,{BackgroundColor3=T.RAISED,TextColor3=T.TEXT},0.14) end
            Tw(b,{BackgroundColor3=T.ACCENT,TextColor3=T.BG},0.14)
            if rpOn then startRP() end
        end)
        insert(mBtns,{b=b,k=key})
    end
    
    MkToggle(P,"NAME TYPEWRITER",4,
        function()
            nameTypewriter=true; SAVE.nameTypewriter=true; task.delay(.5,DoSave)
            rpNameIdx=1; Notif("Name Typewriter","Active","ok")
        end,
        function()
            nameTypewriter=false; SAVE.nameTypewriter=false; task.delay(.5,DoSave)
            pcall(function() if RF.UpdateRPName then RF.UpdateRPName:FireServer(lp.DisplayName) end end)
            Notif("Name Typewriter","Off","")
        end)
    
    MkToggle(P,"BIO PHRASES",5,
        function() bioPhrasesOn=true; startPhrases(); Notif("Bio Phrases","Active","ok") end,
        function() stopPhrases(); Notif("Bio Phrases","Off","") end)
    
    MkSlider(P,"BIO TYPE SPEED",1,250,SAVE.bioTypeSpeed,6,function(v)
        bioTypeSpeed=v; SAVE.bioTypeSpeed=v; task.delay(.5,DoSave)
    end)
    
    local phCard=MkCard(P,106,7)
    MkLabel(phCard,{text="PHRASES (one per line)",size=7,color=T.DIM,font=Bold,sz=UDim2.new(1,-28,0,10),pos=UDim2.new(0,14,0,7),z=14})
    local phBox=Instance.new("TextBox",phCard)
    phBox.Size=UDim2.new(1,-28,0,78); phBox.Position=UDim2.new(0,14,0,22)
    phBox.BackgroundColor3=T.RAISED; phBox.BackgroundTransparency=0.2
    phBox.FontFace=Reg; phBox.TextSize=9; phBox.TextColor3=T.TEXT
    phBox.PlaceholderColor3=T.DIM; phBox.PlaceholderText="One phrase per line..."
    phBox.Text=SAVE.phrases; phBox.ClearTextOnFocus=false; phBox.BorderSizePixel=0
    phBox.TextXAlignment=Enum.TextXAlignment.Left; phBox.TextYAlignment=Enum.TextYAlignment.Top
    phBox.MultiLine=true; phBox.ZIndex=15; Cnr(phBox,6); LP(phBox,6,6,4,4)
    local phS=Strk(phBox,T.BORDER,1,0.4)
    phBox.Focused:Connect(function() Tw(phS,{Transparency=0,Color=T.ACCENT},0.14) end)
    phBox.FocusLost:Connect(function()
        Tw(phS,{Transparency=0.4,Color=T.BORDER},0.14)
        SAVE.phrases=phBox.Text; parseUserPhrases(SAVE.phrases); task.delay(.5,DoSave)
    end)
end

-- ═══════════════════════════════════════
-- TAB 4: MOVEMENT
-- ═══════════════════════════════════════
do
    local P=tabPanels[4]
    
    _G.XYRO_tpwOn=false; _G.XYRO_tpwSpd=SAVE.tpwSpeed; local tpwConn
    local function startTPW()
        if tpwConn then tpwConn:Disconnect() end
        tpwConn=TC(RunSvc.RenderStepped:Connect(function(dt)
            if not _G.XYRO_tpwOn then return end
            local ch=lp.Character; if not ch then return end
            local hrp=ch:FindFirstChild("HumanoidRootPart"); local hum=ch:FindFirstChildWhichIsA("Humanoid")
            if not (hrp and hum and hum.Health>0) then return end
            local md=hum.MoveDirection; if
