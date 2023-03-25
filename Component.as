interface Component
{
    void SetPosition(float x, float y);
    Component@ getHoveredComponent();
    Vec2f getBounds();
    void Update();
    void Render();
}
