function M.{{CONDITION_FUNC}}()
    local result = false
    print("[CONDITION] {{CONDITION_NAME}}: " .. tostring(result))
    return result and bt.SUCCESS or bt.FAILED
end

