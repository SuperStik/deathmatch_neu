AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_scoreboard.lua")
include("shared.lua")
util.AddNetworkString("SendTaunt")
util.AddNetworkString("PlayerInit")
local clean = GetConVar("dm_timer")
local infinite = GetConVar("dm_infinite")

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

local function playerSetModel(ply)
	hook.Run("PlayerSetModel", ply)
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
	ply:SetShowTaunts(false)
end)

function GM:PlayerSpawn(pl, transiton)
	player_manager.SetPlayerClass(pl, "player_deathmatch")
	player_manager.OnPlayerSpawn(pl, transiton)
	player_manager.RunClass(pl, "Spawn")

	-- If we are in transition, do not touch player's weapons
	if (not transiton) then
		-- Call item loadout function
		hook.Run("PlayerLoadout", pl)
	end

	-- Set player model
	playerSetModel(pl)
end

concommand.Add("dm_instantchange", playerSetModel, nil, "Set the player\'s model without respawning", FCVAR_CLIENTCMD_CAN_EXECUTE)

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
		timer.Remove("CleanUpMap")
	end

	BroadcastLua("hook.Run('StartRound')")
	cleanMap("Starting round...", true)

	for k, v in ipairs(player.GetAll()) do
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

	for k, v in ipairs(player.GetAll()) do
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
	timer.Simple(5, self.StartRound)
end

function GM:ShowHelp(ply)
	ply:SendLua("hook.Run('ShowHelp')")
end

function GM:ShowTeam(ply)
	ply:SendLua("hook.Run('ShowTeam')")
end

function GM:ShowSpare1(ply)
	ply:SetShowTaunts(true)
	ply:SendLua("hook.Run('ShowSpare1')")
	local time = "HideSpare1" .. ply:EntIndex()
	if timer.Exists(time) then
		timer.Adjust(time, 2)
	else
		timer.Create(time, 2, 1, function()
			ply:SetShowTaunts(false)
		end)
	end
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

function GM:ShutDown()
	RunConsoleCommand("sk_plr_dmg_crowbar", "10")
	RunConsoleCommand("sk_plr_dmg_stunstick", "10")
	RunConsoleCommand("sk_npc_dmg_crowbar", "5")
	RunConsoleCommand("sv_defaultdeployspeed", self.OldDeploySpeed)
end

function GM:PlayerInitialSpawn(ply)
	ply:SetTeam(TEAM_UNASSIGNED)

	if ply:GetInfo("dm_hidehelp") == "0" then
		self:ShowHelp(ply)
	end
end

function GM:PlayerInit(ply)
	ply:SetHost(ply:IsListenServerHost())
end

net.Receive("PlayerInit", function(len, ply)
	gamemode.Run("PlayerInit", ply)
end)