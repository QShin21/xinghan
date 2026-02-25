-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂武将包 - 主入口文件

local prefix = "packages.xinhanwujiang.pkg."

-- 加载子扩展包
local yiwu = require(prefix .. "yiwu")
local lizhan = require(prefix .. "lizhan")

Fk:loadTranslationTable {
  ["xinhanwujiang"] = "星汉武将",
}

return {
  yiwu,
  lizhan
}
