//JUNK EMPIRES RANGED SUPPORT

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "ranged_support" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	//the army
	self.Entity:SetModel( "models/props_lab/desklamp01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetColor( 255,255, 255,255 )
	
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON    )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false) //Don't want it rolling around everywhere
	end
	
	self.claimed = false
	self.combatant = false
	self.Overlord = "nothing"
	self.SpawnedBy = "nothing"
	
	self.health = 150
	self.type = "ranged"
	
end

function ENT:Think()

	if(self.health <= 0 ) then
		self.Entity:Disband()
	end

end

function ENT:SetSpawner(ply)
	self.SpawnedBy = ply
	if(!self.claimed) then
	if(ply == self.SpawnedBy) then
		self.Entity:SetColor(ply:GetColor())
		ply:SetNWInt(ply:Nick() .. "_ranged", ply:GetNWInt(ply:Nick() .. "_ranged") + 1) 
		self.claimed = true
		self.Overlord = ply
		self.combatant = true
	end
	end
end

function ENT:GetOverlord()
	return self.Overlord
end

function ENT:setHealth(value)
	self.health = value
end

function ENT:getHealth()
	return self.health
end

function ENT:Disband()
	if(self.Overlord != "nothing") then
		self.Overlord:SetNWInt(self.Overlord:Nick() .. "_ranged", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_ranged") - 1)
		local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetOrigin( self.Entity:GetPos())
		util.Effect( "gib_explosion", effectdata )
		self.Overlord = "nothing"
		self.SpawnedBy = "nothing"
		self.Entity:Remove()
	end
	
	if(self.Overlord == "nothing") then
		local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetOrigin( self.Entity:GetPos())
		util.Effect( "gib_explosion", effectdata )
		self.Entity:Remove()
	end
	
end

function ENT:IsCombatant()
	return self.combatant
end

