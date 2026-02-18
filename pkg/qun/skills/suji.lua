-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张燕 - 肃疾技能
-- 已受伤角色的出牌阶段开始时，你可以将一张黑色牌当【杀】使用，
-- 若其受到此【杀】伤害，你获得其一张牌。

local suji = fk.CreateSkill {
  name = "suji",
}

Fk:loadTranslationTable {
  ["suji"] = "肃疾",
  [":suji"] = "已受伤角色的出牌阶段开始时，你可以将一张黑色牌当【杀】使用，"..
    "若其受到此【杀】伤害，你获得其一张牌。",

  ["#suji-invoke"] = "肃疾：你可以将一张黑色牌当【杀】对 %dest 使用",
  ["@@suji_damage"] = "肃疾",

  ["$suji1"] = "肃清奸佞，疾如闪电！",
  ["$suji2"] = "疾风骤雨，势不可挡！",
}

suji:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(suji.name) and
      target.phase == Player.Play and target:isWounded() and
      not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = suji.name,
      pattern = ".|.|black",
      prompt = "#suji-invoke::" .. target.id,
      cancelable = true,
    })

    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = event:getCostData(self).cards[1]

    -- 将黑色牌当杀使用
    local slash = Fk:cloneCard("slash")
    slash.skillName = suji.name
    slash:addSubcard(card)

    room:useCard{
      from = player.id,
      tos = {target.id},
      card = slash,
      extra_data = {suji_from = player.id},
    }
  end,
})

-- 造成伤害后获得牌
suji:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not data.card or data.card.skillName ~= suji.name then return false end
    return target == player and data.to and not data.to.dead and not data.to:isNude()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to

    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = suji.name,
    })
    room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, suji.name, nil, false, to.id)
  end,
})

return suji
