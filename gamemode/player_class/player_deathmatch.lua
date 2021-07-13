
AddCSLuaFile()

DEFINE_BASECLASS("player_default")

local PLAYER = {}

PLAYER.DisplayName			= "Deathmatch Class"

PLAYER.WalkSpeed			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 320		-- How fast to move when running
PLAYER.JumpPower			= 210		-- How powerful our jump should be
PLAYER.DropWeaponOnDie		= true		-- Do we drop our weapon when we die
PLAYER.TauntCam = TauntCamera()

local dm_models = {female08="models/player/Group03/female_02.mdl",female05="models/player/Group01/female_05.mdl",male03="models/player/Group01/male_03.mdl",medic06="models/player/Group03m/male_06.mdl",male13="models/player/Group03/male_04.mdl",medic11="models/player/Group03m/female_02.mdl",male04="models/player/Group01/male_04.mdl",medic14="models/player/Group03m/female_05.mdl",odessa="models/player/odessa.mdl",female11="models/player/Group03/female_05.mdl",female07="models/player/Group03/female_01.mdl",css_guerilla="models/player/guerilla.mdl",combineelite="models/player/combine_super_soldier.mdl",male05="models/player/Group01/male_05.mdl",female06="models/player/Group01/female_06.mdl",medic05="models/player/Group03m/male_05.mdl",male07="models/player/Group01/male_07.mdl",mossmanarctic="models/player/mossman_arctic.mdl",male06="models/player/Group01/male_06.mdl",refugee03="models/player/Group02/male_06.mdl",male10="models/player/Group03/male_01.mdl",breen="models/player/breen.mdl",corpse="models/player/corpse1.mdl",monk="models/player/monk.mdl",female01="models/player/Group01/female_01.mdl",male15="models/player/Group03/male_06.mdl",barney="models/player/barney.mdl",medic15="models/player/Group03m/female_06.mdl",male09="models/player/Group01/male_09.mdl",css_swat="models/player/swat.mdl",female03="models/player/Group01/female_03.mdl",male17="models/player/Group03/male_08.mdl",zombie="models/player/zombie_classic.mdl",female02="models/player/Group01/female_02.mdl",magnusson="models/player/magnusson.mdl",charple="models/player/charple.mdl",eli="models/player/eli.mdl",skeleton="models/player/skeleton.mdl",dod_american="models/player/dod_american.mdl",dod_german="models/player/dod_german.mdl",css_urban="models/player/urban.mdl",css_riot="models/player/riot.mdl",male01="models/player/Group01/male_01.mdl",police="models/player/police.mdl",css_leet="models/player/leet.mdl",alyx="models/player/alyx.mdl",medic08="models/player/Group03m/male_08.mdl",css_gasmask="models/player/gasmask.mdl",zombine="models/player/zombie_soldier.mdl",stripped="models/player/soldier_stripped.mdl",policefem="models/player/police_fem.mdl",kleiner="models/player/kleiner.mdl",male14="models/player/Group03/male_05.mdl",css_arctic="models/player/arctic.mdl",female12="models/player/Group03/female_06.mdl",gman="models/player/gman_high.mdl",female04="models/player/Group01/female_04.mdl",zombiefast="models/player/zombie_fast.mdl",medic02="models/player/Group03m/male_02.mdl",hostage02="models/player/hostage/hostage_02.mdl",medic03="models/player/Group03m/male_03.mdl",combineprison="models/player/combine_soldier_prisonguard.mdl",refugee04="models/player/Group02/male_08.mdl",refugee02="models/player/Group02/male_04.mdl",refugee01="models/player/Group02/male_02.mdl",medic10="models/player/Group03m/female_01.mdl",male02="models/player/Group01/male_02.mdl",male12="models/player/Group03/male_03.mdl",medic07="models/player/Group03m/male_07.mdl",hostage03="models/player/hostage/hostage_03.mdl",female10="models/player/Group03/female_04.mdl",male18="models/player/Group03/male_09.mdl",css_phoenix="models/player/phoenix.mdl",hostage01="models/player/hostage/hostage_01.mdl",medic01="models/player/Group03m/male_01.mdl",hostage04="models/player/hostage/hostage_04.mdl",male08="models/player/Group01/male_08.mdl",medic12="models/player/Group03m/female_03.mdl",male11="models/player/Group03/male_02.mdl",medic13="models/player/Group03m/female_04.mdl",medic09="models/player/Group03m/male_09.mdl",combine="models/player/combine_soldier.mdl",mossman="models/player/mossman.mdl",female09="models/player/Group03/female_03.mdl",chell="models/player/p2_chell.mdl",medic04="models/player/Group03m/male_04.mdl",male16="models/player/Group03/male_07.mdl"}
local dm_weapons = GetConVar("dm_weapons")
local dm_grenades = GetConVar("dm_grenades")
local dm_allplayermodels = GetConVar("dm_allplayermodels")
local dm_medpacktimer = GetConVar("dm_medpacktimer")
local testvec = Vector(0,300,0)

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Bool", 0, "Host") --shit way to see who is listen server host
	self.Player:NetworkVar("Bool", 1, "ShowTaunts")
	self.Player:NetworkVar("Float", 0, "NextTaunt")
end

function PLAYER:Init()
	self.Player:SetShowTaunts(false)
	self.Player:SetNextTaunt(0)
end

--
-- Name: PLAYER:Loadout
-- Desc: Called on spawn to give the player their default loadout
-- Arg1:
-- Ret1:
--
function PLAYER:Loadout()
	if not dm_weapons:GetBool() then return end
	self.Player:Give("weapon_pistol")
	self.Player:Give("weapon_crowbar")
	self.Player:Give("weapon_357")
	self.Player:Give("weapon_crossbow")
	self.Player:Give("weapon_shotgun")
	self.Player:Give("weapon_smg1")
	self.Player:Give("weapon_physcannon")
	if dm_grenades:GetBool() then
		self.Player:Give("weapon_frag")
		self.Player:GiveAmmo(4, "Grenade", true)
	end
	self.Player:GiveAmmo(50, "Pistol", true)
	self.Player:GiveAmmo(2, "SMG1_Grenade", true)
	self.Player:GiveAmmo(12, "357", true)
	self.Player:GiveAmmo(75, "SMG1", true)
	self.Player:GiveAmmo(20, "Buckshot", true)
	self.Player:GiveAmmo(12, "XBowBolt", true)
end

function PLAYER:SetModel()
	local cl_playermodel = self.Player:GetInfo("cl_playermodel")
	local cl_playercolor = self.Player:GetInfo("cl_playercolor")
	local cl_playerskin = self.Player:GetInfoNum( "cl_playerskin", 0)
	local cl_playerbodygroups = self.Player:GetInfo("cl_playerbodygroups")
	if not (dm_allplayermodels:GetBool() or isstring(dm_models[cl_playermodel])) then cl_playermodel = "kleiner" end
	--local col = Vector(cl_playercolor)
	local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
	util.PrecacheModel(modelname)
	self.Player:SetModel(modelname)
	self.Player:SetSkin(cl_playerskin)
	if cl_playerbodygroups == nil then cl_playerbodygroups = "" end
	local cl_playerbodygroups = string.Explode(" ", cl_playerbodygroups)
	for k = 0, self.Player:GetNumBodyGroups() - 1 do
		self.Player:SetBodygroup(k, tonumber(cl_playerbodygroups[k + 1]) or 0)
	end
	self.Player:SetupHands()
	self.Player:SetPlayerColor( Vector(cl_playercolor) )
end

function PLAYER:Death( inflictor, attacker )
	if not dm_medpacktimer:GetBool() then return end
	local medkit = ents.Create("item_healthkit")
	medkit:SetModel("models/items/healthkit.mdl")
	medkit:SetPos(self.Player:GetPos())
	medkit:Spawn()
	local respawn = dm_medpacktimer:GetFloat()
	if respawn < 0 then return end
	SafeRemoveEntityDelayed(medkit,respawn)
end

function PLAYER:ShouldDrawLocal() 
	local bool = self.Player:IsPlayingTaunt()
	if self.TauntCam:ShouldDrawLocalPlayer(self.Player, bool) then return bool end
end

function PLAYER:CreateMove( cmd )
	if self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CalcView( view )
	local bool = self.Player:IsPlayingTaunt()
	if self.TauntCam:CalcView(view, self.Player, bool) then return bool end
end

player_manager.RegisterClass( "player_deathmatch", PLAYER, "player_default" )