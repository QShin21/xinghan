-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭汜 - 贪狈技能
-- 出牌阶段限一次，你可以令一名其他角色选择一项：
-- 1.其交给你一张手牌，你此阶段不能再对其使用牌；
-- 2.令你此阶段对其使用牌无距离和次数限制。

local tanbei = fk.CreateSkill {
  name = "tanbei",
}

Fk:loadTranslationTable {
  ["tanbei"] = "贪狈",
  [":tanbei"] = "出牌阶段限一次，你可以令一名其他角色选择一项："..
    "1.其交给你一张手牌，你此阶段不能再对其使用牌；"..
    "2.令你此阶段对其使用牌无距离和次数限制。",

  ["#tanbei-target"] = "贪狈：选择一名其他角色",
  ["tanbei_give"] = "交给一张手牌",
  ["tanbei_unlimit"] = "令其使用牌无距离和次数限制",
  ["@@tanbei_forbid"] = "贪狈禁止",
  ["@@tanbei_unlimit"] = "贪狈",

  ["$tanbei1"] = "贪狈之性，得寸进尺！",
  ["$tanbei2"] = "贪得无厌，狈行天下！",
}

tanbei:addEffect("active", {
  mute = true,
  prompt = "#tanbei-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(tanbei.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, tanbei.name, "control", {target})
    player:broadcastSkillInvoke(tanbei.name)

    local choice
    if target:isKongcheng() then
      choice = "tanbei_unlimit"
    else
      choice = room:askToChoice(target, {
        choices = {"tanbei_give", "tanbei_unlimit"},
        skill_name = tanbei.name,
        prompt = "选择一项",
        detailed = false,
      })
    end
    
    if choice == "tanbei_give" then
      -- 交给一张手牌
      local id = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = tanbei.name,
        pattern = ".",
        prompt = "选择一张手牌交给" .. player.name,
        cancelable = false,
      })
      room:moveCardTo(id[1], Player.Hand, player, fk.ReasonGive, tanbei.name, nil, false, target.id)
      
      -- 此阶段不能再对其使用牌
      room:setPlayerMark(player, "@@tanbei_forbid_" .. target.id, 1)
    else
      -- 此阶段对其使用牌无距离和次数限制
      room:setPlayerMark(player, "@@tanbei_unlimit_" .. target.id, 1)
    end
  end,
})

-- 不能使用牌
tanbei:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from:getMark("@@tanbei_forbid_" .. to.id) > 0 then
      return true
    end
    return false
  end,
})

-- 无距离和次数限制
tanbei:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    if player:getMark("@@tanbei_unlimit_" .. to.id) > 0 then
      return true
    end
    return false
  end,
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" then
      for _, p in ipairs(player.room.alive_players) do
        if player:getMark("@@tanbei_unlimit_" .. p.id) > 0 then
          return 999
        end
      end
    end
    return 0
  end,
})

-- 回合结束清除标记
tanbei:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    for _, p in ipairs(player.room.alive_players) do
      if player:getMark("@@tanbei_forbid_" .. p.id) > 0 or
        player:getMark("@@tanbei_unlimit_" .. p.id) > 0 then
        return true
      end
    end
    return false
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(room.alive_players) do
      room:setPlayerMark(player, "@@tanbei_forbid_" .. p.id, 0)
      room:setPlayerMark(player, "@@tanbei_unlimit_" .. p.id, 0)
    end
  end,
})

return tanbei
