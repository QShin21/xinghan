-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘协 - 密诏技能
-- 出牌阶段限一次，你可以与对手拼点，拼点赢的角色视为对拼点没赢的角色使用一张无距离和次数限制的普通【杀】。

local mizhao = fk.CreateSkill {
  name = "mizhao",
}

Fk:loadTranslationTable {
  ["mizhao"] = "密诏",
  [":mizhao"] = "出牌阶段限一次，你可以与对手拼点，拼点赢的角色视为对拼点没赢的角色使用一张无距离和次数限制的普通【杀】。",

  ["#mizhao-target"] = "密诏：选择一名对手进行拼点",

  ["$mizhao1"] = "密诏已下，谁敢不从！",
  ["$mizhao2"] = "汉室密诏，奉旨讨贼！",
}

mizhao:addEffect("active", {
  mute = true,
  prompt = "#mizhao-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(mizhao.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, mizhao.name, "offensive", {target})
    player:broadcastSkillInvoke(mizhao.name)

    local pindian = room:pindian({player, target}, mizhao.name)
    
    local winner, loser
    if pindian.results[player].winner then
      winner = player
      loser = target
    else
      winner = target
      loser = player
    end
    
    -- 赢的角色对没赢的角色使用杀
    local slash = Fk:cloneCard("slash")
    slash.skillName = mizhao.name
    
    room:useCard{
      from = winner.id,
      tos = {loser.id},
      card = slash,
    }
  end,
})

return mizhao
