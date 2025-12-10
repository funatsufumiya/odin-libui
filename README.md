# odin-libui

Odin language [libui-ng](https://github.com/libui-ng/libui-ng) wrapper. Tested on Win/Mac/Linux (Ubuntu).

![screenshots/basic_controls.png](screenshots/basic_controls.png)

Forked from [v-libui](https://github.com/funatsufumiya/v-libui) (which based on [libui_examples](https://github.com/funatsufumiya/libui_examples))

Dynamic libraries are already placed in this repo. These were prebuilt from [libui-ng/libui-ng](https://github.com/libui-ng/libui-ng).  (So if you need other architecture/platform versions, please build and replace it by yourself.)

## Examples (how to build and run)

- [minimal](./examples/minimal/main.odin)
- [timer](./examples/timer/main.odin)
- [calendar](./examples/calendar/main.odin)
- [graph](./examples/graph/main.odin)
- [label](./examples/label/main.odin)
- [widgets](./examples/widgets/main.odin)

### Windows

```bash
.\build.ps1

# then run each .exe in bin folder
```

### Mac

```bash
$ ./build.sh

# run executables, for example:
$ DYLD_LIBRARY_PATH=bin bin/graph
```

### Linux

```bash
$ ./build.sh

# run executables, for example:
$ LD_LIBRARY_PATH=bin bin/graph
```

-------

Original README ([libui_examples](https://github.com/funatsufumiya/libui_examples))

--------

# libui examples
Small [libui examples](https://github.com/andlabs/libui/tree/master/examples) that can be compile with [tiny c compile](https://bellard.org/tcc/)
Examples are automatically compiled and exposed at [actions](https://github.com/graysuit/libui_examples/actions/runs/1077977361) tab.

![screenshots/basic_controls.png](screenshots/basic_controls.png)

## Build and Run

### Windows

```bash
.\build.bat

# then run each .exe in bin folder
```

### Mac

```bash
$ ./build.sh

# run executables, for example:
$ DYLD_LIBRARY_PATH=bin bin/graph
```

### Linux

```bash
$ ./build.sh

# run executables, for example:
$ LD_LIBRARY_PATH=bin bin/graph
```

## Screenshots

![screenshots/basic_controls.png](screenshots/basic_controls.png)
![screenshots/calender.png](screenshots/calender.png)
![screenshots/data_choosers.png](screenshots/data_choosers.png)
![screenshots/graph.png](screenshots/graph.png)
![screenshots/label.png](screenshots/label.png)
![screenshots/numbers_and_lists.png](screenshots/numbers_and_lists.png)
![screenshots/timer.png](screenshots/timer.png)
