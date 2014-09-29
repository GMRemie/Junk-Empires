//JUNK EMPIRES RANGED MARKER

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "ranged_support_marker" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	//the army
	self.Entity:SetModel( "models/props_junk/TrafficCone001a.mdl" )
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
	self.angYaw = 0
	
	self.health = 25
	self.damageTotal = 0
	
end

function ENT:Think()
	
	self.Entity:SetAngles(Angle(0, self.angYaw, 0))  
	self.angYaw = self.angYaw + 10
	if(self.angYaw >= 360) then
		self.angYaw = 0
	end
	
	self.health = self.health - 1
	
	if(self.health <= 0) then
		for _, x in pairs(ents.FindInSphere(self.Entity:GetPos(), 72)) do //now check what's around it
			if( (x:GetClass() == "army" || x:GetClass() == "city" || x:GetClass() == "farm" || x:GetClass() == "iron_mine" || x:GetClass() == "ranged_support" || x:GetClass() == "medic_station" || x:GetClass() == "wall" || x:GetClass() == "pylon") && x:GetOverlord() != nil && x:IsValid()) then // it's an army and owned
	
				if( x:IsValid() && (x:GetOverlord() != self.Entity:GetOverlord()) ) then
					if(self.damageTotal > x:getHealth() && self.damageTotal > 0) then
						self.damageTotal = self.damageTotal - x:getHealth()
						x:setHealth(0)
					end
				end
						
			end
		end
		self.Entity:Disband()
	end
end

function ENT:SetSpawner(ply)
	self.SpawnedBy = ply
	if(!self.claimed) then
	if(ply == self.SpawnedBy) then
		self.Entity:SetColor(ply:GetColor())
		self.claimed = true
		self.Overlord = ply
		self.combatant = true
		self.damageTotal = self.Overlord:GetNWInt(self.Overlord:Nick() .. "_ranged") * 256
	end
	end
end

function ENT:GetOverlord()
	return self.Overlord
end

function ENT:Disband()
	
	self.Entity:Remove()
end

function ENT:IsCombatant()
	return self.combatant
end

