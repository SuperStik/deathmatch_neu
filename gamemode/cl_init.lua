include("shared.lua")

local dm_models = {
	female08 = "models/player/Group03/female_02.mdl",
	female05 = "models/player/Group01/female_05.mdl",
	male03 = "models/player/Group01/male_03.mdl",
	medic06 = "models/player/Group03m/male_06.mdl",
	male13 = "models/player/Group03/male_04.mdl",
	medic11 = "models/player/Group03m/female_02.mdl",
	male04 = "models/player/Group01/male_04.mdl",
	medic14 = "models/player/Group03m/female_05.mdl",
	odessa = "models/player/odessa.mdl",
	female11 = "models/player/Group03/female_05.mdl",
	female07 = "models/player/Group03/female_01.mdl",
	css_guerilla = "models/player/guerilla.mdl",
	combineelite = "models/player/combine_super_soldier.mdl",
	male05 = "models/player/Group01/male_05.mdl",
	female06 = "models/player/Group01/female_06.mdl",
	medic05 = "models/player/Group03m/male_05.mdl",
	male07 = "models/player/Group01/male_07.mdl",
	mossmanarctic = "models/player/mossman_arctic.mdl",
	male06 = "models/player/Group01/male_06.mdl",
	refugee03 = "models/player/Group02/male_06.mdl",
	male10 = "models/player/Group03/male_01.mdl",
	breen = "models/player/breen.mdl",
	corpse = "models/player/corpse1.mdl",
	monk = "models/player/monk.mdl",
	female01 = "models/player/Group01/female_01.mdl",
	male15 = "models/player/Group03/male_06.mdl",
	barney = "models/player/barney.mdl",
	medic15 = "models/player/Group03m/female_06.mdl",
	male09 = "models/player/Group01/male_09.mdl",
	css_swat = "models/player/swat.mdl",
	female03 = "models/player/Group01/female_03.mdl",
	male17 = "models/player/Group03/male_08.mdl",
	zombie = "models/player/zombie_classic.mdl",
	female02 = "models/player/Group01/female_02.mdl",
	magnusson = "models/player/magnusson.mdl",
	charple = "models/player/charple.mdl",
	eli = "models/player/eli.mdl",
	skeleton = "models/player/skeleton.mdl",
	dod_american = "models/player/dod_american.mdl",
	dod_german = "models/player/dod_german.mdl",
	css_urban = "models/player/urban.mdl",
	css_riot = "models/player/riot.mdl",
	male01 = "models/player/Group01/male_01.mdl",
	police = "models/player/police.mdl",
	css_leet = "models/player/leet.mdl",
	alyx = "models/player/alyx.mdl",
	medic08 = "models/player/Group03m/male_08.mdl",
	css_gasmask = "models/player/gasmask.mdl",
	zombine = "models/player/zombie_soldier.mdl",
	stripped = "models/player/soldier_stripped.mdl",
	policefem = "models/player/police_fem.mdl",
	kleiner = "models/player/kleiner.mdl",
	male14 = "models/player/Group03/male_05.mdl",
	css_arctic = "models/player/arctic.mdl",
	female12 = "models/player/Group03/female_06.mdl",
	gman = "models/player/gman_high.mdl",
	female04 = "models/player/Group01/female_04.mdl",
	zombiefast = "models/player/zombie_fast.mdl",
	medic02 = "models/player/Group03m/male_02.mdl",
	hostage02 = "models/player/hostage/hostage_02.mdl",
	medic03 = "models/player/Group03m/male_03.mdl",
	combineprison = "models/player/combine_soldier_prisonguard.mdl",
	refugee04 = "models/player/Group02/male_08.mdl",
	refugee02 = "models/player/Group02/male_04.mdl",
	refugee01 = "models/player/Group02/male_02.mdl",
	medic10 = "models/player/Group03m/female_01.mdl",
	male02 = "models/player/Group01/male_02.mdl",
	male12 = "models/player/Group03/male_03.mdl",
	medic07 = "models/player/Group03m/male_07.mdl",
	hostage03 = "models/player/hostage/hostage_03.mdl",
	female10 = "models/player/Group03/female_04.mdl",
	male18 = "models/player/Group03/male_09.mdl",
	css_phoenix = "models/player/phoenix.mdl",
	hostage01 = "models/player/hostage/hostage_01.mdl",
	medic01 = "models/player/Group03m/male_01.mdl",
	hostage04 = "models/player/hostage/hostage_04.mdl",
	male08 = "models/player/Group01/male_08.mdl",
	medic12 = "models/player/Group03m/female_03.mdl",
	male11 = "models/player/Group03/male_02.mdl",
	medic13 = "models/player/Group03m/female_04.mdl",
	medic09 = "models/player/Group03m/male_09.mdl",
	combine = "models/player/combine_soldier.mdl",
	mossman = "models/player/mossman.mdl",
	female09 = "models/player/Group03/female_03.mdl",
	chell = "models/player/p2_chell.mdl",
	medic04 = "models/player/Group03m/male_04.mdl",
	male16 = "models/player/Group03/male_07.mdl"
}

local TauntList = {"1: Good God...", "2: Ha ha! Like that?", "3: Oh no...", "4: Here they come!", "5: Over here!", "6: Get the hell out of here!", "7: Help!", "8: Hi", "9: Okay", "0: Incoming!"}

local convartbl = {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}

local infinite = CreateConVar("dm_infinite", "1", convartbl, "If set, the game will have an infinite round, and the round timer will act as a cleanup timer")
local customweps = CreateConVar("dm_customweapons", "0", convartbl, "Player load-out is assigned by data/deathmatch/, not the code")
local dm_allplayermodels = CreateConVar("dm_allplayermodels", "0", convartbl, "If enabled, players can use custom server-side models")

local cl_playercolor = CreateConVar("cl_playercolor", "0.24 0.34 0.41", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

local cl_playerskin = CreateConVar("cl_playerskin", "0", 131712, "The skin to use, if the model has any")
local cl_playerbodygroups = CreateConVar("cl_playerbodygroups", "0", 131712, "The bodygroups to use, if the model has any")
CreateClientConVar("dm_hidehelp", "0", nil, true, "Prevents the help menu from opening when loading into a game.")
local cl_playermodel = GetConVar("cl_playermodel")
local cheats = GetConVar("sv_cheats")
local boxColor = Color(0, 0, 0, 128)
local deadColo = Color(255, 30, 40)
local voiceCol = Color(61, 66, 212)
local replacetable
local modelskin
local modelpanel
local bodygroups

local function HideSpare1()
	hook.Run("HideSpare1")
end

local function timeThink(self)
	local timeleft = math.Round(GetGlobalInt("TimeLeft"))
	self:SetText(timeleft < 3600 and string.FormattedTime(timeleft, "%02i:%02i") or "60:00")
end

local function playerColor()
	return Vector(cl_playercolor:GetString())
end

local function makeNiceName(str)
	local newname = {}

	for _, s in pairs(string.Explode("_", str)) do
		if #s == 1 then
			table.insert(newname, s:upper())
		else
			table.insert(newname, s:Left(1):upper() .. s:Right(#s - 1)) -- Ugly way to capitalize first letters.
		end
	end

	return table.concat(newname, " ")
end

local function updateBodygroups(pnl, val)
	modelpanel.Entity:SetBodygroup(pnl.num, math.Round(val))
	local str = string.Explode(" ", cl_playerbodygroups:GetString())

	if (#str < pnl.num + 1) then
		for i = 1, pnl.num + 1 do
			str[i] = str[i] or 0
		end
	end

	str[pnl.num + 1] = math.Round(val)
	cl_playerbodygroups:SetString(table.concat(str, " "))
end

local function generateBodygroups(pnl, gm)
	pnl:Clear()

	for k = 0, modelpanel.Entity:GetNumBodyGroups() - 1 do
		if modelpanel.Entity:GetBodygroupCount(k) <= 1 then continue end
		local slider = pnl:Add("DNumSlider")
		slider:Dock(TOP)
		slider:DockMargin(0, 8, 0, 8)
		slider:SetText(makeNiceName(modelpanel.Entity:GetBodygroupName(k)))
		slider:SetDark(true)
		slider:SetTall(50)
		slider:SetDecimals(0)
		slider.num = k
		slider:SetMax(modelpanel.Entity:GetBodygroupCount(k) - 1)
		local groups = string.Explode(" ", cl_playerbodygroups:GetString())
		slider:SetValue(groups[k + 1] or 0)
		slider.OnValueChanged = updateBodygroups
		modelpanel.Entity:SetBodygroup(k, groups[k + 1] or 0)
	end

	pnl:InvalidateLayout(true)
	pnl:SizeToChildren(nil, true)
end

local function gameTimerPaint(pnl, w, h)
	draw.RoundedBoxEx(8, 0, 0, w, h, boxColor, nil, nil, true, true)
end

local function mousePress(pnl)
	pnl.PressX, pnl.PressY = gui.MousePos()
	pnl.Pressed = true
end

local function mouseRelease(pnl)
	pnl.Pressed = false
end

local function dragMove(pnl, ent)
	if (pnl.Pressed) then
		local mx = gui.MousePos()
		pnl.Angles = pnl.Angles - Angle(0, ((pnl.PressX or mx) - mx) / 2, 0)
		pnl.PressX, pnl.PressY = gui.MousePos()
	end

	ent:SetAngles(pnl.Angles)
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
	self.GameTimer = vgui.CreateX("Panel", nil, "GameTimer")
	self.GameTimer:SetSize(96, 48)
	self.GameTimer:DockPadding(4, 4, 4, 4)
	self.GameTimer:CenterHorizontal()
	self.GameTimer.Paint = gameTimerPaint
	local roundtime = Label("ST:OP", self.GameTimer)
	roundtime:Dock(FILL)
	roundtime:SetContentAlignment(5)
	roundtime:SetFont("DermaLarge")
	roundtime:SetBright(true)
	roundtime.Think = timeThink
end

--[[---------------------------------------------------------
	Name: gamemode:InitPostEntity()
-----------------------------------------------------------]]
function GM:InitPostEntity()
	net.Start("PlayerInit")
	net.SendToServer()
end

--[[---------------------------------------------------------
	Name: gamemode:ShowHelp()
-----------------------------------------------------------]]
function GM:ShowHelp()
	if IsValid(self.HelpFrame) then return end
	self.HelpFrame = vgui.Create("DFrame")
	self.HelpFrame:SetTitle("Help")
	local width = math.min(ScrW() - 64, 516)
	self.HelpFrame:SetSize(width, ScrH())
	self.HelpFrame.btnMinim:SetCursor("arrow")
	self.HelpFrame.btnMaxim:SetCursor("arrow")
	local title = Label("Welcome to Deathmatch!", self.HelpFrame)
	title:Dock(TOP)
	title:SetFont("DermaLarge")
	title:SetContentAlignment(8)
	title:SetAutoStretchVertical(true)
	local text = Label("Here, your goal is to kill each other (pretty obvious because of the name). Pressing " .. input.LookupBinding("gm_showteam") .. " opens the panel to change your player model, and pressing " .. input.LookupBinding("gm_showspare1") .. " opens the taunt menu. You can press " .. input.LookupBinding("gm_showhelp"):upper() .. " to show this menu again. Press " .. input.LookupBinding("gm_showspare2") .. " to view the server options.", self.HelpFrame)
	text:Dock(TOP)
	text:SetWrap(true)
	text:SetContentAlignment(8)
	local btn = vgui.Create("DButton", self.HelpFrame)
	local widthd3 = width / 3
	btn:SetTall(30)
	btn:Dock(TOP)
	btn:DockMargin(widthd3, 4, widthd3, 0)
	btn:SetText("Close")
	btn.DoClick = self.HelpFrame.btnClose.DoClick
	local check = vgui.Create("DCheckBoxLabel", self.HelpFrame)
	check:SetText("Do not auto-show again")
	check:AlignRight()
	check:SetPos(check:GetX() - 4, 118)
	check:SetConVar("dm_hidehelp")
	text:SetAutoStretchVertical(true)
	self.HelpFrame:InvalidateLayout(true)
	self.HelpFrame:SizeToChildren(nil, true)
	self.HelpFrame:SetTall(self.HelpFrame:GetTall() + 8)
	self.HelpFrame:Center()
	self.HelpFrame:MakePopup()
end

--[[---------------------------------------------------------
	Name: gamemode:ShowTeam()
-----------------------------------------------------------]]
function GM:ShowTeam()
	if (IsValid(self.TeamSelectFrame)) then return end
	replacetable = dm_allplayermodels:GetBool() and player_manager.AllValidModels() or dm_models
	-- Simple team selection box
	self.TeamSelectFrame = vgui.Create("DFrame", nil, "PlayerModelSelector")
	self.TeamSelectFrame:SetTitle("#smwidget.playermodel_title")
	self.TeamSelectFrame:SetSize(math.min(ScrW() - 64, 516), math.min(ScrH() - 64, 508))
	local tabsheet = self.TeamSelectFrame:Add("DPropertySheet")
	tabsheet:Dock(FILL)
	tabsheet:DockPadding(8, 0, 8, 8)
	local teampanel = vgui.Create("DPanel")
	teampanel:Dock(FILL)
	teampanel:DockPadding(8, 8, 8, 8)
	local parentpanel = vgui.CreateX("Panel", teampanel)
	parentpanel:Dock(TOP)
	parentpanel:DockMargin(0, 0, 0, 4)
	parentpanel:SetTall(math.min(self.TeamSelectFrame:GetTall() / 3, 260))
	local button = parentpanel:Add("DButton")
	button:SetText("Update Now")
	button:Dock(LEFT)
	button:SetWide(96)
	button:DockMargin(0, 64, 4, 64)

	function button:DoClick()
		RunConsoleCommand("dm_instantchange")
	end

	local colormixer = vgui.Create("DColorMixer", parentpanel)
	colormixer:SetAlphaBar(false)
	colormixer:SetPalette(false)
	colormixer:Dock(TOP)
	colormixer:SetTall(math.min(parentpanel:GetTall(), 260))
	colormixer:SetVector(Vector(cl_playercolor:GetString()))

	colormixer.ValueChanged = function()
		cl_playercolor:SetString(tostring(colormixer:GetVector()))
	end

	local searchbar = vgui.Create("DTextEntry", teampanel)
	searchbar:Dock(TOP)
	searchbar:DockMargin(0, 0, 0, 2)
	searchbar:SetUpdateOnType(true)
	searchbar:SetPlaceholderText("#spawnmenu.quick_filter")
	local modellist = vgui.Create("DPanelSelect", teampanel)
	modellist:Dock(FILL)

	for k, v in SortedPairs(replacetable) do
		local icon = vgui.Create("SpawnIcon")
		icon:SetModel(v)
		icon:SetSize(64, 64)
		icon:SetTooltip(k)
		icon.playermodel = k
		icon.model_path = v

		icon.OpenMenu = function(ico)
			local menu = DermaMenu()

			menu:AddOption("#spawnmenu.menu.copy", function()
				SetClipboardText(v)
			end):SetIcon("icon16/page_copy.png")

			menu:Open()
		end

		modellist:AddPanel(icon, {
			cl_playermodel = k
		})
	end

	searchbar.OnValueChange = function(s, str)
		for id, pnl in pairs(modellist:GetItems()) do
			if (not pnl.playermodel:find(str, 1, true) and not pnl.model_path:find(str, 1, true)) then
				pnl:SetVisible(false)
			else
				pnl:SetVisible(true)
			end
		end

		modellist:InvalidateLayout()
	end

	tabsheet:AddSheet("#smwidget.model", teampanel, "icon16/user.png", false, false, "Select a playermodel")
	local mainpnl = vgui.CreateX("Panel")
	mainpnl:Dock(FILL)
	mainpnl:InvalidateParent()
	local skinpnl = mainpnl:Add("DScrollPanel")
	skinpnl:SetPaintBackground(true)
	local curwide = (self.TeamSelectFrame:GetWide() / 2) - 12
	skinpnl:SetWide(curwide)
	skinpnl:Dock(RIGHT)
	skinpnl:DockMargin(4, 0, 0, 0)
	skinpnl:DockPadding(8, 8, 8, 8)

	if IsValid(skinpnl.VBar) then
		skinpnl.VBar:SetWide(13)
	end

	local skinlabel = Label("Skin", skinpnl)
	skinlabel:Dock(TOP)
	skinlabel:DockMargin(8, 8, 0, 2)
	skinlabel:SetDark(true)
	modelskin = skinpnl:Add("DNumberWang")
	modelskin:Dock(TOP)
	modelskin:DockMargin(8, 0, (curwide / 3) * 2, 0)
	modelskin:SetConVar("cl_playerskin")
	local skinmax = NumModelSkins(player_manager.TranslatePlayerModel(cl_playermodel:GetString())) - 1
	modelskin:SetMax(skinmax)
	modelskin:SetMin(0)
	modelskin:SetValue(cl_playerskin:GetInt())
	modelskin:SetEnabled(skinmax > 0)
	modelskin:SetEditable(skinmax > 0)
	bodygroups = skinpnl:Add("Panel")
	bodygroups:Dock(TOP)
	bodygroups:DockPadding(8, 8, 8, 8)
	--bodygroups:SetTall(curwide)
	modelpanel = mainpnl:Add("DModelPanel")
	modelpanel:SetWide(curwide)
	modelpanel:Dock(LEFT)
	modelpanel:DockMargin(0, 0, 4, 0)
	modelpanel:SetModel(replacetable[cl_playermodel:GetString()] or "models/player/kleiner.mdl")
	modelpanel.Angles = angle_zero
	modelpanel.DragMousePress = mousePress
	modelpanel.DragMouseRelease = mouseRelease
	modelpanel.LayoutEntity = dragMove
	modelpanel.Entity.GetPlayerColor = playerColor
	modelpanel:SetFOV(40)
	generateBodygroups(bodygroups, self)
	tabsheet:AddSheet("#smwidget.bodygroups", mainpnl, "icon16/cog.png", false, false, "Select bodygroups and skins")
	self.TeamSelectFrame:Center()
	self.TeamSelectFrame:MakePopup()
end

cvars.AddChangeCallback("cl_playermodel", function(_, __, val)
	if IsValid(modelskin) then
		modelskin:SetValue(0)
		local mdlnum = NumModelSkins(player_manager.TranslatePlayerModel(GetConVar("cl_playermodel"):GetString())) - 1
		modelskin:SetMax(mdlnum)
		modelskin:SetEnabled(mdlnum > 0)
		modelskin:SetEditable(mdlnum > 0)
		modelskin:InvalidateLayout()
	end

	if IsValid(modelpanel) then
		modelpanel:SetModel(replacetable[val])
		modelpanel.Entity.GetPlayerColor = playerColor
	end

	if IsValid(bodygroups) then
		cl_playerbodygroups:SetString(0)
		generateBodygroups(bodygroups, GAMEMODE)
		bodygroups:InvalidateLayout()
	end
end)

cvars.AddChangeCallback("cl_playerskin", function(_, __, val)
	if IsValid(modelpanel) then
		modelpanel.Entity:SetSkin(val)
	end
end)

--[[---------------------------------------------------------
	Name: gamemode:ShowSpare1()
-----------------------------------------------------------]]
function GM:ShowSpare1()
	if IsValid(self.TauntTextPanel) then
		self:HideSpare1()

		return
	end

	self.TauntTextPanel = vgui.CreateX("Panel", GetHUDPanel(), "TauntMenu")
	self.TauntTextPanel:SetSize(ScrW() / 8, 265)
	self.TauntTextPanel:SetPos(25, ScrH() / 6)

	self.TauntTextPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, boxColor)
	end

	self.TauntTextPanel:DockPadding(10, 10, 10, 10)

	for k, v in ipairs(TauntList) do
		self.TauntTextPanel["Option" .. k] = Label(v, self.TauntTextPanel)
		self.TauntTextPanel["Option" .. k]:Dock(TOP)

		if k ~= 10 then
			self.TauntTextPanel["Option" .. k]:DockMargin(0, 0, 0, 5)
		end

		self.TauntTextPanel["Option" .. k]:SetBright(true)
	end

	timer.Create("HideSpare1", 2, 1, HideSpare1)
end

--[[---------------------------------------------------------
	Name: gamemode:HideSpare1()
-----------------------------------------------------------]]
function GM:HideSpare1()
	timer.Remove("HideSpare1")

	if IsValid(self.TauntTextPanel) then
		self.TauntTextPanel:Remove()
	end

	self.TauntTextPanel = nil
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
	tlbl:SetTall(16)
	tlbl:Dock(TOP)
	tlbl:DockMargin(0, 0, 0, 8)
	tlbl.PerformLayout = layout
	local txt = vgui.Create("DTextEntry", tlbl)
	txt:SetEnabled(ishost)
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
	local bool = LocalPlayer():GetHost() and customweps:GetBool()
	pnl:SetEnabled(bool)
	pnl:SetCursor(bool and "hand" or "arrow")
end

local function checkThink(pnl)
	pnl:SetEnabled(LocalPlayer():GetHost() and not customweps:GetBool())
end

local function buttonClick(pnl)
	pnl:GetParent():Close()
	local frame = vgui.Create("DFrame", nil, "CustomWeapons")
	frame:SetSize(math.min(ScrW() - 64, 512), ScrH())
	frame:SetTitle("Custom Weapon Scripts")
	local Close = frame.Close

	frame.Close = function(self)
		Close(self)
		hook.Run("ShowSpare2")
	end

	local weplbl = Label("Custom Weapons", frame)
	weplbl:Dock(TOP)
	weplbl:DockMargin(0, 0, 0, 8)
	local weptxt = frame:Add("DTextEntry")
	weptxt:Dock(TOP)
	weptxt:DockMargin(0, 0, 0, 8)
	weptxt:SetPlaceholderText("weapon_physcannon;weapon_pistol")
	local ammlbl = Label("Custom Ammo", frame)
	ammlbl:Dock(TOP)
	ammlbl:DockMargin(0, 0, 0, 8)
	local ammtxt = frame:Add("DTextEntry")
	ammtxt:Dock(TOP)
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
		local grenades = checkbox(self.OptionsConf, "dm_grenades", "Spawn with grenades")
		grenades.Think = checkThink
		checkbox(self.OptionsConf, "dm_customweapons", "Use custom weapons")
		local button = vgui.Create("DButton", self.OptionsConf)
		button:Dock(TOP)
		button:DockMargin(0, 0, 0, 8)
		button:SetText("Open custom weapon scripts")
		button.Think = buttonThink
		button.DoClick = buttonClick
		checkbox(self.OptionsConf, "dm_allplayermodels", "Allow all player models")
		checkbox(self.OptionsConf, "dm_adminnoclip", "Admin noclip")
		local check = self.OptionsConf:Add("DCheckBoxLabel")
		check:SetEnabled(LocalPlayer():GetHost() and cheats:GetBool())
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
	Name: gamemode:PlayerBindPress()
-----------------------------------------------------------]]
function GM:PlayerBindPress(ply, bind)
	local textpos = string.find(bind, "slot")

	if ply:GetShowTaunts() and textpos == 1 then
		local curtime = CurTime()

		if ply:GetNextTaunt() <= curtime then
			net.Start("SendTaunt")
			net.WriteUInt(tonumber(string.Right(bind, 1)), 4)
			net.SendToServer()
		end

		self:HideSpare1()

		return true
	end

	return false
end

--[[---------------------------------------------------------
	Name: gamemode:OnPlayerTaunt()
-----------------------------------------------------------]]
net.Receive("SendTaunt", function()
	local ply = Entity(net.ReadUInt(8))
	hook.Run("OnPlayerTaunt", ply, net.ReadUInt(4), not ply:Alive())
end)

function GM:OnPlayerTaunt(ply, num, dead)
	local tab = {}

	if dead then
		table.insert(tab, deadColo)
		table.insert(tab, "*DEAD* ")
	end

	table.insert(tab, voiceCol)
	table.insert(tab, "(VOICE) ")

	if IsValid(ply) then
		table.insert(tab, ply)
	else
		table.insert(tab, "Console")
	end

	table.insert(tab, color_white)
	table.insert(tab, ": " .. string.sub(TauntList[num ~= 0 and num or 10], 4))
	chat.AddText(unpack(tab))
end

--[[---------------------------------------------------------
	Name: gamemode:StartRound()
-----------------------------------------------------------]]
function GM:StartRound()
	self.RoundEnd = false
	hook.Run("ScoreboardHide", true)
	self:Initialize()
end

--[[---------------------------------------------------------
	Name: gamemode:EndRound()
-----------------------------------------------------------]]
function GM:EndRound()
	self.RoundEnd = true
	hook.Run("ScoreboardShow")
	surface.PlaySound("buttons/blip1.wav")
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
	surface.SetTextPos(x + 1, y + 1)
	surface.SetTextColor(0, 0, 0, 120)
	surface.DrawText(text)
	surface.SetTextPos(x + 2, y + 2)
	surface.SetTextColor(0, 0, 0, 50)
	surface.DrawText(text)
	surface.SetTextPos(x, y)
	surface.SetTextColor(teamcol.r, teamcol.g, teamcol.b)
	surface.DrawText(text)
	text = trace.Entity:Health() .. "%"
	local armo = trace.Entity:Armor() .. "%"
	y = y + h + 5
	surface.SetFont("TargetIDSmall")
	w, h = surface.GetTextSize(text)
	x = MouseX - w / 2
	surface.SetTextPos(x + 1, y + 1)
	surface.SetTextColor(0, 0, 0, 120)
	surface.DrawText(text)
	surface.SetTextPos(x + 1, y + 16)
	surface.DrawText(armo)
	surface.SetTextPos(x + 2, y + 2)
	surface.SetTextColor(0, 0, 0, 50)
	surface.DrawText(text)
	surface.SetTextPos(x + 2, y + 17)
	surface.DrawText(armo)
	surface.SetTextPos(x, y)
	surface.SetTextColor(teamcol.r, teamcol.g, teamcol.b)
	surface.DrawText(text)
	surface.SetTextPos(x, y + 15)
	surface.DrawText(armo)
end