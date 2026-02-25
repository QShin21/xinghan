-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 义武武将包
local extension = Package:new("xinhan_yiwu")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/yiwu/skills")

Fk:loadTranslationTable {
  ["xinhan_yiwu"] = "星汉灿烂·义武",
}


-- 以下为魏国武将

-- 曹洪，男，魏，4勾玉
General:new(extension, "xh__caohong", "wei", 4):addSkills { "xh__yuanhu" }
Fk:loadTranslationTable {
  ["xh__caohong"] = "曹洪",
  ["#xh__caohong"] = "忠烈护主",
  ["illustrator:xh__caohong"] = "KayaK",
  ["~xh__caohong"] = "将军走好！",
}

-- 曹仁，男，魏，4勾玉
General:new(extension, "xh__caoren", "wei", 4):addSkills { "xh__sujun", "xh__lifeng" }
Fk:loadTranslationTable {
  ["xh__caoren"] = "曹仁",
  ["#xh__caoren"] = "大将军",
  ["illustrator:xh__caoren"] = "KayaK",
  ["~xh__caoren"] = "实在是守不住了……",
}


-- 夏侯惇，男，魏，4勾玉
General:new(extension, "xh__xiahoudun", "wei", 4):addSkills { "ex__ganglie", "ex__qingjian" }
Fk:loadTranslationTable {
  ["xh__xiahoudun"] = "夏侯惇",
  ["#xh__xiahoudun"] = "独眼的罗刹",
  ["illustrator:xh__xiahoudun"] = "KayaK",
  ["~xh__xiahoudun"] = "独目残躯，不惧生死。",
}

-- 许褚，男，魏，4勾玉
General:new(extension, "xh__xuchu", "wei", 4):addSkills { "ex__luoyi" }
Fk:loadTranslationTable {
  ["xh__xuchu"] = "许褚",
  ["#xh__xuchu"] = "虎痴",
  ["illustrator:xh__xuchu"] = "KayaK",
  ["~xh__xuchu"] = "冷……好冷……",
}

-- 张辽，男，魏，4勾玉
General:new(extension, "xh__zhangliao", "wei", 4):addSkills { "ex__tuxi" }
Fk:loadTranslationTable {
  ["xh__zhangliao"] = "张辽",
  ["#xh__zhangliao"] = "前将军",
  ["illustrator:xh__zhangliao"] = "KayaK",
  ["~xh__zhangliao"] = "真的没想到……",
}

-- 荀彧，男，魏，3勾玉
General:new(extension, "xh__xunyu", "wei", 3):addSkills { "quhu", "m_ex__jieming" }
Fk:loadTranslationTable {
  ["xh__xunyu"] = "荀彧",
  ["#xh__xunyu"] = "王佐之才",
  ["illustrator:xh__xunyu"] = "KayaK",
  ["~xh__xunyu"] = "主公，臣去矣……",
}

-- 郭嘉，男，魏，3勾玉
General:new(extension, "xh__guojia", "wei", 3):addSkills { "mou__tiandu", "mou__yiji" }
Fk:loadTranslationTable {
  ["xh__guojia"] = "郭嘉",
  ["#xh__guojia"] = "早终的先知",
  ["illustrator:xh__guojia"] = "KayaK",
  ["~xh__guojia"] = "咳……咳……",
}

-- 乐进，男，魏，4勾玉
General:new(extension, "xh__lejin", "wei", 4):addSkills { "ty__xiaoguo" }
Fk:loadTranslationTable {
  ["xh__lejin"] = "乐进",
  ["#xh__lejin"] = "奋强突固",
  ["illustrator:xh__lejin"] = "KayaK",
  ["~xh__lejin"] = "力竭……",
}

-- 于禁，男，魏，4勾玉
General:new(extension, "xh__yujin", "wei", 4):addSkills { "ty_ex__zhenjun" }
Fk:loadTranslationTable {
  ["xh__yujin"] = "于禁",
  ["#xh__yujin"] = "弗克其终",
  ["illustrator:xh__yujin"] = "KayaK",
  ["~xh__yujin"] = "将军走好！",
}

-- 李典，男，魏，3勾玉
General:new(extension, "xh__lidian", "wei", 3):addSkills { "xunxun", "ol_ex__wangxi" }
Fk:loadTranslationTable {
  ["xh__lidian"] = "李典",
  ["#xh__lidian"] = "深明大义",
  ["illustrator:xh__lidian"] = "KayaK",
  ["~xh__lidian"] = "报国无门……",
}

-- 以下为蜀国武将

-- 赵云，男，蜀，4勾玉
General:new(extension, "xh__zhaoyun", "shu", 4):addSkills { "ol_ex__longdan", "ol_ex__yajiao" }
Fk:loadTranslationTable {
  ["xh__zhaoyun"] = "赵云",
  ["#xh__zhaoyun"] = "常山赵子龙",
  ["illustrator:xh__zhaoyun"] = "KayaK",
  ["~xh__zhaoyun"] = "这，就是失败的滋味吗……",
}

-- 张飞，男，蜀，4勾玉
General:new(extension, "xh__zhangfei", "shu", 4):addSkills { "ex__paoxiao", "ex__tishen" }
Fk:loadTranslationTable {
  ["xh__zhangfei"] = "张飞",
  ["#xh__zhangfei"] = "万夫不当",
  ["illustrator:xh__zhangfei"] = "KayaK",
  ["~xh__zhangfei"] = "实在是……打不动了……",
}

-- 关羽，男，蜀，4勾玉
General:new(extension, "xh__guanyu", "shu", 4):addSkills { "ex__wusheng", "ex__yijue" }
Fk:loadTranslationTable {
  ["xh__guanyu"] = "关羽",
  ["#xh__guanyu"] = "武圣",
  ["illustrator:xh__guanyu"] = "KayaK",
  ["~xh__guanyu"] = "什么？此地竟有……",
}



-- 以下为吴国武将



-- 孙坚，男，吴，4/5勾玉
General:new(extension, "xh__sunjian", "wu", 4, 5):addSkills { "yinghun" }
Fk:loadTranslationTable {
  ["xh__sunjian"] = "孙坚",
  ["#xh__sunjian"] = "江东猛虎",
  ["illustrator:xh__sunjian"] = "KayaK",
  ["~xh__sunjian"] = "有埋伏……呃……",
}

-- 黄盖，男，吴，4勾玉
General:new(extension, "xh__huanggai", "wu", 4):addSkills { "ex__kurou", "zhaxiang" }
Fk:loadTranslationTable {
  ["xh__huanggai"] = "黄盖",
  ["#xh__huanggai"] = "轻身为国",
  ["illustrator:xh__huanggai"] = "KayaK",
  ["~xh__huanggai"] = "再无……苦肉计了……",
}

-- 韩当，男，吴，4勾玉
General:new(extension, "xh__handang", "wu", 4):addSkills { "ty_ex__gongqi", "ty_ex__jiefan" }
Fk:loadTranslationTable {
  ["xh__handang"] = "韩当",
  ["#xh__handang"] = "石城侯",
  ["illustrator:xh__handang"] = "KayaK",
  ["~xh__handang"] = "江东……",
}


return extension
