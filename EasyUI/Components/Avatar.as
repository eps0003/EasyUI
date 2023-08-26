interface Avatar : Component
{
    void SetPlayer(CPlayer@ player);
    CPlayer@ getPlayer();

    void SetSize(float size);
    Vec2f getSize();

    void SetClickable(bool clickable);
}

class StandardAvatar : Avatar
{
    private Component@ parent;

    private CPlayer@ player;
    private float size = 0.0f;
    private Vec2f margin = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private bool clickable = true;

    private EventDispatcher@ events = StandardEventDispatcher();

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
    }

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

        CalculateBounds();
    }

    Vec2f getSize()
    {
        return Vec2f(size, size);
    }

    void SetMargin(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        CalculateBounds();
    }

    Vec2f getMargin()
    {
        return margin;
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

    Vec2f getTruePosition()
    {
        return getPosition() + margin;
    }

    Vec2f getInnerPosition()
    {
        return getTruePosition();
    }

    Vec2f getMinBounds()
    {
        return getBounds();
    }

    Vec2f getBounds()
    {
        return getTrueBounds() + margin * 2.0f;
    }

    Vec2f getTrueBounds()
    {
        return Vec2f_abs(getSize());
    }

    Vec2f getInnerBounds()
    {
        return getTrueBounds();
    }

    void CalculateBounds()
    {
        DispatchEvent("resize");
    }

    bool isHovering()
    {
        return ::isHovering(this);
    }

    void SetClickable(bool clickable)
    {
        this.clickable = clickable;
    }

    bool canClick()
    {
        return clickable;
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
