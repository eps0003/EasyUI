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
            this.components.push_back(component);
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
        for (int i = components.size() - 1; i >= 0; i--)
        {
            Component@ component = components[i];

            @hovered = getHoveredComponent(component);
            @scrollable = getScrollableComponent(component);

            if (hovered !is null)
            {
                break;
            }
        }
    }

    private Component@ getHoveredComponent(Component@ component)
    {
        // Ignore nonexistent components
        if (component is null || !component.isHovered())
        {
            return null;
        }

        // Check if child components are hovered
        Component@[] children = component.getComponents();
        for (int i = children.size() - 1; i >= 0; i--)
        {
            Component@ hovered = getHoveredComponent(children[i]);
            if (hovered !is null)
            {
                return hovered;
            }
        }

        // Check if component is hovered
        if (component.canClick())
        {
            return component;
        }

        // Component is not hovered
        return null;
    }

    private Component@ getScrollableComponent(Component@ component)
    {
        // Ignore nonexistent components
        if (component is null || !component.isHovered())
        {
            return null;
        }

        // Check if child components are scrollable
        Component@[] children = component.getComponents();
        for (int i = children.size() - 1; i >= 0; i--)
        {
            Component@ scrollable = getScrollableComponent(children[i]);
            if (scrollable !is null)
            {
                return scrollable;
            }
        }

        // Check if component is scrollable
        if (component.canScroll())
        {
            return component;
        }

        // Component is not scrollable
        return null;
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
