#include "Avatar.as"
#include "Button.as"
#include "CachedBounds.as"
#include "ClickHandler.as"
#include "Component.as"
#include "Container.as"
#include "Draggable.as"
#include "DragHandle.as"
#include "EventListener.as"
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

    private Component@ hovered;
    private Component@ scrollable;
    private Component@ interacting;

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

    bool isHovered()
    {
        return hovered !is null;
    }

    bool isInteracting()
    {
        return interacting !is null;
    }

    bool hasControl()
    {
        return isHovered() || isInteracting();
    }

    bool canClick(Component@ component)
    {
        return component !is null && component is hovered;
    }

    bool canScroll(Component@ component)
    {
        return component !is null && component is scrollable;
    }

    Component@ getHoveredComponent()
    {
        return hovered;
    }

    Component@ getScrollableComponent()
    {
        return scrollable;
    }

    private void CacheComponents()
    {
        @hovered = null;
        @scrollable = null;
        @interacting = null;

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
        bool hover = isHovered();

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

        if (component.isHovered())
        {
            // Check if component is hovered
            if (hovered is null && component.canClick())
            {
                @hovered = component;
            }

            // Check if component is scrollable
            if (scrollable is null && component.canScroll())
            {
                @scrollable = component;
            }
        }

        // Check if interacting with component
        if (interacting is null && component.isInteracting())
        {
            @interacting = component;
        }
    }

    void Update()
    {
        if (!isClient()) return;

        CacheComponents();

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

    void Debug()
    {
        if (!isClient()) return;

        if (scrollable !is null)
        {
            Vec2f min = scrollable.getPosition();
            Vec2f max = min + scrollable.getBounds();
            SColor color(255, 0, 0, 255);
            GUI::DrawOutlinedRectangle(min, max, 2, color);
        }

        if (hovered !is null)
        {
            Vec2f min = hovered.getPosition();
            Vec2f max = min + hovered.getBounds();
            SColor color(255, 255, 0, 0);
            GUI::DrawOutlinedRectangle(min, max, 2, color);
        }

        if (interacting !is null)
        {
            Vec2f min = interacting.getPosition();
            Vec2f max = min + interacting.getBounds();
            SColor color(255, 0, 255, 0);
            GUI::DrawOutlinedRectangle(min, max, 2, color);
        }
    }
}
