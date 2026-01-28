# EasyUI

The only [King Arthur's Gold](https://kag2d.com/) UI mod you'll ever need. Build responsive user interfaces with ease using modular components.

## Table of Contents

- [Features](#features)
- [Usage](#usage)
- [Example](#example)
- [Fundamentals](#fundamentals)
- [Diagrams](#diagrams)
- [Components](#components)
- [Interfaces](#interfaces)

## Features

- **Modular**: Components can be combined in various ways to build any layout you desire.
- **Familiar**: The standard UI components provided out of the box match KAG's iconic style.
- **Responsive**: Components can be dynamically resized and everything will adjust accordingly.
- **Extensible**: Components can easily be inherited to alter the look or behaviour to fit your needs.
- **Optimised**: Components recalculate their bounds only when necessary so complex UIs run fast.
- **Effortless**: Seamlessly integrate a fully-featured UI experience into any mod with a single #include.

## Usage

1. Download and unzip `EasyUI.zip` from the [latest release](https://github.com/eps0003/EasyUI/releases/latest).
2. Put the contained `EasyUI` folder in your `Mods` folder.
3. Add `EasyUI` to a new line in `mods.cfg` above any mod that will use it.
4. Build, update, and render your UI in a new or existing client-only script.

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

## Fundamentals

- Components are positioned relative to their parent or the screen if they are a root component. Therefore, it is not possible to set the (x, y) position of a component.
- Components can never exceed or extend beyond their parent's bounds. The parent will always grow to fit its children.
- Components stretch to fill their parent. The stretched bounds will never cause the parent's bounds to grow.
- All input components require the `EasyUI` instance to be passed into the constructor. This is so the components can query the component tree to determine if they can be interacted with.
- It is recommended that the [model-view-controller](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) design pattern be used for developing dynamic UIs. Use the game and player state (controller) to manipulate the data (model) that is displayed in the UI (view). The various `Set...()` methods should be used to update the UI with the data from the model rather than directly from game and player state.

## Diagrams

<details>
  <summary>Position and bounds</summary>

```
                                    minimum bounds
                                ┌──────────┴──────────┐
                position ──────>┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
                true position ──|─>┏━━━━━━━━━━━━━━━┓  |<────── bounds
                inner position ─|──┃─>┌ ─ ─ ─ ─ ┐  ┃<─|── true bounds
                                |  ┃  | epsilon |<─┃──|─ inner bounds
                                |  ┃  └ ─ ─ ─ ─ ┘  ┃  |
                                |  ┗━━━━━━━━━━━━━━━┛  |
                                └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
                                └┬─┘            └─┬┘
                               margin          padding
```

</details>

<details>
  <summary>Composition and stretch</summary>

Note: This diagram depicts stretching for stack-based components; stretching in list-based components behaves slightly differently. Children don't stretch to the list's inner bounds; they instead stretch to fill the cell they occupy which is a division of the list's inner bounds.

```
                        ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
parent minimum bounds ─>|  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  |
                        |  ┃  ┏━━━━━━━━━━━━━━━━━━━━━━━━━┓  ┃  |
parent true bounds ─────|─>┃  ┃                         ┃  ┃  |
                        |  ┃  ┃                         ┃<─┃──|───────── child bounds
parent inner bounds ────|──┃─>┃       ┌ ─ ─ ─ ─ ┐       ┃  ┃  |
                        |  ┃  ┃       |         |<──────┃──┃──|─ child minimum bounds
                        |  ┃  ┃       └ ─ ─ ─ ─ ┘       ┃  ┃  |
                        |  ┃  ┃                         ┃  ┃  |
                        |  ┃  ┃                         ┃  ┃  |
                        |  ┃  ┗━━━━━━━━━━━━━━━━━━━━━━━━━┛  ┃  |
                        |  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  |
                        └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
                           └┬─┘                 └┬──────┘  └─┬┘
                    parent padding    child 100% stretch    parent margin
```

</details>

## Components

| Category      | Components                                                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Input         | [StandardButton](#button) • [StandardVerticalSlider](#slider) • [StandardHorizontalSlider](#slider) • [StandardToggle](#toggle) |
| Informational | [StandardAvatar](#avatar) • [StandardIcon](#icon) • [StandardLabel](#label) • [StandardHorizontalProgress](#progress)           |
| Container     | [StandardList](#list) • [StandardPane](#pane) • [StandardStack](#stack)                                                         |

Planned: Dropdown, Minimap, Radio Button, Tile, Vertical Progress

## Interfaces

> [!IMPORTANT]  
> Only methods that should be used by modders are documented here. Other methods exposed on each interface are required for the UI system to work and should never be used.

### Component

The base interface implemented by all components.

Implemented by: [Avatar](#avatar), [Button](#button), [Icon](#icon), [Label](#label), [List](#list), [Pane](#pane), [Progress](#progress), [Slider](#slider), [Stack](#stack), [Toggle](#toggle)  
Source code: [Component.as](/EasyUI/Component.as)

#### Margin

Add margin outside the visible bounds of the component.

Minimum: `0.0f, 0.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetMargin(float x, float y);
Vec2f getMargin();
```

#### Padding

Add padding inside the visible bounds of the component.

Minimum: `0.0f, 0.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetPadding(float x, float y);
Vec2f getMargin();
```

#### Alignment

Align the component relative to its parent. The component is aligned relative to the screen if it is at the root.

Range: `0.0f, 0.0f` – `1.0f, 1.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetAlignment(float x, float y);
Vec2f getAlignment();
```

Examples:

- `0.0f, 0.0f` means the component will align its top left corner to the top left corner of its parent.
- `0.5f, 0.5f` means the component will be aligned to the middle of its parent.
- `1.0f, 1.0f` means the component will align its bottom right corner to the bottom right corner of its parent.

#### Stretch ratio

Stretch the component to fill its parent. The component stretches to fill the screen if it is at the root.

Range: `0.0f, 0.0f` – `1.0f, 1.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetStretchRatio(float x, float y);
Vec2f getStretchRatio();
```

Examples:

- `0.0f` on the x-axis means the component will stretch to 0% of its parent's width which the minimum size will always exceed.
- `0.5f` on the x-axis means the component will stretch to 50% of its parent's width unless the minimum size exceeds this.
- `1.0f` on the x-axis means the component will stretch to 100% of its parent's width.

#### Minimum size

Require the component to have a minimum size. The minimum size ignores margin.

Minimum: `0.0f, 0.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetMinSize(float width, float height);
Vec2f getMinSize();
```

#### Max size

Restrict the component to a maximum size if it stretches, unless its children exceed this size. The maximum size ignores margin.

Minimum: `0.0f, 0.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetMaxSize(float width, float height);
Vec2f getMaxSize();
```

#### Visibility

The visibility of the component. If the component is hidden, all its children are hidden.

Default: `true`

```angelscript
void SetVisible(bool visible);
bool isVisible();
```

#### Composition

Add children to the component. Children can never exceed the bounds of the component.

```angelscript
void AddComponent(Component@ component);
void SetComponents(Component@[] components);
Component@[] getComponents();
```

#### Position

Get the various positions of the component. Components are always positioned relative to its parent or screen and cannot be positioned manually.

```angelscript
// The position before margin or padding are applied
Vec2f getPosition();
// The true position after margin is applied
Vec2f getTruePosition();
// The inner position after margin and padding are applied
Vec2f getInnerPosition();
```

#### Bounds

Get the various bounds of the component.

```angelscript
// The minimum bounds the component can be
// Takes into account margin, padding, and the minimum bounds of child components
Vec2f getMinBounds();
// The stretched bounds with margin and padding applied
Vec2f getBounds();
// The stretched bounds with only padding applied
Vec2f getTrueBounds();
// The stretched bounds before margin and padding are applied
Vec2f getInnerBounds();
```

#### Mouse

Check various mouse-related attributes of the component.

```angelscript
// Is the mouse within the component's bounds
bool isHovering();
// Can the component be clicked if it is hovered and unobstructed
bool canClick();
// Can the component be scrolled down if it is hovered and unobstructed
bool canScrollDown();
// Can the component be scrolled up if it is hovered and unobstructed
bool canScrollUp();
```

### Stack

A component that stacks its children on top of each other.

Implements: [Component](#component)  
Implemented by: [Avatar](#avatar), [Icon](#icon), [Label](#label)  
Source code: [Stack.as](/EasyUI/Components/Stack.as)

No stack-specific methods.

### List

A component that lists its children one after the other.

Implements: [Component](#component)  
Implemented by: [Button](#button), [List](#list), [Pane](#pane), [Progress](#progress), [Slider](#slider), [Stack](#stack), [Toggle](#toggle)  
Source code: [List.as](/EasyUI/Components/List.as)

#### Spacing

The spacing between the component's children.

Minimum: `0.0f, 0.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetSpacing(float x, float y);
Vec2f getSpacing();
```

#### Cell wrap

The number of children that can be listed on the same row/column before they wrap.

Minimum: `1`  
Default: `1`

```angelscript
void SetCellWrap(uint cells);
uint getCellWrap();
```

#### Flow direction

The direction children flow and wrap.

Default: `FlowDirection::RightDown`

```angelscript
void SetFlowDirection(FlowDirection direction);
FlowDirection getFlowDirection();
```

Valid values:

- Top left: `FlowDirection::RightDown` / `FlowDirection::DownRight`
- Top right: `FlowDirection::LeftDown` / `FlowDirection::DownLeft`
- Bottom right: `FlowDirection::RightUp` / `FlowDirection::UpRight`
- Bottom left: `FlowDirection::LeftUp` / `FlowDirection::UpLeft`

Examples:

- `FlowDirection::RightDown` means children are listed from left to right and wrap down onto new rows.
- `FlowDirection::DownRight` means children are listed from top to bottom and wrap right onto new columns.

#### Max lines

The maximum number of lines before the list requires scrolling to view all children.

Default: `0` (no maximum)

```angelscript
void SetMaxLines(uint lines);
uint getMaxLines();
```

#### Scroll index

The number of lines to scroll.

Default: `0`

```angelscript
void SetScrollIndex(uint index);
uint getScrollIndex();
```

#### Column sizes

The relative size of each column for when children stretch.

Default: `{}` (equally sized columns)

```angelscript
void SetColumnSizes(float[] sizes);
float[] getColumnSizes();
```

Implementation notes:

- If the array of sizes is too short compared to the number of columns, the remaining columns will assume a value of `0` (minimum stretch). For example, `{ 2, 1 }` and `{ 2, 1, 0 }` are identical when there are only two columns.
- If the array of sizes is too long compared to the number of columns, the extra values are ignored. For example, `{ 1, 2, 3 }` and `{ 1, 2 }` are identical when there are only two columns.
- If the array of sizes is empty or contains only zeros, each column will be equally sized. For example, `{}`, `{ 0, 0 }`, and `{ 1, 1 }` are identical when there are two columns.

Examples:

- `{ 2, 3 }` means the first column will stretch two-fifths of the component's inner width and the second column will stretch three-fifths.
- `{ 0, 1 }` means the first column will have minimum stretch and the second column will stretch to fill the component's remaining inner width.

#### Row sizes

The relative size of each row for when children stretch.

Default: `{}` (equally sized rows)

```angelscript
void SetColumnSizes(float[] sizes);
float[] getColumnSizes();
```

The implementation notes and examples mentioned for [column sizes](#column-sizes) applies to row sizes as well.

### Avatar

A component that displays a player's avatar from the [Transhuman Design Forum](https://forum.thd.vg/).

Implements: [Stack](#stack)  
Source code: [Avatar.as](/EasyUI/Components/Avatar.as)

Implementation notes:

- If a player isn't configured, doesn't have a forum account, or doesn't have profile picture set, a black image will be displayed.
- The avatar can only be drawn with a 1:1 aspect ratio, so black bars will be present if the component has a non-square size.

### Player

The player whose avatar should be displayed.

Default: `null`

```angelscript
void SetPlayer(CPlayer@ player);
CPlayer@ getPlayer();
```

### Button

A button that can be hovered and pressed. A sound is played when it is clicked.

Implements: [List](#list)  
Source code: [Button.as](/EasyUI/Components/Button.as)

#### Pressed

Check whether the button is being pressed.

```angelscript
bool isPressed();
```

### Icon

A component that displays an icon.

Implements: [Stack](#stack)  
Source code: [Icon.as](/EasyUI/Components/Icon.as)

#### Texture

The texture that contains the icon.

Default: `""`

```angelscript
void SetTexture(string texture);
string getTexture();
```

#### Frame index

Set the index of the icon frame in the texture.

Minimum: `0`  
Default: `0`

```angelscript
void SetFrameIndex(uint index);
uint getFrameIndex();
```

#### Frame dimensions

The dimensions of the icon frame in the texture.

Minimum: `0.0f`  
Default: `0.0f, 0.0f`

```angelscript
void SetFrameDim(uint width, uint height);
Vec2f getFrameDim();
```

#### Team

The team number of the icon.

Default: `0`

```angelscript
void SetTeam(uint team);
uint getTeam();
```

#### Color

The color of the icon.

Default: `white`

```angelscript
void SetColor(SColor color);
SColor getColor();
```

#### Crop

The icon can be cropped if it is too small compared to its frame dimensions.

Default: `0.0f, 0.0f, 0.0f, 0.0f`

```angelscript
void SetCrop(float top, float right, float bottom, float left);
```

#### Fixed aspect ratio

Whether the icon should maintain its aspect ratio regardless of the size of the component.

Default: `true`

```angelscript
void SetFixedAspectRatio(bool fixed);
bool isFixedAspectRatio();
```

#### Clickable

Whether the icon is clickable to allow for icon buttons.

Default: `false`

```angelscript
void SetClickable(bool clickable);
```

### Label

A component that displays text.

Implements: [Stack](#stack)  
Source code: [Label.as](/EasyUI/Components/Label.as)

#### Text

The text to display.

Default: `""`

```angelscript
void SetText(string text);
string getText();
```

#### Font

The font to display the text as.

Default: `"menu"` (default KAG font)

```angelscript
void SetFont(string font);
string getFont();
```

#### Color

The color of the text.

Default: white

```angelscript
void SetColor(SColor color);
SColor getColor();
```

#### Wrap

Whether the text can wrap. Wrapped text must have a minimum width configured.

Default: `false`

```angelscript
void SetWrap(bool wrap);
bool getWrap();
```

#### Max lines

The maximum number of lines before the text is truncated with ellipsis (...). This only comes into effect if the text can wrap.

Default: `1` (truncate on the first line)

```angelscript
void SetMaxLines(uint lines);
uint getMaxLines();
```

### Pane

A component that displays a rectangular pane.

Implements: [List](#list)

No pane-specific methods.

### Progress

A component that displays a progress bar.

Implements: [List](#list)  
Source code: [Progress.as](/EasyUI/Components/Progress.as)

#### Percentage

The progress percentage.

Range: `0.0f` – `1.0f`  
Default: `0.0f`

```angelscript
void SetPercentage(float percentage);
float getPercentage();
```

### Slider

A component that displays a slider whose handle can be dragged.

Implements: [List](#list)  
Source code: [Slider.as](/EasyUI/Components/Slider.as)

#### Percentage

The percentage of the handle.

Range: `0.0f` – `1.0f`  
Default: `0.0f`

```angelscript
void SetPercentage(float percentage);
float getPercentage();
```

### Toggle

A button that toggles when clicked.

Implements: [Button](#button)  
Source code: [ToggleButton.as](/EasyUI/Components/ToggleButton.as)

#### Checked

Whether the button is toggled.

Default: `false`

```angelscript
void SetChecked(bool checked);
bool isChecked();
```

