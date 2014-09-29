//JUNK EMPIRES PYLON
//sassafrass stop stealing my code
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "pylon" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	self.Entity:SetModel( "models/props_c17/gravestone_cross001b.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetColor( 255,255, 255,255 )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false) //Don't want it rolling around everywhere
	end
	
	self.claimed = false
	self.Overlord = "nothing"
	self.health = 1000
	self.type = "pylon"
	
end

function ENT:Use(ply)

	if(!self.claimed) then
		if(ply:GetNWInt(ply:Nick() .. "_gold") < 75) then
			ply:ChatPrint("You need 75 gold to take over a pylon!")
			return
		end
		self.Entity:SetColor(ply:GetColor())
		ply:SetNWInt(ply:Nick() .. "_pylons", ply:GetNWInt(ply:Nick() .. "_pylons") + 1) 
		ply:SetNWInt(ply:Nick() .. "_gold", ply:GetNWInt(ply:Nick() .. "_gold") - 75) 
		self.claimed = true
		self.Overlord = ply
	end

end

function ENT:Think()
	if(self.health <= 0 ) then
		self.Entity:RemoveControl()
	end
end

function ENT:setHealth(value)
	self.health = value
end

function ENT:getHealth()
	return self.health
end

function ENT:GetOverlord()
	return self.Overlord
end

function ENT:RemoveControl()
	if(self.Overlord != "nothing") then
		self.Overlord:SetNWInt(self.Overlord:Nick() .. "_pylons", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_pylons") - 1)
		self.claimed = false
		self.Overlord = "nothing"
		self.Entity:SetColor( 255,255, 255,255 )
		self.health = 250
	end
end

