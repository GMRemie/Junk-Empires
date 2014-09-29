//JUNK EMPIRES IRON MINE

AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "iron_mine" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	//the mine
	self.Entity:SetModel( "models/props_junk/sawblade001a.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetColor( 255,255, 255,255 )
	self.Entity:SetMaterial("models/debug/debugwhite")

	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false) //Don't want it rolling around everywhere
	end
	
	self.claimed = false
	self.Overlord = "nothing"
	self.health = 250
	self.type = "resource"
	
end

function ENT:Use(ply)

	if( (ply:GetNWInt(ply:Nick() .. "_farms") + ply:GetNWInt(ply:Nick() .. "_mines")) < ( ply:GetNWInt(ply:Nick() .. "_cities") + 2) ) then
		if(!self.claimed) then
			self.Entity:SetColor(ply:GetColor())
			ply:SetNWInt(ply:Nick() .. "_mines", ply:GetNWInt(ply:Nick() .. "_mines") + 1) 
			self.claimed = true
			self.Overlord = ply
		end
	end


end

function ENT:setHealth(value)
	self.health = value
end

function ENT:getHealth()
	return self.health
end

function ENT:Think()
	if(self.health <= 0 ) then
		self.Entity:RemoveControl()
	end
end

function ENT:GetOverlord()
	return self.Overlord
end

function ENT:RemoveControl()
	if(self.Overlord != "nothing") then
		self.Overlord:SetNWInt(self.Overlord:Nick() .. "_mines", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_mines") - 1)
		self.claimed = false
		self.Overlord = "nothing"
		self.Entity:SetColor( 255,255, 255,255 )
		self.health = 250
	end

end
