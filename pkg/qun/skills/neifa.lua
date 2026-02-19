-- SPDX-License-Identifier: GPL-3.0-or-later
-- 袁谭袁尚袁熙 - 内伐技能
-- 出牌阶段开始时，你可以摸一张牌，然后弃置一张牌并选择一项：
-- 1.此阶段你不能使用锦囊牌且【杀】的使用次数+1；
-- 2.此阶段你不能使用基本牌，使用普通锦囊牌指定目标后你可以摸一张牌；
-- 3.此阶段你使用装备牌后，可以弃置对手一张牌。

local neifa = fk.CreateSkill {
  name = "neifa",
}

Fk:loadTranslationTable {
  ["neifa"] = "内伐",
  [":neifa"] = "出牌阶段开始时，你可以摸一张牌，然后弃置一张牌并选择一项："..
    "1.此阶段你不能使用锦囊牌且【杀】的使用次数+1；"..
    "2.此阶段你不能使用基本牌，使用普通锦囊牌指定目标后你可以摸一张牌；"..
    "3.此阶段你使用装备牌后，可以弃置对手一张牌。",

  ["neifa_choice1"] = "不能使用锦囊牌，杀次数+1",
  ["neifa_choice2"] = "不能使用基本牌，锦囊摸牌",
  ["neifa_choice3"] = "装备牌弃置对手牌",
  ["@@neifa_choice"] = "内伐",

  ["$neifa1"] = "内伐之计，兄弟阋墙！",
  ["$neifa2"] = "袁氏兄弟，内伐不休！",
}

neifa:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(neifa.name) then return false end
    if player.phase ~= Player.Play then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    -- 摸一张牌
    player:drawCards(1, neifa.name)
    
    -- 弃置一张牌
    if player:isNude() then return false end
    
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = neifa.name,
      pattern = ".",
      prompt = "选择一张牌弃置",
      cancelable = true,
    })
    
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_id = event:getCostData(self).cards[1]
    
    room:throwCard(card_id, neifa.name, player, player)
    
    -- 选择效果
    local choice = room:askToChoice(player, {
      choices = {"neifa_choice1", "neifa_choice2", "neifa_choice3"},
      skill_name = neifa.name,
      prompt = "选择一项效果",
      detailed = false,
    })
    
    room:setPlayerMark(player, "@@neifa_choice", choice)
  end,
})

-- 不能使用锦囊牌
neifa:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from:getMark("@@neifa_choice") == "neifa_choice1" then
      return card.type == Card.TypeTrick
    end
    return false
  end,
})

-- 杀次数+1
neifa:addEffect("targetmod", {
  residue_func = function(self, player, skill, scope, card)
    if player:getMark("@@neifa_choice") == "neifa_choice1" and skill.trueName == "slash_skill" then
      return 1
    end
    return 0
  end,
})

-- 不能使用基本牌
neifa:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from:getMark("@@neifa_choice") == "neifa_choice2" then
      return card.type == Card.TypeBasic
    end
    return false
  end,
})

-- 使用锦囊牌后摸牌
neifa:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player:getMark("@@neifa_choice") ~= "neifa_choice2" then return false end
    if not data.card or data.card.type ~= Card.TypeTrick then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, neifa.name)
  end,
})

-- 使用装备牌后弃置对手牌
neifa:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player:getMark("@@neifa_choice") ~= "neifa_choice3" then return false end
    if not data.card or data.card.type ~= Card.TypeEquip then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isNude()
    end)
    
    if #targets == 0 then return false end
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = neifa.name,
      prompt = "选择一名角色弃置其一张牌",
      cancelable = true,
    })
    
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = neifa.name,
    })
    room:throwCard(id, neifa.name, to, player)
  end,
})

-- 回合结束清除标记
neifa:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@neifa_choice") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@neifa_choice", 0)
  end,
})

return neifa
