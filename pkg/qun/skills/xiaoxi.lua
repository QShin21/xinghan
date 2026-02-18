-- SPDX-License-Identifier: GPL-3.0-or-later
-- 韩遂 - 骁袭技能
-- 你可以将一张黑色牌当【杀】使用或打出。

local xiaoxi = fk.CreateSkill {
  name = "xiaoxi",
}

Fk:loadTranslationTable {
  ["xiaoxi"] = "骁袭",
  [":xiaoxi"] = "你可以将一张黑色牌当【杀】使用或打出。",

  ["$xiaoxi1"] = "骁勇善战，袭敌不备！",
  ["$xiaoxi2"] = "突袭敌阵，一击必中！",
}

xiaoxi:addEffect("viewas", {
  mute = true,
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.color == Card.Black
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("slash")
    card.skillName = xiaoxi.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:canUse(Fk:cloneCard("slash"))
  end,
  enabled_at_response = function(self, player)
    return true
  end,
})

return xiaoxi
