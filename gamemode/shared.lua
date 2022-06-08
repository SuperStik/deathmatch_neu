AddCSLuaFile()
list.Set("ValidDMPlayerModels", "combine", "models/player/combine_soldier.mdl")
list.Set("ValidDMPlayerModels", "combineprison", "models/player/combine_soldier_prisonguard.mdl")
list.Set("ValidDMPlayerModels", "combineelite", "models/player/combine_super_soldier.mdl")
list.Set("ValidDMPlayerModels", "police", "models/player/police.mdl")
list.Set("ValidDMPlayerModels", "policefem", "models/player/police_fem.mdl")
list.Set("ValidDMPlayerModels", "female07", "models/player/Group03/female_01.mdl")
list.Set("ValidDMPlayerModels", "female08", "models/player/Group03/female_02.mdl")
list.Set("ValidDMPlayerModels", "female09", "models/player/Group03/female_03.mdl")
list.Set("ValidDMPlayerModels", "female10", "models/player/Group03/female_04.mdl")
list.Set("ValidDMPlayerModels", "female11", "models/player/Group03/female_05.mdl")
list.Set("ValidDMPlayerModels", "female12", "models/player/Group03/female_06.mdl")

for i = 1, 9 do
	list.Set("ValidDMPlayerModels", "male" .. i + 9, "models/player/Group03/male_0" .. i .. ".mdl")
end

include"player_class/player_deathmatch.lua"
GM.Name = "Deathmatch"
GM.Author = "Stik"
GM.Email = ""
GM.Website = ""
GM.IsDeathmatchDerived = true
local adminfly = CreateConVar("dm_adminnoclip", "1", 8576, "Allow admins to noclip")
local playerfly = CreateConVar("dm_playernoclip", "0", 8576, "Allow players to noclip")

function GM:PlayerNoClip(ply, state)
	if not IsValid(ply) then
		return false
	elseif ply:IsAdmin() and ply:Alive() and adminfly:GetBool() then
		return true
	else
		return playerfly:GetBool() or not state
	end
end

function GM:CreateTeams()
	TEAM_DEATHMATCH = 3
	team.SetUp(TEAM_DEATHMATCH, "Deathmatch", Color(255, 255, 100))
end
