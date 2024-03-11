interface Stack : Component, Stretch
{
    void SetMinSize(float width, float height);
    Vec2f getMinSize();

    void SetMaxSize(float width, float height);
    Vec2f getMaxSize();
}

class StackCachedMinBounds : CachedBounds, EventHandler
{
    private Stack@ stack;
    private bool recalculate = true;
    private Vec2f minBounds = Vec2f_zero;

    StackCachedMinBounds(Stack@ stack)
    {
        @this.stack = stack;
    }

    void Handle()
    {
        if (recalculate) return;

        recalculate = true;
        stack.DispatchEvent(Event::MinBounds);
    }

    Vec2f getBounds()
    {
        if (recalculate)
        {
            recalculate = false;

            minBounds.SetZero();

            Component@[] components = stack.getComponents();
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

            minBounds += stack.getPadding() * 2.0f;

            Vec2f minSize = stack.getMinSize();
            minBounds.x = Maths::Max(minBounds.x, minSize.x);
            minBounds.y = Maths::Max(minBounds.y, minSize.y);

            minBounds += stack.getMargin() * 2.0f;
        }

        return minBounds;
    }
}

class StackCachedBounds : CachedBounds, EventHandler
{
    private Stack@ stack;
    private bool recalculate = true;
    private Vec2f bounds = Vec2f_zero;

    StackCachedBounds(Stack@ stack)
    {
        @this.stack = stack;
    }

    void Handle()
    {
        if (recalculate) return;

        recalculate = true;
        stack.DispatchEvent(Event::Bounds);
    }

    Vec2f getBounds()
    {
        if (recalculate)
        {
            recalculate = false;

            bounds = stack.getMinBounds();

            Component@ parent = stack.getParent();
            Vec2f maxSize = stack.getMaxSize();

            Vec2f parentBounds = parent !is null
                ? parent.getStretchBounds(stack)
                : getDriver().getScreenDimensions() - stack.getPosition();
            parentBounds *= stack.getStretchRatio();

            Vec2f maxBounds;
            maxBounds.x = maxSize.x != 0.0f ? Maths::Min(parentBounds.x, maxSize.x) : parentBounds.x;
            maxBounds.y = maxSize.y != 0.0f ? Maths::Min(parentBounds.y, maxSize.y) : parentBounds.y;

            bounds.x = Maths::Max(bounds.x, maxBounds.x);
            bounds.y = Maths::Max(bounds.y, maxBounds.y);
        }

        return bounds;
    }
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

    private StackCachedMinBounds@ minBounds;
    private StackCachedBounds@ bounds;
    private bool calculateBounds = true;

    private EventDispatcher@ events = StandardEventDispatcher();

    StandardStack()
    {
        @minBounds = StackCachedMinBounds(this);
        AddEventListener(Event::Components, minBounds);
        AddEventListener(Event::Padding, minBounds);
        AddEventListener(Event::Margin, minBounds);
        AddEventListener(Event::MinSize, minBounds);

        @bounds = StackCachedBounds(this);
        AddEventListener(Event::Parent, bounds);
        AddEventListener(Event::MaxSize, bounds);
        AddEventListener(Event::Position, bounds);
        AddEventListener(Event::StretchRatio, bounds);
        AddEventListener(Event::MinBounds, bounds);
    }

    void AddComponent(Component@ component)
    {
        if (component is null) return;

        components.push_back(component);
        component.SetParent(this);

        DispatchEvent(Event::Components);
    }

    void SetParent(Component@ parent)
    {
        if (this.parent is parent) return;

        if (this.parent !is null)
        {
            parent.RemoveEventListener(Event::Bounds, bounds);
        }

        @this.parent = parent;

        if (this.parent !is null)
        {
            parent.AddEventListener(Event::Bounds, bounds);
        }

        DispatchEvent(Event::Parent);
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
    }

    Vec2f getMaxSize()
    {
        return maxSize;
    }

    void SetStretchRatio(float x, float y)
    {
        x = Maths::Clamp01(x);
        y = Maths::Clamp01(y);

        if (stretch.x == x && stretch.y == y) return;

        stretch.x = x;
        stretch.y = y;

        DispatchEvent(Event::StretchRatio);
    }

    Vec2f getStretchRatio()
    {
        return stretch;
    }

    void SetPosition(float x, float y)
    {
        if (position.x == x && position.y == y) return;

        position.x = x;
        position.y = y;

        DispatchEvent(Event::Position);
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
        return minBounds.getBounds();
    }

    Vec2f getBounds()
    {
        return bounds.getBounds();
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

    void CalculateBounds()
    {

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
