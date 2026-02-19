-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张燕 - 狼蹈技能
-- 每项限一次，当你使用【杀】指定唯一目标时，你可以选择一项，令此【杀】：
-- 1.造成的伤害+1；2.不能被响应。

local langdao = fk.CreateSkill {
  name = "langdao",
}

Fk:loadTranslationTable {
  ["langdao"] = "狼蹈",
  [":langdao"] = "每项限一次，当你使用【杀】指定唯一目标时，你可以选择一项，令此【杀】："..
    "1.造成的伤害+1；2.不能被响应。",

  ["#langdao-choice"] = "狼蹈：选择一项效果",
  ["langdao_damage"] = "伤害+1",
  ["langdao_unrespondable"] = "不能被响应",
  ["@@langdao_damage_used"] = "狼蹈伤害已用",
  ["@@langdao_unrespondable_used"] = "狼蹈不可响应已用",

  ["$langdao1"] = "狼蹈之威，势不可挡！",
  ["$langdao2"] = "黑山狼骑，天下无双！",
}

langdao:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(langdao.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    if #data.use.tos ~= 1 then return false end
    
    -- 检查是否还有可用选项
    local damage_used = player:getMark("@@langdao_damage_used") > 0
    local unrespondable_used = player:getMark("@@langdao_unrespondable_used") > 0
    
    return not (damage_used and unrespondable_used)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local choices = {}
    if player:getMark("@@langdao_damage_used") == 0 then
      table.insert(choices, "langdao_damage")
    end
    if player:getMark("@@langdao_unrespondable_used") == 0 then
      table.insert(choices, "langdao_unrespondable")
    end
    
    if #choices == 0 then return false end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = langdao.name,
      prompt = "#langdao-choice",
      detailed = false,
    })
    
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    
    if choice == "langdao_damage" then
      room:setPlayerMark(player, "@@langdao_damage_used", 1)
      data.extra_data = data.extra_data or {}
      data.extra_data.langdao_damage = true
    else
      room:setPlayerMark(player, "@@langdao_unrespondable_used", 1)
      data.extra_data = data.extra_data or {}
      data.extra_data.langdao_unrespondable = true
    end
  end,
})

-- 伤害+1
langdao:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return data.extra_data and data.extra_data.langdao_damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 不能被响应
langdao:addEffect(fk.CardEffecting, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not data.card or data.card.trueName ~= "slash" then return false end
    return data.extra_data and data.extra_data.langdao_unrespondable
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.disresponsive = true
  end,
})

-- 回合结束清除标记
langdao:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@langdao_damage_used") > 0 or player:getMark("@@langdao_unrespondable_used") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@langdao_damage_used", 0)
    room:setPlayerMark(player, "@@langdao_unrespondable_used", 0)
  end,
})

return langdao
