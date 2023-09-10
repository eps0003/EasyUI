interface Stack : Container, MultiChild
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
    private Vec2f stretch = Vec2f_zero;
    private Vec2f position = Vec2f_zero;

    private Vec2f minBounds = Vec2f_zero;
    private bool calculateBounds = true;

    private EventDispatcher@ events = StandardEventDispatcher();

    void AddComponent(Component@ component)
    {
        if (component is null) return;

        components.push_back(component);
        component.SetParent(this);

        CalculateBounds();
        component.AddEventListener("resize", CachedBoundsHandler(this));
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        @this.parent = parent;

        CalculateBounds();
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

    void SetPadding(float x, float y)
    {
        x = Maths::Max(0, x);
        y = Maths::Max(0, y);

        if (padding.x == x && padding.y == y) return;

        padding.x = x;
        padding.y = y;

        CalculateBounds();
    }

    Vec2f getPadding()
    {
        return padding;
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

    void SetMinSize(float width, float height)
    {
        if (minSize.x == width && minSize.y == height) return;

        minSize.x = width;
        minSize.y = height;

        CalculateBounds();
    }

    Vec2f getMinSize()
    {
        return minSize;
    }

    void SetMaxSize(float width, float height)
    {
        if (maxSize.x == width && maxSize.y == height) return;

        maxSize.x = width;
        maxSize.y = height;

        CalculateBounds();
    }

    Vec2f getMaxSize()
    {
        return maxSize;
    }

    void SetStretchRatio(float x, float y)
    {
        stretch.x = Maths::Clamp01(x);
        stretch.y = Maths::Clamp01(y);
    }

    Vec2f getStretchRatio()
    {
        return stretch;
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
        return getTruePosition() + padding;
    }

    Vec2f getMinBounds()
    {
        if (calculateBounds)
        {
            calculateBounds = false;
            minBounds.SetZero();

            for (uint i = 0; i < components.size(); i++)
            {
                Vec2f childBounds = components[i].getMinBounds();
                if (childBounds.x > minBounds.x)
                {
                    minBounds.x = childBounds.x;
                }
                if (childBounds.y > minBounds.y)
                {
                    minBounds.y = childBounds.y;
                }
            }

            minBounds += padding * 2.0f;

            minBounds.x = Maths::Max(minBounds.x, minSize.x);
            minBounds.y = Maths::Max(minBounds.y, minSize.y);

            minBounds += margin * 2.0f;
        }

        return minBounds;
    }

    Vec2f getBounds()
    {
        Vec2f outerBounds = getMinBounds();

        if (parent !is null)
        {
            Vec2f parentBounds = parent.getInnerBounds();
            parentBounds *= getStretchRatio();

            Vec2f maxBounds;
            maxBounds.x = maxSize.x != 0.0f ? Maths::Min(parentBounds.x, maxSize.x) : parentBounds.x;
            maxBounds.y = maxSize.y != 0.0f ? Maths::Min(parentBounds.y, maxSize.y) : parentBounds.y;

            outerBounds.x = Maths::Max(outerBounds.x, maxBounds.x);
            outerBounds.y = Maths::Max(outerBounds.y, maxBounds.y);
        }

        return outerBounds;
    }

    Vec2f getTrueBounds()
    {
        return getBounds() - margin * 2.0f;
    }

    Vec2f getInnerBounds()
    {
        return getTrueBounds() - padding * 2.0f;
    }

    void CalculateBounds()
    {
        if (calculateBounds) return;

        calculateBounds = true;

        DispatchEvent("resize");
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
