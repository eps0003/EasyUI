#include "Component.as"
#include "Container.as"
#include "Button.as"
#include "ToggleButton.as"
#include "Progress.as"
#include "Label.as"
#include "Icon.as"
#include "List.as"
#include "Slider.as"
#include "Stack.as"
#include "Pane.as"
#include "Utilities.as"
#include "EventListener.as"
#include "CachedBounds.as"

class EasyUI
{
    private Component@[] components;

    void AddComponent(Component@ component)
    {
        if (component !is null)
        {
            this.components.push_back(component);
        }
    }

    bool canClick(Component@ component)
    {
        return component !is null && component is getHoveredComponent();
    }

    bool canScroll(Component@ component)
    {
        return component !is null && component is getScrollableComponent();
    }

    Component@ getHoveredComponent()
    {
        Component@ hovered;

        for (int i = components.size() - 1; i >= 0; i--)
        {
            @hovered = components[i].getHoveredComponent();
            if (hovered !is null) break;
        }

        return hovered;
    }

    Component@ getScrollableComponent()
    {
        Component@ scrollable;

        for (int i = components.size() - 1; i >= 0; i--)
        {
            Component@ component = components[i];
            if (component is null) continue;

            @scrollable = component.getScrollableComponent();
            if (scrollable !is null) return scrollable;

            Component@ hovered = component.getHoveredComponent();
            if (hovered !is null) break;
        }

        return null;
    }

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        for (uint i = 0; i < components.size(); i++)
        {
            components[i].Render();
        }
    }
}
