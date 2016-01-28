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

local ROOT = (...):gsub('[^.]*$', '')

local Shortcut = require(ROOT .. 'shortcut')

local Attribute = {}

local function cascade (widget, attribute)
    local value = rawget(widget, 'attributes')[attribute]
    if value ~= nil then return value end
    local parent = rawget(widget, 'parent')
    return parent and parent[attribute]
end

--[[--
Type of widget.

Should contain a string identifying the widget's type.
After the layout is built, may be replaced by an array
of strings identifying multiple types. This is used
internally by some widgets to provide information about
the widget's state to the theme (themes describe the
appearance of widgets according to their type).

If a type is registered with the widget's layout, the registered
type initializer function will run once when the widget is constructed.

@see Widget.register

@attrib type
--]]--
Attribute.type = {}

function Attribute.type.set (widget, value)
    local oldType = widget.attributes.type

    widget.attributes.type = value

    if value and not widget.hasType then
        widget.hasType = true
        local Widget = require(ROOT .. 'widget')
        local decorate = Widget.typeDecorators[value]

        if decorate then
            decorate(widget)
        end
    end
end

--[[--
Widget identifier.

Should contain a unique string identifying the widget, if present.

A reference to the widget will be stored in the associated layout
in a property having the same name as the widget's id.

Setting this attribute re-registers the widget with its layout.

@attrib id
--]]--
Attribute.id = {}

function Attribute.id.set (widget, value)
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

--[[--
Widget value.

Some widget types expect the value to be of a specific type and
within a specific range. For example, `slider` and `progress`
widgets expect a normalized number, `text` widgets expect
a string, and `check` and `radio` widgets expect a boolean.

Setting this attribute bubbles the `Change` event.

@attrib value
--]]--
Attribute.value = {}

function Attribute.value.set (widget, value)
    local oldValue = widget.value
    widget.attributes.value = value
    widget:bubbleEvent('Change', { value = value, oldValue = oldValue })
end

--[[--
Solidity.

Should true or false.

@attrib icon
--]]--
Attribute.solid = {}

function Attribute.solid.set (widget, value)
    widget.attributes.solid = value
end

Attribute.solid.get = cascade

--[[--
Context menu.

- This attribute cascades.

@attrib context
--]]--
Attribute.context = {}

function Attribute.context.set (widget, value)
    widget.attributes.context = value
    if not value then return end
    value.isContextMenu = true
    widget.layout:createWidget { type = 'menu', value }
end

Attribute.context.get = cascade

--[[--
Widget style.

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
Attribute.style = {}

function Attribute.style.set (widget, value)
    widget.attributes.style = value
    widget.fontData = nil
    widget.textData = nil
    widget.reshape(widget.parent or widget)
end

--[[--
Status message.

Should contain a string with a short message describing the
purpose or state of the widget.

This message will appear in the last created `status` widget
in the same layout, or in the master layout if one exists.

- This attribute cascades.

@attrib status
--]]--
Attribute.status = {}

Attribute.status.get = cascade

--[[--
Scroll ability.

Should contain `true` or `false` (or `nil`).

If set to `true`, moving the scroll wheel over the widget will adjust
its scroll position when the widget's contents overflow its boundary.

@attrib scroll
--]]--
Attribute.scroll = {}

--[[--
Keyboard Attributes.

@section keyboard
--]]--

--[[--
Focusable.

Should contain `true` if the widget can be focused by pressing the tab key.

@attrib focusable
--]]--
Attribute.focusable = {}

--[[--
Keyboard shortcut.

Should contain a string representing a key and optional modifiers,
separated by dashes; for example `'ctrl-c'` or `'alt-shift-escape'`.

Pressing this key combination bubbles a `Press` event on the widget,
as if it had been pressed with a mouse or touch interface.

Setting this attribute re-registers the widget with its layout.

@attrib shortcut
--]]--
Attribute.shortcut = {}

local function setShortcut (layout, shortcut, value)
    local mainKey, modifierFlags = Shortcut.parseKeyCombo(shortcut)
    if mainKey then
        layout.shortcuts[modifierFlags][mainKey] = value
    end
end

function Attribute.shortcut.set (widget, value)
    local layout = widget.layout.master or widget.layout
    local oldValue = widget.attributes.shortcut

    if oldValue then
        if type(oldValue) == 'table' then
            for _, v in ipairs(oldValue) do
                setShortcut(layout, v, nil)
            end
        else
            setShortcut(layout, oldValue, nil)
        end
    end

    if value then
        if type(value) == 'table' then
            for _, v in ipairs(value) do
                setShortcut(layout, v, widget)
            end
        else
            setShortcut(layout, value, widget)
        end
    end

    widget.attributes.shortcut = value
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
Attribute.flow = {}

function Attribute.flow.set (widget, value)
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
Attribute.width = {}

function Attribute.width.set (widget, value)
    if value ~= 'auto' then
        value = value and math.max(value, widget.minwidth or 0)
    end
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
Attribute.height = {}

function Attribute.height.set (widget, value)
    if value ~= 'auto' then
        value = value and math.max(value, widget.minheight or 0)
    end
    widget.attributes.height = value
    widget.reshape(widget.parent or widget)
end

--[[--
Minimum width.

@attrib minwidth
--]]--
Attribute.minwidth = {}

function Attribute.minwidth.set (widget, value)
    local attributes = widget.attributes
    attributes.minwidth = value
    if type(value) == 'number' then
        local current = attributes.width
        if type(current) == 'number' then
            attributes.width = math.max(current, value)
        end
    end
    widget.reshape(widget.parent or widget)
end

--[[--
Minimum height.

@attrib minheight
--]]--
Attribute.minheight = {}

function Attribute.minheight.set (widget, value)
    local attributes = widget.attributes
    attributes.minheight = value
    if type(value) == 'number' then
        local current = attributes.height
        if type(current) == 'number' then
            attributes.height = math.max(current, value)
        end
    end
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

- This attribute cascades.

@attrib font
--]]--
Attribute.font = {}

local function resetFont (widget)
    rawset(widget, 'fontData', nil)
    rawset(widget, 'textData', nil)
    for _, child in ipairs(widget) do
        resetFont(child)
    end
    local items = widget.items
    if items then
        for _, child in ipairs(items) do
            resetFont(child)
        end
    end
end

function Attribute.font.set (widget, value)
    widget.attributes.font = value
    resetFont(widget)
end

Attribute.font.get = cascade

--[[--
Font size.

Should contain a number representing the size of the font, in points.
Defaults to 12.

- This attribute cascades.

@attrib size
--]]--
Attribute.size = {}

function Attribute.size.set (widget, value)
    widget.attributes.size = value
    widget.fontData = nil
    widget.textData = nil
end

Attribute.size.get = cascade

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
Attribute.text = {}

function Attribute.text.set (widget, value)
    widget.attributes.text = value
    widget.textData = nil
end

--[[--
Text color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

- This attribute cascades.

@attrib color
--]]--
Attribute.color = {}

function Attribute.color.set (widget, value)
    widget.attributes.color = value
    widget.textData = nil
end

Attribute.color.get = cascade

--[[--
Text and icon alignment.

Should contain a string defining vertical and horizontal alignment.
Vertical alignment is defined by either 'top', 'middle', or 'bottom',
and horizontal alignment is defined by either 'left', 'center', or 'right'.

For example, `align = 'top left'`

- This attribute cascades.

@attrib align
--]]--
Attribute.align = {}

function Attribute.align.set (widget, value)
    widget.attributes.align = value
    widget.textData = nil
end

Attribute.align.get = cascade

--[[--
Wrap text onto multiple lines.

Should contain `true` for multiline text, or `false` or `nil`
for a single line. Even text containing line breaks will display
as a single line when this attribute is not set to `true`.

- This attribute cascades.

@attrib wrap
--]]--
Attribute.wrap = {}

function Attribute.wrap.set (widget, value)
    widget.attributes.wrap = value
    widget.textData = nil
end

Attribute.wrap.get = cascade

--[[--
Visual Attributes.

@section visual
--]]--

--[[--
Background color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

@attrib background
--]]--
Attribute.background = {}

--[[--
Outline color.

Should contain an array with 3 or 4 values (RGB or RGBA) from 0 to 255.

@attrib outline
--]]--
Attribute.outline = {}

--[[--
Slice image.

Should contain a path to an image with "slices" to display for this widget.

@attrib slices
--]]--
Attribute.slices = {}

--[[--
Margin size.

The margin area occupies space outside of the `outline` and `slices`.

@attrib margin
--]]--
Attribute.margin = {}

function Attribute.margin.set (widget, value)
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
Attribute.padding = {}

function Attribute.padding.set (widget, value)
    widget.attributes.padding = value
    widget.textData = nil
    widget:reshape()
end

--[[--
Icon path.

Should contain a path to an image file.

@attrib icon
--]]--
Attribute.icon = {}

function Attribute.icon.set (widget, value)
    widget.attributes.icon = value
    widget.textData = nil
end


return Attribute
