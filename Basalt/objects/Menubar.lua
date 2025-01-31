local utils = require("utils")
local tHex = require("tHex")

return function(name, basalt)
    local base = basalt.getObject("List")(name, basalt)
    base:setType("Menubar")
    local object = {}

    base:setSize(30, 1)
    base:setZ(5)

    base:addProperty("ItemOffset", "number", 0)
    base:addProperty("Space", "number", 1)

    local function maxScroll()
        local mScroll = 0
        local w = base:getWidth()
        local list = base:getAll()
        local space = base:getSpace()
        for n = 1, #list do
            mScroll = mScroll + list[n].text:len() + space * 2
        end
        return math.max(mScroll - w, 0)
    end

    object = {
        init = function(self)
            self:listenEvent("mouse_click")
            self:listenEvent("mouse_drag")
            self:listenEvent("mouse_scroll")
            return base.init(self)
        end,

        getBase = function(self)
            return base
        end,

        mouseHandler = function(self, button, x, y)
            if(base:getBase().mouseHandler(self, button, x, y))then
                local objX, objY = self:getAbsolutePosition()
                local w,h = self:getSize()
                    local xPos = 0
                    local list = self:getAll()
                    local space = self:getSpace()
                    local itemOffset = self:getItemOffset()
                    for n = 1, #list do
                        if (list[n] ~= nil) then
                            if (objX + xPos <= x + itemOffset) and (objX + xPos + list[n].text:len() + (space*2) > x + itemOffset) and (objY == y) then
                                self:setValue(list[n])
                                self:selectHandler()
                            end
                            xPos = xPos + list[n].text:len() + space * 2
                        end
                    end
                self:updateDraw()
                return true
            end
        end,

        scrollHandler = function(self, dir, x, y)
            if(base:getBase().scrollHandler(self, dir, x, y))then
                local scrollable = self:getScrollable()
                if(scrollable)then
                    local itemOffset = self:getItemOffset()
                    itemOffset = itemOffset + dir
                    if (itemOffset < 0) then
                        itemOffset = 0
                    end

                    local mScroll = maxScroll()

                    if (itemOffset > mScroll) then
                        itemOffset = mScroll
                    end
                    self:setItemOffset(itemOffset)
                    self:updateDraw()
                end
                return true
            end
            return false
        end,

        draw = function(self)
            base.draw(self)
            self:addDraw("list", function()
                local w,h = self:getSize()
                local text = ""
                local textBGCol = ""
                local textFGCol = ""
                local itemSelectedBG, itemSelectedFG = self:getSelectionColor()
                local itemOffset = self:getItemOffset()
                local space = self:getSpace()
                for _, v in pairs(self:getAll()) do
                    local newItem = (" "):rep(space) .. v.text .. (" "):rep(space)
                    text = text .. newItem
                    if(v == self:getValue())then
                        textBGCol = textBGCol .. tHex[itemSelectedBG or v.bgCol or self:getBackground()]:rep(newItem:len())
                        textFGCol = textFGCol .. tHex[itemSelectedFG or v.FgCol or self:getForeground()]:rep(newItem:len())
                    else
                        textBGCol = textBGCol .. tHex[v.bgCol or self:getBackground()]:rep(newItem:len())
                        textFGCol = textFGCol .. tHex[v.FgCol or self:getForeground()]:rep(newItem:len())
                    end
                end

                self:addBlit(1, 1, text:sub(itemOffset+1, w+itemOffset), textFGCol:sub(itemOffset+1, w+itemOffset), textBGCol:sub(itemOffset+1, w+itemOffset))
            end)
        end,
    }

    object.__index = object
    return setmetatable(object, base)
end