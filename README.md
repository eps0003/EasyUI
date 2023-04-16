# EasyUI

The only [King Arthur's Gold](https://kag2d.com/) UI mod you'll ever need. Build responsive user interfaces with ease using modular components.

## Features

- **Modular**: Components can be combined in various ways to build any layout you desire.
- **Familiar**: The standard UI components provided out of the box match KAG's iconic style.
- **Responsive**: Components can be dynamically resized and containers will adjust accordingly.
- **Extensible**: Components can easily be inherited to alter the look or behaviour to fit your needs.
- **Effortless**: Seamlessly integrate a fully-featured UI experience into any mod with a single #include.

## Example

```angelscript
#include "EasyUI.as"
#define CLIENT_ONLY

EasyUI ui;

void onInit(CRules@ this)
{
    // TODO
}

void onTick(CRules@ this)
{
    ui.Update();
}

void onRender(CRules@ this)
{
    ui.Render();
}
```

## Usage

1. Put the EasyUI folder in your `Mods` folder.
2. Add `EasyUI` to a new line in `mods.cfg` above any mod that will use it.
3. Build, update, and render your UI in a new or existing client-only script.

## Components

| Category       | Components                                                                  |
| -------------- | --------------------------------------------------------------------------- |
| Input Controls | [Button](#button) • [Slider](#slider) • [Toggle](#toggle)                   |
| Informational  | [Avatar](#avatar) • [Icon](#icon) • [Label](#label) • [Progress](#progress) |
| Containers     | [List](#list) • [Pane](#pane) • [Stack](#stack)                             |

### Avatar

### Button

### Icon

### Label

### List

### Pane

### Progress

### Slider

### Stack

### Toggle
