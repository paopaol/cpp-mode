local M = {}

-- "### instance-method `Print`  \n\n---\n→ `void`  \nParameters:  \n- `int age`\n- `const char * name`\n\n---\n```cpp\n// In Printer\npublic: void Print(int age, const char *name) const\n```"
local generate_cpp_method = function(result)
  local contents = result["contents"].value
  local type = string.match(contents, 'instance%-(%w+)')
  local class_name = string.match(contents, '// In (%w+)')
  local signature = string.match(contents, '// In .+\n(.*)\n')
  if type == 'method' then
    signature = (string.gsub(signature, '^[^:]+:', ''))
    local functon_name = string.match(contents, 'instance%-method `(%w+)`')
    local before = functon_name .. '%('
    local after = class_name .. '::' .. functon_name .. '%('
    signature = (string.gsub(signature, before, after))
  end
  vim.call('setreg', '0', signature)
end

M.copy_cpp_method = function()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/hover', params,
                      function(err, method, result, client_id, bufnr, config)
    generate_cpp_method(result)
  end)
end

M.paste_cpp_method = function() vim.fn.setline('.', vim.fn.getreg('0')) end

return M
