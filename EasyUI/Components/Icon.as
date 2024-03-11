interface Icon : Stack
{
    void SetIcon(string icon);
    string getIcon();

    void SetFrameIndex(uint index);
    uint getFrameIndex();

    void SetFrameDim(uint width, uint height);
    Vec2f getFrameDim();

    void SetCrop(float top, float right, float bottom, float left);

    void SetScale(float x, float y);
    Vec2f getScale();

    // void SetMaintainAspectRatio(bool maintain);
    // bool isMaintainingAspectRatio();

    void SetClickable(bool clickable);
}

class StandardIcon : Icon, StandardStack
{
    private string icon = "";
    private uint frameIndex = 0;
    private Vec2f frameDim = Vec2f_zero;
    private float cropTop = 0.0f;
    private float cropRight = 0.0f;
    private float cropBottom = 0.0f;
    private float cropLeft = 0.0f;
    private Vec2f scale = Vec2f(1, 1);
    private bool clickable = true;

    void SetIcon(string icon)
    {
        if (this.icon == icon) return;

        this.icon = icon;

        DispatchEvent(Event::Icon);
    }

    string getIcon()
    {
        return icon;
    }

    void SetFrameIndex(uint index)
    {
        if (frameIndex == index) return;

        frameIndex = index;

        DispatchEvent(Event::FrameIndex);
    }

    uint getFrameIndex()
    {
        return frameIndex;
    }

    void SetFrameDim(uint width, uint height)
    {
        if (frameDim.x == width && frameDim.y == height) return;

        frameDim.x = width;
        frameDim.y = height;

        DispatchEvent(Event::FrameDim);
    }

    Vec2f getFrameDim()
    {
        return frameDim;
    }

    void SetCrop(float top, float right, float bottom, float left)
    {
        if (cropTop == top && cropRight == right && cropBottom == bottom && cropLeft == left) return;

        cropTop = top;
        cropRight = right;
        cropBottom = bottom;
        cropLeft = left;

        DispatchEvent(Event::Crop);
    }

    void SetScale(float x, float y)
    {
        if (scale.x == x && scale.y == y) return;

        scale.x = x;
        scale.y = y;

        DispatchEvent(Event::Scale);
    }

    Vec2f getScale()
    {
        return scale;
    }

    void SetClickable(bool clickable)
    {
        if (this.clickable == clickable) return;

        this.clickable = clickable;

        DispatchEvent(Event::Clickable);
    }

    bool canClick()
    {
        return clickable;
    }

    bool canScroll()
    {
        return false;
    }

    private bool canRender()
    {
        return (
            icon != "" &&
            scale.x != 0.0f &&
            scale.y != 0.0f &&
            frameDim.x != 0.0f &&
            frameDim.y != 0.0f
        );
    }

    void Render()
    {
        if (canRender())
        {
            Vec2f size = getTrueBounds();

            Vec2f croppedDim;
            croppedDim.x = frameDim.x - cropLeft - cropRight;
            croppedDim.y = frameDim.y - cropTop - cropBottom;

            Vec2f scale;
            scale.x = croppedDim.x != 0.0f
                ? size.x / croppedDim.x * 0.5f
                : 0.0f;
            scale.y = croppedDim.y != 0.0f
                ? size.y / croppedDim.y * 0.5f
                : 0.0f;

            Vec2f offset = Vec2f_zero;
            offset.x = scale.x > 0.0f ? -cropLeft : frameDim.x - cropRight;
            offset.y = scale.y > 0.0f ? -cropTop : frameDim.y - cropBottom;
            offset *= Vec2f_abs(scale) * 2.0f;

            GUI::DrawIcon(icon, frameIndex, frameDim, position + offset, scale.x, scale.y, color_white);
        }

        StandardStack::Render();
    }
}
