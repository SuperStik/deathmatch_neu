local dm_allplayermodels = CreateConVar("dm_allplayermodels", "0", 8576, "If enabled, players can use custom server-side models")
local cl_playercolor = CreateConVar("cl_playercolor", "0.24 0.34 0.41", 131712, "The value is a Vector - so between 0-1 - not between 0-255")
local cl_playerskin = CreateConVar("cl_playerskin", "0", 131712, "The skin to use, if the model has any")
local cl_playerbodygroups = CreateConVar("cl_playerbodygroups", "0", 131712, "The bodygroups to use, if the model has any")
local cl_playermodel = GetConVar("cl_playermodel")
local replacetable
local modelskin
local modelpanel
local bodygroups

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

local function changeClick()
	RunConsoleCommand("dm_instantchange")
end

local function changeThink(pnl)
	local alive = LocalPlayer():Alive()
	pnl:SetEnabled(alive)
	pnl:SetCursor(alive and "hand" or "arrow")
end

local function mousePress(pnl)
	pnl.PressX, pnl.PressY = gui.MousePos()
	pnl.Pressed = true
end

local function mouseRelease(pnl)
	pnl.Pressed = false
end

local function dragMove(pnl, ent)
	if pnl.Pressed then
		local mx = gui.MousePos()
		pnl.Angles = pnl.Angles - Angle(0, ((pnl.PressX or mx) - mx) / 2, 0)
		pnl.PressX, pnl.PressY = gui.MousePos()
	end

	ent:SetAngles(pnl.Angles)
end

local function updateBodygroups(pnl, val)
	modelpanel.Entity:SetBodygroup(pnl.num, math.Round(val))
	local str = string.Explode(" ", cl_playerbodygroups:GetString())

	if #str < pnl.num + 1 then
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

--[[---------------------------------------------------------
	Name: gamemode:ShowTeam()
-----------------------------------------------------------]]
function GM:ShowTeam()
	if IsValid(self.TeamSelectFrame) then return end
	replacetable = dm_allplayermodels:GetBool() and player_manager.AllValidModels() or list.GetForEdit("ValidDMPlayerModels")
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
	button.DoClick = changeClick
	button.Think = changeThink
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
			if not pnl.playermodel:find(str, 1, true) and not pnl.model_path:find(str, 1, true) then
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
		local mdl = replacetable[val]
		if mdl then
			modelpanel:SetModel(mdl)
		elseif dm_allplayermodels:GetBool() then
			modelpanel:SetModel("models/player/kleiner.mdl")
		else
			modelpanel:SetModel("models/player/combine_soldier.mdl")
		end
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
