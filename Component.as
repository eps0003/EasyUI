interface Component
{
    void SetPosition(float x, float y);
    Vec2f getPosition();

    Vec2f getBounds();
    Component@ getHoveredComponent();

    void Update();
    void Render();
}
