-- SPDX-License-Identifier: GPL-3.0-or-later
-- 沮授 - 矢北技能
-- 锁定技，你每回合第一次受到伤害后，回复1点体力。你每回合第二次受到伤害后，失去1点体力。

local shibei = fk.CreateSkill {
  name = "shibei",
}

Fk:loadTranslationTable {
  ["shibei"] = "矢北",
  [":shibei"] = "锁定技，你每回合第一次受到伤害后，回复1点体力。你每回合第二次受到伤害后，失去1点体力。",

  ["@@shibei_count"] = "矢北计数",

  ["$shibei1"] = "矢志不渝，北面称臣！",
  ["$shibei2"] = "河北忠臣，矢志不渝！",
}

shibei:addEffect(fk.Damaged, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shibei.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@@shibei_count") or 0
    count = count + 1
    room:setPlayerMark(player, "@@shibei_count", count)
    
    if count == 1 then
      -- 第一次：回复体力
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = shibei.name,
      }
    elseif count == 2 then
      -- 第二次：失去体力
      room:loseHp(player, 1, shibei.name)
    end
  end,
})

-- 回合结束清除标记
shibei:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@shibei_count") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@shibei_count", 0)
  end,
})

return shibei
