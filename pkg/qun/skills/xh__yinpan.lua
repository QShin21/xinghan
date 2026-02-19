-- SPDX-License-Identifier: GPL-3.0-or-later
-- 陈宫 - 引叛技能
-- 限定技，出牌阶段开始时，你可以对对手造成X点伤害（X为对手因"明策"摸牌的次数）。

local yinpan = fk.CreateSkill {
  name = "xh__yinpan",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__yinpan"] = "引叛",
  [":xh__yinpan"] = "限定技，出牌阶段开始时，你可以对对手造成X点伤害（X为对手因\"明策\"摸牌的次数）。",

  ["#xh__yinpan-invoke"] = "引叛：是否对对手造成伤害？",
  ["@@xh__yinpan_count"] = "引叛计数",

  ["$xh__yinpan1"] = "引叛之计，借刀杀人！",
  ["$xh__yinpan2"] = "陈宫引叛，天下大乱！",
}

yinpan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yinpan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(yinpan.name, Player.HistoryGame) > 0 then return false end
    
    local count = player:getMark("@@yinpan_count") or 0
    return count > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = yinpan.name,
      prompt = "#xh__yinpan-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@@yinpan_count") or 0
    
    -- 找出对手
    local opponents = room:getOtherPlayers(player)
    if #opponents == 0 then return end
    
    local to = opponents[1]
    
    room:damage{
      from = player,
      to = to,
      damage = count,
      skillName = yinpan.name,
    }
  end,
})

return yinpan
