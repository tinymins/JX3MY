-- Configuration authoring example, not a standalone importable jx3dat package.
-- Bind tCountdown to a real event and adjust duration before use.
-- Offline members are skipped; all readable online members are included.
local tVars = {
    nVersion = 1,
    szUnavailable = '团队状态不完整',
    bUpdate = true,
    nDebounce = 100,
    aQueries = {
        { szName = 'calc_total', dwBuffID = 34095, nStackNum = 0 },
        { szName = 'calc_red1', dwBuffID = 34095, nStackNum = 1, szStackOp = '==', aExcludeBuffIDs = { 34096, 34097 } },
        { szName = 'calc_red2', dwBuffID = 34095, nStackNum = 2, szStackOp = '==', aExcludeBuffIDs = { 34096, 34097 } },
        { szName = 'calc_zero', dwBuffID = 34095, nStackNum = 0, szStackOp = '==', aExcludeBuffIDs = { 34096, 34097 } },
        { szName = 'calc_black1', dwBuffID = 34096, nStackNum = 1, szStackOp = '==', aExcludeBuffIDs = { 34095, 34097 } },
        { szName = 'calc_black2', dwBuffID = 34096, nStackNum = 2, szStackOp = '==', aExcludeBuffIDs = { 34095, 34097 } },
    },
    aValues = {
        {
            szName = 'calc_other',
            tExpression = { 'sub', { 'sub', { 'sub', { 'sub', { 'sub',
                'calc_total', 'calc_red1' }, 'calc_red2' }, 'calc_zero' }, 'calc_black1' }, 'calc_black2' },
        },
    },
}

return {
    tCountdown = {
        { nClass = 8, key = 'example-six-red1', nTime = 20, nRefresh = 0, szName = '红1：{$calc_red1}人', tVars = tVars },
        { nClass = 8, key = 'example-six-red2', nTime = 20, nRefresh = 0, szName = '红2：{$calc_red2}人', tVars = tVars },
        { nClass = 8, key = 'example-six-zero', nTime = 20, nRefresh = 0, szName = '0：{$calc_zero}人', tVars = tVars },
        { nClass = 8, key = 'example-six-black1', nTime = 20, nRefresh = 0, szName = '黑1：{$calc_black1}人', tVars = tVars },
        { nClass = 8, key = 'example-six-black2', nTime = 20, nRefresh = 0, szName = '黑2：{$calc_black2}人', tVars = tVars },
        { nClass = 8, key = 'example-six-other', nTime = 20, nRefresh = 0, szName = '其他：{$calc_other}人', tVars = tVars },
    },
}
