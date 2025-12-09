package main

import "core:mem"
import "core:fmt"
import "core:strings"
import "base:runtime"
import ui "../.."
import util "../example_util"

mainwin: ^ui.uiWindow
area: ^ui.uiArea
handler: ui.uiAreaHandler
fontButton: ^ui.uiFontButton
alignment: ^ui.uiCombobox
attrstr: ^ui.uiAttributedString

append_with_attribute :: proc(what: cstring, attr: ^ui.uiAttribute, attr2: ^ui.uiAttribute) {
	start := ui.uiAttributedStringLen(attrstr)
	end := start + len(what)
	ui.uiAttributedStringAppendUnattributed(attrstr, what)
	ui.uiAttributedStringSetAttribute(attrstr, attr, start, end)
	if attr2 != nil {
		ui.uiAttributedStringSetAttribute(attrstr, attr2, start, end)
	}
}

make_attributed_string :: proc() {
	attr: ^ui.uiAttribute
	attr2: ^ui.uiAttribute
	otf: ^ui.uiOpenTypeFeatures


    str : cstring = "Drawing strings with libui is done with the uiAttributedString and uiDrawTextLayout objects.\nuiAttributedString lets you have a variety of attributes: "
	attrstr = ui.uiNewAttributedString(str)

	attr = ui.uiNewFamilyAttribute("Courier New")
	append_with_attribute("font family", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewSizeAttribute(18)
	append_with_attribute("font size", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewWeightAttribute(ui.uiTextWeightBold)
	append_with_attribute("font weight", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewItalicAttribute(ui.uiTextItalicItalic)
	append_with_attribute("font italicness", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewStretchAttribute(ui.uiTextStretchCondensed)
	append_with_attribute("font stretch", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewColorAttribute(0.75, 0.25, 0.5, 0.75)
	append_with_attribute("text color", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewBackgroundAttribute(0.5, 0.5, 0.25, 0.5)
	append_with_attribute("text background color", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	attr = ui.uiNewUnderlineAttribute(ui.uiUnderlineSingle)
	append_with_attribute("underline style", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, ", ")

	ui.uiAttributedStringAppendUnattributed(attrstr, "and ")
	attr = ui.uiNewUnderlineAttribute(ui.uiUnderlineDouble)
	attr2 = ui.uiNewUnderlineColorAttribute(ui.uiUnderlineColorCustom, 1.0, 0.0, 0.5, 1.0)
	append_with_attribute("underline color", attr, attr2)
	ui.uiAttributedStringAppendUnattributed(attrstr, ". ")

	ui.uiAttributedStringAppendUnattributed(attrstr, "Furthermore, there are attributes allowing for ")
	attr = ui.uiNewUnderlineAttribute(ui.uiUnderlineSuggestion)
	attr2 = ui.uiNewUnderlineColorAttribute(ui.uiUnderlineColorSpelling, 0, 0, 0, 0)
	append_with_attribute("special underlines for indicating spelling errors", attr, attr2)
	ui.uiAttributedStringAppendUnattributed(attrstr, " (and other types of errors) ")

	ui.uiAttributedStringAppendUnattributed(attrstr, "and control over OpenType features such as ligatures (for instance, ")
	otf = ui.uiNewOpenTypeFeatures()
	ui.uiOpenTypeFeaturesAdd(otf, 'l', 'i', 'g', 'a', 0)
	attr = ui.uiNewFeaturesAttribute(otf)
	append_with_attribute("afford", attr, nil)
	ui.uiAttributedStringAppendUnattributed(attrstr, " vs. ")
	ui.uiOpenTypeFeaturesAdd(otf, 'l', 'i', 'g', 'a', 1)
	attr = ui.uiNewFeaturesAttribute(otf)
	append_with_attribute("afford", attr, nil)
	ui.uiFreeOpenTypeFeatures(otf)
	ui.uiAttributedStringAppendUnattributed(attrstr, ").\n")

	ui.uiAttributedStringAppendUnattributed(attrstr, "Use the controls opposite to the text to control properties of the text.")
}

handler_draw :: proc "c" (a: ^ui.uiAreaHandler, area: ^ui.uiArea, p: ^ui.uiAreaDrawParams) {
	textLayout: ^ui.uiDrawTextLayout
	defaultFont: ui.uiFontDescriptor
	params: ui.uiDrawTextLayoutParams

	params.String = attrstr
	ui.uiFontButtonFont(fontButton, &defaultFont)
	params.DefaultFont = &defaultFont
	params.Width = p.AreaWidth
	params.Align = cast(ui.uiDrawTextAlign) ui.uiComboboxSelected(alignment)
	textLayout = ui.uiDrawNewTextLayout(&params)
	ui.uiDrawText(p.Context, textLayout, 0, 0)
	ui.uiDrawFreeTextLayout(textLayout)
	ui.uiFreeFontButtonFont(&defaultFont)
}

handler_mouse_event :: proc "c" (a: ^ui.uiAreaHandler, area: ^ui.uiArea, e: ^ui.uiAreaMouseEvent) {
	// do nothing
}

handler_mouse_crossed :: proc "c" (ah: ^ui.uiAreaHandler, a: ^ui.uiArea, left: i32) {
	// do nothing
}

handler_drag_broken :: proc "c" (ah: ^ui.uiAreaHandler, a: ^ui.uiArea) {
	// do nothing
}

handler_key_event :: proc "c" (ah: ^ui.uiAreaHandler, a: ^ui.uiArea, e: ^ui.uiAreaKeyEvent) -> i32 {
	return 0
}

on_font_changed :: proc "c" (b: ^ui.uiFontButton, data: rawptr) {
	ui.uiAreaQueueRedrawAll(area)
}

on_combobox_selected :: proc "c" (b: ^ui.uiCombobox, data: rawptr) {
	ui.uiAreaQueueRedrawAll(area)
}

on_closing :: proc "c" (w: ^ui.uiWindow, data: rawptr) -> i32 {
    context = runtime.default_context()
	ui.uiControlDestroy(ui.to_uiControl(mainwin))
	ui.uiQuit()
	return 0
}

should_quit :: proc "c" (data: rawptr) -> i32 {
    context = runtime.default_context()
	ui.uiControlDestroy(ui.to_uiControl(mainwin))
	return 1
}

main :: proc() {
	util.debug_tracking_allocator_init()
	o: ui.uiInitOptions
	mem.set(&o, 0, size_of(ui.uiInitOptions))
	if ui.uiInit(&o) != nil {
		fmt.eprintln("error initializing ui")
		assert(false)
	}

	ui.uiOnShouldQuit(should_quit, nil)

	make_attributed_string()

	mainwin = ui.uiNewWindow("libui Text-Drawing Example", 640, 480, 1)
	ui.uiWindowSetMargined(mainwin, 1)
	ui.uiWindowOnClosing(mainwin, on_closing, nil)

	hbox := ui.uiNewHorizontalBox()
	ui.uiBoxSetPadded(hbox, 1)
	ui.uiWindowSetChild(mainwin, ui.to_uiControl(hbox))

	vbox := ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox, 1)
	ui.uiBoxAppend(hbox, ui.to_uiControl(vbox), 0)

	fontButton = ui.uiNewFontButton()
	ui.uiFontButtonOnChanged(fontButton, on_font_changed, nil)
	ui.uiBoxAppend(vbox, ui.to_uiControl(fontButton), 0)

	form := ui.uiNewForm()
	ui.uiFormSetPadded(form, 1)
	ui.uiBoxAppend(vbox, ui.to_uiControl(form), 0)

	alignment = ui.uiNewCombobox()
	ui.uiComboboxAppend(alignment, "Left")
	ui.uiComboboxAppend(alignment, "Center")
	ui.uiComboboxAppend(alignment, "Right")
	ui.uiComboboxSetSelected(alignment, 0)
	ui.uiComboboxOnSelected(alignment, on_combobox_selected, nil)
	ui.uiFormAppend(form, "Alignment", ui.to_uiControl(alignment), 0)

	handler.Draw = handler_draw
	handler.MouseEvent = handler_mouse_event
	handler.MouseCrossed = handler_mouse_crossed
	handler.DragBroken = handler_drag_broken
	handler.KeyEvent = handler_key_event

	area = ui.uiNewArea(&handler)
	ui.uiBoxAppend(hbox, ui.to_uiControl(area), 1)

	ui.uiControlShow(ui.to_uiControl(mainwin))
	ui.uiMain()
	ui.uiFreeAttributedString(attrstr)
	ui.uiUninit()
}
