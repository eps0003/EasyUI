interface Component
{
    void SetPosition(float x, float y);
    Vec2f getPosition();

    Vec2f getBounds();
    Component@ getHoveredComponent();
    List@ getHoveredList();

    void Update();
    void PreRender();
    void Render();
}
