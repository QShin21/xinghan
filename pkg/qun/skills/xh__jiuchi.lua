-- SPDX-License-Identifier: GPL-3.0-or-later
-- 董卓 - 酒池技能
-- 你可以将一张♤手牌当【酒】使用。

local jiuchi = fk.CreateSkill {
  name = "xh__jiuchi",
}

Fk:loadTranslationTable {
  ["xh__jiuchi"] = "酒池",
  [":xh__jiuchi"] = "你可以将一张♤手牌当【酒】使用。",

  ["$xh__jiuchi1"] = "美酒佳酿，畅饮不醉！",
  ["$xh__jiuchi2"] = "好酒，好酒！",
}

jiuchi:addEffect("viewas", {
  mute = true,
  pattern = "analeptic",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.suit == Card.Spade and player:getCardIds("h")[1] == to_select
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("analeptic")
    card.skillName = jiuchi.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:canUse(Fk:cloneCard("analeptic"))
  end,
  enabled_at_response = function(self, player)
    return true
  end,
})

return jiuchi
