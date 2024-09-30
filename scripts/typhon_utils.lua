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

local function printTable(t, indent)
  indent = indent or 0
  local indentStr = string.rep("  ", indent)

  for k, v in pairs(t) do
    if type(v) == "table" then
      print(indentStr .. tostring(k) .. ":")
      printTable(v, indent + 1)
    else
      print(indentStr .. tostring(k) .. ": " .. tostring(v))
    end
  end
end

local function shuffleArray(array)
  local n = #array
  for i = n, 2, -1 do
    local j = math.random(i)
    array[i], array[j] = array[j], array[i]
  end
end

local function truncateArray(arr, length)
  if #arr > length then
    for i = #arr, length + 1, -1 do
      table.remove(arr, i)
    end
  end
end

local function concatArray(arr1, arr2)
  local newArr = {}
  for i, v in ipairs(arr1) do
    table.insert(newArr, v)
  end
  for i, v in ipairs(arr2) do
    table.insert(newArr, v)
  end
  return newArr
end

return {
  get = get,
  printTable = printTable,
  shuffleArray = shuffleArray,
  truncateArray = truncateArray,
  concatArray = concatArray
}
