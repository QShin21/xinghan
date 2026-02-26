local yinpan = fk.CreateSkill {
  name = "xh__yinpan",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable{
  ["xh__yinpan"] = "引叛",
  [":xh__yinpan"] = "限定技，出牌阶段，你可以对对手造成X点伤害（X为对手因“明策”摸牌的次数）。",

  ["#xh__yinpan-invoke"] = "引叛：是否对对手造成伤害？",
  ["@@xh__yinpan_count"] = "引叛计数",

  ["$xh__yinpan1"] = "引叛之计，借刀杀人！",
  ["$xh__yinpan2"] = "陈宫引叛，天下大乱！",
}

-- 存储明策技能的摸牌次数
local last_mingce_draw_count = {}

-- 监听"明策"技能，记录对手摸牌的次数
mingce:addEffect(fk.CardUseFinished, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card.trueName == "slash" and player:hasSkill("xh__mingce")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 记录“明策”摸牌次数
    local draw_count = data.card.number == 6 and 2 or 1  -- 假设摸牌次数为2时代表特殊条件
    last_mingce_draw_count[target.id] = (last_mingce_draw_count[target.id] or 0) + draw_count
  end,
})

-- 引叛技能
yinpan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(yinpan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(yinpan.name, Player.HistoryGame) > 0 then return false end
    
    -- 获取因明策技能触发的摸牌次数
    local count = last_mingce_draw_count[target.id] or 0
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
    -- 获取引叛伤害值
    local count = last_mingce_draw_count[target.id] or 0
    
    -- 找出对手
    local opponents = room:getOtherPlayers(player)
    if #opponents == 0 then return end
    
    local to = opponents[1]
    
    -- 对对手造成伤害
    room:damage{
      from = player,
      to = to,
      damage = count,
      skillName = yinpan.name,
    }

    -- 清空“明策”技能的摸牌次数
    last_mingce_draw_count[target.id] = 0
  end,
})

return yinpan