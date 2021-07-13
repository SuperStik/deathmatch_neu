AddCSLuaFile()
include("player_class/player_deathmatch.lua")
GM.Name = "Team Class Deathmatch"
GM.Author = "Stik"
GM.Email = ""
GM.Website = ""
GM.IsDeathmatchDerived = true
local adminfly = CreateConVar("dm_adminnoclip", "1", 8576, "Allow admins to noclip")
local playerfly = CreateConVar("dm_playernoclip", "0", 24960, "Allow players to noclip")

function GM:PlayerNoClip(ply, state)
	if not IsValid(ply) then
		return false
	elseif ply:IsAdmin() and ply:Alive() and adminfly:GetBool() then
		return true
	else
		return playerfly:GetBool() or not state
	end
end