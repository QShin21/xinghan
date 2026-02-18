-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘表 - 宗室技能
-- 锁定技，你的手牌上限+X（X为全场势力数）；准备阶段，若你的手牌数大于你的体力值，
-- 则你本回合使用【杀】无次数限制。

local zongshi = fk.CreateSkill {
  name = "zongshi",
}

Fk:loadTranslationTable {
  ["zongshi"] = "宗室",
  [":zongshi"] = "锁定技，你的手牌上限+X（X为全场势力数）；准备阶段，若你的手牌数大于你的体力值，"..
    "则你本回合使用【杀】无次数限制。",

  ["@@zongshi_no_limit"] = "宗室",

  ["$zongshi1"] = "宗室之贵，非同凡响！",
  ["$zongshi2"] = "汉室宗亲，名正言顺！",
}

-- 手牌上限+X
zongshi:addEffect(fk.MaxCardsCalc, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(zongshi.name)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      kingdoms[p.kingdom] = true
    end
    local x = table.size(kingdoms)
    data.num = data.num + x
  end,
})

-- 准备阶段检查
zongshi:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zongshi.name) and
      player.phase == Player.Start and
      player:getHandcardNum() > player.hp
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@zongshi_no_limit", 1)
  end,
})

-- 杀无次数限制
zongshi:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if skill.trueName == "slash_skill" and player:getMark("@@zongshi_no_limit") > 0 then
      return 999
    end
    return 0
  end,
})

-- 回合结束清除标记
zongshi:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@zongshi_no_limit") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@zongshi_no_limit", 0)
  end,
})

return zongshi
