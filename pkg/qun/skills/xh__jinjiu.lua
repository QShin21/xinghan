-- SPDX-License-Identifier: GPL-3.0-or-later
-- 高顺 - 禁酒技能
-- 锁定技，你的【酒】和你判定牌的【酒】视为点数为K的【杀】；
-- 你的回合内，其他角色不能使用【酒】。

local jinjiu = fk.CreateSkill {
  name = "xh__jinjiu",
}

Fk:loadTranslationTable {
  ["xh__jinjiu"] = "禁酒",
  [":xh__jinjiu"] = "锁定技，你的【酒】和你判定牌的【酒】视为点数为K的【杀】；"..
    "你的回合内，其他角色不能使用【酒】。",

  ["$xh__jinjiu1"] = "禁酒令下，滴酒不沾！",
  ["$xh__jinjiu2"] = "军中禁酒，违者必究！",
}

-- 酒视为杀
jinjiu:addEffect("filter", {
  mute = true,
  card_filter = function(self, card, player)
    if not player:hasSkill(jinjiu.name) then return false end
    if card.trueName ~= "analeptic" then return false end
    return true
  end,
  card_change = function(self, card, player)
    local slash = Fk:cloneCard("slash")
    slash.number = 13  -- K = 13
    return slash
  end,
})

-- 其他角色不能使用酒
jinjiu:addEffect("prohibit", {
  mute = true,
  prohibit_use = function(self, player, card)
    if not player.room.current:hasSkill(jinjiu.name) then return false end
    if player == player.room.current then return false end
    return card.trueName == "analeptic"
  end,
})

return jinjiu
