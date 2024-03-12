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

    Label@ label = StandardLabel();
    label.SetText("This pane is centered on the screen and stretches horizontally!");
    label.SetColor(color_white);

    Pane@ pane = StandardPane();
    pane.SetMargin(200, 0);
    pane.SetPadding(20, 20);
    pane.SetAlignment(0.5f, 0.5f);
    pane.SetStretchRatio(1.0f, 0.0f);
    pane.SetMaxSize(600, 0);
    pane.AddComponent(label);

    ui.AddComponent(pane);
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
