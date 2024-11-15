local boxColor = NamedColor("BgColor")
local deadColo = Color(255, 30, 40)
local voiceCol = Color(61, 66, 212)
local hudColor = NamedColor("FgColor")

local TauntList = {"npc_citizen.goodgod", "npc_citizen.likethat", "npc_citizen.ohno", "npc_citizen.heretheycome01", "npc_citizen.overhere01", "npc_citizen.gethellout", "npc_citizen.help01", "npc_citizen.hi01", "npc_citizen.ok01", "npc_citizen.incoming01"}

--[[---------------------------------------------------------
	Name: gamemode:PlayerBindPress()
-----------------------------------------------------------]]
function GM:PlayerBindPress(ply, bind)
	local textpos = string.find(bind, "slot")
	local curtime = CurTime()

	if ply:GetTauntTimer() > curtime and textpos == 1 and IsValid(self.TauntTextPanel) then
		if ply:GetNextTaunt() <= curtime then
			net.Start("SendTaunt")
			net.WriteUInt(tonumber(string.Right(bind, 1)), 4)
			net.SendToServer()
		end

		hook.Call("HideSpare1", self)

		return true
	end

	return false
end

local function teamClick(pnl)
	RunConsoleCommand("team_set", pnl.iTeam)
	pnl:GetParent():GetParent():Close()
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
	local text = Label("Here, your goal is to kill each other (pretty obvious because of the name). Pressing " .. input.LookupBinding("gm_showteam") .. " opens the panel to change your player model, and pressing " .. input.LookupBinding("gm_showspare1") .. " opens the taunt menu. You can press " .. input.LookupBinding("gm_showhelp"):upper() .. " to show this menu again. Press " .. input.LookupBinding("gm_showspare2") .. " to view the server options. To continue, press one of the two buttons below.", self.HelpFrame)
	text:Dock(TOP)
	text:SetWrap(true)
	text:SetContentAlignment(8)
	local pContainer = vgui.CreateX("Panel", self.HelpFrame, "ButtonContainer")
	pContainer:Dock(TOP)
	pContainer:SetTall(30)

	local spec = vgui.Create("DButton", pContainer, "SpectatorBtn")	
	local bwidth
	if self.TeamBased then
		bwidth = width / 8
		local blu = vgui.Create("DButton", pContainer, "BluTeamBtn")
		local red = vgui.Create("DButton", pContainer, "RedTeamBtn")
		blu.iTeam = TEAM_COMBINE
		red.iTeam = TEAM_RESISTANCE
		blu.DoClick = teamClick
		red.DoClick = teamClick
		blu:SetWide(96)
		red:SetWide(96)
		blu:Dock(LEFT)
		red:Dock(FILL)
		blu:DockMargin(bwidth, 4, 0, 0)
		bwidthd = bwidth * 0.7
		red:DockMargin(bwidthd, 4, bwidthd, 0)
		red:CenterHorizontal()
		blu:SetText("Combine")
		red:SetText("Resistance")
	else
		bwidth = width / 4
		local sdm = vgui.Create("DButton", pContainer, "TeamlessBtn")
		sdm.iTeam = TEAM_DEATHMATCH
		sdm.DoClick = teamClick
		sdm:SetWide(96)
		sdm:Dock(LEFT)
		sdm:DockMargin(bwidth, 4, 0, 0)
		sdm:SetText("Deathmatch")
		
	end
	
	spec.iTeam = 1002
	spec.DoClick = teamClick
	spec:SetWide(96)
	spec:Dock(RIGHT)
	spec:DockMargin(0, 4, bwidth, 0)
	spec:SetText("Spectator")
	text:SetAutoStretchVertical(true)
	self.HelpFrame:InvalidateLayout(true)
	self.HelpFrame:SizeToChildren(nil, true)
	self.HelpFrame:SetTall(self.HelpFrame:GetTall() + pContainer:GetTall() + 23)
	self.HelpFrame:Center()
	self.HelpFrame:MakePopup()
end

--[[---------------------------------------------------------
	Name: gamemode:ShowSpare1()
-----------------------------------------------------------]]
function GM:ShowSpare1()
	local ply, curtime = LocalPlayer(), CurTime()
	if ply:GetNextTaunt() > curtime then return end

	if IsValid(self.TauntTextPanel) then
		hook.Call("HideSpare1", self)

		return
	end

	self.TauntTextPanel = vgui.CreateX("Panel", GetHUDPanel(), "TauntMenu")
	self.TauntTextPanel:SetSize(ScrW() / 7, 265)
	self.TauntTextPanel:SetPos(25, ScrH() / 6)

	self.TauntTextPanel.Paint = function(pnl, w, h)
		draw.RoundedBox(8, 0, 0, w, h, boxColor)
	end

	self.TauntTextPanel:DockPadding(10, 10, 10, 10)

	for k, v in ipairs(TauntList) do
		local opt = "Option" .. k
		self.TauntTextPanel[opt] = vgui.Create("DLabel", self.TauntTextPanel)
		self.TauntTextPanel[opt]:SetFont("HudSelectionText")
		self.TauntTextPanel[opt]:Dock(TOP)

		if k == 10 then
			self.TauntTextPanel[opt]:SetText("0: " .. language.GetPhrase(v))
		else
			self.TauntTextPanel[opt]:SetText(k .. ": " .. language.GetPhrase(v))
			self.TauntTextPanel[opt]:DockMargin(0, 0, 0, 5)
		end

		self.TauntTextPanel[opt]:SetColor(hudColor)
	end
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

--[[---------------------------------------------------------
	Name: gamemode:OnPlayerTaunt()
-----------------------------------------------------------]]
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
	table.insert(tab, ": " .. language.GetPhrase(TauntList[num == 0 and 10 or num]))
	chat.AddText(unpack(tab))
end

net.Receive("SendTaunt", function()
	local ply = Entity(net.ReadUInt(8))
	hook.Run("OnPlayerTaunt", ply, net.ReadUInt(4), not ply:Alive())
end)

return boxColor, hudColor
