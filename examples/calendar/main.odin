package main

import "core:mem"
import "core:fmt"
import "core:strings"
import "core:time"
import "base:runtime"
import ui "../.."
import util "../example_util"

dtboth: ^ui.uiDateTimePicker
dtdate: ^ui.uiDateTimePicker
dttime: ^ui.uiDateTimePicker

time_format :: proc(d: rawptr) -> string {
    if d == rawptr(dtboth) {
        return "%c"
    } else if d == rawptr(dtdate) {
        return "%x"
    } else if d == rawptr(dttime) {
        return "%X"
    }
    return ""
}

on_changed :: proc "c" (d: ^ui.uiDateTimePicker, data: rawptr) {
    tm: ui.tm
    context = runtime.default_context()
    ui.uiDateTimePickerTime(d, &tm)
    buf: [64]u8
    fmt := time_format(d)

    // FIXME: implement
    // time.strftime(&buf[0], len(buf), fmt, &tm)

    ui.uiLabelSetText(cast(^ui.uiLabel)(data), strings.clone_to_cstring(fmt, allocator = context.temp_allocator))
}

on_clicked :: proc "c" (b: ^ui.uiButton, data: rawptr) {
    now := cast(int)(uintptr(data))
    t: time.Time
    if now != 0 {
        t = time.now()
    } else {
        t = time.Time{_nsec = 0}
    }
    tm: ui.tm

    // FIXME: implement
    // ui.time_to_tm(t, &tm)

    if now != 0 {
        ui.uiDateTimePickerSetTime(dtdate, &tm)
        ui.uiDateTimePickerSetTime(dttime, &tm)
    } else {
        ui.uiDateTimePickerSetTime(dtboth, &tm)
    }
}

on_closing :: proc "c" (w: ^ui.uiWindow, data: rawptr) -> i32 {
    ui.uiQuit()
    return 1
}

main :: proc() {
    util.debug_tracking_allocator_init()

    o: ui.uiInitOptions
    mem.set(&o, 0, size_of(ui.uiInitOptions))
    if ui.uiInit(&o) != nil {
        assert(false)
    }

    w := ui.uiNewWindow("Date / Time", 320, 240, 0)
    ui.uiWindowSetMargined(w, 1)

    g := ui.uiNewGrid()
    ui.uiGridSetPadded(g, 1)
    ui.uiWindowSetChild(w, ui.to_uiControl(g))

    dtboth = ui.uiNewDateTimePicker()
    dtdate = ui.uiNewDatePicker()
    dttime = ui.uiNewTimePicker()

    ui.uiGridAppend(g, ui.to_uiControl(dtboth), 0, 0, 2, 1, 1, ui.uiAlignFill, 0, ui.uiAlignFill)
    ui.uiGridAppend(g, ui.to_uiControl(dtdate), 0, 1, 1, 1, 1, ui.uiAlignFill, 0, ui.uiAlignFill)
    ui.uiGridAppend(g, ui.to_uiControl(dttime), 1, 1, 1, 1, 1, ui.uiAlignFill, 0, ui.uiAlignFill)

    l1 := ui.uiNewLabel("")
    ui.uiGridAppend(g, ui.to_uiControl(l1), 0, 2, 2, 1, 1, ui.uiAlignCenter, 0, ui.uiAlignFill)
    ui.uiDateTimePickerOnChanged(dtboth, on_changed, l1)

    l2 := ui.uiNewLabel("")
    ui.uiGridAppend(g, ui.to_uiControl(l2), 0, 3, 1, 1, 1, ui.uiAlignCenter, 0, ui.uiAlignFill)
    ui.uiDateTimePickerOnChanged(dtdate, on_changed, l2)

    l3 := ui.uiNewLabel("")
    ui.uiGridAppend(g, ui.to_uiControl(l3), 1, 3, 1, 1, 1, ui.uiAlignCenter, 0, ui.uiAlignFill)
    ui.uiDateTimePickerOnChanged(dttime, on_changed, l3)

    b1 := ui.uiNewButton("Now")

    @(static)
    dat1 := 1
    
    ui.uiButtonOnClicked(b1, on_clicked, rawptr(&dat1))
    ui.uiGridAppend(g, ui.to_uiControl(b1), 0, 4, 1, 1, 1, ui.uiAlignFill, 1, ui.uiAlignEnd)

    b2 := ui.uiNewButton("Unix epoch")

    @(static)
    dat0 := 0

    ui.uiButtonOnClicked(b2, on_clicked, rawptr(&dat0))
    ui.uiGridAppend(g, ui.to_uiControl(b2), 1, 4, 1, 1, 1, ui.uiAlignFill, 1, ui.uiAlignEnd)

    ui.uiWindowOnClosing(w, on_closing, nil)
    ui.uiControlShow(ui.to_uiControl(w))
    ui.uiMain()
}