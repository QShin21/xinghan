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

  ["#xiongrao-invoke"] = "熊扰：令所有其他角色技能失效，加体力上限至4点并摸牌",
  ["@@xiongrao_disable"] = "熊扰",

  ["$xiongrao1"] = "熊扰天下，谁敢不从！",
  ["$xiongrao2"] = "群雄束手，唯我独尊！",
}

xiongrao:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xiongrao.name) and
      player.phase == Player.Start and player:usedSkillTimes(xiongrao.name) == 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xiongrao.name,
      prompt = "#xiongrao-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 令所有其他角色技能失效
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p.dead then
        -- 添加技能失效标记
        room:setPlayerMark(p, "@@xiongrao_disable", 1)

        -- 失效非锁定技、非限定技、非觉醒技
        for _, skill in ipairs(p.player_skills) do
          if skill.frequency ~= Skill.Limited and
             skill.frequency ~= Skill.Wake and
             skill.frequency ~= Skill.Locked then
            room:handleAddLoseSkills(p, "-" .. skill.name, nil, false, true)
          end
        end
      end
    end

    -- 加体力上限至4点
    local add_hp = math.max(0, 4 - player.maxHp)
    if add_hp > 0 then
      room:changeMaxHp(player, add_hp)
    end

    -- 摸等同于加体力上限数量的牌
    if not player.dead and add_hp > 0 then
      player:drawCards(add_hp, xiongrao.name)
    end
  end,
})

-- 回合结束恢复技能
xiongrao:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xiongrao_disable") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@xiongrao_disable", 0)

    -- 恢复技能
    for _, skill in ipairs(player.player_skills) do
      if skill.frequency ~= Skill.Limited and
         skill.frequency ~= Skill.Wake and
         skill.frequency ~= Skill.Locked then
        if not player:hasSkill(skill.name, true) then
          room:handleAddLoseSkills(player, skill.name, nil, false, true)
        end
      end
    end
  end,
})

return xiongrao
