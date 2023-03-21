#include "Component.as"

interface List : VisibleComponent
{
    void AddComponent(BoundedComponent@ component);
    void SetSpacing(float spacing);
}

class VerticalList : List
{
    private BoundedComponent@[] components;
    private float spacing = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(BoundedComponent@ component)
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

    void Render()
    {
        float offset = 0.0f;

        for (uint i = 0; i < components.size(); i++)
        {
            BoundedComponent@ component = components[i];
            component.SetPosition(position.x, position.y + offset);

            offset += component.getSize().y + spacing;
        }
    }
}

class HorizontalList : List
{
    private BoundedComponent@[] components;
    private float spacing = 0.0f;
    private Vec2f position = Vec2f_zero;

    void AddComponent(BoundedComponent@ component)
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

    void Render()
    {
        float offset = 0.0f;

        for (uint i = 0; i < components.size(); i++)
        {
            BoundedComponent@ component = components[i];
            component.SetPosition(position.x + offset, position.y);

            offset += component.getSize().x + spacing;
        }
    }
}
