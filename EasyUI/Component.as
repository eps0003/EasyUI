interface Component : EventListener
{
    void SetPosition(float x, float y);
    Vec2f getPosition();

    Vec2f getBounds();

    void Update();
    void Render();

    bool isHovered();
    bool canClick();
    bool canScroll();

    Component@[] getComponents();
}
