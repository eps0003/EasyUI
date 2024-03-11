interface Stack : Component, Stretch
{
    void SetMinSize(float width, float height);
    Vec2f getMinSize();

    void SetMaxSize(float width, float height);
    Vec2f getMaxSize();
}

class StandardStack : Stack
{
    private Component@ parent;
    private Component@[] components;

    private Vec2f margin = Vec2f_zero;
    private Vec2f padding = Vec2f_zero;
    private Vec2f alignment = Vec2f_zero;
    private Vec2f minSize = Vec2f_zero;
    private Vec2f maxSize = Vec2f_zero;
    private Vec2f stretchRatio = Vec2f_zero;
    private Vec2f position = Vec2f_zero;

    private Vec2f minBounds = Vec2f_zero;
    private Vec2f bounds = Vec2f_zero;

    private bool calculateMinBounds = true;
    private bool calculateBounds = true;

    private CachedMinBoundsHandler@ minBoundsHandler;
    private CachedBoundsHandler@ boundsHandler;

    private EventDispatcher@ events = StandardEventDispatcher();

    StandardStack()
    {
        @minBoundsHandler = CachedMinBoundsHandler(this);
        @boundsHandler = CachedBoundsHandler(this);
    }

    void AddComponent(Component@ component)
    {
        if (component is null) return;

        components.push_back(component);
        component.SetParent(this);

        // If child minimum bounds changes, update my minimum bounds
        component.AddEventListener(Event::MinBounds, minBoundsHandler);

        DispatchEvent(Event::Components);
        CalculateMinBounds();
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        if (this.parent !is null)
        {
            parent.RemoveEventListener(Event::Bounds, boundsHandler);
        }

        @this.parent = parent;

        if (this.parent !is null)
        {
            // If parent bounds changes, update my bounds
            parent.AddEventListener(Event::Bounds, boundsHandler);
        }

        DispatchEvent(Event::Parent);
        CalculateBounds();
    }

    Component@ getParent()
    {
        return parent;
    }

    void SetMargin(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        DispatchEvent(Event::Margin);
        CalculateMinBounds();
    }

    Vec2f getMargin()
    {
        return margin;
    }

    void SetPadding(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (padding.x == x && padding.y == y) return;

        padding.x = x;
        padding.y = y;

        DispatchEvent(Event::Padding);
        CalculateMinBounds();
    }

    Vec2f getPadding()
    {
        return padding;
    }

    void SetAlignment(float x, float y)
    {
        x = Maths::Clamp01(x);
        y = Maths::Clamp01(y);

        if (alignment.x == x && alignment.y == y) return;

        alignment.x = x;
        alignment.y = y;

        DispatchEvent(Event::Alignment);
    }

    Vec2f getAlignment()
    {
        return alignment;
    }

    void SetMinSize(float width, float height)
    {
        width = Maths::Max(0, width);
        height = Maths::Max(0, height);

        if (minSize.x == width && minSize.y == height) return;

        minSize.x = width;
        minSize.y = height;

        DispatchEvent(Event::MinSize);
        CalculateMinBounds();
    }

    Vec2f getMinSize()
    {
        return minSize;
    }

    void SetMaxSize(float width, float height)
    {
        width = Maths::Max(0, width);
        height = Maths::Max(0, height);

        if (maxSize.x == width && maxSize.y == height) return;

        maxSize.x = width;
        maxSize.y = height;

        DispatchEvent(Event::MaxSize);
        CalculateBounds();
    }

    Vec2f getMaxSize()
    {
        return maxSize;
    }

    void SetStretchRatio(float x, float y)
    {
        x = Maths::Clamp01(x);
        y = Maths::Clamp01(y);

        if (stretchRatio.x == x && stretchRatio.y == y) return;

        stretchRatio.x = x;
        stretchRatio.y = y;

        DispatchEvent(Event::StretchRatio);
        CalculateBounds();
    }

    Vec2f getStretchRatio()
    {
        return stretchRatio;
    }

    void SetPosition(float x, float y)
    {
        if (position.x == x && position.y == y) return;

        position.x = x;
        position.y = y;

        DispatchEvent(Event::Position);

        // Position is only used when stretching to fill the screen
        if (parent is null)
        {
            CalculateBounds();
        }
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
        return getTruePosition() + padding;
    }

    Vec2f getMinBounds()
    {
        if (calculateMinBounds)
        {
            calculateMinBounds = false;

            Vec2f maxChildBounds = Vec2f_zero;
            for (uint i = 0; i < components.size(); i++)
            {
                Vec2f childBounds = components[i].getMinBounds();
                if (childBounds.x > maxChildBounds.x)
                {
                    maxChildBounds.x = childBounds.x;
                }
                if (childBounds.y > maxChildBounds.y)
                {
                    maxChildBounds.y = childBounds.y;
                }
            }

            minBounds.x = Maths::Max(maxChildBounds.x + padding.x * 2.0f, minSize.x) + margin.x * 2.0f;
            minBounds.y = Maths::Max(maxChildBounds.y + padding.y * 2.0f, minSize.y) + margin.y * 2.0f;
        }

        return minBounds;
    }

    Vec2f getBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;

            // Use method to get mininmum bounds in case it needs to be recalculated
            Vec2f minBounds = getMinBounds();

            // Stretch to fill the parent or the screen
            Vec2f stretchBounds = parent !is null
                ? parent.getStretchBounds(this)
                : getDriver().getScreenDimensions() - position;
            stretchBounds *= stretchRatio;

            // Constrain the stretch bounds within the maximum size if configured
            // This bounds ranges from (0,0) to the maximum possible bounds
            Vec2f maxBounds;
            maxBounds.x = maxSize.x != 0.0f ? Maths::Min(stretchBounds.x, maxSize.x) : stretchBounds.x;
            maxBounds.y = maxSize.y != 0.0f ? Maths::Min(stretchBounds.y, maxSize.y) : stretchBounds.y;

            // Pick the larger bounds
            bounds.x = Maths::Max(minBounds.x, maxBounds.x);
            bounds.y = Maths::Max(minBounds.y, maxBounds.y);
        }

        return bounds;
    }

    Vec2f getTrueBounds()
    {
        return getBounds() - margin * 2.0f;
    }

    Vec2f getInnerBounds()
    {
        return getTrueBounds() - padding * 2.0f;
    }

    Vec2f getStretchBounds(Component@ child)
    {
        return getInnerBounds();
    }

    void CalculateMinBounds()
    {
        if (calculateMinBounds) return;

        calculateMinBounds = true;

        DispatchEvent(Event::MinBounds);
        CalculateBounds();
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;

        DispatchEvent(Event::Bounds);
    }

    bool isHovering()
    {
        return ::isHovering(this);
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
        return components;
    }

    void AddEventListener(Event type, EventHandler@ handler)
    {
        events.AddEventListener(type, handler);
    }

    void RemoveEventListener(Event type, EventHandler@ handler)
    {
        events.RemoveEventListener(type, handler);
    }

    void DispatchEvent(Event type)
    {
        events.DispatchEvent(type);
    }

    void Update()
    {
        for (int i = components.size() - 1; i >= 0; i--)
        {
            components[i].Update();
        }
    }

    void Render()
    {
        Vec2f innerPos = getInnerPosition();
        Vec2f innerBounds = getInnerBounds();

        for (uint i = 0; i < components.size(); i++)
        {
            Component@ component = components[i];
            Vec2f childBounds = component.getBounds();
            Vec2f boundsDiff = innerBounds - childBounds;

            Vec2f childPos;
            childPos.x = innerPos.x + boundsDiff.x * alignment.x;
            childPos.y = innerPos.y + boundsDiff.y * alignment.y;

            component.SetPosition(childPos.x, childPos.y);
            component.Render();
        }
    }
}
