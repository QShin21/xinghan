-- SPDX-License-Identifier: GPL-3.0-or-later
-- 华雄 - 扬威技能
-- 出牌阶段限一次，你可以摸两张牌并令你本阶段：使用【杀】的次数上限+1、使用【杀】无距离限制且无视防具。
-- 若如此做，此技能失效，直到你下个回合的结束阶段。

local yangwei = fk.CreateSkill {
  name = "xh__yangwei",
}

Fk:loadTranslationTable {
  ["xh__yangwei"] = "扬威",
  [":xh__yangwei"] = "出牌阶段限一次，你可以摸两张牌并令你本阶段：使用【杀】的次数上限+1、使用【杀】无距离限制且无视防具。"..
    "若如此做，此技能失效，直到你下个回合的结束阶段。",

  ["#xh__yangwei-invoke"] = "扬威：是否摸两张牌并强化杀？",
  ["@@xh__yangwei_active"] = "扬威",

  ["$xh__yangwei1"] = "扬威天下，谁敢争锋！",
  ["$xh__yangwei2"] = "西凉华雄，威震天下！",
}

yangwei:addEffect("active", {
  mute = true,
  prompt = "#xh__yangwei-invoke",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(yangwei.name, Player.HistoryPhase) == 0 and
      player:getMark("@@yangwei_disabled") == 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, yangwei.name, "offensive")
    player:broadcastSkillInvoke(yangwei.name)

    -- 摸两张牌
    player:drawCards(2, yangwei.name)
    
    -- 设置标记
    room:setPlayerMark(player, "@@yangwei_active", 1)
    
    -- 技能失效
    room:setPlayerMark(player, "@@yangwei_disabled", 1)
  end,
})

-- 杀次数+1
yangwei:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" and player:getMark("@@yangwei_active") > 0 then
      return 1
    end
    return 0
  end,
})

-- 杀无距离限制
yangwei:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    if player:getMark("@@yangwei_active") > 0 and skill.trueName == "slash_skill" then
      return true
    end
    return false
  end,
})

-- 无视防具
yangwei:addEffect("filter", {
  card_filter = function(self, card, player)
    if player:getMark("@@yangwei_active") > 0 then
      return card.sub_type == Card.SubtypeArmor
    end
    return false
  end,
})

-- 回合结束清除标记
yangwei:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@yangwei_active") > 0 or player:getMark("@@yangwei_disabled") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@yangwei_active", 0)
    
    -- 如果是自己的回合结束，清除失效标记
    if player:getMark("@@yangwei_disabled") > 0 then
      room:setPlayerMark(player, "@@yangwei_disabled", 0)
    end
  end,
})

return yangwei
