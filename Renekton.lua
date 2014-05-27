local Version = "1.01"
local Author = "QQQ"
if myHero.charName ~= "Renekton" then return end
local IsLoaded = "Crocodile Dundee"
local AUTOUPDATE = true

---------------------------------------------------------------------
--- AutoUpdate for the script ---------------------------------------
---------------------------------------------------------------------
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_NAME = "Renekton - Crocodile Dundee"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/bolqqq/BoLScripts/master/Renekton%20-%20Crocodile%20Dundee.lua?chunk="..math.random(1, 1000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FFFF73\">["..IsLoaded.."]:</font> <font color=\"#FFDFBF\">"..msg..".</font>") end
if AUTOUPDATE then
    local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
    if ServerData then
        local ServerVersion = string.match(ServerData, "local Version = \"%d+.%d+\"")
        ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
        if ServerVersion then
            ServerVersion = tonumber(ServerVersion)
            if tonumber(Version) < ServerVersion then
                AutoupdaterMsg("A new version is available: ["..ServerVersion.."]")
                AutoupdaterMsg("The script is updating... please don't press [F9]!")
                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function ()
				AutoupdaterMsg("Successfully updated! ("..Version.." -> "..ServerVersion.."), Please reload (double [F9]) for the updated version!") end) end, 3)
            else
                AutoupdaterMsg("Your script is already the latest version: ["..ServerVersion.."]")
            end
        end
    else
        AutoupdaterMsg("Error downloading version info!")
    end
end
---------------------------------------------------------------------
--- AutoDownload the required libraries -----------------------------
---------------------------------------------------------------------
local REQUIRED_LIBS = 
  {
    ["VPrediction"] = "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua",
    ["SOW"] = "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua"
  }   		
local DOWNLOADING_LIBS = false
local DOWNLOAD_COUNT = 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#FFFF73\">["..IsLoaded.."]:</font><font color=\"#FFDFBF\"> Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1

		print("<font color=\"#FFFF73\">["..IsLoaded.."]:</font><font color=\"#FFDFBF\"> Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end
if DOWNLOADING_LIBS then return end
---------------------------------------------------------------------
--- Vars ------------------------------------------------------------
---------------------------------------------------------------------
-- Vars for Ranges --
	local qRange = 325
	local wRange = myHero.range + GetDistance(myHero.minBBox)
	local eRange = 450
	local rRange = 175
	local eWidth = 50
	local eSpeed = 1400
	local eDelay = 0.250
-- Vars for Abilitys --
	local qName = "Cull the Meek"
	local wName = "Ruthless Predator"
	local eName = "Slice & Dice"
	local rName = "Dominus"
	local qColor = ARGB(100,217,0,163)
	local wColor = ARGB(100,76,255,76)
	local eColor = ARGB(100,153,229,255)
	local rColor = ARGB(100,207,255,191)
	local TargetColor = ARGB(100,76,255,76)
	-- Vars for JungleClear --
	local JungleMobs = {}
	local JungleFocusMobs = {}
	-- Vars for LaneClear --
	local enemyMinions = minionManager(MINION_ENEMY, 500, myHero.visionPos, MINION_SORT_HEALTH_ASC)
-- Vars for TargetSelector --
	local ts
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1000, DAMAGE_PHYSICAL, true)
	ts.name = "Renekton: Target"
	local Target = nil
-- Vars for Autolevel --
	levelSequence = {
					startQ = { 1,3,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2 },
					startW = { 2,3,1,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2 },
					startE = { 3,1,2,1,1,4,1,3,1,3,4,3,3,2,2,4,2,2 }
					}
-- Vars for Damage Calculations and KilltextDrawing --
	local ignite = nil
	local iDmg = 0
	local qDmg = 0
	local wDmg = 0
	local eDmg = 0
	local dfgDmg = 0
	local hxgDmg = 0
	local bwcDmg = 0
	local botrkDmg = 0
	local sheenDmg = 0
	local lichbaneDmg = 0
	local trinityDmg = 0
	local liandrysDmg = 0
	local KillText = {}
	local KillTextColor = ARGB(250, 255, 38, 1)
	local KillTextList = {		
							"Harass your enemy!", 					-- 01
							"Wait for your CD's!",					-- 02
							"Kill! - Ignite",						-- 03
							"Kill! - (Q)",							-- 04 
							"Kill! - (W)",							-- 05
							"Kill! - (E)",							-- 06
							"Kill! - (Q)+(W)",						-- 07
							"Kill! - (Q)+(E)",						-- 08
							"Kill! - (W)+(E)",						-- 09
							"Kill! - (Q)+(W)+(E)"					-- 10
						}
-- Misc Vars --	
	local enemyHeroes = GetEnemyHeroes()
	local RenektonMenu
	local VP = nil
	local lastDash
---------------------------------------------------------------------
--- OnLoad ----------------------------------------------------------
---------------------------------------------------------------------
function OnLoad()
	IgniteCheck()
	JungleNames()
	VP = VPrediction()
	rSOW = SOW(VP)
	AddMenu()
	-- LFC --
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	PrintChat("<font color=\"#eFF99CC\">["..IsLoaded.."]:</font><font color=\"#FFDFBF\"> Sucessfully loaded! Version: [<u><b>"..Version.."</b></u>]</font>")
end
---------------------------------------------------------------------
--- Menu ------------------------------------------------------------
---------------------------------------------------------------------
function AddMenu()
	-- Script Menu --
	RenektonMenu = scriptConfig("Renekton - Crocodile Dundee", "Renekton")
	
	-- Target Selector --
	RenektonMenu:addTS(ts)
	
	-- Create SubMenu --
	RenektonMenu:addSubMenu(""..myHero.charName..": Key Bindings", "KeyBind")
	RenektonMenu:addSubMenu(""..myHero.charName..": Extra", "Extra")
	RenektonMenu:addSubMenu(""..myHero.charName..": Orbwalk", "Orbwalk")
	RenektonMenu:addSubMenu(""..myHero.charName..": Ultimate", "Ultimate")
	RenektonMenu:addSubMenu(""..myHero.charName..": SBTW-Combo", "SBTW")
	RenektonMenu:addSubMenu(""..myHero.charName..": Harass", "Harass")
	RenektonMenu:addSubMenu(""..myHero.charName..": KillSteal", "KS")
	RenektonMenu:addSubMenu(""..myHero.charName..": LaneClear", "Farm")
	RenektonMenu:addSubMenu(""..myHero.charName..": JungleClear", "Jungle")
	RenektonMenu:addSubMenu(""..myHero.charName..": Drawings", "Draw")
	
	-- KeyBindings --
	RenektonMenu.KeyBind:addParam("SBTWKey", "SBTW-Combo Key: ", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	RenektonMenu.KeyBind:addParam("UltimateKey", "Enable/Disable Auto-Ultimate: ", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("O"))
	RenektonMenu.KeyBind:addParam("HarassKey", "HarassKey: ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	RenektonMenu.KeyBind:addParam("HarassToggleKey", "Toggle Harass: ", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("U"))
	RenektonMenu.KeyBind:addParam("ClearKey", "Jungle- and LaneClear Key: ", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	
	-- Extra --
	RenektonMenu.Extra:addParam("aniCancelW", "Use Animationcanceling on (W) with Tiamat/Hydra: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Extra:addParam("aniCancelWSlider", "Delay for AnimationCanceling: ", SCRIPT_PARAM_SLICE, 0.3, 0, 1.5, 1)
	RenektonMenu.Extra:addParam("AutoLevelSkills", "Auto Level Skills (Reload Script!)", SCRIPT_PARAM_LIST, 1, { "No Autolevel", "QEWQ - R>Q>E>W", "WEQQ - R>Q>E>W", "EQWQ - R>Q>E>W"})
	
	-- SOW-Orbwalking --
	rSOW:LoadToMenu(RenektonMenu.Orbwalk)
	
	-- Ultimate --
	RenektonMenu.Ultimate:addParam("UltimateInfo", "--- Enable/disable Ultimate in KeyBindings ---", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Ultimate:addParam("useUltimateIfLow", "Use Ultimate if below %: ", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Ultimate:addParam("useUltimateIfLowSlider", "Health-%: ", SCRIPT_PARAM_SLICE, 20, 0, 100, -1)
	RenektonMenu.Ultimate:addParam("UltimateInfo", "-----------------------------------------------------", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Ultimate:addParam("useUltimateTowerDive", "Use Ultimate if below % under tower: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Ultimate:addParam("useUltimateTowerDiveSlider", "Health-%: ", SCRIPT_PARAM_SLICE, 40, 0, 100, -1)
	RenektonMenu.Ultimate:addParam("UltimateInfo", "-----------------------------------------------------", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Ultimate:addParam("useUltimateEnemy", "Use Ultimate if x-enemys in range and below %: ", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Ultimate:addParam("useUltimateEnemySliderNumber", "Number of enemys: ", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
	RenektonMenu.Ultimate:addParam("useUltimateEnemySliderHealth", "Health-%: ", SCRIPT_PARAM_SLICE, 60, 0, 100, -1)
	RenektonMenu.Ultimate:addParam("useUltimateEnemySliderRange", "Range for enemys: ", SCRIPT_PARAM_SLICE, 500, 0, 1000, 1)
	
	-- SBTW-Combo --
	RenektonMenu.SBTW:addParam("sbtwItems", "Use Items in Combo: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.SBTW:addParam("sbtwInfo", "", SCRIPT_PARAM_INFO, "")
	RenektonMenu.SBTW:addParam("sbtwInfo", "--- Choose your abilitys for SBTW ---", SCRIPT_PARAM_INFO, "")
	RenektonMenu.SBTW:addParam("sbtwQ", "Use "..qName.." (Q) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.SBTW:addParam("sbtwW", "Use "..wName.." (W) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.SBTW:addParam("sbtwE1", "Use Slice (E1) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.SBTW:addParam("sbtwE2", "Use Dice (E2) in Combo: ", SCRIPT_PARAM_ONOFF, true)
	
	-- Harass --
	RenektonMenu.Harass:addParam("harassMode", "Choose your HarassMode: ", SCRIPT_PARAM_LIST, 1, {"Q", "Q-W", "EQWE to enemyPos", "EQWE to startPos"})
	RenektonMenu.Harass:addParam("harassInfo", "", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Harass:addParam("harassInfo", "--- Choose your abilitys for Harass ---", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Harass:addParam("harassQ","Use "..qName.." (Q) in Harass:", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Harass:addParam("harassW","Use "..wName.." (W) in Harass:", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Harass:addParam("harassE1","Use Slice (E1) in Harass:", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Harass:addParam("harassE2","Use Dice (E2) in Harass:", SCRIPT_PARAM_ONOFF, true)
	
	-- KillSteal --
	RenektonMenu.KS:addParam("Ignite", "Use Auto Ignite: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.KS:addParam("smartKS", "Enable smart KS: ", SCRIPT_PARAM_ONOFF, true)
	
	-- Lane Clear --
	RenektonMenu.Farm:addParam("farmInfo", "--- Choose your abilitys for LaneClear ---", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Farm:addParam("farmQ", "Farm with "..qName.." (Q): ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Farm:addParam("farmW", "Farm with "..wName.." (W): ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Farm:addParam("farmE1", "Farm with Slice (E1): ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Farm:addParam("farmE2", "Farm with Dice (E2): ", SCRIPT_PARAM_ONOFF, true)
	-- Jungle Clear --
	RenektonMenu.Jungle:addParam("jungleInfo", "--- Choose your abilitys for JungleClear ---", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Jungle:addParam("jungleQ", "Clear with "..qName.." (Q):", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Jungle:addParam("jungleW", "Clear with "..wName.." (W):", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Jungle:addParam("jungleE1", "Clear with Slice (E1):", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Jungle:addParam("jungleE2", "Clear with Dice (E2):", SCRIPT_PARAM_ONOFF, true)
	-- Drawings --
	RenektonMenu.Draw:addParam("drawQ", "Draw (Q) Range:", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Draw:addParam("drawW", "Draw (W) Range:", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Draw:addParam("drawE", "Draw (E) Range:", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Draw:addParam("drawEmax", "Draw (E) max Range:", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Draw:addParam("drawR", "Draw (R) Range:", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Draw:addParam("drawKillText", "Draw killtext on enemy: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Draw:addParam("drawTarget", "Draw current target: ", SCRIPT_PARAM_ONOFF, false)
		-- LFC --
	RenektonMenu.Draw:addSubMenu("LagFreeCircles: ", "LFC")
	RenektonMenu.Draw.LFC:addParam("LagFree", "Activate Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
	RenektonMenu.Draw.LFC:addParam("CL", "Length before Snapping", SCRIPT_PARAM_SLICE, 350, 75, 2000, 0)
	RenektonMenu.Draw.LFC:addParam("CLinfo", "Higher length = Lower FPS Drops", SCRIPT_PARAM_INFO, "")
		-- Permashow --
	RenektonMenu.Draw:addSubMenu("PermaShow: ", "PermaShow")
	RenektonMenu.Draw.PermaShow:addParam("info", "--- Reload (Double F9) if you change the settings ---", SCRIPT_PARAM_INFO, "")
	RenektonMenu.Draw.PermaShow:addParam("UltimateKey", "Show Auto-Ultimate: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Draw.PermaShow:addParam("HarassMode", "Show HarassMode: ", SCRIPT_PARAM_ONOFF, true)
	RenektonMenu.Draw.PermaShow:addParam("HarassToggleKey", "Show HarassToggleKey: ", SCRIPT_PARAM_ONOFF, true)
	
	-- Other --
	RenektonMenu:addParam("Version", "Version", SCRIPT_PARAM_INFO, Version)
	RenektonMenu:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
	
	-- PermaShow --
	if RenektonMenu.Draw.PermaShow.UltimateKey
		then RenektonMenu.KeyBind:permaShow("UltimateKey") 
	end
	if RenektonMenu.Draw.PermaShow.HarassMode
		then RenektonMenu.Harass:permaShow("harassMode") 
	end
	if RenektonMenu.Draw.PermaShow.HarassToggleKey
		then RenektonMenu.KeyBind:permaShow("HarassToggleKey") 
	end
	
end
---------------------------------------------------------------------
--- On Tick ---------------------------------------------------------
---------------------------------------------------------------------
function OnTick()
	if myHero.dead then return end
	ts:update()
	Target = ts.target 
	Check()
	LFCfunc()
	AutoLevelMySkills()
	KeyBindings()
	DamageCalculation()
	if Target
		then
			if RenektonMenu.KS.Ignite then AutoIgnite(Target) end
	end

	if UltimateKey then RenektonsUltimate() end
	if SBTWKey then SBTW() end
	if HarassKey then Harass() end
	if HarassToggleKey then Harass() end
	if ClearKey then LaneClear() JungleClear() end
	if RenektonMenu.KS.smartKS then smartKS() end
end
---------------------------------------------------------------------
--- Function KeyBindings for easier KeyManagement -------------------
---------------------------------------------------------------------
function KeyBindings()
	UltimateKey = RenektonMenu.KeyBind.UltimateKey
	SBTWKey = RenektonMenu.KeyBind.SBTWKey
	HarassKey = RenektonMenu.KeyBind.HarassKey
	HarassToggleKey = RenektonMenu.KeyBind.HarassToggleKey
	ClearKey = RenektonMenu.KeyBind.ClearKey
end
---------------------------------------------------------------------
--- Function Checks for Spells and Forms ----------------------------
---------------------------------------------------------------------
function Check()
	-- Cooldownchecks for Abilitys and Summoners -- 
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	E1READY = (myHero:CanUseSpell(_E) == READY) and myHero:GetSpellData(_E).name == "RenektonSliceAndDice"
	E2READY = (myHero:CanUseSpell(_E) == READY) and myHero:GetSpellData(_E).name == "renektondice"
	
	-- Check if items are ready -- 
		dfgReady		= (dfgSlot		~= nil and myHero:CanUseSpell(dfgSlot)		== READY) -- Deathfire Grasp
		hxgReady		= (hxgSlot		~= nil and myHero:CanUseSpell(hxgSlot)		== READY) -- Hextech Gunblade
		bwcReady		= (bwcSlot		~= nil and myHero:CanUseSpell(bwcSlot)		== READY) -- Bilgewater Cutlass
		botrkReady		= (botrkSlot	~= nil and myHero:CanUseSpell(botrkSlot)	== READY) -- Blade of the Ruined King
		sheenReady		= (sheenSlot 	~= nil and myHero:CanUseSpell(sheenSlot) 	== READY) -- Sheen
		lichbaneReady	= (lichbaneSlot ~= nil and myHero:CanUseSpell(lichbaneSlot) == READY) -- Lichbane
		trinityReady	= (trinitySlot 	~= nil and myHero:CanUseSpell(trinitySlot) 	== READY) -- Trinity Force
		lyandrisReady	= (liandrysSlot	~= nil and myHero:CanUseSpell(liandrysSlot) == READY) -- Liandrys 
		tmtReady		= (tmtSlot 		~= nil and myHero:CanUseSpell(tmtSlot)		== READY) -- Tiamat
		hdrReady		= (hdrSlot		~= nil and myHero:CanUseSpell(hdrSlot) 		== READY) -- Hydra
		youReady		= (youSlot		~= nil and myHero:CanUseSpell(youSlot)		== READY) -- Youmuus Ghostblade
	
	-- Set the slots for item --
		dfgSlot 		= GetInventorySlotItem(3128)
		hxgSlot 		= GetInventorySlotItem(3146)
		bwcSlot 		= GetInventorySlotItem(3144)
		botrkSlot		= GetInventorySlotItem(3153)							
		sheenSlot		= GetInventorySlotItem(3057)
		lichbaneSlot	= GetInventorySlotItem(3100)
		trinitySlot		= GetInventorySlotItem(3078)
		liandrysSlot	= GetInventorySlotItem(3151)
		tmtSlot			= GetInventorySlotItem(3077)
		hdrSlot			= GetInventorySlotItem(3074)	
		youSlot			= GetInventorySlotItem(3142)
end
---------------------------------------------------------------------
--- ItemUsage -------------------------------------------------------
---------------------------------------------------------------------
function UseItems()
	if not enemy then enemy = Target end
	if ValidTarget(enemy) then
		if dfgReady		and GetDistance(enemy) <= 750 then CastSpell(dfgSlot, enemy) end
		if hxgReady		and GetDistance(enemy) <= 700 then CastSpell(hxgSlot, enemy) end
		if bwcReady		and GetDistance(enemy) <= 450 then CastSpell(bwcSlot, enemy) end
		if botrkReady	and GetDistance(enemy) <= 450 then CastSpell(botrkSlot, enemy) end
		if youReady		and GetDistance(enemy) <= 185 then CastSpell(youSlot) end
	end
end
---------------------------------------------------------------------
--- Draw Function ---------------------------------------------------
---------------------------------------------------------------------	
function OnDraw()
	if myHero.dead then return end 
-- Draw SpellRanges only when our champ is alive and the spell is ready --
	-- Draw Q + W + E + Emax + R --
		if QREADY and RenektonMenu.Draw.drawQ then DrawCircle(myHero.x, myHero.y, myHero.z, qRange, qColor) end
		if WREADY and RenektonMenu.Draw.drawW then DrawCircle(myHero.x, myHero.y, myHero.z, wRange, wColor) end
		if EREADY and RenektonMenu.Draw.drawE then DrawCircle(myHero.x, myHero.y, myHero.z, eRange, eColor) end
		if EREADY and RenektonMenu.Draw.drawEmax then DrawCircle(myHero.x, myHero.y, myHero.z, eRange*2, eColor) end
		if RREADY and RenektonMenu.Draw.drawR then DrawCircle(myHero.x, myHero.y, myHero.z, rRange, rColor) end
	-- Draw Target --
	if Target ~= nil and RenektonMenu.Draw.drawTarget
		then DrawCircle(Target.x, Target.y, Target.z, (GetDistance(Target.minBBox, Target.maxBBox)/2), TargetColor)
	end
	-- Draw KillText --
	if RenektonMenu.Draw.drawKillText then
			for i = 1, heroManager.iCount do
				local enemy = heroManager:GetHero(i)
				if ValidTarget(enemy) and enemy ~= nil then
					local barPos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
					local PosX = barPos.x - 60
					local PosY = barPos.y - 10
					DrawText(KillTextList[KillText[i]], 16, PosX, PosY, KillTextColor)
				end
			end
	end
end
---------------------------------------------------------------------
--- Cast Functions for Spells ---------------------------------------
---------------------------------------------------------------------
-- Renekton Q --
function CastTheQ(enemy)
		if not enemy then enemy = Target end
		if (not QREADY or (GetDistance(enemy) > qRange))
			then return false
		end
		if ValidTarget(enemy)
			then CastSpell(_Q)
			return true
		end
		return false
end
-- Renekton W --
function CastTheW(enemy)
		if not enemy then enemy = Target end
		if (not WREADY or (GetDistance(enemy) > wRange))
			then return false
		end
		if ValidTarget(enemy)
			then CastSpell(_W, enemy)
			myHero:Attack(enemy)
			return true
		end
		return false
end
-- Renekton E --
function AimTheE(enemy)
	if not enemy then enemy = Target end
	local CastPosition, HitChance, Position = VP:GetLineCastPosition(enemy, eDelay, eWidth, eRange, eSpeed, myHero, false)
	if HitChance >= 2 and GetDistance(enemy) <= eRange and EREADY
		then CastSpell(_E,CastPosition.x,CastPosition.z)
	end
end
-- Renekton Slice (E1) --
function AimTheSlice(enemy)
	if not enemy then enemy = Target end
	local CastPosition, HitChance, Position = VP:GetLineCastPosition(enemy, eDelay, eWidth, eRange, eSpeed, myHero, false)
	if HitChance >= 2 and GetDistance(enemy) <= eRange and E1READY
		then CastSpell(_E,CastPosition.x,CastPosition.z)
	end
end
-- Renekton Dice (E2) --
function AimTheDice(enemy)
	if not enemy then enemy = Target end
	local CastPosition, HitChance, Position = VP:GetLineCastPosition(enemy, eDelay, eWidth, eRange, eSpeed, myHero, false)
	if HitChance >= 2 and GetDistance(enemy) <= eRange and E2READY
		then CastSpell(_E,CastPosition.x,CastPosition.z)
	end
end

---------------------------------------------------------------------
-- Function RenektonsUltimate --------------------------------------- 
---------------------------------------------------------------------
function RenektonsUltimate()
if not RREADY then return end
		if RenektonMenu.Ultimate.useUltimateIfLow
			then 
				if RREADY and myHero.health < (myHero.maxHealth * (RenektonMenu.Ultimate.useUltimateIfLowSlider/100))
					then CastSpell(_R)
				end
		end
		if RenektonMenu.Ultimate.useUltimateTowerDive
			then
				if CountEnemyHeroInRange(1000) > 0 and UnitAtTower(myHero) and RREADY and myHero.health < (myHero.maxHealth * (RenektonMenu.Ultimate.useUltimateTowerDiveSlider/100))
					then CastSpell(_R)
				end
		end	
		if RenektonMenu.Ultimate.useUltimateEnemy
			then
				if RREADY and CountEnemyHeroInRange(RenektonMenu.Ultimate.useUltimateEnemySliderRange) >= RenektonMenu.Ultimate.useUltimateEnemySliderNumber and myHero.health < (myHero.maxHealth * (RenektonMenu.Ultimate.useUltimateEnemySliderHealth/100))
					then CastSpell(_R)
				end
		end
end
---------------------------------------------------------------------
--- SBTW Functions --------------------------------------------------
---------------------------------------------------------------------
function SBTW()
	if ValidTarget(Target)
		then 
			if RenektonMenu.SBTW.sbtwQ then CastTheQ(Target) end
			if RenektonMenu.SBTW.sbtwW then CastTheW(Target) end
			if RenektonMenu.SBTW.sbtwE1 then AimTheSlice(Target) end
			if RenektonMenu.SBTW.sbtwE2 then AimTheDice(Target) end
			if RenektonMenu.SBTW.sbtwItems then UseItems() end
	end
end
---------------------------------------------------------------------
--- Harass Functions ------------------------------------------------
---------------------------------------------------------------------
function Harass()
	if Target
			then
				if RenektonMenu.Harass.harassMode == 1
					then 
						if RenektonMenu.Harass.harassQ then CastTheQ(Target) end
				end
				if RenektonMenu.Harass.harassMode == 2
					then
						if RenektonMenu.Harass.harassQ then CastTheQ(Target) end
						if RenektonMenu.Harass.harassW then CastTheW(Target) end
				end
				if RenektonMenu.Harass.harassMode == 3
					then
						if RenektonMenu.Harass.harassQ then CastTheQ(Target) end
						if RenektonMenu.Harass.harassW then CastTheW(Target) end
						if RenektonMenu.Harass.harassE1 then AimTheSlice(Target) end
						if RenektonMenu.Harass.harassE2 then AimTheDice(Target) end
				end
				if RenektonMenu.Harass.harassMode == 4
					then 
						if RenektonMenu.Harass.harassE1 then AimTheSlice(enemy) end
						if not E1READY and RenektonMenu.Harass.harassQ then CastTheQ(Target) end
						if not E1READY and not QREADY and RenektonMenu.Harass.harassW then CastTheW(Target) end
						if not E1READY and not QREADY and not WREADY and RenektonMenu.Harass.harassE2 then LastDash() end
				end				
	end
end
-- Save the last location we dashed from --
function OnDash(unit, dash)
	if HarassKey and RenektonMenu.Harass.harassMode == 4
		then
			if unit and unit.valid and unit.isMe
				then
					lastDash = { dash.startPos, dash.startT, dash.endT }
			end
	end
end
function LastDash()
if E2READY and lastDash and GetTickCount() > lastDash[3] and type(lastDash) == 'table'
	then
		local time = GetTickCount() - lastDash[2]
		if lastDash[2] + 4000 <= GetTickCount()
			then
				CastSpell(_E, lastDash[1].x, lastDash[1].z)
		end
	end	
end
---------------------------------------------------------------------
--- OnProcessSpell --------------------------------------------------
---------------------------------------------------------------------
function OnProcessSpell(object, spell)
	if ValidTarget(Target)
		then
			-- Renekton W --
			if spell.name == 'RenektonExecute' and RenektonMenu.Extra.aniCancelW
				then 
					DelayAction(function()
					if tmtReady then CastSpell(tmtSlot) end
					if hdrReady then CastSpell(hdrSlot) end
					local delay = RenektonMenu.Extra.aniCancelWSlider
					end, delay)
			end	
	end
end
---------------------------------------------------------------------
--- KillSteal Functions ---------------------------------------------
---------------------------------------------------------------------
function AutoIgnite(enemy)
		if enemy.health <= iDmg and GetDistance(enemy) <= 600 and ignite ~= nil
			then
				if IREADY then CastSpell(ignite, enemy) end
		end
end
-- Checks the Summonerspells for ignite (OnLoad) --
function IgniteCheck()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
			ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
			ignite = SUMMONER_2
	end
end
function smartKS()
	for _, enemy in pairs(enemyHeroes) do
		if enemy ~= nil and ValidTarget(enemy) then
		local distance = GetDistance(enemy)
		local hp = enemy.health
			if hp <= qDmg and QREADY and (distance <= qRange)
				then CastTheQ(enemy)
			elseif hp <= wDmg and WREADY and (distance <= wRange) 
				then CastTheW(enemy)
			elseif hp <= eDmg and EREADY and (distance <= eRange) 
				then AimTheE()
			elseif hp <= (qDmg + wDmg) and QREADY and WREADY and (distance <= qRange)
				then CastTheW(enemy)
			elseif hp <= (qDmg + eDmg) and QREADY and EREADY and (distance <= qRange)
				then AimTheE()
			elseif hp <= (wDmg + eDmg) and WREADY and EREADY and (distance <= wRange)
				then AimTheE()
			elseif hp <= (qDmg + wDmg + eDmg) and QREADY and WREADY and EREADY and (distance <= qRange)
				then AimTheE()
			end
		end
	end
end
---------------------------------------------------------------------
-- Jungle Mob Names -------------------------------------------------
---------------------------------------------------------------------
function JungleNames()
-- JungleMobNames are the names of the smaller Junglemobs --
	JungleMobNames =
{
	-- Blue Side --
		-- Blue Buff --
		["YoungLizard1.1.2"] = true, ["YoungLizard1.1.3"] = true,
		-- Red Buff --
		["YoungLizard4.1.2"] = true, ["YoungLizard4.1.3"] = true,
		-- Wolf Camp --
		["wolf2.1.2"] = true, ["wolf2.1.3"] = true,
		-- Wraith Camp --
		["LesserWraith3.1.2"] = true, ["LesserWraith3.1.3"] = true, ["LesserWraith3.1.4"] = true,
		-- Golem Camp --
		["SmallGolem5.1.1"] = true,
	-- Purple Side --
		-- Blue Buff --
		["YoungLizard7.1.2"] = true, ["YoungLizard7.1.3"] = true,
		-- Red Buff --
		["YoungLizard10.1.2"] = true, ["YoungLizard10.1.3"] = true,
		-- Wolf Camp --
		["wolf8.1.2"] = true, ["wolf8.1.3"] = true,
		-- Wraith Camp --
		["LesserWraith9.1.2"] = true, ["LesserWraith9.1.3"] = true, ["LesserWraith9.1.4"] = true,
		-- Golem Camp --
		["SmallGolem11.1.1"] = true,
}
-- FocusJungleNames are the names of the important/big Junglemobs --
	FocusJungleNames =
{
	-- Blue Side --
		-- Blue Buff --
		["AncientGolem1.1.1"] = true,
		-- Red Buff --
		["LizardElder4.1.1"] = true,
		-- Wolf Camp --
		["GiantWolf2.1.1"] = true,
		-- Wraith Camp --
		["Wraith3.1.1"] = true,		
		-- Golem Camp --
		["Golem5.1.2"] = true,		
		-- Big Wraith --
		["GreatWraith13.1.1"] = true, 
	-- Purple Side --
		-- Blue Buff --
		["AncientGolem7.1.1"] = true,
		-- Red Buff --
		["LizardElder10.1.1"] = true,
		-- Wolf Camp --
		["GiantWolf8.1.1"] = true,
		-- Wraith Camp --
		["Wraith9.1.1"] = true,
		-- Golem Camp --
		["Golem11.1.2"] = true,
		-- Big Wraith --
		["GreatWraith14.1.1"] = true,
	-- Dragon --
		["Dragon6.1.1"] = true,
	-- Baron --
		["Worm12.1.1"] = true,
}
	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil then
			if FocusJungleNames[object.name] then
				table.insert(JungleFocusMobs, object)
			elseif JungleMobNames[object.name] then
				table.insert(JungleMobs, object)
			end
		end
	end
end
---------------------------------------------------------------------
--- Jungle Clear ----------------------------------------------------
---------------------------------------------------------------------
function JungleClear()
	JungleMob = GetJungleMob()
		if JungleMob ~= nil then
			if RenektonMenu.Jungle.jungleQ then CastTheQ(JungleMob) end
			if RenektonMenu.Jungle.jungleW then CastTheW(JungleMob) end
			if RenektonMenu.Jungle.jungleE1 then AimTheSlice(JungleMob) end
			if RenektonMenu.Jungle.jungleE2 then AimTheDice(JungleMob) end
		end
end
-- Get Jungle Mob --
function GetJungleMob()
        for _, Mob in pairs(JungleFocusMobs) do
                if ValidTarget(Mob, qRange) then return Mob end
        end
        for _, Mob in pairs(JungleMobs) do
                if ValidTarget(Mob, qRange) then return Mob end
        end
end
---------------------------------------------------------------------
--- Lane Clear ------------------------------------------------------
---------------------------------------------------------------------
function LaneClear()
	enemyMinions:update()
	for _, minion in pairs(enemyMinions.objects) do
		if ValidTarget(minion) and minion ~= nil and not rSOW:CanAttack()
			then 
				if RenektonMenu.Farm.farmQ then CastTheQ(minion) end
				if RenektonMenu.Farm.farmW then CastTheW(minion) end
				if RenektonMenu.Farm.farmE1 then AimTheSlice(minion) end
				if RenektonMenu.Farm.farmE2 then AimTheDice(minion) end
		end
	end
end
---------------------------------------------------------------------
-- Object Handling Functions ----------------------------------------
-- Checks for objects that are created and deleted
---------------------------------------------------------------------
function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			if GetDistance(obj) <= 70 then
				Recalling = true
			end
		end 
		if FocusJungleNames[obj.name] then
			table.insert(JungleFocusMobs, obj)
		elseif JungleMobNames[obj.name] then
            table.insert(JungleMobs, obj)
		end
	end
end
function OnDeleteObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			if GetDistance(obj) <= 70 then
				Recalling = false
			end
		end 
		for i, Mob in pairs(JungleMobs) do
			if obj.name == Mob.name then
				table.remove(JungleMobs, i)
			end
		end
		for i, Mob in pairs(JungleFocusMobs) do
			if obj.name == Mob.name then
				table.remove(JungleFocusMobs, i)
			end
		end
	end
end
---------------------------------------------------------------------
-- Recalling Functions ----------------------------------------------
-- Checks if our champion is recalling or not and sets the var Recalling based on that
-- Other functions can check Recalling to not interrupt it
---------------------------------------------------------------------
function OnRecall(hero, channelTimeInMs)
	if hero.networkID == player.networkID then
		Recalling = true
	end
end
function OnAbortRecall(hero)
	if hero.networkID == player.networkID
		then Recalling = false
	end
end
function OnFinishRecall(hero)
	if hero.networkID == player.networkID
		then Recalling = false
	end
end
---------------------------------------------------------------------
--- Lag Free Circles ------------------------------------------------
---------------------------------------------------------------------
function LFCfunc()
	if not RenektonMenu.Draw.LFC.LagFree then _G.DrawCircle = _G.oldDrawCircle end
	if RenektonMenu.Draw.LFC.LagFree then _G.DrawCircle = DrawCircle2 end
end
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
	quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end
function round(num) 
 if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end
function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, RenektonMenu.Draw.LFC.CL) 
    end
end
---------------------------------------------------------------------
--- Autolevel Skills ------------------------------------------------
---------------------------------------------------------------------
function AutoLevelMySkills()
		if RenektonMenu.Extra.AutoLevelSkills == 2 then
			autoLevelSetSequence(levelSequence.startQ)
		elseif RenektonMenu.Extra.AutoLevelSkills == 3 then
			autoLevelSetSequence(levelSequence.startW)
		elseif RenektonMenu.Extra.AutoLevelSkills == 4 then
			autoLevelSetSequence(levelSequence.startE)
		end
end
---------------------------------------------------------------------
--- Function Damage Calculations for Skills/Items/Enemys --- 
---------------------------------------------------------------------
function DamageCalculation()
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) and enemy ~= nil
				then
				aaDmg 		= ((getDmg("AD", enemy, myHero)))
				qDmg 		= ((getDmg("Q", enemy, myHero)) or 0)	
				wDmg		= ((getDmg("W", enemy, myHero)) or 0)	
				eDmg		= ((getDmg("E", enemy, myHero)) or 0)	
				iDmg 		= ((ignite and getDmg("IGNITE", enemy, myHero)) or 0)	-- Ignite
				dfgDmg 		= ((dfgReady and getDmg("DFG", enemy, myHero)) or 0)	-- Deathfire Grasp
				hxgDmg 		= ((hxgReady and getDmg("HXG", enemy, myHero)) or 0)	-- Hextech Gunblade
				bwcDmg 		= ((bwcReady and getDmg("BWC", enemy, myHero)) or 0)	-- Bilgewater Cutlass
				botrkDmg 	= ((botrkReady and getDmg("RUINEDKING", enemy, myHero)) or 0)	-- Blade of the Ruined King
				sheenDmg	= ((sheenReady and getDmg("SHEEN", enemy, myHero)) or 0)	-- Sheen
				lichbaneDmg = ((lichbaneReady and getDmg("LICHBANE", enemy, myHero)) or 0)	-- Lichbane
				trinityDmg 	= ((trinityReady and getDmg("TRINITY", enemy, myHero)) or 0)	-- Trinity Force
				liandrysDmg = ((liandrysReady and getDmg("LIANDRYS", enemy, myHero)) or 0)	-- Liandrys 
				local extraDmg 	= iDmg + dfgDmg + hxgDmg + bwcDmg + botrkDmg + sheenDmg + trinityDmg + liandrysDmg + lichbaneDmg 
				local abilityDmg = qDmg + wDmg + eDmg
				local totalDmg = abilityDmg + extraDmg
	-- Set Kill Text --	
					-- "Kill! - Ignite" --
					if enemy.health <= iDmg
						then
							 if IREADY then KillText[i] = 3
							 else KillText[i] = 2
							 end
					-- "Kill! - (Q)" --
					elseif enemy.health <= qDmg
						then
							if QREADY then KillText[i] = 4
							else KillText[i] = 2
							end
					--	"Kill! - (W)" --
					elseif enemy.health <= wDmg
						then
							if WREADY then KillText[i] = 5
							else KillText[i] = 2
							end
					-- "Kill! - (E)" --
					elseif enemy.health <= eDmg
						then
							if EREADY then KillText[i] = 6
							else KillText[i] = 2
							end
					-- "Kill! - (Q)+(W)" --
					elseif enemy.health <= qDmg+wDmg
						then
							if QREADY and WREADY then KillText[i] = 7
							else KillText[i] = 2
							end
					-- "Kill! - (Q)+(E)" --
					elseif enemy.health <= qDmg+eDmg
						then
							if QREADY and EREADY then KillText[i] = 8
							else KillText[i] = 2
							end
					-- "Kill! - (W)+(E)" --
					elseif enemy.health <= wDmg+eDmg
						then
							if WREADY and EREADY then KillText[i] = 9
							else KillText[i] = 2
							end
					-- "Kill! - (Q)+(W)+(E)" --
					elseif enemy.health <= qDmg+wDmg+eDmg
						then
							if QREADY and WREADY and EREADY then KillText[i] = 10
							else KillText[i] = 2
							end
					-- "Harass your enemy!" -- 
					else KillText[i] = 1				
					end
			end
		end
end
---------------------------------------------------------------------
-- Function UnitAtTower --------------------------------------------- 
-- Checks if a unit is under a tower e.g. UnitAtTower(enemy)
---------------------------------------------------------------------
function UnitAtTower(unit)
	for i, turret in pairs(GetTurrets()) do
		if turret ~= nil then
			if turret.team ~= myHero.team then
				if GetDistance(unit, turret) <= turret.range then
					return true
				end
			end
		end
	end
	return false
end
