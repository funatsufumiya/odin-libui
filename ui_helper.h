#pragma once

#include "ui.h"

uiControl* asUiControl(void* ptr){
    return (uiControl*) ptr;
}

// uiControl* winAsUiControl(uiWindow* ptr){
//     return (uiControl*) ptr;
// }