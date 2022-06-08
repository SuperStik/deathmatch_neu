AddCSLuaFile()
DEFINE_BASECLASS("player_default")
local PLAYER = {}
PLAYER.DisplayName = "Deathmatch Class"
PLAYER.WalkSpeed = 200 -- How fast to move when not running
PLAYER.RunSpeed = 320 -- How fast to move when running
PLAYER.JumpPower = 210 -- How powerful our jump should be
PLAYER.DropWeaponOnDie = true -- Do we drop our weapon when we die
PLAYER.TauntCam = TauntCamera()

local dm_models = {
	combine = "models/player/combine_soldier.mdl",
	combineprison = "models/player/combine_soldier_prisonguard.mdl",
	combineelite = "models/player/combine_super_soldier.mdl",
	police = "models/player/police.mdl",
	policefem = "models/player/police_fem.mdl",
	female07 = "models/player/Group03/female_01.mdl",
	female08 = "models/player/Group03/female_02.mdl",
	female09 = "models/player/Group03/female_03.mdl",
	female10 = "models/player/Group03/female_04.mdl",
	female11 = "models/player/Group03/female_05.mdl",
	female12 = "models/player/Group03/female_06.mdl",
	male10 = "models/player/Group03/male_01.mdl",
	male11 = "models/player/Group03/male_02.mdl",
	male12 = "models/player/Group03/male_03.mdl",
	male13 = "models/player/Group03/male_04.mdl",
	male14 = "models/player/Group03/male_05.mdl",
	male15 = "models/player/Group03/male_06.mdl",
	male16 = "models/player/Group03/male_07.mdl",
	male17 = "models/player/Group03/male_08.mdl",
	male18 = "models/player/Group03/male_09.mdl"
}

local meta = FindMetaTable("Player")

function meta:Lives()
	return self.dt.Lives
end

if CLIENT then
	dm_models = nil
else
	function meta:SetLives(int)
		self.dt.Lives = int
	end

	function meta:AddLives(int)
		self.dt.Lives = self.dt.Lives + int
	end
end

local dm_weapons = GetConVar("dm_weapons")
local dm_grenades = GetConVar("dm_grenades")
local dm_allplayermodels = GetConVar("dm_allplayermodels")
local dm_medpacktimer = GetConVar("dm_medpacktimer")
local customloadout = GetConVar("dm_customloadout")

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Bool", 0, "Host") --shit way to see who is listen server host
	self.Player:NetworkVar("Float", 0, "NextTaunt")
	self.Player:NetworkVar("Float", 1, "TauntTimer")
	self.Player:DTVar("Int", 0, "Lives")
end

--
-- Name: PLAYER:Loadout
-- Desc: Called on spawn to give the player their default loadout
-- Arg1:
-- Ret1:
--
local function readCustom(ply)
	for k, v in ipairs(string.Explode(";", file.Read("deathmatch/customweapons.txt", "DATA"))) do
		ply:Give(v)
	end

	for k, v in ipairs(string.Explode(";", file.Read("deathmatch/customammo.txt", "DATA"))) do
		v = string.Explode(":", v)
		ply:GiveAmmo(tonumber(v[2]), v[1], true)
	end
end

function PLAYER:Loadout()
	if not dm_weapons:GetBool() then return end
	local ply = self.Player

	if customloadout:GetBool() then
		if not pcall(readCustom, ply) then
			ErrorNoHalt("Custom weapon or ammo configuration is incorrect! Check the deathmatch configuration!")
		end
	else
		ply:Give("weapon_pistol")
		ply:Give("weapon_crowbar")
		ply:Give("weapon_smg1")
		ply:Give("weapon_physcannon")

		if dm_grenades:GetBool() then
			ply:Give("weapon_frag")
			ply:GiveAmmo(1, "Grenade", true)
		end

		ply:GiveAmmo(180, "Pistol", true)
		ply:GiveAmmo(45, "SMG1", true)
	end
end

function PLAYER:SetModel()
	local cl_playermodel = self.Player:GetInfo("cl_playermodel")
	local cl_playercolor = self.Player:GetInfo("cl_playercolor")
	local cl_playerskin = self.Player:GetInfoNum("cl_playerskin", 0)
	local cl_playerbodygroups = self.Player:GetInfo("cl_playerbodygroups")

	if not (dm_allplayermodels:GetBool() or isstring(dm_models[cl_playermodel])) then
		cl_playermodel = "kleiner"
	end

	--local col = Vector(cl_playercolor)
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
	util.PrecacheModel(modelname)
	self.Player:SetModel(modelname)
	self.Player:SetSkin(cl_playerskin)

	if cl_playerbodygroups == nil then
		cl_playerbodygroups = ""
	end

	cl_playerbodygroups = string.Explode(" ", cl_playerbodygroups)

	for k = 0, self.Player:GetNumBodyGroups() - 1 do
		self.Player:SetBodygroup(k, tonumber(cl_playerbodygroups[k + 1]) or 0)
	end

	self.Player:SetupHands()
	self.Player:SetPlayerColor(Vector(cl_playercolor))
end

function PLAYER:Death(inflictor, attacker)
	if not dm_medpacktimer:GetBool() then return end
	local medkit = ents.Create("item_healthkit")
	medkit:SetModel("models/items/healthkit.mdl")
	medkit:SetPos(self.Player:GetPos())
	medkit:Spawn()
	local respawn = dm_medpacktimer:GetFloat()
	if respawn < 0 then return end
	SafeRemoveEntityDelayed(medkit, respawn)
end

function PLAYER:ShouldDrawLocal()
	local bool = self.Player:IsPlayingTaunt()
	if self.TauntCam:ShouldDrawLocalPlayer(self.Player, bool) then return bool end
end

function PLAYER:CreateMove(cmd)
	if self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CalcView(view)
	local bool = self.Player:IsPlayingTaunt()
	if self.TauntCam:CalcView(view, self.Player, bool) then return bool end
end

player_manager.RegisterClass("player_deathmatch", PLAYER, "player_default")
