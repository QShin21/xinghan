-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄月英 - 奇才技能
-- 锁定技，你使用锦囊牌无距离限制；对方不能弃置你装备区里的防具牌。

local qicai = fk.CreateSkill {
  name = "qicai",
}

Fk:loadTranslationTable {
  ["qicai"] = "奇才",
  [":qicai"] = "锁定技，你使用锦囊牌无距离限制；对方不能弃置你装备区里的防具牌。",

  ["$qicai1"] = "奇才妙计，巧夺天工！",
  ["$qicai2"] = "才智过人，非同凡响！",
}

-- 使用锦囊牌无距离限制
qicai:addEffect("targetmod", {
  bypass_distances = function(self, player, skill, card, to)
    return player:hasSkill(qicai.name) and card and card.type == Card.TypeTrick
  end,
})

-- 对方不能弃置你装备区里的防具牌
qicai:addEffect("prohibit", {
  prohibit_discard = function(self, player, card)
    if not player:hasSkill(qicai.name) then return false end
    if card.sub_type ~= Card.SubtypeArmor then return false end
    if not table.contains(player:getCardIds("e"), card.id) then return false end
    return true
  end,
})

return qicai
