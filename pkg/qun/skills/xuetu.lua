-- SPDX-License-Identifier: GPL-3.0-or-later
-- 杨奉 - 血途技能
-- 转换技，出牌阶段限一次，
-- 阳：你可以令一名角色回复1点体力；
-- 阴：你可以令一名角色摸两张牌。

local xuetu = fk.CreateSkill {
  name = "xuetu",
}

Fk:loadTranslationTable {
  ["xuetu"] = "血途",
  [":xuetu"] = "转换技，出牌阶段限一次，阳：你可以令一名角色回复1点体力；阴：你可以令一名角色摸两张牌。",

  ["@@xuetu-state"] = "血途状态",
  ["#xuetu-yang"] = "血途（阳）：令一名角色回复1点体力",
  ["#xuetu-yin"] = "血途（阴）：令一名角色摸两张牌",

  ["$xuetu1"] = "血途漫漫，生死由天！",
  ["$xuetu2"] = "命途多舛，唯勇者胜！",
}

-- 初始化状态
xuetu:addEffect(fk.GameStart, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(xuetu.name)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xuetu-state", "yang")
  end,
})

xuetu:addEffect("active", {
  mute = true,
  prompt = function(self, player)
    local state = player:getMark("@@xuetu-state")
    if state == "yang" then
      return "#xuetu-yang"
    else
      return "#xuetu-yin"
    end
  end,
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    if player:usedSkillTimes(xuetu.name, Player.HistoryPhase) > 0 then
      return false
    end

    local state = player:getMark("@@xuetu-state")
    if state == "yang" then
      -- 阳状态：需要有受伤角色
      return table.find(player.room.alive_players, function(p)
        return p:isWounded()
      end)
    else
      -- 阴状态：始终可以使用
      return true
    end
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end

    local state = player:getMark("@@xuetu-state")
    if state == "yang" then
      return to_select:isWounded()
    else
      return true
    end
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local state = player:getMark("@@xuetu-state")

    room:notifySkillInvoked(player, xuetu.name, "support", {target})
    player:broadcastSkillInvoke(xuetu.name)

    if state == "yang" then
      -- 阳：令其回复1点体力
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = xuetu.name,
      }
      room:setPlayerMark(player, "@@xuetu-state", "yin")
    else
      -- 阴：令其摸两张牌
      target:drawCards(2, xuetu.name)
      room:setPlayerMark(player, "@@xuetu-state", "yang")
    end
  end,
})

return xuetu
