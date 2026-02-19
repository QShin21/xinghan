-- SPDX-License-Identifier: GPL-3.0-or-later
-- 貂蝉 - 闭月技能
-- 结束阶段，你可以摸一张牌，若你本回合未造成过伤害，则改为摸两张牌。

local biyue = fk.CreateSkill {
  name = "xh__biyue",
}

Fk:loadTranslationTable {
  ["xh__biyue"] = "闭月",
  [":xh__biyue"] = "结束阶段，你可以摸一张牌，若你本回合未造成过伤害，则改为摸两张牌。",

  ["#xh__biyue-invoke"] = "闭月：摸一张牌（若本回合未造成伤害则摸两张）",

  ["$xh__biyue1"] = "夫君，我要……",
  ["$xh__biyue2"] = "失礼了……",
}

biyue:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__biyue.name) and
      player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__biyue.name,
      prompt = "#biyue-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 检查本回合是否造成过伤害
    local has_damage = player:getMark("@@biyue_damage") > 0

    if has_damage then
      -- 造成过伤害：摸一张牌
      player:drawCards(1, xh__biyue.name)
    else
      -- 未造成伤害：摸两张牌
      player:drawCards(2, xh__biyue.name)
    end
    
    -- 清除标记
    room:setPlayerMark(player, "@@biyue_damage", 0)
  end,
})

-- 记录是否造成过伤害
biyue:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__biyue.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@biyue_damage", 1)
  end,
})

return biyue
