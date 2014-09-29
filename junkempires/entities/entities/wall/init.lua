//JUNK EMPIRES WALL

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "wall" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	self.Entity:SetModel( "models/Gibs/HGIBS_spine.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON    )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false) //Don't want our cities rolling around everywhere
	end
	
	self.claimed = false
	self.combatant = false
	self.Overlord = "nothing"
	self.SpawnedBy = "nothing"
	
	//combat stats
	self.health = 400
	self.type = "wall"

end

function ENT:Think()
	if(self.health <= 0 ) then
		self.Entity:Raze()
	end
end


function ENT:setHealth(value)
	self.health = value
end

function ENT:getHealth()
	return self.health
end

function ENT:SetSpawner(ply)
	self.SpawnedBy = ply
	if(!self.claimed) then
	if(ply == self.SpawnedBy) then
		self.Entity:SetColor( ply:GetColor() ) //set city to player's color
		self.claimed = true
		self.Overlord = ply
		self.combatant = true
	end
	end
end

function ENT:GetOverlord()
	return self.Overlord
end

function ENT:Raze()

	self.Overlord = "nothing"
	self.SpawnedBy = "nothing"
	self.Entity:Remove()
	
end

function ENT:IsCombatant()
	return self.combatant
end
