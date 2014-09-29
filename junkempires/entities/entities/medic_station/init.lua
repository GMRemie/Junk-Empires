//JUNK EMPIRES MEDIC STATION

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "medic_station" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	self.Entity:SetModel( "models/props_junk/garbage_milkcarton002a.mdl" )
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
	self.health = 50
	self.type = "medic_station"
	self.healed = 0

end

function ENT:Think()
	if(self.health <= 0 ) then
		self.Entity:Raze()
	end
	
	for _, x in pairs(ents.FindInSphere(self.Entity:GetPos(), 36)) do //now check what's around it
		if( (x:GetClass() == "army" && x:GetOverlord() != nil)) then // it's an army and owned
			
			if( (x:GetOverlord() == self.Entity:GetOverlord()) ) then
				if(x:getHealth() < 250) then
					x:setHealth(x:getHealth() + 1)
					self.healed = self.healed + 1
					if(self.healed >= 50) then
						self.Overlord:SetNWInt(self.Overlord:Nick() .. "_food", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_food") - 1 )
						self.healed = 0
					end
				end
			end
						
		end
		
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

	local effectdata = EffectData()
	effectdata:SetEntity( self )
	effectdata:SetOrigin( self.Entity:GetPos())
	util.Effect( "gib_explosion", effectdata )
	self.Overlord = "nothing"
	self.SpawnedBy = "nothing"
	self.Entity:Remove()
	
end

function ENT:IsCombatant()
	return self.combatant
end
