interface Component : EventListener
{
    void SetPosition(float x, float y);
    Vec2f getPosition();

    Vec2f getBounds();

    void Update();
    void PreRender();
    void Render();

    Component@ getHoveredComponent();
    Component@ getScrollableComponent();
}
