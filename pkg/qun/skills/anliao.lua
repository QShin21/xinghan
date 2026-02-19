-- SPDX-License-Identifier: GPL-3.0-or-later
-- 公孙度 - 安辽技能
-- 出牌阶段限X次，你可以重铸一名角色的一张牌（X为群雄势力角色数）。

local anliao = fk.CreateSkill {
  name = "anliao",
}

Fk:loadTranslationTable {
  ["anliao"] = "安辽",
  [":anliao"] = "出牌阶段限X次，你可以重铸一名角色的一张牌（X为群雄势力角色数）。",

  ["#anliao-target"] = "安辽：选择一名角色重铸其一张牌",

  ["$anliao1"] = "安辽之策，保境安民！",
  ["$anliao2"] = "辽东公孙，安辽天下！",
}

anliao:addEffect("active", {
  mute = true,
  prompt = "#anliao-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    -- 计算群雄势力角色数
    local room = player.room
    local qun_count = 0
    for _, p in ipairs(room.alive_players) do
      if p.kingdom == "qun" then
        qun_count = qun_count + 1
      end
    end
    
    return player:usedSkillTimes(anliao.name, Player.HistoryPhase) < qun_count
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return not to_select:isNude()
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, anliao.name, "control", {target})
    player:broadcastSkillInvoke(anliao.name)

    -- 选择一张牌重铸
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = anliao.name,
    })
    
    room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, anliao.name)
    player:drawCards(1, anliao.name)
  end,
})

return anliao
