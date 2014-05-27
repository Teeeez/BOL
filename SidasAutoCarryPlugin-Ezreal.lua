--[[
╔╦╗┌─┐┌─┐┌┬┐┬ ┬ ┬  ╔═╗┌─┐┬─┐┌─┐┌─┐┬  
 ║║├┤ ├─┤ │││ └┬┘  ║╣ ┌─┘├┬┘├┤ ├─┤│  
═╩╝└─┘┴ ┴─┴┘┴─┘┴   ╚═╝└─┘┴└─└─┘┴ ┴┴─┘
┌┐ ┬ ┬  ╔═╗╔═╗╔═╗╔╗╔╔╗╔              
├┴┐└┬┘  ║  ║  ║ ║║║║║║║              
└─┘ ┴   ╚═╝╚═╝╚═╝╝╚╝╝╚╝                 

VERSION:	1.00

CHANGELOG:	VERSION 1.00
				Initial Release

				
		Follow me on Facebook! Its the easiest way to communicate with me.
		CCONN's Facebook: https://www.facebook.com/CCONN81
		
		Like the script and want to donate?
		All donations go towards purchasing additional scripts and premium time so I can script more for you guys.
		CCONN's DONATE LINK: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JTWL7DK86V56S
--]]

if myHero.charName ~= "Ezreal" then return end

--[[
		Required Libs
--]]
require "Prodiction"
require "VPrediction"
require "FastCollision"
require "Collision"

--[[
		Variables
--]]
local Target = AutoCarry.GetAttackTarget()
local qRDY, wRDY, eRDY, rRDY
local qRNG, wRNG, eRNG, rRNG
local qSPD, wSPD, eSPD, rSPD = 2000, 1600, 0, 2000
local qDLY, wDLY, eDLY, rDLY = 0.25, 0.25, 0.5, 1
local qWTH, wWTH, eWTH, rWTH = 80, 80, 0, 150
local Prodict = ProdictManager.GetInstance()
local ProdictQ = Prodict:AddProdictionObject(_Q, qRNG, qSPD, qDLY, qWTH)
local ProdictW = Prodict:AddProdictionObject(_W, wRNG, wSPD, wDLY, wWTH)
local ProdictR = Prodict:AddProdictionObject(_R, rRNG, rSPD, rDLY, rWTH)
local ProdictQFastCol = FastCol(ProdictQ)
local ProdictQCol = Collision(qRNG, qSPD, qDLY, qWTH)
local VipPredTarget
local qp = TargetPredictionVIP(qRNG, qSPD, qDLY, qWTH)
local wp = TargetPredictionVIP(wRNG, wSPD, wDLY, wWTH)
local rp = TargetPredictionVIP(rRNG, rSPD, rDLY, rWTH)
local VP = VPrediction()
local Version = "1.00"

function PluginOnLoad()
	Menu()
	PrintChat(">> Deadly Ezreal version "..Version.." by CCONN")
end

function SpellCheck()
	qRNG = AutoCarry.PluginMenu.spelloptions.qoptions.RNG
	wRNG = AutoCarry.PluginMenu.spelloptions.woptions.RNG
	eRNG = AutoCarry.PluginMenu.spelloptions.eoptions.RNG
	rRNG = AutoCarry.PluginMenu.spelloptions.roptions.RNG
	qRDY = (myHero:CanUseSpell(_Q) == READY)
	wRDY = (myHero:CanUseSpell(_W) == READY)
	eRDY = (myHero:CanUseSpell(_E) == READY)
	rRDY = (myHero:CanUseSpell(_R) == READY)
end

--[[
		Script Menu
--]]
  
function Menu()
--[[
		Sub Menus
--]]
	AutoCarry.PluginMenu:addSubMenu("Auto Carry", "autocarry")
	AutoCarry.PluginMenu:addSubMenu("Mixed Mode", "mixedmode")
	AutoCarry.PluginMenu:addSubMenu("Lane Clear", "laneclear")
	AutoCarry.PluginMenu:addSubMenu("Last Hit", "farm")
	AutoCarry.PluginMenu:addSubMenu("Spell Options", "spelloptions")
	AutoCarry.PluginMenu:addSubMenu("Kill Steal", "killsteal")
	AutoCarry.PluginMenu:addSubMenu("Draw", "draw")
	AutoCarry.PluginMenu:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "Deadly Ezreal by CCONN", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "Version: "..Version, SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "www.facebook.com/CCONN81", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("Q: Mystic Shot", "qoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("W: Essence Flux", "woptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("E: Arcane Shift", "eoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("R: Trueshot Barrage", "roptions")
	
--[[
		Auto Carry Sub Menu
--]]
	AutoCarry.PluginMenu.autocarry:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)

--[[
		Mixed Mode Sub Menu
--]]
	AutoCarry.PluginMenu.mixedmode:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.mixedmode:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.mixedmode:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
	
	
--[[
		Last Hit Menu
--]]
	AutoCarry.PluginMenu.farm:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.farm:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.farm:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
	
	
--[[
		Lane Clear Sub Menu
--]]
	AutoCarry.PluginMenu.laneclear:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("useQ", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.laneclear:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.laneclear:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
	
--[[
		Spell Options Sub Menu
--]]
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1100, 0, 1100, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 4, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Collision", "Choose Collision: ", SCRIPT_PARAM_LIST, 1, {"Fast Collision", "Collision"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> Q Farm Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QFarmMana", "Mana Threshold", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
	
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Reset", "Reset Auto Attacks Only", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1050, 0, 1050, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
	
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> No Options Yet <<", SCRIPT_PARAM_INFO, "")
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 475, 0, 475, 0)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("Packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
	
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 19000, 0, 19000, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 3, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("Packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
	
	
--[[
		Kill Steal Sub Menu
--]]
	AutoCarry.PluginMenu.killsteal:addParam("KSEnable", "Enable Kill Steals", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("KSOverride", "Override Mana Thresholds", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("sep", ">> Kill Steal Permutations <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.killsteal:addParam("Q", "Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("W", "W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("R", "R", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("sep", "more coming soon...", SCRIPT_PARAM_INFO, "")
	--TODO add more killsteal permuations

--[[
		Draw Sub Menu
--]]
	AutoCarry.PluginMenu.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
end

--[[
		Draw Related
--]]
function PluginOnDraw()
	if qRDY and AutoCarry.PluginMenu.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRNG, 0xFFFFFF)
	end
	if wRDY and AutoCarry.PluginMenu.draw.DrawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, wRNG, 0xFFFFFF)
	end
	if eRDY and AutoCarry.PluginMenu.draw.DrawE then
		DrawCircle(myHero.x, myHero.y, myHero.z, eRNG, 0xFFFFFF)
	end
	if AutoCarry.PluginMenu.draw.DrawXP then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1600, 0xFFFFFF)
	end
end
--TODO lag free circles

--[[
		Main Script Function
--]]
function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	SpellCheck()
	if Target and AutoCarry.MainMenu.AutoCarry then ComboAC() end
	if Target and AutoCarry.MainMenu.MixedMode then ComboMM() end
	if Target and AutoCarry.MainMenu.LastHit then ComboFarm() end
	if Target and AutoCarry.MainMenu.LaneClear then ComboLC() end
	if AutoCarry.PluginMenu.killsteal.KSEnable then KillSteal() end
	if qRDY and AutoCarry.MainMenu.MixedMode and AutoCarry.PluginMenu.mixedmode.farmQ
	or qRDY and AutoCarry.MainMenu.LastHit and AutoCarry.PluginMenu.farm.farmQ
	or qRDY and AutoCarry.MainMenu.LaneClear and AutoCarry.PluginMenu.laneclear.farmQ then
	FarmQ() end
end

--[[
		Will last hit minions with
		Q using VPrediction to aim
--]]
function FarmQ()
	for i, creep in pairs(AutoCarry.EnemyMinions().objects) do
		if creep and not creep.dead and GetDistance(creep) <= qRNG then
			if myHero.mana >= myHero.maxMana * (AutoCarry.PluginMenu.spelloptions.qoptions.QFarmMana / 100) then
				if creep.health < getDmg("Q", creep, myHero) then
					CastVPredQ(creep)
				end
			end
		end
	end
end

--[[
		Kill Steals
--]]
  
--TODO Add all permutations for kill steals
--TODO Add mana thresholds and overrides
function KillSteal()
	for i = 1, heroManager.iCount do
	local enemy = heroManager:getHero(i)
	local Menu1 = AutoCarry.PluginMenu.killsteal
	local Menu2 = AutoCarry.PluginMenu.spelloptions
		if qRDY and Menu1.Q and ValidTarget(enemy, qRNG) and enemy.health < getDmg("Q",enemy,myHero) and myHero.mana >= ManaCost(Q) then
			if Menu2.qoptions.Prediction == 1 then CastVPredQ(enemy) end
			if Menu2.qoptions.Prediction == 2 then CastProdQ(enemy) end
			if Menu2.qoptions.Prediction == 3 then CastVIPQ(enemy) end
		end
		if wRDY and Menu1.W and ValidTarget(enemy, eRNG) and enemy.health < getDmg("W",enemy,myHero) and myHero.mana >= ManaCost(W) then
			if Menu2.eoptions.Prediction == 1 then CastVPredW(enemy) end
			if Menu2.eoptions.Prediction == 2 then CastProdW(enemy) end
			if Menu2.eoptions.Prediction == 3 then CastVIPW(enemy) end
		end
		if rRDY and Menu1.R and ValidTarget(enemy, rRNG) and enemy.health < getDmg("R",enemy,myHero) + 60 and myHero.mana >= ManaCost(R) then
			if Menu2.roptions.Prediction == 1 then CastVPredR(enemy) end
			if Menu2.roptions.Prediction == 2 then CastProdR(enemy) end
			if Menu2.roptions.Prediction == 3 then CastVIPR(enemy) end
		end
	end
end

--[[
		Combo that is executed when
		holding the AutoCarry hotkey
--]]
  --TODO Add spell casting order
function ComboAC()
	local Menu1 = AutoCarry.PluginMenu.autocarry
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target then
		if qRDY and Menu1.useQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
				if Menu2.qoptions.Prediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.Prediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.Prediction == 3 then CastVIPQ(Target) end
			end
		end
		if wRDY and Menu1.useW and GetDistance(Target) <= wRNG and not Menu2.woptions.Reset then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
				if Menu2.eoptions.Prediction == 1 then CastVPredW(Target) end
				if Menu2.eoptions.Prediction == 2 then CastProdW(Target) end
				if Menu2.eoptions.Prediction == 3 then CastVIPW(Target) end
			end
		end
		if rRDY and Menu1.useR and GetDistance(Target) <= rRNG then 
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
				if Menu2.roptions.Prediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.Prediction == 2 then CastProdR(Target) end
				if Menu2.roptions.Prediction == 3 then CastVIPR(Target) end
			end
		end
	end
end

--[[
		Combo that is executed when
		holding the Mixed Mode hotkey
--]]
  --TODO Add spell casting order
function ComboMM()
	local Menu1 = AutoCarry.PluginMenu.mixedmode
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target ~= nil then
		if qRDY and Menu1.useQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
				if Menu2.qoptions.Prediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.Prediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.Prediction == 3 then CastVIPQ(Target) end
			end
		end
		if wRDY and Menu1.useW and GetDistance(Target) <= wRNG and not Menu2.woptions.Reset then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
				if Menu2.eoptions.Prediction == 1 then CastVPredW(Target) end
				if Menu2.eoptions.Prediction == 2 then CastProdW(Target) end
				if Menu2.eoptions.Prediction == 3 then CastVIPW(Target) end
			end
		end
		if rRDY and Menu1.useR and GetDistance(Target) <= rRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
				if Menu2.roptions.Prediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.Prediction == 2 then CastProdR(Target) end
				if Menu2.roptions.Prediction == 3 then CastVIPR(Target) end
			end
		end
	end
end

--[[
		Combo that is executed when
		holding the Last Hit hotkey
--]]
function ComboFarm()
	local Menu1 = AutoCarry.PluginMenu.farm
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target then
		if qRDY and Menu1.useQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
				if Menu2.qoptions.Prediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.Prediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.Prediction == 3 then CastVIPQ(Target) end
			end
		end
		if wRDY and Menu1.useW and GetDistance(Target) <= wRNG and not Menu2.woptions.Reset then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
				if Menu2.eoptions.Prediction == 1 then CastVPredW(Target) end
				if Menu2.eoptions.Prediction == 2 then CastProdW(Target) end
				if Menu2.eoptions.Prediction == 3 then CastVIPW(Target) end
			end
		end
		if rRDY and Menu1.useR and GetDistance(Target) <= rRNG then 
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
				if Menu2.roptions.Prediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.Prediction == 2 then CastProdR(Target) end
				if Menu2.roptions.Prediction == 3 then CastVIPR(Target) end
			end
		end
	end
end

--[[
		Combo that is executed when
		holding the Lane Clear hotkey
--]]
  --TODO Add spell casting order
function ComboLC()
	local Menu1 = AutoCarry.PluginMenu.laneclear
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target and ValidTarget(Target) then
		if qRDY and Menu1.useQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
			end
		end
		if wRDY and Menu1.useW and GetDistance(Target) <= wRNG and not Menu2.woptions.Reset then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
				if Menu2.eoptions.Prediction == 1 then CastVPredW(Target) end
				if Menu2.eoptions.Prediction == 2 then CastProdW(Target) end
				if Menu2.eoptions.Prediction == 3 then CastVIPW(Target) end
			end
		end
		if rRDY and Menu1.useR and GetDistance(Target) <= rRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
				if Menu2.roptions.RPrediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.RPrediction == 2 then CastProdR(Target) end
				if Menu2.roptions.RPrediction == 3 then CastVIPR(Target) end
			end
		end
	end
end

--TODO add hitboxes
function CastProdQ(unit)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		QPos = ProdictQ:GetPrediction(unit)
		if QPos ~= nil then
			if AutoCarry.PluginMenu.spelloptions.qoptions.Collision == 1 then
				local willCollide = ProdictQFastCol:GetMinionCollision(QPos, myHero)
				if not willCollide then
					if AutoCarry.PluginMenu.spelloptions.qoptions.Packet then
						Packet("S_CAST", {spellId = _Q, fromX =  QPos.x, fromY =  QPos.z, toX =  QPos.x, toY =  QPos.z}):send()
					else
						CastSpell(_Q, QPos.x, QPos.z) end
					end
			elseif AutoCarry.PluginMenu.spelloptions.qoptions.Collision == 2 then
				local willCollide = ProdictQCol:GetMinionCollision(QPos, myHero)
				if not willCollide then
					Packet("S_CAST", {spellId = _Q, fromX =  QPos.x, fromY =  QPos.z, toX =  QPos.x, toY =  QPos.z}):send()
				else
					CastSpell(_Q, Qpos.x, QPos.z)
				end
			end
		end
	end
end

--TODO add hitboxes
function CastVPredQ(unit)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, qDLY, qWTH, qRNG, qSPD, myHero, true)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.qoptions.HitChance and GetDistance(CastPosition) <= qRNG then
			if AutoCarry.PluginMenu.spelloptions.qoptions.Packet then
				Packet("S_CAST", {spellId = _Q, fromX =  CastPosition.x, fromY =  CastPosition.z, toX =  CastPosition.x, toY =  CastPosition.z}):send()
			else
				CastSpell(_Q, CastPosition.x, CastPosition.z)
			end
		end
	end
end

--TODO add hitboxes
function CastVIPQ(unit)
	VipPredTarget = qp:GetPrediction(Target)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) and VipPredTarget and GetDistance(unit) <= qRNG then
		local QColl = (Collision(qRNG, qSPD, qDLY, qWTH))
		local willCollide = QColl:GetMinionCollision(unit, myHero)
		if not willCollide and GetDistance(unit) <= qRNG then
			if AutoCarry.PluginMenu.spelloptions.qoptions.Packet then
				Packet("S_CAST", {spellId = _Q, fromX =  VipPredTarget.x, fromY =  VipPredTarget.z, toX =  VipPredTarget.x, toY =  VipPredTarget.z}):send()
			else
				CastSpell(_Q, VipPredTarget.x, VipPredTarget.z)
			end
		end
	end
end

function OnAttacked()
	if AutoCarry.PluginMenu.spelloptions.woptions.Reset then
		if Target and wRDY and ValidTarget(Target) and myHero.mana >= ManaCost(W) and myHero.mana >= myHero.maxMana * (AutoCarry.PluginMenu.spelloptions.woptions.MANA / 100) then
			if AutoCarry.PluginMenu.spelloptions.woptions.Prediction == 1 then CastVPredW(Target) end
			if AutoCarry.PluginMenu.spelloptions.woptions.Prediction == 2 then CastProdW(Target) end
			if AutoCarry.PluginMenu.spelloptions.woptions.Prediction == 3 then CastVIPW(Target) end
		end
	end
end

--TODO add hitboxes
function CastProdW(unit)
	if wRDY and ValidTarget(unit) and myHero.mana >= ManaCost(W) then
		WPos = ProdictW:GetPrediction(unit)
		if WPos ~= nil then
			if AutoCarry.PluginMenu.spelloptions.woptions.Packet then
				Packet("S_CAST", {spellId = _W, fromX =  WPos.x, fromY =  WPos.z, toX =  WPos.x, toY =  WPos.z}):send()
			else
				CastSpell(_W, WPos.x, WPos.z)
			end
		end
	end
end

--TODO add hitboxes
function CastVPredW(unit)
	if wRDY and ValidTarget(unit) and myHero.mana >= ManaCost(W) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, wDLY, wWTH, wRNG, wSPD, myHero, false)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.woptions.HitChance and GetDistance(unit) <= wRNG then
			if AutoCarry.PluginMenu.spelloptions.eoptions.Packet then
				Packet("S_CAST", {spellId = _W, fromX =  CastPosition.x, fromY =  CastPosition.z, toX =  CastPosition.x, toY =  CastPosition.z}):send()
			else
				CastSpell(_W, CastPosition.x, CastPosition.z)
			end
		end
	end
end

--TODO add hitboxes
function CastVIPW(unit)
	VipPredTarget = wp:GetPrediction(unit)
	if wRDY and ValidTarget(unit) and myHero.mana >= ManaCost(W) and VipPredTarget then
		if GetDistance(unit) <= wRNG then
			if AutoCarry.PluginMenu.spelloptions.woptions.Packet then
				Packet("S_CAST", {spellId = _W, fromX =  VipPredTarget.x, fromY =  VipPredTarget.z, toX =  VipPredTarget.x, toY =  VipPredTarget.z}):send()
			else
				CastSpell(_W, VipPredTarget.x, VipPredTarget.z)
			end
		end
	end
end

--TODO add hitboxes
function CastProdR(unit)
	if rRDY and ValidTarget(unit) and myHero.mana >= ManaCost(R) then
		RPos = ProdictR:GetPrediction(unit)
		if RPos ~= nil then
			if AutoCarry.PluginMenu.spelloptions.roptions.Packet then
				Packet("S_CAST", {spellId = _R, fromX =  RPos.x, fromY =  RPos.z, toX =  RPos.x, toY =  RPos.z}):send()
			else
				CastSpell(_R, RPos.x, RPos.z)
			end
		end
	end
end

--TODO add hitboxes
function CastVPredR(unit)
	if rRDY and ValidTarget(unit) and myHero.mana >= ManaCost(R) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, rDLY, rWTH, rRNG, rSPD, myHero, false)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.roptions.HitChance and GetDistance(CastPosition) <= rRNG then
			if AutoCarry.PluginMenu.spelloptions.roptions.Packet then
				Packet("S_CAST", {spellId = _R, fromX =  CastPosition.x, fromY =  CastPosition.z, toX =  CastPosition.x, toY =  CastPosition.z}):send()
			else
				CastSpell(_R, CastPosition.x, CastPosition.z)
			end
		end
	end
end

--TODO add hitboxes
function CastVIPR(unit)
	VipPredTarget = rp:GetPrediction(unit)
	if rRDY and ValidTarget(unit) and myHero.mana >= ManaCost(R) and VipPredTarget then
		if GetDistance(unit) <= rRNG then
			if GetDistance(unit) <= rRNG then
				if AutoCarry.PluginMenu.spelloptions.roptions.Packet then
					Packet("S_CAST", {spellId = _R, fromX =  VipPredTarget.x, fromY =  VipPredTarget.z, toX =  VipPredTarget.x, toY =  VipPredTarget.z}):send()
				else
					CastSpell(_R, VipPredTarget.x, VipPredTarget.z)
				end
			end
		end
	end
end

--[[
		Returns mana cost
		of spells
--]]
function ManaCost(spell)
	if spell == Q then
		return 25 + (3 * myHero:GetSpellData(_Q).level)
	elseif spell == E then
		return 40 + (10 * myHero:GetSpellData(_W).level)
	elseif spell == R then
		return 100
	end
end
