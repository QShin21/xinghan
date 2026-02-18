-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄盖 - 诈降技能
-- 锁定技，当你失去1点体力后，你摸三张牌，然后若此时为你的出牌阶段，
-- 则此阶段你使用【杀】的次数上限+1、此阶段你使用红色【杀】无距离限制且不能被【闪】响应。

local zhaxiang = fk.CreateSkill {
  name = "zhaxiang",
}

Fk:loadTranslationTable {
  ["zhaxiang"] = "诈降",
  [":zhaxiang"] = "锁定技，当你失去1点体力后，你摸三张牌，然后若此时为你的出牌阶段，"..
    "则此阶段你使用【杀】的次数上限+1、此阶段你使用红色【杀】无距离限制且不能被【闪】响应。",

  ["@@zhaxiang_phase"] = "诈降",

  ["$zhaxiang1"] = "铁索连环，火烧赤壁！",
  ["$zhaxiang2"] = "诈降之计，已成功矣！",
}

zhaxiang:addEffect(fk.HpLost, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhaxiang.name) and data.num > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 摸三张牌
    player:drawCards(3, zhaxiang.name)

    -- 若为出牌阶段，设置标记
    if player.phase == Player.Play then
      room:addPlayerMark(player, "@@zhaxiang_phase", 1)
    end
  end,
})

-- 杀次数+1
zhaxiang:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if player:getMark("@@zhaxiang_phase") > 0 and skill.trueName == "slash_skill" then
      return player:getMark("@@zhaxiang_phase")
    end
  end,
})

-- 红色杀无距离限制且不能被闪响应
zhaxiang:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local card = data.card
    if not card or card.trueName ~= "slash" then return false end
    if player:getMark("@@zhaxiang_phase") == 0 then return false end
    return card.color == Card.Red
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.zhaxiang_no_distance = true
    data.extra_data.zhaxiang_unrespondable = true
  end,
})

-- 无距离限制
zhaxiang:addEffect(fk.TargetSpecifying, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local extra_data = data.extra_data or {}
    return extra_data.zhaxiang_no_distance
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.bypass_distances = true
  end,
})

-- 不能被闪响应
zhaxiang:addEffect(fk.CardEffectCancelledOut, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local extra_data = data.extra_data or {}
    return extra_data.zhaxiang_unrespondable
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.unresponseable = true
  end,
})

-- 回合结束清除标记
zhaxiang:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@zhaxiang_phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zhaxiang_phase", 0)
  end,
})

return zhaxiang
