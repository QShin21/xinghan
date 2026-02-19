-- SPDX-License-Identifier: GPL-3.0-or-later
-- 诸葛亮 - 火计技能
-- 你可以将一张红色牌当【火攻】使用，你的【火攻】改为令目标展示随机手牌。

local huoji = fk.CreateSkill {
  name = "huoji",
}

Fk:loadTranslationTable {
  ["huoji"] = "火计",
  [":huoji"] = "你可以将一张红色牌当【火攻】使用，你的【火攻】改为令目标展示随机手牌。",

  ["$huoji1"] = "火计破敌，势不可挡！",
  ["$huoji2"] = "火烧连营，片甲不留！",
}

huoji:addEffect("viewas", {
  mute = true,
  pattern = "fire_attack",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("fire_attack")
    card.skillName = huoji.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:canUse(Fk:cloneCard("fire_attack"))
  end,
})

return huoji
