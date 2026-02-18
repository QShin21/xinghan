-- SPDX-License-Identifier: GPL-3.0-or-later
-- 牛辅 - 熊扰技能
-- 限定技，准备阶段，你可以令所有其他角色本回合除锁定技、限定技、觉醒技以外的技能均失效，
-- 然后你加体力上限至4点并摸等同于加体力上限数量的牌。

local xiongrao = fk.CreateSkill {
  name = "xiongrao",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xiongrao"] = "熊扰",
  [":xiongrao"] = "限定技，准备阶段，你可以令所有其他角色本回合除锁定技、限定技、觉醒技以外的技能均失效，"..
    "然后你加体力上限至4点并摸等同于加体力上限数量的牌。",

  ["#xiongrao-invoke"] = "熊扰：是否发动？",
  ["@@xiongrao_disable"] = "熊扰失效",

  ["$xiongrao1"] = "熊扰天下，谁敢争锋！",
  ["$xiongrao2"] = "西凉熊虎，威震天下！",
}

xiongrao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongrao.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(xiongrao.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiongrao.name,
      prompt = "#xiongrao-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 令其他角色技能失效
    for _, p in ipairs(room.alive_players) do
      if p ~= player then
        room:addPlayerMark(p, "@@xiongrao_disable", 1)
      end
    end
    
    -- 加体力上限至4点
    local add = math.max(0, 4 - player.maxHp)
    if add > 0 then
      room:changeMaxHp(player, add)
    end
    
    -- 摸牌
    player:drawCards(add, xiongrao.name)
  end,
})

-- 技能失效
xiongrao:addEffect("filter", {
  card_filter = function(self, card, player)
    if player:getMark("@@xiongrao_disable") > 0 then
      return card.skill and not card.skill.frequency == Skill.Limited and
        not card.skill.frequency == Skill.Wake and not card.skill.frequency == Skill.Lock
    end
    return false
  end,
})

-- 回合结束清除标记
xiongrao:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xiongrao_disable") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xiongrao_disable", 0)
  end,
})

return xiongrao
