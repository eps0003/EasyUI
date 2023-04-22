interface Button : Container, SingleChild
{
    void SetSize(float width, float height);
    Vec2f getSize();

    bool isPressed();
}

class StandardButton : Button, CachedBounds
{
    private EasyUI@ ui;

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

    StandardButton(EasyUI@ ui)
    {
        @this.ui = ui;
        @componentResizeHandler = CachedBoundsHandler(this);
    }

    void SetComponent(Component@ component)
    {
        @this.component = component;
    }

    Component@ getComponent()
    {
        return component;
    }

    bool isPressed()
    {
        return ui.isInteractingWith(this);
    }

    void SetMargin(float x, float y)
    {
        if (margin.x == x && margin.y == y) return;

        margin.x = x;
        margin.y = y;

        DispatchEvent("resize");
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

        DispatchEvent("resize");
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

    bool isHovering()
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

        if (ui.canClick(this))
        {
            if (isPressed())
            {
                GUI::DrawButtonPressed(min, max);
            }
            else
            {
                GUI::DrawButtonHover(min, max);
            }
        }
        else
        {
            if (isPressed())
            {
                GUI::DrawButtonHover(min, max);
            }
            else
            {
                GUI::DrawButton(min, max);
            }
        }

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
