-- SPDX-License-Identifier: GPL-3.0-or-later
-- 夏侯惇 - 清俭技能
-- 每回合限一次，当你于你的摸牌阶段外获得牌后，你可以展示任意张牌并将这些牌交给一名其他角色，
-- 然后当前回合角色本回合的手牌上限+X（X为你以此法交给其他角色的牌的类别数）。

local qingjian = fk.CreateSkill {
  name = "qingjian",
}

Fk:loadTranslationTable {
  ["qingjian"] = "清俭",
  [":qingjian"] = "每回合限一次，当你于你的摸牌阶段外获得牌后，你可以展示任意张牌并将这些牌交给一名其他角色，"..
    "然后当前回合角色本回合的手牌上限+X（X为你以此法交给其他角色的牌的类别数）。",

  ["#qingjian-ask"] = "清俭：你可以展示任意张牌交给一名其他角色",
  ["#qingjian-give"] = "清俭：选择要交给 %dest 的牌",

  ["$qingjian1"] = "俭而有度，志在千里！",
  ["$qingjian2"] = "戒奢宁俭，以聚军心！",
}

qingjian:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(qingjian.name) and player:usedEffectTimes(qingjian.name, Player.HistoryTurn) == 0 and
      player.phase ~= Player.Draw and not player:isKongcheng() then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and move.skillName ~= qingjian.name then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 999,
      include_equip = false,
      skill_name = qingjian.name,
      prompt = "#qingjian-ask",
      cancelable = true,
    })
    if #cards > 0 then
      local targets = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = room:getOtherPlayers(player, false),
        skill_name = qingjian.name,
        prompt = "#qingjian-give",
        cancelable = true,
      })
      if #targets > 0 then
        event:setCostData(self, {cards = cards, tos = targets})
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    local to = event:getCostData(self).tos[1]

    -- 展示牌
    room:showCards(player, cards, qingjian.name)

    -- 将牌交给目标
    room:moveCardTo(cards, Player.Hand, to, fk.ReasonGive, qingjian.name, nil, false, player.id)

    -- 计算牌的类别数
    local types = {}
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      if not table.contains(types, card.type) then
        table.insert(types, card.type)
      end
    end

    -- 当前回合角色本回合的手牌上限+X
    local current_player = room.current
    if current_player and #types > 0 then
      room:addPlayerMark(current_player, "@@qingjian_max_cards", #types)
    end
  end,
})

-- 手牌上限增加
qingjian:addEffect(fk.MaxCardsCalc, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@qingjian_max_cards") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = data.num + player:getMark("@@qingjian_max_cards")
  end,
})

-- 回合结束时清除标记
qingjian:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@qingjian_max_cards") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@qingjian_max_cards", 0)
  end,
})

return qingjian
