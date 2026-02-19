-- SPDX-License-Identifier: GPL-3.0-or-later
-- 吕布 - 利驭技能
-- 当你使用【杀】对一名其他角色造成伤害后，你可以获得其区域里的一张牌并展示之，
-- 然后若此牌为：非装备牌，其摸一张牌；装备牌，你视为对由其指定的另一名其他角色使用一张【决斗】。

local liyu = fk.CreateSkill {
  name = "xh__liyu",
}

Fk:loadTranslationTable {
  ["xh__liyu"] = "利驭",
  [":xh__liyu"] = "当你使用【杀】对一名其他角色造成伤害后，你可以获得其区域里的一张牌并展示之，"..
    "然后若此牌为：非装备牌，其摸一张牌；装备牌，你视为对由其指定的另一名其他角色使用一张【决斗】。",

  ["#xh__liyu-invoke"] = "利驭：获得 %dest 区域里的一张牌",
  ["#xh__liyu-duel"] = "利驭：选择一名角色使用【决斗】",

  ["$xh__liyu1"] = "人不为己，天诛地灭！",
  ["$xh__liyu2"] = "大丈夫相时而动！",
}

liyu:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(liyu.name) and
      data.card and data.card.trueName == "slash" and
      data.to and data.to ~= player and not data.to.dead and
      not data.to:isAllNude()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = liyu.name,
      prompt = "#xh__liyu-invoke::" .. data.to.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to

    -- 获得其区域里的一张牌
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "hej",
      skill_name = liyu.name,
    })

    local card = Fk:getCardById(id)

    -- 展示牌
    room:showCards(player, {id}, liyu.name)

    -- 获得牌
    room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, liyu.name, nil, false, to.id)

    -- 判断牌的类型
    if card.type == Card.TypeEquip then
      -- 装备牌：视为对由其指定的另一名角色使用决斗
      local targets = table.filter(room:getOtherPlayers(to), function(p)
        return p ~= player
      end)

      if #targets > 0 then
        local victim = room:askToChoosePlayers(to, {
          min_num = 1,
          max_num = 1,
          targets = targets,
          skill_name = liyu.name,
          prompt = "#xh__liyu-duel",
          cancelable = false,
        })[1]

        local duel = Fk:cloneCard("duel")
        duel.skillName = liyu.name
        room:useCard{
          from = player.id,
          tos = {victim.id},
          card = duel,
        }
      end
    else
      -- 非装备牌：其摸一张牌
      if not to.dead then
        to:drawCards(1, liyu.name)
      end
    end
  end,
})

return liyu
