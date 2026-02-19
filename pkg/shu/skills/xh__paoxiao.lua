-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张飞 - 咆哮技能
-- 锁定技，你使用【杀】无次数限制；
-- 当你使用的【杀】被【闪】抵消后，你本回合使用【杀】下一次造成伤害时，此伤害+1。

local paoxiao = fk.CreateSkill {
  name = "xh__paoxiao",
}

Fk:loadTranslationTable {
  ["xh__paoxiao"] = "咆哮",
  [":xh__paoxiao"] = "锁定技，你使用【杀】无次数限制；"..
    "当你使用的【杀】被【闪】抵消后，你本回合使用【杀】下一次造成伤害时，此伤害+1。",

  ["@@xh__paoxiao_damage"] = "咆哮",

  ["$xh__paoxiao1"] = "啊啊啊啊！",
  ["$xh__paoxiao2"] = "燕人张飞在此！",
}

-- 无次数限制
paoxiao:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if player:hasSkill(paoxiao.name) and skill.trueName == "slash_skill" then
      return 999
    end
  end,
})

-- 被闪抵消后标记
paoxiao:addEffect(fk.CardEffectCancelledOut, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(paoxiao.name) and
      data.card and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@paoxiao_damage", 1)
  end,
})

-- 伤害+1
paoxiao:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(paoxiao.name) and
      data.card and data.card.trueName == "slash" and
      player:getMark("@@paoxiao_damage") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
    player.room:setPlayerMark(player, "@@paoxiao_damage", 0)
  end,
})

return paoxiao
