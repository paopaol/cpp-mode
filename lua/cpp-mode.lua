local M = {}

-- "### instance-method `Print`  \n\n---\n→ `void`  \nParameters:  \n- `int age`\n- `const char * name`\n\n---\n```cpp\n// In Printer\npublic: void Print(int age, const char *name) const\n```"
local generate_cpp_method = function(result)
  local contents = result["contents"].value
  local type = string.match(contents, '### ([a-z-]+)')
  local class_name = string.match(contents, '// In (%w+)')
  local signature = string.match(contents, '// In .+\n(.*)\n')
  print(type)
  if type == 'instance-method' or type == 'static-method' or type == 'constructor' then
    signature = (string.gsub(signature, '^[^:]+: ', ''))
    signature = (string.gsub(signature, '^public: ', ''))
    signature = (string.gsub(signature, '^private: ', ''))
    signature = (string.gsub(signature, '^protected: ', ''))
    signature = (string.gsub(signature, '^explicit ', ''))
    signature = (string.gsub(signature, '^static ', ''))
    local functon_name = string.match(contents, '### [a-z-]+ `(%w+)`')
    local before = functon_name .. '%('
    local after = class_name .. '::' .. functon_name .. '%('
    signature = (string.gsub(signature, before, after))
  end
  signature = string.format("%s\n{\n}\n", signature)
  vim.fn.setreg(0, signature)
end

M.copy_cpp_method = function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/hover', params,
    function(err, result, ctx, config)
    generate_cpp_method(result)
  end)
end

M.paste_cpp_method = function()
  vim.cmd([[normal! "0p]])
  vim.cmd([[normal! jo]])
  vim.cmd([[startinsert!]])
end



return M
