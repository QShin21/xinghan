-- SPDX-License-Identifier: GPL-3.0-or-later
-- 貂蝉 - 闭月技能
-- 结束阶段，你可以摸一张牌，若你本回合未造成过伤害，则改为摸两张牌。

local biyue = fk.CreateSkill {
  name = "biyue",
}

Fk:loadTranslationTable {
  ["biyue"] = "闭月",
  [":biyue"] = "结束阶段，你可以摸一张牌，若你本回合未造成过伤害，则改为摸两张牌。",

  ["#biyue-invoke"] = "闭月：摸一张牌（若本回合未造成伤害则摸两张）",

  ["$biyue1"] = "夫君，我要……",
  ["$biyue2"] = "失礼了……",
}

biyue:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(biyue.name) and
      player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = biyue.name,
      prompt = "#biyue-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 检查本回合是否造成过伤害
    local has_damage = player:hasFlag("biyue_damage")

    if has_damage then
      -- 造成过伤害：摸一张牌
      player:drawCards(1, biyue.name)
    else
      -- 未造成伤害：摸两张牌
      player:drawCards(2, biyue.name)
    end
  end,
})

-- 记录是否造成过伤害
biyue:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(biyue.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerFlag(player, "biyue_damage")
  end,
})

-- 回合开始清除标记
biyue:addEffect(fk.TurnStart, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasFlag("biyue_damage")
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerFlag(player, "-biyue_damage")
  end,
})

return biyue
