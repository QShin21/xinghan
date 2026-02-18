-- SPDX-License-Identifier: GPL-3.0-or-later
-- 华雄 - 扬威技能
-- 出牌阶段限一次，你可以摸两张牌并令你本阶段：
-- 使用【杀】的次数上限+1、使用【杀】无距离限制且无视防具。
-- 若如此做，此技能失效，直到你下个回合的结束阶段。

local yangwei = fk.CreateSkill {
  name = "yangwei",
}

Fk:loadTranslationTable {
  ["yangwei"] = "扬威",
  [":yangwei"] = "出牌阶段限一次，你可以摸两张牌并令你本阶段："..
    "使用【杀】的次数上限+1、使用【杀】无距离限制且无视防具。"..
    "若如此做，此技能失效，直到你下个回合的结束阶段。",

  ["#yangwei-invoke"] = "扬威：摸两张牌，本阶段杀次数+1、无距离限制、无视防具，技能暂时失效",
  ["@@yangwei_phase"] = "扬威",

  ["$yangwei1"] = "扬威沙场，谁敢来战！",
  ["$yangwei2"] = "威震天下，无人能敌！",
}

yangwei:addEffect("active", {
  mute = true,
  prompt = "#yangwei-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(yangwei.name, Player.HistoryPhase) == 0 and
      not player:hasSkill(yangwei.name, true)
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, yangwei.name, "offensive")
    player:broadcastSkillInvoke(yangwei.name)

    -- 摸两张牌
    player:drawCards(2, yangwei.name)

    -- 设置标记
    room:setPlayerMark(player, "@@yangwei_phase", 1)

    -- 技能暂时失效
    room:handleAddLoseSkills(player, "-" .. yangwei.name, nil, false, true)
  end,
})

-- 杀次数+1
yangwei:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if player:getMark("@@yangwei_phase") > 0 and skill.trueName == "slash_skill" then
      return 1
    end
  end,
  distance_limit_func = function(self, player, skill, scope, card)
    if player:getMark("@@yangwei_phase") > 0 and skill.trueName == "slash_skill" then
      return true
    end
  end,
})

-- 无视防具
yangwei:addEffect(fk.TargetSpecifying, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return player:getMark("@@yangwei_phase") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.yangwei_unequip = true
  end,
})

-- 回合结束恢复技能
yangwei:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@yangwei_phase") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@yangwei_phase", 0)
    room:handleAddLoseSkills(player, yangwei.name, nil, false, true)
  end,
})

return yangwei
