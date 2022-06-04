local TextColor = Color(93, 93, 93)
local ConnectingCol = Color(200, 200, 200, 200)
--local DeadColor = Color( 230, 200, 200 )
local DeadColor = Color(255, 77, 77)
--local AdminColor = Color( 230, 255, 230 )
local AdminColor = Color(128, 255, 128)
local ElseColor = Color(230, 230, 230)
local ExpensiveCol = Color(0, 0, 0, 200)
local MaxPlayers = game.MaxPlayers()
local playersStr = language.GetPhrase("players")
local playersL = string.Left(playersStr, 1)
local playersR = string.Right(playersStr, #playersStr - 1)
playersL = string.upper(playersL)
playersStr = nil
local user_green_img = Material("icon16/user_green.png")
local user_red_img = Material("icon16/user_red.png")
local user_orange_img = Material("icon16/user_orange.png")
local user_img = Material("icon16/user.png")
local sound_mute_img = Material("icon16/sound_mute.png")
local sound_img = Material("icon16/sound.png")
local maxlives = CreateConVar("dm_lives", "0", 8576, "If greater than 0, the every player will have a set amount of lives")

--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = {
	Init = function(self)
		self.AvatarButton = self:Add("DButton")
		self.AvatarButton:Dock(LEFT)
		self.AvatarButton:SetSize(32, 32)

		self.AvatarButton.DoClick = function()
			self.Player:ShowProfile()
		end

		self.Avatar = vgui.CreateX("AvatarImage", self.AvatarButton)
		self.Avatar:SetSize(32, 32)
		self.Avatar:SetMouseInputEnabled(false)
		self.Name = self:Add("DLabel")
		self.Name:Dock(FILL)
		self.Name:SetFont("ScoreboardDefault")
		self.Name:SetTextColor(TextColor)
		self.Name:DockMargin(8, 0, 0, 0)
		self.Mute = self:Add("DImageButton")
		self.Mute:SetSize(32, 32)
		self.Mute:Dock(RIGHT)
		self.Ping = self:Add("DLabel")
		self.Ping:Dock(RIGHT)
		self.Ping:SetWidth(50)
		self.Ping:SetFont("ScoreboardDefault")
		self.Ping:SetTextColor(TextColor)
		self.Ping:SetContentAlignment(5)
		self.Deaths = self:Add("DLabel")
		self.Deaths:Dock(RIGHT)
		self.Deaths:SetWidth(50)
		self.Deaths:SetFont("ScoreboardDefault")
		self.Deaths:SetTextColor(TextColor)
		self.Deaths:DockMargin(0, 0, 50, 0)
		self.Deaths:SetContentAlignment(5)
		self.Kills = self:Add("DLabel")
		self.Kills:Dock(RIGHT)
		self.Kills:SetWidth(50)
		self.Kills:SetFont("ScoreboardDefault")
		self.Kills:SetTextColor(TextColor)
		self.Kills:DockMargin(0, 0, 50, 0)
		self.Kills:SetContentAlignment(5)
		self.Friend = self:Add("DImage")
		self.Friend:SetSize(32, 32)
		--self.Friend:SetImage("icon16/user.png")
		self.Friend:Dock(RIGHT)
		self.Friend:SetContentAlignment(5)
		self.Friend:DockMargin(0, 0, 200, 0)
		self:Dock(TOP)
		self:DockPadding(3, 3, 3, 3)
		self:SetHeight(32 + 3 * 2)
		self:DockMargin(2, 0, 2, 2)
	end,
	Setup = function(self, pl)
		self.Player = pl
		self.Avatar:SetPlayer(pl)
		self:Think(self)
		self.FriendStatus = self.Player:GetFriendStatus()
	end,
	--MsgN( pl, " Friend: ", friend )
	Think = function(self)
		local lives = maxlives:GetInt()
		if not IsValid(self.Player) then
			self:SetZPos(9999) -- Causes a rebuild
			self:Remove()

			return
		end

		if self.PName == nil or self.PName ~= self.Player:Nick() then
			self.PName = self.Player:Nick()
			self.Name:SetText(self.PName)
		end

		if lives <= 0 then
			if self.NumDeaths == nil or self.NumDeaths ~= self.Player:Deaths() then
				self.NumDeaths = self.Player:Deaths()
				self.Deaths:SetText(self.NumDeaths)
			end
		else
			if self.NumDeaths == nil or self.NumDeaths ~= self.Player:Lives() then
				self.NumDeaths = self.Player:Lives()
				self.Deaths:SetText(self.NumDeaths)
			end
		end

		if self.NumKills == nil or self.NumKills ~= self.Player:Frags() then
			self.NumKills = self.Player:Frags()
			self.Kills:SetText(self.NumKills)
		end

		if self.NumPing == nil or self.NumPing ~= self.Player:Ping() then
			self.NumPing = self.Player:Ping()
			self.Ping:SetText(self.NumPing)
		end

		--
		-- Change the icon of the mute button based on state
		--
		if self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
			self.Muted = self.Player:IsMuted()

			if self.Muted then
				self.Mute:SetMaterial(sound_mute_img)
			else
				self.Mute:SetMaterial(sound_img)
			end

			self.Mute.DoClick = function()
				self.Player:SetMuted(not self.Muted)
			end

			self.Mute.OnMouseWheeled = function(s, delta)
				self.Player:SetVoiceVolumeScale(self.Player:GetVoiceVolumeScale() + (delta / 100 * 5))
				s.LastTick = CurTime()
			end

			self.Mute.PaintOver = function(s, w, h)
				if not IsValid(self.Player) then return end
				local a = 255 - math.Clamp(CurTime() - (s.LastTick or 0), 0, 3) * 255
				if (a <= 0) then return end
				draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, a * 0.75))
				draw.SimpleText(math.ceil(self.Player:GetVoiceVolumeScale() * 100) .. "%", "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		if self.FriendStatus == "friend" then
			self.Friend:SetMaterial(user_green_img)
		elseif self.FriendStatus == "blocked" then
			self.Friend:SetMaterial(user_red_img)
		elseif self.FriendStatus == "requested" then
			self.Friend:SetMaterial(user_orange_img)
		else
			self.Friend:SetMaterial(user_img)
		end

		--
		-- Connecting players go at the very bottom
		--
		if (self.Player:Team() == TEAM_CONNECTING) then
			self:SetZPos(2000 + self.Player:EntIndex())

			return
		end

		--
		-- This is what sorts the list. The panels are docked in the z order,
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--
		self:SetZPos((self.NumKills * -50) + self.NumDeaths + self.Player:EntIndex())
	end,
	Paint = function(self, w, h)
		if not IsValid(self.Player) then return end

		--
		-- We draw our background a different colour based on the status of the player
		--
		if self.Player:Team() == TEAM_CONNECTING then
			draw.RoundedBox(4, 0, 0, w, h, ConnectingCol)

			return
		end

		if not self.Player:Alive() then
			draw.RoundedBox(4, 0, 0, w, h, DeadColor)

			return
		end

		if self.Player:IsAdmin() then
			draw.RoundedBox(4, 0, 0, w, h, AdminColor)

			return
		end

		draw.RoundedBox(4, 0, 0, w, h, ElseColor)
	end
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE, "DPanel")

--
-- Here we define a new panel table for the scoreboard. It basically consists
-- of a header and a scrollpanel - into which the player lines are placed.
--

local SCORE_BOARD = {
	Init = function(self)
		self.Header = self:Add("Panel")
		self.Header:Dock(TOP)
		self.Header:SetHeight(100)
		self.Name = self.Header:Add("DLabel")
		self.Name:SetFont("ScoreboardDefaultTitle")
		self.Name:SetTextColor(color_white)
		self.Name:Dock(TOP)
		self.Name:SetHeight(40)
		self.Name:SetContentAlignment(5)
		self.Name:SetExpensiveShadow(2, ExpensiveCol)
		self.NumPlayers = self.Header:Add("DLabel")
		self.NumPlayers:Dock(LEFT)
		self.NumPlayers:SetFont("ScoreboardDefault")
		self.NumPlayers:SetTextColor(color_white)
		self.NumPlayers:SetPos(0, 70)
		self.NumPlayers:SetSize(300, 30)
		self.NumPlayers:DockMargin(2, 0, 0, 0)
		self.NumPlayers:SetContentAlignment(4)
		self.NumPlayers:SetExpensiveShadow(2, ExpensiveCol)
		local pingL = language.GetPhrase("ping")
		local pingR = string.Right(pingL, #pingL - 1)
		pingL = pingL:Left(1):upper()
		self.TextPing = self.Header:Add("DLabel")
		self.TextPing:Dock(RIGHT)
		self.TextPing:SetFont("ScoreboardDefault")
		self.TextPing:SetTextColor(color_white)
		self.TextPing:SetPos(0, 70)
		self.TextPing:SetSize(50, 30)
		self.TextPing:SetText(pingL .. pingR)
		self.TextPing:DockMargin(0, 0, 38, 0)
		self.TextPing:SetContentAlignment(5)
		self.TextPing:SetExpensiveShadow(2, ExpensiveCol)
		self.TextDeaths = self.Header:Add("DLabel")
		self.TextDeaths:Dock(RIGHT)
		self.TextDeaths:SetFont("ScoreboardDefault")
		self.TextDeaths:SetTextColor(color_white)
		self.TextDeaths:SetPos(0, 70)
		self.TextDeaths:SetSize(80, 30)
		self.TextDeaths:SetText("Deaths")
		self.TextDeaths:DockMargin(0, 0, 35, 0)
		self.TextDeaths:SetContentAlignment(5)
		self.TextDeaths:SetExpensiveShadow(2, ExpensiveCol)
		self.TextDeaths.Think = textDeathsThink
		self.TextFrags = self.Header:Add("DLabel")
		self.TextFrags:Dock(RIGHT)
		self.TextFrags:SetFont("ScoreboardDefault")
		self.TextFrags:SetTextColor(color_white)
		self.TextFrags:SetPos(0, 70)
		self.TextFrags:SetSize(50, 30)
		self.TextFrags:SetText("Frags")
		self.TextFrags:DockMargin(0, 0, 35, 0)
		self.TextFrags:SetContentAlignment(5)
		self.TextFrags:SetExpensiveShadow(2, ExpensiveCol)
		self.Scores = self:Add("DScrollPanel")
		self.Scores:Dock(FILL)
	end,
	PerformLayout = function(self)
		self:SetSize(700, ScrH() - 200)
		self:SetPos(ScrW() / 2 - 350, 100)
	end,
	Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, ExpensiveCol)
	end,
	Think = function(self, w, h)
		local lives = maxlives:GetInt()
		self.Name:SetText(GetHostName())
		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		self.NumPlayers:SetText(#plyrs .. "/" .. MaxPlayers .. " " .. playersL .. playersR)

		for id, pl in pairs(plyrs) do
			if IsValid(pl.ScoreEntry) then continue end
			pl.ScoreEntry = vgui.CreateFromTable(PLAYER_LINE, pl.ScoreEntry)
			pl.ScoreEntry:Setup(pl)
			self.Scores:AddItem(pl.ScoreEntry)
		end

		if lives <= 0 then
			self.TextDeaths:SetText("Deaths")
		else
			self.TextDeaths:SetText("Lives")
		end
	end
}

SCORE_BOARD = vgui.RegisterTable(SCORE_BOARD, "EditablePanel")

--[[---------------------------------------------------------
	Name: gamemode:ScoreboardShow( )
	Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()
	if not IsValid(g_Scoreboard) then
		g_Scoreboard = vgui.CreateFromTable(SCORE_BOARD)
	end

	if IsValid(g_Scoreboard) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled(false)
	end
end

function GM:ScoreboardHide()
	if self.RoundEnd and GetGlobalBool("EndOfRound") then
		return
	elseif IsValid(g_Scoreboard) then
		g_Scoreboard:Hide()
	end
end
