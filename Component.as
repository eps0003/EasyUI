interface VisibleComponent
{
    void SetPosition(float x, float y);
    void Render();
}

interface InteractableComponent
{
    void Update();
}

interface BoundedComponent : VisibleComponent
{
    void SetSize(float width, float height);
    Vec2f getSize();
}