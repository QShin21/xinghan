-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄月英 - 奇才技能
-- 锁定技，你使用锦囊牌无距离限制；对方不能弃置你装备区里的防具牌。

local qicai = fk.CreateSkill {
  name = "xh__qicai",
}

Fk:loadTranslationTable {
  ["xh__qicai"] = "奇才",
  [":xh__qicai"] = "锁定技，你使用锦囊牌无距离限制；对方不能弃置你装备区里的防具牌。",

  ["$xh__qicai1"] = "奇才妙计，巧夺天工！",
  ["$xh__qicai2"] = "才智过人，非同凡响！",
}

-- 使用锦囊牌无距离限制
qicai:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(xh__qicai.name) and card and card.type == Card.TypeTrick
  end,
})

-- 对方不能弃置你装备区里的防具牌
qicai:addEffect("prohibit", {
  prohibit_discard = function(self, player, card)
    if not player:hasSkill(xh__qicai.name) then return false end
    if card.sub_type ~= Card.SubtypeArmor then return false end
    if not table.contains(player:getCardIds("e"), card.id) then return false end
    return true
  end,
})

return qicai
