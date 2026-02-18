-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张燕 - 狼蹈技能
-- 每项限一次，当你使用【杀】指定唯一目标时，你可以选择一项，令此【杀】：
-- 1. 造成的伤害+1；2. 不能被响应。

local langdao = fk.CreateSkill {
  name = "langdao",
}

Fk:loadTranslationTable {
  ["langdao"] = "狼蹈",
  [":langdao"] = "每项限一次，当你使用【杀】指定唯一目标时，你可以选择一项，令此【杀】："..
    "1. 造成的伤害+1；2. 不能被响应。",

  ["#langdao-choice"] = "狼蹈：选择一项效果",
  ["langdao_choice1"] = "造成的伤害+1",
  ["langdao_choice2"] = "不能被响应",
  ["@@langdao_damage"] = "狼蹈伤害",
  ["@@langdao_unrespondable"] = "狼蹈无响应",

  ["$langdao1"] = "狼行千里，蹈险如夷！",
  ["$langdao2"] = "狼子野心，蹈厉奋发！",
}

langdao:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(langdao.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    if #data.use.tos ~= 1 then return false end

    -- 检查是否还有可用选项
    local damage_used = player:getMark("@@langdao_damage") > 0
    local unrespondable_used = player:getMark("@@langdao_unrespondable") > 0

    return not (damage_used and unrespondable_used)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local choices = {}
    if player:getMark("@@langdao_damage") == 0 then
      table.insert(choices, "langdao_choice1")
    end
    if player:getMark("@@langdao_unrespondable") == 0 then
      table.insert(choices, "langdao_choice2")
    end

    if #choices == 0 then return false end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = langdao.name,
      prompt = "#langdao-choice",
      detailed = false,
    })

    if choice then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice

    if choice == "langdao_choice1" then
      -- 伤害+1
      room:setPlayerMark(player, "@@langdao_damage", 1)
      data.extra_data = data.extra_data or {}
      data.extra_data.langdao_damage = true
    else
      -- 不能被响应
      room:setPlayerMark(player, "@@langdao_unrespondable", 1)
      data.extra_data = data.extra_data or {}
      data.extra_data.langdao_unrespondable = true
    end
  end,
})

-- 伤害+1
langdao:addEffect(fk.DamageCaused, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end

    local extra_data = data.extra_data or {}
    return extra_data.langdao_damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 不能被响应
langdao:addEffect(fk.CardEffectCancelledOut, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    local extra_data = data.extra_data or {}
    return extra_data.langdao_unrespondable
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.unresponseable = true
  end,
})

-- 回合结束清除标记
langdao:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@langdao_damage") > 0 or player:getMark("@@langdao_unrespondable") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@langdao_damage", 0)
    room:setPlayerMark(player, "@@langdao_unrespondable", 0)
  end,
})

return langdao
