-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘备(群) - 振鞘技能
-- 锁定技，你的攻击范围+1；当你使用【杀】指定目标后，若你的武器栏空置，则你令此【杀】的结算执行两次。

local zhenqia = fk.CreateSkill {
  name = "zhenqia",
}

Fk:loadTranslationTable {
  ["zhenqia"] = "振鞘",
  [":zhenqia"] = "锁定技，你的攻击范围+1；当你使用【杀】指定目标后，若你的武器栏空置，则你令此【杀】的结算执行两次。",

  ["@@zhenqia_double"] = "振鞘",

  ["$zhenqia1"] = "振鞘出鞘，势不可挡！",
  ["$zhenqia2"] = "双股剑出，天下无双！",
}

-- 攻击范围+1
zhenqia:addEffect("attack_range", {
  correct_func = function(self, from, to)
    if from:hasSkill(zhenqia.name) then
      return 1
    end
    return 0
  end,
})

-- 杀结算两次
zhenqia:addEffect(fk.TargetSpecified, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(zhenqia.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    -- 检查武器栏是否空置
    return #player:getCardIds(Card.SubtypeWeapon) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@@zhenqia_double", 1)
  end,
})

-- 执行两次
zhenqia:addEffect(fk.CardEffecting, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not data.card or data.card.trueName ~= "slash" then return false end
    return player:getMark("@@zhenqia_double") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@@zhenqia_double")
    room:setPlayerMark(player, "@@zhenqia_double", 0)
    
    -- 再次执行效果
    for i = 1, count do
      room:damage{
        from = room:getPlayerById(data.from),
        to = player,
        damage = data.card.damage or 1,
        card = data.card,
        skillName = zhenqia.name,
      }
    end
  end,
})

return zhenqia
