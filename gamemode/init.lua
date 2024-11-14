AddCSLuaFile"cl_init.lua"
AddCSLuaFile"cl_scoreboard.lua"
AddCSLuaFile"cl_taunt.lua"
AddCSLuaFile"cl_editor.lua"
include"shared.lua"
util.AddNetworkString"SendTaunt"
util.AddNetworkString"PlayerInit"
local clean = GetConVar"dm_timer"
GM.TeamBased = GetConVar"mp_teamplay":GetBool()
print("Team Mode", GM.TeamBased)
SetGlobal2Bool("TeamPlay", GM.TeamBased)

local infinite = GetConVar"dm_infinite"
local customloadout = GetConVar"dm_customloadout"
local teammode = GetConVar"mp_teamplay"

local tauntList = {"npc_citizen.goodgod", "npc_citizen.likethat", "npc_citizen.ohno", "npc_citizen.heretheycome01", "npc_citizen.overhere01", "npc_citizen.gethellout", "npc_citizen.help01", "npc_citizen.hi0", "npc_citizen.ok0", "npc_citizen.incoming02"}

if not file.Exists("deathmatch/", "DATA") then
	file.CreateDir("deathmatch")
end

if not file.Exists("deathmatch/customweapons.txt", "DATA") then
	file.Write("deathmatch/customweapons.txt", "weapon_physcannon;weapon_pistol;weapon_smg1")
end

if not file.Exists("deathmatch/customammo.txt", "DATA") then
	file.Write("deathmatch/customammo.txt", "Pistol:50;SMG1:75;SMG1_Grenade:2")
end

local function cleanMap(str, bool)
	if infinite:GetBool() or bool then
		game.CleanUpMap()
		PrintMessage(4, str or "Cleaning up map...")
	else
		hook.Run("EndRound")
	end
end

net.Receive("SendTaunt", function(_, ply)
	local curtime = CurTime()
	if not ply:Alive() or ply:GetNextTaunt() > curtime then return end
	ply:SetNextTaunt(curtime + 2)
	local key = net.ReadUInt(4)

	if key > 0 and key < 8 then
		ply:EmitSound(tauntList[key])
	elseif key >= 8 then
		ply:EmitSound(tauntList[key] .. math.random(1, 2))
	else
		ply:EmitSound(tauntList[10])
	end

	local num = hook.Run("PlayerVoice", ply, key)
	net.Start("SendTaunt")

	if IsValid(ply) then
		net.WriteUInt(ply:EntIndex(), 8)
	else
		net.WriteUInt(0, 8)
	end

	net.WriteUInt(num, 4)
	net.Broadcast()
end)

function GM:PlayerSpawnAsSpectator(pl)
	pl:StripWeapons()
	pl:SetTeam(TEAM_SPECTATOR)
	pl:Spectate(OBS_MODE_ROAMING)
end

function GM:PlayerSpawn(pl, transiton)
	local pteam = pl:Team()
	player_manager.SetPlayerClass(pl, "player_deathmatch")

	if pteam == TEAM_SPECTATOR or pteam == TEAM_UNASSIGNED then
		hook.Call("PlayerSpawnAsSpectator", self, pl)

		return
	end

	pl:UnSpectate()
	player_manager.OnPlayerSpawn(pl, transiton)
	player_manager.RunClass(pl, "Spawn")

	pl:AddFlags(FL_GODMODE)
	timer.Simple(3,function()
		pl:RemoveFlags(FL_GODMODE)
	end)

	-- Set player model
	hook.Call("PlayerSetModel", self, pl)

	-- If we are in transition, do not touch player's weapons
	if not transiton then
		-- Call item loadout function
		hook.Call("PlayerLoadout", self, pl)
	end
end

function GM:Think()
	if infinite:GetBool() then return end
	SetGlobalInt("TimeLeft", timer.TimeLeft("CleanUpMap"))
end

function GM:StartRound()
	SetGlobalBool("EndOfRound", false)

	if clean:GetBool() then
		if timer.Exists("CleanUpMap") then
			timer.Start("CleanUpMap")
		else
			timer.Create("CleanUpMap", clean:GetFloat(), 0, cleanMap)
		end
	else
		timer.Remove"CleanUpMap"
	end

	BroadcastLua("hook.Run('StartRound')")
	cleanMap("Starting round...", true)

	for k, v in player.Iterator() do
		v:UnLock()
		v:StripAmmo()
		v:StripWeapons()
		v:Spawn()
		v:SetFrags(0)
		v:SetDeaths(0)
	end
end

function GM:EndRound()
	SetGlobalBool("EndOfRound", true)
	timer.Stop("CleanUpMap")
	local lowest = math.huge
	local highest = -lowest
	local winner
	BroadcastLua("hook.Run('EndRound')")

	if teammode:GetBool() then
		local combine, resistance
		for k, v in player.Iterator() do
			v:Lock()

			local team = v:Team()
			if team == TEAM_COMBINE then
				combine = combine + v:Frags()
			elseif team == TEAM_RESISTANCE then
				resistance = resistance + v:Frags()
			end
		end
	else
		for k, v in player.Iterator() do
			v:Lock()
			local frags = v:Frags()
			local deaths = v:Deaths()

			if frags > highest then
				winner = v
				highest = frags
				lowest = deaths < lowest and deaths or lowest
			elseif frags == highest then
				winner = deaths < lowest and v or winner
				lowest = deaths < lowest and deaths or lowest
			end
		end
		PrintMessage(HUD_PRINTTALK, "Player " .. winner:Nick() .. " won with " .. winner:Frags() .. " frags!")
	end

	timer.Simple(5, self.StartRound)
end

function GM:ShowHelp(ply)
	ply:SendLua("hook.Run('ShowHelp')")
end

function GM:ShowTeam(ply)
	ply:SendLua("hook.Run('ShowTeam')")
end

function GM:ShowSpare1(ply)
	local curtime = CurTime()
	ply:SetTauntTimer(curtime + (ply:GetTauntTimer() <= curtime and 2 or 0))
	ply:SendLua("hook.Run('ShowSpare1')")
end

function GM:ShowSpare2(ply)
	ply:SendLua("hook.Run('ShowSpare2')")
end

function GM:PlayerVoice(ply, num)
	return num
end

function GM:InitPostEntity()
	RunConsoleCommand("sk_plr_dmg_crowbar", "25")
	RunConsoleCommand("sk_plr_dmg_stunstick", "40")
	RunConsoleCommand("sk_npc_dmg_crowbar", "10")
	self.OldDeploySpeed = GetConVar("sv_defaultdeployspeed"):GetString()
	RunConsoleCommand("sv_defaultdeployspeed", "1")
	RunConsoleCommand("gmod_maxammo", "0")
	RunConsoleCommand("sv_sticktoground", "0")
end

function GM:Initialize()
	if clean:GetBool() then
		timer.Create("CleanUpMap", math.Clamp(clean:GetFloat(), 0, 3600), 0, cleanMap)
	end
end

cvars.AddChangeCallback("dm_timer", function(_, __, val)
	local num = math.Clamp(tonumber(val), 0, 3600)

	if num ~= 0 then
		if timer.Exists("CleanUpMap") then
			timer.Adjust("CleanUpMap", num)
		else
			timer.Create("CleanUpMap", num, 0, cleanMap)
		end
	else
		timer.Remove("CleanUpMap")
		infinite:SetBool(true)
	end
end)

cvars.AddChangeCallback("dm_infinite", function()
	hook.Run("StartRound")
end)

cvars.AddChangeCallback("gmod_suit", function(convar, _, val)
	PrintMessage(HUD_PRINTTALK, "Server cvar '" .. convar .. "' changed to " .. val)
end)

function GM:ShutDown()
	RunConsoleCommand("sk_plr_dmg_crowbar", "10")
	RunConsoleCommand("sk_plr_dmg_stunstick", "10")
	RunConsoleCommand("sk_npc_dmg_crowbar", "5")
	RunConsoleCommand("sv_defaultdeployspeed", self.OldDeploySpeed)
	RunConsoleCommand("gmod_maxammo", "9999")
	RunConsoleCommand("sv_sticktoground", "1")
end

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_UNASSIGNED)
end

function GM:PlayerInit(ply)
	ply:SetHost(ply:IsListenServerHost())

	if ply:GetInfoNum("dm_hidehelp", 0) == 0 then
		self:ShowHelp(ply)
	end
end

function GM:PlayerCanPickupWeapon(ply)
	return ply:Team() < 1001
end

function GM:PlayerRequestTeam(ply, teamid)
	if team.Joinable(teamid) then
		if hook.Call("PlayerCanJoinTeam", self, ply, teamid) then
			hook.Call("PlayerJoinTeam", self, ply, teamid)
		end
	else
		ply:ChatPrint("You can't join that team")
	end
end

function GM:PlayerJoinTeam(ply, teamid)
	local iOldTeam = ply:Team()

	if ply:Alive() then
		if iOldTeam == TEAM_SPECTATOR or iOldTeam == TEAM_UNASSIGNED then
			ply:KillSilent()
		else
			ply:Kill()
		end
	end

	ply:SetTeam(teamid)
	ply.LastTeamSwitch = RealTime()
	ply:SetFrags(0)
	ply:SetDeaths(0)
	self:OnPlayerChangedTeam(ply, iOldTeam, teamid)
end

function GM:CanPlayerSuicide(ply) 
	return ply:Team() ~= TEAM_SPECTATOR
end

net.Receive("PlayerInit", function(len, ply)
	hook.Run("PlayerInit", ply)
end)

concommand.Add("dm_instantchange", function(ply)
	hook.Run("PlayerSetModel", ply)
	if customloadout:GetBool() then return end

	if hook.Run("IsModelCombine", ply:GetModel()) then
		ply:StripWeapon("weapon_crowbar")
		ply:Give("weapon_stunstick")
	else
		ply:StripWeapon("weapon_stunstick")
		ply:Give("weapon_crowbar")
	end
end, nil, "Set the player\'s model without respawning", FCVAR_CLIENTCMD_CAN_EXECUTE)

concommand.Add("team_set", function(ply, _, args)
	hook.Run("PlayerRequestTeam", ply, tonumber(args[1]))
end, nil, "Set the player's team", FCVAR_CLIENTCMD_CAN_EXECUTE)
