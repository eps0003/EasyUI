interface Container : Component
{
    void SetMargin(float x, float y);
    Vec2f getMargin();

    void SetPadding(float x, float y);
    Vec2f getPadding();

    Vec2f getTrueBounds();
    Vec2f getInnerBounds();
}

interface SingleChild
{
    void SetComponent(Component@ component);
    Component@ getComponent();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();
}

interface MultiChild
{
    void AddComponent(Component@ component);
    Component@[] getComponents();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();
}
