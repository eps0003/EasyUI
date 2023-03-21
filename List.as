#include "Component.as"

interface List : VisibleComponent
{
    void AddComponent(VisibleComponent@ component);
    void SetSpacing(float spacing);
}

class VerticalList : List
{
    private VisibleComponent@[] components;
    private float spacing = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(VisibleComponent@ component)
    {
        components.push_back(component);
    }

    void SetSpacing(float spacing)
    {
        this.spacing = spacing;
    }

    void SetPosition(float x, float y)
    {
        position = Vec2f(x, y);
    }

    Vec2f getBounds()
    {
        Vec2f bounds = Vec2f_zero;
        for (uint i = 0; i < components.size(); i++)
        {
            bounds += components[i].getBounds() + Vec2f(0.0f, spacing);
        }
        return bounds;
    }

    void Render()
    {
        float offset = 0.0f;

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            component.SetPosition(position.x, position.y + offset);

            offset += component.getBounds().y + spacing;
        }
    }
}

class HorizontalList : List
{
    private VisibleComponent@[] components;
    private float spacing = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(VisibleComponent@ component)
    {
        components.push_back(component);
    }

    void SetSpacing(float spacing)
    {
        this.spacing = spacing;
    }

    void SetPosition(float x, float y)
    {
        position = Vec2f(x, y);
    }

    Vec2f getBounds()
    {
        Vec2f bounds = Vec2f_zero;
        for (uint i = 0; i < components.size(); i++)
        {
            bounds += components[i].getBounds() + Vec2f(0.0f, spacing);
        }
        return bounds;
    }

    void Render()
    {
        float offset = 0.0f;

        for (uint i = 0; i < components.size(); i++)
        {
            VisibleComponent@ component = components[i];
            component.SetPosition(position.x + offset, position.y);

            offset += component.getBounds().x + spacing;
        }
    }
}
