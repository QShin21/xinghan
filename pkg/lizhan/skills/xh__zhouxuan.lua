local zhouxuan = fk.CreateSkill{
  name = "xh__zhouxuan",
  derived_piles = "$xh__zhanghe_xuan",
}

Fk:loadTranslationTable{
  ["xh__zhouxuan"] = "周旋",
  [":xh__zhouxuan"] = "弃牌阶段开始时，你可以将任意张手牌扣置于你的武将牌上，称为“旋”（至多五张），直到你下个出牌阶段结束。当你使用牌时你移去一张“旋”并摸一张牌。",
  
  ["#xh__zhouxuan-invoke"] = "周旋：你可以将至多%arg张手牌置为“旋”",
  
  ["$xh__zhanghe_xuan"] = "旋",
  ["$xh__zhouxuan1"] = "详勘细察，洞若观火。",
  ["$xh__zhouxuan2"] = "知敌底细，方能百战百胜。",
}

-- 弃牌阶段，选择手牌扣置为“旋”
zhouxuan:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhouxuan.name) and player.phase == Player.Discard and
      not player:isKongcheng() and #player:getPile("$xh__zhanghe_xuan") < 5
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local x = 5 - #player:getPile("$xh__zhanghe_xuan")
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = x,
      include_equip = false,
      skill_name = zhouxuan.name,
      prompt = "#xh__zhouxuan-invoke:::"..x,
      cancelable = true,
    })
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player:addToPile("$xh__zhanghe_xuan", event:getCostData(self).cards, false, zhouxuan.name)
  end,
})

-- 出牌阶段结束时移除“旋”
zhouxuan:addEffect(fk.EventPhaseEnd, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and #player:getPile("$xh__zhanghe_xuan") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$xh__zhanghe_xuan"), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile,
      zhouxuan.name, nil, true, player)
  end,
})

-- 使用牌时移去“旋”并摸一张牌
zhouxuan:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and #player:getPile("$xh__zhanghe_xuan") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 1
    -- 如果不是唯一手牌数最大的角色，则摸X张牌
    if table.find(room:getOtherPlayers(player, false), function(p)
      return p:getHandcardNum() >= player:getHandcardNum()
    end) then
      n = #player:getPile("$xh__zhanghe_xuan")
    end
    player:drawCards(n, zhouxuan.name)
    if not player.dead and #player:getPile("$xh__zhanghe_xuan") > 0 then
      -- 随机移去一张“旋”
      room:moveCardTo(table.random(player:getPile("$xh__zhanghe_xuan")), Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile,
        zhouxuan.name, nil, true, player)
    end
  end,
})

return zhouxuan