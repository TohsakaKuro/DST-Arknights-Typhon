-- 根据路径获取table中的值
local function get(source, path)
    string.gsub(path, '[^.]+', function(w)
        if source == nil then
            return nil
        end
        source = source[w]
    end)
    return source
end

return {
    get = get
}
