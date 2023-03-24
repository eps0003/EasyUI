interface Container : Component
{
    void SetMargin(float x, float y);
    void SetPadding(float x, float y);
    Vec2f getTrueBounds();
    Vec2f getInnerBounds();
}

interface SingleContainer : Container
{
    void SetComponent(Component@ component);
}

interface MultiContainer : Container
{
    void AddComponent(Component@ component);
}
