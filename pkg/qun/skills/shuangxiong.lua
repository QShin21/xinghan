-- SPDX-License-Identifier: GPL-3.0-or-later
-- 颜良文丑 - 双雄技能
-- 摸牌阶段结束时，你可以弃置一张牌，然后本回合你可以将与之颜色不同的一张牌当【决斗】使用。
-- 结束阶段，你获得本回合对你造成伤害的牌。

local shuangxiong = fk.CreateSkill {
  name = "shuangxiong",
}

Fk:loadTranslationTable {
  ["shuangxiong"] = "双雄",
  [":shuangxiong"] = "摸牌阶段结束时，你可以弃置一张牌，然后本回合你可以将与之颜色不同的一张牌当【决斗】使用。"..
    "结束阶段，你获得本回合对你造成伤害的牌。",

  ["#shuangxiong-discard"] = "双雄：弃置一张牌，本回合可将不同颜色牌当【决斗】使用",
  ["@@shuangxiong_color"] = "双雄",
  ["@@shuangxiong_damage"] = "双雄伤害",

  ["$shuangxiong1"] = "双雄并立，天下无敌！",
  ["$shuangxiong2"] = "颜良文丑，勇冠三军！",
}

-- 摸牌阶段结束时弃牌
shuangxiong:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong.name) and
      player.phase == Player.Draw and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = shuangxiong.name,
      pattern = ".",
      prompt = "#shuangxiong-discard",
      cancelable = true,
    })

    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = Fk:getCardById(event:getCostData(self).cards[1])

    -- 记录颜色
    room:setPlayerMark(player, "@@shuangxiong_color", card.color)

    -- 弃置牌
    room:throwCard(event:getCostData(self).cards, shuangxiong.name, player, player)
  end,
})

-- 将不同颜色牌当决斗使用
shuangxiong:addEffect("viewas", {
  mute = true,
  pattern = "duel",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local color = player:getMark("@@shuangxiong_color")
    if color == 0 then return false end

    local card = Fk:getCardById(to_select)
    return card.color ~= color
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("duel")
    card.skillName = shuangxiong.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@@shuangxiong_color") ~= 0 and
      player:canUse(Fk:cloneCard("duel"))
  end,
})

-- 记录对你造成伤害的牌
shuangxiong:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong.name) and
      data.card and not data.card:isVirtual()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@@shuangxiong_damage", data.card.id)
  end,
})

-- 结束阶段获得伤害牌
shuangxiong:addEffect(fk.EventPhaseEnd, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong.name) and
      player.phase == Player.Finish and player:getMark("@@shuangxiong_damage") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getMark("@@shuangxiong_damage")

    if type(cards) == "table" then
      for _, id in ipairs(cards) do
        if table.contains(room.discard_pile, id) then
          room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, shuangxiong.name)
        end
      end
    elseif type(cards) == "number" then
      if table.contains(room.discard_pile, cards) then
        room:moveCardTo(cards, Player.Hand, player, fk.ReasonPrey, shuangxiong.name)
      end
    end

    room:setPlayerMark(player, "@@shuangxiong_damage", 0)
    room:setPlayerMark(player, "@@shuangxiong_color", 0)
  end,
})

return shuangxiong
