--[[
	Name: Thresh - Nobody Escapes
	Author: Pain
	Version: 0.009
	Credits: Lab Rats; AWA, Degrec and Silent Man. Code; QQQ, Hellsing and Honda7.
	Features;
		Spacebar:
			Predict Q
			Predict W
			Predict E
			Predict R
		A:
			Predict W
		T:
			Reverse Flay Cast
		Z:
			Predict Q
			Predict W		
		
		Advanced:
		Custom Hit Chances
		Custom Ability Casting
		Custom Shield Casting		
		Custom Ultimate Casting
		Auto Flay Gap Closers
--]]
local version = 0.009
local autoUpdate = true
local SilentPrint = false --[[Change to true if you wish the script to not print anything in chat. Does not work for Libs or Errors]]

if not VIP_USER or myHero.charName ~= "Thresh" then return end
--[[Credits to Hellsing, QQQ and Honda7]]
local host = "bitbucket.org"
local path = "/BoLPain/bol-studio/raw/master/Scripts/Thresh.lua".."?rand="..math.random(1,10000)
local url  = "https://"..host..path
local printMessage = function(message) if not SilentPrint then print("<font color=\"#6699ff\"><b>Thresh:</b></font> <font color=\"#FFFFFF\">" .. message .. "</font>") end end
local webResult = GetWebResult(host, path)
if autoUpdate then
	if webResult then
		local serverVersion = string.match(webResult, "%s*local%s+version%s+=%s+.*%d+%.%d+")
		if serverVersion then
			serverVersion = tonumber(string.match(serverVersion, "%d+%.?%d*"))
			if version < serverVersion then
				printMessage("New version available: v" .. serverVersion)
				printMessage("Updating, please don't press F9")
				DelayAction(function () DownloadFile(url, SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, function () printMessage("Successfully updated, please reload!") end) end, 2)
			else
				printMessage("You've got the latest version: v" .. serverVersion)
			end
		else
			printMessage("Something went wrong! Please manually update the script!")
		end
	else
		printMessage("Error downloading version info!")
	end
else
	printMessage("Auto Updater has been disabled, please enable it to automatically keep up to date!")
end
local REQUIRED_LIBS = {
	["VPrediction"] = "https://raw.githubusercontent.com/honda7/BoL/master/Common/VPrediction.lua",
	["SOW"] = "https://raw.githubusercontent.com/honda7/BoL/master/Common/SOW.lua"
}               
local DOWNLOADING_LIBS = false
local DOWNLOAD_COUNT = 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""
function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		printMessage("Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end 
for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		printMessage("Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end 
if DOWNLOADING_LIBS then return end
--[[End of Credits]]
local Thresh = {
	Q = {range = 1075, speed = 1200, delay = 0.5, width = 95, collision = true, hitchance = 2},
	W = {range = 950, speed = math.huge, delay = 0.5, width = 200, collision = false, hitchance = 2},
	E = {range = 500, speed = math.huge, delay = 0.3, width = 60, collision = false, hitchance = 1},
	R = {range = 420, speed = math.huge, delay = 0.5, width = 50, collision = false, hitchance = 2}
}
function OnLoad()
	QCast = false
	VP = VPrediction(true) --[[Loads VPrediction]]
	Menu = scriptConfig("Thresh","Thresh") --[[Starts the Shift Menu]]
	Menu:addParam("Author","Author: Pain",5,"")
	Menu:addParam("Version","Version: "..version,5,"")
	Menu.Thread = false
	Menu:addSubMenu("Thresh: Key Bindings","General")
		Menu.General:addParam("Combo","Combo",2,false,32)
		Menu.General:addParam("HookAndPull","Hook and Lantern",2,false,string.byte("Z"))
		Menu.General:addParam("ReverseFlay", "Reverse Flay",2,false,string.byte("T"))
		Menu.General:addParam("Info","The option below ignores Q check",5,"")
		Menu.General:addParam("Lantern","Cast Lantern at Ally",2,false,string.byte("A"))
	Menu:addSubMenu("Thresh: Combo","Combo")
		Menu.Combo:addParam("Q","Use Q in 'Combo'",1,true)
		Menu.Combo:addParam("W","Use W in 'Combo'",1,true)
		Menu.Combo:addParam("E","Use E in 'Combo'",1,true)
		Menu.Combo:addParam("R","Use R in 'Combo'",1,true)
	Menu:addSubMenu("Thresh: Hit Chances","HC")
		Menu.HC:addParam("Q","Cast Q if:",7,Thresh.Q["hitchance"], { "Low Hit Chance", "High Hit Chance", "Target Slow/Close", "Target Immobilised", "Target Dashing/Blinking"})
		Menu.HC:addParam("E","Cast E if:",7,Thresh.E["hitchance"], { "Low Hit Chance", "High Hit Chance", "Target Slow/Close", "Target Immobilised"})
		Menu.HC:addParam("R","Cast R if:",7,Thresh.R["hitchance"], { "Low Hit Chance", "High Hit Chance", "Target Slow/Close", "Target Immobilised", "Target Dashing/Blinking"})
	Menu:addSubMenu("Thresh: Lantern Options","Lantern")
		Menu.Lantern:addParam("Save","Only Lantern if Q hooked",1,true)
		Menu.Lantern:addParam("Ally","Ally to Shield",7,2, { "Lowest Ally", "Closest Ally", "Furthest Ally" })
		Menu.Lantern:addParam("Info","Using Closest Ally will Shield yourself unless the option below is true",5,"")
		Menu.Lantern:addParam("IgnoreMe","Ignore My Hero when Shielding",1,true)
	Menu:addSubMenu("Thresh: Extra","Extra")
		Menu.Extra:addParam("Tower","Don't Dive Towers with Q",1,true)
		Menu.Extra:addParam("E","Flay Option",7,1, { "Pull", "Push"})
		Menu.Extra:addParam("PushAwayGapclosers","Flay away Gap Closer Spells",1,true)		
		Menu.Extra:addParam("RCount","Enemies in range to use R",7,2, { "One Enemy", "Two Enemies", "Three Enemies", "Four Enemies", "Five Enemies"})
	Menu:addSubMenu("Thresh: Drawing","Draw")
		Menu.Draw:addParam("Q","Draw Q range",1,true)
		Menu.Draw:addParam("W","Draw W range",1,true)
		Menu.Draw:addParam("E","Draw E range",1,true)
		Menu.Draw:addParam("R","Draw R range",1,true)
		Menu.Draw:addParam("Combo","Show 'Combo'",1,true)
		Menu.Draw:addParam("HookAndPull","Show 'Hook and Lantern'",1,true)
		Menu.Draw:addParam("Lantern","Show 'Lantern'",1,true)
		Menu.Draw:addParam("Flay","Show 'Flay Options'",1,true)
		Menu.Draw:addParam("ReverseFlay","Show 'Reverse Flay'",1,true)
	if Menu.Draw.Combo then
		Menu.General:permaShow("Combo")
	end
	if Menu.Draw.HookAndPull then
		Menu.General:permaShow("HookAndPull")
	end		
	if Menu.Draw.Lantern then
		Menu.General:permaShow("Lantern")
	end
	if Menu.Draw.ReverseFlay then
		Menu.General:permaShow("ReverseFlay")
	end
	if Menu.Draw.Flay then
		Menu.Extra:permaShow("E")
	end		
	ts = TargetSelector(8,1100,1,false) --[[AllClass target selector]]
	ts.name = "Thresh Target"
	Menu:addTS(ts)
	printMessage("Script Loaded")
	if not _G.SOWLoaded then
		SOWi = SOW(VP)
		SMenu = scriptConfig("Simple Orbwalker", "Simple Orbwalker")
		SMenu:addSubMenu("Drawing", "Drawing")
		SMenu.Drawing:addParam("Range", "Draw auto-attack range", SCRIPT_PARAM_ONOFF, true)
		SOWi:LoadToMenu(SMenu)
		SOWi:RegisterAfterAttackCallback(AfterAttack)
	end
	MenuLoad = true
end
function OnTick()
	if MenuLoad ~= true then return end
	ts:update()
	Target = ts.target
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	if Menu.General.Lantern then
		CastLantern()
	end
	if Target then
		if Menu.General.ReverseFlay then
			local CastPosition, HitChance, nTargets = VP:GetLineAOECastPosition(Target,Thresh.E["delay"],Thresh.E["width"],Thresh.E["range"],Thresh.E["speed"],myHero,Thresh.E["collision"])
			if HitChance <= 4 and HitChance >= Menu.HC.E then
				if Menu.Extra.E == 2 then				
					local CastPosition = Vector(myHero.x + (myHero.x - CastPosition.x),myHero.y,myHero.z + (myHero.z - CastPosition.z))
					if GetDistance(myHero,CastPosition) <= Thresh.E["range"] and HitChance >= Menu.HC.E then
						CastSpell(_E,CastPosition.x,CastPosition.z)
					end
				elseif Menu.Extra.E == 1 then
					if GetDistance(myHero,CastPosition) <= Thresh.E["range"] and HitChance >= Menu.HC.E then
						CastSpell(_E,CastPosition.x,CastPosition.z)
					end
				end
			end
		elseif Menu.General.Combo then
			if Menu.Combo.Q and QREADY and not QCast then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target,Thresh.Q["delay"],Thresh.Q["width"],Thresh.Q["range"],Thresh.Q["speed"],myHero,Thresh.Q["collision"])
				if GetDistance(myHero,CastPosition) <= Thresh.Q["range"] and HitChance >= Menu.HC.Q and HitChance ~= -1 then
					CastSpell(_Q,CastPosition.x,CastPosition.z)
				end
			end
			if Menu.Combo.W and not Menu.Lantern.Save and WREADY then
					CastLantern()
			end
			if Menu.Combo.E and EREADY and not QCast then
				DelayAction(function()
					if EREADY and Menu.General.Combo and Target and not QCast then --[[Stops ECasting when hooking]]
						local CastPosition, HitChance, nTargets = VP:GetLineAOECastPosition(Target,Thresh.E["delay"],Thresh.E["width"],Thresh.E["range"],Thresh.E["speed"],myHero,Thresh.E["collision"])
						if HitChance >= Menu.HC.E or HitChance == 0 then
							if Menu.Extra.E == 1 then					
								local CastPosition = Vector(myHero.x + (myHero.x - CastPosition.x),myHero.y,myHero.z + (myHero.z - CastPosition.z))
								if GetDistance(myHero,CastPosition) <= Thresh.E["range"] then
									CastSpell(_E,CastPosition.x,CastPosition.z)
								end
							elseif Menu.Extra.E == 2 then
								if GetDistance(myHero,CastPosition) <= Thresh.E["range"] then
									CastSpell(_E,CastPosition.x,CastPosition.z)
								end
							end
						end
					end
				end, 1+(GetDistance(myHero,Target)/2000))
			end
			if Menu.Combo.R and RREADY and Menu.Extra.RCount <= CountEnemyHeroInRange(Thresh.R["range"]) then
				local CastPosition, HitChance = VP:GetPredictedPos(Target,Thresh.R["delay"],Thresh.R["speed"],myHero,Thresh.R["collision"])
				if GetDistance(myHero,CastPosition) <= Thresh.R["range"] + 75 and GetDistance(myHero,CastPosition) <= Thresh.R["range"] - 75 and HitChance >= Menu.HC.R then
					CastSpell(_R)
				end
			end
		elseif Menu.General.HookAndPull then
			if not QCast then
				local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target,Thresh.Q["delay"],Thresh.Q["width"],Thresh.Q["range"],Thresh.Q["speed"],myHero,Thresh.Q["collision"])
				if GetDistance(myHero,CastPosition) <= Thresh.Q["range"] and HitChance >= Menu.HC.Q and HitChance == 0 then
					CastSpell(_Q,CastPosition.x,CastPosition.z)
				end
			end
		end
		if Menu.Extra.PushAwayGapclosers and not QCast then
			for a = 1, heroManager.iCount do
				local FlayTarget = heroManager:GetHero(a)
				if ValidTarget(FlayTarget) then
					local CastPosition, HitChance, Position = VP:GetLineCastPosition(FlayTarget,Thresh.E["delay"],Thresh.E["width"],Thresh.E["range"],Thresh.E["speed"],myHero,Thresh.E["collision"])
					if GetDistance(myHero,CastPosition) <= Thresh.E["range"] and HitChance == 5 then
						CastSpell(_E,CastPosition.x,CastPosition.z)
					end
				end
			end
		end
	end
end
function OnDraw()
	if SOWi and SMenu.Drawing.Range then
        SOWi:DrawAARange()
    end
	if Menu.Draw.Q and QREADY then DrawCircle(myHero.x,myHero.y,myHero.z,Thresh.Q["range"],0x00FFFF) end
	if Menu.Draw.W and WREADY then DrawCircle(myHero.x,myHero.y,myHero.z,Thresh.W["range"],0x00FFFF) end
	if Menu.Draw.E and EREADY then DrawCircle(myHero.x,myHero.y,myHero.z,Thresh.E["range"],0x00FFFF) end
	if Menu.Draw.R and RREADY then DrawCircle(myHero.x,myHero.y,myHero.z,Thresh.R["range"],0x00FFFF) end
end
function OnGainBuff(unit, buff)
	if unit == Target and buff.name == "threshqfakeknockup" then
		QCast = true
		DelayAction(function() QCast = false end, 1.5)
		if Menu.General.Combo or Menu.General.HookAndPull then			
			DelayAction(function()
				if GetGame().map.index == 1 and TargetUnderTower(Target) and Menu.Extra.Tower then return end
				if Menu.Combo.W or Menu.General.HookAndPull then CastLantern() end
				CastSpell(_Q)
			end, (GetDistance(myHero,Target)/2000))
		end
	end
end
function TargetUnderTower(unit)
	for k = 1, objManager.maxObjects do
		local obj = objManager:GetObject(k)
		if obj ~= nil then
			if obj.name:find("Turret_T2") and obj.name:find("_A") and obj.team ~= myHero.team and GetDistance(unit,obj) <= 825 then
				return true
			end
		end
	end
	return false
end
function CastLantern()
	if not WREADY then return end
	if PickAlly() == nil then return end
	local CastPosition, HitChance, nTargets = VP:GetCircularAOECastPosition(PickAlly(),Thresh.W["delay"],Thresh.W["width"],Thresh.W["range"],Thresh.W["speed"],myHero,Thresh.W["collision"])
	CastSpell(_W,CastPosition.x,CastPosition.z)
end
function PickAlly()
	if Menu.Lantern.Ally == 1 then
		return GetLowestAlly(Thresh.W["range"])
	elseif Menu.Lantern.Ally == 2 then
		return GetClosestAlly(Thresh.W["range"])
	elseif Menu.Lantern.Ally == 3 then
		return GetFurthestAlly(Thresh.W["range"])
	end
	return nil
end
function GetLowestAlly(range) --[[Returns the lowest ally in range]]
	assert(range, "GetLowestAlly: Range returned nil. Cannot check valid ally in nil range")
	LowestAlly = nil
	for a = 1, heroManager.iCount do
		Ally = heroManager:GetHero(a)
		if (Ally ~= myHero and Menu.Lantern.IgnoreMe) or (not Menu.Lantern.IgnoreMe) then
			if Ally.team == myHero.team and not Ally.dead and GetDistance(myHero,Ally) <= range then
				if LowestAlly == nil then
					LowestAlly = Ally
				elseif not LowestAlly.dead and (Ally.health/Ally.maxHealth) < (LowestAlly.health/LowestAlly.maxHealth) then
					LowestAlly = Ally
				end
			end
		end
	end
	return LowestAlly
end
function GetClosestAlly(range) --[[Returns the closest ally]]
	assert(range, "GetClosestAlly: Range returned nil. Cannot check valid ally in nil range")
	ClosestAlly = nil
	for a = 1, heroManager.iCount do
		Ally = heroManager:GetHero(a)
		if (Ally ~= myHero and Menu.Lantern.IgnoreMe) or (not Menu.Lantern.IgnoreMe) then
			if Ally.team == myHero.team and not Ally.dead and GetDistance(myHero,Ally) <= range then
				if ClosestAlly == nil then
					ClosestAlly = Ally
				elseif not ClosestAlly.dead and (GetDistance(myHero,Ally) < GetDistance(myHero,ClosestAlly)) then
					ClosestAlly = Ally
				end
			end
		end
	end
	return ClosestAlly
end
function GetFurthestAlly(range) --[[Returns the furthest ally]]
	assert(range, "GetFurthestAlly: Range returned nil. Cannot check valid ally in nil range")
	FurthestAlly = nil
	for a = 1, heroManager.iCount do
		Ally = heroManager:GetHero(a)
		if (Ally ~= myHero and Menu.Lantern.IgnoreMe) or (not Menu.Lantern.IgnoreMe) then
			if Ally.team == myHero.team and not Ally.dead and GetDistance(myHero,Ally) <= range then
				if FurthestAlly == nil then
					FurthestAlly = Ally
				elseif not FurthestAlly.dead and (GetDistance(myHero,Ally) > GetDistance(myHero,FurthestAlly)) then
					FurthestAlly = Ally
				end
			end
		end
	end
	return FurthestAlly
end
function CountEnemyHeroInRange(range)
	local enemyInRange = 0
	for i = 1, heroManager.iCount, 1 do
		local enemyheros = heroManager:getHero(i)
		if enemyheros.valid and enemyheros.visible and enemyheros.dead == false and enemyheros.team ~= myHero.team and GetDistance(enemyheros) <= range then
			enemyInRange = enemyInRange + 1
		end
	end
	return enemyInRange
end
