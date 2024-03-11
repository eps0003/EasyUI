# EasyUI

The only [King Arthur's Gold](https://kag2d.com/) UI mod you'll ever need. Build responsive user interfaces with ease using modular components.

## Features

- **Modular**: Components can be combined in various ways to build any layout you desire.
- **Familiar**: The standard UI components provided out of the box match KAG's iconic style.
- **Responsive**: Components can be dynamically resized and everything will adjust accordingly.
- **Extensible**: Components can easily be inherited to alter the look or behaviour to fit your needs.
- **Optimised**: Components recalculate their bounds only when necessary so complex UIs run fast.
- **Effortless**: Seamlessly integrate a fully-featured UI experience into any mod with a single #include.

## Usage

1. Put the EasyUI folder in your `Mods` folder.
2. Add `EasyUI` to a new line in `mods.cfg` above any mod that will use it.
3. Build, update, and render your UI in a new or existing client-only script.

## Example

```angelscript
#include "EasyUI.as"
#define CLIENT_ONLY

EasyUI@ ui;

void onInit(CRules@ this)
{
    onRestart(this);
}

void onRestart(CRules@ this)
{
    @ui = EasyUI();

    // Displays a single-line label
    Label@ label = StandardLabel();
    label.SetText("This pane is centered on the screen and stretches horizontally!");
    label.SetColor(color_white);

    // Stretches to fill the width of the canvas
    Pane@ pane = StandardPane();
    pane.SetPadding(20, 20);
    pane.SetStretchRatio(1.0f, 0.0f);
    pane.AddComponent(label);

    // Covers the entire screen so the pane can be center-aligned
    Stack@ canvas = StandardStack();
    canvas.SetStretchRatio(1.0f, 1.0f);
    canvas.SetAlignment(0.5f, 0.5f);
    canvas.SetMargin(200, 200);
    canvas.AddComponent(pane);

    ui.AddComponent(canvas);
}

void onTick(CRules@ this)
{
    ui.Update();
}

void onRender(CRules@ this)
{
    ui.Render();
    // ui.Debug(getControls().isKeyPressed(KEY_LSHIFT));
}
```
