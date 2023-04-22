interface Progress : Container, SingleChild
{
    void SetSize(float width, float height);
    Vec2f getSize();

    void SetProgress(float progress);
    float getProgress();
}

class StandardProgress : Progress, CachedBounds
{
    private float progress = 0.0f;
    private Component@ component;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f size = Vec2f_zero;
    private Vec2f position = Vec2f_zero;
    private EventDispatcher@ events = StandardEventDispatcher();

    private Vec2f bounds = Vec2f_zero;
    private bool calculateBounds = true;
    private EventHandler@ componentResizeHandler;

    StandardProgress()
    {
        @componentResizeHandler = CachedBoundsHandler(this);
    }

    void SetProgress(float progress)
    {
        progress = Maths::Clamp01(progress);

        if (this.progress == progress) return;

        this.progress = progress;

        DispatchEvent("change");
    }

    float getProgress()
    {
        return progress;
    }

    void SetComponent(Component@ component)
    {
        @this.component = component;
    }

    Component@ getComponent()
    {
        return component;
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

    void SetMargin(float x, float y)
    {
        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        CalculateBounds();
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

        CalculateBounds();
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

        CalculateBounds();
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
        if (calculateBounds)
        {
            calculateBounds = false;

            bounds = component !is null
                ? component.getBounds()
                : Vec2f_zero;

            bounds.x = Maths::Max(bounds.x, size.x);
            bounds.y = Maths::Max(bounds.y, size.y);
        }

        return bounds;
    }

    Vec2f getTrueBounds()
    {
        return padding + getInnerBounds() + padding;
    }

    Vec2f getBounds()
    {
        return margin + getTrueBounds() + margin;
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;
        DispatchEvent("resize");
    }

    bool isHovered()
    {
        Vec2f min = position + margin;
        Vec2f max = min + getTrueBounds();
        return isMouseInBounds(min, max);
    }

    bool canClick()
    {
        return true;
    }

    bool canScroll()
    {
        return false;
    }

    Component@[] getComponents()
    {
        Component@[] components;
        if (component !is null)
        {
            components.push_back(component);
        }
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
        if (component !is null)
        {
            component.Update();
        }
    }

    void Render()
    {
        Vec2f innerBounds = getInnerBounds();
        Vec2f min = position + margin;
        Vec2f max = min + padding + innerBounds + padding;

        GUI::DrawProgressBar(min, max, progress);

        if (component !is null)
        {
            Vec2f boundsDiff = innerBounds - component.getBounds();

            Vec2f innerPos;
            innerPos.x = min.x + padding.x + boundsDiff.x * alignment.x;
            innerPos.y = min.y + padding.y + boundsDiff.y * alignment.y;

            component.SetPosition(innerPos.x, innerPos.y);
            component.Render();
        }
    }
}
