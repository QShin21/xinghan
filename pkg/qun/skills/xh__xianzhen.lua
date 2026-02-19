-- SPDX-License-Identifier: GPL-3.0-or-later
-- 高顺 - 陷阵技能
-- 出牌阶段限一次，你可以与一名角色拼点：若你赢，本回合你无视其防具且对其使用【杀】无距离和次数限制；
-- 若你没赢，本回合你不能使用【杀】。

local xianzhen = fk.CreateSkill {
  name = "xh__xianzhen",
}

Fk:loadTranslationTable {
  ["xh__xianzhen"] = "陷阵",
  [":xh__xianzhen"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，本回合你无视其防具且对其使用【杀】无距离和次数限制；"..
    "若你没赢，本回合你不能使用【杀】。",

  ["#xh__xianzhen-choose"] = "陷阵：选择一名角色进行拼点",
  ["@@xh__xianzhen_target"] = "陷阵目标",
  ["@@xh__xianzhen_no_slash"] = "陷阵禁止杀",

  ["$xh__xianzhen1"] = "陷阵之志，有死无生！",
  ["$xh__xianzhen2"] = "高顺陷阵，天下无双！",
}

xianzhen:addEffect("active", {
  mute = true,
  prompt = "#xianzhen-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__xianzhen.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, xh__xianzhen.name, "offensive", {target})
    player:broadcastSkillInvoke(xh__xianzhen.name)

    local pindian = room:pindian({player, target}, xh__xianzhen.name)
    
    if pindian.results[player].winner then
      -- 你赢：无视防具，无距离和次数限制
      room:setPlayerMark(player, "@@xianzhen_target", target.id)
    else
      -- 你没赢：不能使用杀
      room:setPlayerMark(player, "@@xianzhen_no_slash", 1)
    end
  end,
})

-- 不能使用杀
xianzhen:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from:getMark("@@xianzhen_no_slash") > 0 and card.trueName == "slash" then
      return true
    end
    return false
  end,
})

-- 无视防具
xianzhen:addEffect("filter", {
  card_filter = function(self, card, player)
    local target_id = player:getMark("@@xianzhen_target")
    if target_id and target_id ~= 0 then
      return card.sub_type == Card.SubtypeArmor
    end
    return false
  end,
})

-- 无距离限制
xianzhen:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    local target_id = player:getMark("@@xianzhen_target")
    if target_id and target_id ~= 0 and skill.trueName == "slash_skill" then
      return true
    end
    return false
  end,
  residue_func = function(self, player, skill, scope, card)
    local target_id = player:getMark("@@xianzhen_target")
    if target_id and target_id ~= 0 and skill.trueName == "slash_skill" then
      return 999
    end
    return 0
  end,
})

-- 回合结束清除标记
xianzhen:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@xianzhen_target") ~= 0 or player:getMark("@@xianzhen_no_slash") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@xianzhen_target", 0)
    room:setPlayerMark(player, "@@xianzhen_no_slash", 0)
  end,
})

return xianzhen
