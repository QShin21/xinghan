-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 蜀国武将包
local extension = Package:new("xinhan_shu")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/shu/skills")

Fk:loadTranslationTable {
  ["xinhan_shu"] = "星汉灿烂·蜀",
}

-- 赵云，男，蜀，4勾玉
General:new(extension, "xh__zhaoyun", "shu", 4):addSkills { "xh__longdan", "xh__yajiao" }
Fk:loadTranslationTable {
  ["xh__zhaoyun"] = "赵云",
  ["#xh__zhaoyun"] = "常山赵子龙",
  ["illustrator:xh__zhaoyun"] = "KayaK",
  ["~xh__zhaoyun"] = "这，就是失败的滋味吗……",
}

-- 张飞，男，蜀，4勾玉
General:new(extension, "xh__zhangfei", "shu", 4):addSkills { "xh__paoxiao", "xh__tishen" }
Fk:loadTranslationTable {
  ["xh__zhangfei"] = "张飞",
  ["#xh__zhangfei"] = "万夫不当",
  ["illustrator:xh__zhangfei"] = "KayaK",
  ["~xh__zhangfei"] = "实在是……打不动了……",
}

-- 关羽，男，蜀，4勾玉
General:new(extension, "xh__guanyu", "shu", 4):addSkills { "xh__wusheng", "xh__yijue" }
Fk:loadTranslationTable {
  ["xh__guanyu"] = "关羽",
  ["#xh__guanyu"] = "武圣",
  ["illustrator:xh__guanyu"] = "KayaK",
  ["~xh__guanyu"] = "什么？此地竟有……",
}

-- 刘备，男，蜀，4勾玉
General:new(extension, "xh__liubei", "shu", 4):addSkills { "xh__renwang" }
Fk:loadTranslationTable {
  ["xh__liubei"] = "刘备",
  ["#xh__liubei"] = "乱世的枭雄",
  ["illustrator:xh__liubei"] = "KayaK",
  ["~xh__liubei"] = "这就是……桃园吗……",
}

-- 诸葛亮，男，蜀，3勾玉
General:new(extension, "xh__zhugeliang", "shu", 3):addSkills { "xh__bazhen", "xh__huoji", "xh__kanpo" }
Fk:loadTranslationTable {
  ["xh__zhugeliang"] = "诸葛亮",
  ["#xh__zhugeliang"] = "卧龙",
  ["illustrator:xh__zhugeliang"] = "KayaK",
  ["~xh__zhugeliang"] = "将星陨落……",
}

-- 黄月英，女，蜀，3勾玉
General:new(extension, "xh__huangyueying", "shu", 3, 3, General.Female):addSkills { "xh__jizhi", "xh__qicai" }
Fk:loadTranslationTable {
  ["xh__huangyueying"] = "黄月英",
  ["#xh__huangyueying"] = "归隐的杰女",
  ["illustrator:xh__huangyueying"] = "KayaK",
  ["~xh__huangyueying"] = "亮……",
}

-- 孙乾，男，蜀，3勾玉
General:new(extension, "xh__sunqian", "shu", 3):addSkills { "xh__shuomeng" }
Fk:loadTranslationTable {
  ["xh__sunqian"] = "孙乾",
  ["#xh__sunqian"] = "说客",
  ["illustrator:xh__sunqian"] = "KayaK",
  ["~xh__sunqian"] = "主公……",
}

-- 张世平，男，蜀，3勾玉
General:new(extension, "xh__zhangshiping", "shu", 3):addSkills { "xh__hongji" }
Fk:loadTranslationTable {
  ["xh__zhangshiping"] = "张世平",
  ["#xh__zhangshiping"] = "商贾",
  ["illustrator:xh__zhangshiping"] = "KayaK",
  ["~xh__zhangshiping"] = "生意……",
}

-- 马超，男，蜀，4勾玉
General:new(extension, "xh__machao", "shu", 4):addSkills { "xh__mashu", "xh__tieji" }
Fk:loadTranslationTable {
  ["xh__machao"] = "马超",
  ["#xh__machao"] = "一骑当千",
  ["illustrator:xh__machao"] = "KayaK",
  ["~xh__machao"] = "西凉……",
}

-- 关平，男，蜀，4勾玉
General:new(extension, "xh__guanping", "shu", 4):addSkills { "xh__longyin", "xh__jiezhong" }
Fk:loadTranslationTable {
  ["xh__guanping"] = "关平",
  ["#xh__guanping"] = "忠义",
  ["illustrator:xh__guanping"] = "KayaK",
  ["~xh__guanping"] = "父亲……",
}

-- 魏延，男，蜀，4勾玉
General:new(extension, "xh__weiyan", "shu", 4):addSkills { "xh__kuanggu", "xh__qimou" }
Fk:loadTranslationTable {
  ["xh__weiyan"] = "魏延",
  ["#xh__weiyan"] = "狂骨",
  ["illustrator:xh__weiyan"] = "KayaK",
  ["~xh__weiyan"] = "谁敢杀我！",
}

-- 黄忠，男，蜀，4勾玉
General:new(extension, "xh__huangzhong", "shu", 4):addSkills { "xh__liegong" }
Fk:loadTranslationTable {
  ["xh__huangzhong"] = "黄忠",
  ["#xh__huangzhong"] = "老当益壮",
  ["illustrator:xh__huangzhong"] = "KayaK",
  ["~xh__huangzhong"] = "老矣……",
}

-- 徐庶，男，蜀，4勾玉
General:new(extension, "xh__xushu", "shu", 4):addSkills { "xh__zhuhai", "xh__qianxin" }
Fk:loadTranslationTable {
  ["xh__xushu"] = "徐庶",
  ["#xh__xushu"] = "忠孝",
  ["illustrator:xh__xushu"] = "KayaK",
  ["~xh__xushu"] = "母亲……",
}

return extension
