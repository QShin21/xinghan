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

  ["#tishen-invoke"] = "替身：是否回复体力至上限并摸牌？",

  ["$tishen1"] = "替身之术，起死回生！",
  ["$tishen2"] = "燕人张飞，在此！",
}

tishen:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tishen.name) and
      player.phase == Player.Start and
      player:usedSkillTimes(tishen.name, Player.HistoryGame) == 0 and
      player.hp < player.maxHp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tishen.name,
      prompt = "#tishen-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local recover = player.maxHp - player.hp
    
    room:recover{
      who = player,
      num = recover,
      recoverBy = player,
      skillName = tishen.name,
    }
    
    player:drawCards(recover, tishen.name)
  end,
})

return tishen
