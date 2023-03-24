interface List : VisibleComponent, ContainerComponent
{
    void SetSpacing(float spacing);
    void SetAlignment(float x);
}

class VerticalList : List
{
    private VisibleComponent@[] components;
    private float spacing = 0.0f;
    private float alignment = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(VisibleComponent@ component)
    {
        components.push_back(component);
    }

    void SetSpacing(float spacing)
    {
        this.spacing = spacing;
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

        Vec2f bounds(0.0f, spacing * (n - 1));
        for (uint i = 0; i < n; i++)
        {
            Vec2f childBounds = components[i].getBounds();
            if (childBounds.x > bounds.x)
            {
                bounds.x = childBounds.x;
            }
            bounds.y += childBounds.y;
        }
        return bounds;
    }

    void Render()
    {
        float offset = 0.0f;
        float width = getBounds().x;

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            Vec2f bounds = component.getBounds();
            float widthDiff = width - bounds.x;

            component.SetPosition(position.x + widthDiff * alignment, position.y + offset);

            offset += bounds.y + spacing;
        }
    }
}

class HorizontalList : List
{
    private VisibleComponent@[] components;
    private float spacing = 0.0f;
    private float alignment = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(VisibleComponent@ component)
    {
        components.push_back(component);
    }

    void SetSpacing(float spacing)
    {
        this.spacing = spacing;
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

        Vec2f bounds(0.0f, spacing * (n - 1));
        for (uint i = 0; i < n; i++)
        {
            Vec2f childBounds = components[i].getBounds();
            if (childBounds.y > bounds.y)
            {
                bounds.y = childBounds.y;
            }
            bounds.x += childBounds.x;
        }
        return bounds;
    }

    void Render()
    {
        float offset = 0.0f;
        float height = getBounds().y;

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            Vec2f bounds = component.getBounds();
            float heightDiff = height - bounds.y;

            component.SetPosition(position.x + offset, position.y + heightDiff * alignment);

            offset += bounds.x + spacing;
        }
    }
}
