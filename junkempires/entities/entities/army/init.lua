//JUNK EMPIRES ARMY

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


//supply radius is approx 140

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "army" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	
	//the army
	self.Entity:SetModel( "models/Gibs/HGIBS.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetColor( 255,255, 255,255 )
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	self.phys = self.Entity:GetPhysicsObject()
	if (self.phys:IsValid()) then
		self.phys:EnableMotion(true)
		self.phys:Wake()
	end
	
	self.claimed = false
	self.combatant = true
	self.Overlord = "nothing"
	self.SpawnedBy = "nothing"
	self.destination = nil
	self.moving = false
	self.destinationEntity = nil
	self.speed = 600
	self.atDestination = false
	self.startPos = self.Entity:GetPos()
	self.travelDist = 0
	self.bootin = false //the unit's "putting the boot in", i.e. got stuck in combat
	self.combatTargets = {}
	self.currentTarget = nil
	self.inCombat = false
	
	self.Entity:SetNWBool("isSelected", false)
	
	//combat stats
	self.damage = 2 //amount of damage done each think
	self.health = 255
	self.type = "army"
	
end

function ENT:Think()

	if(self.Entity:WaterLevel() > 0) then
		if(self.destinationEntity) then
			if(self.destinationEntity:IsValid()) then
				self.destinationEntity:Remove()
			end
		end
		self.Entity:Disband()
	end
	
	if(self.health <= 55 ) then
		if(self.destinationEntity) then
			if(self.destinationEntity:IsValid()) then
				self.destinationEntity:Remove()
			end
		end
		self.Entity:Disband()
		return
	end

	if(self.moving) then		
		
		for _, x in pairs(ents.FindInSphere(self.destination, 6)) do
			if(x == self.Entity) then
				self.atDestination = true
				self.moving = false
				self.destination = nil
				if(self.destinationEntity) then
					if(self.destinationEntity:IsValid()) then
						self.destinationEntity:Remove()
					end
				end
				self.phys:Sleep()
				return
			end
		end
		
		if(self.Entity:checkGround(8)) then
			self.Entity:PointAtEntity(self.destinationEntity)
			local veloc = self.Entity:GetForward() * self.speed + Vector(0,0,1)
			self.phys:ApplyForceCenter(veloc)
		end
		
	end
	
	for _, x in pairs(ents.FindInSphere(self.Entity:GetPos(), 8)) do //now check what's around it
		if( (x:GetClass() == "army" || x:GetClass() == "city" || x:GetClass() == "farm" || x:GetClass() == "iron_mine" || x:GetClass() == "ranged_support" || x:GetClass() == "medic_station" || x:GetClass() == "wall" || x:GetClass() == "pylon") && x:IsValid() && x:GetOverlord() != nil) then // it's an army and owned
		
			for _, z in pairs(alliances[self.Overlord]) do //check it's an ally
				if(x:GetOverlord() == z) then 
					isAlly = true
				end
			end
			
			if( (x:GetOverlord() != self.Entity:GetOverlord()) && !isAlly && (x:GetOverlord() != "nothing")) then
				if(!self.inCombat) then
				self.moving = false
				self.bootin = true
				self.inCombat = true
				self.currentTarget = x
				self.phys:EnableMotion(false)
				self.destination = nil
				if(self.destinationEntity) then
					if(self.destinationEntity:IsValid()) then
						self.destinationEntity:Remove()
					end
				end
				self.destinationEntity = nil
				self.atDestination = true
				end
				
				
			end
						
			isAlly = false
						
		end
	end
	
	if(self.inCombat) then
		if(self.currentTarget) then
			if(self.currentTarget:IsValid() && (self.currentTarget:GetOverlord() != "nothing") ) then
				self.Entity:PointAtEntity(self.currentTarget)
				self.phys:Sleep()
				self.currentTarget:setHealth(self.currentTarget:getHealth() - self.damage)
			else
				self.currentTarget = nil
				self.inCombat = false
				self.bootin = false
				self.combatTargets = {}
				self.phys:Wake()
				self.phys:EnableMotion(true)
			end
		end
	end
	
	local r,g,b,a = self.Overlord:GetColor()
	self.Entity:SetColor(r,g,b,self.health)
	
end


function ENT:setHealth(value)
	self.health = value
end

function ENT:getHealth()
	return self.health
end

function ENT:checkGround(units)
	local pos = self.Entity:GetPos()
	local ang = Vector(0,0,-1)
	local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*units)
		tracedata.filter = self.Entity
	local trace = util.TraceLine(tracedata) 
	return trace.HitWorld
end

function ENT:MoveTo(dest)
	if(self.destinationEntity) then
			if(self.destinationEntity:IsValid()) then
				self.destinationEntity:Remove()
			end
		end
	if(!self.bootin) then
	self.atDestination = false
	self.destination = dest
	self.moving = true
	self.destinationEntity = ents.Create("info_target")
	self.destinationEntity:SetPos(dest)
	self.destinationEntity:Spawn()
	self.Entity:PointAtEntity(self.destinationEntity)
	self.phys:Wake()
	self.hasTouched = false
	end
end

function ENT:isAtDestination()
	return self.atDestination
end

function ENT:StartTouch( ent )
	if ent:IsPlayer() then return end
	if(!self.hasTouched) then
	if(ent:GetClass() == "army" && ent:GetOverlord() == self.Overlord && ent:isAtDestination()) then
		self.atDestination = true
		self.moving = false
		self.destination = nil
		if(self.destinationEntity) then
			if(self.destinationEntity:IsValid()) then
				self.destinationEntity:Remove()
			end
		end
		self.phys:Sleep()
		self.hasTouched = true
		return
	end
	end
end


function ENT:SetSpawner(ply)
	self.SpawnedBy = ply
	if(!self.claimed) then
	if(ply == self.SpawnedBy) then
		self.Entity:SetColor(ply:GetColor())
		ply:SetNWInt(ply:Nick() .. "_soldiers", ply:GetNWInt(ply:Nick() .. "_soldiers") + 1) 
		self.claimed = true
		self.Overlord = ply
		self.combatant = true
	end
	end
end

function ENT:GetOverlord()
	return self.Overlord
end

function ENT:Disband()
	if(self.Overlord != "nothing") then
		self.Overlord:SetNWInt(self.Overlord:Nick() .. "_soldiers", self.Overlord:GetNWInt(self.Overlord:Nick() .. "_soldiers") - 1)
		local effectdata = EffectData()
		effectdata:SetEntity( self )
		effectdata:SetOrigin( self.Entity:GetPos())
		util.Effect( "gib_explosion", effectdata )
		self.Overlord = "nothing"
		self.SpawnedBy = "nothing"
		if(self.destinationEntity) then
			if(self.destinationEntity:IsValid()) then
				self.destinationEntity:Remove()
			end
		end
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

