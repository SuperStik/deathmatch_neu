AddCSLuaFile()
include("player_class/player_deathmatch.lua")
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