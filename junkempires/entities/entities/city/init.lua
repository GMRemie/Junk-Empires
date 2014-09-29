//JUNK EMPIRES CITY

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "city" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	//the city
	self.Entity:SetModel( "models/props_combine/breenglobe.mdl" )
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
	self.health = 1000
	self.type = "city"

end

function ENT:Think()

	if(self.health <= 0 ) then
		self.Entity:Raze()
		return
	end
	
	if(self.Entity:WaterLevel() > 0) then
		self.Entity:Raze()
		return
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
		ply:SetNWInt(ply:Nick() .. "_cities", ply:GetNWInt(ply:Nick() .. "_cities") + 1) //add to the citycount
		//ply:SetNWEntity( "city_" .. ply:GetNWInt(ply:Nick() .. "_cities"), self.Entity) //not too sure about this lagwise
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
	if(self.Overlord != "nothing") then
		self.Overlord:SetNWInt(self.Overlord:Nick() .. "_cities", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_cities") - 1)
		self.Overlord:SetNWInt(self.Overlord:Nick() .. "_gold", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_gold") - 5)
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
