-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘备 - 振鞘技能
-- 锁定技，你的攻击范围+1；
-- 当你使用【杀】指定目标后，若你的武器栏空置，则你令此【杀】的结算执行两次。

local zhenqia = fk.CreateSkill {
  name = "zhenqia",
}

Fk:loadTranslationTable {
  ["zhenqia"] = "振鞘",
  [":zhenqia"] = "锁定技，你的攻击范围+1；当你使用【杀】指定目标后，若你的武器栏空置，"..
    "则你令此【杀】的结算执行两次。",

  ["@@zhenqia_double"] = "振鞘",

  ["$zhenqia1"] = "振鞘出鞘，剑气如虹！",
  ["$zhenqia2"] = "双剑合璧，天下无敌！",
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

-- 杀结算执行两次
zhenqia:addEffect(fk.TargetSpecifying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(zhenqia.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end

    -- 检查武器栏是否空置
    return #player:getCardIds("e", Card.SubtypeWeapon) == 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.zhenqia_double = true
  end,
})

-- 执行两次结算
zhenqia:addEffect(fk.CardEffectFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local extra_data = data.extra_data or {}
    return extra_data.zhenqia_double and not extra_data.zhenqia_used
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data.extra_data.zhenqia_used = true

    -- 再次使用此杀
    local card = data.card
    if card and not player.dead then
      room:useCard{
        from = player.id,
        tos = data.tos,
        card = card,
      }
    end
  end,
})

return zhenqia
