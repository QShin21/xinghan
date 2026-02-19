-- SPDX-License-Identifier: GPL-3.0-or-later
-- 魏延 - 奇谋技能
-- 限定技，出牌阶段，你可以失去任意点体力，然后直到回合结束，
-- 你计算与其他角色的距离-X，且你可以多使用X张【杀】（X为你以此法失去的体力值数）。

local qimou = fk.CreateSkill {
  name = "xh__qimou",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__qimou"] = "奇谋",
  [":xh__qimou"] = "限定技，出牌阶段，你可以失去任意点体力，然后直到回合结束，"..
    "你计算与其他角色的距离-X，且你可以多使用X张【杀】（X为你以此法失去的体力值数）。",

  ["#xh__qimou-use"] = "奇谋：选择失去的体力值",
  ["@@xh__qimou_x"] = "奇谋",

  ["$xh__qimou1"] = "奇谋妙计，出奇制胜！",
  ["$xh__qimou2"] = "兵行险着，方为上策！",
}

qimou:addEffect("active", {
  mute = true,
  prompt = "#qimou-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__qimou.name) == 0 and player.hp > 1
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, xh__qimou.name, "offensive")
    player:broadcastSkillInvoke(xh__qimou.name)

    -- 选择失去的体力值
    local max_lose = player.hp - 1
    local choices = {}
    for i = 1, max_lose do
      table.insert(choices, tostring(i))
    end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = xh__qimou.name,
      prompt = "#qimou-use",
      detailed = false,
    })
    
    local x = tonumber(choice)
    
    -- 失去体力
    room:loseHp(player, x, xh__qimou.name)
    
    -- 设置标记
    room:setPlayerMark(player, "@@qimou_x", x)
  end,
})

-- 距离修正
qimou:addEffect("distance", {
  correct_func = function(self, from, to)
    local x = from:getMark("@@qimou_x")
    if x > 0 then
      return -x
    end
    return 0
  end,
})

-- 杀次数修正
qimou:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" then
      return player:getMark("@@qimou_x")
    end
    return 0
  end,
})

-- 回合结束清除标记
qimou:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@qimou_x") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@qimou_x", 0)
  end,
})

return qimou
