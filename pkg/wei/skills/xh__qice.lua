-- SPDX-License-Identifier: GPL-3.0-or-later
-- 荀攸 - 奇策技能
-- 出牌阶段限一次，你可以将所有的手牌（至少一张）当做任意一张普通锦囊牌使用。

local qice = fk.CreateSkill {
  name = "xh__qice",
}

Fk:loadTranslationTable {
  ["xh__qice"] = "奇策",
  [":xh__qice"] = "出牌阶段限一次，你可以将所有的手牌（至少一张）当做任意一张普通锦囊牌使用。",

  ["#xh__qice-use"] = "奇策：将所有手牌当普通锦囊牌使用",

  ["$xh__qice1"] = "奇策百出，算无遗策！",
  ["$xh__qice2"] = "运筹帷幄，决胜千里！",
}

qice:addEffect("active", {
  mute = true,
  prompt = "#qice-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(xh__qice.name, Player.HistoryPhase) == 0 and
      not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, xh__qice.name, "offensive")
    player:broadcastSkillInvoke(xh__qice.name)

    local handcards = player:getCardIds("h")

    -- 获取所有普通锦囊牌名称
    local trick_names = {}
    for _, card in pairs(Fk.cards) do
      if card and card.type == Card.TypeTrick and not card.is_derived then
        table.insert(trick_names, card.name)
      end
    end

    if #trick_names == 0 then return end

    -- 让玩家选择要使用的锦囊牌
    local choice = room:askToChoice(player, {
      choices = trick_names,
      skill_name = xh__qice.name,
      prompt = "选择要使用的普通锦囊牌",
      detailed = true,
    })

    if not choice then return end

    local card = Fk:cloneCard(choice)
    card.skillName = xh__qice.name
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
