interface Stack : Container, MultiChild
{

}

class StandardStack : Stack
{
    private Component@[] components;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

    private Vec2f innerBounds = Vec2f_zero;

    void AddComponent(Component@ component)
    {
        if (component !is null)
        {
            components.push_back(component);
            CalculateInnerBounds();
        }
    }

    void SetMargin(float x, float y)
    {
        margin.x = x;
        margin.y = y;
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetPadding(float x, float y)
    {
        padding.x = x;
        padding.y = y;
    }

    Vec2f getPadding()
    {
        return padding;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    Vec2f getAlignment()
    {
        return alignment;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getPosition()
    {
        return position;
    }

    private void CalculateInnerBounds()
    {
        innerBounds.SetZero();

        for (uint i = 0; i < components.size(); i++)
        {
            Vec2f childBounds = components[i].getBounds();
            if (childBounds.x > innerBounds.x)
            {
                innerBounds.x = childBounds.x;
            }
            if (childBounds.y > innerBounds.y)
            {
                innerBounds.y = childBounds.y;
            }
        }
    }

    Vec2f getInnerBounds()
    {
        return innerBounds;
    }

    Vec2f getTrueBounds()
    {
        return padding + getInnerBounds() + padding;
    }

    Vec2f getBounds()
    {
        return margin + getTrueBounds() + margin;
    }

    bool isClickable()
    {
        return false;
    }

    Component@ getHoveredComponent()
    {
        if (isHovered())
        {
            for (int i = components.size() - 1; i >= 0; i--)
            {
                Component@ component = components[i];
                if (component is null) continue;

                Component@ hovered = component.getHoveredComponent();
                if (hovered is null) continue;

                return hovered;
            }
        }
        return null;
    }

    List@ getHoveredList()
    {
        if (isHovered())
        {
            for (int i = components.size() - 1; i >= 0; i--)
            {
                Component@ component = components[i];
                if (component is null) continue;

                List@ list = component.getHoveredList();
                if (list !is null) return list;

                Component@ hovered = component.getHoveredComponent();
                if (hovered !is null) break;
            }
        }
        return null;
    }

    void AddEventListener(string type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(string type)
    {
        events.DispatchEvent(type);
    }

    private bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
    }

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void PreRender()
    {
        for (uint i = 0; i < components.size(); i++)
        {
            components[i].PreRender();
        }

        CalculateInnerBounds();
    }

    void Render()
    {
        Vec2f innerPos = position + margin + padding;

        for (uint i = 0; i < components.size(); i++)
        {
            Component@ component = components[i];
            Vec2f bounds = component.getBounds();
            Vec2f boundsDiff = innerBounds - bounds;
            Vec2f pos = innerPos + Vec2f(boundsDiff.x * alignment.x, boundsDiff.y * alignment.y);

            component.SetPosition(pos.x, pos.y);
            component.Render();
        }
    }
}
