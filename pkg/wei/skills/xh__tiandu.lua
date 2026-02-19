-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭嘉 - 天妒技能
-- 转换技，出牌阶段开始时，你可以：
-- 阳：弃置两张手牌，然后视为使用任意一张普通锦囊牌；
-- 阴：进行判定并获得此判定牌，然后若你因发动此技能而弃置过与结果花色相同的牌，你受到1点无来源伤害。

local tiandu = fk.CreateSkill {
  name = "xh__tiandu",
}

Fk:loadTranslationTable {
  ["xh__tiandu"] = "天妒",
  [":xh__tiandu"] = "转换技，出牌阶段开始时，你可以："..
    "阳：弃置两张手牌，然后视为使用任意一张普通锦囊牌；"..
    "阴：进行判定并获得此判定牌，然后若你因发动此技能而弃置过与结果花色相同的牌，你受到1点无来源伤害。",

  ["#xh__tiandu-yang"] = "天妒（阳）：弃置两张手牌，视为使用一张普通锦囊牌",
  ["#xh__tiandu-yin"] = "天妒（阴）：进行判定并获得此判定牌",
  ["@@xh__tiandu-state"] = "天妒状态",

  ["$xh__tiandu1"] = "天意如此，奈何？",
  ["$xh__tiandu2"] = "得之我幸，失之我命。",
}

-- 转换技状态
tiandu:addEffect(fk.GameStart, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(tiandu.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@tiandu-state", "yang")
  end,
})

tiandu:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tiandu.name) and player.phase == Player.Play
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local state = player:getMark("@@tiandu-state")

    if state == "yang" then
      -- 阳：需要两张手牌
      if player:getHandcardNum() < 2 then return false end
      return room:askToSkillInvoke(player, {
        skill_name = tiandu.name,
        prompt = "#xh__tiandu-yang",
      })
    else
      -- 阴
      return room:askToSkillInvoke(player, {
        skill_name = tiandu.name,
        prompt = "#xh__tiandu-yin",
      })
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local state = player:getMark("@@tiandu-state")

    if state == "yang" then
      -- 阳：弃置两张手牌，视为使用普通锦囊牌
      local cards = room:askToCards(player, {
        min_num = 2,
        max_num = 2,
        include_equip = false,
        skill_name = tiandu.name,
        pattern = ".",
        cancelable = false,
      })

      -- 记录弃置牌的花色
      local suits = {}
      for _, id in ipairs(cards) do
        local card = Fk:getCardById(id)
        table.insertIfNeed(suits, card.suit)
      end
      room:setPlayerMark(player, "@@tiandu_suits", suits)

      room:throwCard(cards, tiandu.name, player, player)

      -- 选择要使用的普通锦囊牌
      local trick_names = {}
      for name, _ in pairs(Fk.packages["standard_cards"].cards) do
        local card = Fk.cards[name]
        if card and card.type == Card.TypeTrick and not card.is_derived then
          table.insert(trick_names, name)
        end
      end

      if #trick_names > 0 then
        local choice = room:askToChoice(player, {
          choices = trick_names,
          skill_name = tiandu.name,
          prompt = "选择要使用的普通锦囊牌",
          detailed = true,
        })

        if choice then
          local card = Fk:cloneCard(choice)
          card.skillName = tiandu.name
          room:useCard({
            from = player.id,
            cards = {},
            card = card,
          })
        end
      end

      -- 切换状态
      room:setPlayerMark(player, "@@tiandu-state", "yin")
    else
      -- 阴：进行判定并获得此判定牌
      local judge = {
        who = player,
        reason = tiandu.name,
        pattern = ".",
      }
      room:judge(judge)

      -- 获得判定牌
      if judge.card then
        room:moveCardTo(judge.card.id, Player.Hand, player, fk.ReasonPrey, tiandu.name)

        -- 检查是否弃置过相同花色的牌
        local suits = player:getMark("@@tiandu_suits")
        if suits and #suits > 0 then
          local card = Fk:getCardById(judge.card.id)
          if table.contains(suits, card.suit) then
            room:damage{
              to = player,
              damage = 1,
              skillName = tiandu.name,
            }
          end
        end
      end

      -- 清除花色记录
      room:setPlayerMark(player, "@@tiandu_suits", nil)

      -- 切换状态
      room:setPlayerMark(player, "@@tiandu-state", "yang")
    end
  end,
})

return tiandu
