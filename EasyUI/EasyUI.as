#include "Button.as"
#include "CachedBounds.as"
#include "Component.as"
#include "Container.as"
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

    void AddComponent(Component@ component)
    {
        if (component !is null)
        {
            components.push_back(component);
        }
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

        for (int i = components.size() - 1; i >= 0; i--)
        {
            TraverseComponentTree(components[i]);
        }
    }

    private void TraverseComponentTree(Component@ component)
    {
        // Exit early if components have been found
        if (hovered !is null) return;

        // Component is nonexistent
        if (component is null) return;

        // Component is not hovered
        if (!component.isHovered()) return;

        // Traverse child components
        Component@[] children = component.getComponents();
        for (int i = children.size() - 1; i >= 0; i--)
        {
            TraverseComponentTree(children[i]);

            // Exit early if hovering over child of stack component
            // Prevents scrolling components underneath the hovered component
            if (hovered !is null && cast<Stack>(component) !is null) return;
        }

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

    void Update()
    {
        CacheComponents();

        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        CacheComponents();

        for (uint i = 0; i < components.size(); i++)
        {
            components[i].Render();
        }
    }

    void Debug()
    {
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
    }
}
