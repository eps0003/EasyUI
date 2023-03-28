interface Progress : Container, SingleChild
{
    void SetSize(float width, float height);
    Vec2f getSize();

    void SetProgress(float progress);
    float getProgress();
}

class StandardProgress : Progress
{
    private string text;
    private float progress = 0.0f;
    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventListener@ events = StandardEventListener();

    void SetProgress(float progress)
    {
        progress = Maths::Clamp01(progress);

        if (this.progress == progress) return;

        this.progress = progress;

        events.DispatchEvent("change");
    }

    float getProgress()
    {
        return progress;
    }

    void SetComponent(Component@ component)
    {
        @this.component = component;
    }

    void SetAlignment(float x, float y)
    {
        alignment.x = Maths::Clamp01(x);
        alignment.y = Maths::Clamp01(y);
    }

    void SetMargin(float x, float y)
    {
        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        events.DispatchEvent("resize");
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetPadding(float x, float y)
    {
        if (padding.x == x && padding.y == y) return;

        padding.x = x;
        padding.y = y;

        events.DispatchEvent("resize");
    }

    Vec2f getPadding()
    {
        return padding;
    }

    void SetSize(float width, float height)
    {
        if (size.x == width && size.y == height) return;

        size.x = width;
        size.y = height;

        events.DispatchEvent("resize");
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

    Vec2f getInnerBounds()
    {
        return size - padding * 2.0f;
    }

    Vec2f getTrueBounds()
    {
        return size;
    }

    Vec2f getBounds()
    {
        return margin + size + margin;
    }

    Component@ getHoveredComponent()
    {
        return isHovered() ? cast<Component>(this) : null;
    }

    Component@ getScrollableComponent()
    {
        return null;
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

    private bool isHovered()
    {
        return isMouseInBounds(position, position + size);
    }

    void Update()
    {
        if (component !is null)
        {
            component.Update();
        }
    }

    void Render()
    {
        Vec2f min = position + margin;
        Vec2f max = min + size;

        GUI::DrawProgressBar(min, max, progress);

        if (component !is null)
        {
            Vec2f innerBounds = getInnerBounds();
            Vec2f pos;

            pos.x = min.x + padding.x + innerBounds.x * alignment.x;
            pos.y = min.y + padding.y + innerBounds.y * alignment.y;

            component.SetPosition(pos.x, pos.y);
            component.Render();
        }
    }
}
