interface Avatar : Component
{
    void SetPlayer(CPlayer@ player);
    CPlayer@ getPlayer();

    void SetSize(float size);
    Vec2f getSize();

    void SetAlignment(float x, float y);
    Vec2f getAlignment();
}

class StandardAvatar : Avatar
{
    private CPlayer@ player;
    private float size = 0.0f;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

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

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    Vec2f getAlignment()
    {
        return alignment;
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
        return getSize();
    }

    bool isHovered()
    {
        return false;
    }

    bool isInteracting()
    {
        return false;
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

        Vec2f align, pos;

        align.x = size > 0 ? alignment.x : 1 - alignment.x;
        align.y = size > 0 ? alignment.y : 1 - alignment.y;

        pos.x = position.x - size * align.x;
        pos.y = position.y - size * align.y;

        player.drawAvatar(pos, size / 96.0f);
    }
}
