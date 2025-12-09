package main

import "core:mem"
import "core:time"
import "core:fmt"
import "core:strings"
import "base:runtime"
import ui "../.."
import util "../example_util"

e: ^ui.uiMultilineEntry

// Timer callback: append current time
say_time :: proc "c" (data: rawptr) -> i32 {
    t := time.now()
    // s := time.format(t, "%Y-%m-%d %H:%M:%S") + "\n"
    context = runtime.default_context()
    s := fmt.aprintfln("{}", t, allocator = context.temp_allocator)
    ui.uiMultilineEntryAppend(e, strings.clone_to_cstring(s, allocator = context.temp_allocator))
    return 1
}

// Window closing callback
on_closing :: proc "c" (w: ^ui.uiWindow, data: rawptr) -> i32 {
    ui.uiQuit()
    return 1
}

// Button callback: append message
say_something :: proc "c" (b: ^ui.uiButton, data: rawptr) {
    ui.uiMultilineEntryAppend(e, "Saying something\n")
}

main :: proc() {
    util.debug_tracking_allocator_init()

    o: ui.uiInitOptions
    mem.set(&o, 0, size_of(ui.uiInitOptions))
    if ui.uiInit(&o) != nil {
        assert(false)
    }

    w := ui.uiNewWindow("Hello", 320, 240, 0)
    ui.uiWindowSetMargined(w, 1)

    b := ui.uiNewVerticalBox()
    ui.uiBoxSetPadded(b, 1)
    ui.uiWindowSetChild(w, ui.to_uiControl(b))

    e = ui.uiNewMultilineEntry()
    ui.uiMultilineEntrySetReadOnly(e, 1)

    btn := ui.uiNewButton("Say Something")
    ui.uiButtonOnClicked(btn, say_something, nil)
    ui.uiBoxAppend(b, ui.to_uiControl(btn), 0)

    ui.uiBoxAppend(b, ui.to_uiControl(e), 1)

    ui.uiTimer(1000, say_time, nil)

    ui.uiWindowOnClosing(w, on_closing, nil)
    ui.uiControlShow(ui.to_uiControl(w))
    ui.uiMain()
}
