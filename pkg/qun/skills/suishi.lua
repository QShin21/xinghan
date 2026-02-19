-- SPDX-License-Identifier: GPL-3.0-or-later
-- 田丰 - 随势技能
-- 锁定技，当其他角色进入濒死状态时，若伤害来源与你势力相同，你摸一张牌；
-- 当其他角色死亡时，若其与你势力相同，你弃置至少一张手牌。

local suishi = fk.CreateSkill {
  name = "suishi",
}

Fk:loadTranslationTable {
  ["suishi"] = "随势",
  [":suishi"] = "锁定技，当其他角色进入濒死状态时，若伤害来源与你势力相同，你摸一张牌；"..
    "当其他角色死亡时，若其与你势力相同，你弃置至少一张手牌。",

  ["#suishi-discard"] = "随势：弃置至少一张手牌",

  ["$suishi1"] = "随势而动，顺势而为！",
  ["$suishi2"] = "势之所趋，不得不从！",
}

-- 进入濒死状态时摸牌
suishi:addEffect(fk.EnterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(suishi.name) and target ~= player and
      data.damageFrom and data.damageFrom.kingdom == player.kingdom
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, suishi.name)
  end,
})

-- 死亡时弃牌
suishi:addEffect(fk.Death, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(suishi.name) and target ~= player and
      target.kingdom == player.kingdom and not player:isKongcheng()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = player:getHandcardNum(),
      include_equip = false,
      skill_name = suishi.name,
      pattern = ".",
      prompt = "#suishi-discard",
      cancelable = false,
    })

    room:throwCard(cards, suishi.name, player, player)
  end,
})

return suishi
