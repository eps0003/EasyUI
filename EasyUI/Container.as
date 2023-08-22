interface Container : Component
{
    void SetStretchRatio(float x, float y);
    Vec2f getStretchRatio();

    void SetPadding(float x, float y);
    Vec2f getPadding();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();
}

interface SingleChild
{
    void SetComponent(Component@ component);
    Component@ getComponent();
}

interface MultiChild
{
    void AddComponent(Component@ component);
    Component@[] getComponents();
}
