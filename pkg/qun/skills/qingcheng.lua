-- SPDX-License-Identifier: GPL-3.0-or-later
-- 邹氏 - 倾城技能
-- 出牌阶段限一次，你可以选择手牌数小于等于你的一名角色与其交换手牌。

local qingcheng = fk.CreateSkill {
  name = "qingcheng",
}

Fk:loadTranslationTable {
  ["qingcheng"] = "倾城",
  [":qingcheng"] = "出牌阶段限一次，你可以选择手牌数小于等于你的一名角色与其交换手牌。",

  ["#qingcheng-target"] = "倾城：选择一名手牌数小于等于你的角色",

  ["$qingcheng1"] = "倾城之貌，倾国倾城！",
  ["$qingcheng2"] = "邹氏倾城，天下无双！",
}

qingcheng:addEffect("active", {
  mute = true,
  prompt = "#qingcheng-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(qingcheng.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and to_select:getHandcardNum() <= player:getHandcardNum()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, qingcheng.name, "control", {target})
    player:broadcastSkillInvoke(qingcheng.name)

    -- 交换手牌
    local player_cards = player:getCardIds("h")
    local target_cards = target:getCardIds("h")
    
    room:moveCardTo(player_cards, Player.Hand, target, fk.ReasonGive, qingcheng.name, nil, false, player.id)
    room:moveCardTo(target_cards, Player.Hand, player, fk.ReasonGive, qingcheng.name, nil, false, target.id)
  end,
})

return qingcheng
