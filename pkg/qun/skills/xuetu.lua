-- SPDX-License-Identifier: GPL-3.0-or-later
-- 杨奉 - 血途技能
-- 转换技，出牌阶段限一次，阳：你可以令一名角色回复1点体力；阴：你可以令一名角色摸两张牌。

local xuetu = fk.CreateSkill {
  name = "xuetu",
}

Fk:loadTranslationTable {
  ["xuetu"] = "血途",
  [":xuetu"] = "转换技，出牌阶段限一次，阳：你可以令一名角色回复1点体力；阴：你可以令一名角色摸两张牌。",

  ["#xuetu-target"] = "血途：选择一名角色",
  ["xuetu_recover"] = "回复1点体力",
  ["xuetu_draw"] = "摸两张牌",

  ["$xuetu1"] = "血途漫漫，生死相依！",
  ["$xuetu2"] = "血途之上，勇者无惧！",
}

xuetu:addEffect("active", {
  mute = true,
  prompt = "#xuetu-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(xuetu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    
    local state = player:getMark("@@xuetu_state") or 0
    
    if state == 0 then
      -- 阳：回复体力
      return to_select:isWounded()
    else
      -- 阴：摸牌
      return true
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local state = player:getMark("@@xuetu_state") or 0

    room:notifySkillInvoked(player, xuetu.name, "support", {target})
    player:broadcastSkillInvoke(xuetu.name)

    if state == 0 then
      -- 阳：回复体力
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = xuetu.name,
      }
    else
      -- 阴：摸牌
      target:drawCards(2, xuetu.name)
    end
    
    -- 切换状态
    room:setPlayerMark(player, "@@xuetu_state", state == 0 and 1 or 0)
  end,
})

return xuetu
