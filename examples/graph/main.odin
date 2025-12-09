
package main

import "core:mem"
import "core:fmt"
import "core:strings"
import "core:time"
import "base:runtime"
import "core:c/libc"
import ui "../.."
import util "../example_util"

mainwin: ^ui.uiWindow
histogram: ^ui.uiArea
handler: ui.uiAreaHandler
datapoints: [10]^ui.uiSpinbox
colorButton: ^ui.uiColorButton
currentPoint: i32 = -1

xoffLeft: i32 = 20
yoffTop: i32 = 20
xoffRight: i32 = 20
yoffBottom: i32 = 20
pointRadius: i32 = 5

colorWhite: u32 = 0xFFFFFF
colorBlack: u32 = 0x000000
colorDodgerBlue: u32 = 0x1E90FF

set_solid_brush :: proc(brush: ^ui.uiDrawBrush, color: u32, alpha: f64) {
	brush.Type = ui.uiDrawBrushTypeSolid
	brush.R = f64((color >> 16) & 0xFF) / 255.0
	brush.G = f64((color >> 8) & 0xFF) / 255.0
	brush.B = f64(color & 0xFF) / 255.0
	brush.A = alpha
}

point_locations :: proc(width, height: f64, xs: ^[10]f64, ys: ^[10]f64) {
	xincr := width / 9.0
	yincr := height / 100.0
	for i in 0..<10 {
		n := ui.uiSpinboxValue(datapoints[i])
		n = 100 - n
		xs[i] = xincr * f64(i)
		ys[i] = yincr * f64(n)
	}
}

construct_graph :: proc(width, height: f64, extend: bool) -> ^ui.uiDrawPath {
	xs: [10]f64
	ys: [10]f64
	point_locations(width, height, &xs, &ys)
	path := ui.uiDrawNewPath(ui.uiDrawFillModeWinding)
	ui.uiDrawPathNewFigure(path, xs[0], ys[0])
	for i in 1..<10 {
		ui.uiDrawPathLineTo(path, xs[i], ys[i])
	}
	if extend {
		ui.uiDrawPathLineTo(path, width, height)
		ui.uiDrawPathLineTo(path, 0, height)
		ui.uiDrawPathCloseFigure(path)
	}
	ui.uiDrawPathEnd(path)
	return path
}

graph_size :: proc(clientWidth, clientHeight: f64, graphWidth: ^f64, graphHeight: ^f64) {
	graphWidth^ = clientWidth - f64(xoffLeft + xoffRight)
	graphHeight^ = clientHeight - f64(yoffTop + yoffBottom)
}

handler_draw :: proc "c" (a: ^ui.uiAreaHandler, area: ^ui.uiArea, p: ^ui.uiAreaDrawParams) {
	graphWidth, graphHeight: f64
	path: ^ui.uiDrawPath
	brush: ui.uiDrawBrush
	sp: ui.uiDrawStrokeParams
	m: ui.uiDrawMatrix
	graphR, graphG, graphB, graphA: f64
    
    context = runtime.default_context()

	set_solid_brush(&brush, colorWhite, 1.0)
	path = ui.uiDrawNewPath(ui.uiDrawFillModeWinding)
	ui.uiDrawPathAddRectangle(path, 0, 0, p.AreaWidth, p.AreaHeight)
	ui.uiDrawPathEnd(path)
	ui.uiDrawFill(p.Context, path, &brush)
	ui.uiDrawFreePath(path)

	graph_size(p.AreaWidth, p.AreaHeight, &graphWidth, &graphHeight)

	mem.set(&sp, 0, size_of(ui.uiDrawStrokeParams))
	sp.Cap = ui.uiDrawLineCapFlat
	sp.Join = ui.uiDrawLineJoinMiter
	sp.Thickness = 2.0
	sp.MiterLimit = ui.uiDrawDefaultMiterLimit

	set_solid_brush(&brush, colorBlack, 1.0)
	path = ui.uiDrawNewPath(ui.uiDrawFillModeWinding)
	ui.uiDrawPathNewFigure(path, f64(xoffLeft), f64(yoffTop))
	ui.uiDrawPathLineTo(path, f64(xoffLeft), f64(yoffTop) + graphHeight)
	ui.uiDrawPathLineTo(path, f64(xoffLeft) + graphWidth, f64(yoffTop) + graphHeight)
	ui.uiDrawPathEnd(path)
	ui.uiDrawStroke(p.Context, path, &brush, &sp)
	ui.uiDrawFreePath(path)

	ui.uiDrawMatrixSetIdentity(&m)
	ui.uiDrawMatrixTranslate(&m, f64(xoffLeft), f64(yoffTop))
	ui.uiDrawTransform(p.Context, &m)

	ui.uiColorButtonColor(colorButton, &graphR, &graphG, &graphB, &graphA)
	brush.Type = ui.uiDrawBrushTypeSolid
	brush.R = graphR
	brush.G = graphG
	brush.B = graphB

	path = construct_graph(graphWidth, graphHeight, true)
	brush.A = graphA / 2.0
	ui.uiDrawFill(p.Context, path, &brush)
	ui.uiDrawFreePath(path)

	path = construct_graph(graphWidth, graphHeight, false)
	brush.A = graphA
	ui.uiDrawStroke(p.Context, path, &brush, &sp)
	ui.uiDrawFreePath(path)

	if currentPoint != -1 {
		xs: [10]f64
		ys: [10]f64
		point_locations(graphWidth, graphHeight, &xs, &ys)
		path = ui.uiDrawNewPath(ui.uiDrawFillModeWinding)
		ui.uiDrawPathNewFigureWithArc(path, xs[currentPoint], ys[currentPoint], f64(pointRadius), 0.0, 6.283, 0)
		ui.uiDrawPathEnd(path)
		ui.uiDrawFill(p.Context, path, &brush)
		ui.uiDrawFreePath(path)
	}
}

in_point :: proc(x, y, xtest, ytest: f64) -> bool {
    x := x
    y := y
	x -= f64(xoffLeft)
	y -= f64(yoffTop)
	return (x >= xtest - f64(pointRadius)) && (x <= xtest + f64(pointRadius)) && (y >= ytest - f64(pointRadius)) && (y <= ytest + f64(pointRadius))
}

handler_mouse_event :: proc "c" (a: ^ui.uiAreaHandler, area: ^ui.uiArea, e: ^ui.uiAreaMouseEvent) {
    context = runtime.default_context() 

	graphWidth, graphHeight: f64
	xs: [10]f64
	ys: [10]f64
	graph_size(e.AreaWidth, e.AreaHeight, &graphWidth, &graphHeight)
	point_locations(graphWidth, graphHeight, &xs, &ys)
	i: i32 = -1
	for j in 0..<10 {
		if in_point(e.X, e.Y, xs[j], ys[j]) {
			i = i32(j)
			break
		}
	}
	currentPoint = i
	ui.uiAreaQueueRedrawAll(histogram)
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

on_datapoint_changed :: proc "c" (s: ^ui.uiSpinbox, data: rawptr) {
	ui.uiAreaQueueRedrawAll(histogram)
}

on_color_changed :: proc "c" (b: ^ui.uiColorButton, data: rawptr) {
	ui.uiAreaQueueRedrawAll(histogram)
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
		assert(false)
	}

	ui.uiOnShouldQuit(should_quit, nil)

	mainwin = ui.uiNewWindow("libui Histogram Example", 640, 480, 1)
	ui.uiWindowSetMargined(mainwin, 1)
	ui.uiWindowOnClosing(mainwin, on_closing, nil)

	hbox := ui.uiNewHorizontalBox()
	ui.uiBoxSetPadded(hbox, 1)
	ui.uiWindowSetChild(mainwin, ui.to_uiControl(hbox))

	vbox := ui.uiNewVerticalBox()
	ui.uiBoxSetPadded(vbox, 1)
	ui.uiBoxAppend(hbox, ui.to_uiControl(vbox), 0)

    t := libc.time(nil)

	libc.srand(u32(t))
	for i in 0..<10 {
		datapoints[i] = ui.uiNewSpinbox(0, 100)
		ui.uiSpinboxSetValue(datapoints[i], libc.rand() % 101)
		ui.uiSpinboxOnChanged(datapoints[i], on_datapoint_changed, nil)
		ui.uiBoxAppend(vbox, ui.to_uiControl(datapoints[i]), 0)
	}

	colorButton = ui.uiNewColorButton()
	brush: ui.uiDrawBrush
	set_solid_brush(&brush, colorDodgerBlue, 1.0)
	ui.uiColorButtonSetColor(colorButton, brush.R, brush.G, brush.B, brush.A)
	ui.uiColorButtonOnChanged(colorButton, on_color_changed, nil)
	ui.uiBoxAppend(vbox, ui.to_uiControl(colorButton), 0)

	handler.Draw = handler_draw
	handler.MouseEvent = handler_mouse_event
	handler.MouseCrossed = handler_mouse_crossed
	handler.DragBroken = handler_drag_broken
	handler.KeyEvent = handler_key_event

	histogram = ui.uiNewArea(&handler)
	ui.uiBoxAppend(hbox, ui.to_uiControl(histogram), 1)

	ui.uiControlShow(ui.to_uiControl(mainwin))
	ui.uiMain()
	ui.uiUninit()
}
