interface Component : EventDispatcher
{
    void SetPosition(float x, float y);
    // The position before margin or padding is applied
    Vec2f getPosition();
    // The true position after margin is applied
    Vec2f getTruePosition();
    // The inner position after padding is applied
    Vec2f getInnerPosition();

    // The minimum bounds the component can be
    // Takes into account margin, padding, and the minimum bounds of child components
    Vec2f getMinBounds();
    // The bounds with margin and padding applied
    Vec2f getBounds();
    // The bounds with padding applied
    Vec2f getTrueBounds();
    // The bounds before margin and padding are applied
    Vec2f getInnerBounds();
    // The bounds the child component can stretch to
    // Usually the inner bounds except for complex layout components like lists
    Vec2f getStretchBounds(Component@ child);
    void CalculateBounds();

    void SetMargin(float x, float y);
    Vec2f getMargin();

    void SetPadding(float x, float y);
    Vec2f getPadding();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();

    void Update();
    void Render();

    bool isHovering();

    bool canClick();
    bool canScroll();

    void SetParent(Component@ parent);

    void AddComponent(Component@ component);
    Component@[] getComponents();
}

interface Stretch
{
    void SetStretchRatio(float x, float y);
    Vec2f getStretchRatio();
}
