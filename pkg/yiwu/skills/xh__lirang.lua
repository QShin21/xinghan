-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孔融 - 礼让技能
-- 当你的牌因弃置而置入弃牌堆后，你可以将其中的任意张牌交给其他角色；
-- 一名角色的结束阶段，你摸等同于你本回合以此法交给其他角色牌数的牌。

local lirang = fk.CreateSkill {
  name = "xh__lirang",
}

Fk:loadTranslationTable {
  ["xh__lirang"] = "礼让",
  [":xh__lirang"] = "当你的牌因弃置而置入弃牌堆后，你可以将其中的任意张牌交给其他角色；"..
    "一名角色的结束阶段，你摸等同于你本回合以此法交给其他角色牌数的牌。",

  ["#xh__lirang-give"] = "礼让：是否将弃牌交给其他角色？",
  ["@@xh__lirang_count"] = "礼让计数",

  ["$xh__lirang1"] = "礼让为先，谦逊待人！",
  ["$xh__lirang2"] = "孔融让梨，千古美谈！",
}

lirang:addEffect(fk.AfterCardsMove, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(lirang.name) then return false end
    
    local moved_cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insert(moved_cards, info.cardId)
          end
        end
      end
    end
    
    if #moved_cards == 0 then return false end
    
    event:setCostData(self, {cards = moved_cards})
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = lirang.name,
      prompt = "#xh__lirang-give",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    
    -- 选择要给的牌
    local to_give = room:askToCards(player, {
      min_num = 1,
      max_num = #cards,
      include_equip = false,
      skill_name = lirang.name,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "选择要交给其他角色的牌",
      cancelable = true,
    })
    
    if #to_give == 0 then return end
    
    -- 选择目标
    local targets = room:getOtherPlayers(player, false)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = lirang.name,
      prompt = "选择一名角色获得这些牌",
      cancelable = false,
    })[1]
    
    room:moveCardTo(to_give, Player.Hand, to, fk.ReasonGive, lirang.name, nil, false, player.id)
    
    -- 记录给出的牌数
    room:addPlayerMark(player, "@@lirang_count", #to_give)
  end,
})

-- 结束阶段摸牌
lirang:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lirang.name) and
      player.phase == Player.Finish and player:getMark("@@lirang_count") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@@lirang_count")
    player:drawCards(count, lirang.name)
    room:setPlayerMark(player, "@@lirang_count", 0)
  end,
})

return lirang
