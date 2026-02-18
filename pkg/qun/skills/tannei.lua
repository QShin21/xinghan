-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭汜 - 贪狈技能
-- 出牌阶段限一次，你可以令一名其他角色选择一项：
-- 1. 其交给你一张手牌，你此阶段不能再对其使用牌；
-- 2. 令你此阶段对其使用牌无距离和次数限制。

local tannei = fk.CreateSkill {
  name = "tannei",
}

Fk:loadTranslationTable {
  ["tannei"] = "贪狈",
  [":tannei"] = "出牌阶段限一次，你可以令一名其他角色选择一项："..
    "1. 其交给你一张手牌，你此阶段不能再对其使用牌；2. 令你此阶段对其使用牌无距离和次数限制。",

  ["#tannei-choose"] = "贪狈：选择一名其他角色",
  ["#tannei-choice"] = "贪狈：请选择一项",
  ["tannei_choice1"] = "交给对方一张手牌，对方此阶段不能再对你使用牌",
  ["tannei_choice2"] = "令对方此阶段对你使用牌无距离和次数限制",
  ["@@tannei_limit"] = "贪狈限制",
  ["@@tannei_unlimit"] = "贪狈无限",

  ["$tannei1"] = "贪婪无度，永不知足！",
  ["$tannei2"] = "给我，都给我！",
}

tannei:addEffect("active", {
  mute = true,
  prompt = "#tannei-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(tannei.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, tannei.name, "control", {target})
    player:broadcastSkillInvoke(tannei.name)

    local choices = {"tannei_choice1", "tannei_choice2"}

    -- 如果目标没有手牌，不能选择第一项
    if target:isKongcheng() then
      table.removeOne(choices, "tannei_choice1")
    end

    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = tannei.name,
      prompt = "#tannei-choice",
      detailed = false,
    })

    if choice == "tannei_choice1" then
      -- 交给你一张手牌
      local card = room:askToCards(target, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = tannei.name,
        pattern = ".",
        cancelable = false,
      })

      room:moveCardTo(card, Player.Hand, player, fk.ReasonGive, tannei.name, nil, false, target.id)

      -- 此阶段不能再对其使用牌
      room:setPlayerMark(player, "@@tannei_limit", target.id)
    else
      -- 此阶段对其使用牌无距离和次数限制
      room:setPlayerMark(player, "@@tannei_unlimit", target.id)
    end
  end,
})

-- 不能对目标使用牌
tannei:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local limit = player:getMark("@@tannei_limit")
    if limit == 0 then return false end

    -- 检查目标是否包含限制的角色
    local tos = data.tos
    if not tos then return false end

    return table.contains(tos, limit)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    -- 取消使用
    data.cancel = true
  end,
})

-- 无距离和次数限制
tannei:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    local unlimit = player:getMark("@@tannei_unlimit")
    if unlimit == 0 then return end
    return 999
  end,
  distance_limit_func = function(self, player, skill, scope, card)
    local unlimit = player:getMark("@@tannei_unlimit")
    if unlimit == 0 then return end
    return true
  end,
})

-- 回合结束清除标记
tannei:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@tannei_limit") ~= 0 or player:getMark("@@tannei_unlimit") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@tannei_limit", 0)
    room:setPlayerMark(player, "@@tannei_unlimit", 0)
  end,
})

return tannei
