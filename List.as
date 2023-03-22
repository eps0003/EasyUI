interface List : VisibleComponent
{
    void AddComponent(VisibleComponent@ component);
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
        Vec2f bounds = Vec2f_zero;
        uint n = components.size();
        if (n == 0) return bounds;

        for (uint i = 0; i < n; i++)
        {
            bounds += components[i].getBounds();
        }

        return bounds + Vec2f(0.0f, spacing) * (n - 1);
    }

    void Render()
    {
        float offset = 0.0f;
        float maxWidth = 0.0f;

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            float width = component.getBounds().x;
            if (width > maxWidth)
            {
                maxWidth = width;
            }
        }

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            Vec2f bounds = component.getBounds();
            float widthDiff = maxWidth - bounds.x;

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
        Vec2f bounds = Vec2f_zero;
        uint n = components.size();
        if (n == 0) return bounds;

        for (uint i = 0; i < n; i++)
        {
            bounds += components[i].getBounds();
        }

        return bounds + Vec2f(spacing, 0.0f) * (n - 1);
    }

    void Render()
    {
        float offset = 0.0f;
        float maxHeight = 0.0f;

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            float height = component.getBounds().y;
            if (height > maxHeight)
            {
                maxHeight = height;
            }
        }

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            Vec2f bounds = component.getBounds();
            float heightDiff = maxHeight - bounds.y;

            component.SetPosition(position.x + offset, position.y + heightDiff * alignment);

            offset += bounds.x + spacing;
        }
    }
}
