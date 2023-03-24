interface Stack : VisibleComponent, ContainerComponent
{
    void SetAlignment(float x);
}

class StandardStack : Stack
{
    private VisibleComponent@[] components;
    private float alignment = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(VisibleComponent@ component)
    {
        components.push_back(component);
    }

    void SetAlignment(float x)
    {
        alignment = Maths::Clamp01(x);
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getBounds()
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

    void Render()
    {
        Vec2f size = getBounds();

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            Vec2f bounds = component.getBounds();
            Vec2f sizeDiff = size - bounds;
            Vec2f pos = position + sizeDiff * alignment;

            component.SetPosition(pos.x, pos.y);
        }
    }
}
