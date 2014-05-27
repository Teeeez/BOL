--[[

8888888b.                         888 888                .d8888b.  888              d8b  .d8888b.           888    888      
888  "Y88b                        888 888               d88P  Y88b 888              88P d88P  Y88b          888    888      
888    888                        888 888               888    888 888              8P  888    888          888    888      
888    888  .d88b.   8888b.   .d88888 888 888  888      888        88888b.   .d88b. "   888         8888b.  888888 88888b.  
888    888 d8P  Y8b     "88b d88" 888 888 888  888      888        888 "88b d88""88b    888  88888     "88b 888    888 "88b 
888    888 88888888 .d888888 888  888 888 888  888      888    888 888  888 888  888    888    888 .d888888 888    888  888 
888  .d88P Y8b.     888  888 Y88b 888 888 Y88b 888      Y88b  d88P 888  888 Y88..88P    Y88b  d88P 888  888 Y88b.  888  888 
8888888P"   "Y8888  "Y888888  "Y88888 888  "Y88888       "Y8888P"  888  888  "Y88P"      "Y8888P88 "Y888888  "Y888 888  888 
                                               888                                                                          
                                          Y8b d88P                                                                          
                                           "Y88P"                                                                           
888                     .d8888b.   .d8888b.   .d88888b.  888b    888 888b    888                                            
888                    d88P  Y88b d88P  Y88b d88P" "Y88b 8888b   888 8888b   888                                            
888                    888    888 888    888 888     888 88888b  888 88888b  888                                            
88888b.  888  888      888        888        888     888 888Y88b 888 888Y88b 888                                            
888 "88b 888  888      888        888        888     888 888 Y88b888 888 Y88b888                                            
888  888 888  888      888    888 888    888 888     888 888  Y88888 888  Y88888                                            
888 d88P Y88b 888      Y88b  d88P Y88b  d88P Y88b. .d88P 888   Y8888 888   Y8888                                            
88888P"   "Y88888       "Y8888P"   "Y8888P"   "Y88888P"  888    Y888 888    Y888                                            
              888                                                                                                           
         Y8b d88P                                                                                                           
          "Y88P"                                                                                                            


VERSION 	1.02
UPDATED:	05/19/2014
BY:			CCONN

CHANGELOG:	VERSION 1.00		
				Initial Release
			VERSION 1.01
				Adjusted Rupture (Q) delay
			VERSION 1.02
				Combo changed to W first
				Feast stack count added
				
PLANNED FEATURES:
	Lane Clear with spells
	Execute jungle monsters with Feast
	Baron / Dragon steal with Feast and Smite + Feast
	Feast when low HP
	Killsteal functions
]]

if myHero.charName ~= "Chogath" then return end

require "Prodiction"
require "AoE_Skillshot_Position"


local qRange = 950
local wRange = 675
local rRange = 150
local QRDY
local WRDY
local ERDY
local RRDY
local Prodict = ProdictManager.GetInstance()
local ProdictQ
local ProdictW
local Target
local Minion

local target = nil
local rcount = 0

function PluginOnLoad()
	Menu()
	Checks()
	AutoCarry.SkillsCrosshair.range = 950 --max range of Rupture (Q)
	ProdictQ = Prodict:AddProdictionObject(_Q, qRange, math.huge, 1.225, 170)  --math.huge, .290, 170) --.915, 190
end

function Menu()
	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Auto Carry", "autocarry")
	AutoCarry.PluginMenu.autocarry:addParam("ACuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseR", "Execute with Feast", SCRIPT_PARAM_ONOFF, true)

	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Mixed Mode", "mixedmode")
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseR", "Execute with Feast", SCRIPT_PARAM_ONOFF, true)

	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Draw", "draw")
	AutoCarry.PluginMenu.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("KillSteal", "Kill Steal with R", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("T"))
AutoCarry.PluginMenu:addParam("FeastMinion", "Auto R to 6 stacks", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("S"))
end


function PluginOnDraw()
	if QRDY and AutoCarry.PluginMenu.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, 950, 0xFFFFFF)
	end
	if WRDY and AutoCarry.PluginMenu.draw.DrawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, 675, 0xFFFFFF)
	end
	if RRDY and AutoCarry.PluginMenu.draw.DrawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 150, 0xFFFFFF)
	end
		if AutoCarry.PluginMenu.draw.DrawXP then
	DrawCircle(myHero.x, myHero.y, myHero.z, 1600, 0xFFFFFF)
	end
end

function PluginOnTick()
	Checks()
	if Target and AutoCarry.MainMenu.AutoCarry then ComboAC() end
	if Target and AutoCarry.MainMenu.MixedMode then ComboMM() end
	if AutoCarry.PluginMenu.KillSteal then ultSteal() end
	if AutoCarry.PluginMenu.FeastMinion and not AutoCarry.MainMenu.AutoCarry then minionFeast() end
end

function ultSteal()
	for i = 1, heroManager.iCount do
	local enemy = heroManager:getHero(i)
		if RRDY and ValidTarget(enemy, 150, true) and enemy.health < getDmg("R",enemy,myHero) then
			CastSpell(_R, enemy)
		end
	end
end
--[[
function minionFeast()
	if myHero:CanUseSpell(_R) == READY and rcount < 6 then 
		for i=1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
			if object ~= nil and object.type == "obj_AI_Minion" and object.team~=myHero.team and object.health <= getDmg("R", object, myHero) and object.visible and not object.dead and GetDistance(myHero, object) <= 200 then
				target = object
				CastSpell(_R, object)
			end
		end
	end
end
]]

function minionFeast()
	if RRDY and rcount < 6 then 
		for i=1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
			if object ~= nil and object.type == "obj_AI_Minion" and object.team~=myHero.team and object.health <= getDmg("R", object, myHero) and object.visible and not object.dead and GetDistance(myHero, object) <= 200 then
				CastSpell(_R, object)
			end
		end
	end
end


function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == 'Feast' then
		rcount = 1
	end
end

function OnUpdateBuff(unit, buff)
	if unit.isMe and buff.name == 'Feast' then
		rcount = buff.stack

	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == 'Feast' then
		rcount = 0
	end
end

--[[
function OnUpdateBuff(unit, buff)
	if unit.isMe and buff.name=="Feast" then
		rcount = buff.stack
	end
end
]]

function ComboAC()
	if Target then
		if WRDY and AutoCarry.PluginMenu.autocarry.ACuseW and GetDistance(Target) <= wRange then W() end
		if QRDY and AutoCarry.PluginMenu.autocarry.ACuseQ and GetDistance(Target) <= qRange then Q() end
		if RRDY and AutoCarry.PluginMenu.autocarry.ACuseR and GetDistance(Target) <= rRange then R() end
	end
end

function ComboMM()
	if Target then
		if WRDY and AutoCarry.PluginMenu.mixedmode.MMuseW and GetDistance(Target) <= wRange then W() end
		if QRDY and AutoCarry.PluginMenu.mixedmode.MMuseQ and GetDistance(Target) <= qRange then Q() end
		if RRDY and AutoCarry.PluginMenu.mixedmode.MMuseR and GetDistance(Target) <= rRange then R() end
	end
end

function Q()
if QRDY then ProdictQ:GetPredictionCallBack(Target, CastQ) end
end

function W()
if WRDY then CastSpell(_W, Target.x, Target.z) end
end

function R()
	for i, enemy in ipairs(GetEnemyHeroes()) do
	local feastDmg = getDmg("R", enemy, myHero)
		if ValidTarget(enemy, feastDmg) and enemy.health < feastDmg and GetDistance(Target) <= rRange then
			CastSpell(_R, enemy)
		end
	end
end

function CastQ(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(Target)/2 < qRange then
		CastSpell(_Q, pos.x, pos.z)
	end
end


local function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)
end

function Checks()
	Target = AutoCarry.GetAttackTarget()
	Minion = AutoCarry.GetMinionTarget()
	QRDY = (myHero:CanUseSpell(_Q) == READY)
	WRDY = (myHero:CanUseSpell(_W) == READY)
	RRDY = (myHero:CanUseSpell(_R) == READY)
end
