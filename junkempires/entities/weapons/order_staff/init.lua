AddCSLuaFile ("cl_init.lua");
AddCSLuaFile ("shared.lua");
  
include ("shared.lua");
  
SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false; 


// lclick select armies, rclick send order, shift lclick select box, 
//shift rclick build army, use+lclick place fire support marker, reload clear selected
//Thanks robbis, andy
local meta = FindMetaTable("Player")
 
 function meta:GetEyeTrace()
    if ( self:GetTable().LastPlayertTrace == CurTime() ) then
        return self:GetTable().PlayerTrace
    end
 
    self:GetTable().PlayerTrace = util.TraceLine({start = self:EyePos(), endpos = self:EyePos() + self:GetAimVector() * 120, filter = self})

    self:GetTable().LastPlayertTrace = CurTime()
       
    return self:GetTable().PlayerTrace
end
	

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()

	for _, ent in pairs( self.selectedUnits) do
		ent:SetNWBool("isSelected", false)
	end 
	self.selectedUnits = {}
end

function SWEP:Deploy()
	if(!self.selectedUnits) then
		self.selectedUnits = {}
	end
	
	self.selectA = nil
	self.selectB = nil
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
	
end

function SWEP:Holster(wep)	
	for _, ent in pairs( self.selectedUnits) do
		ent:SetNWBool("isSelected", false)
	end 
	self.selectedUnits = {}
	
	return true
end

function SWEP:JEID()
	return "order_staff"
end

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	local tr = self.Owner:GetEyeTrace()
	
	if self.Owner:KeyDown( IN_SPEED ) then
	
		if (!tr.HitWorld ) then return end
		
		if(!self.selectA) then
			self.selectA = tr.HitPos
			self.Owner:ChatPrint("Starting group select...")
			return
		else
			self.selectB = tr.HitPos 
			self.Owner:ChatPrint("Group select completed!")
			local c = (self.selectA + self.selectB) * 0.5
			local r = self.selectA:Distance(self.selectB) * 0.5
			for _, ent in pairs(ents.FindInSphere( c, r)) do
				if(ent:GetClass() == "army") then
				if(ent:GetOverlord() == self.Owner) then
					if(!ent:GetNWBool("isSelected")) then
						table.insert(self.selectedUnits, ent)
						ent:SetNWBool("isSelected", true)
					end
				end
				end
			end
			self.selectA = nil
			self.selectB = nil
			return
		end
	end
	
	if(tr.HitWorld ) then return end
	
	if (!tr.Entity:IsValid()) then return end
	
	if(!tr.Entity:GetClass() == "army") then return end
	
	local army = tr.Entity
	
	if(army:GetOverlord() != self.Owner) then return end
	
	if(army:GetOverlord() == self.Owner) then
		if(army:GetNWBool("isSelected")) then
			army:SetNWBool("isSelected", false)
			local c = 1
			for _, ent in pairs( self.selectedUnits) do
				if(ent == army) then
					table.remove(self.selectedUnits, c)
				end
				c = c + 1
			end 
			
			return
		end
		table.insert(self.selectedUnits, army)
		army:SetNWBool("isSelected", true)
	end


end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	local tr = self.Owner:GetEyeTrace()
	
	if self.Owner:KeyDown( IN_SPEED ) then
		self.inSupply = false
		
		if (!tr.HitWorld ) then return end
		
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_food") < 10 || self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") < 5) then
			self.Owner:ChatPrint("You don't have enough resources: Need 10 food and 5 iron")
			return
		end
	
		for _, ent in pairs( ents.FindInSphere(tr.HitPos, 70) ) do
			if(ent:GetClass() == "city") then
				if(ent:GetOverlord() == self.Owner) then
					self.inSupply = true
				end
			end
		end 


		if(self.inSupply) then
			local ent = ents.Create( "army" )
			ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
			ent:SetAngles(Angle(0, 90, 0))  
			ent:Spawn()
			ent:Activate()
			ent:SetSpawner(self.Owner)
		end
	
		if(!self.inSupply) then
			self.Owner:ChatPrint("Can't create an army outside of a supply/attack zone!")
			return
		end
	
		self.inSupply = false
	
		self.Owner:SetNWInt(self.Owner:Nick() .. "_food", self.Owner:GetNWInt(self.Owner:Nick() .. "_food") - 10)
		self.Owner:SetNWInt(self.Owner:Nick() .. "_iron", self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") - 5)
		return
	end
	
	if self.Owner:KeyDown( IN_USE) then
	
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_ranged") <= 0) then
			self.Owner:ChatPrint("You don't have any ranged support available!")
			return
		end
		
		if(!self.Owner:GetNWBool(self.Owner:Nick() .. "_calledFireSupport")) then
			local ent = ents.Create( "ranged_support_marker" )
			ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 + Vector(0,0,20) )
			ent:Spawn()
			ent:Activate()
			ent:SetSpawner(self.Owner)
			self.Owner:SetNWBool(self.Owner:Nick() .. "_calledFireSupport", true)
			resetFSTick(self.Owner)
			return
		else
			self.Owner:ChatPrint("Ranged support is reloading!")
			return
		end
		
		return
	end
	
	if(tr.HitWorld ) then 
		if(table.getn(self.selectedUnits) > 0) then
		for _, x in pairs(self.selectedUnits) do
			if(x:IsValid() && x:GetClass() == "army") then
				x:MoveTo(tr.HitPos)
			end
		end
		end
	end

	
	
end


 