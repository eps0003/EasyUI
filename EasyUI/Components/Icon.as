interface Icon : Stack
{
    void SetTexture(string texture);
    string getTexture();

    void SetFrameIndex(uint index);
    uint getFrameIndex();

    void SetFrameDim(uint width, uint height);
    Vec2f getFrameDim();

    void SetCrop(float top, float right, float bottom, float left);

    void SetFixedAspectRatio(bool fixed);
    bool isFixedAspectRatio();

    void SetClickable(bool clickable);
}

class StandardIcon : Icon, StandardStack
{
    private string texture = "";
    private uint frameIndex = 0;
    private Vec2f frameDim = Vec2f_zero;
    private float cropTop = 0.0f;
    private float cropRight = 0.0f;
    private float cropBottom = 0.0f;
    private float cropLeft = 0.0f;
    private bool fixedAspectRatio = true;
    private bool clickable = false;

    void SetTexture(string texture)
    {
        if (this.texture == texture) return;

        this.texture = texture;

        DispatchEvent(Event::Texture);
    }

    string getTexture()
    {
        return texture;
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

    void SetFixedAspectRatio(bool fixed)
    {
        if (fixedAspectRatio == fixed) return;

        fixedAspectRatio = fixed;

        DispatchEvent(Event::FixedAspectRatio);
    }

    bool isFixedAspectRatio()
    {
        return fixedAspectRatio;
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

    private Vec2f getCroppedFrameDim()
    {
        return Vec2f(
            frameDim.x - cropLeft - cropRight,
            frameDim.y - cropTop - cropBottom
        );
    }

    private Vec2f getScale()
    {
        Vec2f croppedFrameDim = getCroppedFrameDim();
        Vec2f trueBounds = getTrueBounds();

        Vec2f scale;
        scale.x = croppedFrameDim.x != 0.0f
            ? trueBounds.x / croppedFrameDim.x
            : 0.0f;
        scale.y = croppedFrameDim.y != 0.0f
            ? trueBounds.y / croppedFrameDim.y
            : 0.0f;

        if (fixedAspectRatio)
        {
            float minScale = Maths::Min(scale.x, scale.y);
            scale.Set(minScale, minScale);
        }

        return scale;
    }

    private Vec2f getOffset()
    {
        Vec2f trueBounds = getTrueBounds();
        Vec2f croppedFrameDim = getCroppedFrameDim();
        Vec2f scale = getScale();
        Vec2f scaledFrameDim = Vec2f(
            croppedFrameDim.x * scale.x,
            croppedFrameDim.y * scale.y
        );
        Vec2f scaledCropOffset = Vec2f(
            cropLeft * scale.x,
            cropTop * scale.y
        );

        return (trueBounds - scaledFrameDim) * 0.5f - scaledCropOffset;
    }

    private bool canRender()
    {
        return (
            isVisible() &&
            texture != "" &&
            frameDim.x != 0.0f &&
            frameDim.y != 0.0f
        );
    }

    void Render()
    {
        if (canRender())
        {
            Vec2f scale = getScale() * 0.5f;
            Vec2f offset = getOffset();

            GUI::DrawIcon(texture, frameIndex, frameDim, position + offset, scale.x, scale.y, color_white);
        }

        StandardStack::Render();
    }
}
