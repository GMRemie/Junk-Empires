//JUNK EMPIRES by GRIPPE
//Hey sassafrasshole, FUCK YOU!

AddCSLuaFile("cl_init.lua")

GM.Name 	= "Junk Empires"
GM.Author 	= "grippe"

default_food = 150
default_gold = 0
default_iron = 75

victory_limit = 1000 //how much gold needs to be accumulated before winning

iron_tick = 2 //how much iron is gained each tick from each node
food_tick = 5 //how much food is gained each tick from each node

resource_tick = 8 //delay in seconds between resource collection

start = true

AllPlayers = {}

resourceTick = true
cityCounter = 1

all_armies = {}
enemy_armies = 0
friendly_armies = 0

alliances = {} //table that holds alliances between players
allianceWait = {} //table that stores people waiting on alliance confirmation
tradeWait = {} //table that stores people waiting on trade confirmation
tradeOffer = {}

playerColors = {
{255, 0, 0},
{0, 255, 0},
{0, 0, 255},
{255, 255, 0},
{255, 0, 255},
{0, 255, 255},
{0, 0, 0},
{125, 0, 0},
{0, 125, 0},
{0, 0, 125},
{125, 125, 0},
{125, 0, 125},
{0, 125, 125},
}


function GM:Initialize()

	self.BaseClass:Initialize()

end

function GM:PlayerInitialSpawn(ply)

	Msg("Initializing resources for " .. ply:Nick() .. "\n")
	ply:SetNWInt(ply:Nick() .. "_food", default_food)
	ply:SetNWInt(ply:Nick() .. "_gold", default_gold)
	ply:SetNWInt(ply:Nick() .. "_iron", default_iron)
	ply:SetNWInt(ply:Nick() .. "_cities", 0)
	ply:SetNWInt(ply:Nick() .. "_soldiers", 0)
	ply:SetNWInt(ply:Nick() .. "_mines", 0)
	ply:SetNWInt(ply:Nick() .. "_farms", 0)
	ply:SetNWInt(ply:Nick() .. "_traders", 0)
	
	ply:SetNWInt(ply:Nick() .. "_ranged", 0)
	
	ply:SetNWInt(ply:Nick() .. "_pylons", 0)
	
	
	ply:SetNWBool(ply:Nick() .. "_calledFireSupport", false)
	
	local pcIndex = math.random(1,table.getn(playerColors))
	
	r = playerColors[pcIndex][1]
	g = playerColors[pcIndex][2]
	b = playerColors[pcIndex][3]
	
	table.remove(playerColors, pcIndex)

	ply:SetNWInt(ply:Nick() .. "_red", r)
	ply:SetNWInt(ply:Nick() .. "_green", g)
	ply:SetNWInt(ply:Nick() .. "_blue", b)
	
	ply:SetColor( r, g, b, 255 )
	
	ply:ChatPrint("Welcome to Junk Empires! Press F1 for help.")
	
	alliances[ply] = {}
	allianceWait[ply] = {}
	tradeWait[ply] = {}
	tradeOffer[ply] = {}
	tradeOffer[ply].fo = 0
	tradeOffer[ply].iro = 0
	tradeOffer[ply].go = 0
	tradeOffer[ply].fr = 0
	tradeOffer[ply].ir = 0
	tradeOffer[ply].gr = 0
	
end

function GM:Think()
	
	//Dole out resources to players
	
	if(resourceTick) then
		for k, ply in pairs(player.GetAll()) do
			//process mines
			for i = 1, ply:GetNWInt(ply:Nick() .. "_mines") do
				ply:SetNWInt(ply:Nick() .. "_iron", ply:GetNWInt(ply:Nick() .. "_iron") + iron_tick)
			end

			//process farms
			for i = 1, ply:GetNWInt(ply:Nick() .. "_farms") do
				ply:SetNWInt(ply:Nick() .. "_food", ply:GetNWInt(ply:Nick() .. "_food") + food_tick)
			end
			
			//process cities for gold 
			for i = 1, ply:GetNWInt(ply:Nick() .. "_cities") do
				ply:SetNWInt(ply:Nick() .. "_gold", ply:GetNWInt(ply:Nick() .. "_gold") + 1)
				
				if(table.getn(ents.FindByClass("pylon")) == 0) then
					ply:SetFrags( ply:GetNWInt(ply:Nick() .. "_gold") )
					if(ply:GetNWInt(ply:Nick() .. "_gold") >= victory_limit) then
						GameOver(ply)
					end
				else
					ply:SetFrags( ply:GetNWInt(ply:Nick() .. "_pylons") )
					if(ply:GetNWInt(ply:Nick() .. "_pylons") > (table.getn(ents.FindByClass("pylon")) * .6)) then
						GameOver(ply)
					end
				end
					
			end
			
			ply:SetNWInt(ply:Nick() .. "_food", ply:GetNWInt(ply:Nick() .. "_food") + 5)
			ply:SetNWInt(ply:Nick() .. "_iron", ply:GetNWInt(ply:Nick() .. "_iron") + 2)
			
		end
		
		resourceTick = false
		timer.Simple(resource_tick, resetResourceTick)
		
		
	end
	

end

function resetFSTick(ply)
	timer.Simple(30,resetFSTick2,ply)
end

function resetFSTick2(ply)
	ply:SetNWBool(ply:Nick() .. "_calledFireSupport", false)
end


function GM:PlayerDisconnected(ply)

	for _, x in pairs(ents.FindByClass("army")) do
		if(x:GetOverlord() == ply) then
			x:Disband()
		end
	end
	
	for _, x in pairs(ents.FindByClass("city")) do
		if(x:GetOverlord() == ply) then
			x:Raze()
		end
	end
	
	
	for _, x in pairs(ents.FindByClass("farm")) do
		if(x:GetOverlord() == ply) then
			x:RemoveControl()
		end
	end
	
	for _, x in pairs(ents.FindByClass("iron_mine")) do
		if(x:GetOverlord() == ply) then
			x:RemoveControl()
		end
	end
	
	for _, x in pairs(ents.FindByClass("wall")) do
		if(x:GetOverlord() == ply) then
			x:Raze()
		end
	end
	
	
	for _, x in pairs(ents.FindByClass("ranged_support")) do
		if(x:GetOverlord() == ply) then
			x:Disband()
		end
	end
	
	for _, x in pairs(ents.FindByClass("medic_station")) do
		if(x:GetOverlord() == ply) then
			x:Raze()
		end
	end
	
	if(table.getn(ents.FindByClass("pylon")) != 0) then
		for _, x in pairs(ents.FindByClass("pylon")) do
			if(x:GetOverlord() == ply) then
				x:RemoveControl()
			end
		end
	end
	
	r = ply:GetNWInt(ply:Nick() .. "_red")
	g = ply:GetNWInt(ply:Nick() .. "_green")
	b = ply:GetNWInt(ply:Nick() .. "_blue")

	table.insert(playerColors, {r, g, b})
	


	ply:SetNWInt(ply:Nick() .. "_gold", 0)
	
end

function GM:ShowHelp(ply)
	ply:ConCommand( "helpme" ) 	
end

function GM:ShowTeam(ply)
	ply:ConCommand( "je_frpanel" ) 	
end

function GM:ShowSpare1(ply)
	ply:ConCommand( "je_showcontrols")
end

function GameOver(ply)

	for _, x in pairs(ents.FindByClass("army")) do
		x:Disband()
	end
	
	for _, x in pairs(ents.FindByClass("city")) do
		x:Raze()
	end
	
	for _, x in pairs(ents.FindByClass("farm")) do
		x:RemoveControl()
	end
	
	for _, x in pairs(ents.FindByClass("iron_mine")) do
		x:RemoveControl()
	end
	
	for _, x in pairs(ents.FindByClass("wall")) do
		x:Raze()
	end
	
	
	for _, x in pairs(ents.FindByClass("ranged_support")) do
		x:Disband()
	end
	
	for _, x in pairs(ents.FindByClass("medic_station")) do
		x:Raze()
	end
	
	for _, x in pairs(ents.FindByClass("pylon")) do
		x:RemoveControl()
	end

	for k, plyr in pairs(player.GetAll()) do
	
		//plyr:ChatPrint(ply:Nick() .. " has won the match!")

		plyr:ChatPrint("Now clearing the world and resetting resources...")
	
		plyr:SetNWInt(plyr:Nick() .. "_food", default_food)
		plyr:SetNWInt(plyr:Nick() .. "_gold", default_gold)
		plyr:SetNWInt(plyr:Nick() .. "_iron", default_iron)
		plyr:SetNWInt(plyr:Nick() .. "_cities", 0)
		plyr:SetNWInt(plyr:Nick() .. "_soldiers", 0)
		plyr:SetNWInt(plyr:Nick() .. "_ranged", 0)
		plyr:SetNWInt(plyr:Nick() .. "_mines", 0)
		plyr:SetNWInt(plyr:Nick() .. "_farms", 0)
		plyr:SetNWInt(plyr:Nick() .. "_pylons", 0)
		
		plyr:SetFrags(0)
		
		plyr:Lock()
		plyr:ConCommand("je_victoryscreen " .. ply:Nick() .. " " .. table.getn(player.GetAll()) .. "\n")
	
	end
	
	ply:AddDeaths(100)
	
	timer.Simple(20, unlockPlayers)
	
end

function unlockPlayers()
	for k, plyr in pairs(player.GetAll()) do
		plyr:UnLock()	
		plyr:SetNWInt(plyr:Nick() .. "_food", default_food)
		plyr:SetNWInt(plyr:Nick() .. "_gold", default_gold)
		plyr:SetNWInt(plyr:Nick() .. "_iron", default_iron)
	end

end

function ManualReset(ply, command, args)

	if(ply:IsAdmin()) then
	Msg(ply:Nick() .. " is resetting the match\n" )
	for _, x in pairs(ents.FindByClass("army")) do
		x:Disband()
	end
	
	for _, x in pairs(ents.FindByClass("city")) do
		x:Raze()
	end
	
	for _, x in pairs(ents.FindByClass("farm")) do
		x:RemoveControl()
	end
	
	for _, x in pairs(ents.FindByClass("iron_mine")) do
		x:RemoveControl()
	end
	
	for _, x in pairs(ents.FindByClass("wall")) do
		x:Raze()
	end
	
	
	for _, x in pairs(ents.FindByClass("ranged_support")) do
		x:Disband()
	end
	
	for _, x in pairs(ents.FindByClass("medic_station")) do
		x:Raze()
	end
	
	for _, x in pairs(ents.FindByClass("pylon")) do
		x:RemoveControl()
	end

	for k, plyr in pairs(player.GetAll()) do
	
		plyr:ChatPrint("MATCH RESET! Resetting all resources, armies, cities, and players")
	
		plyr:SetNWInt(plyr:Nick() .. "_food", default_food)
		plyr:SetNWInt(plyr:Nick() .. "_gold", default_gold)
		plyr:SetNWInt(plyr:Nick() .. "_iron", default_iron)
		plyr:SetNWInt(plyr:Nick() .. "_cities", 0)
		plyr:SetNWInt(plyr:Nick() .. "_soldiers", 0)
		plyr:SetNWInt(plyr:Nick() .. "_mines", 0)
		plyr:SetNWInt(plyr:Nick() .. "_farms", 0)
		plyr:SetNWInt(plyr:Nick() .. "_ranged", 0)
		plyr:SetNWInt(plyr:Nick() .. "_pylons", 0)
		
		plyr:SetFrags(0)
	
	end
	end
end

function resetResourceTick()
	resourceTick = true
	
	
	for k, plyr in pairs(player.GetAll()) do
		plyr:SetNWInt(plyr:Nick() .. "_rtint", 1)
	end
	
	
end

function GM:PlayerLoadout( ply )
	ply:StripWeapons()  
	ply:Give("command_staff")
	ply:Give("order_staff")
	return true
end

function createAlliance(ply, command, args)
	
	local ply2 = nil
	
	for k, v in pairs(player.GetAll()) do //dumb hack since player.GetByID() doesn't work?
		if(v:UserID() == tonumber(args[1])) then
			ply2 = v
		end
	end 
	
	if(ply2) then
	
		for _, p in pairs(allianceWait[ply]) do //check  they're needed to wait for an alliance
			if(p == ply2) then
				table.insert(alliances[ply], ply2)
				table.insert(alliances[ply2], ply)
				
				count = 1
				for _, b in pairs(allianceWait[ply]) do
					if(b == ply2) then
						table.remove(allianceWait[ply], count)
					end
				count = count + 1
				end 
	
				count = 1
				for _, b in pairs(allianceWait[ply2]) do
					if(b == ply) then
						table.remove(allianceWait[ply2], count)
					end
				count = count + 1
				end
				
				for k, v in pairs(player.GetAll()) do
					v:ChatPrint(ply:Nick() .. " has allied with " .. ply2:Nick() .. "!")
				end 
		
				return
			end
		end 

		//If you're not one of the people he needs to confirm an alliance
		table.insert(allianceWait[ply2], ply) //enter ply as someone needing to confirm alliance
		table.insert(allianceWait[ply], ply2) //enter ply as someone needing to confirm alliance
		ply2:ChatPrint(ply:Nick() .. " wants to ally with you! To confirm alliance press F2 and offer an alliance to player ID " .. ply:UserID())

	else
		Msg("Sorry, user not found!\n")
	end
	
end

function breakAlliance(ply, command, args)

	local ply2 = nil
	local allied = false
		
	for _, v in pairs(player.GetAll()) do //dumb hack since player.GetByID() doesn't work?
		if(v:UserID() == tonumber(args[1])) then
			ply2 = v
		end
	end 
	
	if(ply2) then
	
	for _, b in pairs(alliances[ply]) do
		if(b == ply2) then
			allied = true
		end
	end 
	
	if(allied) then
	
	count = 1
	for _, b in pairs(alliances[ply]) do
		if(b == ply2) then
			table.remove(alliances[ply], count)
		end
		count = count + 1
	end 
	
	count = 1
	for _, b in pairs(alliances[ply2]) do
		if(b == ply) then
			table.remove(alliances[ply2], count)
		end
		count = count + 1
	end

	for k, v in pairs(player.GetAll()) do
		v:ChatPrint("The alliance between " .. ply:Nick() .. " and " .. ply2:Nick() .. " has been broken!")
	end 
	
	end
	
	else
		Msg("Sorry, user not found!\n")
	
	end

	
	
	
end


/*
The args table of the trade functions are as follows:
args[1] = player ID of the offer recipient
args[2] = food offer
args[3] = iron offer
args[4] = gold offer
args[5] = food request
args[6] = iron request
args[7] = gold request
*/

function trade(ply, command, args)
	if(table.getn(args) < 7) then
		Msg("Trade data incomplete! Make sure 0's are used instead of blanks\n")
		return
	end
	
	local tply = nil
	
	for k, v in pairs(player.GetAll()) do //dumb hack since player.GetByID() doesn't work?
		if(v:UserID() == tonumber(args[1])) then
			tply = v
		end
	end 
	
	if(tply) then
	
		for _, p in pairs(tradeWait[ply]) do //check  ply they're needed to wait for a trade
			if(p == tply) then
				
				if(	(tply:GetNWInt(tply:Nick() .. "_food") < tradeOffer[tply].fo) || (tply:GetNWInt(tply:Nick() .. "_iron") < tradeOffer[tply].iro) || (tply:GetNWInt(tply:Nick() .. "_gold") < tradeOffer[tply].go)) then
					tply:ChatPrint("Not enough resources for trade!")
					ply:ChatPrint("Not enough resources for trade!")
				return
				end
				
				if(	(ply:GetNWInt(ply:Nick() .. "_food") < tradeOffer[tply].fr) || (ply:GetNWInt(ply:Nick() .. "_iron") < tradeOffer[tply].ir) || (ply:GetNWInt(ply:Nick() .. "_gold") < tradeOffer[tply].gr)) then
					tply:ChatPrint("Not enough resources for trade!")
					ply:ChatPrint("Not enough resources for trade!")
				return
				end
				
				tply:SetNWInt(tply:Nick() .. "_food", tply:GetNWInt(tply:Nick() .. "_food") - tradeOffer[tply].fo)
				tply:SetNWInt(tply:Nick() .. "_iron", tply:GetNWInt(tply:Nick() .. "_iron") - tradeOffer[tply].iro)
				tply:SetNWInt(tply:Nick() .. "_gold", tply:GetNWInt(tply:Nick() .. "_gold") - tradeOffer[tply].go)
	
				ply:SetNWInt(ply:Nick() .. "_food", ply:GetNWInt(ply:Nick() .. "_food") + tradeOffer[tply].fo)
				ply:SetNWInt(ply:Nick() .. "_iron", ply:GetNWInt(ply:Nick() .. "_iron") + tradeOffer[tply].iro)
				ply:SetNWInt(ply:Nick() .. "_gold", ply:GetNWInt(ply:Nick() .. "_gold") + tradeOffer[tply].go)
				
				tply:SetNWInt(tply:Nick() .. "_food", tply:GetNWInt(tply:Nick() .. "_food") + tradeOffer[tply].fr)
				tply:SetNWInt(tply:Nick() .. "_iron", tply:GetNWInt(tply:Nick() .. "_iron") + tradeOffer[tply].ir)
				tply:SetNWInt(tply:Nick() .. "_gold", tply:GetNWInt(tply:Nick() .. "_gold") + tradeOffer[tply].gr)
	
				ply:SetNWInt(ply:Nick() .. "_food", ply:GetNWInt(ply:Nick() .. "_food") - tradeOffer[tply].fr)
				ply:SetNWInt(ply:Nick() .. "_iron", ply:GetNWInt(ply:Nick() .. "_iron") - tradeOffer[tply].ir)
				ply:SetNWInt(ply:Nick() .. "_gold", ply:GetNWInt(ply:Nick() .. "_gold") - tradeOffer[tply].gr)
				
				tply:ChatPrint("Trade with " .. ply:Nick() .. " completed.")
				ply:ChatPrint("Trade with " .. tply:Nick() .. " completed.")
				
				count = 1
				for _, b in pairs(tradeWait[ply]) do
					if(b == tply) then
						table.remove(tradeWait[ply], count)
					end
				count = count + 1
				end 
	
				count = 1
				for _, b in pairs(tradeWait[tply]) do
					if(b == ply) then
						table.remove(tradeWait[tply], count)
					end
				count = count + 1
				end
				
				tradeOffer[tply].fo = 0
				tradeOffer[tply].iro = 0
				tradeOffer[tply].go = 0
				tradeOffer[tply].fr = 0
				tradeOffer[tply].ir = 0
				tradeOffer[tply].gr = 0
				
				
				return
			end
		end 
		
		if(	(ply:GetNWInt(ply:Nick() .. "_food") < tonumber(args[2])) || (ply:GetNWInt(ply:Nick() .. "_iron") < tonumber(args[3])) || (ply:GetNWInt(ply:Nick() .. "_gold") < tonumber(args[4]))) then
			ply:ChatPrint("Not enough resources for trade!")
			return
		end

		//If you're not one of the people he needs to confirm a trade
		table.insert(tradeWait[ply], tply) //enter tply as someone needing to confirm trade
		table.insert(tradeWait[tply], ply) //enter tply as someone needing to confirm trade
		tply:ChatPrint(ply:Nick() .. " wants to trade: You will get " .. args[2] .. "f , " .. args[3] .. "i, " .. args[4] .. "g in exchange for " .. args[5] .. "f , " .. args[6] .. "i, " .. args[7] .. "g")
		tply:ChatPrint("to accept press F2 and send an empty trade request to player ID " .. ply:UserID())
		tradeOffer[ply].fo = tonumber(args[2])
		tradeOffer[ply].iro = tonumber(args[3])
		tradeOffer[ply].go = tonumber(args[4])
		tradeOffer[ply].fr = tonumber(args[5])
		tradeOffer[ply].ir = tonumber(args[6])
		tradeOffer[ply].gr = tonumber(args[7])
		
	else
		Msg("Sorry, user not found!\n")
	end
	
	
end

function give(ply, command, args)
	
	if(table.getn(args) < 7) then
		Msg("Trade data incomplete! Make sure 0's are used instead of blanks\n")
		return
	end
	
	local tply = nil
		
	for _, v in pairs(player.GetAll()) do //dumb hack since player.GetByID() doesn't work?
		if(v:UserID() == tonumber(args[1])) then
			tply = v
		end
	end 
	
	if(	(ply:GetNWInt(ply:Nick() .. "_food") < tonumber(args[2])) || (ply:GetNWInt(ply:Nick() .. "_iron") < tonumber(args[3])) || (ply:GetNWInt(ply:Nick() .. "_gold") < tonumber(args[4]))) then
		Msg("Incomplete resources for trade!\n")
		return
	end
	
	tply:SetNWInt(tply:Nick() .. "_food", tply:GetNWInt(tply:Nick() .. "_food") + args[2])
	tply:SetNWInt(tply:Nick() .. "_iron", tply:GetNWInt(tply:Nick() .. "_iron") + args[3])
	tply:SetNWInt(tply:Nick() .. "_gold", tply:GetNWInt(tply:Nick() .. "_gold") + args[4])
	
	ply:SetNWInt(ply:Nick() .. "_food", ply:GetNWInt(ply:Nick() .. "_food") - args[2])
	ply:SetNWInt(ply:Nick() .. "_iron", ply:GetNWInt(ply:Nick() .. "_iron") - args[3])
	ply:SetNWInt(ply:Nick() .. "_gold", ply:GetNWInt(ply:Nick() .. "_gold") - args[4])
	
	ply:ChatPrint("Gave resources to " .. tply:Nick() .. "!")
	tply:ChatPrint("Received resources from " .. ply:Nick() .. "!")
	
end

concommand.Add( "je_ally", createAlliance)
concommand.Add( "je_break", breakAlliance)
concommand.Add( "je_reset", ManualReset) 
concommand.Add( "je_trade", trade)
concommand.Add( "je_give", give)



