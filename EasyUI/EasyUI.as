#include "Avatar.as"
#include "Button.as"
#include "CachedBounds.as"
#include "Component.as"
#include "Container.as"
#include "Draggable.as"
#include "DragHandle.as"
#include "EventDispatcher.as"
#include "Icon.as"
#include "Label.as"
#include "List.as"
#include "Pane.as"
#include "Progress.as"
#include "Slider.as"
#include "Stack.as"
#include "ToggleButton.as"
#include "Utilities.as"

class EasyUI
{
    private Component@[] components;

    private Component@ hovering;
    private Component@ clickable;
    private Component@ scrollable;
    private Component@ interacting;

    private CControls@ controls;

    EasyUI()
    {
        if (!isClient()) return;

        @controls = getControls();
    }

    void AddComponent(Component@ component)
    {
        if (component is null || !isClient()) return;

        components.push_back(component);
    }

    void RemoveComponent(Component@ component)
    {
        if (component is null || !isClient()) return;

        for (int i = components.size() - 1; i >= 0; i--)
        {
            Component@ other = components[i];
            if (other !is component) continue;

            components.removeAt(i);

            break;
        }
    }

    void SetComponents(Component@[] components)
    {
        if (!isClient()) return;

        this.components = components;
    }

    bool isHovering()
    {
        return hovering !is null;
    }

    bool isInteracting()
    {
        return interacting !is null;
    }

    bool hasControl()
    {
        return isHovering() || isInteracting();
    }

    bool canClick(Component@ component)
    {
        return component !is null && component is clickable;
    }

    bool canScroll(Component@ component)
    {
        return component !is null && component is scrollable;
    }

    bool isHovering(Component@ component)
    {
        return component !is null && component is hovering;
    }

    bool isInteractingWith(Component@ component)
    {
        return component !is null && component is interacting;
    }

    private void CacheComponents()
    {
        @hovering = null;
        @clickable = null;
        @scrollable = null;

        for (int i = components.size() - 1; i >= 0; i--)
        {
            TraverseComponentTree(components[i]);
        }
    }

    private void TraverseComponentTree(Component@ component)
    {
        // Component is nonexistent
        if (component is null) return;

        // Remember scrollable component and if hovering
        Component@ scroll = scrollable;
        bool hover = isHovering();

        // Traverse child components
        Component@[] children = component.getComponents();
        for (int i = children.size() - 1; i >= 0; i--)
        {
            TraverseComponentTree(children[i]);
        }

        // Reapply scrollable component if hovering
        if (hover)
        {
            @scrollable = scroll;
        }

        if (component.isHovering())
        {
            if (hovering is null)
            {
                @hovering = component;
            }

            if (clickable is null && component.canClick())
            {
                @clickable = component;
            }

            if (scrollable is null && component.canScroll())
            {
                @scrollable = component;
            }
        }
    }

    void Update()
    {
        if (!isClient()) return;

        if (interacting !is null && !controls.isKeyPressed(KEY_LBUTTON) && !controls.isKeyPressed(KEY_RBUTTON))
        {
            if (ui.canClick(interacting))
            {
                interacting.DispatchEvent("click");
            }

            interacting.DispatchEvent("release");

            @interacting = null;
        }

        CacheComponents();

        if (interacting is null && clickable !is null && (controls.isKeyJustPressed(KEY_LBUTTON) || controls.isKeyJustPressed(KEY_RBUTTON)))
        {
            @interacting = clickable;

            interacting.DispatchEvent("press");
        }

        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        if (!isClient()) return;

        CacheComponents();

        for (uint i = 0; i < components.size(); i++)
        {
            components[i].Render();
        }
    }

    void Debug(bool detailed = false)
    {
        if (!isClient()) return;

        DrawDebug(scrollable, "scrollable", SColor(255, 0, 0, 255), detailed);
        DrawDebug(clickable, "clickable", SColor(255, 255, 0, 0), detailed);
        DrawDebug(hovering, "hovering", SColor(255, 255, 165, 0), detailed);
        DrawDebug(interacting, "interacting", SColor(255, 0, 128, 0), detailed);

        if (detailed)
        {
            DrawDebugCursor();
        }
    }

    private void DrawDebug(Component@ component, string text, SColor color, bool detailed = false)
    {
        DrawDebugOutline(component, color);
        DrawDebugLabel(component, text, color, detailed);
    }

    private void DrawDebugOutline(Component@ component, SColor color)
    {
        if (component is null) return;

        Vec2f min = component.getPosition();
        Vec2f max = min + component.getBounds();
        GUI::DrawOutlinedRectangle(min, max, 2, color);
    }

    private void DrawDebugLabel(Component@ component, string text, SColor color, bool detailed = false)
    {
        if (component is null) return;

        GUI::SetFont("");

        string[] lines = { text };

        if (detailed)
        {
            lines.push_back("pos: " + component.getPosition().toString());
            lines.push_back("size: " + component.getBounds().toString());
        }

        float dimX = 0.0f;

        for (uint i = 0; i < lines.size(); i++)
        {
            Vec2f dim;
            GUI::GetTextDimensions(lines[i], dim);

            if (dim.x > dimX)
            {
                dimX = dim.x;
            }
        }

        Vec2f position = component.getPosition();
        Vec2f padding = Vec2f(2.0f, 0.0f);

        Vec2f min = position - Vec2f(0, 12 * lines.size() + padding.y * (lines.size() + 1));
        Vec2f max = position + Vec2f(dimX + padding.x * 2, 0);

        GUI::DrawRectangle(min, max, color);

        for (uint i = 0; i < lines.size(); i++)
        {
            GUI::DrawText(lines[i], min + padding - Vec2f(3, 1) + Vec2f(0, 12 * i), color_white);
        }
    }

    private void DrawDebugCursor()
    {
        Vec2f mousePos = getControls().getInterpMouseScreenPos();
        GUI::DrawRectangle(mousePos - Vec2f(1, 1), mousePos + Vec2f(1, 1), SColor(255, 255, 0, 255));
    }
}
