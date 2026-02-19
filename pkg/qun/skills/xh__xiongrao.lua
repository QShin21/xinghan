-- SPDX-License-Identifier: GPL-3.0-or-later
-- 牛辅 - 熊扰技能
-- 限定技，准备阶段，你可以令所有其他角色本回合除锁定技、限定技、觉醒技以外的技能均失效，
-- 然后你加体力上限至4点并摸等同于加体力上限数量的牌。

local xiongrao = fk.CreateSkill {
  name = "xh__xiongrao",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__xiongrao"] = "熊扰",
  [":xh__xiongrao"] = "限定技，准备阶段，你可以令所有其他角色本回合除锁定技、限定技、觉醒技以外的技能均失效，"..
    "然后你加体力上限至4点并摸等同于加体力上限数量的牌。",

  ["#xh__xiongrao-invoke"] = "熊扰：是否发动？",
  ["@@xh__xiongrao_disable"] = "熊扰失效",

  ["$xh__xiongrao1"] = "熊扰天下，谁敢争锋！",
  ["$xh__xiongrao2"] = "西凉熊虎，威震天下！",
}

xiongrao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__xiongrao.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(xh__xiongrao.name, Player.HistoryGame) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__xiongrao.name,
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
    player:drawCards(add, xh__xiongrao.name)
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
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@xiongrao_disable") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xiongrao_disable", 0)
  end,
})

return xiongrao
