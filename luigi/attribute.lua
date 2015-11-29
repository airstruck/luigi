--[[--
Widget attributes.

This module defines "attributes" (special fields) that are
recognized by all widgets. Their interpretation may vary
depending on the `type` of widget. Some widget types may also
recognize additional attributes.

Setting attributes can have side effects. For example, setting
`height` or `width` causes the parent widget and its descendants
to recalculate their size and position.
--]]--

local Attribute = {}

--[[--
widget identifier.

Should contain a unique string identifying the widget, if present.

A reference to the widget will be stored in the associated layout
in a property having the same name as the widget's id.

Setting this attribute re-registers the widget with its layout.

@attrib id
--]]--
function Attribute.id (widget, value)
    local layout = widget.layout.master or widget.layout
    local oldValue = widget.attributes.id

    if oldValue then
        layout[oldValue] = nil
    end

    if value then
        layout[value] = widget
    end

    widget.attributes.id = value
end

-- TODO: formalize this bitfield somewhere
local function parseKeyCombo (value)
    local mainKey = (value):match '[^%-]+$'
    local alt = (value):match 'alt%-' and 1 or 0
    local ctrl = (value):match 'ctrl%-' and 2 or 0
    local shift = (value):match 'shift%-' and 4 or 0
    local modifierFlags = alt + ctrl + shift

    return mainKey, modifierFlags
end

--[[--
Keyboard accelerator.

Should contain a string representing a key and optional modifiers,
separated by dashes; for example `'ctrl-c'` or `'alt-shift-escape'`.

Pressing this key combination bubbles a `Press` event on the widget,
as if it had been pressed with a mouse or touch interface.

Setting this attribute re-registers the widget with its layout.

@attrib key
--]]--
function Attribute.key (widget, value)
    local layout = widget.layout.master or widget.layout
    local oldValue = widget.attributes.key

    if oldValue then
        local mainKey, modifierFlags = parseKeyCombo(oldValue)
        layout.accelerators[modifierFlags][mainKey] = nil
    end

    if value then
        local mainKey, modifierFlags = parseKeyCombo(value)
        layout.accelerators[modifierFlags][mainKey] = widget
    end

    widget.attributes.key = value
end

--[[--
widget value.

Some widget types expect the value to be of a specific type and
within a specific range. For example, `slider` and `progress`
widgets expect a normalized number, and `text` widgets expect
a string.

Setting this attribute bubbles the `Change` event.

@attrib value
--]]--
function Attribute.value (widget, value)
    local oldValue = widget.value
    widget.attributes.value = value
    widget:bubbleEvent('Change', { value = value, oldValue = oldValue })
end

--[[--
widget style.

Should contain a string or array of strings identifying
style rules to be applied to the widget. When resolving
any attribute with a `nil` value, these style rules are
searched for a corresponding attribute.

Setting this attribute resets the `Font` and `Text` object
associated with this widget.

Setting this attribute recalculates the size and position
of the parent widget and its descendants.

@attrib style
--]]--
function Attribute.style (widget, value)
    widget.attributes.style = value
    widget.fontData = nil
    widget.textData = nil
    widget.reshape(widget.parent or widget)
end

--[[--
Size Attributes.

Setting these attributes recalculates the size and position
of the parent widget and its descendants.

@section size
--]]--

--[[--
Flow axis.

Should equal either `'x'` or `'y'`. Defaults to `'y'`.

This attribute determines the placement and default dimensions
of any child widgets.

When flow is `'x'`, the `height` of child widgets defaults
to this widget's height, and each child is placed to the
right of the previous child. When flow is `'y'`, the `width`
of child widgets defaults to this widget's width, and each
child is placed below the previous child.

Setting this attribute resets the `Text` object associated
with this widget.

@attrib flow
--]]--
function Attribute.flow (widget, value)
    widget.attributes.flow = value
    widget.textData = nil
    widget.reshape(widget.parent or widget)
end

--[[--
Width.

This attribute may not always hold a numeric value.
To get the calculated width, use `Widget:getWidth`.

Setting this attribute when the `wrap` attribute is
also present resets the `Text` object associated
with this widget.

@attrib width
--]]--
function Attribute.width (widget, value)
    value = value and math.max(value, widget.minwidth or 0)
    widget.attributes.width = value
    if widget.wrap then
        widget.textData = nil
    end
    widget.reshape(widget.parent or widget)
end

--[[--
Height.

This attribute may not always hold a numeric value.
To get the calculated height, use `Widget:getHeight`.

@attrib height
--]]--
function Attribute.height (widget, value)
    value = value and math.max(value, widget.minheight or 0)
    widget.attributes.height = value
    widget.reshape(widget.parent or widget)
end

--[[--
Minimum width.

@attrib minwidth
--]]--
function Attribute.minwidth (widget, value)
    widget.attributes.minwidth = value
    widget.reshape(widget.parent or widget)
end

--[[--
Minimum height.

@attrib minheight
--]]--
function Attribute.minheight (widget, value)
    widget.attributes.minheight = value
    widget.reshape(widget.parent or widget)
end

--[[--
Font Attributes.

Setting these attributes resets the Font and Text
objects associated with the widget.

@section font
--]]--

--[[--
Font path.

Should contain a path to a TrueType font to use for displaying
this widget's `text`.

@attrib font
--]]--
function Attribute.font (widget, value)
    widget.attributes.font = value
    widget.fontData = nil
    widget.textData = nil
end

--[[--
Font size.

Should contain a number representing the size of the font, in points.
Defaults to 12.

@attrib size
--]]--
function Attribute.size (widget, value)
    widget.attributes.size = value
    widget.fontData = nil
    widget.textData = nil
end

--[[--
Text Attributes.

Setting these attributes resets the Text object
associated with the widget.

@section text
--]]--

--[[--
Text to display.

@attrib text
--]]--
function Attribute.text (widget, value)
    widget.attributes.text = value
    widget.textData = nil
end

--[[--
Text color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

@attrib color
--]]--
function Attribute.color (widget, value)
    widget.attributes.color = value
    widget.textData = nil
end
--[[--
Text and icon alignment.

@attrib align
--]]--
function Attribute.align (widget, value)
    widget.attributes.align = value
    widget.textData = nil
end

--[[--
Wrap text onto multiple lines.

Should contain `true` for multiline text, or `false` or `nil`
for a single line. Even text containing line breaks will display
as a single line when this attribute is not set to `true`.

@attrib wrap
--]]--
function Attribute.wrap (widget, value)
    widget.attributes.wrap = value
    widget.textData = nil
end

--[[--
Visual Attributes.

@section visual
--]]--

--[[--
Background color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

@attrib background
--]]--
function Attribute.background (widget, value)
    widget.attributes.background = value
end

--[[--
Outline color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

@attrib outline
--]]--
function Attribute.outline (widget, value)
    widget.attributes.outline = value
end

--[[--
Slice image.

Should contain a path to an image with "slices" to display for this widget.

@attrib slices
--]]--
function Attribute.slices (widget, value)
    widget.attributes.slices = value
end

--[[--
Margin size.

The margin area occupies space outside of the `outline` and `slices`.

@attrib margin
--]]--
function Attribute.margin (widget, value)
    widget.attributes.margin = value
    widget.textData = nil
    widget:reshape()
end

--[[--
Padding size.

The padding area occupies space inside the `outline` and `slices`,
and outside the space where the `icon` and `text` and any
child widgets appear.

@attrib padding
--]]--
function Attribute.padding (widget, value)
    widget.attributes.padding = value
    widget.textData = nil
    widget:reshape()
end

--[[--
Icon path.

Should contain a path to an image file.

@attrib icon
--]]--
function Attribute.icon (widget, value)
    widget.attributes.icon = value
    widget.textData = nil
end


return Attribute
