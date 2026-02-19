-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄盖 - 诈降技能
-- 锁定技，当你失去1点体力后，你摸三张牌，然后若此时为你的出牌阶段，
-- 则此阶段你使用【杀】的次数上限+1、此阶段你使用红色【杀】无距离限制且不能被【闪】响应。

local zhaxiang = fk.CreateSkill {
  name = "xh__zhaxiang",
}

Fk:loadTranslationTable {
  ["xh__zhaxiang"] = "诈降",
  [":xh__zhaxiang"] = "锁定技，当你失去1点体力后，你摸三张牌，然后若此时为你的出牌阶段，"..
    "则此阶段你使用【杀】的次数上限+1、此阶段你使用红色【杀】无距离限制且不能被【闪】响应。",

  ["@@xh__zhaxiang_slash"] = "诈降",

  ["$xh__zhaxiang1"] = "诈降之计，苦肉为名！",
  ["$xh__zhaxiang2"] = "苦肉计成，诈降破敌！",
}

zhaxiang:addEffect(fk.HpLost, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__zhaxiang.name) and data.num > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 摸三张牌
    player:drawCards(3, xh__zhaxiang.name)
    
    -- 如果是出牌阶段
    if player.phase == Player.Play then
      room:addPlayerMark(player, "@@zhaxiang_slash", 1)
    end
  end,
})

-- 杀次数+1
zhaxiang:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" and player:getMark("@@zhaxiang_slash") > 0 then
      return player:getMark("@@zhaxiang_slash")
    end
    return 0
  end,
})

-- 红色杀无距离限制
zhaxiang:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    if player:hasSkill(xh__zhaxiang.name) and player.phase == Player.Play and
      card and card.trueName == "slash" and card.color == Card.Red then
      return true
    end
    return false
  end,
})

-- 回合结束清除标记
zhaxiang:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@zhaxiang_slash") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zhaxiang_slash", 0)
  end,
})

return zhaxiang
