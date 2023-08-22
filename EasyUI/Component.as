interface Component : EventDispatcher
{
    void SetPosition(float x, float y);
    Vec2f getPosition();
    Vec2f getTruePosition();
    Vec2f getInnerPosition();

    Vec2f getMinBounds();
    Vec2f getBounds();
    Vec2f getTrueBounds();
    Vec2f getInnerBounds();
    void CalculateBounds();

    void Update();
    void Render();

    void SetMargin(float x, float y);
    Vec2f getMargin();

    bool isHovering();

    bool canClick();
    bool canScroll();

    void SetParent(Component@ parent);
    Component@[] getComponents();
}
