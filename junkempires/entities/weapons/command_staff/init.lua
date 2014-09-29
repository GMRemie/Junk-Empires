AddCSLuaFile ("cl_init.lua");
AddCSLuaFile ("shared.lua");
  
include ("shared.lua");
  
SWEP.Weight = 5;
SWEP.AutoSwitchTo = false;
SWEP.AutoSwitchFrom = false; 

//Lclick cities, rclick medic, shift rclick wall, shift lclick fire support
//Thanks robbis, andy
local meta = FindMetaTable("Player")
 
 function meta:GetEyeTrace()
    if ( self:GetTable().LastPlayertTrace == CurTime() ) then
        return self:GetTable().PlayerTrace
    end
 
    self:GetTable().PlayerTrace = util.TraceLine( util.GetPlayerTrace( self, self:GetCursorAimVector() ) )
    self:GetTable().LastPlayertTrace = CurTime()
       
    return self:GetTable().PlayerTrace
end
	

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
	
end

function SWEP:Deploy()
	unitList = {
	"City",
	"Ranged Support",
	"Wall",
	"Medic Station"
	}
	
	unitPrices = {
	"50 food, 25 iron",
	"20 food, 30 iron",
	"2 iron, 2 gold",
	"30 food, 15 gold"
	}

	
	self.buildSelect = unitList[1]
	self.buildSelectCount = 1
	self.Owner:SetNWInt("buildSelected", 1)
	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	local tr = self.Owner:GetEyeTrace()

	if (!tr.HitWorld ) then return end
	
	local inSupply = false
		
	for _, ent in pairs( ents.FindInSphere(tr.HitPos, 72) ) do
		if(ent:GetClass() == "city") then
			if(ent:GetOverlord() == self.Owner) then
				inSupply = true
				break
			end
		end
	end 
	
	if(self.buildSelect == "City") then
		//so ya don't have to use shit after building it, thanks devenger
		if(tr.HitNormal != Vector(0,0,1)) then
			self.Owner:ChatPrint("Sorry, cities must be built on flat ground!")
			return
		end
	
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_food") < 50 || self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") < 25) then 
			self.Owner:ChatPrint("You don't have enough resources: Need 50 food and 25 iron")
			return
		end
		
		for _, ent in pairs( ents.FindInSphere(tr.HitPos, 144) ) do
			if(ent:GetClass() == "city" || ent:GetClass() == "army" || ent:GetClass() == "wall" && ent:IsValid()) then
				if(ent:GetOverlord() != self.Owner) then
					self.Owner:ChatPrint("Can't build so close to enemy combat units!")
					return
				end
			end
		end 
	
		local ent = ents.Create( "city" )
			ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
			ent:SetAngles(Angle(0, 90, 0))  
			ent:Spawn()
			ent:Activate()
			ent:SetSpawner(self.Owner)
	
	
		self.Owner:SetNWInt(self.Owner:Nick() .. "_food", self.Owner:GetNWInt(self.Owner:Nick() .. "_food") - 50)
		self.Owner:SetNWInt(self.Owner:Nick() .. "_iron", self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") - 25)
		
		return
	end
	
	if(self.buildSelect == "Ranged Support") then
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_food") < 20 || self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") < 30) then
			self.Owner:ChatPrint("You don't have enough resources: Need 20 food and 30 iron")
			return
		end
		
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_ranged") >= 5) then
			self.Owner:ChatPrint("Sorry! Only 5 ranged support units are allowed!")
			return
		end
		
		if(inSupply) then
			local ent = ents.Create( "ranged_support" )
				ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
				ent:Spawn()
				ent:Activate()
				ent:SetSpawner(self.Owner)
			
			self.Owner:SetNWInt(self.Owner:Nick() .. "_food", self.Owner:GetNWInt(self.Owner:Nick() .. "_food") - 20)
			self.Owner:SetNWInt(self.Owner:Nick() .. "_iron", self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") - 30)
			return
		else
			self.Owner:ChatPrint("Ranged support units must be built close to friendly cities!")
			return
		end
	end
	
	
	if(self.buildSelect == "Wall") then
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") < 2 || self.Owner:GetNWInt(self.Owner:Nick() .. "_gold") < 2) then
			self.Owner:ChatPrint("You don't have enough resources: Need 2 iron and 2 gold")
			return
		end

		if(inSupply) then
			local ent = ents.Create( "wall" )
				ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 - Vector(0,0,8) )
				ent:SetAngles(Angle(0, 90, 0))  
				ent:Spawn()
				ent:Activate()
				ent:SetSpawner(self.Owner)
		else
			self.Owner:ChatPrint("Can't create a wall outside of a city supply zone!")
			return
		end
	
		self.Owner:SetNWInt(self.Owner:Nick() .. "_gold", self.Owner:GetNWInt(self.Owner:Nick() .. "_gold") - 2)
		self.Owner:SetNWInt(self.Owner:Nick() .. "_iron", self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") - 2)
		return
	end
	
	if(self.buildSelect == "Medic Station") then
		if(self.Owner:GetNWInt(self.Owner:Nick() .. "_food") < 30 || self.Owner:GetNWInt(self.Owner:Nick() .. "_gold") < 15) then
			self.Owner:ChatPrint("You don't have enough resources: Need 30 food and 15 gold")
			return
		end
		
		if(inSupply) then
			local ent = ents.Create( "medic_station" )
				ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
				ent:Spawn()
				ent:Activate()
				ent:SetSpawner(self.Owner)
				
			self.Owner:SetNWInt(self.Owner:Nick() .. "_food", self.Owner:GetNWInt(self.Owner:Nick() .. "_food") - 30)
			self.Owner:SetNWInt(self.Owner:Nick() .. "_gold", self.Owner:GetNWInt(self.Owner:Nick() .. "_gold") - 15)	
			return
		else
			self.Owner:ChatPrint("Medic stations must be built close to friendly cities!")
			return
		end
	end
	
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	
	if(self.buildSelectCount < 4) then
		self.buildSelectCount = self.buildSelectCount + 1
		self.buildSelect = unitList[self.buildSelectCount]
		self.Owner:SetNWInt("buildSelected", self.buildSelectCount)
		return
	else
		self.buildSelect = unitList[1]
		self.buildSelectCount = 1
		self.Owner:SetNWInt("buildSelected", 1)
		return
	end
	
	
end

function SWEP:Reload()

	local tr = self.Owner:GetEyeTrace()

	if (tr.HitWorld ) then return end
	
	if(!tr.Entity:IsValid()) then return end
	
	if(tr.Entity:GetClass() == "army") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:Disband()
			self.Owner:SetNWInt(self.Owner:Nick() .. "_food", self.Owner:GetNWInt(self.Owner:Nick() .. "_food") + 5)
			self.Owner:SetNWInt(self.Owner:Nick() .. "_iron", self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") + 2)
		end
	end
	
	if(tr.Entity:GetClass() == "city") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:Raze()
			self.Owner:SetNWInt(self.Owner:Nick() .. "_food", self.Owner:GetNWInt(self.Owner:Nick() .. "_food") + 25)
			self.Owner:SetNWInt(self.Owner:Nick() .. "_iron", self.Owner:GetNWInt(self.Owner:Nick() .. "_iron") + 12)
		end
	end
	
	if(tr.Entity:GetClass() == "farm") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:RemoveControl()
		end
	end
	
	if(tr.Entity:GetClass() == "iron_mine") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:RemoveControl()
		end
	end
	
	if(tr.Entity:GetClass() == "wall") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:Raze()
		end
	end
	
	if(tr.Entity:GetClass() == "ranged_support") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:Disband()
		end
	end
	
	if(tr.Entity:GetClass() == "medic_station") then
		if( tr.Entity:GetOverlord() == self.Owner ) then
			tr.Entity:Raze()
		end
	end
		
	
  
 end 
 
 
 