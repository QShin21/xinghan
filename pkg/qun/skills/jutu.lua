-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘璋 - 据土技能
-- 锁定技，准备阶段，你获得所有你武将牌上的"生"，然后摸一张牌，
-- 然后将X张牌置于你的武将牌上，称之为"生"（X为你"邀虎"选择势力的角色数量）

local jutu = fk.CreateSkill {
  name = "jutu",
}

Fk:loadTranslationTable {
  ["jutu"] = "据土",
  [":jutu"] = "锁定技，准备阶段，你获得所有你武将牌上的\"生\"，然后摸一张牌，"..
    "然后将X张牌置于你的武将牌上，称之为\"生\"（X为你\"邀虎\"选择势力的角色数量）",

  ["@@jutu_sheng"] = "生",

  ["$jutu1"] = "据土益州，保境安民！",
  ["$jutu2"] = "刘璋据土，益州太平！",
}

jutu:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(jutu.name) then return false end
    if player.phase ~= Player.Start then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 获得所有"生"
    local sheng = player:getMark("@@jutu_sheng") or {}
    if type(sheng) == "table" and #sheng > 0 then
      room:moveCardTo(sheng, Player.Hand, player, fk.ReasonPrey, jutu.name)
      room:setPlayerMark(player, "@@jutu_sheng", 0)
    end
    
    -- 摸一张牌
    player:drawCards(1, jutu.name)
    
    -- 计算X
    local x = player:getMark("@@yaohu_count") or 0
    if x == 0 then x = 1 end
    
    -- 置X张牌为"生"
    if not player:isNude() then
      local cards = room:askToCards(player, {
        min_num = math.min(x, player:getCardIds("he")),
        max_num = math.min(x, player:getCardIds("he")),
        include_equip = true,
        skill_name = jutu.name,
        pattern = ".",
        prompt = "选择" .. math.min(x, player:getCardIds("he")) .. "张牌置为生",
        cancelable = false,
      })
      
      local new_sheng = {}
      for _, id in ipairs(cards) do
        table.insert(new_sheng, id)
        room:moveCardTo(id, Card.Processing, player, fk.ReasonPut, jutu.name)
      end
      
      room:setPlayerMark(player, "@@jutu_sheng", new_sheng)
    end
  end,
})

return jutu
