-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭汜 - 伺盗技能
-- 出牌阶段限一次，当你对一名其他角色连续使用两张牌后，
-- 你可以将一张手牌当【顺手牵羊】对其使用。

local sidao = fk.CreateSkill {
  name = "sidao",
}

Fk:loadTranslationTable {
  ["sidao"] = "伺盗",
  [":sidao"] = "出牌阶段限一次，当你对一名其他角色连续使用两张牌后，"..
    "你可以将一张手牌当【顺手牵羊】对其使用。",

  ["#sidao-use"] = "伺盗：将一张手牌当顺手牵羊使用",

  ["$sidao1"] = "伺机而动，盗亦有道！",
  ["$sidao2"] = "伺盗之术，出其不意！",
}

sidao:addEffect(fk.CardUsing, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(sidao.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(sidao.name, Player.HistoryPhase) > 0 then return false end
    if player:isKongcheng() then return false end
    
    -- 检查是否连续使用两张牌给同一目标
    local last_use = player:getMark("@@sidao_last_use")
    if last_use and last_use.to == data.to and last_use.card ~= data.card then
      return true
    end
    
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    
    return room:askToSkillInvoke(player, {
      skill_name = sidao.name,
      prompt = "#sidao-use",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    
    local card_id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = sidao.name,
      pattern = ".",
      prompt = "选择一张手牌当顺手牵羊使用",
      cancelable = false,
    })
    
    local card = Fk:cloneCard("dismantlement")
    card.skillName = sidao.name
    card:addSubcard(card_id[1])
    
    room:useCard{
      from = player.id,
      tos = {data.to},
      card = card,
    }
  end,
})

-- 记录上一张使用的牌
sidao:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.to then
      room:setPlayerMark(player, "@@sidao_last_use", {
        to = data.to,
        card = data.card.id,
      })
    end
  end,
})

return sidao
