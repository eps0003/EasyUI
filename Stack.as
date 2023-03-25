interface Stack : Container, MultiChild
{

}

class StandardStack : Stack
{
    private Component@[] components;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f position = Vec2f_zero;

    void AddComponent(Component@ component)
    {
        components.push_back(component);
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetMargin(float x, float y)
    {
        margin.x = x;
        margin.y = y;
    }

    void SetPadding(float x, float y)
    {
        padding.x = x;
        padding.y = y;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getInnerBounds()
    {
        uint n = components.size();
        if (n == 0) return Vec2f_zero;

        Vec2f bounds = Vec2f_zero;
        for (uint i = 0; i < n; i++)
        {
            Vec2f childBounds = components[i].getBounds();
            if (childBounds.x > bounds.x)
            {
                bounds.x = childBounds.x;
            }
            if (childBounds.y > bounds.y)
            {
                bounds.y = childBounds.y;
            }
        }
        return bounds;
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

    private bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
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

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        Vec2f innerBounds = getInnerBounds();
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
