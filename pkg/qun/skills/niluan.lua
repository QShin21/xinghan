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

  ["#niluan-invoke"] = "逆乱：你可以对 %dest 使用一张【杀】",
  ["@@niluan_damage"] = "逆乱伤害",

  ["$niluan1"] = "逆乱天下，何人能挡！",
  ["$niluan2"] = "乱世枭雄，唯我独尊！",
}

-- 记录角色是否对其他角色使用过牌
niluan:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and data.tos and #data.tos > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    -- 检查是否对其他角色使用牌
    for _, to in ipairs(data.tos) do
      if to ~= target.id then
        target.room:setPlayerFlag(target, "niluan_used")
        break
      end
    end
  end,
})

niluan:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(niluan.name) and
      target.phase == Player.Finish and target:hasFlag("niluan_used")
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local slash = Fk:cloneCard("slash")

    if not player:canUseTo(slash, target) then return false end

    return room:askToSkillInvoke(player, {
      skill_name = niluan.name,
      prompt = "#niluan-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 使用杀
    local slash = Fk:cloneCard("slash")
    slash.skillName = niluan.name

    room:useCard{
      from = player.id,
      tos = {target.id},
      card = slash,
      extra_data = {niluan_from = player.id},
    }
  end,
})

-- 造成伤害后弃置牌
niluan:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not data.card or data.card.skillName ~= niluan.name then return false end
    return target == player and data.to and not data.to.dead and not data.to:isNude()
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

-- 回合开始清除标记
niluan:addEffect(fk.TurnStart, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:hasFlag("niluan_used")
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerFlag(player, "-niluan_used")
  end,
})

return niluan
