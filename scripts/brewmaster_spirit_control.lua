--<<HippyFizz Brewmaster MOD Beta>> 
require("libs.Utils")
require("libs.TargetFind")
require("libs.ScriptConfig")
require("libs.SkillShot")

config = ScriptConfig.new()
config:SetParameter("StunKey", "Z", config.TYPE_HOTKEY)
config:SetParameter("WindKey", "X", config.TYPE_HOTKEY)
config:SetParameter("InvisKey", "C", config.TYPE_HOTKEY)
config:SetParameter("CleanceKey", "B", config.TYPE_HOTKEY)
config:SetParameter("ComboKey", "V", config.TYPE_HOTKEY)
config:SetParameter("HideNotes", "H", config.TYPE_HOTKEY)
config:SetParameter("Text X", 5)
config:SetParameter("Text Y", 45)
config:Load()

init = false
local cooldown = false
local manatick = false

local stun_key = config.StunKey
local wind_key = config.WindKey
local invis_key = config.InvisKey
local cleance_key = config.CleanceKey
local combo_key = config.ComboKey
local hide_hotes_key = config.HideNotes

local stun_active = false
local wind_active = false
local invis_active = false
local cleance_active = false
local combo_active = false

Brewmaster_PrimalEarth = nil
Brewmaster_PrimalFire = nil
Brewmaster_PrimalStorm = nil

thunder_clap = nil
drunken_haze = nil
primal_split = nil

local x,y = config:GetParameter("Text X"), config:GetParameter("Text Y")
local TitleFont = drawMgr:CreateFont("Title","Segoe UI",18,580) 
local ControlFont = drawMgr:CreateFont("Title","Segoe UI",14,500)
local text = drawMgr:CreateText(x,y,0x6CF58CFF,"HippyFizz Brewmaster MOD Beta",TitleFont) text.visible = false
local info = drawMgr:CreateText(x,y+16,0x6CF58CFF," Press  " .. string.char(hide_hotes_key) .." to show more info",ControlFont) info.visible = false
local button_message_1 = drawMgr:CreateText(x,y+16,0x6CF58CFF," >  " .. string.char(stun_key) .." stun enemy under mouse",ControlFont) button_message_1.visible = false
local button_message_2 = drawMgr:CreateText(x,y+32,0x6CF58CFF," >  " .. string.char(wind_key) .." wind enemy under mouse",ControlFont) button_message_2.visible = false
local button_message_3 = drawMgr:CreateText(x,y+48,0x6CF58CFF," >  " .. string.char(invis_key) .." use WINDWALK on BLUE ONE",ControlFont) button_message_3.visible = false
local button_message_4 = drawMgr:CreateText(x,y+64,0x6CF58CFF," >  " .. string.char(cleance_key) .." dispel magic under cursor",ControlFont) button_message_4.visible = false
local button_message_5 = drawMgr:CreateText(x,y+80,0x6CF58CFF," >  " .. string.char(combo_key) .." HOLD TO FULL AUTO COMBO",ControlFont) button_message_5.visible = false
local status = drawMgr:CreateText(x,y+100,0x2CFA02FF,"Script Status : Ready!",ControlFont) status.visible = false
local invis_status = drawMgr:CreateText(x,y+120,0xED5153FF,"WindWalk Status: Disable",ControlFont) invis_status.visible = false
local manawarning = drawMgr:CreateText(x,y+140,0xED5153FF,"",ControlFont) manawarning.visible = false


function Load_func()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Brewmaster then 
			script:Disable()
		else
		    print("HippyFizz Brewmaster MOD Loaded")
			info.visible = true
			if combo_key == 32 then 
			    combo_message.text = "HOLD Space to combo on target nearest to mouse"
			end
			script:RegisterEvent(EVENT_TICK,Tick_func)
			script:RegisterEvent(EVENT_KEY,key)
			script:UnregisterEvent(Load_func)
		end
	end
end

function Close_func()
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
end

function key(msg, code)
	if client.chat or client.console or client.loading then return end
	
	if code == hide_hotes_key then
		if button_message_1.visible == true then
		else
			info.visible = false
			button_message_1.visible = true
			button_message_2.visible = true
			button_message_3.visible = true
			button_message_4.visible = true
			button_message_5.visible = true
		end
	end
	
	if code == stun_key then
		stun_active = (msg == KEY_DOWN)
		stun_func()
		status.text = "Script Status : enemy STUNED!"
		status.color = 0xED9A09FF
	end
	
	if code == wind_key then
		wind_active = (msg == KEY_DOWN)
		wind_func()
		status.text = "Script Status : enemy WINDED!"
		status.color = 0xED9A09FF
	end
	
	if code == invis_key then
		invis_active_on = (msg == KEY_DOWN)
		invis_func()
		invis_status.text = "WindWalk Status: Enable"
		invis_status.color = 0x2CFA02FF
	end
	
	if code == cleance_key then
		cleance_active = (msg == KEY_DOWN)
		cleane_func()
		status.text = "Script Status: Purge used!"
		status.color = 0xED9A09FF
	end
	
	if code == combo_key then
		combo_active = (msg == KEY_DOWN)
		blink_combo_func()
		stun_func()
		fire_rush()
		status.text = "Script Status : Combo-ing!"
		status.color = 0xED9A09FF
    end
end

function Tick_func(tick)
	local me = entityList:GetMyHero()
	if not me then return end
	
	init_func()
	
	
	--[[stun_func()
	wind_func()
	invis_func()
	combo_func()
	cleane_func()]]
	
	--[[if thunder_clap.cd > 0 and primal_split.cd > 0 then
	        status.text = "Script Status : Cooling Down!"
		status.color = 0xED5153FF
		cooldown = true
	elseif thunder_clap.cd == 0 and primal_split.cd == 0 then
	        cooldown = false
	end]]
	
if pcall(function ()	
	local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split then
		if Brewmaster_PrimalStorm:DoesHaveModifier("modifier_brewmaster_storm_wind_walk") and not Brewmaster_PrimalStorm:DoesHaveModifier("modifier_item_dustofappearance")then
			invis_status.text = "WindWalk Status: Enable"
			invis_status.color = 0x2CFA02FF
			invis_status.visible = true
		else 
			invis_status.text = "WindWalk Status: Disable"
			invis_status.color = 0xED5153FF
			invis_status.visible = true
		end else
		invis_status.text = "WindWalk Status: Disable"
		invis_status.color = 0xED5153FF
		invis_status.visible = true
	end
end) then 
end

end

function init_func()
	local me = entityList:GetMyHero()	
	thunder_clap = me:GetAbility(1)
	drunken_haze = me:GetAbility(2)
	primal_split = me:GetAbility(4)
		
	Brewmaster_PrimalEarth = initiate_earth()
	Brewmaster_PrimalFire = initiate_fire()
	Brewmaster_PrimalStorm = initiate_storm()
end

function initiate_earth()
	local me = entityList:GetMyHero()
	local earth = entityList:GetEntities({classId = CDOTA_Unit_Brewmaster_PrimalEarth, controllable = true, alive = true, team = me.team})[1]
	return earth
end

function initiate_fire()
	local me = entityList:GetMyHero()
	local fire = entityList:GetEntities({classId = CDOTA_Unit_Brewmaster_PrimalFire, controllable = true, alive = true, team = me.team})[1]
	return fire
end

function initiate_storm()
	local me = entityList:GetMyHero()
	local storm = entityList:GetEntities({classId = CDOTA_Unit_Brewmaster_PrimalStorm, controllable = true, alive = true, team = me.team})[1]
	return storm	
end

function blink_combo_func()
local me = entityList:GetMyHero()	
local Blink = me:FindItem("item_blink")
local Range = 250
local blink_range = 1200
local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})
for i,v in ipairs(enemies) do
	if v.visible and v.alive and v.health > 0 then
		if SleepCheck("blink") and GetDistance2D(me,v) <= blink_range+150 and GetDistance2D(me,v) > Range then
		local bpos = v.position							
		if GetDistance2D(me,v) > blink_range then
			bpos = (v.position - me.position) * 1100 / GetDistance2D(me,v) + me.position
		end
		me:SafeCastItem(Blink.name,bpos)		
	    Sleep(me:GetTurnTime(v)+client.latency,"blink")
		me:SafeCastAbility(thunder_clap,false)
		me:SafeCastAbility(primal_split,false)
		end
	end
end
end

function fire_rush()
local me = entityList:GetMyHero()
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
if check_primal_split then
	if pcall(function ()
	local cursor = targetFind:GetClosestToMouse(100,false)
	Brewmaster_PrimalFire:Attack(cursor)
	Brewmaster_PrimalEarth:Attack(cursor)
	Sleep(1000)
	end) then end
end
end

function stun_func()
local me = entityList:GetMyHero()
--[[local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})]]
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
--[[for i,v in ipairs(enemies) do
	if v.visible and v.alive and v.health > 0 then
		if GetDistance2D(me,v) < 800 then]]
			if check_primal_split and SleepCheck("hurl_boulder") then 
				if pcall(function ()
				local v = targetFind:GetClosestToMouse(100)
				local hurl_boulder = Brewmaster_PrimalEarth:GetAbility(1)
					Brewmaster_PrimalEarth:SafeCastAbility(hurl_boulder,v,false)
					Sleep(1000, "hurl_boulder")
				end) then end
				
			--[[end
		end
	end]]
end
end

function wind_func()
local me = entityList:GetMyHero()
--[[local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})]]
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
--[[for i,v in ipairs(enemies) do]]
	if check_primal_split and SleepCheck("cyclone") then 
		--[[if v.visible and v.alive and v.health > 0 then
			if GetDistance2D(me,v) < 600 and not Brewmaster_PrimalStorm:DoesHaveModifier("modifier_brewmaster_storm_wind_walk") then]]
				local v = targetFind:GetClosestToMouse(100)
				local cyclone = Brewmaster_PrimalStorm:GetAbility(2)
				if pcall(function () 
					Brewmaster_PrimalStorm:SafeCastAbility(cyclone,v,false)
					Sleep(1000, "cyclone")
				end) then end
				
			--[[end
		end
	end]]
end
end

function cleane_func()
local me = entityList:GetMyHero()
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
	if check_primal_split and SleepCheck("dispel_magic") then 
	local target = client.mousePosition
		local dispel_magic = Brewmaster_PrimalStorm:GetAbility(1)
		Brewmaster_PrimalStorm:SafeCastAbility(dispel_magic,target,false)
		Sleep(1000,"dispel_magic")
	end
end

function invis_func()
local me = entityList:GetMyHero()
local cursor = client.mousePosition
local check_primal_split = me:DoesHaveModifier("modifier_brewmaster_primal_split")
if check_primal_split and SleepCheck("windwalk") then
	local windwalk = Brewmaster_PrimalStorm:GetAbility(3)
	Brewmaster_PrimalStorm:SafeCastAbility(windwalk, false)
	Sleep(1000, "windwalk")
end
end

script:RegisterEvent(EVENT_TICK,Load_func)
script:RegisterEvent(EVENT_CLOSE,Close_func)