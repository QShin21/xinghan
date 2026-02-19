-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关羽(魏) - 武圣技能
-- 你的红色牌可以当作【杀】使用或打出；你使用♢【杀】无距离限制。

local wusheng = fk.CreateSkill {
  name = "xh__wusheng",
}

Fk:loadTranslationTable {
  ["xh__wusheng"] = "武圣",
  [":xh__wusheng"] = "你的红色牌可以当作【杀】使用或打出；你使用♢【杀】无距离限制。",

  ["$xh__wusheng1"] = "武圣关公，义薄云天！",
  ["$xh__wusheng2"] = "关公武圣，天下无双！",
}

wusheng:addEffect("viewas", {
  mute = true,
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return Fk:getCardById(to_select).color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("slash")
    card.skillName = xh__wusheng.name
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

-- 方片杀无距离限制
wusheng:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    if skill.trueName == "slash_skill" and card and card.suit == Card.Diamond then
      return true
    end
    return false
  end,
})

return wusheng
