interface Icon : Component
{
    void SetIcon(string icon);
    string getIcon();

    void SetFrameIndex(uint index);
    uint getFrameIndex();

    void SetFrameDimension(uint width, uint height);
    Vec2f getFrameDimension();

    void SetCrop(float top, float right, float bottom, float left);

    void SetSize(float width, float height);
    Vec2f getSize();
}

class StandardIcon : Icon
{
    private string icon;
    private uint frameIndex = 0;
    private Vec2f frameDim = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private float cropTop = 0.0f;
    private float cropRight = 0.0f;
    private float cropBottom = 0.0f;
    private float cropLeft = 0.0f;
    private Vec2f scale = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventDispatcher@ events = StandardEventDispatcher();

    private void CalculateScale()
    {
        Vec2f croppedDim;
        croppedDim.x = frameDim.x - cropLeft - cropRight;
        croppedDim.y = frameDim.y - cropTop - cropBottom;

        scale.x = croppedDim.x != 0.0f
            ? size.x / croppedDim.x * 0.5f
            : 0.0f;

        scale.y = croppedDim.y != 0.0f
            ? size.y / croppedDim.y * 0.5f
            : 0.0f;
    }

    void SetIcon(string icon)
    {
        this.icon = icon;
    }

    string getIcon()
    {
        return icon;
    }

    void SetFrameIndex(uint index)
    {
        frameIndex = index;
    }

    uint getFrameIndex()
    {
        return frameIndex;
    }

    void SetFrameDimension(uint width, uint height)
    {
        if (frameDim.x == width && frameDim.y == height) return;

        frameDim.x = width;
        frameDim.y = height;

        CalculateScale();
    }

    Vec2f getFrameDimension()
    {
        return frameDim;
    }

    void SetCrop(float top, float right, float bottom, float left)
    {
        cropTop = top;
        cropRight = right;
        cropBottom = bottom;
        cropLeft = left;
    }

    void SetSize(float width, float height)
    {
        if (size.x == width && size.y == height) return;

        size.x = width;
        size.y = height;

        CalculateScale();
        DispatchEvent("resize");
    }

    Vec2f getSize()
    {
        return size;
    }

    void SetPosition(float x, float y)
    {
        position.x = x;
        position.y = y;
    }

    Vec2f getPosition()
    {
        return position;
    }

    Vec2f getBounds()
    {
        return Vec2f_abs(size);
    }

    void CalculateBounds()
    {

    }

    bool isHovering()
    {
        return isMouseInBounds(position, position + getBounds());
    }

    bool canClick()
    {
        return false;
    }

    bool canScroll()
    {
        return false;
    }

    Component@[] getComponents()
    {
        Component@[] components;
        return components;
    }

    void AddEventListener(string type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(string type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(string type)
    {
        events.DispatchEvent(type);
    }

    void Update()
    {

    }

    private bool canRender()
    {
        return (
            icon != "" &&
            size.x != 0.0f &&
            size.y != 0.0f &&
            frameDim.x != 0.0f &&
            frameDim.y != 0.0f
        );
    }

    void Render()
    {
        if (!canRender()) return;

        Vec2f offset = Vec2f_zero;
        offset.x = size.x > 0.0f ? -cropLeft : frameDim.x - cropRight;
        offset.y = size.y > 0.0f ? -cropTop : frameDim.y - cropBottom;
        offset *= Vec2f_abs(scale) * 2.0f;

        GUI::DrawIcon(icon, frameIndex, frameDim, position + offset, scale.x, scale.y, color_white);
    }
}
