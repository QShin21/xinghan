-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张飞 - 替身技能
-- 限定技，准备阶段，你可以回复体力至上限，然后摸X张牌（X为你以此法回复的体力值）。

local tishen = fk.CreateSkill {
  name = "tishen",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["tishen"] = "替身",
  [":tishen"] = "限定技，准备阶段，你可以回复体力至上限，然后摸X张牌（X为你以此法回复的体力值）。",

  ["#tishen-invoke"] = "替身：回复体力至上限，然后摸X张牌",

  ["$tishen1"] = "替身之术，起死回生！",
  ["$tishen2"] = "我还没死呢！",
}

tishen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tishen.name) and
      player.phase == Player.Start and player:usedSkillTimes(tishen.name) == 0 and
      player:isWounded()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tishen.name,
      prompt = "#tishen-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 计算需要回复的体力值
    local recover_num = player.maxHp - player.hp

    -- 回复体力至上限
    room:recover{
      who = player,
      num = recover_num,
      skillName = tishen.name,
    }

    -- 摸X张牌
    if not player.dead and recover_num > 0 then
      player:drawCards(recover_num, tishen.name)
    end
  end,
})

return tishen
