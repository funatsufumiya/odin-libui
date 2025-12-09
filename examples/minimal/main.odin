package main

import "core:mem"
import ui "../.."
import util "../example_util"

on_closing :: proc"c" (w: ^ui.uiWindow, data: rawptr) -> i32
{
	ui.uiQuit()
	return 1
}

main :: proc() {
	util.debug_tracking_allocator_init()

	o: ui.uiInitOptions

 	mem.set(&o, 0, size_of (ui.uiInitOptions))
	if ui.uiInit(&o) != nil {
		// C.abort();
		assert(false)
    }

	w := ui.uiNewWindow("Hello", 320, 240, 0);
	ui.uiWindowOnClosing(w, on_closing, nil);
	ui.uiControlShow(ui.to_uiControl(w));
	ui.uiMain();
}
