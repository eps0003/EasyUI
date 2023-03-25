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
#include "EventHandler.as"

class EasyUI
{
    private Component@[] components;
    private Component@ hovered;
    private bool queried = false;

    void AddComponent(Component@ component)
    {
        if (component !is null)
        {
            this.components.push_back(component);
        }
    }

    Component@ getHoveredComponent()
    {
        if (queried) return hovered;

        for (int i = components.size() - 1; i >= 0; i--)
        {
            @hovered = components[i].getHoveredComponent();
            if (hovered !is null) break;
        }

        queried = true;
        return hovered;
    }

    bool isComponentHovered(Component@ component)
    {
        return component !is null && component is getHoveredComponent();
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
        @hovered = null;
        queried = false;

        for (uint i = 0; i < components.size(); i++)
        {
            components[i].Render();
        }
    }
}
