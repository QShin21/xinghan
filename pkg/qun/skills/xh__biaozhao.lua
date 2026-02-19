-- SPDX-License-Identifier: GPL-3.0-or-later
-- 许贡 - 表召技能
-- 结束阶段，你可以将一张牌置于武将牌上，称为"表"。
-- 当有一张与"表"点数相同的牌进入弃牌堆时，你移去"表"并失去1点体力。
-- 准备阶段，若你的武将牌上有"表"，则你移去"表"并选择一名角色，该角色回复1点体力并摸三张牌。

local biaozhao = fk.CreateSkill {
  name = "xh__biaozhao",
}

Fk:loadTranslationTable {
  ["xh__biaozhao"] = "表召",
  [":xh__biaozhao"] = "结束阶段，你可以将一张牌置于武将牌上，称为\"表\"。"..
    "当有一张与\"表\"点数相同的牌进入弃牌堆时，你移去\"表\"并失去1点体力。"..
    "准备阶段，若你的武将牌上有\"表\"，则你移去\"表\"并选择一名角色，该角色回复1点体力并摸三张牌。",

  ["#xh__biaozhao-place"] = "表召：选择一张牌置为表",
  ["@@xh__biaozhao_biao"] = "表",

  ["$xh__biaozhao1"] = "表召之计，借刀杀人！",
  ["$xh__biaozhao2"] = "许贡表召，天下大乱！",
}

biaozhao:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(biaozhao.name) then return false end
    if player.phase ~= Player.Finish then return false end
    return not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = biaozhao.name,
      pattern = ".",
      prompt = "#xh__biaozhao-place",
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
    
    -- 置为表
    room:moveCardTo(card_id, Card.Processing, player, fk.ReasonPut, biaozhao.name)
    room:setPlayerMark(player, "@@biaozhao_biao", card_id)
  end,
})

-- 准备阶段处理表
biaozhao:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(biaozhao.name) then return false end
    if player.phase ~= Player.Start then return false end
    
    local biao = player:getMark("@@biaozhao_biao")
    return biao and biao ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local biao = player:getMark("@@biaozhao_biao")
    
    -- 移去表
    room:moveCardTo(biao, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, biaozhao.name)
    room:setPlayerMark(player, "@@biaozhao_biao", 0)
    
    -- 选择一名角色
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room.alive_players,
      skill_name = biaozhao.name,
      prompt = "选择一名角色回复1点体力并摸三张牌",
      cancelable = false,
    })[1]
    
    room:recover{
      who = to,
      num = 1,
      recoverBy = player,
      skillName = biaozhao.name,
    }
    to:drawCards(3, biaozhao.name)
  end,
})

-- 弃牌堆检测
biaozhao:addEffect(fk.AfterCardsMove, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(biaozhao.name) then return false end
    
    local biao = player:getMark("@@biaozhao_biao")
    if not biao or biao == 0 then return false end
    
    local biao_card = Fk:getCardById(biao)
    
    for _, move in ipairs(data) do
      if move.toArea == Card.DiscardPile then
        for _, info in ipairs(move.moveInfo) do
          local card = Fk:getCardById(info.cardId)
          if card.number == biao_card.number then
            return true
          end
        end
      end
    end
    
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local biao = player:getMark("@@biaozhao_biao")
    
    -- 移去表
    room:moveCardTo(biao, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, biaozhao.name)
    room:setPlayerMark(player, "@@biaozhao_biao", 0)
    
    -- 失去1点体力
    room:loseHp(player, 1, biaozhao.name)
  end,
})

return biaozhao
