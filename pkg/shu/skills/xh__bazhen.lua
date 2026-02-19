-- SPDX-License-Identifier: GPL-3.0-or-later
-- 诸葛亮 - 八阵技能
-- 锁定技，当你装备区没有防具牌时，视为你拥有防具【八卦阵】的效果。

local bazhen = fk.CreateSkill {
  name = "xh__bazhen",
}

Fk:loadTranslationTable {
  ["xh__bazhen"] = "八阵",
  [":xh__bazhen"] = "锁定技，当你装备区没有防具牌时，视为你拥有防具【八卦阵】的效果。",

  ["$xh__bazhen1"] = "八阵图成，万夫莫开！",
  ["$xh__bazhen2"] = "八卦阵中，生门何在？",
}

-- 当没有防具时视为拥有八卦阵效果
bazhen:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player)
    if not player:hasSkill(bazhen.name) then return false end
    if card.trueName ~= "jink" then return false end
    return true
  end,
  handly_cards = function(self, player)
    if not player:hasSkill(bazhen.name) then return nil end
    -- 检查是否有防具
    if #player:getCardIds("e", Card.SubtypeArmor) > 0 then return nil end
    -- 返回八卦阵的虚拟牌
    return {}
  end,
})

return bazhen
