-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 肃军技能
-- 出牌阶段限一次，当你使用牌时，你可以展示所有手牌（无牌则跳过），
-- 若你的手牌中基本牌与非基本牌的数量相等，你摸两张牌。

local sujun = fk.CreateSkill {
  name = "sujun",
}

Fk:loadTranslationTable {
  ["sujun"] = "肃军",
  [":sujun"] = "出牌阶段限一次，当你使用牌时，你可以展示所有手牌（无牌则跳过），"..
    "若你的手牌中基本牌与非基本牌的数量相等，你摸两张牌。",

  ["#sujun-invoke"] = "肃军：你可以展示所有手牌，若基本牌与非基本牌数量相等，摸两张牌",

  ["$sujun1"] = "整军备战，严阵以待！",
  ["$sujun2"] = "军纪严明，不可懈怠！",
}

sujun:addEffect(fk.CardUsing, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(sujun.name) and
      player.phase == Player.Play and
      player:usedSkillTimes(sujun.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = sujun.name,
      prompt = "#sujun-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 无牌则跳过
    if player:isKongcheng() then return end

    -- 展示所有手牌
    local handcards = player:getCardIds("h")
    room:showCards(player, handcards, sujun.name)

    -- 计算基本牌和非基本牌数量
    local basic_count = 0
    local non_basic_count = 0

    for _, id in ipairs(handcards) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic then
        basic_count = basic_count + 1
      else
        non_basic_count = non_basic_count + 1
      end
    end

    -- 若数量相等，摸两张牌
    if basic_count == non_basic_count then
      player:drawCards(2, sujun.name)
    end
  end,
})

return sujun
