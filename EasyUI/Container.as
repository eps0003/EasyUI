interface Container : Component
{
    void AddComponent(Component@ component);

    void SetPadding(float x, float y);
    Vec2f getPadding();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();
}

interface Stretch
{
    void SetStretchRatio(float x, float y);
    Vec2f getStretchRatio();
}
