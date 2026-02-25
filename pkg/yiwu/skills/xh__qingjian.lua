-- SPDX-License-Identifier: GPL-3.0-or-later
-- 李典 - 清俭技能
-- 每回合限一次，当你获得其他角色的牌后，你可以将其中任意张牌交给任意名角色。

local qingjian = fk.CreateSkill {
  name = "xh__qingjian",
}

Fk:loadTranslationTable {
  ["xh__qingjian"] = "清俭",
  [":xh__qingjian"] = "每回合限一次，当你获得其他角色的牌后，你可以将其中任意张牌交给任意名角色。",

  ["#xh__qingjian-invoke"] = "清俭：是否将获得的牌交给其他角色？",
  ["@@xh__qingjian_max_cards"] = "清俭手牌上限",

  ["$xh__qingjian1"] = "清俭之德，天下无双！",
  ["$xh__qingjian2"] = "李典清俭，忠义无双！",
}

qingjian:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(qingjian.name) then return false end
    if player:usedSkillTimes(qingjian.name, Player.HistoryTurn) > 0 then return false end
    
    -- 检查是否获得了其他角色的牌
    for _, move in ipairs(data) do
      if move.to == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.from and info.from ~= player.id then
            return true
          end
        end
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qingjian.name,
      prompt = "#xh__qingjian-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 简化实现：让玩家选择要给出的牌
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = player:getHandcardNum(),
      include_equip = false,
      skill_name = qingjian.name,
      pattern = ".",
      prompt = "选择要给出的牌",
      cancelable = true,
    })
    
    if #cards == 0 then return end
    
    -- 选择目标
    local targets = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = #cards,
      targets = room:getOtherPlayers(player),
      skill_name = qingjian.name,
      prompt = "选择目标角色",
      cancelable = false,
    })
    
    -- 给牌
    for i, to in ipairs(targets) do
      if i <= #cards then
        room:moveCardTo(cards[i], Player.Hand, to, fk.ReasonGive, qingjian.name, nil, false, player.id)
      end
    end
  end,
})

return qingjian
