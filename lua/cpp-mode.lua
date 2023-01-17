local M = {
}

local context = {
  signature = nil
}


local function class_name(markdown)
  return string.match(markdown, '// In (%w+)')
end

local function method_handler(markdown, signature)
  local functon_name = string.match(markdown, '### [a-z-]+ `(%w+)`')
  local before = functon_name .. '%('
  local after = class_name(markdown) .. '::' .. functon_name .. '%('
  return string.gsub(signature, before, after)
end

local function function_handler(markdown, signature)
  return signature
end

local handler = {
  ["instance-method"] = method_handler,
  ["function"] = function_handler,
  ["constructor"] = method_handler,
}

local function create_markdown_tmp_buf(markdown)
  local br = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_lines(br, 0, 0, true, vim.split(markdown, '\n'))
  vim.api.nvim_buf_set_option(br, 'filetype', 'markdown')

  return br
end

local function type(markdown)
  return string.match(markdown, '### ([a-z-]+)')
end

local function signature(br)
  local range = {}
  vim.api.nvim_buf_call(br, function()
    local pos = vim.fn.searchpos('```cpp', 'n')
    pos[1]    = pos[1] + 1

    range["start"] = pos
  end)

  vim.api.nvim_buf_call(br, function()
    local pos    = vim.fn.searchpos('```$', 'n')
    pos[1]       = pos[1] - 1
    range["end"] = pos
  end)

  if range["start"][1] == range["end"][1] then
    range["start"][1] = range["start"][1] - 1
  end
  local lines = vim.api.nvim_buf_get_lines(br, range["start"][1], range["end"][1], true)

  return vim.fn.join(lines, '')
end

local function remove_keywords(signature)
  local keywords = {
    '^[^:]+: ',
    '^public: ',
    '^private: ',
    '^protected: ',
    '^explicit ',
    '^static ',
    '^inline ',
  }

  for _, key in pairs(keywords) do
    signature = (string.gsub(signature, key, ''))
  end

  return signature
end

-- "### instance-method `Print`  \n\n---\n→ `void`  \nParameters:  \n- `int age`\n- `const char * name`\n\n---\n```cpp\n// In Printer\npublic: void Print(int age, const char *name) const\n```"
local generate_cpp_method = function(result)
  local markdown = result["contents"].value

  local br = create_markdown_tmp_buf(markdown)

  local method = handler[type(markdown)](markdown, remove_keywords(signature(br)))
  method = string.gsub(method, '  ', '')
  method = string.format("%s{}", method)
  context.signature = vim.fn.split(method, '\n')

  vim.api.nvim_buf_delete(br, {})
end

M.copy_cpp_method = function()
  context.signature = nil
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, 'textDocument/hover', params,
    function(err, result, ctx, config)
      generate_cpp_method(result)
    end)
end

M.paste_cpp_method = function()
  if context.signature then
    local s = vim.fn.line('.')
    vim.api.nvim_buf_set_lines(0, s, s, false, context.signature)
    vim.cmd([[normal! j]])
  end
end



return M
