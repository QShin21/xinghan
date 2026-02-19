-- SPDX-License-Identifier: GPL-3.0-or-later
-- 韩遂 - 骁袭技能
-- 你可以将一张黑色牌当【杀】使用或打出。

local xiaoxi = fk.CreateSkill {
  name = "xh__xiaoxi",
}

Fk:loadTranslationTable {
  ["xh__xiaoxi"] = "骁袭",
  [":xh__xiaoxi"] = "你可以将一张黑色牌当【杀】使用或打出。",

  ["$xh__xiaoxi1"] = "骁袭敌阵，势不可挡！",
  ["$xh__xiaoxi2"] = "西凉骁骑，袭敌千里！",
}

xiaoxi:addEffect("viewas", {
  mute = true,
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return Fk:getCardById(to_select).color == Card.Black
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
  enabled_at_response = function(self, player, response)
    return not response
  end,
})

return xiaoxi
