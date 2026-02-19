-- SPDX-License-Identifier: GPL-3.0-or-later
-- 诸葛亮 - 看破技能
-- 你可以将一张黑色牌当【无懈可击】使用。

local kanpo = fk.CreateSkill {
  name = "kanpo",
}

Fk:loadTranslationTable {
  ["kanpo"] = "看破",
  [":kanpo"] = "你可以将一张黑色牌当【无懈可击】使用。",

  ["$kanpo1"] = "看破敌计，洞若观火！",
  ["$kanpo2"] = "此计已被我看破！",
}

kanpo:addEffect("viewas", {
  mute = true,
  pattern = "nullification",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return Fk:getCardById(to_select).color == Card.Black
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("nullification")
    card.skillName = kanpo.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player, response)
    return not response
  end,
})

return kanpo
