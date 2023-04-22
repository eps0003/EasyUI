interface Icon : Component
{
    void SetIcon(string icon);
    string getIcon();

    void SetFrameIndex(uint index);
    uint getFrameIndex();

    void SetFrameDimension(uint width, uint height);
    Vec2f getFrameDimension();

    void SetSize(float width, float height);
    Vec2f getSize();
}

class StandardIcon : Icon
{
    private string icon;
    private uint frameIndex = 0;
    private Vec2f frameDim = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventDispatcher@ events = StandardEventDispatcher();

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
    }

    Vec2f getFrameDimension()
    {
        return frameDim;
    }

    void SetSize(float width, float height)
    {
        if (size.x == width && size.y == height) return;

        size.x = width;
        size.y = height;

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
        return size;
    }

    bool isHovered()
    {
        return isMouseInBounds(position, position + size);
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
            size.LengthSquared() > 0 &&
            frameDim.LengthSquared() > 0
        );
    }

    void Render()
    {
        if (!canRender()) return;

        float scaleX = size.x / frameDim.x * 0.5f;
        float scaleY = size.y / frameDim.y * 0.5f;

        GUI::DrawIcon(icon, frameIndex, frameDim, position, scaleX, scaleY, color_white);
    }
}
