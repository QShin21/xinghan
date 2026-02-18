-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄月英 - 集智技能
-- 当你使用一张普通锦囊牌时，你可以摸一张牌；若此牌是基本牌，你可以弃置此牌然后本回合手牌上限+1。

local jizhi = fk.CreateSkill {
  name = "jizhi",
}

Fk:loadTranslationTable {
  ["jizhi"] = "集智",
  [":jizhi"] = "当你使用一张普通锦囊牌时，你可以摸一张牌；若此牌是基本牌，你可以弃置此牌然后本回合手牌上限+1。",

  ["#jizhi-invoke"] = "集智：你可以摸一张牌",
  ["#jizhi-discard"] = "集智：是否弃置此牌令本回合手牌上限+1？",
  ["@@jizhi_hand_limit"] = "集智",

  ["$jizhi1"] = "集智成谋，运筹帷幄！",
  ["$jizhi2"] = "智者千虑，必有一得！",
}

jizhi:addEffect(fk.CardUsing, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jizhi.name) and
      data.card and data.card.type == Card.TypeTrick
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jizhi.name,
      prompt = "#jizhi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, jizhi.name)
    
    -- 检查摸到的牌是否为基本牌
    local last_card = player:getCardIds("h")[#player:getCardIds("h")]
    if last_card and Fk:getCardById(last_card).type == Card.TypeBasic then
      if room:askToSkillInvoke(player, {
        skill_name = jizhi.name,
        prompt = "#jizhi-discard",
      }) then
        room:throwCard(last_card, jizhi.name, player, player)
        room:addPlayerMark(player, "@@jizhi_hand_limit", 1)
      end
    end
  end,
})

-- 手牌上限+1
jizhi:addEffect(fk.MaxCardsCalc, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@jizhi_hand_limit") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    data.num = data.num + player:getMark("@@jizhi_hand_limit")
  end,
})

-- 回合结束清除标记
jizhi:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@jizhi_hand_limit") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@jizhi_hand_limit", 0)
  end,
})

return jizhi
