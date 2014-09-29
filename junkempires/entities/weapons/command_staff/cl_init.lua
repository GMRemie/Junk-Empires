include ("shared.lua")

SWEP.PrintName = "JE Command Staff"
SWEP.Slot = 2
SWEP.Slotpos = 1
SWEP.Drawammo = false
SWEP.Drawcrosshair = true

	unitList = {
	"City",
	"Ranged Support",
	"Wall",
	"Medic Station"
	}
	
	unitPrices = {
	"50 Food, 25 Iron",
	"20 Food, 30 Iron",
	"2 Iron, 2 Gold",
	"30 Food, 15 Gold"
	}
	
	
	LocalPlayer():SetNWInt("buildSelected", 1)

function SWEP:DrawHUD()
  
	draw.RoundedBox( 8, ScrW() * .5, ScrH() * .5, 120, 40, Color(0,0,0,155) ) 
	
	draw.DrawText( unitList[self.Owner:GetNWInt("buildSelected")] , "ScoreboardText", ScrW() * .5 + 5, ScrH() * .5 + 5 , Color(155,155,155,255),0)
	draw.DrawText( unitPrices[self.Owner:GetNWInt("buildSelected")] , "ScoreboardText", ScrW() * .5 + 5, ScrH() * .5 + 18 , Color(155,155,155,255),0)

end 