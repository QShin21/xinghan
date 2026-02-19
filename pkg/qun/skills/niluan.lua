-- SPDX-License-Identifier: GPL-3.0-or-later
-- 韩遂 - 逆乱技能
-- 其他角色的结束阶段，若其本回合对除其以外的角色使用过牌，
-- 则你可以对其使用一张【杀】，当此【杀】结算结束后，若此【杀】对其造成过伤害，则你弃置其一张牌。

local niluan = fk.CreateSkill {
  name = "niluan",
}

Fk:loadTranslationTable {
  ["niluan"] = "逆乱",
  [":niluan"] = "其他角色的结束阶段，若其本回合对除其以外的角色使用过牌，"..
    "则你可以对其使用一张【杀】，当此【杀】结算结束后，若此【杀】对其造成过伤害，则你弃置其一张牌。",

  ["#niluan-use"] = "逆乱：是否对其使用一张杀？",
  ["@@niluan_damage"] = "逆乱伤害",

  ["$niluan1"] = "逆乱之志，不屈不挠！",
  ["$niluan2"] = "西凉铁骑，逆乱天下！",
}

niluan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player or not player:hasSkill(niluan.name) then return false end
    if target.phase ~= Player.Finish then return false end
    
    -- 检查是否对其他角色使用过牌
    return target:getMark("@@niluan_used") > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = niluan.name,
      prompt = "#niluan-use",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local slash = Fk:cloneCard("slash")
    slash.skillName = niluan.name
    
    room:useCard{
      from = player.id,
      tos = {target.id},
      card = slash,
      extra_data = { niluan = true },
    }
  end,
})

-- 记录使用牌
niluan:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and target.phase == Player.Play and data.to and data.to ~= target.id
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    target.room:addPlayerMark(target, "@@niluan_used", 1)
  end,
})

-- 造成伤害后弃牌
niluan:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not target or not data.card then return false end
    if not data.card.extra_data or not data.card.extra_data.niluan then return false end
    return target == player and data.to and not data.to:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = niluan.name,
    })
    room:throwCard(id, niluan.name, to, player)
  end,
})

-- 回合结束清除标记
niluan:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@niluan_used") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@niluan_used", 0)
  end,
})

return niluan
