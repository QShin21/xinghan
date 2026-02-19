-- SPDX-License-Identifier: GPL-3.0-or-later
-- 杨彪 - 让节技能
-- 当你受到1点伤害后，你可以移动场上的一张牌，然后你可以于本回合进入弃牌堆的牌中选择一张与此牌花色相同的牌获得之。

local rangjie = fk.CreateSkill {
  name = "xh__rangjie",
}

Fk:loadTranslationTable {
  ["xh__rangjie"] = "让节",
  [":xh__rangjie"] = "当你受到1点伤害后，你可以移动场上的一张牌，然后你可以于本回合进入弃牌堆的牌中选择一张与此牌花色相同的牌获得之。",

  ["#xh__rangjie-move"] = "让节：移动场上的一张牌",
  ["#xh__rangjie-get"] = "让节：是否获得弃牌堆中同花色的牌？",

  ["$xh__rangjie1"] = "让节守礼，不失风度！",
  ["$xh__rangjie2"] = "礼让为先，节操为重！",
}

rangjie:addEffect(fk.Damaged, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(rangjie.name) and
      data.damage == 1
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = rangjie.name,
      prompt = "#xh__rangjie-move",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    -- 移动场上的一张牌（简化处理）
    -- 选择来源
    local froms = table.filter(room.alive_players, function(p)
      return not p:isNude()
    end)
    
    if #froms == 0 then return end
    
    local from = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = froms,
      skill_name = rangjie.name,
      prompt = "选择移动牌的来源",
      cancelable = false,
    })[1]
    
    -- 选择牌
    local card_id = room:askToChooseCard(player, {
      target = from,
      flag = "he",
      skill_name = rangjie.name,
    })
    
    local card = Fk:getCardById(card_id)
    
    -- 选择目标
    local tos = table.filter(room.alive_players, function(p)
      return p ~= from
    end)
    
    if #tos == 0 then return end
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = tos,
      skill_name = rangjie.name,
      prompt = "选择移动牌的目标",
      cancelable = false,
    })[1]
    
    room:moveCardTo(card_id, Player.Hand, to, fk.ReasonGive, rangjie.name, nil, false, from.id)
    
    -- 询问是否获得弃牌堆中同花色的牌
    local suit = card.suit
    local discard_pile = room.discard_pile
    local same_suit_cards = table.filter(discard_pile, function(id)
      return Fk:getCardById(id).suit == suit
    end)
    
    if #same_suit_cards > 0 then
      if room:askToSkillInvoke(player, {
        skill_name = rangjie.name,
        prompt = "#xh__rangjie-get",
      }) then
        local get_id = room:askToCards(player, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = rangjie.name,
          pattern = tostring(Exppattern{ id = same_suit_cards }),
          prompt = "选择一张同花色的牌获得",
          cancelable = false,
        })
        
        room:moveCardTo(get_id[1], Player.Hand, player, fk.ReasonPrey, rangjie.name)
      end
    end
  end,
})

return rangjie
