interface Avatar : Component
{
    void SetPlayer(CPlayer@ player);
    CPlayer@ getPlayer();

    void SetSize(float size);
    Vec2f getSize();
}

class StandardAvatar : Avatar
{
    private CPlayer@ player;
    private float size = 0.0f;
    private Vec2f position = Vec2f_zero;
    private EventDispatcher@ events = StandardEventDispatcher();

    void SetPlayer(CPlayer@ player)
    {
        @this.player = player;
    }

    CPlayer@ getPlayer()
    {
        return player;
    }

    void SetSize(float size)
    {
        if (this.size == size) return;

        this.size = size;

        DispatchEvent("resize");
    }

    Vec2f getSize()
    {
        return Vec2f(size, size);
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
        return Vec2f_abs(getSize());
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
        return player !is null && size != 0.0f;
    }

    void Render()
    {
        if (!canRender()) return;

        float offset = Maths::Min(size, 0.0f);
        Vec2f pos = position - Vec2f(offset, offset);

        player.drawAvatar(pos, size / 96.0f);
    }
}
