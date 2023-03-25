interface Icon : Component
{
    void SetIcon(string icon);
    void SetFrameIndex(uint index);
    void SetFrameDimension(uint width, uint height);
    void SetSize(float width, float height);
    void SetAlignment(float x, float y);
}

class StandardIcon : Icon
{
    private string icon;
    private uint frameIndex = 0;
    private Vec2f frameDim = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;

    void SetIcon(string icon)
    {
        this.icon = icon;
    }

    void SetFrameIndex(uint index)
    {
        frameIndex = index;
    }

    void SetFrameDimension(uint width, uint height)
    {
        frameDim.x = width;
        frameDim.y = height;

        if (size.LengthSquared() == 0)
        {
            size.x = width;
            size.y = height;
        }
    }

    void SetSize(float width, float height)
    {
        size.x = width;
        size.y = height;

        if (frameDim.LengthSquared() == 0)
        {
            frameDim.x = width;
            frameDim.y = height;
        }
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getBounds()
    {
        return size;
    }

    Component@ getHoveredComponent()
    {
        return null;
    }

    void Update()
    {

    }

    void Render()
    {
        if (icon == "") return;
        if (size.LengthSquared() == 0) return;
        if (frameDim.LengthSquared() == 0) return;

        Vec2f align(
            size.x > 0 ? alignment.x : 1 - alignment.x,
            size.y > 0 ? alignment.y : 1 - alignment.y
        );
        Vec2f scale = Vec2f(size.x / frameDim.x, size.y / frameDim.y) * 0.5f;
        Vec2f pos = position - Vec2f(size.x * align.x, size.y * align.y);

        GUI::DrawIcon(icon, frameIndex, frameDim, pos, scale.x, scale.y, color_white);
    }
}
