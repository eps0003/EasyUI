interface VisibleComponent
{
    void SetPosition(float x, float y);
    Vec2f getBounds();
    void Render();
}

interface InteractableComponent
{
    void Update();
}
