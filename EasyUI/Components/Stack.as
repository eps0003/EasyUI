interface Stack : Container, MultiChild
{

}

class StandardStack : Stack, CachedBounds
{
    private Component@[] components;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

    private Vec2f innerBounds = Vec2f_zero;
    private bool calculateBounds = true;

    void AddComponent(Component@ component)
    {
        if (component is null) return;

        components.push_back(component);

        CalculateBounds();
        component.AddEventListener("resize", CachedBoundsHandler(this));
    }

    void SetMargin(float x, float y)
    {
        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        CalculateBounds();
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetPadding(float x, float y)
    {
        if (padding.x == x && padding.y == y) return;

        padding.x = x;
        padding.y = y;

        CalculateBounds();
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

    Vec2f getInnerBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;
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

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;
        DispatchEvent("resize");
    }

    bool isClickable()
    {
        return false;
    }

    bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
    }

    bool isInteracting()
    {
        return false;
    }

    bool canClick()
    {
        return false;
    }

    bool canScroll()
    {
        return false;
    }

    Component@[] getComponents()
    {
        return components;
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

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        Vec2f innerPos = position + margin + padding;
        Vec2f innerBounds = getInnerBounds();

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
