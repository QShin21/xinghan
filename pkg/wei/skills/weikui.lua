-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 伪溃技能
-- 出牌阶段限一次，你可以失去1点体力并观看一名有手牌的其他角色的手牌，
-- 若其中没有【闪】，你弃置其中一张牌，否则你视为对其使用一张【杀】，且你本回合计算与其的距离视为1。

local weikui = fk.CreateSkill {
  name = "weikui",
}

Fk:loadTranslationTable {
  ["weikui"] = "伪溃",
  [":weikui"] = "出牌阶段限一次，你可以失去1点体力并观看一名有手牌的其他角色的手牌，"..
    "若其中没有【闪】，你弃置其中一张牌，否则你视为对其使用一张【杀】，且你本回合计算与其的距离视为1。",

  ["#weikui-choose"] = "伪溃：选择一名有手牌的角色",
  ["#weikui-discard"] = "伪溃：弃置其一张牌",
  ["@@weikui_distance"] = "伪溃",

  ["$weikui1"] = "伪溃诱敌，出奇制胜！",
  ["$weikui2"] = "示敌以弱，攻其不备！",
}

weikui:addEffect("active", {
  mute = true,
  prompt = "#weikui-choose",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(weikui.name, Player.HistoryPhase) == 0 and
      player.hp > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and not to_select:isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, weikui.name, "offensive", {target})
    player:broadcastSkillInvoke(weikui.name)

    -- 失去1点体力
    room:loseHp(player, 1, weikui.name)

    if player.dead or target.dead then return end

    -- 观看其手牌
    local handcards = target:getCardIds("h")
    room:showCards(player, handcards, weikui.name)

    -- 检查是否有闪
    local has_jink = table.find(handcards, function(id)
      return Fk:getCardById(id).trueName == "jink"
    end)

    if not has_jink then
      -- 没有闪：弃置其中一张牌
      if #handcards > 0 then
        local id = room:askToChooseCard(player, {
          target = target,
          flag = "h",
          skill_name = weikui.name,
        })
        room:throwCard(id, weikui.name, target, player)
      end
    else
      -- 有闪：视为对其使用杀
      local slash = Fk:cloneCard("slash")
      slash.skillName = weikui.name
      room:useCard{
        from = player.id,
        tos = {target.id},
        card = slash,
      }

      -- 本回合计算与其的距离视为1
      room:setPlayerMark(player, "@@weikui_distance", target.id)
    end
  end,
})

-- 距离视为1
weikui:addEffect("distance", {
  correct_func = function(self, from, to)
    local mark = from:getMark("@@weikui_distance")
    if mark == to.id then
      -- 计算实际距离，如果大于1则修正为1
      local actual_distance = from:distanceTo(to, false)
      if actual_distance > 1 then
        return 1 - actual_distance
      end
    end
    return 0
  end,
})

-- 回合结束清除标记
weikui:addEffect(fk.TurnEnd, {
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@weikui_distance") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@weikui_distance", 0)
  end,
})

return weikui
