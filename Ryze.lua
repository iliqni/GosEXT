---------------------------------------------------------------------------------------------------------------------------------------------------
if myHero.charName ~= "Ryze" then
  PrintChat ("You aint Playin ryze, Shutting down")
  return end
---------------------------------------------------------------------------------------------------------------------------------------------------
class "Ryze"
require 'DamageLib'

local _shadow = myHero.pos
---------------------------------------------------------------------------------------------------------------------------------------------------
function Ryze:__init()
  PrintChat("ManlyRyze Enabled")
  if _G.EOWLoaded then
    Orb = 1
  elseif _G.SDK and _G.SDK.Orbwalker then
    Orb = 2
  end
  self:LoadSpells()
  self:LoadMenu()
  Callback.Add("Tick", function() self:Tick() end)
  Callback.Add("Draw", function() self:Draw() end)
end
---------------------------------------------------------------------------------------------------------------------------------------------------
local function GetTarget(range)
  local target = nil
  if Orb == 1 then
    target = EOW:GetTarget(range)
  elseif Orb == 2 then
    target = _G.SDK.TargetSelector:GetTarget(range)
  elseif Orb == 3 then
    target = GOS:GetTarget(range)
  end
  return target
end
---------------------------------------------------------------------------------------------------------------------------------------------------
local function Ready (spell)
  return Game.CanUseSpell(spell) == 0
end
---------------------------------------------------------------------------------------------------------------------------------------------------
local intToMode = {
  [0] = "0",
  [1] = "Combo",
  [2] = "Harass",
  [3] = "LastHit",
  [4] = "Clear"
}
---------------------------------------------------------------------------------------------------------------------------------------------------
local function GetMode()
  if Orb == 1 then
    return intToMode[EOW.CurrentMode]
  elseif Orb == 2 then
    if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
      return "Combo"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
      return "Harass"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_JUNGLECLEAR] then
      return "Clear"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] then
      return "LastHit"
    elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
      return "Flee"
    end
  else
    return GOS.GetMode()
  end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
local function EnableOrb(bool)
  if Orb == 1 then
    EOW:SetMovements(bool)
    EOW:SetAttacks(bool)
  elseif Orb == 2 then
    _G.SDK.Orbwalker:SetMovement(bool)
    _G.SDK.Orbwalker:SetAttack(bool)
  else
    GOS.BlockMovement = not bool
    GOS.BlockAttack = not bool
  end
end
local function Idmg(target)
  if (myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1))
    or (myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_2)) then
    return 50 + 20 * myHero.levelData.lvl
  end
  return 0
end

local function BSdmg(target)
  if (myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_1))
    or (myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_2)) then
    return 20 + 8 * myHero.levelData.lvl
  end
  return 0
end

local function RSdmg(target)
  if (myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_1))
    or (myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_2)) then
    return 54 + 6 * myHero.levelData.lvl
  end
  return 0
end

local function NoPotion()
  for i = 0, 63 do
    local buff = myHero:GetBuff(i)
    if buff.type == 13 and Game.Timer() < buff.expireTime then
      return false
    end
  end
  return true
end
function PercentHP(target)
  return 100 * target.health / target.maxHealth
end

function PercentMP(target)
  return 100 * target.mana / target.maxMana
end

local HKITEM = {
  [ITEM_1] = HK_ITEM_1,
  [ITEM_2] = HK_ITEM_2,
  [ITEM_3] = HK_ITEM_3,
  [ITEM_4] = HK_ITEM_4,
  [ITEM_5] = HK_ITEM_5,
  [ITEM_6] = HK_ITEM_6,
  [ITEM_7] = HK_ITEM_7,
}

---------------------------------------------------------------------------------------------------------------------------------------------------
function Ryze:LoadSpells()
  Q = { range = myHero:GetSpellData(_Q).range, delay = myHero:GetSpellData(_Q).delay, speed = myHero:GetSpellData(_Q).speed, width = myHero:GetSpellData(_Q).width }
  W = { range = myHero:GetSpellData(_W).range, delay = myHero:GetSpellData(_W).delay, speed = myHero:GetSpellData(_W).speed, width = myHero:GetSpellData(_W).width }
  E = { range = myHero:GetSpellData(_E).range, delay = myHero:GetSpellData(_E).delay, speed = myHero:GetSpellData(_E).speed, width = myHero:GetSpellData(_E).width }
end
---------------------------------------------------------------------------------------------------------------------------------------------------
function Ryze:LoadMenu()
  self.Menu = MenuElement({type = MENU, id = "Ryze", name = "ManlyRyze"})
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  function Ryze:Clear()
    for i = 1, Game.MinionCount(725) do
      local minion = Game.Minion(i)
      if  minion and minion.team ~= myHero.team  then
        if myHero.pos:DistanceTo(minion.pos) < 1000 and self.Menu.Clear.ClearQ:Value() and Ready(_Q) then
          Control.CastSpell(HK_Q,minion.pos)
        end
        if myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.Clear.ClearE:Value() and Ready(_E) then
          Control.CastSpell(HK_E,minion.pos)
        end
        if myHero.pos:DistanceTo(minion.pos) < 600 and self.Menu.Clear.ClearW:Value() and Ready(_W) then
          Control.CastSpell(HK_W)
        end
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------
  end

  ---------------------------------------------------------------------------------------------------------------------------------------------------
  function Ryze:CQ()
    if GetTarget(1000) == false then end
    local qtarg = GetTarget(1000)
    if self.Menu.Combo.ComboQ:Value() and Ready(_Q) and qtarg ~= nil and qtarg:GetCollision(Q.width,Q.speed,Q.delay) == 0 then
      EnableOrb(false)
      Control.CastSpell(HK_Q,qtarg)
      EnableOrb(true)
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  function Ryze:CE()
    if GetTarget(615) == false then return
    end
    local etarg = GetTarget(615)
    if etarg ~= nil then
      if self.Menu.Combo.ComboE:Value() and Ready(_E) 
      then
        EnableOrb(false)
        Control.CastSpell(HK_E, etarg)
        EnableOrb(true)
      end
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  function Ryze:CW()
    if GetTarget(615) == false then return end
    local wtarg = GetTarget(615)
    if self.Menu.Combo.ComboW:Value() and Ready(_W) and wtarg ~= nil then
      Control.CastSpell(HK_W,wtarg)
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------

  ---------------------------------------------------------------------------------------------------------------------------------------------------
  function Ryze:Tick()
    self:AutoLevel()
    self:Activator()
    self:Summoners()

    if myHero.dead then return end
    local Mode = GetMode()
    if self.Menu.Combo.PrioKey:Value() then
      local x = self.Menu.Combo.Prio:Value() +1
      Control.KeyUp(14)
      DelayAction(function() self.Menu.Combo.Prio:Value(x) end, 0.1)
    end

    if self.Menu.Combo.Prio:Value() > 3 then
      self.Menu.Combo.Prio:Value(1) end

    ---------------------------------------------------------------------------------------------------------------------------------------------------
    if Mode == "Combo" then
      if self.Menu.Combo.Prio:Value() == 1 then
        self:CQ() self:CW() self:CQ() self:CE() self:CQ()
        ---------------------------------------------------------------------------------------------------------------------------------------------------
      elseif self.Menu.Combo.Prio:Value() == 2 then
        self:CW() self:CQ() self:CE() self:CQ()
        ---------------------------------------------------------------------------------------------------------------------------------------------------
      elseif self.Menu.Combo.Prio:Value() == 3 then
        self:CE() self:CW() self:CQ()
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    if Mode == "Clear" then
      self:Clear()
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------
       if Mode == "Harass" then
      if self.Menu.Combo.Prio:Value() == 1 then
        self:CQ() self:CW() self:CQ() self:CE() self:CQ()
        ---------------------------------------------------------------------------------------------------------------------------------------------------
      elseif self.Menu.Combo.Prio:Value() == 2 then
        self:CW() self:CQ() self:CE() self:CQ()
        ---------------------------------------------------------------------------------------------------------------------------------------------------
      elseif self.Menu.Combo.Prio:Value() == 3 then
        self:CE() self:CW() self:CQ()
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------




  end

  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --[[Combo]]
  self.Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
  self.Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
  self.Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
  self.Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
  self.Menu.Combo:MenuElement({id = "Prio", name = "Combo Priority", drop = {"Q","W","E"}})
  self.Menu.Combo:MenuElement({id = "PrioKey", name = "Priority key",key = string.byte("T")})
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --Clear
  self.Menu:MenuElement({type = MENU, id = "Clear", name = "Clear Settings"})
  self.Menu.Clear:MenuElement({id = "ClearQ", name = "Use Q", value = true})
  self.Menu.Clear:MenuElement({id = "ClearW", name = "Use W", value = true})
  self.Menu.Clear:MenuElement({id = "ClearE", name = "Use E", value = true})
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --Misc
  self.Menu:MenuElement({type = MENU, id = "Misc", name = "Misc"})
  self.Menu.Misc:MenuElement({id = "lvEnabled", name = "Enable AutoLeveler", value = false})
  self.Menu.Misc:MenuElement({id = "Block", name = "Block on Level 1", value = true})
  self.Menu.Misc:MenuElement({id = "Order", name = "Skill Priority", drop = {"[Custom Lvler > [Q]>[E]>[W]","[Q] - [E] - [W] > Max [Q]","[W] - [Q] - [E] > Max [W]","[W] - [E] - [Q] > Max [W]","[E] - [Q] - [W] > Max [E]","[E] - [W] - [Q] > Max [E]"}})
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --[[Draw]]
  self.Menu:MenuElement({type = MENU, id = "Draw", name = "Drawings"})
  self.Menu.Draw:MenuElement({id = "DrawQW", name = "Draw W Range", value = false})
  self.Menu.Draw:MenuElement({id = "DrawQQ", name = "Draw Q Range", value = false})
  self.Menu.Draw:MenuElement({id = "DrawE", name = "Draw E Range", value = false})
  self.Menu.Draw:MenuElement({id = "DrawP", name = "Draw Priority", value = false})
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --ITEM ACTIVATOR
  self.Menu:MenuElement({type = MENU, id ="Activator", name = "Activator"})
  self.Menu.Activator:MenuElement({type = SPACE, id = "A", name = "24/7 Item Activator"})
  self.Menu.Activator:MenuElement({type = MENU, id = "Potions", name = "Potions"})
  self.Menu.Activator.Potions:MenuElement({id = "Pot", name = "Use Pots?", value = false})
  self.Menu.Activator.Potions:MenuElement({id = "HP", name = "Health % to Potion", value = 60, min = 0, max = 100})
  self.Menu.Activator:MenuElement({type = SPACE, id = "Ab", name = "Combo Item Activator"})
  self.Menu.Activator:MenuElement({type = MENU, id = "Items", name = "Items"})
  self.Menu.Activator.Items:MenuElement({id = "YG", name = "Youmuu's Ghostblade", value = true})
  self.Menu.Activator.Items:MenuElement({type = MENU, id = "YGS", name = "GhostBlade Settings"})
  self.Menu.Activator.Items.YGS:MenuElement({id = "ED", name = "Enemy Distance", value = 1000, min = 400, max = 2500, step = 25})
  self.Menu.Activator.Items:MenuElement({id = "TIA", name = "Tiamat", value = true})
  self.Menu.Activator.Items:MenuElement({id = "HYD", name = "Ravenous Hydra", value = true})
  self.Menu.Activator.Items:MenuElement({id = "TIT", name = "Titanic Hydra", value = true})
  self.Menu.Activator.Items:MenuElement({id = "QSS", name = "QSS / Scimitar", value = true})
  self.Menu.Activator.Items:MenuElement({type = MENU, id = "QSSS", name = "QSS Settings"})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Blind", name = "Blind", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Charm", name = "Charm", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Flee", name = "Flee", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Slow", name = "Slow", value = false})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Root", name = "Root/Snare", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Poly", name = "Polymorph", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Silence", name = "Silence", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Stun", name = "Stun", value = true})
  self.Menu.Activator.Items.QSSS:MenuElement({id = "Taunt", name = "Taunt", value = true})
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --SUMMONER ACTIVATOR
  self.Menu.Activator:MenuElement({type = MENU, id = "Summoners", name = "Summoner Spells"})
  DelayAction(function()
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" then
      self.Menu.Activator.Summoners:MenuElement({id = "Smite", name = "Smite in Combo [?]", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "SmiteS", name = "Smite Stacks to Combo", value = 1, min = 1, max = 2})
      self.Menu.Activator.Summoners:MenuElement({id = "SmiteHp", name = "Enemy Hp for smite",value = 50, min = 0, max = 100, step = 1})
    end
  end, 2)
  DelayAction(function()
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then
      self.Menu.Activator.Summoners:MenuElement({id = "Heal", name = "Auto Heal", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "HealHP", name = "Health % to Heal", value = 25, min = 0, max = 100})
    end
  end, 2)
  DelayAction(function()
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then
      self.Menu.Activator.Summoners:MenuElement({id = "Barrier", name = "Auto Barrier", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "BarrierHP", name = "Health % to Barrier", value = 25, min = 0, max = 100})
    end
  end, 2)
  DelayAction(function()
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then
      self.Menu.Activator.Summoners:MenuElement({id = "Ignite", name = "Ignite in Combo", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "IgniteHP", name = "Enemy Hp for Ignite",value = 30, min = 0, max = 100, step = 1})
    end
  end, 2)
  DelayAction(function()
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then
      self.Menu.Activator.Summoners:MenuElement({id = "Exh", name = "Exhaust in Combo", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "ExhaustHp", name = "Enemy Hp for Exhaust",value = 30, min = 0, max = 100, step = 1})
    end
  end, 2)
  DelayAction(function()
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" then
      self.Menu.Activator.Summoners:MenuElement({id = "Cleanse", name = "Auto Cleanse", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Blind", name = "Blind", value = false})
      self.Menu.Activator.Summoners:MenuElement({id = "Charm", name = "Charm", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Flee", name = "Flee", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Slow", name = "Slow", value = false})
      self.Menu.Activator.Summoners:MenuElement({id = "Root", name = "Root/Snare", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Poly", name = "Polymorph", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Silence", name = "Silence", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Stun", name = "Stun", value = true})
      self.Menu.Activator.Summoners:MenuElement({id = "Taunt", name = "Taunt", value = true})
    end
  end, 2)
  self.Menu.Activator.Summoners:MenuElement({type = SPACE, id = "Note", name = "Note: Ghost/TP/Flash is not supported"})


end
---------------------------------------------------------------------------------------------------------------------------------------------------
function Ryze:AutoLevel()
  if self.Menu.Misc.lvEnabled:Value() == false then return end
  local Sequence = {
    [1] = { HK_E, HK_Q, HK_W, HK_Q, HK_Q, HK_R, HK_Q, HK_E, HK_E, HK_E, HK_R, HK_E, HK_Q, HK_Q, HK_W, HK_R, HK_W, HK_W },
    [2] = { HK_Q, HK_E, HK_W, HK_Q, HK_Q, HK_R, HK_Q, HK_E, HK_Q, HK_E, HK_R, HK_E, HK_E, HK_W, HK_W, HK_R, HK_W, HK_W },
    [3] = { HK_W, HK_Q, HK_E, HK_W, HK_W, HK_R, HK_W, HK_Q, HK_W, HK_Q, HK_R, HK_Q, HK_Q, HK_E, HK_E, HK_R, HK_E, HK_E },
    [4] = { HK_W, HK_E, HK_Q, HK_W, HK_W, HK_R, HK_W, HK_E, HK_W, HK_E, HK_R, HK_E, HK_E, HK_Q, HK_Q, HK_R, HK_Q, HK_Q },
    [5] = { HK_E, HK_Q, HK_W, HK_E, HK_E, HK_R, HK_E, HK_Q, HK_E, HK_Q, HK_R, HK_Q, HK_Q, HK_W, HK_W, HK_R, HK_W, HK_W },
    [6] = { HK_E, HK_W, HK_Q, HK_E, HK_E, HK_R, HK_E, HK_W, HK_E, HK_W, HK_R, HK_W, HK_W, HK_Q, HK_Q, HK_R, HK_Q, HK_Q },
  }
  local Slot = nil
  local Tick = 0
  local SkillPoints = myHero.levelData.lvl - (myHero:GetSpellData(_Q).level + myHero:GetSpellData(_W).level + myHero:GetSpellData(_E).level + myHero:GetSpellData(_R).level)
  local level = myHero.levelData.lvl
  local Check = Sequence[self.Menu.Misc.Order:Value()][level - SkillPoints + 1]
  if SkillPoints > 0 then
    if self.Menu.Misc.Block:Value() and level == 1 then return end
    if GetTickCount() - Tick > 800 and
      Check ~= nil then
      Control.KeyDown(HK_LUS)
      Control.KeyDown(Check)
      Slot = Check
      Tick = GetTickCount()
    end
  end
  if Control.IsKeyDown(HK_LUS) then
    Control.KeyUp(HK_LUS)
  end
  if Slot and Control.IsKeyDown(Slot) then
    Control.KeyUp(Slot)
  end
end
---------------------------------------------------------------------------------------------------------------------------------------------------
function Ryze:Draw()
  local P = self.Menu.Combo.Prio:Value()
  local textPos = myHero.pos:To2D()
  if myHero.dead then return end
  if self.Menu.Draw.DrawQW:Value() then
    Draw.Circle(myHero.pos, 615, 1, Draw.Color(255, 255, 255, 255))
  end
  if self.Menu.Draw.DrawQQ:Value() then
    Draw.Circle(myHero.pos, 1000, 1, Draw.Color(255, 255, 255, 255))
  end
  if self.Menu.Draw.DrawE:Value() then
    Draw.Circle(myHero.pos, 615, 1, Draw.Color(255, 255, 255, 255))
  end
  if self.Menu.Draw.DrawP:Value() then
    if P == 1  then
      Draw.Text("Q Combo", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    else if P == 2  then
      Draw.Text("W Combo", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    else Draw.Text("E Combo", 20, textPos.x - 80, textPos.y + 60, Draw.Color(255, 255, 0, 0))
    end
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
end
---------------------------------------------------------------------------------------------------------------------------------------------------
function Ryze:Summoners()
  local target = GetTarget(1200)
  if target == nil then return end
  if GetMode() == "Combo" then
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    if myHero:GetSpellData(SUMMONER_1).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerSmite" or myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" or myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" then

      if self.Menu.Activator.Summoners.Smite:Value() then

        if myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_1) and self.Menu.Activator.Summoners.SmiteHp:Value() / 100 >= target.health/target.maxHealth
          and myHero:GetSpellData(SUMMONER_1).ammo >= self.Menu.Activator.Summoners.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
          Control.CastSpell(HK_SUMMONER_1, target)
        elseif myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmiteDuel" and Ready(SUMMONER_2) and self.Menu.Activator.Summoners.SmiteHp:Value() / 100 >= target.health/target.maxHealth
          and myHero:GetSpellData(SUMMONER_2).ammo >= self.Menu.Activator.Summoners.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
          Control.CastSpell(HK_SUMMONER_2, target)
        end

        if myHero:GetSpellData(SUMMONER_1).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_1) and self.Menu.Activator.Summoners.SmiteHp:Value() / 100 >= target.health/target.maxHealth
          and myHero:GetSpellData(SUMMONER_1).ammo >= self.Menu.Activator.Summoners.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
          Control.CastSpell(HK_SUMMONER_1, target)
        elseif myHero:GetSpellData(SUMMONER_2).name == "S5_SummonerSmitePlayerGanker" and Ready(SUMMONER_2) and self.Menu.Activator.Summoners.SmiteHp:Value() / 100 >= target.health/target.maxHealth
          and myHero:GetSpellData(SUMMONER_2).ammo >= self.Menu.Activator.Summoners.SmiteS:Value() and myHero.pos:DistanceTo(target.pos) < 500 then
          Control.CastSpell(HK_SUMMONER_2, target)
        end
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------

    if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" then

      if self.Menu.Activator.Summoners.Ignite:Value() then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerDot" and Ready(SUMMONER_1) and self.Menu.Activator.Summoners.IgniteHP:Value() / 100 >= target.health/target.maxHealth
          and myHero.pos:DistanceTo(target.pos) < 600 then
          Control.CastSpell(HK_SUMMONER_1, target)
        elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerDot" and Ready(SUMMONER_1) and self.Menu.Activator.Summoners.IgniteHP:Value() / 100 >= target.health/target.maxHealth
          and myHero.pos:DistanceTo(target.pos) < 600 then
          Control.CastSpell(HK_SUMMONER_2, target)
        end
      end
    end

    if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" then

      if self.Menu.Activator.Summoners.Exh:Value() then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerExhaust" and Ready(SUMMONER_1) and self.Menu.Activator.Summoners.ExhaustHp:Value() / 100 >= target.health/target.maxHealth
          and myHero.pos:DistanceTo(target.pos) < 650 then
          Control.CastSpell(HK_SUMMONER_1, target)
        elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerExhaust" and Ready(SUMMONER_1) and self.Menu.Activator.Summoners.ExhaustHp:Value() / 100 >= target.health/target.maxHealth
          and myHero.pos:DistanceTo(target.pos) < 650 then
          Control.CastSpell(HK_SUMMONER_2, target)
        end
      end
    end


    if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" then

      if self.Menu.Activator.Summoners.Heal:Value() then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerHeal" and Ready(SUMMONER_1) and PercentHP(myHero) < self.Menu.Activator.Summoners.HealHP:Value() then
          Control.CastSpell(HK_SUMMONER_1)
        elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerHeal" and Ready(SUMMONER_1) and PercentHP(myHero) < self.Menu.Activator.Summoners.HealHP:Value() then
          Control.CastSpell(HK_SUMMONER_2)
        end
      end
    end

    if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" then

      if self.Menu.Activator.Summoners.Barrier:Value() then
        if myHero:GetSpellData(SUMMONER_1).name == "SummonerBarrier" and Ready(SUMMONER_1) and PercentHP(myHero) < self.Menu.Activator.Summoners.BarrierHP:Value() then
          Control.CastSpell(HK_SUMMONER_1)
        elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBarrier" and Ready(SUMMONER_1) and PercentHP(myHero) < self.Menu.Activator.Summoners.BarrierHP:Value() then
          Control.CastSpell(HK_SUMMONER_2)
        end
      end
    end

    if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost"
      or myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" then

      if self.Menu.Activator.Summoners.Cleanse:Value() then
        for i = 0, myHero.buffCount do
          local buff = myHero:GetBuff(i);
          if buff.count > 0 then
            if ((buff.type == 5 and self.Menu.Activator.Summoners.Stun:Value())
              or (buff.type == 7 and  self.Menu.Activator.Summoners.Silence:Value())
              or (buff.type == 8 and  self.Menu.Activator.Summoners.Taunt:Value())
              or (buff.type == 9 and  self.Menu.Activator.Summoners.Poly:Value())
              or (buff.type == 10 and  self.Menu.Activator.Summoners.Slow:Value())
              or (buff.type == 11 and  self.Menu.Activator.Summoners.Root:Value())
              or (buff.type == 21 and  self.Menu.Activator.Summoners.Flee:Value())
              or (buff.type == 22 and  self.Menu.Activator.Summoners.Charm:Value())
              or (buff.type == 25 and  self.Menu.Activator.Summoners.Blind:Value())
              or (buff.type == 28 and  self.Menu.Activator.Summoners.Flee:Value())) then
              if myHero:GetSpellData(SUMMONER_1).name == "SummonerBoost" and Ready(SUMMONER_1) then
                Control.CastSpell(HK_SUMMONER_1)
              elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerBoost" and Ready(SUMMONER_2) then
                Control.CastSpell(HK_SUMMONER_2)
              end
            end
          end
        end
      end
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
end
---------------------------------------------------------------------------------------------------------------------------------------------------

function Ryze:Activator()
  local target = GetTarget(2500)
  local items = {}
  for slot = ITEM_1,ITEM_6 do
    local id = myHero:GetItemData(slot).itemID
    if id > 0 then
      items[id] = slot
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --PASSIVE ACTIVATOR
  local Potion = items[2003] or items[2010] or items[2031] or items[2032] or items[2033] -- ALl potions
  if Potion and self.Menu.Activator.Potions.Pot:Value() then
    if myHero:GetSpellData(Potion).currentCd == 0 and NoPotion()  then
      if PercentHP(myHero) < self.Menu.Activator.Potions.HP:Value() then
        Control.CastSpell(HKITEM[Potion])
      end
    end
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
  --COMBO MODE ACTIVATOR
  if target == nil then return end
  if GetMode() == "Combo" then
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    local YGB = items[3142] -- Ghostblade
    if YGB then
      if self.Menu.Activator.Items.YG:Value() and myHero:GetSpellData(YGB).currentCd == 0 then
        if myHero.pos:DistanceTo(target.pos) <= self.Menu.Activator.Items.YGS.ED:Value() then
          Control.CastSpell(HKITEM[YGB])
        end
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------

    local TIA = items[3077] --Tiamat
    local HYD = items[3074] --Rav Hydra
    local TIT = items[3748] -- Tit Hydra
    if HYD then
      if self.Menu.Activator.Items.HYD:Value() and myHero:GetSpellData(HYD).currentCd == 0 then
        if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.attackData.state == STATE_WINDDOWN then
          Control.CastSpell(HKITEM[HYD])
        end
      end
    end
    if TIA then
      if self.Menu.Activator.Items.TIA:Value() and myHero:GetSpellData(TIA).currentCd == 0 then
        if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.attackData.state == STATE_WINDDOWN then
          Control.CastSpell(HKITEM[TIA])
        end
      end
    end
    if TIT then
      if self.Menu.Activator.Items.TIT:Value() and myHero:GetSpellData(TIT).currentCd == 0 then
        if myHero.pos:DistanceTo(target.pos) <= 400 and myHero.attackData.state == STATE_WINDDOWN then
          Control.CastSpell(HKITEM[TIT])
        end
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------
    local QSS = items[3140] or items[3139] --QSS - Scimitar
    if QSS then
      if self.Menu.Activator.Items.QSS:Value() and myHero:GetSpellData(QSS).currentCd == 0 then
        for i = 0, myHero.buffCount do
          local buff = myHero:GetBuff(i);
          if buff.count > 0 then
            if ((buff.type == 5 and self.Menu.Activator.Items.QSSS.Stun:Value())
              or (buff.type == 7 and  self.Menu.Activator.Items.QSSS.Silence:Value())
              or (buff.type == 8 and  self.Menu.Activator.Items.QSSS.Taunt:Value())
              or (buff.type == 9 and  self.Menu.Activator.Items.QSSS.Poly:Value())
              or (buff.type == 10 and  self.Menu.Activator.Items.QSSS.Slow:Value())
              or (buff.type == 11 and  self.Menu.Activator.Items.QSSS.Root:Value())
              or (buff.type == 21 and  self.Menu.Activator.Items.QSSS.Flee:Value())
              or (buff.type == 22 and  self.Menu.Activator.Items.QSSS.Charm:Value())
              or (buff.type == 25 and  self.Menu.Activator.Items.QSSS.Blind:Value())
              or (buff.type == 28 and  self.Menu.Activator.Items.QSSS.Flee:Value())) then
              Control.CastSpell(HKITEM[QSS])
            end
          end
        end
      end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------------------
  end
  ---------------------------------------------------------------------------------------------------------------------------------------------------
end
---------------------------------------------------------------------------------------------------------------------------------------------------
function OnLoad()
  Ryze()
end
---------------------------------------------------------------------------------------------------------------------------------------------------
