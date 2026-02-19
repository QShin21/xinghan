-- SPDX-License-Identifier: GPL-3.0-or-later
-- 周瑜 - 反间技能
-- 出牌阶段限一次，你可以展示并交给对手一张手牌并令其本回合非锁定技失效，
-- 其选择一项：1.展示所有手牌，然后弃置与此牌花色相同的所有牌（至少两张）；
-- 2.失去1点体力。

local fanjian = fk.CreateSkill {
  name = "fanjian",
}

Fk:loadTranslationTable {
  ["fanjian"] = "反间",
  [":fanjian"] = "出牌阶段限一次，你可以展示并交给对手一张手牌并令其本回合非锁定技失效，"..
    "其选择一项：1.展示所有手牌，然后弃置与此牌花色相同的所有牌（至少两张）；2.失去1点体力。",

  ["#fanjian-use"] = "反间：选择一张手牌交给对手",
  ["#fanjian-choice"] = "反间：选择一项",
  ["fanjian_discard"] = "展示手牌并弃置同花色牌",
  ["fanjian_damage"] = "失去1点体力",

  ["$fanjian1"] = "反间之计，谁能识破？",
  ["$fanjian2"] = "此计名为反间，实则离间！",
}

fanjian:addEffect("active", {
  mute = true,
  prompt = "#fanjian-use",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(fanjian.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("h"), to_select)
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local card_id = effect.cards[1]

    room:notifySkillInvoked(player, fanjian.name, "control", {target})
    player:broadcastSkillInvoke(fanjian.name)

    -- 展示并交给对手
    local card = Fk:getCardById(card_id)
    room:showCards(player, {card_id}, fanjian.name)
    room:moveCardTo(card_id, Player.Hand, target, fk.ReasonGive, fanjian.name, nil, false, player.id)

    -- 令其非锁定技失效
    room:addPlayerMark(target, "@@fanjian_disable", 1)

    -- 选择
    local choice
    if target:isKongcheng() then
      choice = "fanjian_damage"
    else
      local suit = card.suit
      local has_suit = table.find(target:getCardIds("h"), function(id)
        return Fk:getCardById(id).suit == suit
      end)
      
      if has_suit then
        choice = room:askToChoice(target, {
          choices = {"fanjian_discard", "fanjian_damage"},
          skill_name = fanjian.name,
          prompt = "#fanjian-choice",
          detailed = false,
        })
      else
        choice = "fanjian_damage"
      end
    end

    if choice == "fanjian_discard" then
      -- 展示所有手牌
      local handcards = target:getCardIds("h")
      room:showCards(target, handcards, fanjian.name)
      
      -- 弃置同花色牌
      local suit = card.suit
      local to_discard = table.filter(handcards, function(id)
        return Fk:getCardById(id).suit == suit
      end)
      
      if #to_discard >= 2 then
        room:throwCard(to_discard, fanjian.name, target, player)
      end
    else
      room:loseHp(target, 1, fanjian.name)
    end
  end,
})

-- 回合结束清除标记
fanjian:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@fanjian_disable") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@fanjian_disable", 0)
  end,
})

return fanjian
