-- SPDX-License-Identifier: GPL-3.0-or-later
-- 荀攸 - 奇策技能
-- 出牌阶段限一次，你可以将所有的手牌（至少一张）当做任意一张普通锦囊牌使用。

local qice = fk.CreateSkill {
  name = "qice",
}

Fk:loadTranslationTable {
  ["qice"] = "奇策",
  [":qice"] = "出牌阶段限一次，你可以将所有的手牌（至少一张）当做任意一张普通锦囊牌使用。",

  ["#qice-use"] = "奇策：将所有手牌当普通锦囊牌使用",

  ["$qice1"] = "奇策百出，算无遗策！",
  ["$qice2"] = "运筹帷幄，决胜千里！",
}

qice:addEffect("viewas", {
  mute = true,
  pattern = "trick",
  card_filter = function(self, player, to_select, selected)
    -- 必须选择所有手牌
    local handcards = player:getCardIds("h")
    if #handcards == 0 then return false end

    if #selected >= #handcards then return false end

    return table.contains(handcards, to_select)
  end,
  view_as = function(self, player, cards)
    local handcards = player:getCardIds("h")
    if #cards ~= #handcards or #cards == 0 then return nil end

    -- 需要玩家选择要使用的锦囊牌
    return nil  -- 这个技能需要特殊处理
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(qice.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
})

-- 使用active技能来处理
qice:addEffect("active", {
  mute = true,
  prompt = "#qice-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(qice.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, qice.name, "offensive")
    player:broadcastSkillInvoke(qice.name)

    local handcards = player:getCardIds("h")

    -- 获取所有普通锦囊牌名称
    local trick_names = {}
    for name, _ in pairs(Fk.packages["standard_cards"].cards) do
      local card = Fk.cards[name]
      if card and card.type == Card.TypeTrick and not card.is_derived then
        table.insert(trick_names, name)
      end
    end

    if #trick_names == 0 then return end

    -- 让玩家选择要使用的锦囊牌
    local choice = room:askToChoice(player, {
      choices = trick_names,
      skill_name = qice.name,
      prompt = "选择要使用的普通锦囊牌",
      detailed = true,
    })

    if not choice then return end

    local card = Fk:cloneCard(choice)
    card.skillName = qice.name
    for _, id in ipairs(handcards) do
      card:addSubcard(id)
    end

    -- 使用卡牌
    room:useCard{
      from = player.id,
      card = card,
    }
  end,
})

return qice
