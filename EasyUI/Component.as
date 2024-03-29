interface Component : EventDispatcher
{
    void SetPosition(float x, float y);

    // The position before margin or padding are applied
    Vec2f getPosition();
    // The true position after margin is applied
    Vec2f getTruePosition();
    // The inner position after margin and padding are applied
    Vec2f getInnerPosition();

    // The minimum bounds the component can be
    // Takes into account margin, padding, and the minimum bounds of child components
    Vec2f getMinBounds();
    // The stretched bounds with margin and padding applied
    Vec2f getBounds();
    // The stretched bounds with only padding applied
    Vec2f getTrueBounds();
    // The stretched bounds before margin and padding are applied
    Vec2f getInnerBounds();
    // The bounds the child component can stretch to
    // Usually is the inner bounds except for complex layout components like lists
    Vec2f getStretchBounds(Component@ child);

    // Schedules bounds recalculation when bounds are next retrieved
    // True and inner bounds can easily be derived so don't need caching
    // These methods are called when the parent or child components are resized, or when this component is updated
    void CalculateMinBounds();
    void CalculateBounds();

    void SetMargin(float x, float y);
    Vec2f getMargin();

    void SetPadding(float x, float y);
    Vec2f getPadding();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();

    void SetStretchRatio(float x, float y);
    Vec2f getStretchRatio();

    void SetMinSize(float width, float height);
    Vec2f getMinSize();

    void SetMaxSize(float width, float height);
    Vec2f getMaxSize();

    void Update();
    void Render();

    bool isHovering();

    bool canClick();
    bool canScrollDown();
    bool canScrollUp();

    void SetParent(Component@ parent);
    Component@ getParent();

    void AddComponent(Component@ component);
    void SetComponents(Component@[] components);
    Component@[] getComponents();

    void SetVisible(bool visible);
    bool isVisible();
}
