-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙坚(新) - 虎烈技能
-- 每回合各限一次，你使用【杀】或【决斗】仅指定一名角色为目标后，
-- 你可令此牌伤害+1，此牌结算后若其体力值小于你，其视为对你使用一张【杀】。

local hulie = fk.CreateSkill {
  name = "xh__hulie",
}

Fk:loadTranslationTable {
  ["xh__hulie"] = "虎烈",
  [":xh__hulie"] = "每回合各限一次，你使用【杀】或【决斗】仅指定一名角色为目标后，"..
    "你可令此牌伤害+1，此牌结算后若其体力值小于你，其视为对你使用一张【杀】。",

  ["#xh__hulie-invoke"] = "虎烈：是否令此牌伤害+1？",
  ["@@xh__hulie_slash"] = "虎烈杀",
  ["@@xh__hulie_duel"] = "虎烈决斗",

  ["$xh__hulie1"] = "虎烈之威，势不可挡！",
  ["$xh__hulie2"] = "江东猛虎，天下无双！",
}

hulie:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__hulie.name) then return false end
    if not data.card then return false end
    if #data.use.tos ~= 1 then return false end
    
    local card_name = data.card.trueName
    if card_name == "slash" then
      return player:usedSkillTimes(xh__hulie.name .. "_slash", Player.HistoryTurn) == 0
    elseif card_name == "duel" then
      return player:usedSkillTimes(xh__hulie.name .. "_duel", Player.HistoryTurn) == 0
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__hulie.name,
      prompt = "#hulie-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_name = data.card.trueName
    
    room:addPlayerMark(player, "@@hulie_" .. card_name, 1)
    room:setPlayerMark(player, "@@hulie_target", data.use.tos[1])
    
    -- 伤害+1
    data.extra_data = data.extra_data or {}
    data.extra_data.hulie_damage = true
  end,
})

-- 伤害+1
hulie:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card then return false end
    return data.extra_data and data.extra_data.hulie_damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 结算后使用杀
hulie:addEffect(fk.CardUseFinished, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__hulie.name) then return false end
    if not data.card then return false end
    
    local card_name = data.card.trueName
    if card_name ~= "slash" and card_name ~= "duel" then return false end
    
    local target_id = player:getMark("@@hulie_target")
    if not target_id or target_id == 0 then return false end
    
    local to = player.room:getPlayerById(target_id)
    return to and not to.dead and to.hp < player.hp
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local target_id = player:getMark("@@hulie_target")
    local to = room:getPlayerById(target_id)
    
    -- 视为对你使用一张杀
    local slash = Fk:cloneCard("slash")
    slash.skillName = xh__hulie.name
    
    room:useCard{
      from = to.id,
      tos = {player.id},
      card = slash,
    }
    
    room:setPlayerMark(player, "@@hulie_target", 0)
  end,
})

return hulie
