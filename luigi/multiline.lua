local Multiline = {}

function Multiline.wrap (font, text, limit)
    local lines = {{ width = 0 }}
    local advance = 0
    local lastSpaceAdvance = 0

    local function append (word, space)
        local wordAdvance = font:getAdvance(word)
        local spaceAdvance = font:getAdvance(space)
        local words = lines[#lines]
        if advance + wordAdvance > limit then
            words.width = (words.width or 0) - lastSpaceAdvance
            advance = wordAdvance + spaceAdvance
            lines[#lines + 1] = { width = advance, word, space }
        else
            advance = advance + wordAdvance + spaceAdvance
            words.width = advance
            words[#words + 1] = word
            words[#words + 1] = space
        end
        lastSpaceAdvance = spaceAdvance
    end

    local function appendFrag (frag, isFirst)
        if isFirst then
            append(frag, '')
        else
            local wordAdvance = font:getAdvance(frag)
            lines[#lines + 1] = { width = wordAdvance, frag }
            advance = wordAdvance
        end
    end

    local leadSpace = text:match '^ +'

    if leadSpace then
        append('', leadSpace)
    end

    for word, space in text:gmatch '([^ ]+)( *)' do
        if word:match '\n' then
            local isFirst = true
            for frag in (word .. '\n'):gmatch '([^\n]*)\n' do
                appendFrag(frag, isFirst)
                isFirst = false
            end
            append('', space)
        else
            append(word, space)
        end
    end

    return lines
end

return Multiline
