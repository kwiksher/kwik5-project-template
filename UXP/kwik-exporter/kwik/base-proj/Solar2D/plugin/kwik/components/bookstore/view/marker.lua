local M = {}

function M.new (dst, group)
    print(dst, group)
    if dst.updateMark == nil then
        local obj = display.newCircle(0,0,4)
        obj.x = dst.x + dst.width/2
        obj.y = dst.y - dst.height/2
        obj:setFillColor(1,0,0)
        group:insert(obj)
        dst.updateMark = obj
    else
        dst.updateMark.alpha = 1
    end
end

return M