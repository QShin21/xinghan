-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘繇 - 戡难技能
-- 出牌阶段限一次，你可与对手拼点，若你赢，你使用的下一张【杀】的伤害值基数+1；
-- 若其赢，其使用的下一张【杀】的伤害值基数+1。

local kannan = fk.CreateSkill {
  name = "kannan",
}

Fk:loadTranslationTable {
  ["kannan"] = "戡难",
  [":kannan"] = "出牌阶段限一次，你可与对手拼点，若你赢，你使用的下一张【杀】的伤害值基数+1；"..
    "若其赢，其使用的下一张【杀】的伤害值基数+1。",

  ["#kannan-target"] = "戡难：选择一名对手进行拼点",
  ["@@kannan_damage"] = "戡难",

  ["$kannan1"] = "戡难之志，平定乱世！",
  ["$kannan2"] = "扬州刺史，戡难安民！",
}

kannan:addEffect("active", {
  mute = true,
  prompt = "#kannan-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(kannan.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, kannan.name, "offensive", {target})
    player:broadcastSkillInvoke(kannan.name)

    local pindian = room:pindian({player, target}, kannan.name)
    
    if pindian.results[player].winner then
      -- 你赢：你的下一张杀伤害+1
      room:setPlayerMark(player, "@@kannan_damage", 1)
    else
      -- 对手赢：对手的下一张杀伤害+1
      room:setPlayerMark(target, "@@kannan_damage", 1)
    end
  end,
})

-- 杀伤害+1
kannan:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return player:getMark("@@kannan_damage") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
    player.room:setPlayerMark(player, "@@kannan_damage", 0)
  end,
})

return kannan
