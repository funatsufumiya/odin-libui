// 6 april 2015

// TODO add a uiVerifyControlType() function that can be used by control implementations to verify controls

// TODOs
// - make getters that return whether something exists accept a NULL pointer to discard the value (and thus only return that the thing exists?)
// - const-correct everything
// - normalize documentation between typedefs and structs

// #ifndef __LIBUI_UI_H__
// #define __LIBUI_UI_H__
package libui

when ODIN_OS == .Windows do foreign import lib "libui.lib"
when ODIN_OS == .Darwin   do foreign import lib "bin/libui.dylib"
when ODIN_OS == .Linux   do foreign import lib "bin/libui.so"

import "core:c"

uiPi :: 3.14159265358979323846264338327950288419716939937510582097494459

// uiForEach represents the return value from one of libui's various ForEach functions.
// _UI_ENUM(uiForEach) {
// 	uiForEachContinue,
// 	uiForEachStop,
// };
// _UI_ENUM(uiForEach) {
uiForEach :: u32

uiForEachStop     :: 1
uiForEachContinue :: 0

uiInitOptions :: struct {
	Size: c.size_t,
}

to_uiControl :: proc(v: rawptr) -> ^uiControl{
    return cast(^uiControl)(v)
}

// alias of to_uiControl
as_uiControl :: proc(v: rawptr) -> ^uiControl{
    return to_uiControl(v)
}

@(default_calling_convention="c")
foreign lib {
	uiInit          :: proc(options: ^uiInitOptions) -> cstring ---
	uiUninit        :: proc() ---
	uiFreeInitError :: proc(err: cstring) ---
	uiMain          :: proc() ---
	uiMainSteps     :: proc() ---
	uiMainStep      :: proc(wait: i32) -> i32 ---
	uiQuit          :: proc() ---
	uiQueueMain     :: proc(f: proc "c" (data: rawptr), data: rawptr) ---

	// TODO standardize the looping behavior return type, either with some enum or something, and the test expressions throughout the code
	// TODO figure out what to do about looping and the exact point that the timer is rescheduled so we can document it; see https://github.com/andlabs/libui/pull/277
	// TODO (also in the above link) document that this cannot be called from any thread, unlike uiQueueMain()
	// TODO document that the minimum exact timing, either accuracy (timer burst, etc.) or granularity (15ms on Windows, etc.), is OS-defined
	// TODO also figure out how long until the initial tick is registered on all platforms to document
	// TODO also add a comment about how useful this could be in bindings, depending on the language being bound to
	uiTimer        :: proc(milliseconds: i32, f: proc "c" (data: rawptr) -> i32, data: rawptr) ---
	uiOnShouldQuit :: proc(f: proc "c" (data: rawptr) -> i32, data: rawptr) ---
	uiFreeText     :: proc(text: cstring) ---
}

uiControl :: struct {
	Signature:     u32,
	OSSignature:   u32,
	TypeSignature: u32,
	Destroy:       proc "c" (^uiControl),
	Handle:        proc "c" (^uiControl) -> c.uintptr_t,
	Parent:        proc "c" (^uiControl) -> ^uiControl,
	SetParent:     proc "c" (^uiControl, ^uiControl),
	Toplevel:      proc "c" (^uiControl) -> i32,
	Visible:       proc "c" (^uiControl) -> i32,
	Show:          proc "c" (^uiControl),
	Hide:          proc "c" (^uiControl),
	Enabled:       proc "c" (^uiControl) -> i32,
	Enable:        proc "c" (^uiControl),
	Disable:       proc "c" (^uiControl),
}

uiWindow :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiControlDestroy   :: proc(^uiControl) ---
	uiControlHandle    :: proc(^uiControl) -> c.uintptr_t ---
	uiControlParent    :: proc(^uiControl) -> ^uiControl ---
	uiControlSetParent :: proc(^uiControl, ^uiControl) ---
	uiControlToplevel  :: proc(^uiControl) -> i32 ---
	uiControlVisible   :: proc(^uiControl) -> i32 ---
	uiControlShow      :: proc(^uiControl) ---
	uiControlHide      :: proc(^uiControl) ---
	uiControlEnabled   :: proc(^uiControl) -> i32 ---
	uiControlEnable    :: proc(^uiControl) ---
	uiControlDisable   :: proc(^uiControl) ---
	uiAllocControl     :: proc(n: c.size_t, OSsig: u32, typesig: u32, typenamestr: cstring) -> ^uiControl ---
	uiFreeControl      :: proc(^uiControl) ---

	// TODO make sure all controls have these
	uiControlVerifySetParent           :: proc(^uiControl, ^uiControl) ---
	uiControlEnabledToUser             :: proc(^uiControl) -> i32 ---
	uiUserBugCannotSetParentOnToplevel :: proc(type: cstring) ---
}

@(default_calling_convention="c")
foreign lib {
	uiWindowTitle                :: proc(w: ^uiWindow) -> cstring ---
	uiWindowSetTitle             :: proc(w: ^uiWindow, title: cstring) ---
	uiWindowContentSize          :: proc(w: ^uiWindow, width: ^i32, height: ^i32) ---
	uiWindowSetContentSize       :: proc(w: ^uiWindow, width: i32, height: i32) ---
	uiWindowFullscreen           :: proc(w: ^uiWindow) -> i32 ---
	uiWindowSetFullscreen        :: proc(w: ^uiWindow, fullscreen: i32) ---
	uiWindowOnContentSizeChanged :: proc(w: ^uiWindow, f: proc "c" (^uiWindow, rawptr), data: rawptr) ---
	uiWindowOnClosing            :: proc(w: ^uiWindow, f: proc "c" (w: ^uiWindow, data: rawptr) -> i32, data: rawptr) ---
	uiWindowBorderless           :: proc(w: ^uiWindow) -> i32 ---
	uiWindowSetBorderless        :: proc(w: ^uiWindow, borderless: i32) ---
	uiWindowSetChild             :: proc(w: ^uiWindow, child: ^uiControl) ---
	uiWindowMargined             :: proc(w: ^uiWindow) -> i32 ---
	uiWindowSetMargined          :: proc(w: ^uiWindow, margined: i32) ---
	uiNewWindow                  :: proc(title: cstring, width: i32, height: i32, hasMenubar: i32) -> ^uiWindow ---
}

uiButton :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiButtonText      :: proc(b: ^uiButton) -> cstring ---
	uiButtonSetText   :: proc(b: ^uiButton, text: cstring) ---
	uiButtonOnClicked :: proc(b: ^uiButton, f: proc "c" (b: ^uiButton, data: rawptr), data: rawptr) ---
	uiNewButton       :: proc(text: cstring) -> ^uiButton ---
}

uiBox :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiBoxAppend        :: proc(b: ^uiBox, child: ^uiControl, stretchy: i32) ---
	uiBoxDelete        :: proc(b: ^uiBox, index: i32) ---
	uiBoxPadded        :: proc(b: ^uiBox) -> i32 ---
	uiBoxSetPadded     :: proc(b: ^uiBox, padded: i32) ---
	uiNewHorizontalBox :: proc() -> ^uiBox ---
	uiNewVerticalBox   :: proc() -> ^uiBox ---
}

uiCheckbox :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiCheckboxText       :: proc(_c: ^uiCheckbox) -> cstring ---
	uiCheckboxSetText    :: proc(_c: ^uiCheckbox, text: cstring) ---
	uiCheckboxOnToggled  :: proc(_c: ^uiCheckbox, f: proc "c" (_c: ^uiCheckbox, data: rawptr), data: rawptr) ---
	uiCheckboxChecked    :: proc(_c: ^uiCheckbox) -> i32 ---
	uiCheckboxSetChecked :: proc(_c: ^uiCheckbox, checked: i32) ---
	uiNewCheckbox        :: proc(text: cstring) -> ^uiCheckbox ---
}

uiEntry :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiEntryText        :: proc(e: ^uiEntry) -> cstring ---
	uiEntrySetText     :: proc(e: ^uiEntry, text: cstring) ---
	uiEntryOnChanged   :: proc(e: ^uiEntry, f: proc "c" (e: ^uiEntry, data: rawptr), data: rawptr) ---
	uiEntryReadOnly    :: proc(e: ^uiEntry) -> i32 ---
	uiEntrySetReadOnly :: proc(e: ^uiEntry, readonly: i32) ---
	uiNewEntry         :: proc() -> ^uiEntry ---
	uiNewPasswordEntry :: proc() -> ^uiEntry ---
	uiNewSearchEntry   :: proc() -> ^uiEntry ---
}

uiLabel :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiLabelText    :: proc(l: ^uiLabel) -> cstring ---
	uiLabelSetText :: proc(l: ^uiLabel, text: cstring) ---
	uiNewLabel     :: proc(text: cstring) -> ^uiLabel ---
}

uiTab :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiTabAppend      :: proc(t: ^uiTab, name: cstring, _c: ^uiControl) ---
	uiTabInsertAt    :: proc(t: ^uiTab, name: cstring, before: i32, _c: ^uiControl) ---
	uiTabDelete      :: proc(t: ^uiTab, index: i32) ---
	uiTabNumPages    :: proc(t: ^uiTab) -> i32 ---
	uiTabMargined    :: proc(t: ^uiTab, page: i32) -> i32 ---
	uiTabSetMargined :: proc(t: ^uiTab, page: i32, margined: i32) ---
	uiNewTab         :: proc() -> ^uiTab ---
}

uiGroup :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiGroupTitle       :: proc(g: ^uiGroup) -> cstring ---
	uiGroupSetTitle    :: proc(g: ^uiGroup, title: cstring) ---
	uiGroupSetChild    :: proc(g: ^uiGroup, _c: ^uiControl) ---
	uiGroupMargined    :: proc(g: ^uiGroup) -> i32 ---
	uiGroupSetMargined :: proc(g: ^uiGroup, margined: i32) ---
	uiNewGroup         :: proc(title: cstring) -> ^uiGroup ---
}

uiSpinbox :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiSpinboxValue     :: proc(s: ^uiSpinbox) -> i32 ---
	uiSpinboxSetValue  :: proc(s: ^uiSpinbox, value: i32) ---
	uiSpinboxOnChanged :: proc(s: ^uiSpinbox, f: proc "c" (s: ^uiSpinbox, data: rawptr), data: rawptr) ---
	uiNewSpinbox       :: proc(min: i32, max: i32) -> ^uiSpinbox ---
}

uiSlider :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiSliderValue     :: proc(s: ^uiSlider) -> i32 ---
	uiSliderSetValue  :: proc(s: ^uiSlider, value: i32) ---
	uiSliderOnChanged :: proc(s: ^uiSlider, f: proc "c" (s: ^uiSlider, data: rawptr), data: rawptr) ---
	uiNewSlider       :: proc(min: i32, max: i32) -> ^uiSlider ---
}

uiProgressBar :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiProgressBarValue    :: proc(p: ^uiProgressBar) -> i32 ---
	uiProgressBarSetValue :: proc(p: ^uiProgressBar, n: i32) ---
	uiNewProgressBar      :: proc() -> ^uiProgressBar ---
}

uiSeparator :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiNewHorizontalSeparator :: proc() -> ^uiSeparator ---
	uiNewVerticalSeparator   :: proc() -> ^uiSeparator ---
}

uiCombobox :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiComboboxAppend      :: proc(_c: ^uiCombobox, text: cstring) ---
	uiComboboxSelected    :: proc(_c: ^uiCombobox) -> i32 ---
	uiComboboxSetSelected :: proc(_c: ^uiCombobox, n: i32) ---
	uiComboboxOnSelected  :: proc(_c: ^uiCombobox, f: proc "c" (_c: ^uiCombobox, data: rawptr), data: rawptr) ---
	uiNewCombobox         :: proc() -> ^uiCombobox ---
}

uiEditableCombobox :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiEditableComboboxAppend  :: proc(_c: ^uiEditableCombobox, text: cstring) ---
	uiEditableComboboxText    :: proc(_c: ^uiEditableCombobox) -> cstring ---
	uiEditableComboboxSetText :: proc(_c: ^uiEditableCombobox, text: cstring) ---

	// TODO what do we call a function that sets the currently selected item and fills the text field with it? editable comboboxes have no consistent concept of selected item
	uiEditableComboboxOnChanged :: proc(_c: ^uiEditableCombobox, f: proc "c" (_c: ^uiEditableCombobox, data: rawptr), data: rawptr) ---
	uiNewEditableCombobox       :: proc() -> ^uiEditableCombobox ---
}

uiRadioButtons :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiRadioButtonsAppend      :: proc(r: ^uiRadioButtons, text: cstring) ---
	uiRadioButtonsSelected    :: proc(r: ^uiRadioButtons) -> i32 ---
	uiRadioButtonsSetSelected :: proc(r: ^uiRadioButtons, n: i32) ---
	uiRadioButtonsOnSelected  :: proc(r: ^uiRadioButtons, f: proc "c" (^uiRadioButtons, rawptr), data: rawptr) ---
	uiNewRadioButtons         :: proc() -> ^uiRadioButtons ---
}

tm               :: struct {}
uiDateTimePicker :: struct {}

@(default_calling_convention="c")
foreign lib {
	// TODO document that tm_wday and tm_yday are undefined, and tm_isdst should be -1
	// TODO document that for both sides
	// TODO document time zone conversions or lack thereof
	// TODO for Time: define what values are returned when a part is missing
	uiDateTimePickerTime      :: proc(d: ^uiDateTimePicker, time: ^tm) ---
	uiDateTimePickerSetTime   :: proc(d: ^uiDateTimePicker, time: ^tm) ---
	uiDateTimePickerOnChanged :: proc(d: ^uiDateTimePicker, f: proc "c" (^uiDateTimePicker, rawptr), data: rawptr) ---
	uiNewDateTimePicker       :: proc() -> ^uiDateTimePicker ---
	uiNewDatePicker           :: proc() -> ^uiDateTimePicker ---
	uiNewTimePicker           :: proc() -> ^uiDateTimePicker ---
}

uiMultilineEntry :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiMultilineEntryText           :: proc(e: ^uiMultilineEntry) -> cstring ---
	uiMultilineEntrySetText        :: proc(e: ^uiMultilineEntry, text: cstring) ---
	uiMultilineEntryAppend         :: proc(e: ^uiMultilineEntry, text: cstring) ---
	uiMultilineEntryOnChanged      :: proc(e: ^uiMultilineEntry, f: proc "c" (e: ^uiMultilineEntry, data: rawptr), data: rawptr) ---
	uiMultilineEntryReadOnly       :: proc(e: ^uiMultilineEntry) -> i32 ---
	uiMultilineEntrySetReadOnly    :: proc(e: ^uiMultilineEntry, readonly: i32) ---
	uiNewMultilineEntry            :: proc() -> ^uiMultilineEntry ---
	uiNewNonWrappingMultilineEntry :: proc() -> ^uiMultilineEntry ---
}

uiMenuItem :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiMenuItemEnable     :: proc(m: ^uiMenuItem) ---
	uiMenuItemDisable    :: proc(m: ^uiMenuItem) ---
	uiMenuItemOnClicked  :: proc(m: ^uiMenuItem, f: proc "c" (sender: ^uiMenuItem, window: ^uiWindow, data: rawptr), data: rawptr) ---
	uiMenuItemChecked    :: proc(m: ^uiMenuItem) -> i32 ---
	uiMenuItemSetChecked :: proc(m: ^uiMenuItem, checked: i32) ---
}

uiMenu :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiMenuAppendItem            :: proc(m: ^uiMenu, name: cstring) -> ^uiMenuItem ---
	uiMenuAppendCheckItem       :: proc(m: ^uiMenu, name: cstring) -> ^uiMenuItem ---
	uiMenuAppendQuitItem        :: proc(m: ^uiMenu) -> ^uiMenuItem ---
	uiMenuAppendPreferencesItem :: proc(m: ^uiMenu) -> ^uiMenuItem ---
	uiMenuAppendAboutItem       :: proc(m: ^uiMenu) -> ^uiMenuItem ---
	uiMenuAppendSeparator       :: proc(m: ^uiMenu) ---
	uiNewMenu                   :: proc(name: cstring) -> ^uiMenu ---
	uiOpenFile                  :: proc(parent: ^uiWindow) -> cstring ---
	uiSaveFile                  :: proc(parent: ^uiWindow) -> cstring ---
	uiMsgBox                    :: proc(parent: ^uiWindow, title: cstring, description: cstring) ---
	uiMsgBoxError               :: proc(parent: ^uiWindow, title: cstring, description: cstring) ---
}

uiArea        :: struct {}
uiDrawContext :: struct {}

uiAreaHandler :: struct {
	Draw: proc "c" (^uiAreaHandler, ^uiArea, ^uiAreaDrawParams),

	// TODO document that resizes cause a full redraw for non-scrolling areas; implementation-defined for scrolling areas
	MouseEvent: proc "c" (^uiAreaHandler, ^uiArea, ^uiAreaMouseEvent),

	// TODO document that on first show if the mouse is already in the uiArea then one gets sent with left=0
	// TODO what about when the area is hidden and then shown again?
	MouseCrossed: proc "c" (_: ^uiAreaHandler, _: ^uiArea, left: i32),
	DragBroken:   proc "c" (^uiAreaHandler, ^uiArea),
	KeyEvent:     proc "c" (^uiAreaHandler, ^uiArea, ^uiAreaKeyEvent) -> i32,
}

// TODO RTL layouts?
// TODO reconcile edge and corner naming
uiWindowResizeEdge :: u32

uiWindowResizeEdgeTop         :: 1
uiWindowResizeEdgeLeft        :: 0
uiWindowResizeEdgeBottom      :: 3
uiWindowResizeEdgeRight       :: 2
uiWindowResizeEdgeTopRight    :: 5
uiWindowResizeEdgeBottomLeft  :: 6
uiWindowResizeEdgeBottomRight :: 7
uiWindowResizeEdgeTopLeft     :: 4

@(default_calling_convention="c")
foreign lib {
	// TODO give a better name
	// TODO document the types of width and height
	uiAreaSetSize :: proc(a: ^uiArea, width: i32, height: i32) ---

	// TODO uiAreaQueueRedraw()
	uiAreaQueueRedrawAll :: proc(a: ^uiArea) ---
	uiAreaScrollTo       :: proc(a: ^uiArea, x: f64, y: f64, width: f64, height: f64) ---

	// TODO document these can only be called within Mouse() handlers
	// TODO should these be allowed on scrolling areas?
	// TODO decide which mouse events should be accepted; Down is the only one guaranteed to work right now
	// TODO what happens to events after calling this up to and including the next mouse up?
	// TODO release capture?
	uiAreaBeginUserWindowMove   :: proc(a: ^uiArea) ---
	uiAreaBeginUserWindowResize :: proc(a: ^uiArea, edge: uiWindowResizeEdge) ---
	uiNewArea                   :: proc(ah: ^uiAreaHandler) -> ^uiArea ---
	uiNewScrollingArea          :: proc(ah: ^uiAreaHandler, width: i32, height: i32) -> ^uiArea ---
}

uiAreaDrawParams :: struct {
	Context: ^uiDrawContext,

	// TODO document that this is only defined for nonscrolling areas
	AreaWidth:  f64,
	AreaHeight: f64,
	ClipX:      f64,
	ClipY:      f64,
	ClipWidth:  f64,
	ClipHeight: f64,
}

uiDrawPath      :: struct {}
uiDrawBrushType :: u32

uiDrawBrushTypeLinearGradient :: 1
uiDrawBrushTypeSolid          :: 0
uiDrawBrushTypeRadialGradient :: 2
uiDrawBrushTypeImage          :: 3
uiDrawLineCapFlat             :: 0

uiDrawLineCap :: u32

uiDrawLineCapSquare :: 2
uiDrawLineCapRound  :: 1
uiDrawLineJoinMiter :: 0
uiDrawLineJoinRound :: 1
uiDrawLineJoinBevel :: 2

uiDrawLineJoin :: u32

// this is the default for botoh cairo and Direct2D (in the latter case, from the C++ helper functions)
// Core Graphics doesn't explicitly specify a default, but NSBezierPath allows you to choose one, and this is the initial value
// so we're good to use it too!
uiDrawDefaultMiterLimit :: 10.0

uiDrawFillMode :: u32

uiDrawFillModeWinding   :: 0
uiDrawFillModeAlternate :: 1

uiDrawMatrix :: struct {
	M11: f64,
	M12: f64,
	M21: f64,
	M22: f64,
	M31: f64,
	M32: f64,
}

uiDrawBrush :: struct {
	Type: uiDrawBrushType,

	// solid brushes
	R: f64,
	G: f64,
	B: f64,
	A: f64,

	// gradient brushes
	X0:          f64, // linear: start X, radial: start X
	Y0:          f64, // linear: start Y, radial: start Y
	X1:          f64, // linear: end X, radial: outer circle center X
	Y1:          f64, // linear: end Y, radial: outer circle center Y
	OuterRadius: f64, // radial gradients only
	Stops:       ^uiDrawBrushGradientStop,
	NumStops:    c.size_t,
}

uiDrawBrushGradientStop :: struct {
	Pos: f64,
	R:   f64,
	G:   f64,
	B:   f64,
	A:   f64,
}

uiDrawStrokeParams :: struct {
	Cap:  uiDrawLineCap,
	Join: uiDrawLineJoin,

	// TODO what if this is 0? on windows there will be a crash with dashing
	Thickness:  f64,
	MiterLimit: f64,
	Dashes:     ^f64,

	// TOOD what if this is 1 on Direct2D?
	// TODO what if a dash is 0 on Cairo or Quartz?
	NumDashes: c.size_t,
	DashPhase: f64,
}

@(default_calling_convention="c")
foreign lib {
	uiDrawNewPath              :: proc(fillMode: uiDrawFillMode) -> ^uiDrawPath ---
	uiDrawFreePath             :: proc(p: ^uiDrawPath) ---
	uiDrawPathNewFigure        :: proc(p: ^uiDrawPath, x: f64, y: f64) ---
	uiDrawPathNewFigureWithArc :: proc(p: ^uiDrawPath, xCenter: f64, yCenter: f64, radius: f64, startAngle: f64, sweep: f64, negative: i32) ---
	uiDrawPathLineTo           :: proc(p: ^uiDrawPath, x: f64, y: f64) ---

	// notes: angles are both relative to 0 and go counterclockwise
	// TODO is the initial line segment on cairo and OS X a proper join?
	// TODO what if sweep < 0?
	uiDrawPathArcTo    :: proc(p: ^uiDrawPath, xCenter: f64, yCenter: f64, radius: f64, startAngle: f64, sweep: f64, negative: i32) ---
	uiDrawPathBezierTo :: proc(p: ^uiDrawPath, c1x: f64, c1y: f64, c2x: f64, c2y: f64, endX: f64, endY: f64) ---

	// TODO quadratic bezier
	uiDrawPathCloseFigure :: proc(p: ^uiDrawPath) ---

	// TODO effect of these when a figure is already started
	uiDrawPathAddRectangle :: proc(p: ^uiDrawPath, x: f64, y: f64, width: f64, height: f64) ---
	uiDrawPathEnd          :: proc(p: ^uiDrawPath) ---
	uiDrawStroke           :: proc(_c: ^uiDrawContext, path: ^uiDrawPath, b: ^uiDrawBrush, p: ^uiDrawStrokeParams) ---
	uiDrawFill             :: proc(_c: ^uiDrawContext, path: ^uiDrawPath, b: ^uiDrawBrush) ---

	// TODO primitives:
	// - rounded rectangles
	// - elliptical arcs
	// - quadratic bezier curves
	uiDrawMatrixSetIdentity    :: proc(m: ^uiDrawMatrix) ---
	uiDrawMatrixTranslate      :: proc(m: ^uiDrawMatrix, x: f64, y: f64) ---
	uiDrawMatrixScale          :: proc(m: ^uiDrawMatrix, xCenter: f64, yCenter: f64, x: f64, y: f64) ---
	uiDrawMatrixRotate         :: proc(m: ^uiDrawMatrix, x: f64, y: f64, amount: f64) ---
	uiDrawMatrixSkew           :: proc(m: ^uiDrawMatrix, x: f64, y: f64, xamount: f64, yamount: f64) ---
	uiDrawMatrixMultiply       :: proc(dest: ^uiDrawMatrix, src: ^uiDrawMatrix) ---
	uiDrawMatrixInvertible     :: proc(m: ^uiDrawMatrix) -> i32 ---
	uiDrawMatrixInvert         :: proc(m: ^uiDrawMatrix) -> i32 ---
	uiDrawMatrixTransformPoint :: proc(m: ^uiDrawMatrix, x: ^f64, y: ^f64) ---
	uiDrawMatrixTransformSize  :: proc(m: ^uiDrawMatrix, x: ^f64, y: ^f64) ---
	uiDrawTransform            :: proc(_c: ^uiDrawContext, m: ^uiDrawMatrix) ---

	// TODO add a uiDrawPathStrokeToFill() or something like that
	uiDrawClip    :: proc(_c: ^uiDrawContext, path: ^uiDrawPath) ---
	uiDrawSave    :: proc(_c: ^uiDrawContext) ---
	uiDrawRestore :: proc(_c: ^uiDrawContext) ---
}

uiAttribute :: struct {}

@(default_calling_convention="c")
foreign lib {
	// @role uiAttribute destructor
	// uiFreeAttribute() frees a uiAttribute. You generally do not need to
	// call this yourself, as uiAttributedString does this for you. In fact,
	// it is an error to call this function on a uiAttribute that has been
	// given to a uiAttributedString. You can call this, however, if you
	// created a uiAttribute that you aren't going to use later.
	uiFreeAttribute :: proc(a: ^uiAttribute) ---
}

uiAttributeTypeSize    :: 1
uiAttributeTypeFamily  :: 0
uiAttributeTypeItalic  :: 3
uiAttributeTypeWeight  :: 2
uiAttributeTypeStretch :: 4

// uiAttributeType holds the possible uiAttribute types that may be
// returned by uiAttributeGetType(). Refer to the documentation for
// each type's constructor function for details on each type.
uiAttributeType :: u32

uiAttributeTypeColor          :: 5
uiAttributeTypeBackground     :: 6
uiAttributeTypeUnderline      :: 7
uiAttributeTypeUnderlineColor :: 8
uiAttributeTypeFeatures       :: 9

@(default_calling_convention="c")
foreign lib {
	// uiAttributeGetType() returns the type of a.
	// TODO I don't like this name
	uiAttributeGetType :: proc(a: ^uiAttribute) -> uiAttributeType ---

	// uiNewFamilyAttribute() creates a new uiAttribute that changes the
	// font family of the text it is applied to. family is copied; you do not
	// need to keep it alive after uiNewFamilyAttribute() returns. Font
	// family names are case-insensitive.
	uiNewFamilyAttribute :: proc(family: cstring) -> ^uiAttribute ---

	// uiAttributeFamily() returns the font family stored in a. The
	// returned string is owned by a. It is an error to call this on a
	// uiAttribute that does not hold a font family.
	uiAttributeFamily :: proc(a: ^uiAttribute) -> cstring ---

	// uiNewSizeAttribute() creates a new uiAttribute that changes the
	// size of the text it is applied to, in typographical points.
	uiNewSizeAttribute :: proc(size: f64) -> ^uiAttribute ---

	// uiAttributeSize() returns the font size stored in a. It is an error to
	// call this on a uiAttribute that does not hold a font size.
	uiAttributeSize :: proc(a: ^uiAttribute) -> f64 ---
}

// uiTextWeight represents possible text weights. These roughly
// map to the OS/2 text weight field of TrueType and OpenType
// fonts, or to CSS weight numbers. The named constants are
// nominal values; the actual values may vary by font and by OS,
// though this isn't particularly likely. Any value between
// uiTextWeightMinimum and uiTextWeightMaximum, inclusive,
// is allowed.
//
// Note that due to restrictions in early versions of Windows, some
// fonts have "special" weights be exposed in many programs as
// separate font families. This is perhaps most notable with
// Arial Black. libui does not do this, even on Windows (because the
// DirectWrite API libui uses on Windows does not do this); to
// specify Arial Black, use family Arial and weight uiTextWeightBlack.
uiTextWeight :: u32

uiTextWeightUltraLight :: 200
uiTextWeightLight      :: 300
uiTextWeightBook       :: 350
uiTextWeightNormal     :: 400
uiTextWeightMedium     :: 500
uiTextWeightMinimum    :: 0
uiTextWeightThin       :: 100
uiTextWeightSemiBold   :: 600
uiTextWeightUltraBold  :: 800
uiTextWeightUltraHeavy :: 950
uiTextWeightBold       :: 700
uiTextWeightHeavy      :: 900
uiTextWeightMaximum    :: 1000

@(default_calling_convention="c")
foreign lib {
	// uiNewWeightAttribute() creates a new uiAttribute that changes the
	// weight of the text it is applied to. It is an error to specify a weight
	// outside the range [uiTextWeightMinimum,
	// uiTextWeightMaximum].
	uiNewWeightAttribute :: proc(weight: uiTextWeight) -> ^uiAttribute ---

	// uiAttributeWeight() returns the font weight stored in a. It is an error
	// to call this on a uiAttribute that does not hold a font weight.
	uiAttributeWeight :: proc(a: ^uiAttribute) -> uiTextWeight ---
}

// uiTextItalic represents possible italic modes for a font. Italic
// represents "true" italics where the slanted glyphs have custom
// shapes, whereas oblique represents italics that are merely slanted
// versions of the normal glyphs. Most fonts usually have one or the
// other.
uiTextItalic :: u32

uiTextItalicNormal  :: 0
uiTextItalicOblique :: 1
uiTextItalicItalic  :: 2

@(default_calling_convention="c")
foreign lib {
	// uiNewItalicAttribute() creates a new uiAttribute that changes the
	// italic mode of the text it is applied to. It is an error to specify an
	// italic mode not specified in uiTextItalic.
	uiNewItalicAttribute :: proc(italic: uiTextItalic) -> ^uiAttribute ---

	// uiAttributeItalic() returns the font italic mode stored in a. It is an
	// error to call this on a uiAttribute that does not hold a font italic
	// mode.
	uiAttributeItalic :: proc(a: ^uiAttribute) -> uiTextItalic ---
}

uiTextStretchExtraCondensed :: 1
uiTextStretchCondensed      :: 2
uiTextStretchSemiCondensed  :: 3

// uiTextStretch represents possible stretches (also called "widths")
// of a font.
//
// Note that due to restrictions in early versions of Windows, some
// fonts have "special" stretches be exposed in many programs as
// separate font families. This is perhaps most notable with
// Arial Condensed. libui does not do this, even on Windows (because
// the DirectWrite API libui uses on Windows does not do this); to
// specify Arial Condensed, use family Arial and stretch
// uiTextStretchCondensed.
uiTextStretch :: u32

uiTextStretchUltraCondensed :: 0
uiTextStretchExpanded       :: 6
uiTextStretchSemiExpanded   :: 5
uiTextStretchUltraExpanded  :: 8
uiTextStretchExtraExpanded  :: 7
uiTextStretchNormal         :: 4

@(default_calling_convention="c")
foreign lib {
	// uiNewStretchAttribute() creates a new uiAttribute that changes the
	// stretch of the text it is applied to. It is an error to specify a strech
	// not specified in uiTextStretch.
	uiNewStretchAttribute :: proc(stretch: uiTextStretch) -> ^uiAttribute ---

	// uiAttributeStretch() returns the font stretch stored in a. It is an
	// error to call this on a uiAttribute that does not hold a font stretch.
	uiAttributeStretch :: proc(a: ^uiAttribute) -> uiTextStretch ---

	// uiNewColorAttribute() creates a new uiAttribute that changes the
	// color of the text it is applied to. It is an error to specify an invalid
	// color.
	uiNewColorAttribute :: proc(r: f64, g: f64, b: f64, a: f64) -> ^uiAttribute ---

	// uiAttributeColor() returns the text color stored in a. It is an
	// error to call this on a uiAttribute that does not hold a text color.
	uiAttributeColor :: proc(a: ^uiAttribute, r: ^f64, g: ^f64, b: ^f64, alpha: ^f64) ---

	// uiNewBackgroundAttribute() creates a new uiAttribute that
	// changes the background color of the text it is applied to. It is an
	// error to specify an invalid color.
	uiNewBackgroundAttribute :: proc(r: f64, g: f64, b: f64, a: f64) -> ^uiAttribute ---
}

uiUnderlineNone :: 0

// uiUnderline specifies a type of underline to use on text.
uiUnderline :: u32

uiUnderlineSuggestion :: 3
uiUnderlineDouble     :: 2
uiUnderlineSingle     :: 1

@(default_calling_convention="c")
foreign lib {
	// uiNewUnderlineAttribute() creates a new uiAttribute that changes
	// the type of underline on the text it is applied to. It is an error to
	// specify an underline type not specified in uiUnderline.
	uiNewUnderlineAttribute :: proc(u: uiUnderline) -> ^uiAttribute ---

	// uiAttributeUnderline() returns the underline type stored in a. It is
	// an error to call this on a uiAttribute that does not hold an underline
	// style.
	uiAttributeUnderline :: proc(a: ^uiAttribute) -> uiUnderline ---
}

uiUnderlineColorCustom  :: 0
uiUnderlineColorGrammar :: 2

// uiUnderlineColor specifies the color of any underline on the text it
// is applied to, regardless of the type of underline. In addition to
// being able to specify a custom color, you can explicitly specify
// platform-specific colors for suggestion underlines; to use them
// correctly, pair them with uiUnderlineSuggestion (though they can
// be used on other types of underline as well).
//
// If an underline type is applied but no underline color is
// specified, the text color is used instead. If an underline color
// is specified without an underline type, the underline color
// attribute is ignored, but not removed from the uiAttributedString.
uiUnderlineColor :: u32

uiUnderlineColorSpelling  :: 1
uiUnderlineColorAuxiliary :: 3

@(default_calling_convention="c")
foreign lib {
	// uiNewUnderlineColorAttribute() creates a new uiAttribute that
	// changes the color of the underline on the text it is applied to.
	// It is an error to specify an underline color not specified in
	// uiUnderlineColor.
	//
	// If the specified color type is uiUnderlineColorCustom, it is an
	// error to specify an invalid color value. Otherwise, the color values
	// are ignored and should be specified as zero.
	uiNewUnderlineColorAttribute :: proc(u: uiUnderlineColor, r: f64, g: f64, b: f64, a: f64) -> ^uiAttribute ---

	// uiAttributeUnderlineColor() returns the underline color stored in
	// a. It is an error to call this on a uiAttribute that does not hold an
	// underline color.
	uiAttributeUnderlineColor :: proc(a: ^uiAttribute, u: ^uiUnderlineColor, r: ^f64, g: ^f64, b: ^f64, alpha: ^f64) ---
}

uiOpenTypeFeatures :: struct {}

// uiOpenTypeFeaturesForEachFunc is the type of the function
// invoked by uiOpenTypeFeaturesForEach() for every OpenType
// feature in otf. Refer to that function's documentation for more
// details.
uiOpenTypeFeaturesForEachFunc :: proc "c" (otf: ^uiOpenTypeFeatures, a: i8, b: i8, _c: i8, d: i8, value: u32, data: rawptr) -> uiForEach

@(default_calling_convention="c")
foreign lib {
	// @role uiOpenTypeFeatures constructor
	// uiNewOpenTypeFeatures() returns a new uiOpenTypeFeatures
	// instance, with no tags yet added.
	uiNewOpenTypeFeatures :: proc() -> ^uiOpenTypeFeatures ---

	// @role uiOpenTypeFeatures destructor
	// uiFreeOpenTypeFeatures() frees otf.
	uiFreeOpenTypeFeatures :: proc(otf: ^uiOpenTypeFeatures) ---

	// uiOpenTypeFeaturesClone() makes a copy of otf and returns it.
	// Changing one will not affect the other.
	uiOpenTypeFeaturesClone :: proc(otf: ^uiOpenTypeFeatures) -> ^uiOpenTypeFeatures ---

	// uiOpenTypeFeaturesAdd() adds the given feature tag and value
	// to otf. The feature tag is specified by a, b, c, and d. If there is
	// already a value associated with the specified tag in otf, the old
	// value is removed.
	uiOpenTypeFeaturesAdd :: proc(otf: ^uiOpenTypeFeatures, a: i8, b: i8, _c: i8, d: i8, value: u32) ---

	// uiOpenTypeFeaturesRemove() removes the given feature tag
	// and value from otf. If the tag is not present in otf,
	// uiOpenTypeFeaturesRemove() does nothing.
	uiOpenTypeFeaturesRemove :: proc(otf: ^uiOpenTypeFeatures, a: i8, b: i8, _c: i8, d: i8) ---

	// uiOpenTypeFeaturesGet() determines whether the given feature
	// tag is present in otf. If it is, *value is set to the tag's value and
	// nonzero is returned. Otherwise, zero is returned.
	//
	// Note that if uiOpenTypeFeaturesGet() returns zero, value isn't
	// changed. This is important: if a feature is not present in a
	// uiOpenTypeFeatures, the feature is NOT treated as if its
	// value was zero anyway. Script-specific font shaping rules and
	// font-specific feature settings may use a different default value
	// for a feature. You should likewise not treat a missing feature as
	// having a value of zero either. Instead, a missing feature should
	// be treated as having some unspecified default value.
	uiOpenTypeFeaturesGet :: proc(otf: ^uiOpenTypeFeatures, a: i8, b: i8, _c: i8, d: i8, value: ^u32) -> i32 ---

	// uiOpenTypeFeaturesForEach() executes f for every tag-value
	// pair in otf. The enumeration order is unspecified. You cannot
	// modify otf while uiOpenTypeFeaturesForEach() is running.
	uiOpenTypeFeaturesForEach :: proc(otf: ^uiOpenTypeFeatures, f: uiOpenTypeFeaturesForEachFunc, data: rawptr) ---

	// uiNewFeaturesAttribute() creates a new uiAttribute that changes
	// the font family of the text it is applied to. otf is copied; you may
	// free it after uiNewFeaturesAttribute() returns.
	uiNewFeaturesAttribute :: proc(otf: ^uiOpenTypeFeatures) -> ^uiAttribute ---

	// uiAttributeFeatures() returns the OpenType features stored in a.
	// The returned uiOpenTypeFeatures object is owned by a. It is an
	// error to call this on a uiAttribute that does not hold OpenType
	// features.
	uiAttributeFeatures :: proc(a: ^uiAttribute) -> ^uiOpenTypeFeatures ---
}

uiAttributedString :: struct {}

// uiAttributedStringForEachAttributeFunc is the type of the function
// invoked by uiAttributedStringForEachAttribute() for every
// attribute in s. Refer to that function's documentation for more
// details.
uiAttributedStringForEachAttributeFunc :: proc "c" (s: ^uiAttributedString, a: ^uiAttribute, start: c.size_t, end: c.size_t, data: rawptr) -> uiForEach

@(default_calling_convention="c")
foreign lib {
	// @role uiAttributedString constructor
	// uiNewAttributedString() creates a new uiAttributedString from
	// initialString. The string will be entirely unattributed.
	uiNewAttributedString :: proc(initialString: cstring) -> ^uiAttributedString ---

	// @role uiAttributedString destructor
	// uiFreeAttributedString() destroys the uiAttributedString s.
	// It will also free all uiAttributes within.
	uiFreeAttributedString :: proc(s: ^uiAttributedString) ---

	// uiAttributedStringString() returns the textual content of s as a
	// '\0'-terminated UTF-8 string. The returned pointer is valid until
	// the next change to the textual content of s.
	uiAttributedStringString :: proc(s: ^uiAttributedString) -> cstring ---

	// uiAttributedStringLength() returns the number of UTF-8 bytes in
	// the textual content of s, excluding the terminating '\0'.
	uiAttributedStringLen :: proc(s: ^uiAttributedString) -> c.size_t ---

	// uiAttributedStringAppendUnattributed() adds the '\0'-terminated
	// UTF-8 string str to the end of s. The new substring will be
	// unattributed.
	uiAttributedStringAppendUnattributed :: proc(s: ^uiAttributedString, str: cstring) ---

	// uiAttributedStringInsertAtUnattributed() adds the '\0'-terminated
	// UTF-8 string str to s at the byte position specified by at. The new
	// substring will be unattributed; existing attributes will be moved
	// along with their text.
	uiAttributedStringInsertAtUnattributed :: proc(s: ^uiAttributedString, str: cstring, at: c.size_t) ---

	// uiAttributedStringDelete() deletes the characters and attributes of
	// s in the byte range [start, end).
	uiAttributedStringDelete :: proc(s: ^uiAttributedString, start: c.size_t, end: c.size_t) ---

	// uiAttributedStringSetAttribute() sets a in the byte range [start, end)
	// of s. Any existing attributes in that byte range of the same type are
	// removed. s takes ownership of a; you should not use it after
	// uiAttributedStringSetAttribute() returns.
	uiAttributedStringSetAttribute :: proc(s: ^uiAttributedString, a: ^uiAttribute, start: c.size_t, end: c.size_t) ---

	// uiAttributedStringForEachAttribute() enumerates all the
	// uiAttributes in s. It is an error to modify s in f. Within f, s still
	// owns the attribute; you can neither free it nor save it for later
	// use.
	// TODO reword the above for consistency (TODO and find out what I meant by that)
	// TODO define an enumeration order (or mark it as undefined); also define how consecutive runs of identical attributes are handled here and sync with the definition of uiAttributedString itself
	uiAttributedStringForEachAttribute :: proc(s: ^uiAttributedString, f: uiAttributedStringForEachAttributeFunc, data: rawptr) ---

	// TODO const correct this somehow (the implementation needs to mutate the structure)
	uiAttributedStringNumGraphemes :: proc(s: ^uiAttributedString) -> c.size_t ---

	// TODO const correct this somehow (the implementation needs to mutate the structure)
	uiAttributedStringByteIndexToGrapheme :: proc(s: ^uiAttributedString, pos: c.size_t) -> c.size_t ---

	// TODO const correct this somehow (the implementation needs to mutate the structure)
	uiAttributedStringGraphemeToByteIndex :: proc(s: ^uiAttributedString, pos: c.size_t) -> c.size_t ---
}

uiFontDescriptor :: struct {
	// TODO const-correct this or figure out how to deal with this when getting a value
	Family:  cstring,
	Size:    f64,
	Weight:  uiTextWeight,
	Italic:  uiTextItalic,
	Stretch: uiTextStretch,
}

uiDrawTextLayout :: struct {}

// uiDrawTextAlign specifies the alignment of lines of text in a
// uiDrawTextLayout.
// TODO should this really have Draw in the name?
uiDrawTextAlign :: u32

uiDrawTextAlignLeft   :: 0
uiDrawTextAlignCenter :: 1
uiDrawTextAlignRight  :: 2

// TODO const-correct this somehow
uiDrawTextLayoutParams :: struct {
	String:      ^uiAttributedString,
	DefaultFont: ^uiFontDescriptor,
	Width:       f64,
	Align:       uiDrawTextAlign,
}

@(default_calling_convention="c")
foreign lib {
	// @role uiDrawTextLayout constructor
	// uiDrawNewTextLayout() creates a new uiDrawTextLayout from
	// the given parameters.
	//
	// TODO
	// - allow creating a layout out of a substring
	// - allow marking compositon strings
	// - allow marking selections, even after creation
	// - add the following functions:
	// 	- uiDrawTextLayoutHeightForWidth() (returns the height that a layout would need to be to display the entire string at a given width)
	// 	- uiDrawTextLayoutRangeForSize() (returns what substring would fit in a given size)
	// 	- uiDrawTextLayoutNewWithHeight() (limits amount of string used by the height)
	// - some function to fix up a range (for text editing)
	uiDrawNewTextLayout :: proc(params: ^uiDrawTextLayoutParams) -> ^uiDrawTextLayout ---

	// @role uiDrawFreeTextLayout destructor
	// uiDrawFreeTextLayout() frees tl. The underlying
	// uiAttributedString is not freed.
	uiDrawFreeTextLayout :: proc(tl: ^uiDrawTextLayout) ---

	// uiDrawText() draws tl in c with the top-left point of tl at (x, y).
	uiDrawText :: proc(_c: ^uiDrawContext, tl: ^uiDrawTextLayout, x: f64, y: f64) ---

	// uiDrawTextLayoutExtents() returns the width and height of tl
	// in width and height. The returned width may be smaller than
	// the width passed into uiDrawNewTextLayout() depending on
	// how the text in tl is wrapped. Therefore, you can use this
	// function to get the actual size of the text layout.
	uiDrawTextLayoutExtents :: proc(tl: ^uiDrawTextLayout, width: ^f64, height: ^f64) ---
}

uiFontButton :: struct {}

@(default_calling_convention="c")
foreign lib {
	// uiFontButtonFont() returns the font currently selected in the uiFontButton in desc.
	// uiFontButtonFont() allocates resources in desc; when you are done with the font, call uiFreeFontButtonFont() to release them.
	// uiFontButtonFont() does not allocate desc itself; you must do so.
	// TODO have a function that sets an entire font descriptor to a range in a uiAttributedString at once, for SetFont?
	uiFontButtonFont :: proc(b: ^uiFontButton, desc: ^uiFontDescriptor) ---

	// TOOD SetFont, mechanics
	// uiFontButtonOnChanged() sets the function that is called when the font in the uiFontButton is changed.
	uiFontButtonOnChanged :: proc(b: ^uiFontButton, f: proc "c" (^uiFontButton, rawptr), data: rawptr) ---

	// uiNewFontButton() creates a new uiFontButton. The default font selected into the uiFontButton is OS-defined.
	uiNewFontButton :: proc() -> ^uiFontButton ---

	// uiFreeFontButtonFont() frees resources allocated in desc by uiFontButtonFont().
	// After calling uiFreeFontButtonFont(), the contents of desc should be assumed to be undefined (though since you allocate desc itself, you can safely reuse desc for other font descriptors).
	// Calling uiFreeFontButtonFont() on a uiFontDescriptor not returned by uiFontButtonFont() results in undefined behavior.
	uiFreeFontButtonFont :: proc(desc: ^uiFontDescriptor) ---
}

uiModifiers :: u32

uiModifierCtrl  :: 1
uiModifierAlt   :: 2
uiModifierSuper :: 8
uiModifierShift :: 4

// TODO document drag captures
uiAreaMouseEvent :: struct {
	// TODO document what these mean for scrolling areas
	X: f64,
	Y: f64,

	// TODO see draw above
	AreaWidth:  f64,
	AreaHeight: f64,
	Down:       i32,
	Up:         i32,
	Count:      i32,
	Modifiers:  uiModifiers,
	Held1To64:  u64,
}

uiExtKeyInsert :: 2
uiExtKeyDelete :: 3
uiExtKeyHome   :: 4

uiExtKey :: u32

uiExtKeyPageUp    :: 6
uiExtKeyPageDown  :: 7
uiExtKeyUp        :: 8
uiExtKeyDown      :: 9
uiExtKeyLeft      :: 10
uiExtKeyEscape    :: 1
uiExtKeyF1        :: 12
uiExtKeyF2        :: 13
uiExtKeyF3        :: 14
uiExtKeyF4        :: 15
uiExtKeyF5        :: 16
uiExtKeyF6        :: 17
uiExtKeyF7        :: 18
uiExtKeyF8        :: 19
uiExtKeyF9        :: 20
uiExtKeyEnd       :: 5
uiExtKeyF11       :: 22
uiExtKeyF12       :: 23
uiExtKeyN0        :: 24
uiExtKeyN1        :: 25
uiExtKeyN2        :: 26
uiExtKeyN3        :: 27
uiExtKeyN4        :: 28
uiExtKeyN5        :: 29
uiExtKeyN6        :: 30
uiExtKeyN7        :: 31
uiExtKeyN8        :: 32
uiExtKeyN9        :: 33
uiExtKeyNDot      :: 34
uiExtKeyNEnter    :: 35
uiExtKeyNAdd      :: 36
uiExtKeyRight     :: 11
uiExtKeyF10       :: 21
uiExtKeyNSubtract :: 37
uiExtKeyNDivide   :: 39
uiExtKeyNMultiply :: 38

uiAreaKeyEvent :: struct {
	Key:       i8,
	ExtKey:    uiExtKey,
	Modifier:  uiModifiers,
	Modifiers: uiModifiers,
	Up:        i32,
}

uiColorButton :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiColorButtonColor     :: proc(b: ^uiColorButton, r: ^f64, g: ^f64, bl: ^f64, a: ^f64) ---
	uiColorButtonSetColor  :: proc(b: ^uiColorButton, r: f64, g: f64, bl: f64, a: f64) ---
	uiColorButtonOnChanged :: proc(b: ^uiColorButton, f: proc "c" (^uiColorButton, rawptr), data: rawptr) ---
	uiNewColorButton       :: proc() -> ^uiColorButton ---
}

uiForm :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiFormAppend    :: proc(f: ^uiForm, label: cstring, _c: ^uiControl, stretchy: i32) ---
	uiFormDelete    :: proc(f: ^uiForm, index: i32) ---
	uiFormPadded    :: proc(f: ^uiForm) -> i32 ---
	uiFormSetPadded :: proc(f: ^uiForm, padded: i32) ---
	uiNewForm       :: proc() -> ^uiForm ---
}

uiAlignStart :: 1

uiAlign :: u32

uiAlignFill   :: 0
uiAlignCenter :: 2
uiAlignEnd    :: 3

uiAt :: u32

uiAtLeading  :: 0
uiAtTop      :: 1
uiAtTrailing :: 2
uiAtBottom   :: 3

uiGrid :: struct {}

@(default_calling_convention="c")
foreign lib {
	uiGridAppend    :: proc(g: ^uiGrid, _c: ^uiControl, left: i32, top: i32, xspan: i32, yspan: i32, hexpand: i32, halign: uiAlign, vexpand: i32, valign: uiAlign) ---
	uiGridInsertAt  :: proc(g: ^uiGrid, _c: ^uiControl, existing: ^uiControl, at: uiAt, xspan: i32, yspan: i32, hexpand: i32, halign: uiAlign, vexpand: i32, valign: uiAlign) ---
	uiGridPadded    :: proc(g: ^uiGrid) -> i32 ---
	uiGridSetPadded :: proc(g: ^uiGrid, padded: i32) ---
	uiNewGrid       :: proc() -> ^uiGrid ---
}

uiImage :: struct {}

@(default_calling_convention="c")
foreign lib {
	// @role uiImage constructor
	// uiNewImage creates a new uiImage with the given width and
	// height. This width and height should be the size in points of the
	// image in the device-independent case; typically this is the 1x size.
	// TODO for all uiImage functions: use const void * for const correctness
	uiNewImage :: proc(width: f64, height: f64) -> ^uiImage ---

	// @role uiImage destructor
	// uiFreeImage frees the given image and all associated resources.
	uiFreeImage :: proc(i: ^uiImage) ---

	// uiImageAppend adds a representation to the uiImage.
	// pixels should point to a byte array of premultiplied pixels
	// stored in [R G B A] order (so ((uint8_t *) pixels)[0] is the R of the
	// first pixel and [3] is the A of the first pixel). pixelWidth and
	// pixelHeight is the size *in pixels* of the image, and pixelStride is
	// the number *of bytes* per row of the pixels array. Therefore,
	// pixels itself must be at least byteStride * pixelHeight bytes long.
	// TODO see if we either need the stride or can provide a way to get the OS-preferred stride (in cairo we do)
	uiImageAppend :: proc(i: ^uiImage, pixels: rawptr, pixelWidth: i32, pixelHeight: i32, byteStride: i32) ---
}

uiTableValue :: struct {}

@(default_calling_convention="c")
foreign lib {
	// @role uiTableValue destructor
	// uiFreeTableValue() frees a uiTableValue. You generally do not
	// need to call this yourself, as uiTable and uiTableModel do this
	// for you. In fact, it is an error to call this function on a uiTableValue
	// that has been given to a uiTable or uiTableModel. You can call this,
	// however, if you created a uiTableValue that you aren't going to
	// use later, or if you called a uiTableModelHandler method directly
	// and thus never transferred ownership of the uiTableValue.
	uiFreeTableValue :: proc(v: ^uiTableValue) ---
}

// uiTableValueType holds the possible uiTableValue types that may
// be returned by uiTableValueGetType(). Refer to the documentation
// for each type's constructor function for details on each type.
// TODO actually validate these
uiTableValueType :: u32

uiTableValueTypeString :: 0
uiTableValueTypeInt    :: 2
uiTableValueTypeImage  :: 1
uiTableValueTypeColor  :: 3

@(default_calling_convention="c")
foreign lib {
	// uiTableValueGetType() returns the type of v.
	// TODO I don't like this name
	uiTableValueGetType :: proc(v: ^uiTableValue) -> uiTableValueType ---

	// uiNewTableValueString() returns a new uiTableValue that contains
	// str. str is copied; you do not need to keep it alive after
	// uiNewTableValueString() returns.
	uiNewTableValueString :: proc(str: cstring) -> ^uiTableValue ---

	// uiTableValueString() returns the string stored in v. The returned
	// string is owned by v. It is an error to call this on a uiTableValue
	// that does not hold a string.
	uiTableValueString :: proc(v: ^uiTableValue) -> cstring ---

	// uiNewTableValueImage() returns a new uiTableValue that contains
	// the given uiImage.
	//
	// Unlike other similar constructors, uiNewTableValueImage() does
	// NOT copy the image. This is because images are comparatively
	// larger than the other objects in question. Therefore, you MUST
	// keep the image alive as long as the returned uiTableValue is alive.
	// As a general rule, if libui calls a uiTableModelHandler method, the
	// uiImage is safe to free once any of your code is once again
	// executed.
	uiNewTableValueImage :: proc(img: ^uiImage) -> ^uiTableValue ---

	// uiTableValueImage() returns the uiImage stored in v. As these
	// images are not owned by v, you should not assume anything
	// about the lifetime of the image (unless you created the image,
	// and thus control its lifetime). It is an error to call this on a
	// uiTableValue that does not hold an image.
	uiTableValueImage :: proc(v: ^uiTableValue) -> ^uiImage ---

	// uiNewTableValueInt() returns a uiTableValue that stores the given
	// int. This can be used both for boolean values (nonzero is true, as
	// in C) or progresses (in which case the valid range is -1..100
	// inclusive).
	uiNewTableValueInt :: proc(i: i32) -> ^uiTableValue ---

	// uiTableValueInt() returns the int stored in v. It is an error to call
	// this on a uiTableValue that does not store an int.
	uiTableValueInt :: proc(v: ^uiTableValue) -> i32 ---

	// uiNewTableValueColor() returns a uiTableValue that stores the
	// given color.
	uiNewTableValueColor :: proc(r: f64, g: f64, b: f64, a: f64) -> ^uiTableValue ---

	// uiTableValueColor() returns the color stored in v. It is an error to
	// call this on a uiTableValue that does not store a color.
	// TODO define whether all this, for both uiTableValue and uiAttribute, is undefined behavior or a caught error
	uiTableValueColor :: proc(v: ^uiTableValue, r: ^f64, g: ^f64, b: ^f64, a: ^f64) ---
}

uiTableModel :: struct {}

// TODO validate ranges; validate types on each getter/setter call (? table columns only?)
uiTableModelHandler :: struct {
	// NumColumns returns the number of model columns in the
	// uiTableModel. This value must remain constant through the
	// lifetime of the uiTableModel. This method is not guaranteed
	// to be called depending on the system.
	// TODO strongly check column numbers and types on all platforms so these clauses can go away
	NumColumns: proc "c" (^uiTableModelHandler, ^uiTableModel) -> i32,

	// ColumnType returns the value type of the data stored in
	// the given model column of the uiTableModel. The returned
	// values must remain constant through the lifetime of the
	// uiTableModel. This method is not guaranteed to be called
	// depending on the system.
	ColumnType: proc "c" (^uiTableModelHandler, ^uiTableModel, i32) -> uiTableValueType,

	// NumRows returns the number or rows in the uiTableModel.
	// This value must be non-negative.
	NumRows: proc "c" (^uiTableModelHandler, ^uiTableModel) -> i32,

	// CellValue returns a uiTableValue corresponding to the model
	// cell at (row, column). The type of the returned uiTableValue
	// must match column's value type. Under some circumstances,
	// NULL may be returned; refer to the various methods that add
	// columns to uiTable for details. Once returned, the uiTable
	// that calls CellValue will free the uiTableValue returned.
	CellValue: proc "c" (mh: ^uiTableModelHandler, m: ^uiTableModel, row: i32, column: i32) -> ^uiTableValue,

	// SetCellValue changes the model cell value at (row, column)
	// in the uiTableModel. Within this function, either do nothing
	// to keep the current cell value or save the new cell value as
	// appropriate. After SetCellValue is called, the uiTable will
	// itself reload the table cell. Under certain conditions, the
	// uiTableValue passed in can be NULL; refer to the various
	// methods that add columns to uiTable for details. Once
	// returned, the uiTable that called SetCellValue will free the
	// uiTableValue passed in.
	SetCellValue: proc "c" (^uiTableModelHandler, ^uiTableModel, i32, i32, ^uiTableValue),
}

@(default_calling_convention="c")
foreign lib {
	// @role uiTableModel constructor
	// uiNewTableModel() creates a new uiTableModel with the given
	// handler methods.
	uiNewTableModel :: proc(mh: ^uiTableModelHandler) -> ^uiTableModel ---

	// @role uiTableModel destructor
	// uiFreeTableModel() frees the given table model. It is an error to
	// free table models currently associated with a uiTable.
	uiFreeTableModel :: proc(m: ^uiTableModel) ---

	// uiTableModelRowInserted() tells any uiTable associated with m
	// that a new row has been added to m at index index. You call
	// this function when the number of rows in your model has
	// changed; after calling it, NumRows() should returm the new row
	// count.
	uiTableModelRowInserted :: proc(m: ^uiTableModel, newIndex: i32) ---

	// uiTableModelRowChanged() tells any uiTable associated with m
	// that the data in the row at index has changed. You do not need to
	// call this in your SetCellValue() handlers, but you do need to call
	// this if your data changes at some other point.
	uiTableModelRowChanged :: proc(m: ^uiTableModel, index: i32) ---

	// uiTableModelRowDeleted() tells any uiTable associated with m
	// that the row at index index has been deleted. You call this
	// function when the number of rows in your model has changed;
	// after calling it, NumRows() should returm the new row
	// count.
	// TODO for this and Inserted: make sure the "after" part is right; clarify if it's after returning or after calling
	uiTableModelRowDeleted :: proc(m: ^uiTableModel, oldIndex: i32) ---
}

// TODO reordering/moving

// uiTableModelColumnNeverEditable and
// uiTableModelColumnAlwaysEditable are the value of an editable
// model column parameter to one of the uiTable create column
// functions; if used, that jparticular uiTable colum is not editable
// by the user and always editable by the user, respectively.
uiTableModelColumnNeverEditable  :: (-1)
uiTableModelColumnAlwaysEditable :: (-2)

uiTableTextColumnOptionalParams :: struct {
	// ColorModelColumn is the model column containing the
	// text color of this uiTable column's text, or -1 to use the
	// default color.
	//
	// If CellValue() for this column for any cell returns NULL, that
	// cell will also use the default text color.
	ColorModelColumn: i32,
}

uiTableParams :: struct {
	// Model is the uiTableModel to use for this uiTable.
	// This parameter cannot be NULL.
	Model: ^uiTableModel,

	// RowBackgroundColorModelColumn is a model column
	// number that defines the background color used for the
	// entire row in the uiTable, or -1 to use the default color for
	// all rows.
	//
	// If CellValue() for this column for any row returns NULL, that
	// row will also use the default background color.
	RowBackgroundColorModelColumn: i32,
}

uiTable :: struct {}

@(default_calling_convention="c")
foreign lib {
	// uiTableAppendTextColumn() appends a text column to t.
	// name is displayed in the table header.
	// textModelColumn is where the text comes from.
	// If a row is editable according to textEditableModelColumn,
	// SetCellValue() is called with textModelColumn as the column.
	uiTableAppendTextColumn :: proc(t: ^uiTable, name: cstring, textModelColumn: i32, textEditableModelColumn: i32, textParams: ^uiTableTextColumnOptionalParams) ---

	// uiTableAppendImageColumn() appends an image column to t.
	// Images are drawn at icon size, appropriate to the pixel density
	// of the screen showing the uiTable.
	uiTableAppendImageColumn :: proc(t: ^uiTable, name: cstring, imageModelColumn: i32) ---

	// uiTableAppendImageTextColumn() appends a column to t that
	// shows both an image and text.
	uiTableAppendImageTextColumn :: proc(t: ^uiTable, name: cstring, imageModelColumn: i32, textModelColumn: i32, textEditableModelColumn: i32, textParams: ^uiTableTextColumnOptionalParams) ---

	// uiTableAppendCheckboxColumn appends a column to t that
	// contains a checkbox that the user can interact with (assuming the
	// checkbox is editable). SetCellValue() will be called with
	// checkboxModelColumn as the column in this case.
	uiTableAppendCheckboxColumn :: proc(t: ^uiTable, name: cstring, checkboxModelColumn: i32, checkboxEditableModelColumn: i32) ---

	// uiTableAppendCheckboxTextColumn() appends a column to t
	// that contains both a checkbox and text.
	uiTableAppendCheckboxTextColumn :: proc(t: ^uiTable, name: cstring, checkboxModelColumn: i32, checkboxEditableModelColumn: i32, textModelColumn: i32, textEditableModelColumn: i32, textParams: ^uiTableTextColumnOptionalParams) ---

	// uiTableAppendProgressBarColumn() appends a column to t
	// that displays a progress bar. These columns work like
	// uiProgressBar: a cell value of 0..100 displays that percentage, and
	// a cell value of -1 displays an indeterminate progress bar.
	uiTableAppendProgressBarColumn :: proc(t: ^uiTable, name: cstring, progressModelColumn: i32) ---

	// uiTableAppendButtonColumn() appends a column to t
	// that shows a button that the user can click on. When the user
	// does click on the button, SetCellValue() is called with a NULL
	// value and buttonModelColumn as the column.
	// CellValue() on buttonModelColumn should return the text to show
	// in the button.
	uiTableAppendButtonColumn :: proc(t: ^uiTable, name: cstring, buttonModelColumn: i32, buttonClickableModelColumn: i32) ---

	// uiNewTable() creates a new uiTable with the specified parameters.
	uiNewTable :: proc(params: ^uiTableParams) -> ^uiTable ---
}

