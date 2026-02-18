-- SPDX-License-Identifier: GPL-3.0-or-later
-- 赵云 - 龙胆技能
-- 你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出。

local longdan = fk.CreateSkill {
  name = "longdan",
}

Fk:loadTranslationTable {
  ["longdan"] = "龙胆",
  [":longdan"] = "你可以将一张【杀】当【闪】、【闪】当【杀】、【酒】当【桃】、【桃】当【酒】使用或打出。",

  ["$longdan1"] = "能进能退，乃真正法器！",
  ["$longdan2"] = "吾乃常山赵子龙也！",
}

longdan:addEffect("viewas", {
  mute = true,
  pattern = "slash,jink,analeptic,peach",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)

    -- 杀当闪，闪当杀
    if card.name == "slash" or card.name == "jink" then
      return true
    end

    -- 酒当桃，桃当酒
    if card.name == "analeptic" or card.name == "peach" then
      return true
    end

    return false
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end

    local card = Fk:getCardById(cards[1])
    local new_card

    if card.name == "slash" then
      new_card = Fk:cloneCard("jink")
    elseif card.name == "jink" then
      new_card = Fk:cloneCard("slash")
    elseif card.name == "analeptic" then
      new_card = Fk:cloneCard("peach")
    elseif card.name == "peach" then
      new_card = Fk:cloneCard("analeptic")
    else
      return nil
    end

    new_card.skillName = longdan.name
    new_card:addSubcard(cards[1])
    return new_card
  end,
  enabled_at_play = function(self, player)
    -- 可以使用杀、酒、桃
    return player:canUse(Fk:cloneCard("slash")) or
           player:canUse(Fk:cloneCard("analeptic")) or
           player:canUse(Fk:cloneCard("peach"))
  end,
  enabled_at_response = function(self, player)
    return true
  end,
})

return longdan
