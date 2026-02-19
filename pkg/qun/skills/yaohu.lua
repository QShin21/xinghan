-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘璋 - 邀虎技能
-- 每轮限一次，你的回合开始时，你须选择场上一个势力。
-- 被你选择势力的其他角色出牌阶段开始时，其获得你的一张"生"，
-- 然后其直到本阶段结束时，其使用伤害牌指定你为目标时，
-- 须交给你两张牌，否则取消之。

local yaohu = fk.CreateSkill {
  name = "yaohu",
}

Fk:loadTranslationTable {
  ["yaohu"] = "邀虎",
  [":yaohu"] = "每轮限一次，你的回合开始时，你须选择场上一个势力。"..
    "被你选择势力的其他角色出牌阶段开始时，其获得你的一张\"生\"，"..
    "然后其直到本阶段结束时，其使用伤害牌指定你为目标时，"..
    "须交给你两张牌，否则取消之。",

  ["#yaohu-choose"] = "邀虎：选择一个势力",
  ["@@yaohu_kingdom"] = "邀虎势力",
  ["@@yaohu_count"] = "邀虎计数",

  ["$yaohu1"] = "邀虎之计，借力打力！",
  ["$yaohu2"] = "刘璋邀虎，益州太平！",
}

yaohu:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yaohu.name) then return false end
    if player.phase ~= Player.Start then return false end
    if player:usedSkillTimes(yaohu.name, Player.HistoryRound) > 0 then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 统计场上势力
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      kingdoms[p.kingdom] = true
    end
    
    local kingdom_list = {}
    for k, _ in pairs(kingdoms) do
      table.insert(kingdom_list, k)
    end
    
    -- 选择势力
    local choice = room:askToChoice(player, {
      choices = kingdom_list,
      skill_name = yaohu.name,
      prompt = "#yaohu-choose",
      detailed = false,
    })
    
    room:setPlayerMark(player, "@@yaohu_kingdom", choice)
    
    -- 统计该势力角色数量
    local count = 0
    for _, p in ipairs(room.alive_players) do
      if p.kingdom == choice and p ~= player then
        count = count + 1
      end
    end
    room:setPlayerMark(player, "@@yaohu_count", count)
  end,
})

-- 出牌阶段开始时获得"生"
yaohu:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player or target.phase ~= Player.Play then return false end
    
    local source = player
    if not source:hasSkill(yaohu.name) then return false end
    
    local kingdom = source:getMark("@@yaohu_kingdom")
    if not kingdom or kingdom == 0 then return false end
    
    if target.kingdom ~= kingdom then return false end
    
    local sheng = source:getMark("@@jutu_sheng")
    return sheng and type(sheng) == "table" and #sheng > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local sheng = player:getMark("@@jutu_sheng")
    
    if #sheng > 0 then
      local id = table.remove(sheng, 1)
      room:moveCardTo(id, Player.Hand, target, fk.ReasonGive, yaohu.name, nil, false, player.id)
      room:setPlayerMark(player, "@@jutu_sheng", sheng)
      
      -- 标记该角色需要交牌
      room:setPlayerMark(target, "@@yaohu_give", player.id)
    end
  end,
})

-- 使用伤害牌指定目标时需要交牌
yaohu:addEffect(fk.TargetConfirming, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or not data.card.is_damage_card then return false end
    
    local source_id = player:getMark("@@yaohu_give")
    if not source_id or source_id == 0 then return false end
    
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local source = room:getPlayerById(player:getMark("@@yaohu_give"))
    
    -- 需要交给两张牌
    if player:getCardIds("he") >= 2 then
      local cards = room:askToCards(player, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = yaohu.name,
        pattern = ".",
        prompt = "选择两张牌交给" .. source.name .. "，否则此牌无效",
        cancelable = true,
      })
      
      if #cards == 2 then
        room:moveCardTo(cards, Player.Hand, source, fk.ReasonGive, yaohu.name, nil, false, player.id)
        return
      end
    end
    
    -- 取消之
    data:cancelTarget(player)
  end,
})

-- 回合结束清除标记
yaohu:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@yaohu_give") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@yaohu_give", 0)
  end,
})

return yaohu
