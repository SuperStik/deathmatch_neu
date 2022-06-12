include"shared.lua"
include"cl_scoreboard.lua"
local boxColor, hudColor = include"cl_taunt.lua"
include"cl_editor.lua"

local convartbl = {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}

local infinite = CreateConVar("dm_infinite", "1", convartbl, "If set, the game will have an infinite round, and the round timer will act as a cleanup timer")
local dm_weapons = CreateConVar("dm_weapons", "1", convartbl, "If enabled, each player will receive weapons on each spawn")
local customweps = CreateConVar("dm_customloadout", "0", convartbl, "Player load-out is assigned by data/deathmatch/, not the code")
local showinfo = CreateConVar("dm_showinfo", "0", convartbl, "Show HUD info when hovering over a player")
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_DrawText = surface.DrawText

surface.CreateFont("TimerNumbers", {
	font = "Verdana",
	size = 32,
	weight = 0,
	additive = true
})

local function timeThink(self)
	local timeleft = math.Round(GetGlobalInt("TimeLeft"))
	self:SetText(timeleft < 3600 and string.FormattedTime(timeleft, "%02i:%02i") or "60:00")
end

local function gameTimerPaint(pnl, w, h)
	draw.RoundedBoxEx(8, 0, 0, w, h, boxColor, nil, nil, true, true)
end

function GetHostName()
	return GetGlobalString("ServerName", "Garry\'s Mod")
end

--[[---------------------------------------------------------
	Name: gamemode:Initialize()
-----------------------------------------------------------]]
function GM:Initialize()
	if IsValid(self.GameTimer) then
		self.GameTimer:Remove()
		self.GameTimer = nil
	end

	if infinite:GetBool() then return end
	self.GameTimer = vgui.CreateX("Panel", GetHUDPanel(), "GameTimer")
	self.GameTimer:SetSize(100, 48)
	self.GameTimer:DockPadding(4, 4, 4, 4)
	self.GameTimer:CenterHorizontal()
	self.GameTimer.Paint = gameTimerPaint
	local roundtime = Label("ST:OP", self.GameTimer)
	roundtime:Dock(FILL)
	roundtime:SetContentAlignment(5)
	roundtime:SetFont("TimerNumbers")
	roundtime:SetColor(hudColor)
	roundtime.Think = timeThink
end

--[[---------------------------------------------------------
	Name: gamemode:InitPostEntity()
-----------------------------------------------------------]]
function GM:InitPostEntity()
	net.Start("PlayerInit")
	net.SendToServer()
end

local function layout(pnl)
	local txt = pnl:GetChild(0)
	local label = pnl:GetChild(1)
	txt:SetSize(48, 16)
	txt:SetPos(0, 0)
	label:SetX(57)
	label:SizeToContents()
end

local function guardrail(pnl, txt)
	if txt == "" then
		pnl:SetText(0)
	end

	pnl:UpdateConvarValue()
	pnl:OnValueChange(pnl:GetText())
end

local function TextEntryLabel(parent, convar, text)
	local tlbl = vgui.CreateX("Panel", parent, "DTextEntryLabel")
	local ishost = LocalPlayer():GetHost()
	tlbl:SetEnabled(ishost)
	tlbl:SetAlpha(ishost and 255 or 75)
	tlbl:SetTall(16)
	tlbl:Dock(TOP)
	tlbl:DockMargin(0, 0, 0, 8)
	tlbl.PerformLayout = layout
	local txt = tlbl:Add("DTextEntry")
	txt:SetEnabled(ishost)
	txt:SetEditable(ishost)
	txt:SetSize(48, 16)
	txt:SetConVar(convar)
	txt:SetNumeric(true)
	txt.OnEnter = guardrail
	local label = Label(text, tlbl)
	label:SetEnabled(ishost)
	label:SetX(57)
	label:SizeToContents()

	return tlbl
end

local function checkbox(parent, convar, text)
	local button = parent:Add("DCheckBoxLabel")
	button:SetEnabled(LocalPlayer():GetHost())
	button:Dock(TOP)
	button:DockMargin(0, 0, 0, 8)
	button:SetConVar(convar)
	button:SetText(text)

	return button
end

local function buttonThink(pnl)
	local bool = LocalPlayer():GetHost() and customweps:GetBool() and dm_weapons:GetBool()
	pnl:SetEnabled(bool)
	pnl:SetCursor(bool and "hand" or "arrow")
end

local function checkThink(pnl)
	pnl:SetEnabled(LocalPlayer():GetHost() and dm_weapons:GetBool() and not customweps:GetBool())
end

local function weaponThink(pnl)
	pnl:SetEnabled(LocalPlayer():GetHost() and dm_weapons:GetBool())
end

local function writeCustom(pnl, txt)
	if txt == "" then
		txt = pnl:GetPlaceholderText()
	end

	file.Write("deathmatch/custom" .. pnl.CustomMode .. ".txt", txt)
end

local function buttonClick(pnl)
	pnl:GetParent():Close()
	local frame = vgui.Create("DFrame", nil, "CustomLoadout")
	frame:SetSize(math.min(ScrW() - 64, 512), ScrH())
	frame:SetTitle("Custom Loadout Settings")
	local Close = frame.Close

	function frame:Close()
		Close(self)
		hook.Run("ShowSpare2")
	end

	local weplbl = Label("Custom Weapons", frame)
	weplbl:Dock(TOP)
	weplbl:DockMargin(0, 0, 0, 4)
	local weptxt = frame:Add("DTextEntry")
	weptxt:Dock(TOP)
	weptxt:DockMargin(0, 0, 0, 8)
	weptxt:SetPlaceholderText("weapon_physcannon;weapon_pistol;weapon_smg1")
	weptxt:SetText(file.Read("deathmatch/customweapons.txt", "DATA"))
	weptxt.CustomMode = "weapons"
	weptxt.OnValueChange = writeCustom
	local wepbtn = frame:Add("DButton")
	wepbtn:Dock(TOP)
	wepbtn:DockMargin(0, 0, 0, 8)
	wepbtn:SetText("Print weapon classes and names to the console")

	function wepbtn:DoClick()
		for k, v in pairs(list.GetForEdit("Weapon")) do
			MsgN(k .. ": " .. v.PrintName)
		end
	end

	local ammlbl = Label("Custom Ammo", frame)
	ammlbl:Dock(TOP)
	ammlbl:DockMargin(0, 0, 0, 4)
	local ammtxt = frame:Add("DTextEntry")
	ammtxt:Dock(TOP)
	ammtxt:DockMargin(0, 0, 0, 8)
	ammtxt:SetPlaceholderText("Pistol:50;SMG1:75;SMG1_Grenade:2")
	ammtxt:SetText(file.Read("deathmatch/customammo.txt", "DATA"))
	ammtxt.CustomMode = "ammo"
	ammtxt.OnValueChange = writeCustom
	local ammbtn = frame:Add("DButton")
	ammbtn:Dock(TOP)
	ammbtn:SetText("Print ammo types to the console")

	function ammbtn:DoClick()
		for k, v in ipairs(game.GetAmmoTypes()) do
			MsgN(v)
		end
	end

	frame:InvalidateLayout(true)
	frame:SizeToChildren(nil, true)
	frame:Center()
	frame:MakePopup()
end

--[[---------------------------------------------------------
	Name: gamemode:ShowSpare2()
-----------------------------------------------------------]]
function GM:ShowSpare2()
	if IsValid(self.OptionsConf) then
		self.OptionsConf:Remove()
		self.OptionsConf = nil
	else
		self.OptionsConf = vgui.Create("DFrame", nil, "OptionsConf")
		self.OptionsConf:SetSize(256, ScrH())
		self.OptionsConf:SetTitle("Game Options")
		TextEntryLabel(self.OptionsConf, "dm_timer", "Round timer")
		TextEntryLabel(self.OptionsConf, "dm_medpacktimer", "Medpack timer")
		checkbox(self.OptionsConf, "dm_infinite", "Infinite mode")
		checkbox(self.OptionsConf, "dm_weapons", "Spawn with weapons")
		checkbox(self.OptionsConf, "dm_grenades", "Spawn with grenades").Think = checkThink
		checkbox(self.OptionsConf, "dm_customloadout", "Use custom weapons").Think = weaponThink
		local button = vgui.Create("DButton", self.OptionsConf)
		button:Dock(TOP)
		button:DockMargin(0, 0, 0, 8)
		button:SetText("Open custom loadout settings")
		button.Think = buttonThink
		button.DoClick = buttonClick
		checkbox(self.OptionsConf, "dm_allplayermodels", "Allow all player models")
		checkbox(self.OptionsConf, "dm_adminnoclip", "Admin noclip")
		local check = self.OptionsConf:Add("DCheckBoxLabel")
		check:SetEnabled(LocalPlayer():GetHost())
		check:Dock(TOP)
		check:SetConVar("dm_playernoclip")
		check:SetText("Player noclip")
		self.OptionsConf:InvalidateLayout(true)
		self.OptionsConf:SizeToChildren(nil, true)
		self.OptionsConf:Center()
		self.OptionsConf:MakePopup()
	end
end

--[[---------------------------------------------------------
	Name: gamemode:StartRound()
-----------------------------------------------------------]]
function GM:StartRound()
	self.RoundEnd = false
	hook.Call("ScoreboardHide", self, true)
	self:Initialize()
end

--[[---------------------------------------------------------
	Name: gamemode:EndRound()
-----------------------------------------------------------]]
function GM:EndRound()
	self.RoundEnd = true
	hook.Call("ScoreboardShow", self)
	surface.PlaySound("buttons/blip1.wav")
end

function GM:Think()
	if LocalPlayer():GetTauntTimer() <= CurTime() then
		hook.Call("HideSpare1", self)
	end
end

function GM:HUDDrawTargetID()
	local trace = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
	if not (trace.Hit or trace.HitNonWorld) then return end
	local text = "ERROR"

	if trace.Entity:IsPlayer() then
		text = trace.Entity:Nick()
	else
		return
	end

	surface.SetFont("TargetID")
	local w, h = surface.GetTextSize(text)
	local MouseX, MouseY = gui.MousePos()

	if MouseX == 0 and MouseY == 0 then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end

	local x = MouseX - w / 2
	local y = MouseY + 30
	local teamcol = self:GetTeamColor(trace.Entity)
	-- The fonts internal drop shadow looks lousy with AA on
	surface_SetTextPos(x + 1, y + 1)
	surface_SetTextColor(0, 0, 0, 120)
	surface_DrawText(text)
	surface_SetTextPos(x + 2, y + 2)
	surface_SetTextColor(0, 0, 0, 50)
	surface_DrawText(text)
	surface_SetTextPos(x, y)
	surface_SetTextColor(teamcol.r, teamcol.g, teamcol.b)
	surface_DrawText(text)

	if showinfo:GetBool() then
		text = trace.Entity:Health() .. "%"
		local armo = trace.Entity:Armor() .. "%"
		y = y + h + 5
		surface.SetFont("TargetIDSmall")
		w, h = surface.GetTextSize(text)
		x = MouseX - w / 2
		surface_SetTextPos(x + 1, y + 1)
		surface_SetTextColor(0, 0, 0, 120)
		surface_DrawText(text)
		surface_SetTextPos(x + 1, y + 16)
		surface_DrawText(armo)
		surface_SetTextPos(x + 2, y + 2)
		surface_SetTextColor(0, 0, 0, 50)
		surface_DrawText(text)
		surface_SetTextPos(x + 2, y + 17)
		surface_DrawText(armo)
		surface_SetTextPos(x, y)
		surface_SetTextColor(teamcol.r, teamcol.g, teamcol.b)
		surface_DrawText(text)
		surface_SetTextPos(x, y + 15)
		surface_DrawText(armo)
	end
end
