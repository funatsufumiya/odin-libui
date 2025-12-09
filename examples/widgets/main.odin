package main

import "core:mem"
import "core:fmt"
import "base:runtime"
import ui "../.."
import util "../example_util"

mainwin: ^ui.uiWindow
spinbox: ^ui.uiSpinbox
slider: ^ui.uiSlider
pbar: ^ui.uiProgressBar

on_closing :: proc "c" (w: ^ui.uiWindow, data: rawptr) -> i32 {
	ui.uiQuit()
	return 1
}

on_should_quit :: proc "c" (data: rawptr) -> i32 {
    context = runtime.default_context()
	mainwin := cast(^ui.uiWindow) data
	ui.uiControlDestroy(ui.to_uiControl(mainwin))
	return 1
}

make_basic_controls_page :: proc() -> ^ui.uiControl {
	vbox := ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox, 1)

	hbox := ui.uiNewHorizontalBox()
	ui.uiBoxSetPadded(hbox, 1)
	ui.uiBoxAppend(vbox, ui.to_uiControl(hbox), 0)

	ui.uiBoxAppend(hbox, ui.to_uiControl(ui.uiNewButton("Button")), 0)
	ui.uiBoxAppend(hbox, ui.to_uiControl(ui.uiNewCheckbox("Checkbox")), 0)

	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewLabel("This is a label. Right now, labels can only span one line.")), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewHorizontalSeparator()), 0)

	group := ui.uiNewGroup("Entries")
	ui.uiGroupSetMargined(group, 1)
	ui.uiBoxAppend(vbox, ui.to_uiControl(group), 1)

	entryForm := ui.uiNewForm()
	ui.uiFormSetPadded(entryForm, 1)
	ui.uiGroupSetChild(group, ui.to_uiControl(entryForm))

	ui.uiFormAppend(entryForm, "Entry", ui.to_uiControl(ui.uiNewEntry()), 0)
	ui.uiFormAppend(entryForm, "Password Entry", ui.to_uiControl(ui.uiNewPasswordEntry()), 0)
	ui.uiFormAppend(entryForm, "Search Entry", ui.to_uiControl(ui.uiNewSearchEntry()), 0)
	ui.uiFormAppend(entryForm, "Multiline Entry", ui.to_uiControl(ui.uiNewMultilineEntry()), 1)
	ui.uiFormAppend(entryForm, "Multiline Entry No Wrap", ui.to_uiControl(ui.uiNewNonWrappingMultilineEntry()), 1)

	return ui.to_uiControl(vbox)
}

on_spinbox_changed :: proc "c" (s: ^ui.uiSpinbox, data: rawptr) {
	ui.uiSliderSetValue(slider, ui.uiSpinboxValue(s))
	ui.uiProgressBarSetValue(pbar, ui.uiSpinboxValue(s))
}

on_slider_changed :: proc "c" (s: ^ui.uiSlider, data: rawptr) {
	ui.uiSpinboxSetValue(spinbox, ui.uiSliderValue(s))
	ui.uiProgressBarSetValue(pbar, ui.uiSliderValue(s))
}

make_numbers_page :: proc() -> ^ui.uiControl {
	hbox := ui.uiNewHorizontalBox()
	ui.uiBoxSetPadded(hbox, 1)

	group := ui.uiNewGroup("Numbers")
	ui.uiGroupSetMargined(group, 1)
	ui.uiBoxAppend(hbox, ui.to_uiControl(group), 1)

	vbox := ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox, 1)
	ui.uiGroupSetChild(group, ui.to_uiControl(vbox))

	spinbox = ui.uiNewSpinbox(0, 100)
	slider = ui.uiNewSlider(0, 100)
	pbar = ui.uiNewProgressBar()
	ui.uiSpinboxOnChanged(spinbox, on_spinbox_changed, nil)
	ui.uiSliderOnChanged(slider, on_slider_changed, nil)
	ui.uiBoxAppend(vbox, ui.to_uiControl(spinbox), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(slider), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(pbar), 0)

	ip := ui.uiNewProgressBar()
	ui.uiProgressBarSetValue(ip, -1)
	ui.uiBoxAppend(vbox, ui.to_uiControl(ip), 0)

	group = ui.uiNewGroup("Lists")
	ui.uiGroupSetMargined(group, 1)
	ui.uiBoxAppend(hbox, ui.to_uiControl(group), 1)

	vbox = ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox, 1)
	ui.uiGroupSetChild(group, ui.to_uiControl(vbox))

	cbox := ui.uiNewCombobox()
	ui.uiComboboxAppend(cbox, "Combobox Item 1")
	ui.uiComboboxAppend(cbox, "Combobox Item 2")
	ui.uiComboboxAppend(cbox, "Combobox Item 3")
	ui.uiBoxAppend(vbox, ui.to_uiControl(cbox), 0)

	ecbox := ui.uiNewEditableCombobox()
	ui.uiEditableComboboxAppend(ecbox, "Editable Item 1")
	ui.uiEditableComboboxAppend(ecbox, "Editable Item 2")
	ui.uiEditableComboboxAppend(ecbox, "Editable Item 3")
	ui.uiBoxAppend(vbox, ui.to_uiControl(ecbox), 0)

	rb := ui.uiNewRadioButtons()
	ui.uiRadioButtonsAppend(rb, "Radio Button 1")
	ui.uiRadioButtonsAppend(rb, "Radio Button 2")
	ui.uiRadioButtonsAppend(rb, "Radio Button 3")
	ui.uiBoxAppend(vbox, ui.to_uiControl(rb), 0)

	return ui.to_uiControl(hbox)
}

on_open_file_clicked :: proc "c" (b: ^ui.uiButton, data: rawptr) {
	entry := cast(^ui.uiEntry) data
	filename := ui.uiOpenFile(mainwin)
	if filename == nil {
		ui.uiEntrySetText(entry, "(cancelled)")
		return
	}
	ui.uiEntrySetText(entry, filename)
	ui.uiFreeText(filename)
}

on_save_file_clicked :: proc "c" (b: ^ui.uiButton, data: rawptr) {
	entry := cast(^ui.uiEntry) data
	filename := ui.uiSaveFile(mainwin)
	if filename == nil {
		ui.uiEntrySetText(entry, "(cancelled)")
		return
	}
	ui.uiEntrySetText(entry, filename)
	ui.uiFreeText(filename)
}

on_msg_box_clicked :: proc "c" (b: ^ui.uiButton, data: rawptr) {
	ui.uiMsgBox(mainwin, "This is a normal message box.", "More detailed information can be shown here.")
}

on_msg_box_error_clicked :: proc "c" (b: ^ui.uiButton, data: rawptr) {
	ui.uiMsgBoxError(mainwin, "This message box describes an error.", "More detailed information can be shown here.")
}

make_data_choosers_page :: proc() -> ^ui.uiControl {
	hbox := ui.uiNewHorizontalBox()
	ui.uiBoxSetPadded(hbox, 1)

	vbox := ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox, 1)
	ui.uiBoxAppend(hbox, ui.to_uiControl(vbox), 0)

	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewDatePicker()), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewTimePicker()), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewDateTimePicker()), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewFontButton()), 0)
	ui.uiBoxAppend(vbox, ui.to_uiControl(ui.uiNewColorButton()), 0)

	ui.uiBoxAppend(hbox, ui.to_uiControl(ui.uiNewVerticalSeparator()), 0)

	vbox2 := ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox2, 1)
	ui.uiBoxAppend(hbox, ui.to_uiControl(vbox2), 1)

	grid := ui.uiNewGrid()
	ui.uiGridSetPadded(grid, 1)
	ui.uiBoxAppend(vbox2, ui.to_uiControl(grid), 0)

	button := ui.uiNewButton("Open File")
	entry := ui.uiNewEntry()
	ui.uiEntrySetReadOnly(entry, 1)
	ui.uiButtonOnClicked(button, on_open_file_clicked, entry)
	ui.uiGridAppend(grid, ui.to_uiControl(button), 0, 0, 1, 1, 0, ui.uiAlignFill, 0, ui.uiAlignFill)
	ui.uiGridAppend(grid, ui.to_uiControl(entry), 1, 0, 1, 1, 1, ui.uiAlignFill, 0, ui.uiAlignFill)

	button = ui.uiNewButton("Save File")
	entry = ui.uiNewEntry()
	ui.uiEntrySetReadOnly(entry, 1)
	ui.uiButtonOnClicked(button, on_save_file_clicked, entry)
	ui.uiGridAppend(grid, ui.to_uiControl(button), 0, 1, 1, 1, 0, ui.uiAlignFill, 0, ui.uiAlignFill)
	ui.uiGridAppend(grid, ui.to_uiControl(entry), 1, 1, 1, 1, 1, ui.uiAlignFill, 0, ui.uiAlignFill)

	msggrid := ui.uiNewGrid()
	ui.uiGridSetPadded(msggrid, 1)
	ui.uiGridAppend(grid, ui.to_uiControl(msggrid), 0, 2, 2, 1, 0, ui.uiAlignCenter, 0, ui.uiAlignStart)

	button = ui.uiNewButton("Message Box")
	ui.uiButtonOnClicked(button, on_msg_box_clicked, nil)
	ui.uiGridAppend(msggrid, ui.to_uiControl(button), 0, 0, 1, 1, 0, ui.uiAlignFill, 0, ui.uiAlignFill)
	button = ui.uiNewButton("Error Box")
	ui.uiButtonOnClicked(button, on_msg_box_error_clicked, nil)
	ui.uiGridAppend(msggrid, ui.to_uiControl(button), 1, 0, 1, 1, 0, ui.uiAlignFill, 0, ui.uiAlignFill)

	return ui.to_uiControl(hbox)
}

main :: proc() {
	util.debug_tracking_allocator_init()
	options: ui.uiInitOptions
	mem.set(&options, 0, size_of(ui.uiInitOptions))
	if ui.uiInit(&options) != nil {
		fmt.eprintln("error initializing libui")
		assert(false)
	}

	mainwin = ui.uiNewWindow("libui Control Gallery", 640, 480, 1)
	ui.uiWindowOnClosing(mainwin, on_closing, nil)
	ui.uiOnShouldQuit(on_should_quit, mainwin)

	tab := ui.uiNewTab()
	ui.uiWindowSetChild(mainwin, ui.to_uiControl(tab))
	ui.uiWindowSetMargined(mainwin, 1)

	ui.uiTabAppend(tab, "Basic Controls", make_basic_controls_page())
	ui.uiTabSetMargined(tab, 0, 1)

	ui.uiTabAppend(tab, "Numbers and Lists", make_numbers_page())
	ui.uiTabSetMargined(tab, 1, 1)

	ui.uiTabAppend(tab, "Data Choosers", make_data_choosers_page())
	ui.uiTabSetMargined(tab, 2, 1)

	ui.uiControlShow(ui.to_uiControl(mainwin))
	ui.uiMain()
}
